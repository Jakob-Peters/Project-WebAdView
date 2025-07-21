# Disclaimer - This guide below is based on a old project and the general idea of it is good, but the actual code is not optimalt and should not be used

# AdSDK - Modular Ad Integration Framework

A modular Swift framework for integrating web-based ads with Didomi consent management and dynamic ad sizing.

<!-- >
## Bugs and Current Known Issues

### Viewability Issues with WebView JS Logic and Native Scrolling

- **Issue**: Currently, the WebView isn't aware whether it's off-screen or on-screen with respect to the native view of the device versus the WebView itself. This fundamentally makes all WebView loads "viewable," resulting in viewability always being 100%.
- **Possible Solution**: 
    1. Create an observer within the native view that sends an event to the WebView (using a JS-based event listener in the HTML code) when it is off-screen or on-screen.
    2. The event listener adds a class to the parent ad unit element (or a new high z-index element) with `display: hidden`, toggling the class on or off based on the WebView's position within the native view.
    3. This should provide a more accurate solution for determining when the ad unit (WebView) is visible or not within the WebView.
- **Problems That Cannot Be Resolved**: The "50% viewport for 1s" requirement cannot be reliably handled, since (to my knowledge) proper MutationObservers cannot track real-time visibility relative to the native view.

### Lazy Loading of WebView Frames (AdWebView)

- **Issue**: All WebViews load when the native view loads, sending auctions and creating impressions even if the user may never see the ad.
- **Possible Solution**:
    1. Create an observer for the native view with a configurable value that can initialize the WebView based on pixel distance (or screen height).
    2. This will allow WebViews to load (and create impressions) only when the user is close to the WebView.
    3. Combined with the viewability observer, this should address most edge cases and performance-related tracking, resulting in behavior closer to normal web-based ad units.
 -->

## Overview

This framework provides a complete solution for displaying web-based ads in iOS applications with:
- Didomi consent management integration
- Dynamic ad sizing and responsive layout
- Modular architecture for easy integration
- Debug mode toggle for development
- Console logging bridge between JavaScript and Swift

## Features

- 🎯 **Modular Design**: Easy to integrate into any iOS project
- 🔒 **Consent Management**: Full Didomi SDK integration
- 📱 **Responsive Ads**: Dynamic sizing based on ad content
- 🐛 **Debug Mode**: Toggle for development and testing
- 🔗 **JavaScript Bridge**: Seamless communication between web and native
- 📊 **Console Logging**: JavaScript logs forwarded to Xcode console


## Quick Start

### 1. Integration

Add the AdSDK sources to your project and ensure you have the required dependencies:

```swift
// In your Package.swift or project dependencies
.package(url: "https://github.com/didomi/swift-sdk", from: "1.0.0")
.package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "9.0.0")
```

### 2. AppDelegate Setup

```swift
import UIKit
import AdSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize AdSDK with your configuration
        AdSDK.shared.initialize(
            didomiApiKey: "your-didomi-api-key",
            yieldManagerId: "your-yield-manager-id"
        )
        
        return true
    }
}
```

### 3. Basic Usage

```swift
import SwiftUI
import AdSDK

struct ContentView: View {
    @State private var adSize = CGSize(width: 320, height: 250)
    
    var body: some View {
        VStack {
            // Your content here
            
            AdWebView(
                adUnitId: "your-ad-unit-id",
                adSize: $adSize,
            )
            .frame(width: adSize.width, height: adSize.height)
            
            // More content
        }
    }
}
```

## Configuration

### Ad Configuration

```swift
let config = AdConfiguration(
    baseURL: "https://your-domain.com/ad-template.html",
    didomiApiKey: "your-didomi-api-key",
    yieldManagerId: "your-yield-manager-id",
    debugMode: true // Enable for development
)
```

### Debug Mode

Debug mode provides:
- Detailed console logging
- `aym_debug=true` query parameter
- JavaScript error forwarding
- Network request logging

## HTML Template

The framework includes a customizable HTML template (`ad-template.html`) that handles:

- Didomi consent management
- Yield Manager ad loading
- Dynamic size monitoring
- Console logging bridge

### Template Features

1. **Didomi Integration**: Automatic consent synchronization
2. **Size Monitoring**: Real-time ad size updates
3. **Styling**: Responsive design for various screen sizes
4. **Debug Support**: Conditional logging and debugging tools



### Console Logging

```swift
// Custom log handler
AdSDK.shared.setConsoleLogHandler { level, message, timestamp in
    print("[\(level)] \(timestamp): \(message)")
}
```


## Requirements

- iOS 14.0+
- Swift 5.5+
- Xcode 13.0+
- Didomi SDK
- Google Mobile Ads SDK (optional)

## License

[Your License Here]

## Support

For issues and questions, please refer to the documentation or contact the development team.