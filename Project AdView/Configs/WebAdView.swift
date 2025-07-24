import Didomi
import SwiftUI
import WebKit

import Combine // NEW: Import Combine

// MARK: - Debug Helper
private func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    // Get the debug settings from the environment or use a default
    // Since we can't easily access @EnvironmentObject in a global function,
    // we'll check UserDefaults directly
    let isDebugEnabled = UserDefaults.standard.bool(forKey: "isDebugEnabled")
    if isDebugEnabled {
        print(items, separator: separator, terminator: terminator)
    }
}

// MARK: - AdLoadState (Moved here)
enum AdLoadState: String, CaseIterable, Equatable, Identifiable {
    var id: String { self.rawValue }
    case notLoaded
    case fetched
    case displayed
    case unloaded
}

// NEW: Define environment key for the LazyLoadingManager
struct AdVisibilityManagerKey: EnvironmentKey {
    static let defaultValue: LazyLoadingManager? = nil // LazyLoadingManager will be defined in a separate file
}

extension EnvironmentValues {
    var adVisibilityManager: LazyLoadingManager? {
        get { self[AdVisibilityManagerKey.self] }
        set { self[AdVisibilityManagerKey.self] = newValue }
    }
}

// NEW: Helper for Publishers (needed for .onReceive with optional manager)
extension Publisher {
    static func empty() -> AnyPublisher<Output, Failure> {
        Empty().eraseToAnyPublisher()
    }
}

// MARK: - Preference Keys for Geometry Tracking (Moved here from previous LazyLoadAdModifier.swift)
struct AdFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

struct ScrollViewBoundsPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

//MARK: WebAdView
struct WebAdView: View {
    // Suppress Didomi web notice via query string
    private let baseURL = "https://adops.stepdev.dk/wp-content/ad-template.html?didomi-disable-notice=true"
    let adUnitId: String
    @EnvironmentObject var debugSettings: DebugSettings

    //MARK: Ad label properties
    var showAdLabel: Bool = false
    var adLabelText: String = "annonce"
    var adLabelFont: Font = .system(size: 10, weight: .bold)

    // Dynamic ad size state
    @State private var adSize: CGSize

    // Initial and constraint properties
    var initialWidth: CGFloat
    var initialHeight: CGFloat
    var minWidth: CGFloat?
    var maxWidth: CGFloat?
    var minHeight: CGFloat?
    var maxHeight: CGFloat?

    // NEW: Environment variable for lazy loading manager
    @Environment(\.adVisibilityManager) var adVisibilityManager
    // NEW: Internal state for ad loading, managed by the AdVisibilityManager
    @State private var loadState: AdLoadState = .notLoaded
    // NEW: Internal WKWebView instance to manage lifecycle
    @State private var webViewInstance: WKWebView?

    /// Initializes a new instance of the WebAdView with the specified configuration.
    /// - Parameters:
    ///   - adUnitId: The unique identifier for the ad unit.
    ///   - showAdLabel: A boolean indicating whether to show an ad label. Defaults to `false`.
    ///   - adLabelText: The text for the ad label. Defaults to "annonce".
    ///   - adLabelFont: The font for the ad label. Defaults to `.system(size: 10, weight: .bold)`.
    ///   - initialWidth: The initial width of the ad view.
    ///   - initialHeight: The initial height of the ad view.
    ///   - minWidth: The minimum width constraint for the ad view.
    ///   - maxWidth: The maximum width constraint for the ad view.
    ///   - minHeight: The minimum height constraint for the ad view.
    ///   - maxHeight: The maximum height constraint for the ad view.
    init(
        adUnitId: String,
        showAdLabel: Bool = false,
        adLabelText: String = "annonce",
        adLabelFont: Font = .system(size: 10, weight: .bold),
        initialWidth: CGFloat = 320,
        initialHeight: CGFloat = 320,
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) {
        self.adUnitId = adUnitId
        self.showAdLabel = showAdLabel
        self.adLabelText = adLabelText
        self.adLabelFont = adLabelFont
        self.initialWidth = initialWidth
        self.initialHeight = initialHeight
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        _adSize = State(initialValue: CGSize(width: initialWidth, height: initialHeight))
    }

