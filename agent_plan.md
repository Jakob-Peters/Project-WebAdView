# Project WebAdView Development Plan

## 🚀 Development Modules

### Module 1: Demo Article App Setup
- [X] **1a. Frontend Homepage**
  - [X] Create SwiftUI homepage with placeholder for 1 ad unit
  - [X] Add navigation to 3 article pages
  - [X] Implement basic routing structure
- [X] **1b. Article Pages**
  - [X] Create Article 1: Filler text + 1 ad unit placeholder
  - [X] Create Article 2: Filler text + 2 ad unit placeholders
  - [X] Create Article 3: Filler text + 3 ad unit placeholders
- [X] **1c. Navigation System**
  - [X] Implement navigation between homepage and articles
  - [X] Set up proper view lifecycle management
  - [X] Test navigation flow

### Module 2: Didomi SDK Integration
- [X] **2a. SDK Import & Initialization**
  - [X] Add Didomi SDK dependency to project
  - [X] Import and configure Didomi SDK
  - [X] Load consent notice on app launch
- [X] **2b. AppDelegate Integration**
  - [X] Set up AppDelegate for SDK initialization
  - [X] Implement `shared.onReady` event handling
  - [X] Ensure SDKs only initialize after Didomi is ready
- [X] **2c. Consent Management UI**
  - [X] Add "Change Consent" button to demo app
  - [X] Implement consent status change handling
  - [X] Test consent flow and status updates
- [X] **2d. Passing consent info to webview**
  - [X] Setup the SDK for passing consent info via JS to webview.
  - [X] Setup the HTML template for recieving external consent signal.
  - [X] Fix HTML template to not open consent notice.

### Module 3: WebView Setup & Basic Communication
- [X] **3a. WebView Integration**
  - [X] Create WKWebView component with proper styling
  - [X] Load HTML page with ad unit containers
  - [X] Implement basic WebView configuration
- [X] **3b. WebView config for ads - Media content & external click**
  - [X] - Media Content Configuration in webview
  - [X] - Optimize WKWebView Click Behavior
- [X] **3c. JavaScript Bridge Setup**
  - [X] Set up WKScriptMessageHandler for native-to-JS communication
  - [X] Implement basic message passing from native to WebView
  - [X] Test bidirectional communication
- [X] **3d. Ad Unit Variable Passing**
  - [X] Pass ad unit IDs from native view to WebView
  - [X] Configure ad unit parameters via JS communication
  - [X] Implement ad unit identification system
- [X] **3e. WebView Lifecycle Management**
  - [X] Implement WebView unloading on view navigation
  - [X] Set up WebView reloading for new views
  - [X] Handle memory management for WebView instances
- [X] **3f. Ad Label**
  - [X] Implement an Ad Label via the WebAdView.

### Module 4: Advanced JS Communication & Dynamic Sizing
- [X] **4a. Console Log Bridge**
  - [X] Capture WebView console logs in native view
  - [X] Forward console.log, console.error, console.warn to Xcode logs
  - [X] Implement log filtering and formatting
- [X] **4b. Dynamic Frame Sizing**
  - [X] Detect ad unit dimensions from WebView
  - [X] Communicate size changes to native view
  - [X] Update SwiftUI frame sizes dynamically
  - [X] Handle size change animations and layout updates

### Module 5: Native View Lazy Loading (Two Tier)
- [ ] **5a. Distance-Based WebView Fetching**
  - [ ] Implement scroll position monitoring in native view
  - [ ] Calculate distance of ad units from viewport
  - [ ] Create/load WebViews based on configurable distance thresholds
  - [ ] Manage WebView lifecycle states (not created, fetched, rendered)
- [ ] **5b. JS Fetch Event System**
  - [ ] Send JS fetch event to WebView when at fetch distance (e.g., 200px)
  - [ ] Trigger `ayManager.fetch()` without displaying ads
  - [ ] Handle fetch completion callbacks
  - [ ] Implement fetch state tracking
- [ ] **5c. JS Display Event System**
  - [ ] Send JS display event when at render distance (e.g., 100px)
  - [ ] Trigger `ayManager.display()` for actual ad rendering
  - [ ] Handle display completion and impression tracking
  - [ ] Prevent duplicate fetch/display calls

### Module 6: Debugging Infrastructure
- [X] **6a. Debug Mode Toggle**
  - [X] Implement easy debug enabler for console logs
  - [X] Add debug mode for both WebView and native view
  - [X] Create debug configuration management
