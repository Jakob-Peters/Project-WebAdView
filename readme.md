
# Project AdView
## Overview
Project AdView is a SwiftUI-based demo app that showcases how to display ad content in a privacy-compliant way using the Didomi consent management SDK. Ad units are rendered in `WKWebView` components and will only load after the user has given consent, ensuring that no consent notices appear inside the ad views themselves.

## Key Features
- **Consent-Gated Ad Loading:** WebAdViews are only loaded after Didomi consent is given.
- **SwiftUI Integration:** Uses `UIViewControllerRepresentable` to bridge UIKit `WKWebView` into SwiftUI.
- **Dynamic Ad Sizing:** WebAdView automatically resizes to fit the ad content, with smooth animation and support for initial, minimum, and maximum size constraints.
- **Multiple Ad Units:** Easily add ad units to SwiftUI content views.
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

### 2. WebAdView
- `WebAdView` is a SwiftUI component that displays an ad in a `WKWebView`.
- It only loads ad content after consent is given, listening for consent events via NotificationCenter.
- Consent status is injected into the web view using Didomi's JavaScript API.
- WKWebView is configured with `allowsInlineMediaPlayback = true` and `mediaTypesRequiringUserActionForPlayback = []` for optimal video ad support.
- Clicks on external links, popup windows (`target="_blank"`), or non-http(s) schemes are detected and opened in the system browser, while the webview remains on the original ad content.
- All debug output in this component is routed through `debugPrint()` and is controlled by the global debug toggle.
- The ad container's frame is initially set to a default size, and then animates to the actual ad size as soon as it is known (from the HTML template via JS bridge). You can customize the initial, minimum, and maximum size constraints for each ad.

### 3. Homepage and Articles (Demo)
- The homepage and each article can display one or more `WebAdView` ad units.
- Navigation between articles is supported.
- The homepage features a toolbar with a ladybug icon for toggling debug mode.

### 4. Debugging Infrastructure
- **DebugSettings.swift:** Defines a global, persistent `isDebugEnabled` boolean using `@Published` and `UserDefaults`.
- **Toolbar Debug Toggle:** The homepage and all views display a ladybug icon in the navigation bar. Tapping it toggles debug mode on/off and updates all debug output instantly.
- **Persistent State:** The debug flag is saved in `UserDefaults` and restored on app launch.
- **Conditional Logging:** All `print()` statements in the app are replaced with `debugPrint()`, which only outputs when debugging is enabled.

## How to Use WebAdView

### Basic Usage

```swift
// Minimal usage (uses default initial size 320x320, no constraints)
WebAdView(adUnitId: "div-gpt-ad-mobile_1")
    .showAdLabel(true) // Optional: show the "annonce" label
    .id(UUID()) // Optional: force reload
    .frame(maxWidth: .infinity, alignment: .center)
```

### Custom Initial Size

```swift
// Set a custom initial size (e.g. 300x250)
WebAdView(adUnitId: "div-gpt-ad-mobile_2", initialWidth: 300, initialHeight: 250)
    .showAdLabel(true, text: "Annonce", font: .caption.bold())
    .frame(maxWidth: .infinity, alignment: .center)
```

### Minimum and Maximum Constraints

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

### Custom Ad Label

```swift
// Show a custom ad label with custom text and font
WebAdView(adUnitId: "div-gpt-ad-mobile_1")
    .showAdLabel(true, text: "Sponsored", font: .system(size: 12, weight: .semibold))
    .frame(maxWidth: .infinity, alignment: .center)
```

### Forcing Reloads

```swift
// Use .id(UUID()) to force the ad view to reload (e.g. on navigation)
@State private var adKey = UUID()

WebAdView(adUnitId: "div-gpt-ad-mobile_1")
    .id(adKey)
    .frame(maxWidth: .infinity, alignment: .center)

// In your view logic:
adKey = UUID() // This will force the WebAdView to be recreated
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

**Why use .id and homepageWebAdKey?**
In SwiftUI, changing the `.id` of a view causes it to be fully recreated. The `homepageWebAdKey` state variable is used as the `.id` for the homepage's main `WebAdView`. By updating this key (e.g., with `homepageWebAdKey = UUID()` in `.onAppear`), you force SwiftUI to destroy and recreate the ad view. This is useful if you want to guarantee the ad view is fully reset and reloaded whenever the homepage appears, rather than just updating its content. Without this, the ad view may persist its state across navigation and not reload as expected.

## Project Structure
- `Project_AdViewApp.swift`: App entry point, Didomi SDK setup, and global debug infrastructure.
- `Views/HomepageView.swift`: Main navigation, ad placement, and debug toggle UI.
- `Configs/WebAdView.swift`: Ad unit implementation, consent gating logic, and conditional debug logging.
- `Configs/DebugSettings.swift`: Global, persistent debug state management.
- `Configs/DidomiWrapper.swift`: Ensures Didomi UI is properly presented in SwiftUI.

## Requirements
- Xcode 12+
- Swift 5.3+
- Didomi iOS SDK

## Customization
- Change the ad template URL in `WebAdView.swift` as needed.
- Add more ad units by placing additional `WebAdView(adUnitId: ...)` components in your views.
- Use the `initialWidth`, `initialHeight`, `minWidth`, `maxWidth`, `minHeight`, and `maxHeight` parameters to control the ad container's sizing behavior.
- You can further customize the WKWebView configuration or external URL handling logic in `WebAdViewController` for your specific ad requirements.
- Adjust or extend the debug logging as needed by using `debugPrint()` in your own code.

## Privacy Compliance
This project ensures that ad content is only loaded after explicit user consent, in line with privacy regulations (GDPR, CCPA, etc.).

## Troubleshooting
- If ads do not load, check that Didomi SDK is initialized and consent is given.
- Ensure the DidomiWrapper is present in your view hierarchy for proper UI handling.
- If you do not see debug output, make sure the debug toggle (ladybug icon) is enabled.

## License
This project is for demo purposes. Please adapt for production use and review privacy requirements for your region.