    // MARK: - Ad Label Modifier
    func showAdLabel(_ show: Bool = true, text: String = "annonce", font: Font = .system(size: 10, weight: .bold)) -> WebAdView {
        var copy = self
        copy.showAdLabel = show
        copy.adLabelText = text
        copy.adLabelFont = font
        return copy
    }

    var body: some View {
        VStack(spacing: 0) {
            if showAdLabel {
                Text(adLabelText)
                    .font(adLabelFont)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
            }
            // Only render WebViewRepresentable if loadState indicates it should exist
            if loadState != .notLoaded && loadState != .unloaded {
                WebViewRepresentable(
                    adUnitId: adUnitId,
                    baseURL: baseURL,
                    onAdSizeChange: { size in
                        let clampedWidth = min(max(size.width, minWidth ?? size.width), maxWidth ?? size.width)
                        let clampedHeight = min(max(size.height, minHeight ?? size.height), maxHeight ?? size.height)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.adSize = CGSize(width: clampedWidth, height: clampedHeight)
                        }
                    }
                )
                .environmentObject(debugSettings)
                .frame(
                    width: adSize.width,
                    height: adSize.height
                )
            } else {
                // Placeholder when not loaded or unloaded
                Color.clear
                    .frame(width: initialWidth, height: initialHeight)
            }
        }
        .id(adUnitId) // Use adUnitId as stable ID for individual ad units
        // Observe adUnitId's state from the manager via onReceive
        .onReceive(adVisibilityManager?.adStatesPublisher(for: adUnitId) ?? .empty()) { newState in
            debugPrint("[SN] [LLM] WebAdView \(adUnitId): Received new state from manager: \(newState.rawValue)")
            self.loadState = newState // Update internal state based on manager
        }
        // React to changes in the internal loadState to trigger webView actions
        .onChange(of: loadState) { _, newValue in handleLoadStateChange(newValue) }
        .background(
            // Report own frame up to the manager using a GeometryReader and PreferenceKey
            GeometryReader { geometry in
                Color.clear.preference(
                    key: AdFramePreferenceKey.self,
                    value: [adUnitId: geometry.frame(in: .global)]
                )
            }
        )
    }

    // Helper to create WKWebView instance (not yet used)
    private func createWebViewInstance() -> WKWebView {
        _ = WebAdViewController(baseURL: baseURL, adUnitId: adUnitId, debugSettings: debugSettings)
        return self.webViewInstance!
    }

    // Handle state transitions for ad loading
    private func handleLoadStateChange(_ newState: AdLoadState) {
        debugPrint("[SN] [LLM] WebAdView \(adUnitId): Handling state change to \(newState.rawValue)")
        
        // Trigger ad rendering when state becomes .displayed
        if newState == .displayed {
            // Note: This will be called on each WebAdView when it becomes displayed
            // The actual rendering trigger will happen in the WebAdViewController
        }
    }
}

// MARK: - Internal UIViewControllerRepresentable
private struct WebViewRepresentable: UIViewControllerRepresentable {
    let adUnitId: String
    let baseURL: String
    var onAdSizeChange: ((CGSize) -> Void)?
    @EnvironmentObject var debugSettings: DebugSettings
    @Environment(\.adVisibilityManager) private var adVisibilityManager

    func makeUIViewController(context: Context) -> WebAdViewController {
        let controller = WebAdViewController(baseURL: baseURL, adUnitId: adUnitId, debugSettings: debugSettings)
        controller.onAdSizeChange = onAdSizeChange
        let id = ObjectIdentifier(controller).hashValue
        debugPrint("[SN] [LLM] WebAdView.makeUIViewController: Created controller [\(id)] with adUnitId: \(adUnitId)")
        
        // Set up lazy loading state observation
        if let manager = adVisibilityManager {
            controller.setupLazyLoadingObserver(manager: manager)
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: WebAdViewController, context: Context) {
        // No-op for static URL
    }

    static func dismantleUIViewController(_ uiViewController: WebAdViewController, coordinator: ()) {
        let id = ObjectIdentifier(uiViewController).hashValue
        debugPrint("[SN] [LLM] WebAdView.dismantleUIViewController: Dismantling controller [\(id)]")
        uiViewController.unloadWebView()
    }
}

// Move extension View and LazyLoadAdInternalModifier to file scope
extension View {
    /// Applies lazy loading behavior to a ScrollView's content with default thresholds.
    /// - Parameter enabled: Whether to enable lazy loading behavior. When true, uses default thresholds.

