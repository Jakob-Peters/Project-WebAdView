# SDK-plan

Dette dokument opdeler projektets funktionalitet i (A) Kerne moduler – absolut nødvendige for en første SDK-release, og (B) Udvidelses / kvalitetsmoduler – stærke differentieringspunkter der øger værdi og konkurrenceevne.

## A. Kerne Moduler

| Nr | Modul | Kort Beskrivelse | Hvorfor nødvendigt |
|----|-------|------------------|--------------------|
| 1 | Consent → WebAdView | Indsamler og validerer Didomi consent og injicerer Didomi JS i hvert WebAdView før annonceload. | Lovkrav (GDPR/CCPA) og korrekt signal til ad stack. Ingen annoncer før gyldigt samtykke. |
| 2 | WebAdView Rendering | SwiftUI wrapper + UIViewController (WKWebView) der loader STEP Network ad template og sætter adUnitId. Dynamisk containerstyring. | Selve annoncemotoren; uden dette ingen revenue. |
| 3 | Basis Native ⇄ JS Kommunikation | WKScriptMessageHandler + injiceret JS til: console bridge, ad size events, adUnitId og custom targeting JS generation. | Muliggør at native kan sende parametre (ad unit, targeting) og modtage events (størrelse, logs). Fundament for alt videre. |
| 4 | Memory / Lifecycle Management | Kontrolleret creation / deallocation af WKWebView via SwiftUI livscyklus + manuel unload i `dismantle` + optional state .unloaded. | Forebygger memory creep og CPU belastning ved mange annoncer / lange artikler. |
| 5 | Misc Compliance & UX (Ad label, eksterne klik, media config) | Ad label API, blokering af intern scrolling, ekstern URL åbning i Safari, inline media playback, autoplay konfiguration. | Juridisk (annoncemarkering), korrekt klikadfærd og bedre videoafspilning. |


## B. Udvidelses / Kvalitetsmoduler

| Nr | Modul | Kort Beskrivelse | Værditilførsel |
|----|-------|------------------|----------------|
| 6 | Avanceret Dynamisk Resizing (Native styret) | Modtager adSize events fra WebView og animerer container (0.2s). | Bedre layout stabilitet, muliggøre remote updates fra wrapper på normaltvis låste UX / UI ting. |
| 7 | Two-Tier Lazy Loading | Threshold-baseret `fetch` og `display` + optional `unload` med hysterese + throttle (15fps). | Performance, lavere memory, bedre initial TTI, realistisk impressions flow. |
| 8 | Korrekt Viewability Measurement | Native beregner procent synlig; sender til JS der dynamisk resizer DOM. | Ægte viewability data |
| 9 | Debugging Infrastruktur | Global toggle, bridged JS console, overlay panel (ad unit, size, GPT console), targeted log prefixing. | Hurtigere fejlretning, transparent integrator experience. |
| 10 | Udvidet Targeting & Param Validation | Single + array targeting injektion | Forbereder avancerede kampagne setups (Audience, Context). |
| 11 | Batch Event Channel (Multi-ad sync) | Samler flere ad state / viewability updates i én JS call pr. frame. | Reducerer JS bridge overhead og CPU ved mange annoncer. |




## Tekniske Krydsafhængigheder
- Viewability (8) kræver Basis Kommunikation (3) + Lazy Loading (7) til timing.
- Batch Event Channel (11) afhænger af at ad states allerede publiseres (7) og JS bridge (3).


## API Konsistens / Naming Anbefalinger
- Brug præfikser (fx `sn_`) til interne targeting keys i næste iteration.
- Overvej `WebAdViewConfiguration` struct til at reducere parameterliste i init.
- Eksponer `LazyLoadingConfig` som value type for fremtidig adaptiv tuning.



### Detaljer pr. Kerne Modul

#### 1. Consent → WebAdView
- Kode: `Project_AdViewApp.swift` + `WebAdViewController.checkConsentAndLoad()`
- Mønster: Konsumerer Didomi events (NotificationCenter + onReady). Loader først annoncer når `!isUserStatusPartial()`.
- Injektion: Didomi JS som `WKUserScript(atDocumentStart)` for at sikre korrekt consent kontekst før ad scripts eksekveres.

#### 2. WebAdView Rendering
- Kode: `WebAdView.swift` (SwiftUI lag) + `WebAdViewController` (UIKit / WKWebView).
- Funktioner: Initial placeholder size, dynamisk resizing, targeting injektion, debug panel (valgfrit), manuelt trigger af rendering ved lazy state = displayed.
- Extensibility: Container constraints (initial/min/max) påvirker kun UI – ikke faktisk creative dimensioner (styres af STEP / Yield Manager).

#### 3. Basis Native ⇄ JS Kommunikation
- Indgående (JS → Native): `console`, `adSize` via `nativeBridge` handler.
- Udgående (Native → JS): adUnitId injection, targeting (`googletag.pubads().setTargeting`), manual dispatch script, Didomi JS.
- Grundlag for senere avanceret viewability og event-bus.

#### 4. Memory / Lifecycle Management
- States: `notLoaded → fetched → displayed → unloaded` (via `LazyLoadingManager` selv om unload pt. er optional).
- Destruction: `dismantleUIViewController` kalder `unloadWebView()` og fjerner referencer.
- Fordel: Hindrer ophobning af WebKit processer og GPU ram.

#### 5. Misc Compliance & UX
- Ad label: `.showAdLabel()` API.
- Eksterne links: Popup (`target="_blank"`), domæneskift og ikke-http(s) skema åbnes i system browser.
- Media: `allowsInlineMediaPlayback = true`, autoplay tilladt (`mediaTypesRequiringUserActionForPlayback = []`).
- Scroll lock: `webView.scrollView.isScrollEnabled = false` for at undgå nested scroll konflikter og viewability artefakter.



### Detaljer pr. Udvidelsesmodul

#### 6. Avanceret Dynamisk Resizing
- Nu: JS sender endelig width/height → native clamps → animere container.
- Næste step: Progressive height expansion (placeholder skeleton) + min jump heuristic.

#### 7. Two-Tier Lazy Loading
- Fetch zone (800pt), display zone (200pt), unload zone (1600pt) + stability timer (2s) mod flicker.
- Throttle på 67ms (≈15fps) balancerer respons og CPU.

#### 8. Korrekt Viewability Measurement
- Plan: Beregn intersektion mellem ad frame og viewport i native koordinater → konverter til procent → send via JS → anvend CSS clipping/overlay.
- Fordel: Undgår falsk 100% viewability fra isoleret iframe/DOM kontekst.

#### 9. Debugging Infrastruktur
- Overlay: Ad unit id, size, GPT console shortcut.
- Konsol bro: Normaliserer console.* output uden farvekoder og stilargumenter.
- Selektiv aktivering via UserDefaults flag.

#### 10. Udvidet Targeting
- Fremtid: Validation layer, namespacing (fx `sn_`), dimension collision detection.

#### 11. Batch Event Channel
- Saml pending opdateringer i buffer → flush på throttle tick.
- Mindsker IPC overhead (WK bridging) ved >10 annoncer.
