// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct SplashView: View {

    let onComplete: () -> Void

    @State private var showFirstLine = false
    @State private var showSecondLine = false

    private let backgroundColor = DesignSystem.Colors.background

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.sm) {
                Image("SplashIconDream")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("Go from dreaming...")
                    .font(DesignSystem.Typography.header(28))
                    .foregroundStyle(DesignSystem.Colors.primaryText)
                    .opacity(showFirstLine ? 1 : 0)

                Text("...to doing.")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(DesignSystem.Colors.terracotta)
                    .opacity(showSecondLine ? 1 : 0)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // First line fades in after 0.3s
        withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
            showFirstLine = true
        }

        // Second line fades in 0.5s after first line completes
        withAnimation(.easeIn(duration: 0.8).delay(1.6)) {
            showSecondLine = true
        }

        // Transition to main app after full animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
            onComplete()
        }
    }
}

#Preview {
    SplashView(onComplete: {})
}
