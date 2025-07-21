# Project AdView Development Plan

## 📋 Project Overview
This project will create a modular **SN AdView SDK** for iOS that integrates web-based advertising into iOS apps using SwiftUI. The SDK will provide a seamless bridge between native iOS views and web-based ad content with consent management, dynamic sizing, and performance optimizations.

## 🎯 Core Objectives
1. **Modular Architecture**: Create a reusable SDK that can be easily integrated into any iOS project
2. **Consent Management**: Integrate Didomi SDK for GDPR/privacy compliance
3. **Dynamic Ad Rendering**: Use WKWebView to display web-based ads with responsive sizing
4. **Performance Optimization**: Implement lazy loading and proper viewability tracking
5. **Debug Support**: Provide comprehensive logging and debugging capabilities

## 🏗️ Technical Architecture

### SDK Structure
```
AdSDK/
├── Core/
│   ├── AdSDK.swift (Main SDK class)
│   ├── AdConfiguration.swift (Configuration management)
│   └── AdLogger.swift (Logging system)
├── Views/
│   ├── AdWebView.swift (Main ad view component)
│   └── AdContainer.swift (Container with observers)
├── Bridge/
│   ├── JSBridge.swift (JS-Native communication)
│   └── MessageHandler.swift (WKWebView message handling)
├── Services/
│   ├── ConsentService.swift (Didomi integration)
│   ├── AdLoadingService.swift (Ad loading logic)
│   ├── AdSizeService.swift (Event-driven size recheck)
│   ├── ViewabilityService.swift (Viewport tracking)
│   └── NavigationService.swift (WebView lifecycle on navigation)
└── Utils/
    ├── Extensions.swift (Utility extensions)
    └── Constants.swift (SDK constants & predefined sizes)
```

## 📦 Dependencies & Integration

### Swift Package Dependencies
1. **Didomi SDK**: `https://github.com/didomi/didomi-ios-sdk-spm`
2. **Google Mobile Ads**: `https://github.com/googleads/swift-package-manager-google-mobile-ads`

### Package.swift Configuration
- Target iOS 15+
- Swift 5.5+
- Include WKWebView capabilities

## 🚀 Development Phases

### Phase 1: Foundation Setup
- [ ] Configure Xcode project structure
- [ ] Add Swift Package dependencies (Didomi, Google Mobile Ads)
- [ ] Create basic SDK structure and main classes
- [ ] Implement AdConfiguration and AdLogger

### Phase 2: Core WebView Integration
- [ ] Create AdWebView SwiftUI component
- [ ] Implement WKWebView configuration for ads
- [ ] Add "annonce" label component above ad units
- [ ] Set up basic HTML template loading
- [ ] Create JS-Native bridge for communication

### Phase 3: Consent Management
- [ ] Integrate Didomi SDK
- [ ] Implement ConsentService
- [ ] Add consent synchronization between native and web
- [ ] Handle consent status changes

### Phase 4: Dynamic Sizing & Communication
- [ ] Implement size detection from web content
- [ ] Create bidirectional communication bridge
- [ ] Add auto-resizing capabilities with predefined height options
- [ ] Handle ad load events and callbacks
- [ ] Implement event-driven size recheck using YM/GPT events (on ad refresh)
- [ ] Add WebView lifecycle management for navigation handling

### Phase 5: Performance Optimizations
- [ ] Implement two-tier lazy loading based on viewport position:
  - **Fetch Phase**: Create/load WKWebView + send JS fetch event (configurable distance, e.g., 200px)
  - **Render Phase**: Send JS display event for actual ad rendering (configurable distance, e.g., 100px)
- [ ] Add viewability tracking with native observers
- [ ] Create proper visibility event handling with JS bridge
- [ ] Optimize memory usage and performance

### Phase 6: Debug & Logging
- [ ] Implement comprehensive logging system
- [ ] Add debug mode toggle
- [ ] Create JS console bridge to Xcode
- [ ] Add network request logging

### Phase 7: Testing & Documentation
- [ ] Create unit tests for core functionality using test ad units:
  - `div-gpt-ad-mobile_1`
  - `div-gpt-ad-mobile_2` 
  - `div-gpt-ad-mobile_3` 
  - `div-gpt-ad-mobile_4` 
