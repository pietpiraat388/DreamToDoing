// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case adventure  // The World Traveler
    case career     // The Boss
    case mindset    // The Main Character
    case finance    // The Money Boss

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .adventure: return "Adventure"
        case .career: return "Career"
        case .mindset: return "Mindset"
        case .finance: return "Finance"
        }
    }

    var iconName: String {
        switch self {
        case .adventure: return "airplane"
        case .career: return "briefcase.fill"
        case .mindset: return "sparkles"
        case .finance: return "dollarsign.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .adventure: return DesignSystem.Colors.oceanBlue
        case .career: return DesignSystem.Colors.terracotta
        case .mindset: return DesignSystem.Colors.sageGreen
        case .finance: return DesignSystem.Colors.goldAmber
        }
    }
}
