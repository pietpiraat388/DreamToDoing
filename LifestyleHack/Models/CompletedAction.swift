// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import Foundation

struct CompletedAction: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let category: Category
    let iconName: String
    let dateCompleted: Date

    init(id: UUID = UUID(), title: String, category: Category, iconName: String, dateCompleted: Date = Date()) {
        self.id = id
        self.title = title
        self.category = category
        self.iconName = iconName
        self.dateCompleted = dateCompleted
    }

    init(from card: ActionCard) {
        self.id = UUID()
        self.title = card.title
        self.category = card.category
        self.iconName = card.iconName
        self.dateCompleted = Date()
    }
}
