// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct CardView: View {

    let card: ActionCard
    let showPremiumBadge: Bool
    let isTopCard: Bool
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void
    let onUnlockTap: () -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    private let swipeThreshold: CGFloat = 100
    private let cardCornerRadius = DesignSystem.Card.cornerRadius

    var body: some View {
        ZStack(alignment: .topTrailing) {
            cardContent
                .saturation(showPremiumBadge ? 0.6 : 1.0)

            if showPremiumBadge {
                premiumBadge
                    .padding(DesignSystem.Spacing.md)
            }

            if !showPremiumBadge {
                swipeOverlay
            }
        }
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .gesture(cardGesture)
        .animation(DesignSystem.Animation.cardSwipe, value: offset)
    }

    // MARK: - Card Content

    private var cardContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(card.category.accentColor.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: card.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(card.category.accentColor)
            }
            .padding(.top, DesignSystem.Spacing.lg)

            Text(card.title)
                .font(DesignSystem.Typography.header(24))
                .foregroundStyle(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.md)

            Text(card.description)
                .font(DesignSystem.Typography.body(16))
                .foregroundStyle(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, DesignSystem.Spacing.lg)

            Spacer()

            HStack(spacing: DesignSystem.Spacing.lg) {
                Label("\(card.durationMinutes) min", systemImage: "clock")
                    .font(DesignSystem.Typography.body(14))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)

                Label(card.difficulty.rawValue.capitalized, systemImage: "chart.bar.fill")
                    .font(DesignSystem.Typography.body(14))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
            .padding(.bottom, DesignSystem.Spacing.lg)

            swipeHints
                .padding(.bottom, DesignSystem.Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: .black.opacity(DesignSystem.Card.shadowOpacity),
                    radius: DesignSystem.Card.shadowRadius,
                    y: DesignSystem.Card.shadowY
                )
        )
    }

    // MARK: - Swipe Hints

    private var swipeHints: some View {
        Group {
            if showPremiumBadge {
                Button(action: onUnlockTap) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "lock.fill")
                        Text("Unlock")
                    }
                    .font(DesignSystem.Typography.bodySemibold(14))
                    .foregroundStyle(DesignSystem.Colors.terracotta)
                }
            } else {
                HStack {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "arrow.left")
                        Text("Skip")
                    }
                    .font(DesignSystem.Typography.body(12))
                    .foregroundStyle(DesignSystem.Colors.skip)

                    Spacer()

                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text("Done")
                        Image(systemName: "arrow.right")
                    }
                    .font(DesignSystem.Typography.body(12))
                    .foregroundStyle(DesignSystem.Colors.success)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
    }

    // MARK: - Premium Badge

    private var premiumBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "crown.fill")
            Text("Premium")
        }
        .font(DesignSystem.Typography.bodySemibold(12))
        .foregroundStyle(.white)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Colors.terracotta, DesignSystem.Colors.oceanBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }

    // MARK: - Swipe Overlay

    private var swipeOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(DesignSystem.Colors.success, lineWidth: 4)
                .opacity(rightSwipeProgress)

            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(DesignSystem.Colors.skip, lineWidth: 4)
                .opacity(leftSwipeProgress)
        }
    }

    // MARK: - Gesture

    private var cardGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if showPremiumBadge {
                    let clampedWidth = min(max(gesture.translation.width, -30), 30)
                    offset = CGSize(width: clampedWidth, height: 0)
                    rotation = Double(clampedWidth / 20)
                } else {
                    offset = gesture.translation
                    rotation = Double(gesture.translation.width / 20)
                }
            }
            .onEnded { gesture in
                if showPremiumBadge {
                    withAnimation(DesignSystem.Animation.bounce) {
                        offset = .zero
                        rotation = 0
                    }
                    onUnlockTap()
                } else {
                    if gesture.translation.width > swipeThreshold {
                        completeSwipe(direction: .right)
                    } else if gesture.translation.width < -swipeThreshold {
                        completeSwipe(direction: .left)
                    } else {
                        offset = .zero
                        rotation = 0
                    }
                }
            }
    }

    private func completeSwipe(direction: SwipeDirection) {
        let offscreenX: CGFloat = direction == .right ? 500 : -500

        withAnimation(DesignSystem.Animation.cardSwipe) {
            offset = CGSize(width: offscreenX, height: 0)
            rotation = direction == .right ? 15 : -15
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = .zero
            rotation = 0

            if direction == .right {
                onSwipeRight()
            } else {
                onSwipeLeft()
            }
        }
    }

    // MARK: - Computed Properties

    private var rightSwipeProgress: Double {
        max(0, min(1, Double(offset.width / swipeThreshold)))
    }

    private var leftSwipeProgress: Double {
        max(0, min(1, Double(-offset.width / swipeThreshold)))
    }

    private enum SwipeDirection {
        case left, right
    }
}

#Preview {
    CardView(
        card: ActionCard(
            title: "Main Character Energy",
            description: "Walk into the next room like you own it. Shoulders back, chin up, slow down.",
            category: .mindset,
            iconName: "star.fill",
            isPremium: true,
            durationMinutes: 2,
            difficulty: .easy
        ),
        showPremiumBadge: true,
        isTopCard: true,
        onSwipeRight: {},
        onSwipeLeft: {},
        onUnlockTap: {}
    )
    .padding()
    .background(DesignSystem.Colors.background)
}