    func lazyLoadAd(_ enabled: Bool = true) -> some View {
        Group {
            if enabled {
                self.modifier(LazyLoadAdInternalModifier(fetchThreshold: 800, displayThreshold: 200, unloadThreshold: 1600))
            } else {
                self
            }
        }
    }
    
    /// Applies lazy loading behavior to a ScrollView's content, managing the lifecycle of contained WebAdViews.
    /// - Parameters:
    ///   - fetchThreshold: Distance from the screen edge (in points) when an ad should start fetching content.
    ///   - displayThreshold: Distance from the screen edge (in points) when an ad should fully display.
    ///   - unloadThreshold: Distance from the screen edge (in points) when an ad should unload (deallocate) to save resources.
    func lazyLoadAd(fetchThreshold: CGFloat, displayThreshold: CGFloat, unloadThreshold: CGFloat) -> some View {
        self.modifier(LazyLoadAdInternalModifier(fetchThreshold: fetchThreshold, displayThreshold: displayThreshold, unloadThreshold: unloadThreshold))
    }
}

private struct LazyLoadAdInternalModifier: ViewModifier {
    @StateObject private var manager: LazyLoadingManager // Manager instance for this ScrollView

    let fetchThreshold: CGFloat
    let displayThreshold: CGFloat
    let unloadThreshold: CGFloat

    init(fetchThreshold: CGFloat, displayThreshold: CGFloat, unloadThreshold: CGFloat) {
        self.fetchThreshold = fetchThreshold
        self.displayThreshold = displayThreshold
        self.unloadThreshold = unloadThreshold
        _manager = StateObject(wrappedValue: LazyLoadingManager())
    }

    func body(content: Content) -> some View {
        content
            // Capture ScrollView bounds using a GeometryReader as an overlay
            .overlay(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollViewBoundsPreferenceKey.self,
                        value: proxy.frame(in: .global)
                    )
                }
            )
            // Observe preferences and update manager
            .onPreferenceChange(ScrollViewBoundsPreferenceKey.self) { bounds in
                manager.updateScrollViewBounds(bounds)
            }
            .onPreferenceChange(AdFramePreferenceKey.self) { frames in
                // Iterate through reported frames and update manager
                for (adId, frame) in frames {
                    manager.updateAdFrame(adId, frame: frame)
                }
            }
            // Inject the manager into the environment for WebAdViews
            .environment(\.adVisibilityManager, manager)
            .onAppear { 
                manager.fetchThreshold = fetchThreshold
                manager.displayThreshold = displayThreshold
                manager.unloadThreshold = unloadThreshold
                // Force initial check in case ads are immediately visible
                manager.updateScrollViewBounds(manager.scrollViewBounds)
                manager.adUnitFrames.forEach { manager.updateAdFrame($0.key, frame: $0.value) }
            }
    }
}

