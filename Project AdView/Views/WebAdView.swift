import Didomi
import SwiftUI
import WebKit

//MARK: WebAdView
struct WebAdView: UIViewControllerRepresentable {
    // Suppress Didomi web notice via query string
    private let baseURL = "https://adops.stepdev.dk/wp-content/ad-template.html?didomi-disable-notice=true"

    func makeUIViewController(context: Context) -> WebAdViewController {
        let controller = WebAdViewController(baseURL: baseURL)
        let id = ObjectIdentifier(controller).hashValue
        print("[SN] [NATIVE] WebAdView.makeUIViewController: Created controller [\(id)]")
        return controller
    }

    func updateUIViewController(_ uiViewController: WebAdViewController, context: Context) {
        // No-op for static URL
    }

    static func dismantleUIViewController(_ uiViewController: WebAdViewController, coordinator: ()) {
        let id = ObjectIdentifier(uiViewController).hashValue
        print("[SN] [NATIVE] WebAdView.dismantleUIViewController: Dismantling controller [\(id)]")
        uiViewController.unloadWebView()
    }
}

//MARK: WebAdViewController
class WebAdViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    private let baseURL: String
    var webView: WKWebView!
    private var hasLoadedContent = false
    private var initialURL: URL?

    init(baseURL: String) {
        self.baseURL = baseURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            print("[SN] [NATIVE] WebAdViewController: Consent already given, loading WebAdViews")
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
                print("[SN] [NATIVE] WebAdViewController: Consent changed")
            }
        }
        
        // Also listen for when SDK becomes ready (in case it wasn't ready yet)
        Didomi.shared.onReady {
            DispatchQueue.main.async {
                if !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
                    self.loadAdContent()
                    print("[SN] [NATIVE] WebAdViewController: Consent onReady, loading WebAdViews")
                }
            }
        }
    }

    deinit {
        let id = ObjectIdentifier(self).hashValue
        print("[SN] [NATIVE] WebAdViewController[\(id)]: deinit called")
        // Remove notification observer
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: Unload WebView
    func unloadWebView() {
        webView?.stopLoading()
        webView?.removeFromSuperview()
        webView = nil
        let id = ObjectIdentifier(self).hashValue
        print("[SN] [NATIVE] WebAdViewController[\(id)]: Unloaded WebView")
    }
    //MARK: Setup WebView
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Set delegates for click handling
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        print("[SN] [NATIVE] WebAdViewController: WebView setup")
    }
    //MARK: Load ad content
    func loadAdContent() {
        guard !hasLoadedContent else { return }
        guard let webView = webView else { return }
        hasLoadedContent = true
        // Inject Didomi consent at document start using WKUserScript
        let didomiJavaScriptCode = Didomi.shared.getJavaScriptForWebView()
        let userScript = WKUserScript(source: didomiJavaScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)
        guard let url = URL(string: baseURL) else { return }
        initialURL = url  // Track the initial URL for domain comparison
        let request = URLRequest(url: url)
        webView.load(request)
        let id = ObjectIdentifier(self).hashValue
        print("[SN] [NATIVE] WebAdViewController[\(id)]: Loading URL \(url)")
        // Consent is now injected at document start via WKUserScript
    }
    
    //MARK: WKUIDelegate - Handle target="_blank" clicks
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        // Handle popup windows by opening externally
        if let url = navigationAction.request.url {
            handleExternalURL(url)
            print("[SN] [NATIVE] External URL handler: Popup window opened externally.")
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
            print("[SN] [NATIVE] External URL handler: No target URL found")
            return false
        }
        
        // Always handle non-HTTP/HTTPS schemes externally
        if let scheme = targetURL.scheme, !["http", "https"].contains(scheme.lowercased()) {
            return true
        }
        
        // Handle popup windows externally (target="_blank")
        if navigationAction.targetFrame == nil {
            print("[SN] [NATIVE] External URL handler: Popup window detected")
            return true
        }
        
        // Handle different domain navigation externally (only for main frame)
        if let initialURL = initialURL,
           let initialDomain = initialURL.host,
           let targetDomain = targetURL.host,
           initialDomain != targetDomain,
           navigationAction.targetFrame?.isMainFrame == true {
            print("[SN] [NATIVE] External URL handler: External domain detected: \(initialDomain) -> \(targetDomain)")
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
