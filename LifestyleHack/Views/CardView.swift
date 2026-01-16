// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI
import Combine

struct CardView: View {

    let card: ActionCard
    let showPremiumBadge: Bool
    let isPremiumUser: Bool
    let isTopCard: Bool
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void
    let onUnlockTap: () -> Void
    var onDragProgress: ((CGFloat) -> Void)?

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    // Flip & Timer State
    @State private var isFlipped = false
    @State private var timeRemaining: Int = 0
    @State private var timerActive = false
    @State private var timerFinished = false
    @State private var pulseOpacity: Double = 1.0

    private let swipeThreshold: CGFloat = 100
    private let cardCornerRadius = DesignSystem.Card.cornerRadius

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Back of card (timer view) - visible when flipped
            backView
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

            // Front of card - visible when not flipped
            frontView
                .opacity(isFlipped ? 0 : 1)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .offset(offset)
        .rotationEffect(.degrees(rotation), anchor: .bottom)
        .onTapGesture {
            if !showPremiumBadge && !isFlipped && isTopCard {
                if isPremiumUser {
                    startFocusMode()
                } else {
                    // Non-premium user tapped - show paywall
                    onUnlockTap()
                }
            }
        }
        .gesture(isFlipped ? nil : cardGesture)
        .animation(DesignSystem.Animation.cardSwipe, value: offset)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
        .onReceive(timer) { _ in
            guard timerActive && timeRemaining > 0 else { return }
            timeRemaining -= 1
            if timeRemaining == 0 {
                timerFinished = true
                timerActive = false
            }
        }
        .sensoryFeedback(.success, trigger: timerFinished)
    }

    // MARK: - Front View

    private var frontView: some View {
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
    }

    // MARK: - Back View (Focus Mode)

    private var backView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Task title (small)
            Text(card.title)
                .font(DesignSystem.Typography.bodySemibold(16))
                .foregroundStyle(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.top, DesignSystem.Spacing.xl)
                .padding(.horizontal, DesignSystem.Spacing.md)

            Spacer()

            // Large countdown timer
            Text(formatTime(timeRemaining))
                .font(DesignSystem.Typography.header(72))
                .foregroundStyle(DesignSystem.Colors.primaryText)
                .monospacedDigit()
                .contentTransition(.numericText())

            // Pulsing "Focus time..." text
            Text(timerFinished ? "Time's up!" : "Focus time...")
                .font(DesignSystem.Typography.body(16))
                .foregroundStyle(DesignSystem.Colors.terracotta)
                .opacity(pulseOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulseOpacity = 0.4
                    }
                }

            Spacer()

            // "I Did It!" button
            Button(action: completeFocusMode) {
                Text(timerFinished ? "Time's Up! Mark Done" : "I Did It!")
                    .font(DesignSystem.Typography.bodySemibold(18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(DesignSystem.Colors.sageGreen)
                    )
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)

            // Cancel button
            Button("Cancel") {
                cancelFocusMode()
            }
            .font(DesignSystem.Typography.body(14))
            .foregroundStyle(DesignSystem.Colors.secondaryText)
            .padding(.bottom, DesignSystem.Spacing.lg)
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

    // MARK: - Focus Mode Functions

    private func startFocusMode() {
        timeRemaining = card.durationMinutes * 60
        timerActive = true
        timerFinished = false
        pulseOpacity = 1.0
        isFlipped = true
    }

    private func completeFocusMode() {
        timerActive = false
        isFlipped = false

        // Small delay to let flip animation complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwipeRight()
        }
    }

    private func cancelFocusMode() {
        timerActive = false
        isFlipped = false
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
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
                .lineLimit(4)
                .padding(.horizontal, DesignSystem.Spacing.lg)

            Spacer()

            HStack(spacing: DesignSystem.Spacing.lg) {
                // Timer indicator with premium lock for non-premium users
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if !isPremiumUser && !showPremiumBadge {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(DesignSystem.Colors.terracotta)
                    }
                    Label("\(card.durationMinutes) min", systemImage: "clock")
                        .font(DesignSystem.Typography.body(14))
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                }

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

                    // Report drag progress to parent for background card animation
                    let progress = abs(gesture.translation.width) / swipeThreshold
                    onDragProgress?(min(progress, 1.0))
                }
            }
            .onEnded { gesture in
                if showPremiumBadge {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                        offset = .zero
                        rotation = 0
                    }
                    onUnlockTap()
                } else {
                    let velocity = gesture.velocity.width

                    if gesture.translation.width > swipeThreshold {
                        completeSwipe(direction: .right, velocity: velocity)
                    } else if gesture.translation.width < -swipeThreshold {
                        completeSwipe(direction: .left, velocity: velocity)
                    } else {
                        // Bouncy snap-back
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                            offset = .zero
                            rotation = 0
                        }
                        onDragProgress?(0)
                    }
                }
            }
    }

    private func completeSwipe(direction: SwipeDirection, velocity: CGFloat) {
        let offscreenX: CGFloat = direction == .right ? 500 : -500
        let exitRotation: Double = direction == .right ? 25 : -25

        // Velocity affects animation speed (faster swipe = faster exit)
        let baseDuration: Double = 0.35
        let velocityFactor = min(abs(velocity) / 1500, 1.0)
        let duration = baseDuration - (velocityFactor * 0.2)

        // Reset drag progress immediately
        onDragProgress?(0)

        withAnimation(.spring(response: duration, dampingFraction: 0.8)) {
            offset = CGSize(width: offscreenX, height: 0)
            rotation = exitRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
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
            isPremium: false,
            durationMinutes: 2,
            difficulty: .easy
        ),
        showPremiumBadge: false,
        isPremiumUser: false,
        isTopCard: true,
        onSwipeRight: {},
        onSwipeLeft: {},
        onUnlockTap: {},
        onDragProgress: nil
    )
    .padding()
    .background(DesignSystem.Colors.background)
}
