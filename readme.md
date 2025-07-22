# Project AdView

## Overview
Project AdView is a SwiftUI-based demo app that showcases how to display ad content in a privacy-compliant way using the Didomi consent management SDK. Ad units are rendered in `WKWebView` components and will only load after the user has given consent, ensuring that no consent notices appear inside the ad views themselves.

## Key Features
- **Consent-Gated Ad Loading:** Ad content is only loaded after Didomi consent is given.
- **SwiftUI Integration:** Uses `UIViewControllerRepresentable` to bridge UIKit `WKWebView` into SwiftUI.
- **Multiple Ad Units:** Easily add ad units to homepage and articles.
- **Consent Preferences:** Users can change their consent preferences at any time.

## Main Components

### 1. Didomi SDK Integration
- The Didomi SDK is initialized in `AppDelegate`.
- A global event listener posts a `DidomiConsentChanged` notification when consent changes.
- The SDK UI is set up using a custom `DidomiWrapper` to ensure proper consent collection.

### 2. WebAdView
- `WebAdView` is a SwiftUI component that displays an ad in a `WKWebView`.
- It only loads ad content after consent is given, listening for consent events via NotificationCenter.
- Consent status is injected into the web view using Didomi's JavaScript API.

### 3. Homepage and Articles
- The homepage and each article can display one or more `WebAdView` ad units.
- Navigation between articles is supported.

## How to Use WebAdView

1. **Add the WebAdView to your SwiftUI view:**
   ```swift
   WebAdView()
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

## Project Structure
- `Project_AdViewApp.swift`: App entry point and Didomi SDK setup.
- `Views/WebAdView.swift`: Ad unit implementation and consent gating logic.
- `Views/HomepageView.swift`: Main navigation and ad placement.
- `DidomiWrapper.swift`: Ensures Didomi UI is properly presented in SwiftUI.

## Requirements
- Xcode 12+
- Swift 5.3+
- Didomi iOS SDK (see Documentation/Didomi SDK.md for setup)

## Customization
- Change the ad template URL in `WebAdView.swift` as needed.
- Add more ad units by placing additional `WebAdView()` components in your views.

## Privacy Compliance
This project ensures that ad content is only loaded after explicit user consent, in line with privacy regulations (GDPR, CCPA, etc.).

## Troubleshooting
- If ads do not load, check that Didomi SDK is initialized and consent is given.
- Ensure the DidomiWrapper is present in your view hierarchy for proper UI handling.

## License
This project is for demo purposes. Please adapt for production use and review privacy requirements for your region.
