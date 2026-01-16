// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

//
//  LifestyleHackApp.swift
//  LifestyleHack
//
//  Created by Patrick van der Ploeg on 15/01/2026.
//

import SwiftUI
import RevenueCat

@main
struct LifestyleHackApp: App {

    @State private var contentManager = ContentManager()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var showSplash = true

    init() {
        // Configure RevenueCat
        Purchases.logLevel = RevenueCatConfig.enableDebugLogs ? .debug : .info
        Purchases.configure(withAPIKey: RevenueCatConfig.apiKey)
        Purchases.shared.delegate = RevenueCatService.shared

        // Initial subscription check
        Task {
            await RevenueCatService.shared.performInitialSetup()
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                HomeView(
                    contentManager: contentManager,
                    subscriptionManager: subscriptionManager
                )

                if showSplash {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}