- [ ] Write comprehensive documentation
- [ ] Create example implementation with demo app:
  - **Homepage**: Features `mobile_1` ad unit with navigation to 4 articles
  - **Article 1**: `mobile_1` + content
  - **Article 2**: `mobile_1` + content + `mobile_2`
  - **Article 3**: `mobile_1` + content + `mobile_2` + content + `mobile_3`
  - **Article 4**: `mobile_1` + content + `mobile_2` + content + `mobile_3` + content + `mobile_4`

## 🔧 Key Technical Features

### 1. AdWebView Component
```swift
AdWebView(
    adUnitId: "div-gpt-ad-mobile_1",
    adSize: $adSize,
    predefinedHeight: 320,  // Optional: prevents content shifting
    showAdLabel: true       // Shows "annonce" label above ad
)
.frame(width: adSize.width, height: adSize.height)
```

### 2. SDK Configuration (Global Level)
```swift
let config = AdConfiguration(
    baseURL: "https://your-domain.com/ad-template.html",
    didomiApiKey: "your-didomi-api-key",
    debugMode: true,
    lazyLoadingFetch: 200,  // Distance (px) to start WebView loading and YM fetching
    lazyLoadingRender: 100, // Distance (px) to trigger YM ad display/impression
    unloadOnNavigation: true, // Global: Auto-unload WebViews on view changes
    showAdLabels: true      // Global: Show "annonce" labels on all ad units
)
```

### 3. Initialization
```swift
AdSDK.shared.initialize(
    didomiApiKey: "your-didomi-api-key",
)
```

## 🛠️ Implementation Details

### HTML Template Features
- Didomi consent integration
- Yield Manager ad loading with two-phase approach:
  - **Fetch Phase**: Use `ayManager.fetch()` for pre-loading without display
  - **Render Phase**: Use `ayManager.display()` for actual ad rendering
- Size detection and reporting
- Debug logging capabilities
- Visibility tracking support
- Event-driven size recheck using YM/GPT events (on ad refresh)
- Predefined ad size constraints (320x320, 300x250, etc.)

### Native-Web Bridge
- **Native → Web**: Consent status, visibility changes, configuration, navigation events, fetch/render signals
- **Web → Native**: Size updates, ad events, console logs, errors, refresh event triggers

### Viewability Solution
1. **Native Observer**: Track WebView position relative to screen
2. **Event Broadcasting**: Send visibility events to WebView
3. **CSS Class Toggle**: Hide/show ads based on visibility
4. **Intersection Tracking**: Monitor 50% visibility threshold

### Lazy Loading Implementation
1. **Two-Tier Loading System**:
   - **Fetch Tier**: At configurable distance (e.g., 200px):
     - Load/create the WKWebView in native view
     - Send JS fetch event to trigger `ayManager.fetch()`
   - **Render Tier**: At closer distance (e.g., 100px), send JS display event for `ayManager.display()`
2. **Scroll Observer**: Monitor scroll position in parent view with dual thresholds
3. **State Management**: Track WebView creation, fetch, and render states to prevent duplicate operations

## 🎨 Advanced Features

### Predefined Ad Sizes
```swift
enum AdSize {
    case mobile1 // 320x320 or 300x250
    case mobile2 // 300x250 or 320x100
    case mobile3 // 300x250
    case mobile4 // 320x320
    case custom(width: CGFloat, height: CGFloat)
}
```

### Event-Driven Size Recheck System
- **YM Events**: `slotOnload`, `slotRenderEnded`, `slotVisibilityChanged`
- **GPT Events**: `gpt.events.SlotOnload`, `gpt.events.SlotRenderEnded`
- **Size Recheck Logic**: Trigger size detection only when YM/GPT indicates ad refresh
- **No Auto-Refresh**: Ad refresh handled entirely by YM/Prebid wrapper logic

### Navigation Lifecycle Management
```swift
// Global WebView management (SDK-wide setting)
AdSDK.shared.configure(unloadOnNavigation: true)

AdSDK.shared.onViewWillDisappear { viewId in
    // Unload all WebViews for this view
}

AdSDK.shared.onViewDidAppear { viewId in
    // Load WebViews for new view
}
```

### Two-Phase Ad Loading (HTML Template)
```javascript
// Phase 1: Fetch (triggered when WebView loads + at 200px distance)
// Native creates WebView, then sends fetch signal
ayManager.fetch(['div-gpt-ad-mobile_1']);

// Phase 2: Display (triggered at 100px distance)
ayManager.display(['div-gpt-ad-mobile_1']);
```

