// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import Foundation

@Observable
@MainActor
final class ContentManager {

    private(set) var allActions: [ActionCard] = []
    private(set) var isLoaded = false

    init() {
        loadActions()
    }

    private func loadActions() {
        guard let url = Bundle.main.url(forResource: "actions", withExtension: "json") else {
            print("Error: actions.json not found in bundle")
            loadFallbackActions()
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            allActions = try decoder.decode([ActionCard].self, from: data)
            isLoaded = true
        } catch {
            print("Error decoding actions.json: \(error)")
            loadFallbackActions()
        }
    }

    private func loadFallbackActions() {
        allActions = [
            ActionCard(
                title: "Main Character Energy",
                description: "Walk into the next room like you own it. Shoulders back, chin up, slow down.",
                category: .mindset,
                iconName: "star.fill",
                isPremium: false,
                durationMinutes: 2,
                difficulty: .easy
            ),
            ActionCard(
                title: "Face Your Finances",
                description: "Open your bank app and look at your balance. No fear, no judgment. Financial freedom starts with awareness.",
                category: .finance,
                iconName: "dollarsign.circle.fill",
                isPremium: false,
                durationMinutes: 3,
                difficulty: .easy
            ),
            ActionCard(
                title: "Check Flight Prices",
                description: "Open Google Flights and look up your dream destination. No commitment, just possibilities.",
                category: .adventure,
                iconName: "airplane.departure",
                isPremium: false,
                durationMinutes: 5,
                difficulty: .easy
            )
        ]
        isLoaded = true
    }

    func getShuffledDeck(includeOnlyFree: Bool = false) -> [ActionCard] {
        var deck = allActions
        if includeOnlyFree {
            deck = deck.filter { !$0.isPremium }
        }
        return deck.shuffled()
    }

    /// Returns a session deck based on subscription status
    /// - Premium users: Full shuffled deck
    /// - Free users: Only `limit` random free cards (prevents infinite reading exploit)
    func getSessionDeck(isPremium: Bool, limit: Int = 5) -> [ActionCard] {
        if isPremium {
            return allActions.shuffled()
        } else {
            let freeCards = allActions.filter { !$0.isPremium }.shuffled()
            return Array(freeCards.prefix(limit))
        }
    }

    func actions(for category: Category) -> [ActionCard] {
        allActions.filter { $0.category == category }
    }
}
