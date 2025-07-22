import SwiftUI
import WebKit

struct WebAdView: UIViewControllerRepresentable {
    private let baseURL = "https://adops.stepdev.dk/wp-content/ad-template.html"

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

class WebAdViewController: UIViewController {
    private let baseURL: String
    var webView: WKWebView!

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
        loadAdContent()
    }

    deinit {
        let id = ObjectIdentifier(self).hashValue
        print("[SN] WebAdViewController[\(id)]: deinit called")
    }

    func unloadWebView() {
        webView?.stopLoading()
        webView?.removeFromSuperview()
        webView = nil
        let id = ObjectIdentifier(self).hashValue
        print("[SN] WebAdViewController[\(id)]: Unloaded WebView")
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
    }

    private func loadAdContent() {
        guard let url = URL(string: baseURL) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        let id = ObjectIdentifier(self).hashValue
        print("[SN] WebAdViewController[\(id)]: Loading URL \(url)")
    }
}
