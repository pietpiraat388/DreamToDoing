// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

enum DesignSystem {

    // MARK: - Colors
    enum Colors {
        // Backgrounds
        static let background = Color(red: 0.98, green: 0.97, blue: 0.94)
        static let cardBackground = Color.white

        // Accents
        static let terracotta = Color(red: 0.89, green: 0.55, blue: 0.44)
        static let sageGreen = Color(red: 0.56, green: 0.67, blue: 0.56)
        static let oceanBlue = Color(red: 0.45, green: 0.62, blue: 0.72)
        static let goldAmber = Color(red: 0.83, green: 0.65, blue: 0.46)

        // Text
        static let primaryText = Color(red: 0.15, green: 0.15, blue: 0.15)
        static let secondaryText = Color(red: 0.45, green: 0.45, blue: 0.45)

        // States
        static let success = Color(red: 0.56, green: 0.67, blue: 0.56)
        static let skip = Color(red: 0.75, green: 0.75, blue: 0.75)
    }

    // MARK: - Typography
    enum Typography {
        static func header(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .serif)
        }

        static func body(_ size: CGFloat) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }

        static func bodyMedium(_ size: CGFloat) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        static func bodySemibold(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Card Styling
    enum Card {
        static let cornerRadius: CGFloat = 24
        static let shadowRadius: CGFloat = 20
        static let shadowOpacity: CGFloat = 0.08
        static let shadowY: CGFloat = 10
    }

    // MARK: - Animation
    enum Animation {
        static let cardSwipe: SwiftUI.Animation = .spring(response: 0.4, dampingFraction: 0.7)
        static let bounce: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.6)
        static let smooth: SwiftUI.Animation = .easeInOut(duration: 0.3)
    }
}
