// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct HomeView: View {

    @State private var viewModel: HomeViewModel
    @State private var showProfile = false
    @State private var streakButtonFrame: CGRect = .zero
    @State private var showFlyingFlame = false
    @State private var flameOffset: CGSize = .zero
    @State private var flameScale: CGFloat = 1.0
    @State private var flameOpacity: Double = 1.0
    @State private var streakButtonScale: CGFloat = 1.0

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
                        onSwipeRight: {
                            triggerFlyingFlame()
                            viewModel.completeCard()
                        },
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

            if showFlyingFlame {
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(DesignSystem.Colors.terracotta)
                    .scaleEffect(flameScale)
                    .opacity(flameOpacity)
                    .offset(flameOffset)
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
        .sheet(isPresented: $showProfile) {
            ProfileView(
                currentStreak: viewModel.currentStreak,
                longestStreak: viewModel.longestStreak,
                totalActions: viewModel.totalActionsCompleted
            )
        }
        .sensoryFeedback(.success, trigger: viewModel.completedTodayCount)
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            // Title (Left-aligned for balance)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Dream to Doing")
                    .font(DesignSystem.Typography.header(24))
                    .foregroundStyle(DesignSystem.Colors.primaryText)

                Text("Small actions, big changes")
                    .font(DesignSystem.Typography.body(12))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }

            Spacer()

            // Profile Button (Right) - Opens unified dashboard
            Button {
                showProfile = true
            } label: {
                streakBadge
            }
            .scaleEffect(streakButtonScale)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            streakButtonFrame = geo.frame(in: .global)
                        }
                        .onChange(of: geo.frame(in: .global)) { _, newValue in
                            streakButtonFrame = newValue
                        }
                }
            )
        }
    }

    private var streakBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "flame.fill")
                .foregroundStyle(DesignSystem.Colors.terracotta)

            Text("\(viewModel.totalActionsCompleted)")
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

    // MARK: - Flying Flame Animation

    private func triggerFlyingFlame() {
        // Reset to center
        flameOffset = .zero
        flameScale = 1.2
        flameOpacity = 1.0
        showFlyingFlame = true

        // Calculate target offset from center to streak button
        let screenCenter = CGPoint(
            x: UIScreen.main.bounds.midX,
            y: UIScreen.main.bounds.midY
        )
        let targetOffset = CGSize(
            width: streakButtonFrame.midX - screenCenter.x,
            height: streakButtonFrame.midY - screenCenter.y
        )

        // Animate to streak button
        withAnimation(.easeInOut(duration: 0.6)) {
            flameOffset = targetOffset
            flameScale = 0.5
            flameOpacity = 0.3
        }

        // Hide after animation + pulse the button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showFlyingFlame = false

            // Pulse the streak button
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                streakButtonScale = 1.15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    streakButtonScale = 1.0
                }
            }
        }
    }
}

#Preview {
    HomeView(
        contentManager: ContentManager(),
        subscriptionManager: SubscriptionManager()
    )
}
