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
        print("[SN] WebAdView.makeUIViewController: Created controller [\(id)]")
        return controller
    }

    func updateUIViewController(_ uiViewController: WebAdViewController, context: Context) {
        // No-op for static URL
    }

    static func dismantleUIViewController(_ uiViewController: WebAdViewController, coordinator: ()) {
        let id = ObjectIdentifier(uiViewController).hashValue
        print("[SN] WebAdView.dismantleUIViewController: Dismantling controller [\(id)]")
        uiViewController.unloadWebView()
    }
}

//MARK: WebAdViewController
class WebAdViewController: UIViewController {
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
        checkConsentAndLoad()
    }

    //MARK: Consent holdback
    private func checkConsentAndLoad() {
        // First check if consent is already given
        if Didomi.shared.isReady() && !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
            self.loadAdContent()
            print("[SN] WebAdViewController: Consent already given, loading WebAdViews")
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
                print("[SN] WebAdViewController: Consent changed, loading WebAdViews")
            }
        }
        
        // Also listen for when SDK becomes ready (in case it wasn't ready yet)
        Didomi.shared.onReady {
            DispatchQueue.main.async {
                if !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
                    self.loadAdContent()
                    print("[SN] WebAdViewController: Consent onReady, loading WebAdViews")
                }
            }
        }
    }

    deinit {
        let id = ObjectIdentifier(self).hashValue
        print("[SN] WebAdViewController[\(id)]: deinit called")
        // Remove notification observer
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: Unload WebView
    func unloadWebView() {
        webView?.stopLoading()
        webView?.removeFromSuperview()
        webView = nil
        let id = ObjectIdentifier(self).hashValue
        print("[SN] WebAdViewController[\(id)]: Unloaded WebView")
    }
    //MARK: WebView setup
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        print("[SN] WebAdViewController: WebView setup")
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
        print("[SN] WebAdViewController[\(id)]: Loading URL \(url)")
        // Consent is now injected at document start via WKUserScript
    }
}
