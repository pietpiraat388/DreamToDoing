// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct StreakView: View {

    @Environment(\.dismiss) private var dismiss

    let currentStreak: Int
    let longestStreak: Int
    let totalActions: Int

    @State private var isPulsing = false

    private let backgroundColor = DesignSystem.Colors.background

    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer()

                // Hero Flame
                flameView

                // Stats Grid
                statsGrid

                Spacer()

                // Motivational Quote
                quoteView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
            .navigationTitle("Your Streak")
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
                .fill(DesignSystem.Colors.terracotta.opacity(0.1))
                .frame(width: 140, height: 140)

            Image(systemName: "flame.fill")
                .font(.system(size: 70))
                .foregroundStyle(DesignSystem.Colors.terracotta)
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isPulsing
                )
        }
        .onAppear {
            isPulsing = true
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            statItem(value: currentStreak, label: "Current", icon: "flame")
            statItem(value: longestStreak, label: "Longest", icon: "trophy")
            statItem(value: totalActions, label: "Total", icon: "checkmark.circle")
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }

    private func statItem(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Colors.terracotta)

            Text("\(value)")
                .font(DesignSystem.Typography.header(28))
                .foregroundStyle(DesignSystem.Colors.primaryText)

            Text(label)
                .font(DesignSystem.Typography.body(12))
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: .black.opacity(0.06),
                    radius: 8,
                    y: 4
                )
        )
    }

    // MARK: - Quote

    private var quoteView: some View {
        Text("Consistency is the bridge between dreams and doing.")
            .font(DesignSystem.Typography.body(14))
            .foregroundStyle(DesignSystem.Colors.secondaryText)
            .italic()
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.lg)
    }
}

#Preview {
    StreakView(
        currentStreak: 7,
        longestStreak: 14,
        totalActions: 42
    )
}
