// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import Foundation

struct ActionCard: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let category: Category
    let iconName: String
    let isPremium: Bool
    let durationMinutes: Int
    let difficulty: Difficulty

    enum Difficulty: String, Codable, CaseIterable {
        case easy
        case medium
        case challenging
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case iconName
        case isPremium
        case durationMinutes
        case difficulty
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: Category,
        iconName: String,
        isPremium: Bool,
        durationMinutes: Int,
        difficulty: Difficulty
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.iconName = iconName
        self.isPremium = isPremium
        self.durationMinutes = durationMinutes
        self.difficulty = difficulty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.category = try container.decode(Category.self, forKey: .category)
        self.iconName = try container.decode(String.self, forKey: .iconName)
        self.isPremium = try container.decode(Bool.self, forKey: .isPremium)
        self.durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
    }
}
