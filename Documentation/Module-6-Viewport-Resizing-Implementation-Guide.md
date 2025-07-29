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

### updated-ad-template.html
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