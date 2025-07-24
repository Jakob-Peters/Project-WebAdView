
# Project AdView
## Overview
Project AdView is a SwiftUI-based demo app that showcases how to display ad content in a privacy-compliant way using the Didomi consent management SDK. Ad units are rendered in `WKWebView` components and will only load after the user has given consent, ensuring that no consent notices appear inside the ad views themselves.

## Key Features
- **Consent-Gated Ad Loading:** WebAdViews are only loaded after Didomi consent is given.
- **Lazy Loading System:** Advanced lazy loading manages ad lifecycle based on scroll position, improving performance by fetching ads when approaching viewport, displaying when visible, and unloading when far from view.
- **SwiftUI Integration:** Uses `UIViewControllerRepresentable` to bridge UIKit `WKWebView` into SwiftUI.
- **Dynamic Ad Sizing:** WebAdView automatically resizes to fit the ad content, with smooth animation and support for initial, minimum, and maximum size constraints.
- **Multiple Ad Units:** Easily add ad units to SwiftUI content views with intelligent resource management.
- **Consent Preferences:** Users can change their consent preferences at any time.
- **Optimized Media Configuration:** WKWebView is configured for inline video playback and autoplay, maximizing ad monetization.
- **External URL Handling:** Ad clicks to external domains or popup windows open in the system browser, keeping the ad content in the webview and preventing unwanted navigation.
- **Global Debug Toggle:** A persistent debug toggle (ladybug icon in the toolbar) enables or disables all debug logging at runtime, with state saved across launches.
- **Conditional Debug Logging:** All debug output (print statements) is routed through a `debugPrint()` helper and only appears when debugging is enabled.

## Main Components

### 1. Didomi SDK Integration
- The Didomi SDK is initialized in `AppDelegate` (`Project_AdViewApp.swift`).
- A global event listener posts a `DidomiConsentChanged` notification when consent changes.
- The SDK UI is set up using a custom `DidomiWrapper` to ensure proper consent collection.

### 2. WebAdView & Lazy Loading System
- `WebAdView` is a SwiftUI component that displays an ad in a `WKWebView`.
- It only loads ad content after consent is given, listening for consent events via NotificationCenter.
- **Lazy Loading Manager:** A sophisticated system that manages ad lifecycle based on scroll position:
  - **Fetch State:** Ads are fetched when they approach the viewport (configurable threshold)
  - **Display State:** Ads are displayed when visible in the viewport
  - **Unload State:** Ads are unloaded when they move far from the viewport to free memory
  - **State Transitions:** Automatic state management with debug logging for each transition
- **Performance Optimization:** Only visible or near-visible ads consume resources, dramatically improving memory usage and scroll performance in long content.
- **Configurable Thresholds:** Customize fetch, display, and unload distances based on your needs.
- Consent status is injected into the web view using Didomi's JavaScript API.
- WKWebView is configured with `allowsInlineMediaPlayback = true` and `mediaTypesRequiringUserActionForPlayback = []` for optimal video ad support.
- Clicks on external links, popup windows (`target="_blank"`), or non-http(s) schemes are detected and opened in the system browser, while the webview remains on the original ad content.
- All debug output in this component is routed through `debugPrint()` and is controlled by the global debug toggle.
- The ad container's frame is initially set to a default size, and then animates to the actual ad size as soon as it is known (from the HTML template via JS bridge). You can customize the initial, minimum, and maximum size constraints for each ad.

### 3. Homepage and Articles (Demo)
- The homepage and each article can display one or more `WebAdView` ad units.
- **Lazy Loading Integration:** ScrollViews automatically enable lazy loading for optimal performance with multiple ads.
- The homepage is now fully scrollable: all content (ads, navigation links, consent button) is wrapped in a `ScrollView`, so you can always scroll to the bottom regardless of content height or number of ads.
- Fixed heights and unnecessary spacers have been removed from the homepage, allowing content to flow naturally and preventing layout issues when adding more ads or content.
- Navigation between articles is supported.
- The homepage features a toolbar with a ladybug icon for toggling debug mode.

### 4. Debugging Infrastructure
- **DebugSettings.swift:** Defines a global, persistent `isDebugEnabled` boolean using `@Published` and `UserDefaults`.
- **Toolbar Debug Toggle:** The homepage and all views display a ladybug icon in the navigation bar. Tapping it toggles debug mode on/off and updates all debug output instantly.
- **Persistent State:** The debug flag is saved in `UserDefaults` and restored on app launch.
- **Conditional Logging:** All `print()` statements in the app are replaced with `debugPrint()`, which only outputs when debugging is enabled.
- **Lazy Loading Debug Output:** When enabled, shows detailed state transitions for each ad (notLoaded → fetched → displayed → unloaded) with frame and scroll position information.

