
# Project AdView

## Overview
Project AdView is a SwiftUI-based demo app that showcases how to display ad content in a privacy-compliant way using the Didomi consent management SDK. Ad units are rendered in `WKWebView` components and will only load after the user has given consent, ensuring that no consent notices appear inside the ad views themselves.

## Key Features
- **Consent-Gated Ad Loading:** WebAdViews is only loaded after Didomi consent is given.
- **SwiftUI Integration:** Uses `UIViewControllerRepresentable` to bridge UIKit `WKWebView` into SwiftUI.
- **Multiple Ad Units:** Easily add ad units to swift content views.
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

1. **Add the WebAdView to your SwiftUI view:**
   ```swift
   WebAdView(adUnitId: "div-gpt-ad-mobile_1")
       .frame(width: 320, height: 320)
   ```
   You can use `.id(UUID())` to force reloads if needed.

**Why use .id and homepageWebAdKey?**
In SwiftUI, changing the `.id` of a view causes it to be fully recreated. The `homepageWebAdKey` state variable is used as the `.id` for the homepage's main `WebAdView`. By updating this key (e.g., with `homepageWebAdKey = UUID()` in `.onAppear`), you force SwiftUI to destroy and recreate the ad view. This is useful if you want to guarantee the ad view is fully reset and reloaded whenever the homepage appears, rather than just updating its content. Without this, the ad view may persist its state across navigation and not reload as expected.

2. **Consent Flow:**
   - The ad will only load after the user has given consent via Didomi.
   - If consent is not given, the ad view will remain empty until consent is received.

3. **Change Consent Preferences:**
   - Use the provided button to call `Didomi.shared.showPreferences()` and allow users to update their choices.

4. **Debugging:**
   - Use the ladybug icon in the top-right toolbar to toggle debug mode on or off at runtime.
   - When debug mode is enabled, all debug logs (including ad loading, consent events, and JS bridge messages) will appear in the Xcode console.
   - The debug state is saved and restored automatically.

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
