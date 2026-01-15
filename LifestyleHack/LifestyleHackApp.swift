// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

//
//  LifestyleHackApp.swift
//  LifestyleHack
//
//  Created by Patrick van der Ploeg on 15/01/2026.
//

import SwiftUI

@main
struct LifestyleHackApp: App {

    @State private var contentManager = ContentManager()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var showSplash = true

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