### 5. Lazy Loading System Architecture
- **LazyLoadingManager:** Central coordinator that tracks ad states and scroll position, managing the lifecycle of all ads in a ScrollView.
- **State Management:** Four distinct states (notLoaded, fetched, displayed, unloaded) with automatic transitions based on proximity to viewport.
- **Configurable Thresholds:** 
  - `fetchThreshold`: Distance from viewport when ad should start loading (default: 800pts)
  - `displayThreshold`: Distance from viewport when ad should be displayed (default: 200pts)  
  - `unloadThreshold`: Distance from viewport when ad should be unloaded (default: 1600pts)
- **Anti-Flickering System:** 
  - **Hysteresis Thresholds:** Different distances for loading vs unloading prevent rapid state changes
  - **Stability Timer:** 2-second delay before unloading ads that go out of view prevents layout thrashing
  - **Throttled Updates:** Visibility checks limited to 15fps (67ms intervals) for smooth scrolling performance
- **Performance Benefits:** Memory usage scales with visible content rather than total content, enabling smooth scrolling with dozens of ads without flickering or layout jumping.
- **Automatic Integration:** Simply apply `.lazyLoadAd()` modifier to any ScrollView to enable lazy loading for all contained WebAdViews.


### How to Use WebAdView

#### Enabling Lazy Loading

To enable lazy loading for optimal performance, simply apply the `.lazyLoadAd()` modifier to your ScrollView:

```swift
ScrollView {
    VStack {
        // Your content with multiple WebAdViews
        WebAdView(adUnitId: "div-gpt-ad-mobile_1")
        // ... more content and ads
        WebAdView(adUnitId: "div-gpt-ad-mobile_2")
    }
}
.lazyLoadAd() // Enable lazy loading with default thresholds
```

#### Custom Lazy Loading Thresholds

```swift
ScrollView {
    // Your content
}
.lazyLoadAd(fetchThreshold: 800, displayThreshold: 200, unloadThreshold: 1600)
```

#### Best Practices for Layout

- **Always wrap your main content in a `ScrollView`** if you have multiple ads or content that may exceed the screen height. This ensures all content (including the consent button) is always reachable.
- **Apply `.lazyLoadAd()` to ScrollViews** containing multiple ads for optimal performance and memory management.
- **Avoid unnecessary `Spacer()`s and fixed heights** in your main layout. Let the content flow naturally, and use `.frame(maxWidth: .infinity, alignment: .top)` for ad units to keep them pinned to the top of their container.
- **If you want to force a reload of a `WebAdView`,** use `.id(UUID())` or a state variable as the `.id`.

#### Basic Usage

```swift
// Minimal usage (uses default initial size 320x320, no constraints)
WebAdView(adUnitId: "div-gpt-ad-mobile_1")
    .showAdLabel(true) // Optional: show the "annonce" label
    .id(UUID()) // Optional: force reload
    .frame(maxWidth: .infinity, alignment: .center)
```

#### Custom Initial Size

```swift
// Set a custom initial size (e.g. 300x250)
WebAdView(adUnitId: "div-gpt-ad-mobile_2", initialWidth: 300, initialHeight: 250)
    .showAdLabel(true, text: "Annonce", font: .caption.bold())
    .frame(maxWidth: .infinity, alignment: .center)
```

#### Minimum and Maximum Constraints

```swift
// Set min/max width and height constraints
WebAdView(
    adUnitId: "div-gpt-ad-mobile_3",
    initialWidth: 320,
    initialHeight: 320,
    minWidth: 200,
    maxWidth: 400,
    minHeight: 100,
    maxHeight: 600
)
    .showAdLabel(true)
    .frame(maxWidth: .infinity, alignment: .center)
```

#### Custom Ad Label

```swift
// Show a custom ad label with custom text and font
WebAdView(adUnitId: "div-gpt-ad-mobile_1")
    .showAdLabel(true, text: "Sponsored", font: .system(size: 12, weight: .semibold))
    .frame(maxWidth: .infinity, alignment: .center)
```

#### Forcing Reloads

```swift
// Use .id(UUID()) to force the ad view to reload (e.g. on navigation)
@State private var adKey = UUID()

WebAdView(adUnitId: "div-gpt-ad-mobile_1")
    .id(adKey)
    .frame(maxWidth: .infinity, alignment: .center)

// In your view logic:
adKey = UUID() // This will force the WebAdView to be recreated
```

#### Complete Example with Lazy Loading

