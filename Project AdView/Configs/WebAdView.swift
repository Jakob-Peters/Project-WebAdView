import Didomi
import SwiftUI
import WebKit

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

//MARK: WebAdView
struct WebAdView: UIViewControllerRepresentable {
    // Suppress Didomi web notice via query string
    private let baseURL = "https://adops.stepdev.dk/wp-content/ad-template.html?didomi-disable-notice=true&aym_debug=true"
    let adUnitId: String
    @EnvironmentObject var debugSettings: DebugSettings

    init(adUnitId: String) {
        self.adUnitId = adUnitId
    }

    func makeUIViewController(context: Context) -> WebAdViewController {
        let controller = WebAdViewController(baseURL: baseURL, adUnitId: adUnitId, debugSettings: debugSettings)
        let id = ObjectIdentifier(controller).hashValue
        debugPrint("[SN] [NATIVE] WebAdView.makeUIViewController: Created controller [\(id)] with adUnitId: \(adUnitId)")
        return controller
    }

    func updateUIViewController(_ uiViewController: WebAdViewController, context: Context) {
        // No-op for static URL
    }

    static func dismantleUIViewController(_ uiViewController: WebAdViewController, coordinator: ()) {
        let id = ObjectIdentifier(uiViewController).hashValue
        debugPrint("[SN] [NATIVE] WebAdView.dismantleUIViewController: Dismantling controller [\(id)]")
        uiViewController.unloadWebView()
    }
}

//MARK: WebAdViewController

class WebAdViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    private let baseURL: String
    private let adUnitId: String
    private var debugSettings: DebugSettings
    var webView: WKWebView!
    private var hasLoadedContent = false
    private var initialURL: URL?

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
        debugPrint("[SN] [NATIVE] WebAdViewController[\(id)]: deinit called")
        // Remove notification observer
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: Unload WebView
    func unloadWebView() {
        webView?.stopLoading()
        webView?.removeFromSuperview()
        webView = nil
        let id = ObjectIdentifier(self).hashValue
        debugPrint("[SN] [NATIVE] WebAdViewController[\(id)]: Unloaded WebView")
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

        // Set delegates for click handling
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.addSubview(webView)
        debugPrint("[SN] [NATIVE] WebAdViewController: WebView setup")
    }

    // MARK: HTML WKScriptMessageHandler - JS Bridge
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dict = message.body as? [String: Any],
           let type = dict["type"] as? String, type == "console" {
            let level = dict["level"] as? String ?? "log"
            let msg = dict["message"] as? String ?? ""
            debugPrint("[SN] [WebAdView] [HTML] [\(level.uppercased())] \(msg)")
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

    //MARK: Load ad content
    func loadAdContent() {
        guard !hasLoadedContent else { return }
        guard let webView = webView else { return }
        hasLoadedContent = true

        // JS injections START 
        // Inject Didomi consent at document start using WKUserScript
        let didomiJavaScriptCode = Didomi.shared.getJavaScriptForWebView()
        let userScript = WKUserScript(source: didomiJavaScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)

        let debuggingPanel = """
            (function() {
                // Create debug info panel
                var debugInfo = document.createElement('div');
                debugInfo.id = 'debugInfo';
                debugInfo.className = 'debug-info';

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
        

        // Inject adUnitId as a WKUserScript at document start
        let adUnitIdJS = """
        window.stepnetwork = window.stepnetwork || {}; window.stepnetwork.adUnitId = '\(self.adUnitId)';
        console.log('Injected adUnitId to JS, value: ' + window.stepnetwork.adUnitId);
        """
        let adUnitIdScript = WKUserScript(source: adUnitIdJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(adUnitIdScript)
        debugPrint("[SN] [NATIVE] Injected adUnitId to JS (window.stepnetwork.adUnitId): \(self.adUnitId)")

        // JS injections END


        // Add random query param to avoid caching
        let randomValue = UUID().uuidString
        var urlString = baseURL
        if urlString.contains("?") {
            urlString += "&rnd=\(randomValue)"
        } else {
            urlString += "?rnd=\(randomValue)"
        }

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
