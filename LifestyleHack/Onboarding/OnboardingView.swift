// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let slides: [(icon: String, title: String, subtitle: String)] = [
        ("airplane.departure", "Stop Dreaming", "Turn your mood board into reality with daily micro-actions."),
        ("hand.draw.fill", "Swipe to Decide", "Swipe Right to accept a challenge. Swipe Left to skip. Keep it simple."),
        ("flame.fill", "Build Your Streak", "Consistency is the key to your dream life. Are you ready?")
    ]

    private var isLastPage: Bool {
        currentPage == slides.count - 1
    }

    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        slideView(for: slides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                // Persistent button - always visible
                Button {
                    withAnimation(DesignSystem.Animation.smooth) {
                        if isLastPage {
                            hasSeenOnboarding = true
                        } else {
                            currentPage += 1
                        }
                    }
                } label: {
                    Text(isLastPage ? "Start My Journey" : "Next")
                        .font(DesignSystem.Typography.bodySemibold(18))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.terracotta)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .contentTransition(.interpolate)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
        }
        .animation(DesignSystem.Animation.smooth, value: currentPage)
    }

    @ViewBuilder
    private func slideView(for slide: (icon: String, title: String, subtitle: String)) -> some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            Image(systemName: slide.icon)
                .font(.system(size: 80))
                .foregroundStyle(DesignSystem.Colors.terracotta)

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(slide.title)
                    .font(DesignSystem.Typography.header(32))
                    .foregroundStyle(DesignSystem.Colors.primaryText)

                Text(slide.subtitle)
                    .font(DesignSystem.Typography.body(16))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            }

            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
