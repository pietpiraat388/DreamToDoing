// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import Foundation

@Observable
@MainActor
final class SubscriptionManager {

    var isPremium: Bool = false

    let dailyFreeLimit = 3

    func unlockPremium() {
        isPremium = true
    }

    func restorePurchases() async {
        // Stub: In real implementation, this restores purchases via StoreKit 2
    }
}
