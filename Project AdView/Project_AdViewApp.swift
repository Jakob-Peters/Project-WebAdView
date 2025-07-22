//
//  Project_AdViewApp.swift
//  Project AdView
//
//  Created by Jakob Svanborg Peters on 21/07/2025.
//

import SwiftUI
import Didomi

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let parameters = DidomiInitializeParameters(
            apiKey: "d0661bea-d696-4069-b308-11057215c4c4",
            disableDidomiRemoteConfig: false
        )
        Didomi.shared.initialize(parameters)

        Didomi.shared.onReady {
            print("[SN] Didomi SDK is ready")
            // Only initialize other SDKs here!
            // e.g. WebAdView.shared.initialize()
            // e.g. AdSDK.shared.start()
        }
        return true
    }
}

@main
struct Project_AdViewApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            HomepageView()
        }
    }
}
