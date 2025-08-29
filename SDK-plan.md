# SDK Plan

This document divides the project functionality into (A) Core Modules – mandatory for an initial SDK release, and (B) Extension / Quality Modules – differentiators that add value and competitiveness.

## A. Core Modules

| # | Module | Short Description | Why Needed |
|---|--------|-------------------|------------|
| 1 | Consent → WebAdView | Collects and validates Didomi consent and injects Didomi JS into every WebAdView before ad load. | Legal (GDPR/CCPA) and correct signal to ad stack. No ads before valid consent. |
| 2 | WebAdView Rendering | SwiftUI wrapper + UIViewController (WKWebView) that loads the STEP Network ad template and sets adUnitId. Dynamic container management. | Core ad engine; without it no revenue. |
| 3 | Basic Native ⇄ JS Communication | WKScriptMessageHandler + injected JS for: console bridge, ad size events, adUnitId and custom targeting JS generation. | Enables native → web parameter passing (ad unit, targeting) and web → native events (size, logs). Foundation for everything else. |
| 4 | Memory / Lifecycle Management | Controlled creation / deallocation of WKWebView via SwiftUI lifecycle + manual unload in `dismantle` + optional `.unloaded` state. | Prevents memory creep & CPU overhead with many ads / long articles. |
| 5 | Misc Compliance & UX (Ad label, external clicks, media config) | Ad label API, internal scroll blocking, external URL opening in Safari, inline media playback, autoplay configuration. | Legal compliance (ad disclosure), correct click behavior, improved video performance. |

## B. Extension / Quality Modules

| # | Module | Short Description | Value Add |
|---|--------|-------------------|----------|
| 6 | Advanced Dynamic Resizing (Native driven) | Receives adSize events from WebView and animates container (0.2s). | Better layout stability; enables remote wrapper-driven adjustments of normally locked UI. |
| 7 | Two-Tier Lazy Loading | Threshold-based `fetch` and `display` + optional `unload` with hysteresis + throttle (15fps). | Performance, lower memory, better initial TTI, realistic impression flow. |
| 8 | Accurate Viewability Measurement | Native calculates visible percentage; sends to JS which dynamically resizes / masks DOM. | Real viewability data. |
| 9 | Debugging Infrastructure | Global toggle, bridged JS console, overlay panel (ad unit, size, GPT console), targeted log prefixing. | Faster troubleshooting, transparent integrator experience. |
|10 | Extended Targeting & Param Validation | Single + array targeting injection (future: validation) | Prepares advanced campaign setups (Audience, Context). |
|11 | Batch Event Channel (Multi-ad sync) | Aggregates multiple ad state / viewability updates into one JS call per frame. | Reduces JS bridge overhead & CPU with many ads. |

## Technical Cross-Dependencies
- Viewability (8) depends on Basic Communication (3) + Lazy Loading (7) for timing.
- Batch Event Channel (11) depends on published ad states (7) and JS bridge (3).

## API Consistency / Naming Recommendations
- Use prefixes (e.g. `sn_`) for internal targeting keys next iteration.
- Consider introducing a `WebAdViewConfiguration` struct to reduce initializer parameter count.
- Expose `LazyLoadingConfig` as a value type for future adaptive tuning.

### Core Module Details

#### 1. Consent → WebAdView
- Code: `Project_AdViewApp.swift` + `WebAdViewController.checkConsentAndLoad()`
- Pattern: Consumes Didomi events (NotificationCenter + onReady). Only loads ads when `!isUserStatusPartial()`.
- Injection: Didomi JS as `WKUserScript(atDocumentStart)` ensuring correct consent context before ad scripts execute.

#### 2. WebAdView Rendering
- Code: `WebAdView.swift` (SwiftUI layer) + `WebAdViewController` (UIKit / WKWebView).
- Features: Initial placeholder size, dynamic resizing, targeting injection, optional debug panel, manual trigger of rendering when lazy state == displayed.
- Extensibility: Container constraints (initial/min/max) only affect UI – not actual creative dimensions (remote via STEP / Yield Manager).

#### 3. Basic Native ⇄ JS Communication
- Incoming (JS → Native): `console`, `adSize` via `nativeBridge` handler.
- Outgoing (Native → JS): adUnitId injection, targeting (`googletag.pubads().setTargeting`), manual dispatch script, Didomi JS.
- Foundation for later advanced viewability and event bus.

#### 4. Memory / Lifecycle Management
- States: `notLoaded → fetched → displayed → unloaded` (via `LazyLoadingManager`, unload optional for UX).
- Destruction: `dismantleUIViewController` calls `unloadWebView()` and clears references.
- Benefit: Prevents accumulation of WebKit processes & GPU memory.

#### 5. Misc Compliance & UX
- Ad label: `.showAdLabel()` API.
- External links: Popup (`target="_blank"`), cross-domain and non-http(s) schemes opened externally.
- Media: `allowsInlineMediaPlayback = true`, autoplay permitted (`mediaTypesRequiringUserActionForPlayback = []`).
- Scroll lock: `webView.scrollView.isScrollEnabled = false` to avoid nested scroll conflicts and viewability artifacts.

### Extension Module Details

#### 6. Advanced Dynamic Resizing
- Current: JS sends final width/height → native clamps → animates container.
- Next: Progressive height expansion (placeholder skeleton) + minimal jump heuristic.

#### 7. Two-Tier Lazy Loading
- Fetch zone (800pt), display zone (200pt), unload zone (1600pt) + stability timer (2s) against flicker.
- Throttle at 67ms (≈15fps) balances responsiveness and CPU.

#### 8. Accurate Viewability Measurement
- Plan: Compute intersection between ad frame and viewport in native coordinates → convert to percentage → send via JS → apply CSS clipping/overlay.
- Benefit: Avoids false 100% viewability from isolated iframe/DOM context.

#### 9. Debugging Infrastructure
- Overlay: Ad unit id, size, GPT console shortcut.
- Console bridge: Normalizes console.* output (strips styles/format codes).
- Selective activation via UserDefaults flag.

#### 10. Extended Targeting
- Future: Validation layer, namespacing (e.g. `sn_`), dimension collision detection.

#### 11. Batch Event Channel
- Buffer pending updates → flush on throttle tick.
- Reduces IPC overhead (WK bridging) with >10 ads.
