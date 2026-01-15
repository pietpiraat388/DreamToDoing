// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

@Observable
@MainActor
final class HomeViewModel {

    // MARK: - Dependencies

    private let contentManager: ContentManager
    private let subscriptionManager: SubscriptionManager

    // MARK: - Card Deck State

    var cardDeck: [ActionCard] = []
    var currentCardIndex: Int = 0

    // MARK: - Daily Progress

    var completedTodayCount: Int = 0
    var skippedTodayCount: Int = 0

    // MARK: - Streak (AppStorage backed)

    @ObservationIgnored
    @AppStorage("currentStreak") private var _currentStreak: Int = 0

    @ObservationIgnored
    @AppStorage("lastCompletedDate") private var _lastCompletedDateString: String = ""

    var currentStreak: Int {
        get { _currentStreak }
        set { _currentStreak = newValue }
    }

    private var lastCompletedDate: Date? {
        get {
            guard !_lastCompletedDateString.isEmpty else { return nil }
            return ISO8601DateFormatter().date(from: _lastCompletedDateString)
        }
        set {
            if let date = newValue {
                _lastCompletedDateString = ISO8601DateFormatter().string(from: date)
            } else {
                _lastCompletedDateString = ""
            }
        }
    }

    // MARK: - UI State

    var showConfetti: Bool = false
    var showPaywall: Bool = false
    var showEmptyState: Bool = false

    // MARK: - Computed Properties

    var currentCard: ActionCard? {
        guard currentCardIndex < cardDeck.count else { return nil }
        return cardDeck[currentCardIndex]
    }

    var hasReachedFreeLimit: Bool {
        !subscriptionManager.isPremium && completedTodayCount >= subscriptionManager.dailyFreeLimit
    }

    var isPremium: Bool {
        subscriptionManager.isPremium
    }

    var remainingFreeCards: Int {
        max(0, subscriptionManager.dailyFreeLimit - completedTodayCount)
    }

    // MARK: - Initialization

    init(contentManager: ContentManager, subscriptionManager: SubscriptionManager) {
        self.contentManager = contentManager
        self.subscriptionManager = subscriptionManager

        checkAndResetDailyProgress()
        loadDeck()
    }

    // MARK: - Deck Management

    func loadDeck() {
        // Free users get limited deck (5 cards) to prevent infinite reading exploit
        // Premium users get full shuffled deck
        cardDeck = contentManager.getSessionDeck(isPremium: isPremium, limit: 5)
        currentCardIndex = 0
    }

    func reshuffleDeck() {
        loadDeck()
    }

    // MARK: - Swipe Actions

    func completeCard() {
        guard let card = currentCard else { return }

        // Check if already at limit before incrementing
        if hasReachedFreeLimit {
            showEmptyState = true
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                showEmptyState = false
                showPaywall = true
            }
            return
        }

        // Save win to history
        HistoryManager.shared.addWin(card: card)

        completedTodayCount += 1
        updateStreak()

        showConfetti = true

        advanceToNextCard()

        Task {
            try? await Task.sleep(for: .seconds(2))
            showConfetti = false

            // Check if we just hit the limit after this completion
            if hasReachedFreeLimit {
                showEmptyState = true
                try? await Task.sleep(for: .seconds(2.5))
                showEmptyState = false
                showPaywall = true
            }
        }
    }

    func skipCard() {
        guard let card = currentCard else { return }

        skippedTodayCount += 1

        // Recycle: move skipped card to bottom of deck instead of removing
        // This prevents infinite reading - same 5 cards keep cycling
        cardDeck.remove(at: currentCardIndex)
        cardDeck.append(card)
        // currentCardIndex stays the same - next card slides into position
    }

    private func advanceToNextCard() {
        withAnimation(DesignSystem.Animation.cardSwipe) {
            currentCardIndex += 1
        }

        if currentCardIndex >= cardDeck.count {
            reshuffleDeck()
        }
    }

    // MARK: - Streak Management

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = lastCompletedDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDifference == 1 {
                currentStreak += 1
            } else if daysDifference > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        lastCompletedDate = Date()
    }

    private func checkAndResetDailyProgress() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = lastCompletedDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            if today > lastDay {
                completedTodayCount = 0
                skippedTodayCount = 0
            }
        }

        if let lastDate = lastCompletedDate {
            let daysDifference = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if daysDifference > 1 {
                currentStreak = 0
            }
        }
    }

    // MARK: - Subscription

    func unlockPremium() {
        subscriptionManager.unlockPremium()
        showPaywall = false
    }
}
