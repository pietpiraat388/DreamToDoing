// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct DeckView: View {

    let cards: [ActionCard]
    let currentIndex: Int
    let isPremium: Bool
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void
    let onUnlockTap: () -> Void

    private let visibleCards = 3

    var body: some View {
        ZStack {
            ForEach(visibleCardIndices, id: \.self) { index in
                let offset = index - currentIndex

                CardView(
                    card: cards[index],
                    showPremiumBadge: !isPremium && cards[index].isPremium,
                    isTopCard: offset == 0,
                    onSwipeRight: onSwipeRight,
                    onSwipeLeft: onSwipeLeft,
                    onUnlockTap: onUnlockTap
                )
                .zIndex(Double(visibleCards - offset))
                .offset(y: CGFloat(offset) * 8)
                .scaleEffect(1 - CGFloat(offset) * 0.05)
                .opacity(offset == 0 ? 1 : 0.7)
                .allowsHitTesting(offset == 0)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
    }

    private var visibleCardIndices: [Int] {
        guard !cards.isEmpty else { return [] }
        let start = currentIndex
        let end = min(currentIndex + visibleCards, cards.count)
        guard start < end else { return [] }
        return Array(start..<end).reversed()
    }
}

#Preview {
    let sampleCards = [
        ActionCard(
            title: "Check Flight Prices",
            description: "Open Google Flights and look up your dream destination. No commitment, just possibilities.",
            category: .adventure,
            iconName: "airplane.departure",
            isPremium: false,
            durationMinutes: 5,
            difficulty: .easy
        ),
        ActionCard(
            title: "Face Your Finances",
            description: "Open your bank app and look at your balance. No fear, no judgment. Financial freedom starts with awareness.",
            category: .career,
            iconName: "dollarsign.circle.fill",
            isPremium: true,
            durationMinutes: 3,
            difficulty: .easy
        ),
        ActionCard(
            title: "Main Character Energy",
            description: "Walk into the next room like you own it. Shoulders back, chin up, slow down.",
            category: .mindset,
            iconName: "star.fill",
            isPremium: false,
            durationMinutes: 2,
            difficulty: .easy
        )
    ]

    return DeckView(
        cards: sampleCards,
        currentIndex: 0,
        isPremium: false,
        onSwipeRight: {},
        onSwipeLeft: {},
        onUnlockTap: {}
    )
    .padding()
    .background(DesignSystem.Colors.background)
}
