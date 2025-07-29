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
- [X] **3f. Misc**
  - [X] Implement an Ad Label via the WebAdView.
  - [X] Fix webview scrolling within native view.

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
- [X] **5a. Distance-Based WebView Fetching**
  - [X] Implement scroll position monitoring in native view
  - [X] Calculate distance of ad units from viewport
  - [X] Create/load WebViews based on configurable distance thresholds
  - [X] Manage WebView lifecycle states (not created, fetched, rendered)
- [X] **5b. JS Fetch Event System**
  - [X] Send JS fetch event to WebView when at fetch distance (e.g., 200px)
  - [X] ayManager will automatically fetch on `onConsentInitialization`, which happens when we have a consent signal
- [X] **5c. JS Display Event System**
  - [X] Send JS display event when at render distance (e.g., 100px) (still missing AY enitiy setup for manual dispatch)
  - [X] Trigger `ayManager.dispatchManualEvent()` for actual ad rendering (using manual event, setup within Yield Manager)
  - [X] Setup ayManager to receive manualEvent signal for rendering replacing `cmd.push.display()`

### Module 6: Correct viewabiltiy measurement
- [ ] **6a. Native Visibility Calculation**
  - [ ] Implement scroll position monitoring for each WebAdView
  - [ ] Calculate visible percentage and coordinates (top, bottom) of ad units relative to the native screen
  - [ ] Ensure visibility calculation is accurate and updates on scroll

- [ ] **6b. Native-to-JS Communication**
  - [ ] Establish a dedicated JS message channel for viewability data
  - [ ] Send viewability data (`adUnitId`, `visibleTop`, `visibleBottom`, `visiblePercentage`, etc.) from native to WebView
  - [ ] Example: `webView.evaluateJavaScript("stepnetwork.updateViewability(adUnitId, { visibleTop, visibleBottom });")`

- [ ] **6c. WebView CSS Overlay (Masking)**
  - [ ] In WebView HTML/CSS, create a high-Z-index transparent overlay div for each ad unit
  - [ ] Implement JS function `stepnetwork.updateViewability()` to receive native data and adjust overlay
  - [ ] Dynamically mask non-visible portions of the ad (e.g., overlay covers top 50% if only bottom 50% is visible)

- [ ] **6d. Performance & UX Optimizations**
  - [ ] Debounce/throttle JS calls (e.g., every 50-100ms) to prevent flicker and performance issues
  - [ ] Apply smooth CSS transitions to overlay changes
  - [ ] Add buffer zones (e.g., 10-20px) for smoother updates
  - [ ] Focus on percentage thresholds (e.g., 50% for 1s) rather than pixel-perfect updates

- [ ] **6e. Batch & Efficient DOM Updates**
  - [ ] Batch JS calls for multiple ads when scrolling
  - [ ] Minimize DOM changes; prefer CSS transforms for performance
  - [ ] Profile with Xcode Instruments and browser dev tools

### Module 7: Debugging Infrastructure
- [X] **7a. Debug Mode Toggle**
  - [X] Implement easy debug enabler for console logs
  - [X] Add debug mode for both WebView and native view
  - [X] Create debug configuration management
- [X] **7b. Yield Manager Debug Integration**
  - [X] Add debug query parameter to WebView URL
  - [X] Enable Yield Manager debugging within WebView
  - [X] Implement debug parameter configuration
- [X] **7c. UI Debug Overlay**
  - [X] Add debugging information overlay in WebView
  - [X] Integrate Publisher Console from gpt.js
  - [X] Create debug UI controls within WebView
  - [X] Implement overlay toggle functionality

