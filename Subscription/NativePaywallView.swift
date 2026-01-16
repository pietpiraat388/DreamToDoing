//
//  NativePaywallView.swift
//  Simplified volgens RevenueCat SwiftUI docs
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct NativePaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // Simpel PaywallView volgens docs
        PaywallView()
            .onPurchaseCompleted { customerInfo in
                print("✅ Purchase successful")

                // Update service (will trigger delegate)
                Task {
                    await RevenueCatService.shared.checkSubscriptionStatus()
                }

                // Send notification for UI updates
                NotificationCenter.default.post(
                    name: NSNotification.Name(RevenueCatConfig.purchaseSuccessNotification),
                    object: nil
                )

                dismiss()
            }
            .onPurchaseCancelled {
                print("ℹ️ Purchase cancelled")
                dismiss()
            }
            .onRestoreCompleted { customerInfo in
                print("✅ Restore completed")

                // Check entitlement status
                let hasActiveSubscription = customerInfo.entitlements[RevenueCatConfig.entitlement]?.isActive == true

                // Update service
                Task {
                    await RevenueCatService.shared.checkSubscriptionStatus()
                }

                // Only dismiss if user has active subscription
                if hasActiveSubscription {
                    dismiss()
                }
                // If no active subscription, paywall blijft open
            }
    }
}
