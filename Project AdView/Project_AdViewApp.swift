//
//  Project_AdViewApp.swift
//  Project AdView
//
//  Created by Jakob Svanborg Peters on 21/07/2025.
//

import SwiftUI
import Didomi

// MARK: - Debug Helper
private func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    // Check UserDefaults directly for debug setting
    let isDebugEnabled = UserDefaults.standard.bool(forKey: "isDebugEnabled")
    if isDebugEnabled {
        print(items, separator: separator, terminator: terminator)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Enable debug mode for development
        #if DEBUG
        UserDefaults.standard.set(true, forKey: "isDebugEnabled")
        #endif
        
        debugPrint("[SN] [NATIVE] App is launching - Debug mode enabled!")
        
        let parameters = DidomiInitializeParameters(
            apiKey: "d0661bea-d696-4069-b308-11057215c4c4",
            disableDidomiRemoteConfig: false
        )
        Didomi.shared.initialize(parameters)

        Didomi.shared.onReady {
            debugPrint("[SN] [NATIVE] Didomi SDK is ready")
            debugPrint("[SN] [NATIVE] DEBUG: Debug logging is working!")
            
            // Set up global consent change listener
            let didomiEventListener = EventListener()
            
            didomiEventListener.onConsentChanged = { event in
                debugPrint("[SN] [NATIVE] Consent event received")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("DidomiConsentChanged"), object: nil)
                }
            }
            
            Didomi.shared.addEventListener(listener: didomiEventListener)
        }
        return true
    }
}

@main
struct Project_AdViewApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var debugSettings = DebugSettings()
    var body: some Scene {
        WindowGroup {
            HomepageView()
                .environmentObject(debugSettings)
        }
    }
}