//MARK: WebAdViewController
class WebAdViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    //MARK: Callback for ad size changes
    var onAdSizeChange: ((CGSize) -> Void)?
    private let baseURL: String
    private let adUnitId: String
    private var debugSettings: DebugSettings
    var webView: WKWebView!
    private var hasLoadedContent = false
    private var initialURL: URL?
    
    // NEW: Lazy loading state observation
    private var lazyLoadingCancellable: AnyCancellable?

    init(baseURL: String, adUnitId: String, debugSettings: DebugSettings) {
        self.baseURL = baseURL
        self.adUnitId = adUnitId
        self.debugSettings = debugSettings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("[SN] [NATIVE] init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        checkConsentAndLoad()
    }
    
    // MARK: Setup Lazy Loading Observer
    func setupLazyLoadingObserver(manager: LazyLoadingManager) {
        lazyLoadingCancellable = manager.adStatesPublisher(for: adUnitId)
            .sink { [weak self] newState in
                guard let self = self else { return }
                debugPrint("[SN] [LLM] WebAdViewController[\(ObjectIdentifier(self).hashValue)]: Received state change to \(newState.rawValue) for \(self.adUnitId)")
                
                // Trigger ad rendering when state becomes .displayed
                if newState == .displayed && self.hasLoadedContent {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.triggerAdRendering()
                    }
                }
            }
    }

    //MARK: Consent holdback
    private func checkConsentAndLoad() {
        // First check if consent is already given
        if Didomi.shared.isReady() && !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
            self.loadAdContent()
            debugPrint("[SN] [NATIVE] WebAdViewController: Consent already given, loading WebAdViews")
            return
        }
        
        // Listen for consent events
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("DidomiConsentChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            if !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
                self.loadAdContent()
                debugPrint("[SN] [NATIVE] WebAdViewController: Consent changed")
            }
        }
        
        // Also listen for when SDK becomes ready (in case it wasn't ready yet)
        Didomi.shared.onReady {
            DispatchQueue.main.async {
                if !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
                    self.loadAdContent()
                    debugPrint("[SN] [NATIVE] WebAdViewController: Consent onReady, loading WebAdViews")
                }
            }
        }
    }

    deinit {
        let id = ObjectIdentifier(self).hashValue
        debugPrint("[SN] [LLM] WebAdViewController[\(id)]: deinit called")
        // Remove notification observer
        NotificationCenter.default.removeObserver(self)
        // Cancel lazy loading subscription
        lazyLoadingCancellable?.cancel()
    }
    //MARK: Unload WebView
    func unloadWebView() {
        webView?.stopLoading()
        webView?.removeFromSuperview()
        webView = nil
        let id = ObjectIdentifier(self).hashValue
        debugPrint("[SN] [LLM] WebAdViewController[\(id)]: Unloaded WebView")
    }
    //MARK: Setup WebView
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Add user content controller and register JS bridge handler
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "nativeBridge")
        config.userContentController = userContentController

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Disable scrolling in the webview so the ad is never scrollable inside the webview
        webView.scrollView.isScrollEnabled = false

        // Set delegates for click handling
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.addSubview(webView)
        debugPrint("[SN] [NATIVE] WebAdViewController: WebView setup")
    }

    // MARK: HTML WKScriptMessageHandler - JS Bridge
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dict = message.body as? [String: Any], let type = dict["type"] as? String {
            if type == "console" {
                let level = dict["level"] as? String ?? "log"
                let msg = dict["message"] as? String ?? ""
                debugPrint("[SN] [WebAdView] [HTML] [\(level.uppercased())] \(msg)")
            } else if type == "adSize" {
                if let width = dict["width"] as? CGFloat, let height = dict["height"] as? CGFloat {
                    debugPrint("[SN] [WebAdView] [HTML] [adSize] width: \(width), height: \(height)")
                    onAdSizeChange?(CGSize(width: width, height: height))
                }
            } else {
                debugPrint("[SN] [WebAdView] [HTML] [Unknown type]", dict)
            }
        } else {
            debugPrint("[SN] [WebAdView] [HTML] ", message.body)
        }
    }

    // MARK: Native → Web Communication
    func sendJavaScript(_ js: String) {
        webView?.evaluateJavaScript(js) { result, error in
            if let error = error {
                debugPrint("[SN] [WebAdView] [NATIVE] Error:", error)
            } else {
                debugPrint("[SN] [WebAdView] [NATIVE] JS Result:", result ?? "nil")
            }
        }
    }

    // MARK: Trigger Ad Rendering with LL
    func triggerAdRendering() {
        guard let webView = webView else {
            debugPrint("[SN] [LLM] WebAdViewController[\(ObjectIdentifier(self).hashValue)]: Cannot trigger ad rendering - WebView is nil")
            return
        }
        
        let triggerAdJS = """
        if (window.ayManager && typeof ayManager.dispatchManualEvent === 'function') {
            ayManager.dispatchManualEvent();
            console.log('[LLM] Triggered manual ad render event for unit: \(adUnitId)');
        } else {
            console.log('[LLM] ayManager.dispatchManualEvent not available for unit: \(adUnitId)');
        }
        """
        
        debugPrint("[SN] [LLM] WebAdViewController[\(ObjectIdentifier(self).hashValue)]: Triggering ad rendering for \(adUnitId)")
        webView.evaluateJavaScript(triggerAdJS) { result, error in
            if let error = error {
                debugPrint("[SN] [LLM] WebAdViewController: Error triggering ad rendering:", error)
            } else {
                debugPrint("[SN] [LLM] WebAdViewController: Successfully triggered ad rendering for \(self.adUnitId)")
            }
        }
    }

    //MARK: Load ad content
    func loadAdContent() {
        guard !hasLoadedContent else { return }
        guard let webView = webView else { return }
        hasLoadedContent = true

        //MARK: Inject Didomi consent
        let didomiJavaScriptCode = Didomi.shared.getJavaScriptForWebView()
        let userScript = WKUserScript(source: didomiJavaScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)

        //MARK: Debugging script
        let debuggingPanel = """
            (function() {
                // Create debug info panel
                var debugInfo = document.createElement('div');
                debugInfo.id = 'debugInfo';
                debugInfo.className = 'debug-info';

                // Ad unit info
                var adUnitDiv = document.createElement('div');
                adUnitDiv.id = 'adUnitInfo';
                adUnitDiv.textContent = 'Ad unit: ' + (window.stepnetwork && window.stepnetwork.adUnitId ? window.stepnetwork.adUnitId : '(not set)');
                debugInfo.appendChild(adUnitDiv);

                // Recheck adUnitId every 100ms, up to 5 times
                (function() {
                    var attempts = 0;
                    var maxAttempts = 5;
                    var interval = setInterval(function() {
                        attempts++;
                        var adUnitId = (window.stepnetwork && window.stepnetwork.adUnitId) ? window.stepnetwork.adUnitId : null;
                        if (adUnitId) {
                            adUnitDiv.textContent = 'Ad unit: ' + adUnitId;
                            clearInterval(interval);
                        } else if (attempts >= maxAttempts) {
                            adUnitDiv.textContent = 'Ad unit: unknown';
                            clearInterval(interval);
                        }
                    }, 100);
                })();
                
                // Ad size info
                var adSizeDiv = document.createElement('div');
                adSizeDiv.id = 'adSizeInfo';
                adSizeDiv.textContent = 'Size: (not sent)';
                debugInfo.appendChild(adSizeDiv);

                // Create Google Publisher Console button container
                var googleButton = document.createElement('div');
                googleButton.id = 'GoogleButton';

                // Create the button itself
                var button = document.createElement('a');
                button.href = '#';
                button.id = 'bookmarklet-button';
                button.textContent = 'Console';

                // Add click handler to open the publisher console
                button.addEventListener('click', function(event) {
                    event.preventDefault();
                    if (window.googletag && typeof googletag.openConsole === 'function') {
                        googletag.openConsole();
                    } else {
                        alert('Google Publisher Console is not available.');
                    }
                });

                // Assemble the elements
                googleButton.appendChild(button);
                debugInfo.appendChild(googleButton);

                // Add the debug panel to the body
                document.body.appendChild(debugInfo);

                // Patch sendAdSizeToNative to update the debug panel
                var origSendAdSizeToNative = window.sendAdSizeToNative;
                window.sendAdSizeToNative = function(width, height) {
                    if (adSizeDiv) {
                        adSizeDiv.textContent = 'Size: ' + width + ' x ' + height;
                    }
                    if (typeof origSendAdSizeToNative === 'function') {
                        origSendAdSizeToNative(width, height);
                    }
                };
            })();

            (function() {
                var methods = ['log', 'info', 'warn', 'error', 'debug'];
                methods.forEach(function(level) {
                    var original = console[level];
                    console[level] = function() {
                        var args = Array.prototype.slice.call(arguments);
                        // Remove %c and its style argument
                        if (typeof args[0] === 'string' && args[0].includes('%c')) {
                            args[0] = args[0].replace(/%c/g, '').trim();
                            args.splice(1, 1); // Remove the style string
                        }
                        // Pretty-print objects/arrays, join with newlines for readability
                        var message = args.map(function(arg) {
                            if (typeof arg === 'object' && arg !== null) {
                                try { return JSON.stringify(arg, null, 2); } catch (e) { return '[Object]'; }
                            }
                            return String(arg);
                        }).join(' - ');
                        window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeBridge.postMessage({
                            type: 'console',
                            level: level,
                            message: message
                        });
                        if (original) original.apply(console, arguments);
                    };
                });
            })();

            window.googletag = window.googletag || {};
            googletag.cmd = googletag.cmd || [];
            
            googletag.cmd.push(function () {
                // Set page-level targeting
                googletag.pubads().setTargeting('yb_target', 'alwayson-standard');
            });
        """
        if debugSettings.isDebugEnabled {
            let debuggingPanelScript = WKUserScript(source: debuggingPanel, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(debuggingPanelScript)
        }

        //MARK: AdunitId injection
        let adUnitIdJS = """
        window.stepnetwork = window.stepnetwork || {}; window.stepnetwork.adUnitId = '\(self.adUnitId)';
        console.log('Injected adUnitId to JS, value: ' + window.stepnetwork.adUnitId);
        """
        let adUnitIdScript = WKUserScript(source: adUnitIdJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(adUnitIdScript)
        debugPrint("[SN] [NATIVE] Injected adUnitId to JS (window.stepnetwork.adUnitId): \(self.adUnitId)")

        // Generate random value from UUID
        let randomValue = UUID().uuidString
        var urlString = baseURL
        
        // Append &aym_debug=true if debugging is enabled
        if debugSettings.isDebugEnabled {
            if urlString.contains("?") {
                urlString += "&aym_debug=true"
            } else {
                urlString += "?aym_debug=true"
            }
        }
        // Append random value to avoid caching
        if urlString.contains("?") {
            urlString += "&rnd=\(randomValue)"
        } else {
            urlString += "?rnd=\(randomValue)"
        }

        // Create the URL from the added Query parameters
        guard let url = URL(string: urlString) else { return }

        initialURL = url  // Track the initial URL for domain comparison
        let request = URLRequest(url: url)
        webView.navigationDelegate = self // Ensure delegate is set
        webView.load(request)
        let id = ObjectIdentifier(self).hashValue
        debugPrint("[SN] [NATIVE] WebAdViewController[\(id)]: Loading URL \(url)")
    }
    
    //MARK: WKUIDelegate - Handle target="_blank" clicks
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        // Handle popup windows by opening externally
        if let url = navigationAction.request.url {
            handleExternalURL(url)
            debugPrint("[SN] [NATIVE] External URL handler: Popup window opened externally.")
        }
    
        return nil
    }
    
    //MARK: WKNavigationDelegate - Handle navigation decisions
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let shouldHandleExternally = shouldHandleExternally(navigationAction: navigationAction, initialURL: initialURL)
        if shouldHandleExternally {
            handleExternalURL(navigationAction.request.url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    //MARK: External URL Handler - Based on working model
    private func shouldHandleExternally(navigationAction: WKNavigationAction, initialURL: URL?) -> Bool {
        guard let targetURL = navigationAction.request.url else {
            debugPrint("[SN] [NATIVE] External URL handler: No target URL found")
            return false
        }
        
        // Always handle non-HTTP/HTTPS schemes externally
        if let scheme = targetURL.scheme, !["http", "https"].contains(scheme.lowercased()) {
            return true
        }
        
        // Handle popup windows externally (target="_blank")
        if navigationAction.targetFrame == nil {
            debugPrint("[SN] [NATIVE] External URL handler: Popup window detected")
            return true
        }
        
        // Handle different domain navigation externally (only for main frame)
        if let initialURL = initialURL,
           let initialDomain = initialURL.host,
           let targetDomain = targetURL.host,
           initialDomain != targetDomain,
           navigationAction.targetFrame?.isMainFrame == true {
            debugPrint("[SN] [NATIVE] External URL handler: External domain detected: \(initialDomain) -> \(targetDomain)")
            return true
        }
        
        return false
    }
    
    private func handleExternalURL(_ url: URL?) {
        guard let url = url else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:]) { success in
            }
        }
    }
}