### Ad Labeling for Compliance
```swift
// Individual control
AdWebView(adUnitId: "mobile_1", showAdLabel: true)

// Global control
AdConfiguration(showAdLabels: true)

// Custom styling (future enhancement)
AdWebView(adUnitId: "mobile_1", adLabelStyle: .custom(text: "annonce", color: .gray))
```

## 📋 File Creation Order

### Immediate Next Steps
1. `Package.swift` - Define Swift package with dependencies
2. `AdSDK/Sources/AdSDK/Core/AdSDK.swift` - Main SDK class
3. `AdSDK/Sources/AdSDK/Core/AdConfiguration.swift` - Configuration management
4. `AdSDK/Sources/AdSDK/Views/AdWebView.swift` - Main SwiftUI component
5. `AdSDK/Sources/AdSDK/Bridge/JSBridge.swift` - JS-Native communication

### Configuration Files
6. `AdSDK/Sources/AdSDK/Resources/ad-template.html` - HTML template
7. `AdSDK/Sources/AdSDK/Utils/Constants.swift` - SDK constants & predefined ad sizes
8. `AdSDK/Sources/AdSDK/Core/AdLogger.swift` - Logging system

### Advanced Features
9. `AdSDK/Sources/AdSDK/Services/ConsentService.swift` - Didomi integration
10. `AdSDK/Sources/AdSDK/Services/ViewabilityService.swift` - Viewport tracking
11. `AdSDK/Sources/AdSDK/Services/AdLoadingService.swift` - Ad loading logic
12. `AdSDK/Sources/AdSDK/Services/AdSizeService.swift` - Event-driven size recheck management
13. `AdSDK/Sources/AdSDK/Services/NavigationService.swift` - WebView lifecycle management

## 🔍 Known Challenges & Solutions

### Challenge 1: WebView Viewability
- **Problem**: WebView reports 100% viewability regardless of screen position
- **Solution**: Native visibility observer + JS event system + CSS visibility toggle

### Challenge 2: Two-Tier Lazy Loading Performance
- **Problem**: WebViews load immediately, causing unnecessary impressions and poor performance
- **Solution**: Implement two-tier system:
  1. **Fetch Phase**: Create WKWebView in native + trigger `ayManager.fetch()` without impressions
  2. **Render Phase**: Trigger `ayManager.display()` for actual ad display and impression tracking

### Challenge 3: Consent Synchronization
- **Problem**: Keeping consent status in sync between native and web
- **Solution**: Bidirectional bridge with real-time updates

### Challenge 4: Content Shifting Prevention
- **Problem**: Dynamic ad sizing causes layout shifts and poor UX
- **Solution**: Predefined height constraints for ad units (320x320, 300x250) with graceful fallbacks

### Challenge 5: Efficient Size Recheck Management
- **Problem**: Unnecessary size rechecks waste resources and impact performance
- **Solution**: Event-driven size recheck using YM/GPT native events (only when ads actually refresh)

### Challenge 6: WebView Memory Management
- **Problem**: WebViews persist across navigation causing memory leaks
- **Solution**: Global automatic WebView unloading/loading based on native view lifecycle

## 🎯 Success Criteria

### Functional Requirements
- ✅ Modular SDK that integrates easily into existing projects
- ✅ Proper consent management with Didomi
- ✅ Dynamic ad sizing based on content
- ✅ Lazy loading to improve performance
- ✅ Accurate viewability tracking
- ✅ Comprehensive debug logging
- ✅ Ad labeling compliance ("annonce" labels)

### Performance Requirements
- Memory usage < 50MB per ad instance
- Zero memory leaks in production

### Integration Requirements
- SwiftUI and UIKit compatibility
- iOS 15+ support
- Simple 3-line integration for basic use cases

## 📝 Next Actions

1. **Review and Approve Plan**: Get feedback on this plan before proceeding
2. **Setup Project Structure**: Create Swift Package with proper organization
3. **Implement Foundation**: Start with core SDK classes and configuration
4. **Iterative Development**: Build and test each phase incrementally
5. **Continuous Testing**: Add tests as each component is developed

---

**Note**: This plan prioritizes modularity, performance, and ease of integration while addressing the known issues from the legacy implementation. Each phase builds upon the previous one, allowing for iterative development and testing.
