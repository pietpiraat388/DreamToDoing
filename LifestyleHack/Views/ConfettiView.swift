// MIT License - Action Deck MVP for Shipyard Hackathon
// See LICENSE file for details

import SwiftUI

struct ConfettiView: View {

    @State private var particles: [ConfettiParticle] = []

    private let colors: [Color] = [
        DesignSystem.Colors.terracotta,
        DesignSystem.Colors.sageGreen,
        DesignSystem.Colors.oceanBlue,
        .yellow,
        .pink
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 0.6)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles(in: geometry.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        particles = (0..<50).map { _ in
            ConfettiParticle(
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 8...14),
                position: CGPoint(
                    x: size.width / 2 + CGFloat.random(in: -50...50),
                    y: size.height / 2
                ),
                velocity: CGVector(
                    dx: CGFloat.random(in: -200...200),
                    dy: CGFloat.random(in: -400 ... -200)
                ),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
        }
    }

    private func animateParticles(in size: CGSize) {
        withAnimation(.easeOut(duration: 2.0)) {
            particles = particles.map { particle in
                var updated = particle
                updated.position = CGPoint(
                    x: particle.position.x + particle.velocity.dx,
                    y: particle.position.y + particle.velocity.dy + 400
                )
                updated.rotation += Double.random(in: 180...360)
                updated.opacity = 0
                return updated
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var position: CGPoint
    let velocity: CGVector
    var rotation: Double
    var opacity: Double
}

#Preview {
    ZStack {
        DesignSystem.Colors.background
            .ignoresSafeArea()

        ConfettiView()
    }
}
