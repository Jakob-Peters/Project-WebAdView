
# Project AdView
## Overview
Project AdView is a SwiftUI-based demo app that showcases how to display ad content in a privacy-compliant way using the Didomi consent management SDK. Ad units are rendered in `WKWebView` components and will only load after the user has given consent, ensuring that no consent notices appear inside the ad views themselves.

## Key Features
- **Consent-Gated Ad Loading:** WebAdViews are only loaded after Didomi consent is given.
- **Advanced Lazy Loading System:** Sophisticated lazy loading manages ad lifecycle based on scroll position, with configurable fetch/display/unload thresholds, throttled updates, and optional bi-directional unloading for optimal performance.
- **Custom Targeting Support:** Built-in Google Ad Manager targeting with support for both single string values and arrays, using a fluent SwiftUI modifier API.
- **SwiftUI Integration:** Uses `UIViewControllerRepresentable` to bridge UIKit `WKWebView` into SwiftUI.
- **Dynamic Ad Sizing:** WebAdView automatically resizes to fit the ad content delivered by Yield Manager (STEP Network's wrapper). The actual ad sizes are controlled remotely by STEP Network's configuration, not by local frame constraints.
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
- **Advanced Lazy Loading Manager:** A sophisticated system that manages ad lifecycle based on scroll position:
  - **Fetch State:** Ads are fetched when they approach the viewport (configurable threshold)
  - **Display State:** Ads are displayed when visible in the viewport
  - **Unload State:** Ads are unloaded when they move far from the viewport to free memory
  - **State Transitions:** Automatic state management with debug logging for each transition
- **Custom Targeting Support:** Built-in Google Ad Manager targeting system for passing additional targeting parameters to STEP Network's ad serving configuration:
  - Single string values: `.customTargeting("key", "value")`
  - Array values: `.customTargeting("key", ["value1", "value2"])`
  - Chainable modifiers for multiple targeting parameters
  - Automatic JavaScript generation for `googletag.pubads().setTargeting()` calls
  - Production-ready injection (works without debug mode)
  - **Important:** Custom targeting parameters can be added as needed, but require configuration by STEP Network within Google Ad Manager before they become usable for campaign targeting.
- **Performance Optimization:** Only visible or near-visible ads consume resources, dramatically improving memory usage and scroll performance in long content.
- **Configurable Thresholds:** Customize fetch, display, and unload distances based on your needs.
- Consent status is injected into the web view using Didomi's JavaScript API.
- WKWebView is configured with `allowsInlineMediaPlaybook = true` and `mediaTypesRequiringUserActionForPlayback = []` for optimal video ad support.
- Clicks on external links, popup windows (`target="_blank"`), or non-http(s) schemes are detected and opened in the system browser, while the webview remains on the original ad content.
- All debug output in this component is routed through `debugPrint()` and is controlled by the global debug toggle.
- **Ad Sizing & STEP Network Integration:** The ad container's frame is initially set to a default size, then automatically resizes based on the actual ad content delivered by Yield Manager (STEP Network's wrapper). Ad dimensions, sizes, and available formats are configured remotely by STEP Network. Local frame constraints (minWidth, maxWidth, etc.) are for UI layout purposes only and do not influence the actual ad sizes requested from the ad server. **Always consult with STEP Network regarding available ad sizes, targeting criteria, and ad unit specifications before implementation.**

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
- **Toggleable Unloading:** 
  - `unloadingEnabled`: Controls whether ads should be unloaded when out of view (default: false)
  - Default behavior prioritizes user experience over memory optimization
  - Can be enabled per ScrollView for memory-sensitive scenarios
- **Anti-Flickering System:** 
  - **Hysteresis Thresholds:** Different distances for loading vs unloading prevent rapid state changes
  - **Stability Timer:** 2-second delay before unloading ads that go out of view prevents layout thrashing
  - **Throttled Updates:** Visibility checks limited to 15fps (67ms intervals) for smooth scrolling performance
- **Performance Benefits:** Memory usage scales with visible content rather than total content, enabling smooth scrolling with dozens of ads without flickering or layout jumping.
- **Automatic Integration:** Simply apply `.lazyLoadAd()` modifier to any ScrollView to enable lazy loading for all contained WebAdViews.


### How to Use WebAdView

## ⚠️ Important: STEP Network Integration

