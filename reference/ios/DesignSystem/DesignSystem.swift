import SwiftUI

enum DSColor {
    static let appBackground = Color(hex: "FDF8F3")
    static let surface = Color.white
    static let textPrimary = Color(hex: "1C1A2E")
    static let textSecondary = Color(hex: "6F6A87")

    static let coral = Color(hex: "FF5E73")
    static let yellow = Color(hex: "FFD75E")
    static let mint = Color(hex: "76E3C1")
    static let oceanBlue = Color(hex: "46B6FF")
    static let lavender = Color(hex: "A8A3FF")
    static let splashDeepTeal = Color(hex: "145868")

    static let oceanGradient = LinearGradient(
        colors: [Color(hex: "28C6FF"), Color(hex: "1E77EA")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let animalsGradient = LinearGradient(
        colors: [Color(hex: "96D26D"), Color(hex: "3FAE52")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let spaceGradient = LinearGradient(
        colors: [Color(hex: "6672FF"), Color(hex: "2A2D78")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let scienceGradient = LinearGradient(
        colors: [Color(hex: "6DE5D1"), Color(hex: "22A59A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mathGradient = LinearGradient(
        colors: [Color(hex: "FFC96B"), Color(hex: "FF8A4C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cultureGradient = LinearGradient(
        colors: [Color(hex: "FFAF87"), Color(hex: "FF6B6B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let emotionsGradient = LinearGradient(
        colors: [Color(hex: "FF9DBB"), Color(hex: "FF6F91")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let historyGradient = LinearGradient(
        colors: [Color(hex: "C9A67A"), Color(hex: "8D6E63")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let geographyGradient = LinearGradient(
        colors: [Color(hex: "7ED957"), Color(hex: "2F9E44")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let technologyGradient = LinearGradient(
        colors: [Color(hex: "7AA8FF"), Color(hex: "4A64D8")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func gradient(for topic: Topic) -> LinearGradient {
        switch topic {
        case .ocean: return oceanGradient
        case .animals: return animalsGradient
        case .space: return spaceGradient
        case .science: return scienceGradient
        case .math: return mathGradient
        case .culture: return cultureGradient
        case .emotionsSocial: return emotionsGradient
        case .history: return historyGradient
        case .geography: return geographyGradient
        case .technologyMachines: return technologyGradient
        }
    }
}

enum DSSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum DSRadii {
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 22
    static let pill: CGFloat = 999
}

enum DSTypography {
    static func hero() -> Font { .system(size: 30, weight: .black, design: .rounded) }
    static func title() -> Font { .system(size: 26, weight: .bold, design: .rounded) }
    static func subtitle() -> Font { .system(size: 18, weight: .semibold, design: .rounded) }
    static func body() -> Font { .system(size: 16, weight: .medium, design: .rounded) }
    static func bodyBold() -> Font { .system(size: 16, weight: .bold, design: .rounded) }
    static func storyReadingBody() -> Font { .system(size: 18, weight: .medium, design: .rounded) }
    static func statLabel() -> Font { .system(size: 16, weight: .bold, design: .rounded) }
    static func caption() -> Font { .system(size: 14, weight: .medium, design: .rounded) }
    static func captionBold() -> Font { .system(size: 14, weight: .bold, design: .rounded) }
    static func tiny() -> Font { .system(size: 12, weight: .semibold, design: .rounded) }
}

enum DSLayout {
    static let screenPadding: CGFloat = 16
    static let horizontalMargin: CGFloat = 16
    static let onboardingHeaderTopInset: CGFloat = 20
    static let onboardingNamePreviewMinHeight: CGFloat = 64
    static let onboardingNameTileSize: CGFloat = 34
    static let onboardingLetterButtonHeight: CGFloat = 42
    static let onboardingActionButtonHeight: CGFloat = 40
    static let onboardingAgeWheelHeight: CGFloat = 116
    static let controlHeight: CGFloat = 54
    static let primaryButtonHeight: CGFloat = 56
    static let artworkHeight: CGFloat = 220
    static let avatarSize: CGFloat = 64
    static let avatarInnerSize: CGFloat = 52
    static let smallAvatarSize: CGFloat = 46
    static let playButtonOuter: CGFloat = 58
    static let playButtonInner: CGFloat = 44
    static let playHudStatMinHeight: CGFloat = 90
    static let playHudStatIconBadgeSize: CGFloat = 28
    static let playHudStatIconSize: CGFloat = 12
    static let statPillMinHeight: CGFloat = 92
    static let statPillIconBadgeSize: CGFloat = 32
    static let statPillIconSize: CGFloat = 15
    static let homeJourneyStatMinHeight: CGFloat = 114
    static let homeJourneyStatIconBadgeSize: CGFloat = 40
    static let homeJourneyStatIconSize: CGFloat = 18
    static let homeCategoryIconSize: CGFloat = 50
    static let miniProgressRingSize: CGFloat = 40
    static let homePointsBubbleSize: CGFloat = 40
    static let homeCategoryBackdropTintOpacity: Double = 1.0
    static let homeCategoryBackdropHeight: CGFloat = 98
    static let homeCategoryBackdropSymbolOpacity: Double = 0.3
    static let homeRightClusterSpacing: CGFloat = 8
    static let homeRightClusterMinWidth: CGFloat = 88
    static let progressRingSize: CGFloat = 88
    static let progressRingLineWidth: CGFloat = 10
    static let categoryCardMinHeight: CGFloat = 182
    static let metricChipMinHeight: CGFloat = 30
    static let storyInfoChipMinHeight: CGFloat = 40
    static let storyInfoChipIconBadgeSize: CGFloat = 22
    static let storyInfoChipIconSize: CGFloat = 11
    static let storyInfoChipRowSpacing: CGFloat = 8
    static let storyStatTileMinHeight: CGFloat = 82
    static let storyStatIconBadgeSize: CGFloat = 30
    static let storyStatIconSize: CGFloat = 14
    static let storyBadgeRowMinHeight: CGFloat = 78
    static let storyBadgePreviewSize: CGFloat = 58
}

struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    DSColor.appBackground.ignoresSafeArea()
                    Circle()
                        .fill(Color(hex: "FFE6D9").opacity(0.65))
                        .frame(width: 340, height: 340)
                        .offset(x: -140, y: -260)
                    Circle()
                        .fill(Color(hex: "FFDCC4").opacity(0.4))
                        .frame(width: 300, height: 300)
                        .offset(x: 160, y: 280)
                }
            )
    }
}

extension View {
    func screenBackground() -> some View {
        modifier(ScreenBackground())
    }

    func cardStyle() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DSSpacing.md)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    func playfulFieldChrome(accent: Color = DSColor.lavender) -> some View {
        self
            .padding(.horizontal, DSSpacing.md)
            .frame(maxWidth: .infinity, minHeight: DSLayout.controlHeight, alignment: .leading)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                    .stroke(accent.opacity(0.45), lineWidth: 1.2)
            )
            .shadow(color: accent.opacity(0.12), radius: 6, x: 0, y: 3)
    }

    func screenContentPadding() -> some View {
        self.padding(.horizontal, DSLayout.horizontalMargin)
    }
}

struct PrimaryCTAButtonStyle: ButtonStyle {
    let font: Font

    init(font: Font = DSTypography.bodyBold()) {
        self.font = font
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundColor(.white)
            .padding(.horizontal, DSSpacing.md)
            .frame(maxWidth: .infinity, minHeight: DSLayout.primaryButtonHeight)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF7B8A"), DSColor.coral],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(configuration.isPressed ? 0.88 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
                    .stroke(Color.white.opacity(0.26), lineWidth: 1.1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .frame(height: DSLayout.primaryButtonHeight * 0.42)
                    .padding(.horizontal, 1)
            }
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.08 : 0.16), radius: configuration.isPressed ? 3 : 7, x: 0, y: configuration.isPressed ? 1 : 4)
            .shadow(color: DSColor.coral.opacity(configuration.isPressed ? 0.08 : 0.2), radius: configuration.isPressed ? 2 : 5, x: 0, y: configuration.isPressed ? 1 : 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct TonalCTAButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = DSColor.lavender) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.bodyBold())
            .foregroundColor(DSColor.textPrimary)
            .padding(.horizontal, DSSpacing.md)
            .frame(maxWidth: .infinity, minHeight: DSLayout.primaryButtonHeight)
            .background(
                LinearGradient(
                    colors: [color.opacity(configuration.isPressed ? 0.3 : 0.38), color.opacity(configuration.isPressed ? 0.22 : 0.28)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
                    .stroke(color.opacity(0.6), lineWidth: 1.3)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous))
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: DSLayout.primaryButtonHeight * 0.38)
                    .padding(.horizontal, 1)
            }
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.06 : 0.11), radius: configuration.isPressed ? 2 : 5, x: 0, y: configuration.isPressed ? 1 : 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SoftTonalCTAButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = DSColor.lavender) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.bodyBold())
            .foregroundColor(DSColor.textPrimary)
            .padding(.horizontal, DSSpacing.md)
            .frame(maxWidth: .infinity, minHeight: DSLayout.primaryButtonHeight)
            .background(
                LinearGradient(
                    colors: [color.opacity(configuration.isPressed ? 0.28 : 0.38), color.opacity(configuration.isPressed ? 0.2 : 0.28)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
                    .stroke(color.opacity(0.56), lineWidth: 1.15)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
                    .fill(Color.white.opacity(0.11))
                    .frame(height: DSLayout.primaryButtonHeight * 0.38)
                    .padding(.horizontal, 1)
            }
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.06 : 0.12), radius: configuration.isPressed ? 2 : 6, x: 0, y: configuration.isPressed ? 1 : 3)
            .shadow(color: color.opacity(configuration.isPressed ? 0.07 : 0.16), radius: configuration.isPressed ? 2 : 5, x: 0, y: configuration.isPressed ? 1 : 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryPillStyle: ButtonStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.captionBold())
            .foregroundColor(selected ? DSColor.textPrimary : DSColor.textSecondary)
            .padding(.horizontal, 14)
            .frame(minHeight: DSLayout.controlHeight)
            .background(
                LinearGradient(
                    colors: selected
                        ? [DSColor.yellow.opacity(configuration.isPressed ? 0.9 : 1), Color(hex: "F6C949").opacity(configuration.isPressed ? 0.86 : 0.96)]
                        : [DSColor.surface.opacity(configuration.isPressed ? 0.9 : 1), Color(hex: "F7F7FB").opacity(configuration.isPressed ? 0.88 : 0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
                    .stroke(selected ? Color.white.opacity(0.35) : Color.black.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.03 : 0.08), radius: configuration.isPressed ? 1 : 3, x: 0, y: configuration.isPressed ? 0 : 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)

        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
