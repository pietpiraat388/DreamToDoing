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

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var contentManager = ContentManager()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var showSplash: Bool

    init() {
        // Show splash only for returning users (who completed onboarding)
        _showSplash = State(initialValue: UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))

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
                if hasSeenOnboarding {
                    HomeView(
                        contentManager: contentManager,
                        subscriptionManager: subscriptionManager
                    )
                } else {
                    OnboardingView()
                }

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