**Before implementing any WebAdView components, consult with STEP Network regarding:**

- **Available ad unit IDs** and their corresponding sizes
- **Supported ad formats** for each ad unit (sizes)
- **Custom targeting parameters** that are configured for your account (if any)
- **Geographic and demographic targeting** requirements
- **Expected ad dimensions** and responsive behavior

**Key Integration Points:**
- **Ad Sizing:** All ad dimensions are controlled remotely by Yield Manager (STEP Network's wrapper). Local frame constraints are for UI layout only.
- **Custom Targeting:** Only use targeting parameters that have been configured by STEP Network for your ad units.
- **Ad Unit IDs:** Use only the specific ad unit IDs provided by STEP Network for your implementation.

Forcing frame sizes different from STEP Network's configuration will not change the actual ad dimensions or request new sizes from the ad server.

---

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

#### Enabling Unloading for Memory Optimization

```swift
ScrollView {
    // Your content with many ads
}
.lazyLoadAd(unloadingEnabled: true) // Enable bi-directional unloading

// Or with custom thresholds
ScrollView {
    // Your content
}
.lazyLoadAd(fetchThreshold: 1000, displayThreshold: 300, unloadThreshold: 2000, unloadingEnabled: true)
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

#### Custom Targeting

**Note:** Custom targeting parameters are used by STEP Network's ad serving system for campaign selection and optimization. These parameters do not control ad sizes or formats. Custom targeting values can be added as needed, but require configuration by STEP Network within Google Ad Manager before they become usable for campaign targeting.

```swift
// Single targeting parameter (consult with STEP Network for configuration)
WebAdView(adUnitId: "div-gpt-ad-mobile_1")
    .customTargeting("section", "homepage")  // Requires STEP Network configuration in GAM
    .customTargeting("user_type", "premium") // Requires STEP Network configuration in GAM
    .showAdLabel(true)

// Array targeting parameter (consult with STEP Network for configuration)
WebAdView(adUnitId: "div-gpt-ad-mobile_2")
    .customTargeting("categories", ["sports", "news", "entertainment"]) // Requires STEP Network configuration in GAM
    .customTargeting("tags", ["breaking", "featured", "local"])         // Requires STEP Network configuration in GAM
    .showAdLabel(true)

// Chainable multiple parameters (all keys require STEP Network configuration)
WebAdView(adUnitId: "div-gpt-ad-mobile_3")
    .customTargeting("section", "articles")      // Requires STEP Network configuration in GAM
    .customTargeting("topics", ["tech", "mobile", "advertising"]) // Requires STEP Network configuration in GAM
    .customTargeting("audience", "tech-savvy")   // Requires STEP Network configuration in GAM
    .showAdLabel(true, text: "artikel forsætter efter annonce")
```

#### Custom Initial Size & Layout Constraints

**Important:** The `initialWidth`, `initialHeight`, `minWidth`, `maxWidth`, `minHeight`, and `maxHeight` parameters are for UI layout purposes only. They do not control the actual ad size delivered by STEP Network's ad server. The WebAdView will automatically resize to match the ad content delivered by Yield Manager.

```swift
// Set initial container size (for layout stability while ad loads)
// Actual ad size is determined by STEP Network configuration
WebAdView(adUnitId: "div-gpt-ad-mobile_2", initialWidth: 300, initialHeight: 250)
    .showAdLabel(true, text: "Annonce", font: .caption.bold())
    .frame(maxWidth: .infinity, alignment: .center)
```

#### Container Constraints (UI Layout Only)

```swift
// These constraints affect the container layout, not the ad content size
WebAdView(
    adUnitId: "div-gpt-ad-mobile_3",
    initialWidth: 320,    // Initial container width (before ad loads)
    initialHeight: 320,   // Initial container height (before ad loads)
    minWidth: 200,        // Minimum container width (UI constraint only)
    maxWidth: 400,        // Maximum container width (UI constraint only)
    minHeight: 100,       // Minimum container height (UI constraint only)
    maxHeight: 600        // Maximum container height (UI constraint only)
)
    .showAdLabel(true)
    .frame(maxWidth: .infinity, alignment: .center)
```

**Note:** If the ad delivered by STEP Network is larger than your container constraints, the WebAdView will prioritize displaying the full ad content and may override local constraints.

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
                    // Header ad with custom targeting
                    WebAdView(adUnitId: "div-gpt-ad-mobile_1", initialHeight: 320)
                        .customTargeting("section", "homepage")
                        .customTargeting("tags", ["breaking", "featured", "local"])
                        .showAdLabel(true, text: "artikel forsætter efter annonce")
                        .frame(maxWidth: .infinity, alignment: .top)
                    
                    // Content between ads
                    Text("Article Content")
                        .padding()
                    
                    // Mid-article ad with different targeting
                    WebAdView(adUnitId: "div-gpt-ad-mobile_2")
                        .customTargeting("position", "mid-article")
                        .customTargeting("categories", ["tech", "mobile"])
                        .showAdLabel(true)
                        .id(adKey) // Force reload when needed
                        .frame(maxWidth: .infinity, alignment: .top)
                    
                    // More content and ads...
                }
                .padding()
            }
            .lazyLoadAd() // Enable lazy loading with default settings (unloading disabled)
            // Or enable unloading for memory optimization:
            // .lazyLoadAd(unloadingEnabled: true)
            .navigationTitle("Demo")
        }
    }
}
```

### Summary Table

| Parameter         | Type      | Default   | Description                                 |
|-------------------|-----------|-----------|---------------------------------------------|
| adUnitId          | String    | (none)    | The ad unit ID provided by STEP Network     |
| showAdLabel       | Bool      | false     | Show the "annonce" label above the ad       |
| adLabelText       | String    | "annonce"| The text for the ad label                   |
| adLabelFont       | Font      | .system(14, .bold) | Font for the ad label           |
| initialWidth      | CGFloat   | 320       | Initial container width (UI layout only)    |
| initialHeight     | CGFloat   | 320       | Initial container height (UI layout only)   |
| minWidth          | CGFloat?  | nil       | Minimum container width (UI constraint only)|
| maxWidth          | CGFloat?  | nil       | Maximum container width (UI constraint only)|
| minHeight         | CGFloat?  | nil       | Minimum container height (UI constraint only)|
| maxHeight         | CGFloat?  | nil       | Maximum container height (UI constraint only)|

**Note:** All size parameters are for UI layout purposes only. Actual ad dimensions are controlled remotely by STEP Network's Yield Manager.

### Custom Targeting Methods

| Method                                    | Description                                      |
|-------------------------------------------|--------------------------------------------------|
| `.customTargeting("key", "value")`        | Set single string targeting parameter (requires STEP Network configuration in GAM) |
| `.customTargeting("key", ["val1", "val2"])` | Set array targeting parameter (requires STEP Network configuration in GAM) |

**Important:** Custom targeting values can be added as needed, but require configuration by STEP Network within Google Ad Manager before they become usable for campaign targeting.

### Lazy Loading Parameters

| Parameter         | Type      | Default   | Description                                 |
|-------------------|-----------|-----------|---------------------------------------------|
| fetchThreshold    | CGFloat   | 800       | Distance from viewport to start fetching   |
| displayThreshold  | CGFloat   | 200       | Distance from viewport to display ad       |
| unloadThreshold   | CGFloat   | 1600      | Distance from viewport to unload ad        |
| unloadingEnabled  | Bool      | false     | Whether ads should be unloaded when out of view |

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
- **Change the ad template URL in `WebAdView.swift` as needed** (coordinate with STEP Network).
- **Add more ad units** by placing additional `WebAdView(adUnitId: ...)` components in your views using ad unit IDs provided by STEP Network.
- **Configure lazy loading thresholds** using `.lazyLoadAd(fetchThreshold:displayThreshold:unloadThreshold:)` to optimize performance for your content.
- **Use the `initialWidth`, `initialHeight`, `minWidth`, `maxWidth`, `minHeight`, and `maxHeight` parameters** to control the ad container's UI layout behavior. These do not affect the actual ad content size delivered by STEP Network.
- **Custom targeting parameters** must be coordinated with STEP Network to ensure they match your account's configuration.
- **Ad unit IDs and expected dimensions** should be obtained from STEP Network before implementation.
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
- **For flickering or layout jumping:** The system now includes anti-flickering mechanisms with hysteresis thresholds and stability timers. If you still experience issues, try increasing the `unloadThreshold` parameter or check debug logs for rapid state transitions. (If issues presist, disable unloading again, using the `default` value)

## License
This project is for demo purposes. Please adapt for production use and review privacy requirements for your region.
