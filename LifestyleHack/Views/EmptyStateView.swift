// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct EmptyStateView: View {

    @State private var showContent = false
    @State private var showCheckmark = false

    private let backgroundColor = DesignSystem.Colors.background

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.sm) {
                // App logo
                Image("SplashIconDream")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheckmark ? 1 : 0.5)
                    .opacity(showCheckmark ? 1 : 0)

                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("You went from dreaming")
                        .font(DesignSystem.Typography.header(28))
                        .foregroundStyle(DesignSystem.Colors.primaryText)

                    Text("to doing today.")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(DesignSystem.Colors.terracotta)
                }
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("See you tomorrow.")
                        .font(DesignSystem.Typography.body(16))
                        .foregroundStyle(DesignSystem.Colors.secondaryText)

                    Text("Come back for 3 new actions.")
                        .font(DesignSystem.Typography.body(14))
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                }
                .padding(.top, DesignSystem.Spacing.md)
                .opacity(showContent ? 1 : 0)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
        .onAppear {
            withAnimation(DesignSystem.Animation.bounce.delay(0.2)) {
                showCheckmark = true
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.4)) {
                showContent = true
            }
        }
    }
}

#Preview {
    EmptyStateView()
}
