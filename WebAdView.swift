import Didomi
import SwiftUI
import WebKit
import SafariServices

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
        webView.uiDelegate = self
        webView.navigationDelegate = self

    //MARK: Consent holdback
    private func checkConsentAndLoad() {
        if Didomi.shared.isReady() && !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
    //MARK: WKWebView Delegates for optimized click behavior
    // Handle target="_blank" and window.open clicks
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil,
           let url = navigationAction.request.url {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true)
            print("[SN] [NATIVE] WKUIDelegate: Opened target=_blank in Safari: \(url)")
        }
        return nil
    }

    // Handle navigation decisions for external links
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           navigationAction.navigationType == .linkActivated {
            // Open non-http(s) schemes externally
            if let scheme = url.scheme, !["http", "https"].contains(scheme) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                print("[SN] [NATIVE] WKNavigationDelegate: Opened custom scheme: \(url)")
                decisionHandler(.cancel)
                return
            }
            // Open external domains in Safari
            if let currentDomain = webView.url?.host,
               let targetDomain = url.host,
               currentDomain != targetDomain {
                let safariVC = SFSafariViewController(url: url)
                self.present(safariVC, animated: true)
                print("[SN] [NATIVE] WKNavigationDelegate: Opened external domain in Safari: \(url)")
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
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
        let request = URLRequest(url: url)
        webView.load(request)
        let id = ObjectIdentifier(self).hashValue
        print("[SN] [NATIVE] WebAdViewController[\(id)]: Loading URL \(url)")
        // Consent is now injected at document start via WKUserScript
    }
    // Handle navigation decisions for external links
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           navigationAction.navigationType == .linkActivated {
            // Open non-http(s) schemes externally
            if let scheme = url.scheme, !["http", "https"].contains(scheme) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                print("[SN] [NATIVE] WKNavigationDelegate: Opened custom scheme: \(url)")
                decisionHandler(.cancel)
                return
            }
            // Open external domains in Safari
            if let currentDomain = webView.url?.host,
               let targetDomain = url.host,
               currentDomain != targetDomain {
                let safariVC = SFSafariViewController(url: url)
                self.present(safariVC, animated: true)
                print("[SN] [NATIVE] WKNavigationDelegate: Opened external domain in Safari: \(url)")
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
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
        let request = URLRequest(url: url)
        webView.load(request)
        let id = ObjectIdentifier(self).hashValue
        print("[SN] [NATIVE] WebAdViewController[\(id)]: Loading URL \(url)")
        // Consent is now injected at document start via WKUserScript
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
        let request = URLRequest(url: url)
        webView.load(request)
        let id = ObjectIdentifier(self).hashValue
        print("[SN] [NATIVE] WebAdViewController[\(id)]: Loading URL \(url)")
        // Consent is now injected at document start via WKUserScript
    }
}
