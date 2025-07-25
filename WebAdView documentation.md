# WebAdView Documentation

A comprehensive guide to implementing and using the WebAdView system for SwiftUI applications with Google Ad Manager integration through STEP Network's Yield Manager.

## ⚠️ Important: STEP Network Integration Requirements

**Before implementing WebAdView components, you must coordinate with STEP Network regarding:**

- **Available ad unit IDs** and their corresponding formats
- **Supported ad sizes** for each ad unit (determined remotely by Yield Manager)
- **Custom targeting parameters** configured for your account
- **Geographic and content targeting** requirements
- **Expected ad behavior** and responsive design considerations

**Key Integration Constraints:**
- **Ad sizing is controlled remotely** by STEP Network's Yield Manager, not by local frame constraints
- **Custom targeting parameters** must match STEP Network's account configuration
- **Ad unit IDs** must be provided by STEP Network for your specific setup
- **Local frame constraints** are for UI layout only and do not influence actual ad dimensions

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation & Setup](#installation--setup)
3. [Core Components](#core-components)
4. [Basic Usage](#basic-usage)
5. [Advanced Features](#advanced-features)
6. [Custom Targeting](#custom-targeting)
7. [Lazy Loading Configuration](#lazy-loading-configuration)
8. [Consent Management](#consent-management)
9. [Debug Mode](#debug-mode)
10. [Troubleshooting](#troubleshooting)
11. [API Reference](#api-reference)
12. [Best Practices](#best-practices)

## Quick Start

The simplest implementation requires an ad unit ID provided by STEP Network:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            // Use ad unit ID provided by STEP Network
            WebAdView(adUnitId: "div-gpt-ad-your-unit-id")
        }
    }
}
```

**Note:** Replace `"div-gpt-ad-your-unit-id"` with the actual ad unit ID provided by STEP Network for your implementation.

## Installation & Setup

### 1. Project Dependencies

Add the required dependencies to your Xcode project:

- **Didomi SDK**: For consent management (GDPR/CCPA compliance)
- **WebKit**: For WKWebView integration (built-in to iOS)

### 2. File Structure

Your project should include these core files:

```
Project/
├── Views/
│   └── HomepageView.swift          # Your main view
├── Configs/
│   ├── WebAdView.swift            # Main WebAdView component
│   ├── LazyLoadingManager.swift   # Lazy loading system
│   └── DidomiWrapper.swift        # Consent management
└── Project_AdViewApp.swift        # App entry point
```

### 3. Consent Management Setup

Initialize the Didomi SDK in your app's entry point:

```swift
import SwiftUI
import Didomi

@main
struct Project_AdViewApp: App {
    init() {
        // Initialize Didomi for consent management
        DidomiWrapper.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            HomepageView()
        }
    }
}
```

## Core Components

### WebAdView

The main SwiftUI component that displays ads with automatic sizing and consent management. Ad content and dimensions are delivered by STEP Network's Yield Manager.

### LazyLoadingManager

A singleton manager that optimizes performance by:
- Loading ads only when they're about to become visible
- Optionally unloading ads when they're far from view
- Managing memory usage across multiple ads
- Working with STEP Network's ad delivery system

### DidomiWrapper

Handles GDPR/CCPA consent collection and provides consent status to the ad system.

## Basic Usage

### Simple Ad Display

```swift
// Use ad unit ID provided by STEP Network
WebAdView(adUnitId: "div-gpt-ad-homepage-banner")
```

### With Custom Dimensions (UI Layout Only)

```swift
// Frame constraints affect container layout, not ad content size
WebAdView(adUnitId: "div-gpt-ad-homepage-banner")
    .frame(width: 728, height: 90)  // Container size for layout stability
```

**Important:** The `.frame()` modifier controls the container size for UI layout purposes. The actual ad dimensions are determined by STEP Network's configuration.

### With Ad Label

```swift
WebAdView(adUnitId: "div-gpt-ad-homepage-banner")
    .showAdLabel(true)
    .adLabelText("Advertisement")
    .adLabelFont(.system(size: 12, weight: .medium))
```

### Multiple Ads in ScrollView

```swift
ScrollView {
    LazyVStack(spacing: 20) {
        ForEach(articles) { article in
            ArticleView(article: article)
            
            if article.shouldShowAd {
                // Use STEP Network provided ad unit ID
                WebAdView(adUnitId: "div-gpt-ad-in-content")
                    .frame(height: 250) // Container height for layout
            }
        }
    }
}
```

## Advanced Features

### Dynamic Sizing

WebAdView automatically adjusts its size based on the ad content delivered by STEP Network's Yield Manager:

```swift
WebAdView(adUnitId: "div-gpt-ad-responsive")
    .minWidth(300)    // Container minimum width (UI layout only)
    .maxWidth(728)    // Container maximum width (UI layout only)
    .minHeight(50)    // Container minimum height (UI layout only)
    .maxHeight(300)   // Container maximum height (UI layout only)
```

**Important:** These constraints affect the container layout only. The actual ad content size is controlled by STEP Network's configuration.

### Constraint System

Set flexible constraints that adapt to different screen sizes while maintaining UI layout stability:

```swift
WebAdView(adUnitId: "div-gpt-ad-mobile-banner")
    .minWidth(320)              // Container minimum width
    .maxWidth(.infinity)        // Container fills available width
    .initialHeight(100)         // Container starting height
    .maxHeight(250)             // Container maximum height
```

**Note:** These constraints are for UI container layout. STEP Network's Yield Manager determines the actual ad content dimensions.

## Custom Targeting

Use Google Ad Manager targeting parameters configured by STEP Network to improve ad relevance and campaign targeting:

**Important:** Custom targeting values can be added as needed, but require configuration by STEP Network within Google Ad Manager before they become usable for campaign targeting. Using unconfigured targeting keys may result in ads not displaying correctly.

### Single Value Targeting

```swift
WebAdView(adUnitId: "div-gpt-ad-homepage-banner")
    .customTargeting("section", "sports")     // Requires STEP Network configuration in GAM
    .customTargeting("category", "football")  // Requires STEP Network configuration in GAM
    .customTargeting("premium", "true")       // Requires STEP Network configuration in GAM
```

### Array Value Targeting

```swift
WebAdView(adUnitId: "div-gpt-ad-article")
    .customTargeting("tags", ["breaking", "politics", "election"])  // Requires STEP Network configuration in GAM
    .customTargeting("interests", ["news", "current-events"])       // Requires STEP Network configuration in GAM
```

### Dynamic Targeting

```swift
struct ArticleAdView: View {
    let article: Article
    
    var body: some View {
        WebAdView(adUnitId: "div-gpt-ad-article")
            .customTargeting("section", article.section)        // Consult with STEP Network for configuration
            .customTargeting("author", article.author.id)       // Consult with STEP Network for configuration
            .customTargeting("tags", article.tags)              // Consult with STEP Network for configuration
            .customTargeting("premium", article.isPremium ? "true" : "false") // Consult with STEP Network for configuration
    }
}
```

### User-Based Targeting

```swift
WebAdView(adUnitId: "div-gpt-ad-personalized")
    .customTargeting("user_type", userManager.userType)          // Requires STEP Network configuration in GAM
    .customTargeting("subscription", userManager.isSubscribed ? "premium" : "free") // Requires STEP Network configuration in GAM
    .customTargeting("age_group", userManager.ageGroup)          // Requires STEP Network configuration in GAM
    .customTargeting("interests", userManager.interests)         // Requires STEP Network configuration in GAM
```

**Best Practice:** Before implementing any custom targeting, consult with STEP Network to obtain a list of available targeting keys and acceptable values. Custom targeting parameters can be added as needed but require configuration within Google Ad Manager to ensure proper campaign delivery.

## Lazy Loading Configuration

The lazy loading system is managed by `LazyLoadingManager.shared`:

### Default Configuration

```swift
// These are the default values - no configuration needed
LazyLoadingManager.shared.fetchThreshold = 800    // Start loading 800pt before visible
LazyLoadingManager.shared.displayThreshold = 200  // Show ad 200pt before visible
LazyLoadingManager.shared.unloadThreshold = 1600  // Unload 1600pt after leaving view
LazyLoadingManager.shared.unloadingEnabled = false // Unloading disabled by default
```

### Performance Optimization

For memory-constrained scenarios, enable unloading:

```swift
// Enable unloading for better memory usage
LazyLoadingManager.shared.unloadingEnabled = true
LazyLoadingManager.shared.unloadThreshold = 1200  // More aggressive unloading
```

### Aggressive Loading

For better user experience with fast scrolling:

```swift
// Load ads earlier for smoother experience
LazyLoadingManager.shared.fetchThreshold = 1200
LazyLoadingManager.shared.displayThreshold = 400
```

### Conservative Loading

For slower networks or data-conscious users:

```swift
// Load ads closer to viewport
LazyLoadingManager.shared.fetchThreshold = 400
LazyLoadingManager.shared.displayThreshold = 100
```

## Consent Management

The system automatically handles consent through the Didomi SDK:

### Automatic Consent Checking

```swift
// WebAdView automatically checks consent before loading ads
WebAdView(adUnitId: "/22722773121/banner")
// No additional consent code needed
```

### Manual Consent Management

```swift
// Access consent status directly
let hasConsent = DidomiWrapper.shared.hasConsent()

if hasConsent {
    // Load personalized ads
    WebAdView(adUnitId: "/22722773121/personalized-banner")
} else {
    // Load non-personalized ads or show alternative content
    WebAdView(adUnitId: "/22722773121/non-personalized-banner")
}
```

### Consent Status Updates

```swift
// Listen for consent changes
NotificationCenter.default.addObserver(
    forName: .didomiConsentChanged,
    object: nil,
    queue: .main
) { _ in
    // Refresh ads when consent status changes
    // WebAdView will automatically adapt
}
```

## Debug Mode

### Enabling Debug Mode

```swift
// In DebugSettings.swift or your configuration
struct DebugSettings {
    static let isDebugMode = true  // Set to false for production
}
```

### Debug Features

When debug mode is enabled:
- Debug targeting parameter `yb_target: 'alwayson-standard'` is automatically added
- Console logging shows ad loading states
- Additional debugging information is available

### Debug Targeting

Debug mode automatically adds this targeting parameter:

```javascript
googletag.pubads().setTargeting('yb_target', 'alwayson-standard');
```

This parameter is preserved even when custom targeting is used.

## Troubleshooting

### Common Issues

#### Ads Not Loading

1. **Check Ad Unit ID**: Ensure the ad unit ID is correct and active
2. **Verify Network**: Check internet connectivity
3. **Consent Status**: Verify consent has been granted
4. **Debug Mode**: Enable debug mode to see console logs

```swift
// Add debugging to your ad view
WebAdView(adUnitId: "/22722773121/test-unit")
    .onAppear {
        print("Ad view appeared")
        print("Consent status: \(DidomiWrapper.shared.hasConsent())")
    }
```

#### Performance Issues

1. **Too Many Ads**: Limit concurrent ads in view
2. **Unloading Disabled**: Consider enabling unloading for memory optimization
3. **Threshold Too Low**: Increase `fetchThreshold` to reduce rapid loading/unloading

```swift
// Optimize for performance
LazyLoadingManager.shared.unloadingEnabled = true
LazyLoadingManager.shared.fetchThreshold = 1000
```

#### Layout Issues

1. **Dynamic Sizing**: Use constraints instead of fixed frames
2. **Scroll Performance**: Use LazyVStack for large lists
3. **Container Size**: Ensure parent views have proper sizing

```swift
// Better layout approach
WebAdView(adUnitId: "/22722773121/responsive-ad")
    .minWidth(300)
    .maxWidth(.infinity)
    .frame(maxHeight: 250)
```

### Debugging Tools

#### Console Logging

Enable detailed logging:

```swift
// Add to your debug configuration
extension WebAdView {
    func enableLogging() -> Self {
        // Add logging configuration
        return self
    }
}
```

#### Performance Monitoring

```swift
// Monitor lazy loading performance
LazyLoadingManager.shared.performanceDelegate = YourPerformanceMonitor()
```

## API Reference

### WebAdView Initializer

```swift
WebAdView(adUnitId: String)
```

**Parameters:**
- `adUnitId`: Ad unit identifier provided by STEP Network (not a standard Google Ad Manager path)

### WebAdView Modifiers

#### Display Configuration

```swift
.showAdLabel(_ show: Bool) -> WebAdView
.adLabelText(_ text: String) -> WebAdView
.adLabelFont(_ font: Font) -> WebAdView
```

#### Size Constraints (UI Layout Only)

**Important:** These modifiers control the WebAdView container layout only. Actual ad content dimensions are controlled by STEP Network's Yield Manager.

```swift
.initialWidth(_ width: CGFloat) -> WebAdView    // Container initial width
.initialHeight(_ height: CGFloat) -> WebAdView  // Container initial height
.minWidth(_ width: CGFloat) -> WebAdView        // Container minimum width
.maxWidth(_ width: CGFloat) -> WebAdView        // Container maximum width
.minHeight(_ height: CGFloat) -> WebAdView      // Container minimum height
.maxHeight(_ height: CGFloat) -> WebAdView      // Container maximum height
```

#### Custom Targeting (Requires STEP Network Configuration in GAM)

```swift
.customTargeting(_ key: String, _ value: String) -> WebAdView      // Single value targeting
.customTargeting(_ key: String, _ values: [String]) -> WebAdView   // Array value targeting
```

**Note:** Custom targeting values can be added as needed, but require configuration by STEP Network within Google Ad Manager before they become usable for campaign targeting.

### LazyLoadingManager Properties

```swift
var fetchThreshold: CGFloat        // Distance to start fetching
var displayThreshold: CGFloat      // Distance to display ad
var unloadThreshold: CGFloat       // Distance to unload ad
var unloadingEnabled: Bool         // Whether to unload distant ads
```

### DidomiWrapper Methods

```swift
func initialize()                  // Initialize consent management
func hasConsent() -> Bool         // Check current consent status
func showConsentNotice()          // Display consent dialog
```

## Best Practices

### STEP Network Coordination

1. **Pre-Implementation Consultation**: Always coordinate with STEP Network before implementing WebAdView components
2. **Ad Unit Verification**: Use only ad unit IDs provided by STEP Network for your specific implementation
3. **Targeting Configuration**: Ensure all custom targeting parameters are configured in your STEP Network account
4. **Size Expectations**: Understand the expected ad dimensions for each ad unit to set appropriate container constraints
5. **Testing Protocol**: Coordinate testing procedures with STEP Network to ensure proper ad delivery

### Performance

1. **Use LazyVStack**: For scrollable content with multiple ads
2. **Limit Concurrent Ads**: Don't load too many ads simultaneously
3. **Consider Unloading**: Enable for memory-constrained scenarios
4. **Optimize Thresholds**: Adjust based on your scroll behavior

### User Experience

1. **Responsive Design**: Use constraint-based sizing
2. **Loading States**: Provide visual feedback during ad loading
3. **Error Handling**: Gracefully handle ad loading failures
4. **Consent First**: Always check consent before loading personalized ads

### Ad Revenue

1. **Strategic Placement**: Place ads at natural content breaks (coordinate placement strategy with STEP Network)
2. **Viewability**: Ensure ads have time to be seen and meet viewability requirements
3. **Targeting Accuracy**: Use relevant custom targeting parameters configured by STEP Network
4. **A/B Testing**: Coordinate A/B testing of different ad placements and targeting with STEP Network
5. **Performance Monitoring**: Work with STEP Network to monitor ad performance and optimize delivery

### Code Organization

1. **Centralize Configuration**: Keep ad unit IDs and targeting configurations in one place
2. **Reusable Components**: Create specific ad view components for different content types
3. **Environment-Based Settings**: Use different ad unit IDs for debug/production (provided by STEP Network)
4. **Documentation**: Document all ad unit IDs and their intended usage/placement

### Example App Structure

```swift
// App.swift
@main
struct MyApp: App {
    init() {
        DidomiWrapper.shared.initialize()
        configureAdSystem()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureAdSystem() {
        #if DEBUG
        LazyLoadingManager.shared.fetchThreshold = 400  // Faster loading in debug
        #else
        LazyLoadingManager.shared.fetchThreshold = 800
        LazyLoadingManager.shared.unloadingEnabled = true  // Save memory in production
        #endif
    }
}

// ContentView.swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    HeaderAdView()
                    
                    ForEach(articles, id: \.id) { article in
                        ArticleRowView(article: article)
                        
                        if shouldShowInlineAd(after: article) {
                            InlineAdView(context: article)
                        }
                    }
                }
            }
        }
    }
}

// AdViews.swift
struct HeaderAdView: View {
    var body: some View {
        WebAdView(adUnitId: "div-gpt-ad-header-banner") // STEP Network provided ID
            .customTargeting("position", "header")         // Requires STEP Network configuration in GAM
            .customTargeting("page_type", "home")          // Requires STEP Network configuration in GAM
            .maxWidth(.infinity)
            .frame(height: 100) // Container height for layout stability
    }
}

struct InlineAdView: View {
    let context: Article
    
    var body: some View {
        WebAdView(adUnitId: "div-gpt-ad-inline") // STEP Network provided ID
            .customTargeting("position", "inline")          // Requires STEP Network configuration in GAM
            .customTargeting("section", context.section)    // Requires STEP Network configuration in GAM
            .customTargeting("tags", context.tags)          // Requires STEP Network configuration in GAM
            .frame(height: 250) // Container height for layout stability
    }
}
```

**Important Implementation Notes:**
- Replace all example ad unit IDs with actual IDs provided by STEP Network
- Custom targeting parameters can be added as needed but require configuration by STEP Network within Google Ad Manager before production deployment
- Container frame sizes are for UI layout stability only
- Actual ad content dimensions are controlled by STEP Network's Yield Manager

This documentation provides a complete guide to implementing and optimizing the WebAdView system with STEP Network integration. Always coordinate with STEP Network for ad unit IDs, targeting parameters, and expected ad behavior before implementation.
