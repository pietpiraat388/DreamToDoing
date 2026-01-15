// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import Foundation

@Observable
@MainActor
final class HistoryManager {

    static let shared = HistoryManager()

    private(set) var completedActions: [CompletedAction] = []

    @ObservationIgnored
    private let storageKey = "completedActionsHistory"

    private init() {
        loadFromStorage()
    }

    // MARK: - Public Methods

    func addWin(card: ActionCard) {
        let completedAction = CompletedAction(from: card)
        completedActions.insert(completedAction, at: 0)
        saveToStorage()
    }

    func clearHistory() {
        completedActions.removeAll()
        saveToStorage()
    }

    // MARK: - Grouped Accessors

    var todayWins: [CompletedAction] {
        completedActions.filter { Calendar.current.isDateInToday($0.dateCompleted) }
    }

    var yesterdayWins: [CompletedAction] {
        completedActions.filter { Calendar.current.isDateInYesterday($0.dateCompleted) }
    }

    var earlierWins: [CompletedAction] {
        completedActions.filter {
            !Calendar.current.isDateInToday($0.dateCompleted) &&
            !Calendar.current.isDateInYesterday($0.dateCompleted)
        }
    }

    var totalWins: Int {
        completedActions.count
    }

    // MARK: - Persistence

    private func saveToStorage() {
        do {
            let data = try JSONEncoder().encode(completedActions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Error saving history: \(error)")
        }
    }

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            completedActions = try JSONDecoder().decode([CompletedAction].self, from: data)
        } catch {
            print("Error loading history: \(error)")
            completedActions = []
        }
    }
}
