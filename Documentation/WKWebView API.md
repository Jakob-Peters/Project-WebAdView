# Set Up WKWebView

If your app uses `WKWebView` to display web content, it's recommended to configure it for optimal ad monetization.

> ⚠️ **Important**: To properly set up and optimize WKWebView, apply all of the following recommendations to **each** `WKWebView` instance in your app.

---

## 1. Media Content Configuration

By default, `WKWebView` settings are **not** optimized for video ads. Use `WKWebViewConfiguration` to:

* Allow inline playback of HTML videos
* Enable automatic video play

### Example (Swift)

```swift
import WebKit

class ViewController: UIViewController {

  var webView: WKWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize a WKWebViewConfiguration object.
    let webViewConfiguration = WKWebViewConfiguration()
    
    // Allow HTML videos with "playsinline" attribute to play inline.
    webViewConfiguration.allowsInlineMediaPlayback = true
    
    // Allow HTML videos with "autoplay" attribute to play automatically.
    webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []

    // Initialize WKWebView with the configuration.
    webView = WKWebView(frame: view.frame, configuration: webViewConfiguration)
    view.addSubview(webView)
  }
}
```

---

## 2. Load Web View Content

> ✅ **Best Practice**: Always load web content using a **network-based URL**.

Cookies and page URLs are essential for monetization and only work correctly when using `load(_:)` with a network-based `URL`.

### Example (Swift)

```swift
import WebKit

var webView: WKWebView!

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize a WKWebViewConfiguration object.
    let webViewConfiguration = WKWebViewConfiguration()
    webViewConfiguration.allowsInlineMediaPlayback = true
    webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []

    // Initialize WKWebView with the configuration.
    webView = WKWebView(frame: view.frame, configuration: webViewConfiguration)
    view.addSubview(webView)

    // Load the URL for optimized performance.
    guard let url = URL(string: "https://google.github.io/webview-ads/test/") else { return }
    let request = URLRequest(url: url)
    webView.load(request)
  }
}
```

---

## 3. Alternative Content Sources

If you need to load web view content from **non-network** sources (e.g. raw HTML), mitigate the impact on monetization by:

* Sending the **Publisher Provided Identifier (PPID)**
* Including the **relevant page URL** (for GPT or AdSense)

These help reduce revenue loss compared to loading from a standard network URL.

---

## 4. Test the Web View

During development, test using this URL:

👉 [https://google.github.io/webview-ads/test/](https://google.github.io/webview-ads/test/)

### Success Criteria:

* ✅ Web view settings are applied
* ✅ First-party cookies work
* ✅ JavaScript is enabled
* ✅ Video ad plays inline (not in fullscreen)
* ✅ Video ad plays automatically (without click)
* ✅ Video ad is replayable

Once verified, replace the test URL with the actual content your web view will load.


# Optimize WKWebView Click Behavior

If your app uses `WKWebView` to display web content, it's important to **optimize click behavior** for several reasons:

* `WKWebView` doesn’t support tabbed browsing.
  ➤ Ad clicks attempting to open in a new tab do nothing by default.
* Ad clicks that open in the same tab **reload the page**, potentially disrupting app content like H5 games.
* AutoFill **doesn't support credit card info** in `WKWebView`, reducing e-commerce conversions.
* **Google Sign-in isn't supported** in `WKWebView`.

> This guide walks through how to optimize click behavior while preserving the `WKWebView` content state.

---

## Prerequisites

Make sure you've completed the steps from the **[Set up the web view guide](#)** before proceeding.

---

## Implementation

### Click Targets

Ads may use different target values in their links:

| `href` target attribute | Default WKWebView behavior   |
| ----------------------- | ---------------------------- |
| `target="_blank"`       | Not handled by the web view  |
| `target="_top"`         | Reloads in the same web view |
| `target="_self"`        | Reloads in the same web view |
| `target="_parent"`      | Reloads in the same web view |

| JavaScript function          | Default WKWebView behavior  |
| ---------------------------- | --------------------------- |
| `window.open(url, "_blank")` | Not handled by the web view |

---

### Steps to Optimize Behavior

1. **Set the `WKUIDelegate`** on your `WKWebView` instance.
2. **Implement**
   `webView(_:createWebViewWith:for:windowFeatures:)`
3. **Set the `WKNavigationDelegate`** on your `WKWebView` instance.
4. **Implement**
   `webView(_:decidePolicyFor:decisionHandler:)`

> ⚠️ Both delegates are required to handle both `href` and JavaScript-based clicks.

---

## Decision Logic

1. **Check navigation type**
   Use `.linkActivated` to detect standard link clicks.

   > Note: `window.open(...)` JavaScript clicks use `.other`.

2. **Check the target frame**
   If `navigationAction.targetFrame == nil`, the link is attempting to open a new window and must be handled manually.

3. **Open the URL externally**
   You may choose to open the link using:

   * `SFSafariViewController`
   * `UIApplication.shared.open`
   * Or your existing web view

---

## Code Example (Swift)

```swift
import GoogleMobileAds
import SafariServices
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()

    // ... Register the WKWebView.

    // 1. Set the delegates
    webView.uiDelegate = self
    webView.navigationDelegate = self
  }

  // 2. Handle target="_blank" clicks
  func webView(
      _ webView: WKWebView,
      createWebViewWith configuration: WKWebViewConfiguration,
      for navigationAction: WKNavigationAction,
      windowFeatures: WKWindowFeatures) -> WKWebView? {
    
    if didHandleClickBehavior(
        currentURL: webView.url,
        navigationAction: navigationAction) {
      print("URL opened in SFSafariViewController.")
    }

    return nil
  }

  // 3. Handle navigation decisions
  func webView(
      _ webView: WKWebView,
      decidePolicyFor navigationAction: WKNavigationAction,
      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
    if didHandleClickBehavior(
        currentURL: webView.url,
        navigationAction: navigationAction) {
      return decisionHandler(.cancel)
    }

    decisionHandler(.allow)
  }

  // 4. Custom click behavior logic
  func didHandleClickBehavior(
      currentURL: URL,
      navigationAction: WKNavigationAction) -> Bool {
    
    guard let targetURL = navigationAction.request.url else {
      return false
    }

    // Handle custom URL schemes
    if navigationAction.navigationType == .linkActivated {
      if let scheme = targetURL.scheme, !["http", "https"].contains(scheme) {
        UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
        return true
      }
    }

    guard let currentDomain = currentURL.host,
          let targetDomain = targetURL.host else {
      return false
    }

    // If navigating to a new domain or target frame is nil
    if (navigationAction.navigationType == .linkActivated ||
        navigationAction.targetFrame == nil),
        currentDomain != targetDomain {
      
      let safariVC = SFSafariViewController(url: targetURL)
      present(safariVC, animated: true)
      return true
    }

    return false
  }
}
```

---

## Test Your Page Navigation

Test your optimized click handling by loading:

👉 [https://google.github.io/webview-ads/test/#click-behavior-tests](https://google.github.io/webview-ads/test/#click-behavior-tests)

### What to Check:

* ✅ Each link opens the correct URL
* ✅ When returning to the app, the counter on the test page **doesn't reset**
  ➤ This confirms that **web view state is preserved**