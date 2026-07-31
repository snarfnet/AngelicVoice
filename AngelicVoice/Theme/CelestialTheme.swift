import SwiftUI

// MARK: - Celestial Color Palette
enum Celestial {
    static let void = Color(red: 0.02, green: 0.02, blue: 0.08)
    static let deepIndigo = Color(red: 0.05, green: 0.04, blue: 0.18)
    static let nebula = Color(red: 0.12, green: 0.06, blue: 0.28)
    static let violet = Color(red: 0.35, green: 0.15, blue: 0.55)
    static let silver = Color(red: 0.78, green: 0.80, blue: 0.88)
    static let starWhite = Color(red: 0.92, green: 0.93, blue: 0.98)
    static let glowBlue = Color(red: 0.30, green: 0.55, blue: 0.95)
    static let glowCyan = Color(red: 0.20, green: 0.75, blue: 0.90)
    static let aurora = Color(red: 0.25, green: 0.85, blue: 0.65)
    static let angelGold = Color(red: 0.90, green: 0.80, blue: 0.50)
    static let faintStar = Color(red: 0.60, green: 0.62, blue: 0.70)
    static let runeGlow = Color(red: 0.55, green: 0.70, blue: 1.0)
}

// MARK: - Starfield Background
struct StarfieldBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Celestial.void, Celestial.deepIndigo, Celestial.void],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Stars
            Canvas { context, size in
                let starCount = 120
                for i in 0..<starCount {
                    let seed = i * 7919 + 1327
                    let x = CGFloat(seed % Int(size.width))
                    let y = CGFloat((seed * 3) % Int(size.height))
                    let brightness = Double((seed * 7) % 100) / 100.0
                    let starSize = CGFloat(1 + (seed % 3))

                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)),
                        with: .color(.white.opacity(0.1 + brightness * 0.5))
                    )
                }
            }
            .ignoresSafeArea()

            // Nebula glow
            RadialGradient(
                colors: [Celestial.nebula.opacity(0.3), .clear],
                center: .init(x: 0.3, y: 0.2),
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Celestial.violet.opacity(0.15), .clear],
                center: .init(x: 0.7, y: 0.8),
                startRadius: 30,
                endRadius: 250
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Glass Card
struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial.opacity(0.3))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Celestial.deepIndigo.opacity(0.5))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Celestial.glowBlue.opacity(0.3),
                                Celestial.violet.opacity(0.1),
                                Celestial.glowCyan.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Glow Effect
struct CelestialGlow: ViewModifier {
    var color: Color = Celestial.glowBlue
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(pulse ? 0.4 : 0.15), radius: pulse ? 15 : 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

// MARK: - Sacred Geometry Divider
struct SacredDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            gradientLine
            triquetra
            gradientLine
        }
        .padding(.vertical, 8)
    }

    private var gradientLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, Celestial.glowBlue.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }

    private var triquetra: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 10))
            .foregroundColor(Celestial.glowCyan.opacity(0.5))
    }
}

// MARK: - Enochian Letter View
struct EnochianLetterView: View {
    let letter: EnochianLetter
    var size: CGFloat = 40

    var body: some View {
        VStack(spacing: 2) {
            Text(letter.glyph)
                .font(.system(size: size, weight: .light))
                .foregroundColor(Celestial.runeGlow)

            Text(letter.name)
                .font(.system(size: size * 0.2, weight: .light))
                .foregroundColor(Celestial.faintStar)
        }
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }

    func celestialGlow(_ color: Color = Celestial.glowBlue) -> some View {
        modifier(CelestialGlow(color: color))
    }
}
