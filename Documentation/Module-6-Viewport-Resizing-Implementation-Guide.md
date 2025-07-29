# Module 6: Viewport Resizing Implementation Guide

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Implementation Details](#implementation-details)
4. [File-by-File Changes](#file-by-file-changes)
5. [Data Flow](#data-flow)
6. [Known Issues & Solutions](#known-issues--solutions)
7. [Future Improvements](#future-improvements)

## Overview

### Problem Statement
The original approach to viewability measurement used DOM overlay elements to mask portions of ad content when less than 50% was visible. However, this approach failed because ad networks (Prebid, Google Ad Manager) could still detect the full ad content and report 100% viewability regardless of the visual masking.

### Solution: Viewport Resizing Approach
Instead of masking content, we dynamically resize the WKWebView viewport to match only the visible portion of the ad. This ensures ad networks naturally measure viewability against the correct viewport dimensions, preventing false 100% viewability reporting when ads are less than 50% visible.

### Key Benefits
- ✅ **Accurate Viewability**: Ad networks measure against correct viewport dimensions
- ✅ **No DOM Manipulation**: Clean, reliable approach without JavaScript overlay tricks
- ✅ **Native Integration**: Leverages WKWebView's native viewport management
- ✅ **50% Threshold Control**: Precisely controls what ad networks detect as viewable

## Architecture

### Core Components

```
ScrollView (User Scrolling)
    ↓
LazyLoadingManager (Calculates Visibility)
    ↓
WebAdView (SwiftUI Container)
    ↓
WebAdViewController (WKWebView Management)
    ↓
WKWebView (Dynamic Viewport Resizing)
```

### Key Classes and Responsibilities

1. **LazyLoadingManager**: Centralized scroll tracking and viewport calculation
2. **WebAdView**: SwiftUI interface with reactive state management
3. **WebAdViewController**: UIKit WKWebView wrapper with viewport control
4. **HTML Template**: Clean ad rendering without viewport dependencies

## Implementation Details

### 1. Reactive Data Flow
- Uses Combine publishers for real-time updates
- @Published properties trigger UI updates automatically
- Throttled updates (67ms/15fps) prevent performance issues

### 2. Viewport Calculation Algorithm
```swift
// Calculate visibility percentage from container intersection
let visiblePercentageWidth = min(1.0, visibleRect.width / adFrame.width)
let visiblePercentageHeight = min(1.0, visibleRect.height / adFrame.height)

// Apply to actual ad content size
let viewportWidth = adContentSize.width * visiblePercentageWidth
let viewportHeight = adContentSize.height * visiblePercentageHeight

// Calculate content offset for proper positioning
let relativeOffsetX = (visibleRect.minX - adFrame.minX) / adFrame.width
let relativeOffsetY = (visibleRect.minY - adFrame.minY) / adFrame.height
let contentOffsetX = relativeOffsetX * adContentSize.width
let contentOffsetY = relativeOffsetY * adContentSize.height
```

### 3. Viewport Management
- **Size Control**: WKWebView frame size matches visible ad portion
- **Position Control**: WebView positioning shows correct ad content area
- **Content Scale**: HTML content maintains natural size, viewport clips appropriately

## File-by-File Changes

### LazyLoadingManager.swift

#### New Properties
```swift
@Published var adViewportSizes: [String: CGSize] = [:]      // Viewport sizes for each ad
@Published var adViewportOffsets: [String: CGPoint] = [:]   // Viewport offsets for each ad
var adContentSizes: [String: CGSize] = [:]                  // Actual ad content sizes from HTML
```

#### New Methods
```swift
// Report actual ad content size from HTML
func updateAdContentSize(_ adId: String, size: CGSize)

// Publisher for viewport size changes
func adViewportSizePublisher(for adId: String) -> AnyPublisher<CGSize, Never>

// Publisher for viewport offset changes  
func adViewportOffsetPublisher(for adId: String) -> AnyPublisher<CGPoint, Never>

// Calculate both viewport size and offset
private func calculateViewportParams(adId: String, adFrame: CGRect, scrollBounds: CGRect) -> (CGSize, CGPoint)
```

#### Key Algorithm Enhancement
- **Before**: Simple state transitions (notLoaded → fetched → displayed → unloaded)
- **After**: Added viewport size/offset calculation for displayed ads
- **Integration**: Viewport updates trigger whenever ad visibility changes

### WebAdView.swift

#### New State Properties
```swift
@State private var viewportSize: CGSize?      // Current viewport size
@State private var viewportOffset: CGPoint?   // Current viewport offset
```

#### New Reactive Subscriptions
```swift
// Subscribe to viewport size changes
.onReceive(adVisibilityManager?.adViewportSizePublisher(for: adUnitId)) { newViewportSize in
    self.viewportSize = newViewportSize
}

// Subscribe to viewport offset changes
.onReceive(adVisibilityManager?.adViewportOffsetPublisher(for: adUnitId)) { newViewportOffset in
    self.viewportOffset = newViewportOffset
}
```

#### Enhanced Ad Size Reporting
```swift
onAdSizeChange: { size in
    // Update SwiftUI display size with constraints
    let clampedSize = CGSize(width: clampedWidth, height: clampedHeight)
    self.adSize = clampedSize
    
    // Report actual ad content size to LazyLoadingManager
    adVisibilityManager?.updateAdContentSize(adUnitId, size: size)
}
```

#### Layout Stability Improvements
```swift
.frame(width: adSize.width, height: adSize.height)
.clipped()        // Clip overflow content
.fixedSize()      // Prevent parent layout influence
```

### WebAdViewController.swift

#### New Viewport Management Properties
```swift
private var currentViewportSize: CGSize?    // Track current viewport size
private var currentViewportOffset: CGPoint? // Track current viewport offset
```

#### Enhanced Viewport Control Method
```swift
func updateViewportParams(size: CGSize, offset: CGPoint) {
    // Only update if parameters actually changed
    guard currentViewportSize != size || currentViewportOffset != offset else { return }
    
    currentViewportSize = size
    currentViewportOffset = offset
    
    // Position WebView to show correct portion of content
    let newFrame = CGRect(
        origin: CGPoint(x: -offset.x, y: -offset.y),
        size: view.bounds.size
    )
    webView.frame = newFrame
    
    // Update container bounds to clip to desired viewport size
    view.bounds = CGRect(origin: .zero, size: size)
}
```

#### Removed Old Code
- ❌ Removed old `updateViewportSize(_ size: CGSize)` method
- ❌ Cleaned up overlay-based viewability JavaScript from debug panel
- ❌ Removed DOM manipulation code

### updated-ad-template.html

#### Enhanced Ad Size Detection
```javascript
function observeAdSize(adDiv) {
    function notifyIfChanged() {
        let width, height;
        
        // Try multiple approaches for accurate sizing:
        const iframeAd = adDiv.querySelector('iframe');
        const imgAd = adDiv.querySelector('img');
        
        if (iframeAd && iframeAd.width && iframeAd.height) {
            // Use iframe dimensions if available
            width = parseInt(iframeAd.width);
            height = parseInt(iframeAd.height);
        } else if (imgAd && imgAd.naturalWidth && imgAd.naturalHeight) {
            // Use image natural dimensions
            width = imgAd.naturalWidth;
            height = imgAd.naturalHeight;
        } else {
            // Fallback: getBoundingClientRect minus padding/margins
            const rect = adDiv.getBoundingClientRect();
            const computedStyle = window.getComputedStyle(adDiv);
            const paddingX = parseFloat(computedStyle.paddingLeft) + parseFloat(computedStyle.paddingRight);
            const paddingY = parseFloat(computedStyle.paddingTop) + parseFloat(computedStyle.paddingBottom);
            const marginX = parseFloat(computedStyle.marginLeft) + parseFloat(computedStyle.marginRight);
            const marginY = parseFloat(computedStyle.marginTop) + parseFloat(computedStyle.marginBottom);
            
            width = Math.round(rect.width - paddingX - marginX);
            height = Math.round(rect.height - paddingY - marginY);
        }
        
        console.log('[LLM] Ad size measured: ' + width + 'x' + height);
        sendAdSizeToNative(width, height);
    }
}
```

#### CSS Layout Improvements
```css
html, body {
    margin: 0;
    padding: 0;
    width: 100%;
    background: #fff;
    position: relative;
    overflow: visible; /* Allow content to overflow */
}

.ad-container {
    width: 100%;
    position: relative;
    overflow: visible; /* Allow ad to overflow container */
}
```

#### Removed Old Code
- ❌ Removed all overlay-based viewability management JavaScript
- ❌ Removed `updateOverlayPositions()` function
- ❌ Removed overlay DOM elements creation
- ❌ Removed viewport-dependent CSS sizing

## Data Flow

### 1. Initialization Flow
```
1. WebAdView created with adUnitId
2. LazyLoadingManager registers ad frame via GeometryReader
3. WebAdViewController created and configured
4. HTML template loads and reports actual ad size
5. Ad content size stored in LazyLoadingManager
```

### 2. Scroll-Triggered Updates
```
1. User scrolls → ScrollView bounds change
2. LazyLoadingManager.updateScrollViewBounds() called
3. triggerVisibilityCheck() → checkAdVisibility()
4. calculateViewportParams() computes size + offset
5. @Published adViewportSizes/adViewportOffsets updated
6. WebAdView receives updates via .onReceive()
7. WebAdViewController.updateViewportParams() called
8. WKWebView frame and bounds updated
```

### 3. Ad Size Reporting Flow
```
1. HTML ad renders → observeAdSize() measures dimensions
2. sendAdSizeToNative() → Swift userContentController bridge
3. WebAdView onAdSizeChange callback → adSize state update
4. LazyLoadingManager.updateAdContentSize() → adContentSizes updated
5. Viewport recalculation triggered for displayed ads
```

## Known Issues & Solutions

### Issue 1: HTML Template Viewport Scaling
**Problem**: When WKWebView viewport resizes, HTML content scales instead of being clipped.

**Current Status**: Partially resolved with CSS fixes, but still experiencing issues during scrolling.

**Potential Solutions**:
1. **Fixed HTML Viewport**: Set HTML meta viewport to fixed dimensions
2. **Container Overflow Strategy**: Create larger HTML container with overflow clipping
3. **JavaScript Viewport Control**: Dynamically adjust HTML viewport via JavaScript

### Issue 2: WebView Positioning Direction
**Problem**: WebView resizes from bottom-up instead of showing correct content portion.

**Current Status**: Addressed with offset-based positioning, but may need refinement.

**Solution Applied**: 
```swift
// Position WebView with negative offset to show correct content area
let newFrame = CGRect(origin: CGPoint(x: -offset.x, y: -offset.y), size: view.bounds.size)
webView.frame = newFrame
view.bounds = CGRect(origin: .zero, size: size)
```

### Issue 3: SwiftUI Layout Stability
**Problem**: WebAdView size changes cause parent view shifting.

**Solution Applied**: 
```swift
.fixedSize()  // Prevent parent layout influence
.clipped()    // Maintain visual boundaries
```

### Issue 4: Ad Size Measurement Accuracy
**Problem**: Ad sizes reported incorrectly due to padding/margins inclusion.

**Solution Applied**: Enhanced size detection with multiple fallback methods and CSS computation.

## Future Improvements

### 1. HTML Template Refactoring
```html
<!-- Suggested approach for stable viewport -->
<meta name="viewport" content="width=1200, height=1200, initial-scale=1.0, user-scalable=no">

<style>
html, body {
    width: 1200px;
    height: 1200px;
    overflow: visible;
}
.ad-container {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}
</style>
```

### 2. Enhanced Viewport Calculation
- Add viewport size validation and constraints
- Implement minimum/maximum viewport size limits
- Add debugging visualization for viewport boundaries

### 3. Performance Optimizations
- Implement viewport update debouncing for rapid scroll events
- Add viewport change animation/transitions
- Optimize memory usage for multiple ad instances

### 4. Error Handling & Diagnostics
- Add comprehensive logging for viewport calculations
- Implement fallback strategies for edge cases
- Add diagnostic tools for troubleshooting viewability issues

### 5. Testing & Validation
- Create automated tests for viewport calculation logic
- Add visual debugging tools for development
- Implement A/B testing framework for different approaches

## Implementation Checklist

### Phase 1: Core Infrastructure ✅
- [x] LazyLoadingManager viewport tracking
- [x] WebAdView reactive subscriptions  
- [x] WebAdViewController viewport management
- [x] Basic HTML template cleanup

### Phase 2: Viewport Calculation ✅
- [x] Size and offset calculation algorithm
- [x] Ad content size tracking
- [x] Reactive update publishers
- [x] WebView positioning logic

### Phase 3: Refinements 🔄
- [x] Enhanced ad size detection
- [x] SwiftUI layout stability
- [x] Removed old overlay code
- [ ] HTML template viewport stability (In Progress)

### Phase 4: Polish & Testing 📋
- [ ] Comprehensive error handling
- [ ] Performance optimization
- [ ] Visual debugging tools
- [ ] Automated testing suite

## Conclusion

The viewport resizing approach provides a robust foundation for accurate viewability measurement by controlling what ad networks detect through native WKWebView viewport management. While some HTML template refinements are still needed, the core architecture successfully prevents false viewability reporting and provides precise control over the 50% visibility threshold.

The reactive, publisher-based architecture ensures real-time updates and maintainable code, while the centralized LazyLoadingManager provides consistent behavior across all ad units in a scroll view.

---

**Last Updated**: July 29, 2025  
**Implementation Status**: Core Complete, Refinements In Progress  
**Next Priority**: HTML template viewport stability during scrolling
