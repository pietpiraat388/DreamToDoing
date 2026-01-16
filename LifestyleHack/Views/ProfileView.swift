// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct ProfileView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedWeekOffset: Int = 0

    let currentStreak: Int
    let longestStreak: Int
    let totalActions: Int

    private let historyManager = HistoryManager.shared
    private let backgroundColor = DesignSystem.Colors.background

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Hero Flame
                    flameView
                        .padding(.top, DesignSystem.Spacing.md)

                    // Weekly Capsule
                    weeklyCapsule

                    // Stats Grid
                    statsGrid

                    // Recent Wins Section
                    recentWinsSection
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
    }

    // MARK: - Hero Flame

    private var flameView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.terracotta,
                            Color(red: 0.95, green: 0.7, blue: 0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 96, height: 96)
                .shadow(
                    color: DesignSystem.Colors.terracotta.opacity(0.3),
                    radius: 15,
                    x: 0,
                    y: 10
                )

            Image(systemName: "flame.fill")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Weekly Capsule

    private var availableWeeks: [Int] {
        Array((0..<8).reversed())
    }

    private func weekDays(for weekOffset: Int) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysSinceMonday = (weekday + 5) % 7

        guard let thisMonday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: today),
              let targetMonday = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: thisMonday) else {
            return []
        }

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: targetMonday)
        }
    }

    private func weekTitle(for weekOffset: Int) -> String {
        switch weekOffset {
        case 0: return "This Week"
        case 1: return "Last Week"
        default: return "\(weekOffset) Weeks Ago"
        }
    }

    private var weeklyCapsule: some View {
        TabView(selection: $selectedWeekOffset) {
            ForEach(availableWeeks, id: \.self) { weekOffset in
                weekView(for: weekOffset)
                    .tag(weekOffset)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 120)
    }

    private func weekView(for weekOffset: Int) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Left arrow: visible when can swipe right to older weeks
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(weekOffset < 7 ? DesignSystem.Colors.secondaryText : .clear)

                Text(weekTitle(for: weekOffset))
                    .font(DesignSystem.Typography.bodySemibold(14))
                    .foregroundStyle(DesignSystem.Colors.primaryText)

                // Right arrow: visible when can swipe left to newer weeks
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(weekOffset > 0 ? DesignSystem.Colors.secondaryText : .clear)
            }

            HStack(spacing: 0) {
                ForEach(weekDays(for: weekOffset), id: \.self) { day in
                    dayCircle(for: day)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DesignSystem.Colors.terracotta.opacity(0.15))
            )
        }
    }

    private func dayCircle(for date: Date) -> some View {
        let isCompleted = hasCompletedAction(on: date)
        let isToday = Calendar.current.isDateInToday(date)
        let dayLabel = dayLetter(for: date)

        return VStack(spacing: 4) {
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(DesignSystem.Colors.sageGreen)
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 32, height: 32)
                }
            }

            Text(dayLabel)
                .font(isToday ? DesignSystem.Typography.bodySemibold(11) : DesignSystem.Typography.body(11))
                .foregroundStyle(isToday ? DesignSystem.Colors.terracotta : DesignSystem.Colors.secondaryText)
        }
    }

    private func hasCompletedAction(on date: Date) -> Bool {
        let calendar = Calendar.current
        return historyManager.completedActions.contains { action in
            calendar.isDate(action.dateCompleted, inSameDayAs: date)
        }
    }

    private func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }

    // MARK: - Stats Grid

    private var groupedWins: [(date: Date, wins: [CompletedAction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: historyManager.completedActions) { action in
            calendar.startOfDay(for: action.dateCompleted)
        }
        return grouped.sorted { $0.key > $1.key }
            .map { (date: $0.key, wins: $0.value.sorted { $0.dateCompleted > $1.dateCompleted }) }
    }

    private func sectionHeader(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }

    private var statsGrid: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            statItem(value: currentStreak, label: "Current", icon: "flame")
            statItem(value: longestStreak, label: "Longest", icon: "trophy")
            statItem(value: totalActions, label: "Total", icon: "checkmark.circle")
        }
    }

    private func statItem(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(DesignSystem.Colors.terracotta)

            Text("\(value)")
                .font(DesignSystem.Typography.header(22))
                .foregroundStyle(DesignSystem.Colors.primaryText)

            Text(label)
                .font(DesignSystem.Typography.body(10))
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 6,
                    y: 3
                )
        )
    }

    // MARK: - Recent Wins Section

    private var recentWinsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Section Header
            Text("Recent Wins")
                .font(DesignSystem.Typography.header(24))
                .foregroundStyle(DesignSystem.Colors.primaryText)
                .padding(.top, DesignSystem.Spacing.sm)

            if historyManager.completedActions.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm, pinnedViews: [.sectionHeaders]) {
                    ForEach(groupedWins.prefix(7), id: \.date) { group in
                        Section {
                            ForEach(group.wins) { win in
                                winCard(win)
                            }
                        } header: {
                            HStack {
                                Text(sectionHeader(for: group.date))
                                    .font(DesignSystem.Typography.bodySemibold(14))
                                    .foregroundStyle(DesignSystem.Colors.secondaryText)

                                Spacer()

                                Text("\(group.wins.count) \(group.wins.count == 1 ? "win" : "wins")")
                                    .font(DesignSystem.Typography.body(12))
                                    .foregroundStyle(DesignSystem.Colors.secondaryText.opacity(0.7))
                            }
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .frame(maxWidth: .infinity)
                            .background(backgroundColor)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 40))
                .foregroundStyle(DesignSystem.Colors.terracotta.opacity(0.4))

            Text("No wins yet")
                .font(DesignSystem.Typography.bodySemibold(16))
                .foregroundStyle(DesignSystem.Colors.secondaryText)

            Text("Complete actions to see them here!")
                .font(DesignSystem.Typography.body(14))
                .foregroundStyle(DesignSystem.Colors.secondaryText.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
    }

    // MARK: - Win Card

    private func winCard(_ win: CompletedAction) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(win.category.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: win.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(win.category.accentColor)
            }

            // Title & Time
            VStack(alignment: .leading, spacing: 4) {
                Text(win.title)
                    .font(DesignSystem.Typography.bodySemibold(15))
                    .foregroundStyle(DesignSystem.Colors.primaryText)
                    .lineLimit(1)

                Text(formatDate(win.dateCompleted))
                    .font(DesignSystem.Typography.body(12))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }

            Spacer()

            // Green Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(DesignSystem.Colors.sageGreen)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 6,
                    y: 3
                )
        )
    }

    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today, " + date.formatted(date: .omitted, time: .shortened)
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday, " + date.formatted(date: .omitted, time: .shortened)
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
}

#Preview {
    ProfileView(
        currentStreak: 7,
        longestStreak: 14,
        totalActions: 42
    )
}
