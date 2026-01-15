// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct PaywallView: View {

    @Environment(\.dismiss) private var dismiss
    let onPurchase: () -> Void

    private let backgroundColor = DesignSystem.Colors.background

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer()

                iconView

                Text("Unlock Premium")
                    .font(DesignSystem.Typography.header(32))
                    .foregroundStyle(DesignSystem.Colors.primaryText)

                Text("You've completed your 3 free actions today!")
                    .font(DesignSystem.Typography.body(16))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)

                benefitsList
                    .padding(.vertical, DesignSystem.Spacing.lg)

                Spacer()

                ctaButton

                restoreButton

                dismissButton
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
    }

    // MARK: - Subviews

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Colors.terracotta, DesignSystem.Colors.oceanBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)

            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white)
        }
    }

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            benefitRow(icon: "infinity", text: "Unlimited daily actions")
            benefitRow(icon: "sparkles", text: "Access all premium cards")
            benefitRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed progress tracking")
            benefitRow(icon: "bell.fill", text: "Custom reminders")
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Colors.terracotta)
                .frame(width: 28)

            Text(text)
                .font(DesignSystem.Typography.body(16))
                .foregroundStyle(DesignSystem.Colors.primaryText)
        }
    }

    private var ctaButton: some View {
        Button(action: {
            onPurchase()
            dismiss()
        }) {
            Text("Unlock Premium")
                .font(DesignSystem.Typography.bodySemibold(18))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [DesignSystem.Colors.terracotta, DesignSystem.Colors.oceanBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .sensoryFeedback(.impact, trigger: true)
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            // Stub for StoreKit restore
        }
        .font(DesignSystem.Typography.body(14))
        .foregroundStyle(DesignSystem.Colors.secondaryText)
    }

    private var dismissButton: some View {
        Button("Maybe Later") {
            dismiss()
        }
        .font(DesignSystem.Typography.bodyMedium(16))
        .foregroundStyle(DesignSystem.Colors.primaryText)
        .padding(.top, DesignSystem.Spacing.sm)
    }
}

#Preview {
    PaywallView(onPurchase: {})
}
