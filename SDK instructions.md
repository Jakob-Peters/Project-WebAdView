# WebAdView SDK - Technical Implementation Guide

This document provides a comprehensive technical overview of the WebAdView SDK implementation for developer teams creating similar ad integration solutions.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Core Components](#core-components)
3. [Didomi Integration](#didomi-integration)
4. [WebAdView Component](#webadview-component)
5. [Lazy Loading System](#lazy-loading-system)
6. [Debug Infrastructure](#debug-infrastructure)
7. [External URL Handling](#external-url-handling)
8. [Custom Targeting System](#custom-targeting-system)
9. [State Management](#state-management)
10. [Performance Optimizations](#performance-optimizations)
11. [JavaScript Bridge](#javascript-bridge)
12. [Environment System](#environment-system)

## Architecture Overview

The SDK follows a modular architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    SwiftUI Layer                            │
├─────────────────────────────────────────────────────────────┤
│  WebAdView (SwiftUI) → UIViewControllerRepresentable        │
├─────────────────────────────────────────────────────────────┤
│                UIKit Layer                                  │
│  WebAdViewController → WKWebView                            │
├─────────────────────────────────────────────────────────────┤
│                  Web Layer                                  │
│  HTML Template + JavaScript (STEP Network)                  │
├─────────────────────────────────────────────────────────────┤
│               Management Layer                              │
│  LazyLoadingManager + DebugSettings + DidomiWrapper         │
└─────────────────────────────────────────────────────────────┘
```

### Key Design Principles

1. **Consent-First Architecture**: All ad loading is gated behind explicit user consent
2. **Performance-Centric**: Lazy loading with configurable thresholds and memory management
3. **Debug-Friendly**: Comprehensive logging and debugging tools
4. **Privacy-Compliant**: GDPR/CCPA compliant through Didomi integration
5. **Flexible Targeting**: Support for both single and array-based custom targeting
6. **Automatic Sizing**: Dynamic resizing based on delivered ad content

## Core Components

### 1. App Initialization (`Project_AdViewApp.swift`)

**Purpose**: Entry point for SDK initialization and global setup.

**Key Implementation Details**:

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Initialize Didomi SDK
        let parameters = DidomiInitializeParameters(
            apiKey: "your-api-key",
            disableDidomiRemoteConfig: false
        )
        Didomi.shared.initialize(parameters)

        // Set up global consent listener
        Didomi.shared.onReady {
            let didomiEventListener = EventListener()
            
            didomiEventListener.onConsentChanged = { event in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("DidomiConsentChanged"), object: nil)
                }
            }
            
            Didomi.shared.addEventListener(listener: didomiEventListener)
        }
        return true
    }
}
```

**Technical Notes**:
- Uses `UIApplicationDelegateAdaptor` to bridge UIKit app lifecycle to SwiftUI
- Establishes global NotificationCenter pattern for consent changes
- Provides environment object for debug settings across the app

### 2. Debug Infrastructure (`DebugSettings.swift`)

**Purpose**: Centralized debug state management with persistence.

**Implementation**:

```swift
class DebugSettings: ObservableObject {
    @Published var isDebugEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isDebugEnabled, forKey: "isDebugEnabled")
        }
    }

    init() {
        self.isDebugEnabled = UserDefaults.standard.bool(forKey: "isDebugEnabled")
    }
}
```

**Global Debug Helper Function**:

```swift
private func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let isDebugEnabled = UserDefaults.standard.bool(forKey: "isDebugEnabled")
    if isDebugEnabled {
        print(items, separator: separator, terminator: terminator)
    }
}
```

**Technical Features**:
- `@Published` property automatically updates UI when debug state changes
- UserDefaults persistence survives app restarts
- Global `debugPrint()` function used throughout codebase
- Accessible via environment object in SwiftUI views

## Didomi Integration

### Consent Management (`DidomiWrapper.swift`)

**Purpose**: Bridge Didomi UIKit components into SwiftUI environment.

```swift
class DidomiViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Didomi.shared.setupUI(containerController: self)
    }
}

struct DidomiWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        DidomiViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
```

**Integration Pattern**:
- Must be present in SwiftUI view hierarchy for consent UI to function
- Provides necessary UIViewController context for Didomi SDK
- Handles consent collection and preference management

**Consent Gate Implementation**:

```swift
private func checkConsentAndLoad() {
    // Check existing consent status
    if Didomi.shared.isReady() && !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
        self.loadAdContent()
        return
    }
    
    // Listen for consent changes
    NotificationCenter.default.addObserver(
        forName: NSNotification.Name("DidomiConsentChanged"),
        object: nil,
        queue: .main
    ) { [weak self] _ in
        guard let self = self else { return }
        if !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
            self.loadAdContent()
        }
    }
    
    // Handle SDK ready state
    Didomi.shared.onReady {
        DispatchQueue.main.async {
            if !Didomi.shared.isUserStatusPartial() && !self.hasLoadedContent {
                self.loadAdContent()
            }
        }
    }
}
```

## WebAdView Component

### SwiftUI Interface (`WebAdView.swift`)

**Core Structure**:

```swift
struct WebAdView: View {
    // Configuration
    private let baseURL = "https://adops.stepdev.dk/wp-content/ad-template.html?didomi-disable-notice=true"
    let adUnitId: String
    
    // Ad label properties
    var showAdLabel: Bool = false
    var adLabelText: String = "annonce"
    var adLabelFont: Font = .system(size: 10, weight: .bold)
    
    // Custom targeting
    private var customTargetingParams: [String: [String]] = [:]
    
    // Dynamic sizing
    @State private var adSize: CGSize
    
    // Constraint properties
    var initialWidth: CGFloat
    var initialHeight: CGFloat
    var minWidth: CGFloat?
    var maxWidth: CGFloat?
    var minHeight: CGFloat?
    var maxHeight: CGFloat?
    
    // Lazy loading integration
    @Environment(\.adVisibilityManager) var adVisibilityManager
    @State private var loadState: AdLoadState = .notLoaded
}
```

### State Management

**Ad Load States**:

```swift
enum AdLoadState: String, CaseIterable, Equatable, Identifiable {
    var id: String { self.rawValue }
    case notLoaded    // Initial state, no resources allocated
    case fetched      // Ad content fetched, ready to display
    case displayed    // Ad visible and active
    case unloaded     // Resources deallocated, back to placeholder
}
```

**Dynamic Sizing Logic**:

```swift
// Size clamping with animation
let clampedWidth = min(max(size.width, minWidth ?? size.width), maxWidth ?? size.width)
let clampedHeight = min(max(size.height, minHeight ?? size.height), maxHeight ?? size.height)
withAnimation(.easeInOut(duration: 0.2)) {
    self.adSize = CGSize(width: clampedWidth, height: clampedHeight)
}
```

### Custom Targeting System

**Fluent API Implementation**:

```swift
// Single value targeting
func customTargeting(_ key: String, _ value: String) -> WebAdView {
    var copy = self
    copy.customTargetingParams[key] = [value]
    return copy
}

// Array value targeting
func customTargeting(_ key: String, _ values: [String]) -> WebAdView {
    var copy = self
    if values.isEmpty {
        debugPrint("[Custom Targeting] Empty array provided for key '\(key)'")
        return copy
    }
    copy.customTargetingParams[key] = values
    return copy
}
```

**JavaScript Generation**:

```swift
private func generateCustomTargetingJS() -> String {
    guard !customTargetingParams.isEmpty else { return "" }
    
    let targetingCalls = customTargetingParams.map { key, values in
        if values.count == 1 {
            return "googletag.pubads().setTargeting('\(key)', '\(values[0])');"
        } else {
            let arrayString = values.map { "'\($0)'" }.joined(separator: ", ")
            return "googletag.pubads().setTargeting('\(key)', [\(arrayString)]);"
        }
    }.joined(separator: "\n                ")
    
    return """
    googletag.cmd.push(function () {
        \(targetingCalls)
    });
    """
}
```

## Lazy Loading System

### Manager Architecture (`LazyLoadingManager.swift`)

**Core Data Structure**:

```swift
class LazyLoadingManager: ObservableObject {
    @Published var adStates: [String: AdLoadState] = [:]
    var adUnitFrames: [String: CGRect] = [:]
    var scrollViewBounds: CGRect = .zero
    
    // Configurable thresholds
    var fetchThreshold: CGFloat = 800
    var displayThreshold: CGFloat = 200
    var unloadThreshold: CGFloat = 1600
    var unloadingEnabled: Bool = false
    
    // Performance optimization
    private var throttleTimer: AnyCancellable?
    private var lastUpdateTime: Date = Date.distantPast
    private let throttleInterval: TimeInterval = 0.067 // ~15fps
    
    // Anti-flickering system
    private var unloadCandidates: [String: Date] = [:]
    private let unloadStabilityDelay: TimeInterval = 2.0
}
```

### Visibility Detection Algorithm

**Core Logic**:

```swift
private func checkAdVisibility() {
    guard !scrollViewBounds.isEmpty else { return }

    let fetchZone = scrollViewBounds.insetBy(dx: 0, dy: -fetchThreshold)
    let displayZone = scrollViewBounds.insetBy(dx: 0, dy: -displayThreshold)
    let unloadZone = scrollViewBounds.insetBy(dx: 0, dy: -unloadThreshold)
    let now = Date()

    for (adId, adFrame) in adUnitFrames {
        let currentLoadState = adStates[adId] ?? .notLoaded
        var newState: AdLoadState? = nil

        // State transition logic with hysteresis
        if currentLoadState == .notLoaded && adFrame.intersects(fetchZone) {
            newState = .fetched
            unloadCandidates.removeValue(forKey: adId)
        } else if currentLoadState == .fetched && adFrame.intersects(displayZone) {
            newState = .displayed
            unloadCandidates.removeValue(forKey: adId)
        } else if (currentLoadState == .fetched || currentLoadState == .displayed) 
                   && !adFrame.intersects(unloadZone) && unloadingEnabled {
            // Stability timer logic
            if unloadCandidates[adId] == nil {
                unloadCandidates[adId] = now
            } else if let candidateTime = unloadCandidates[adId], 
                     now.timeIntervalSince(candidateTime) >= unloadStabilityDelay {
                newState = .unloaded
                unloadCandidates.removeValue(forKey: adId)
            }
        } else {
            unloadCandidates.removeValue(forKey: adId)
        }

        if let newState = newState, newState != currentLoadState {
            adStates[adId] = newState
        }
    }
}
```

### Performance Optimization

**Throttling Mechanism**:

```swift
private func triggerVisibilityCheck() {
    let now = Date()
    let timeSinceLastUpdate = now.timeIntervalSince(lastUpdateTime)
    
    if timeSinceLastUpdate >= throttleInterval {
        lastUpdateTime = now
        checkAdVisibility()
    } else {
        if throttleTimer == nil {
            let remainingTime = throttleInterval - timeSinceLastUpdate
            throttleTimer = Timer.publish(every: remainingTime, on: .main, in: .common)
                .autoconnect()
                .first()
                .sink { [weak self] _ in
                    self?.throttleTimer = nil
                    self?.lastUpdateTime = Date()
                    self?.checkAdVisibility()
                }
        }
    }
}
```

### SwiftUI Integration

**Environment System**:

```swift
struct AdVisibilityManagerKey: EnvironmentKey {
    static let defaultValue: LazyLoadingManager? = nil
}

extension EnvironmentValues {
    var adVisibilityManager: LazyLoadingManager? {
        get { self[AdVisibilityManagerKey.self] }
        set { self[AdVisibilityManagerKey.self] = newValue }
    }
}
```

**Modifier Implementation**:

```swift
private struct LazyLoadAdInternalModifier: ViewModifier {
    @StateObject private var manager: LazyLoadingManager
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollViewBoundsPreferenceKey.self,
                        value: proxy.frame(in: .global)
                    )
                }
            )
            .onPreferenceChange(ScrollViewBoundsPreferenceKey.self) { bounds in
                manager.updateScrollViewBounds(bounds)
            }
            .onPreferenceChange(AdFramePreferenceKey.self) { frames in
                for (adId, frame) in frames {
                    manager.updateAdFrame(adId, frame: frame)
                }
            }
            .environment(\.adVisibilityManager, manager)
    }
}
```

## WebAdViewController Implementation

### WKWebView Configuration

**Optimal Settings**:

```swift
private func setupWebView() {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = true
    config.mediaTypesRequiringUserActionForPlayback = []
    config.preferences.javaScriptCanOpenWindowsAutomatically = true

    let userContentController = WKUserContentController()
    userContentController.add(self, name: "nativeBridge")
    config.userContentController = userContentController

    webView = WKWebView(frame: view.bounds, configuration: config)
    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    webView.scrollView.isScrollEnabled = false
    webView.uiDelegate = self
    webView.navigationDelegate = self
}
```

### External URL Handling

**Decision Logic**:

```swift
private func shouldHandleExternally(navigationAction: WKNavigationAction, initialURL: URL?) -> Bool {
    guard let targetURL = navigationAction.request.url else { return false }
    
    // Non-HTTP schemes
    if let scheme = targetURL.scheme, !["http", "https"].contains(scheme.lowercased()) {
        return true
    }
    
    // Popup windows (target="_blank")
    if navigationAction.targetFrame == nil {
        return true
    }
    
    // Different domain navigation
    if let initialURL = initialURL,
       let initialDomain = initialURL.host,
       let targetDomain = targetURL.host,
       initialDomain != targetDomain,
       navigationAction.targetFrame?.isMainFrame == true {
        return true
    }
    
    return false
}
```

## JavaScript Bridge

### Native-Web Communication

**Message Handler**:

```swift
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if let dict = message.body as? [String: Any], let type = dict["type"] as? String {
        switch type {
        case "console":
            let level = dict["level"] as? String ?? "log"
            let msg = dict["message"] as? String ?? ""
            debugPrint("[WebAdView] [HTML] [\(level.uppercased())] \(msg)")
        case "adSize":
            if let width = dict["width"] as? CGFloat, let height = dict["height"] as? CGFloat {
                onAdSizeChange?(CGSize(width: width, height: height))
            }
        default:
            debugPrint("[WebAdView] [HTML] [Unknown type]", dict)
        }
    }
}
```

### Script Injection System

**Content Injection Order**:

1. **Didomi Consent Script** (Document Start)
2. **Debug Panel Script** (Document End, Debug Only)
3. **Ad Unit ID Script** (Document End)
4. **Custom Targeting Script** (Document End)

**Debug Panel Injection**:

```swift
let debuggingPanel = """
(function() {
    var debugInfo = document.createElement('div');
    debugInfo.id = 'debugInfo';
    debugInfo.className = 'debug-info';

    var adUnitDiv = document.createElement('div');
    adUnitDiv.id = 'adUnitInfo';
    adUnitDiv.textContent = 'Ad unit: ' + (window.stepnetwork && window.stepnetwork.adUnitId ? window.stepnetwork.adUnitId : '(not set)');
    debugInfo.appendChild(adUnitDiv);

    var adSizeDiv = document.createElement('div');
    adSizeDiv.id = 'adSizeInfo';
    adSizeDiv.textContent = 'Size: (not sent)';
    debugInfo.appendChild(adSizeDiv);

    var googleButton = document.createElement('div');
    googleButton.id = 'GoogleButton';
    var button = document.createElement('a');
    button.href = '#';
    button.textContent = 'Console';
    button.addEventListener('click', function(event) {
        event.preventDefault();
        if (window.googletag && typeof googletag.openConsole === 'function') {
            googletag.openConsole();
        }
    });
    googleButton.appendChild(button);
    debugInfo.appendChild(googleButton);
    document.body.appendChild(debugInfo);
})();
"""
```

## State Management

### Publisher Pattern

**Ad State Publishing**:

```swift
func adStatesPublisher(for adId: String) -> AnyPublisher<AdLoadState, Never> {
    $adStates
        .compactMap { $0[adId] }
        .eraseToAnyPublisher()
}
```

**WebAdView State Observation**:

```swift
.onReceive(adVisibilityManager?.adStatesPublisher(for: adUnitId) ?? .empty()) { newState in
    self.loadState = newState
}
.onChange(of: loadState) { _, newValue in 
    handleLoadStateChange(newValue) 
}
```

### Lazy Loading Observer Setup

**WebAdViewController Integration**:

```swift
func setupLazyLoadingObserver(manager: LazyLoadingManager) {
    lazyLoadingCancellable = manager.adStatesPublisher(for: adUnitId)
        .sink { [weak self] newState in
            guard let self = self else { return }
            
            if newState == .displayed && self.hasLoadedContent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.triggerAdRendering()
                }
            }
        }
}
```

## Performance Optimizations

### Memory Management

1. **Lazy Loading**: Only load ads when approaching viewport
2. **Optional Unloading**: Configurable memory cleanup when ads leave viewport
3. **Throttled Updates**: Limit visibility checks to 15fps
4. **Hysteresis Thresholds**: Different distances for load/unload prevent flickering
5. **Stability Timers**: 2-second delay before unloading prevents thrashing

### Resource Cleanup

```swift
func unloadWebView() {
    webView?.stopLoading()
    webView?.removeFromSuperview()
    webView = nil
}

deinit {
    NotificationCenter.default.removeObserver(self)
    lazyLoadingCancellable?.cancel()
}
```

## Environment System

### Preference Keys

**Frame Tracking**:

```swift
struct AdFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

struct ScrollViewBoundsPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
```

**GeometryReader Integration**:

```swift
.background(
    GeometryReader { geometry in
        Color.clear.preference(
            key: AdFramePreferenceKey.self,
            value: [adUnitId: geometry.frame(in: .global)]
        )
    }
)
```

## Integration Checklist for SDK Development

### Required Components

- [ ] Consent management system (Didomi or equivalent)
- [ ] WKWebView-based ad rendering
- [ ] Lazy loading with configurable thresholds
- [ ] Custom targeting support
- [ ] Debug infrastructure
- [ ] External URL handling
- [ ] JavaScript bridge for size reporting
- [ ] SwiftUI environment integration
- [ ] Performance optimization (throttling, hysteresis)
- [ ] Memory management (optional unloading)

### Key Implementation Patterns

1. **UIViewControllerRepresentable Bridge**: For WKWebView integration
2. **Environment Objects**: For sharing state across SwiftUI hierarchy
3. **Preference Keys**: For geometry data flow from child to parent
4. **Publisher Pattern**: For reactive state management
5. **Combine Framework**: For subscription-based updates
6. **Throttling**: For performance-critical updates
7. **Hysteresis**: For stable state transitions

### Critical Technical Decisions

1. **Consent Gating**: All ad loading must be consent-dependent
2. **Dynamic Sizing**: Automatic resizing with optional constraints
3. **State Management**: Clear separation between UI state and loading state
4. **Performance First**: Lazy loading enabled by default
5. **Debug Friendly**: Comprehensive logging throughout
6. **Privacy Compliant**: No data collection without consent

This architecture provides a robust foundation for creating high-performance, privacy-compliant ad integration SDKs for iOS applications.
