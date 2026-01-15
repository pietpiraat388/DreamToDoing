// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct HomeView: View {

    @State private var viewModel: HomeViewModel
    @State private var showHistory = false

    private let backgroundColor = DesignSystem.Colors.background

    init(contentManager: ContentManager, subscriptionManager: SubscriptionManager) {
        _viewModel = State(initialValue: HomeViewModel(
            contentManager: contentManager,
            subscriptionManager: subscriptionManager
        ))
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.lg) {
                headerView

                Spacer(minLength: 40)

                if viewModel.cardDeck.isEmpty {
                    loadingView
                } else {
                    DeckView(
                        cards: viewModel.cardDeck,
                        currentIndex: viewModel.currentCardIndex,
                        isPremium: viewModel.isPremium,
                        onSwipeRight: { viewModel.completeCard() },
                        onSwipeLeft: { viewModel.skipCard() },
                        onUnlockTap: { viewModel.showPaywall = true }
                    )
                }

                progressView

                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.md)

            if viewModel.showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if viewModel.showEmptyState {
                EmptyStateView()
                    .transition(.opacity)
            }
        }
        .animation(DesignSystem.Animation.smooth, value: viewModel.showEmptyState)
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(onPurchase: viewModel.unlockPremium)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .sensoryFeedback(.success, trigger: viewModel.completedTodayCount)
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            // History Button (Left)
            Button {
                showHistory = true
            } label: {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(DesignSystem.Colors.terracotta)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.cardBackground)
                            .shadow(
                                color: .black.opacity(DesignSystem.Card.shadowOpacity),
                                radius: 6,
                                y: 3
                            )
                    )
            }

            Spacer()

            // Title (Center)
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Dream to Doing")
                    .font(DesignSystem.Typography.header(24))
                    .foregroundStyle(DesignSystem.Colors.primaryText)

                Text("Small actions, big changes")
                    .font(DesignSystem.Typography.body(12))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }

            Spacer()

            // Streak Badge (Right)
            streakBadge
        }
    }

    private var streakBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "flame.fill")
                .foregroundStyle(DesignSystem.Colors.terracotta)

            Text("\(viewModel.currentStreak)")
                .font(DesignSystem.Typography.bodySemibold(18))
                .foregroundStyle(DesignSystem.Colors.primaryText)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: .black.opacity(DesignSystem.Card.shadowOpacity),
                    radius: 8,
                    y: 4
                )
        )
    }

    private var progressView: some View {
        Group {
            if !viewModel.isPremium {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(DesignSystem.Colors.terracotta)

                    Text("\(viewModel.remainingFreeCards) Daily Actions Left")
                        .font(DesignSystem.Typography.bodyMedium(14))
                        .foregroundStyle(DesignSystem.Colors.terracotta)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    Capsule()
                        .fill(DesignSystem.Colors.terracotta.opacity(0.1))
                )
            }
        }
        .padding(.bottom, DesignSystem.Spacing.xl)
    }

    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading your deck...")
                .font(DesignSystem.Typography.body(16))
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }
        .frame(height: 420)
    }
}

#Preview {
    HomeView(
        contentManager: ContentManager(),
        subscriptionManager: SubscriptionManager()
    )
}