```swift
struct ContentView: View {
    @State private var adKey = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Multiple ads with lazy loading management
                    WebAdView(adUnitId: "div-gpt-ad-mobile_1", initialHeight: 320)
                        .showAdLabel(true, text: "Featured Ad")
                        .frame(maxWidth: .infinity, alignment: .top)
                    
                    // Content between ads
                    Text("Article Content")
                        .padding()
                    
                    WebAdView(adUnitId: "div-gpt-ad-mobile_2")
                        .showAdLabel(true)
                        .id(adKey) // Force reload when needed
                        .frame(maxWidth: .infinity, alignment: .top)
                    
                    // More content and ads...
                }
                .padding()
            }
            .lazyLoadAd() // Enable lazy loading for all WebAdViews with anti-flickering
            .navigationTitle("Demo")
        }
    }
}
```

### Summary Table

| Parameter         | Type      | Default   | Description                                 |
|-------------------|-----------|-----------|---------------------------------------------|
| adUnitId          | String    | (none)    | The ad unit ID to display                   |
| showAdLabel       | Bool      | false     | Show the "annonce" label above the ad       |
| adLabelText       | String    | "annonce"| The text for the ad label                   |
| adLabelFont       | Font      | .system(14, .bold) | Font for the ad label           |
| initialWidth      | CGFloat   | 320       | Initial width of the ad container           |
| initialHeight     | CGFloat   | 320       | Initial height of the ad container          |
| minWidth          | CGFloat?  | nil       | Minimum width constraint (optional)         |
| maxWidth          | CGFloat?  | nil       | Maximum width constraint (optional)         |
| minHeight         | CGFloat?  | nil       | Minimum height constraint (optional)        |
| maxHeight         | CGFloat?  | nil       | Maximum height constraint (optional)        |

### Lazy Loading Parameters

| Parameter         | Type      | Default   | Description                                 |
|-------------------|-----------|-----------|---------------------------------------------|
| fetchThreshold    | CGFloat   | 800       | Distance from viewport to start fetching   |
| displayThreshold  | CGFloat   | 200       | Distance from viewport to display ad       |
| unloadThreshold   | CGFloat   | 1600      | Distance from viewport to unload ad        |

**Why use .id and homepageWebAdKey?**
In SwiftUI, changing the `.id` of a view causes it to be fully recreated. The `homepageWebAdKey` state variable is used as the `.id` for the homepage's main `WebAdView`. By updating this key (e.g., with `homepageWebAdKey = UUID()` in `.onAppear`), you force SwiftUI to destroy and recreate the ad view. This is useful if you want to guarantee the ad view is fully reset and reloaded whenever the homepage appears, rather than just updating its content. Without this, the ad view may persist its state across navigation and not reload as expected.

## Project Structure
- `Project_AdViewApp.swift`: App entry point, Didomi SDK setup, and global debug infrastructure.
- `Views/HomepageView.swift`: Main navigation, ad placement, lazy loading integration, and debug toggle UI.
- `Configs/WebAdView.swift`: Ad unit implementation, consent gating logic, lazy loading UI integration, and conditional debug logging.
- `Configs/LazyLoadingManager.swift`: Central lazy loading coordinator managing ad states and performance optimization.
- `Configs/DebugSettings.swift`: Global, persistent debug state management.
- `Configs/DidomiWrapper.swift`: Ensures Didomi UI is properly presented in SwiftUI.

## Requirements
- Xcode 12+
- Swift 5.3+
- Didomi iOS SDK

## Customization
- Change the ad template URL in `WebAdView.swift` as needed.
- Add more ad units by placing additional `WebAdView(adUnitId: ...)` components in your views.
- **Configure lazy loading thresholds** using `.lazyLoadAd(fetchThreshold:displayThreshold:unloadThreshold:)` to optimize performance for your content.
- Use the `initialWidth`, `initialHeight`, `minWidth`, `maxWidth`, `minHeight`, and `maxHeight` parameters to control the ad container's sizing behavior.
- You can further customize the WKWebView configuration or external URL handling logic in `WebAdViewController` for your specific ad requirements.
- Adjust or extend the debug logging as needed by using `debugPrint()` in your own code.

## Privacy Compliance
This project ensures that ad content is only loaded after explicit user consent, in line with privacy regulations (GDPR, CCPA, etc.).

## Troubleshooting
- If ads do not load, check that Didomi SDK is initialized and consent is given.
- Ensure the DidomiWrapper is present in your view hierarchy for proper UI handling.
- If you do not see debug output, make sure the debug toggle (ladybug icon) is enabled.
- **For performance issues with many ads:** Ensure `.lazyLoadAd()` is applied to your ScrollView.
- **If ads aren't loading/unloading properly:** Check debug logs for state transitions and verify ScrollView bounds are being captured correctly.
- **For flickering or layout jumping:** The system now includes anti-flickering mechanisms with hysteresis thresholds and stability timers. If you still experience issues, try increasing the `unloadThreshold` parameter or check debug logs for rapid state transitions.

## License
This project is for demo purposes. Please adapt for production use and review privacy requirements for your region.
