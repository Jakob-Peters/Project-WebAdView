# Guide: Modular Ad Integration Framework (SN AdView SDK)

> ⚠️ **Disclaimer**: This guide is based on a legacy project. The concept and structure are sound, but the original implementation is outdated and suboptimal. Use this guide as a foundation to rebuild or refactor with modern best practices.

---

## ✅ Purpose

This project aims to build a **modular Swift framework** (`SN AdView SDK`) to integrate web-based advertising into iOS apps using:

* **Didomi** for consent management
* **WKWebView** for ad rendering
* **Dynamic sizing** and lazy loading for performance
* **Bridge communication** between native and web
* **Support for debugging and logging**

---

## 🎯 Project Scope

### Functional Modules

* **Consent Integration** (Didomi)
* **Ad Display via WKWebView** (Assertive Yield, Yield Manager)
* **Dynamic Ad Sizing** (Webview js events to natvie view frames)
* **Lazy Load Trigger Based on Viewport** (Native view events to webview)
* **Console Logging & JS Bridge** 
* **Debug Mode Support**
* **Custom HTML Ad Template**

### Out of Scope (for now)

* Native ad rendering
* Full analytics pipeline
* Server-side bidding integrations

---
<!-- 
## 🧠 Known Issues & Challenges (To Fix or Rebuild)

### 1. WebView Viewability

* **Problem**: WebView reports 100% viewability regardless of actual screen visibility.
* **Goal**: Use native observers to notify JS when the ad is off-screen.
* **Proposed Fix**:

  * Add a `visibilityObserver` in native code.
  * Send `visibilitychange` events to JS.
  * Toggle a CSS class that hides the ad when not visible.

### 2. Lazy Loading Ads

* **Problem**: WebViews load and trigger impressions on view load, even if not visible.
* **Goal**: Trigger WebView init only when close to screen.
* **Proposed Fix**:

  * Observe scroll position.
  * Load WebView only when in or near viewport.

---
-->

## 📦 Features

| Feature              | Description                                        |
| -------------------- | -------------------------------------------------- |
| Modular Architecture | Easy to plug into existing SwiftUI or UIKit apps   |
| Consent Integration  | Built-in Didomi SDK support                        |
| Dynamic Sizing       | Detects and adjusts ad container size in real-time |
| Debug Mode           | Enables network logging, JS console mirroring      |
| JS-Native Bridge     | JS errors and logs surfaced in Xcode               |
| HTML Template        | Customizable, includes ad logic and size reporting |

---

## 🛠 Quick Integration (Reference Code)

### Swift Package Dependencies

```swift
.package(url: "https://github.com/didomi/swift-sdk", from: "1.0.0"),
.package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "9.0.0")
```

### AppDelegate Setup

```swift
import AdSDK

AdSDK.shared.initialize(
    didomiApiKey: "your-didomi-api-key",
)
```

### SwiftUI Example

```swift
import AdSDK

AdWebView(
    adUnitId: "your-ad-unit-id",
    adSize: $adSize
)
.frame(width: adSize.width, height: adSize.height)
```

---

## ⚙️ Configuration

```swift
let config = AdConfiguration(
    baseURL: "https://your-domain.com/ad-template.html",
    didomiApiKey: "your-didomi-api-key",
    debugMode: true
)
```

---

## 🧪 Debug Mode

* Adds `?aym_debug=true` to all requests
* Surfaces JS errors in the Xcode console (the debug QP adds logs from Yield Manager into the browser console)

```swift
AdSDK.shared.setConsoleLogHandler { level, message, timestamp in
    print("[\(level)] \(timestamp): \(message)")
}
```

---

## 🌐 HTML Template Responsibilities

* Load ads via Yield Manager
* Communicate size updates to native
* Sync consent with Didomi
* Display logs conditionally in debug mode (using Yield Managers logs)

---

## 📋 Requirements

* iOS 15+
* Swift 5.5+
* Xcode 13+
* WKWebView enabled
* Didomi SDK
* Google Mobile Ads SDK (for future ad types in native view)