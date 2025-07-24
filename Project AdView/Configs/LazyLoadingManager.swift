import Foundation
import SwiftUI
import Combine

// MARK: - Debug Helper for LazyLoadingManager
private func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let isDebugEnabled = UserDefaults.standard.bool(forKey: "isDebugEnabled")
    if isDebugEnabled {
        print(items, separator: separator, terminator: terminator)
    }
}

class LazyLoadingManager: ObservableObject {
    @Published var adStates: [String: AdLoadState] = [:] // Stores current state for each adUnitId
    var adUnitFrames: [String: CGRect] = [:] // Frames reported by WebAdViews - made internal
    var scrollViewBounds: CGRect = .zero // Visible bounds of the ScrollView - made internal
    
    // Thresholds for lazy loading (can be configured via modifier)
    // This is a fixed value in iOS "points" (not pixels or % of screen).
    // On most devices, 800pt is roughly 1.0–1.2x the screen height. (Retina is around 1600pt.)
    var fetchThreshold: CGFloat = 800
    var displayThreshold: CGFloat = 200
    var unloadThreshold: CGFloat = 1600 // Increased for hysteresis to prevent flickering

    // Throttling mechanism instead of debouncing
    private var throttleTimer: AnyCancellable?
    private var lastUpdateTime: Date = Date.distantPast
    private let throttleInterval: TimeInterval = 0.067 // ~15fps (67ms)
    
    // Stability timer to prevent rapid unloading (Option B)
    private var unloadCandidates: [String: Date] = [:] // Track when ads became unload candidates
    private let unloadStabilityDelay: TimeInterval = 2.0 // 2 seconds delay before unloading

    func updateAdFrame(_ adId: String, frame: CGRect) {
        if adUnitFrames[adId] != frame { // Only update if frame actually changed
            adUnitFrames[adId] = frame
            triggerVisibilityCheck()
        }
    }

    func updateScrollViewBounds(_ bounds: CGRect) {
        if scrollViewBounds != bounds { // Only update if bounds actually changed
            scrollViewBounds = bounds
            triggerVisibilityCheck()
        }
    }

    // Provides a Publisher for a specific ad unit's state
    func adStatesPublisher(for adId: String) -> AnyPublisher<AdLoadState, Never> {
        $adStates
            .compactMap { $0[adId] } // Get the state for this specific adId
            .eraseToAnyPublisher()
    }

    // Throttled visibility check to ensure updates during scrolling at controlled frequency
    private func triggerVisibilityCheck() {
        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(lastUpdateTime)
        
        if timeSinceLastUpdate >= throttleInterval {
            // Enough time has passed, execute immediately
            lastUpdateTime = now
            checkAdVisibility()
        } else {
            // Too soon, schedule for later if not already scheduled
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

    private func checkAdVisibility() {
        guard !scrollViewBounds.isEmpty else {
            debugPrint("[SN] [LLM] checkAdVisibility: scrollViewBounds is empty. Skipping.")
            return
        }

        let fetchZone = scrollViewBounds.insetBy(dx: 0, dy: -fetchThreshold)
        let displayZone = scrollViewBounds.insetBy(dx: 0, dy: -displayThreshold)
        let unloadZone = scrollViewBounds.insetBy(dx: 0, dy: -unloadThreshold)
        let now = Date()

        for (adId, adFrame) in adUnitFrames {
            let currentLoadState = adStates[adId] ?? .notLoaded
            var newState: AdLoadState? = nil

            // State Transition Logic
            if currentLoadState == .notLoaded && adFrame.intersects(fetchZone) {
                newState = .fetched
                // Clear any unload candidate status when fetching
                unloadCandidates.removeValue(forKey: adId)
            } else if currentLoadState == .fetched && adFrame.intersects(displayZone) && adFrame.intersects(scrollViewBounds) {
                newState = .displayed
                // Clear any unload candidate status when displaying
                unloadCandidates.removeValue(forKey: adId)
            } else if (currentLoadState == .fetched || currentLoadState == .displayed) && !adFrame.intersects(unloadZone) {
                // Option B: Stability Timer - Check if ad should be marked for unloading
                if unloadCandidates[adId] == nil {
                    // First time this ad is out of unload zone, mark as candidate
                    unloadCandidates[adId] = now
                    debugPrint("[SN] [LLM] Ad \(adId) marked as unload candidate")
                } else if let candidateTime = unloadCandidates[adId], 
                         now.timeIntervalSince(candidateTime) >= unloadStabilityDelay {
                    // Ad has been out of zone long enough, proceed with unloading
                    newState = .unloaded
                    unloadCandidates.removeValue(forKey: adId)
                }
                // If not enough time has passed, don't change state yet
            } else if currentLoadState == .unloaded && adFrame.intersects(fetchZone) {
                newState = .notLoaded // Reset to notLoaded to trigger recreation/re-fetch
                unloadCandidates.removeValue(forKey: adId)
            } else {
                // Ad is back in a safe zone, clear unload candidate status
                unloadCandidates.removeValue(forKey: adId)
            }

            if let newState = newState, newState != currentLoadState {
                debugPrint("[SN] [LLM] Ad \(adId) TRANSITION: \(currentLoadState.rawValue) -> \(newState.rawValue)")
                adStates[adId] = newState // Update the published state
            }
        }
    }
}