- [ ] **6b. Yield Manager Debug Integration**
  - [X] Add debug query parameter to WebView URL
  - [X] Enable Yield Manager debugging within WebView
  - [X] Implement debug parameter configuration
- [ ] **6c. UI Debug Overlay**
  - [ ] Add debugging information overlay in WebView
  - [X] Integrate Publisher Console from gpt.js
  - [ ] Create debug UI controls within WebView
  - [X] Implement overlay toggle functionality

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
WebAdView.shared.initialize(
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
// Global WebView management
WebAdView.shared.configure(unloadOnNavigation: true)

WebAdView.shared.onViewWillDisappear { viewId in
    // Unload all WebViews for this view
}

WebAdView.shared.onViewDidAppear { viewId in
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

## 📋 Module Implementation Order

### Current Focus: Module-by-Module Development
Instead of building the project in phases, we'll implement complete functional modules one at a time. Each module will be fully functional before moving to the next.

### Module 1: Demo Article App (Foundation)
**Objective**: Create a working demo app with navigation and ad unit placeholders
- **Deliverable**: Functional demo app with 3 articles and navigation
- **Files to create**:
  - `DemoApp/ContentView.swift` - Homepage with ad placeholder
  - `DemoApp/ArticleView.swift` - Reusable article view component
  - `DemoApp/NavigationRouter.swift` - Navigation management
  - `DemoApp/MockData.swift` - Sample article content

### Module 2: Didomi SDK Integration
**Objective**: Full consent management integration
- **Deliverable**: Working consent notice and management system
- **Files to create**:
  - `ConsentManager.swift` - Didomi SDK wrapper
  - `AppDelegate.swift` - SDK initialization orchestration
  - `ConsentService.swift` - Consent status management

### Module 3: WebView Setup & Basic Communication  
**Objective**: Working WebView with native-JS communication
- **Deliverable**: WebView displaying HTML with ad containers and basic JS bridge
- **Files to create**:
  - `AdWebView.swift` - Main WebView component
  - `JSBridge.swift` - Native-JS communication
  - `ad-template.html` - HTML template with ad containers
  - `WebViewManager.swift` - WebView lifecycle management

### Module 4: Advanced JS Communication & Dynamic Sizing
**Objective**: Advanced communication features and dynamic sizing
- **Deliverable**: Console log forwarding and dynamic frame sizing
- **Files to create**:
  - `ConsoleLogHandler.swift` - WebView console integration
  - `SizeManager.swift` - Dynamic sizing management
  - Enhanced `JSBridge.swift` - Advanced communication features

### Module 5: Native View Lazy Loading (Two Tier)
**Objective**: Implement performance-optimized lazy loading with two-tier system
- **Deliverable**: Efficient lazy loading based on viewport distance with fetch/display phases
- **Files to create**:
  - `LazyLoadingManager.swift` - Two-tier lazy loading orchestration
  - `ScrollObserver.swift` - Viewport distance monitoring
  - `LoadingStateManager.swift` - WebView state tracking (not created, fetched, rendered)

### Module 6: Debugging Infrastructure
**Objective**: Comprehensive debugging tools
- **Deliverable**: Full debugging capabilities for development
- **Files to create**:
  - `DebugManager.swift` - Debug mode management
  - `DebugOverlay.swift` - UI debug controls
  - Enhanced `ad-template.html` - Debug features integration

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


### Immediate Start: Module 1 - Demo Article App
1. **Create Demo App Structure**: Set up SwiftUI navigation and article views
2. **Implement Homepage**: Homepage with 1 ad placeholder and 3 article links
3. **Build Article Views**: 3 different article pages with varying ad unit counts
4. **Test Navigation**: Ensure smooth navigation between all views

### Module Progression Strategy
- **One Module at a Time**: Complete each module fully before proceeding
- **Incremental Testing**: Test each module thoroughly before moving forward
- **Iterative Refinement**: Refine and perfect each module as needed
- **Documentation**: Document each module's functionality and integration points

### Development Approach
- Focus on **functional completeness** per module.
- Each module should be **demonstrable and testable** independently
- Build **incrementally** with working demos at each stage
- Maintain **clean separation** between module responsibilities

---

**Note**: This modular approach allows for focused development, easier testing, and clearer progress tracking. Each module builds upon the previous ones while maintaining distinct functional boundaries.
