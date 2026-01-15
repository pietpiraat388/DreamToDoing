// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct HistoryView: View {

    @Environment(\.dismiss) private var dismiss

    private let historyManager = HistoryManager.shared
    private let backgroundColor = DesignSystem.Colors.background

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                headerView
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.lg)

                if historyManager.completedActions.isEmpty {
                    Spacer()
                    emptyStateView
                    Spacer()
                } else {
                    historyList
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("My Wins")
                    .font(DesignSystem.Typography.header(32))
                    .foregroundStyle(DesignSystem.Colors.primaryText)

                Text("\(historyManager.totalWins) total actions completed")
                    .font(DesignSystem.Typography.body(14))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.cardBackground)
                    )
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.terracotta.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(DesignSystem.Colors.terracotta.opacity(0.5))
            }

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No wins yet.")
                    .font(DesignSystem.Typography.header(24))
                    .foregroundStyle(DesignSystem.Colors.primaryText)

                Text("Go get some, Queen!")
                    .font(DesignSystem.Typography.body(16))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
        }
        .padding()
    }

    // MARK: - History List

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md, pinnedViews: .sectionHeaders) {
                if !historyManager.todayWins.isEmpty {
                    historySection(title: "Today", wins: historyManager.todayWins)
                }

                if !historyManager.yesterdayWins.isEmpty {
                    historySection(title: "Yesterday", wins: historyManager.yesterdayWins)
                }

                if !historyManager.earlierWins.isEmpty {
                    historySection(title: "Earlier", wins: historyManager.earlierWins)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
    }

    private func historySection(title: String, wins: [CompletedAction]) -> some View {
        Section {
            ForEach(wins) { win in
                winCard(win)
            }
        } header: {
            HStack {
                Text(title)
                    .font(DesignSystem.Typography.bodySemibold(14))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)

                Spacer()

                Text("\(wins.count) \(wins.count == 1 ? "win" : "wins")")
                    .font(DesignSystem.Typography.body(12))
                    .foregroundStyle(DesignSystem.Colors.secondaryText.opacity(0.7))
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .background(backgroundColor)
        }
    }

    // MARK: - Win Card (Mini-Card Style)

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

                Text(win.dateCompleted.formatted(date: .omitted, time: .shortened))
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
                    color: .black.opacity(0.06),
                    radius: 8,
                    y: 4
                )
        )
    }
}

#Preview {
    HistoryView()
}
