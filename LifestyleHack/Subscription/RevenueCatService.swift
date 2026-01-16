//
//  RevenueCatService.swift - Simplified volgens RevenueCat docs
//  StampIdentifier
//

import Foundation
import Combine
import RevenueCat

class RevenueCatService: NSObject, ObservableObject {
    static let shared = RevenueCatService()
    
    // Published properties
    @Published var customerInfo: CustomerInfo?
    @Published var currentOffering: Offering?
    @Published var hasActiveSubscription = false
    
    private override init() {
        super.init()
    }
    
    // MARK: - Initial Setup (called after early configuration)
    @MainActor
    func performInitialSetup() async {
        await checkSubscriptionStatus()
        await loadOfferings()
        
        // Update UI
        objectWillChange.send()
    }
    
    // MARK: - Subscription Status
    @MainActor
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            self.customerInfo = customerInfo
            
            let hasActiveEntitlement = customerInfo.entitlements[RevenueCatConfig.entitlement]?.isActive == true
            self.hasActiveSubscription = hasActiveEntitlement
            
            // Update UserDefaults
            UserDefaults.standard.set(hasActiveEntitlement, forKey: RevenueCatConfig.subscriptionStatusKey)
            
            print("🔒 Subscription status: \(hasActiveEntitlement ? "Active" : "Inactive")")
            
            if let entitlement = customerInfo.entitlements[RevenueCatConfig.entitlement] {
                print("📅 Subscription expires: \(entitlement.expirationDate?.description ?? "Never")")
            }
            
        } catch {
            print("❌ Failed to check subscription status: \(error)")
            // Fallback to UserDefaults
            hasActiveSubscription = UserDefaults.standard.bool(forKey: RevenueCatConfig.subscriptionStatusKey)
        }
    }
    
    // MARK: - Offerings
    @MainActor
    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            
            // Try specific offering first, then current
            if let targetOffering = offerings.offering(identifier: RevenueCatConfig.offering) {
                currentOffering = targetOffering
                print("✅ Loaded offering: \(RevenueCatConfig.offering)")
            } else if let currentOffering = offerings.current {
                self.currentOffering = currentOffering
                print("✅ Loaded current offering: \(currentOffering.identifier)")
            } else {
                print("⚠️ No offerings available")
            }
            
        } catch {
            print("❌ Failed to load offerings: \(error)")
            // Retry after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                Task { await self.loadOfferings() }
            }
        }
    }
    
    // MARK: - Purchase Flow (simplified)
    func purchaseProduct(_ package: Package) async throws -> CustomerInfo {
        let result = try await Purchases.shared.purchase(package: package)
        
        await MainActor.run {
            self.customerInfo = result.customerInfo
            let hasActive = result.customerInfo.entitlements[RevenueCatConfig.entitlement]?.isActive == true
            self.hasActiveSubscription = hasActive
            
            // Update UserDefaults and notify
            UserDefaults.standard.set(hasActive, forKey: RevenueCatConfig.subscriptionStatusKey)
            NotificationCenter.default.post(
                name: NSNotification.Name(RevenueCatConfig.subscriptionChangedNotification),
                object: nil,
                userInfo: ["status": hasActive]
            )

            print("💰 Purchase completed - Active: \(hasActive)")
        }
        
        return result.customerInfo
    }
    
    // MARK: - Restore Purchases (simplified)
    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        
        await MainActor.run {
            self.customerInfo = customerInfo
            let hasActive = customerInfo.entitlements[RevenueCatConfig.entitlement]?.isActive == true
            self.hasActiveSubscription = hasActive
            
            // Update UserDefaults and notify
            UserDefaults.standard.set(hasActive, forKey: RevenueCatConfig.subscriptionStatusKey)
            NotificationCenter.default.post(
                name: NSNotification.Name(RevenueCatConfig.subscriptionChangedNotification),
                object: nil,
                userInfo: ["status": hasActive]
            )
            
            print("🔄 Restore completed - Active: \(hasActive)")
        }
    }
}

// MARK: - PurchasesDelegate (volgens docs)
extension RevenueCatService: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        DispatchQueue.main.async {
            self.customerInfo = customerInfo
            let hasActive = customerInfo.entitlements[RevenueCatConfig.entitlement]?.isActive == true
            
            let previousStatus = self.hasActiveSubscription
            self.hasActiveSubscription = hasActive
            
            // Update UserDefaults
            UserDefaults.standard.set(hasActive, forKey: RevenueCatConfig.subscriptionStatusKey)
            
            // Only notify on changes
            if previousStatus != hasActive {
                NotificationCenter.default.post(
                    name: NSNotification.Name(RevenueCatConfig.subscriptionChangedNotification),
                    object: nil,
                    userInfo: ["status": hasActive]
                )
                
                print("🔄 Subscription status changed: \(previousStatus) → \(hasActive)")
                
                // Note: Review request is handled in purchase() method, not here to avoid duplicates
            }
        }
    }
}
