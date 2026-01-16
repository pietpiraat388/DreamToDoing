// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import Foundation
import Combine

@Observable
@MainActor
final class SubscriptionManager {

    var isPremium: Bool = false

    let dailyFreeLimit = 3

    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Sync with RevenueCat on init
        syncWithRevenueCat()

        // Listen for purchase success notification
        NotificationCenter.default.publisher(for: NSNotification.Name(RevenueCatConfig.purchaseSuccessNotification))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.syncWithRevenueCat()
                }
            }
            .store(in: &cancellables)
    }

    private func syncWithRevenueCat() {
        isPremium = RevenueCatService.shared.hasActiveSubscription
    }

    func unlockPremium() {
        isPremium = true
    }

    func restorePurchases() async {
        do {
            try await RevenueCatService.shared.restorePurchases()
            syncWithRevenueCat()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
}
