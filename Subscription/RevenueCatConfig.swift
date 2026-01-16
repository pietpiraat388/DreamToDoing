//
//  RevenueCatConfig.swift
//  StampIdentifier
//
//  Configuration file for RevenueCat settings
//  Change these values for different projects
//

import Foundation

// MARK: - RevenueCat Configuration
struct RevenueCatConfig {
  
  // MARK: - API & App Settings
  static let apiKey = "appl_fLWKewgGGRvuLDEGAJobdmuVEJH"
  static let entitlement = "pro_access"
  static let offering = "birthday_app_premium"
  
  // MARK: - UserDefaults Keys
  static let subscriptionStatusKey = "hasActiveSubscription"
  
  // MARK: - Notification Names
  static let subscriptionChangedNotification = "SubscriptionStatusChanged"
  static let purchaseSuccessNotification = "PurchaseSuccess"
  
  // MARK: - Debug Settings
  #if DEBUG
  static let enableDebugLogs = true
  #else
  static let enableDebugLogs = false
  #endif
} 
