import SwiftUI
import AudioToolbox

// Shared visual language for Flamio: deep space, violet glass and warm flame.
enum FlamioPalette {
    static let bg = Color(red: 0.025, green: 0.018, blue: 0.055)
    static let panel = Color(red: 0.075, green: 0.035, blue: 0.13)
    static let purple = Color(red: 0.62, green: 0.20, blue: 1.0)
    static let violet = Color(red: 0.34, green: 0.10, blue: 0.72)
    static let orange = Color(red: 1.0, green: 0.48, blue: 0.12)
    static let gold = Color(red: 1.0, green: 0.72, blue: 0.22)
    static let muted = Color(red: 0.69, green: 0.64, blue: 0.77)
}

struct FlamioBackground: View {
    private let stars: [(CGFloat, CGFloat, CGFloat)] = [
        (0.08, 0.12, 2), (0.24, 0.20, 1.5), (0.72, 0.10, 2), (0.91, 0.23, 1.5),
        (0.58, 0.34, 1.5), (0.13, 0.48, 1.5), (0.84, 0.58, 2), (0.38, 0.72, 1.5)
    ]
    var body: some View {
        GeometryReader { geo in
            ZStack {
                FlamioPalette.bg
                RadialGradient(colors: [FlamioPalette.purple.opacity(0.30), .clear], center: .topLeading, startRadius: 5, endRadius: 440)
                RadialGradient(colors: [Color(red: 0.30, green: 0.02, blue: 0.62).opacity(0.28), .clear], center: .bottomTrailing, startRadius: 10, endRadius: 430)
                ForEach(stars.indices, id: \.self) { i in
                    Circle().fill(i.isMultiple(of: 3) ? FlamioPalette.orange : .white.opacity(0.9))
                        .frame(width: stars[i].2, height: stars[i].2)
                        .shadow(color: i.isMultiple(of: 3) ? FlamioPalette.orange : FlamioPalette.purple, radius: 5)
                        .position(x: geo.size.width * stars[i].0, y: geo.size.height * stars[i].1)
                }
                VStack {
                    Spacer()
                    HStack(alignment: .bottom, spacing: -18) {
                        cloud(width: 175, height: 88).offset(x: -45, y: 18)
                        Spacer(minLength: 0)
                        cloud(width: 205, height: 104).offset(x: 55, y: 16)
                    }
                    .frame(height: 100)
                    .opacity(0.78)
                }
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
    }

    func cloud(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            Capsule().fill(LinearGradient(colors: [Color(red: 0.23, green: 0.04, blue: 0.48), Color(red: 0.045, green: 0.012, blue: 0.11)], startPoint: .top, endPoint: .bottom)).frame(width: width, height: height * 0.48)
            HStack(alignment: .bottom, spacing: -18) {
                Circle().fill(Color(red: 0.17, green: 0.025, blue: 0.38)).frame(width: height * 0.72, height: height * 0.72)
                Circle().fill(Color(red: 0.24, green: 0.035, blue: 0.50)).frame(width: height, height: height)
                Circle().fill(Color(red: 0.13, green: 0.02, blue: 0.31)).frame(width: height * 0.78, height: height * 0.78)
            }
            .offset(y: 2)
            .shadow(color: FlamioPalette.purple.opacity(0.42), radius: 15)
        }
        .frame(width: width, height: height)
    }
}

struct FlamioCard: ViewModifier {
    var accent: Color = FlamioPalette.purple
    var radius: CGFloat = 24
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(LinearGradient(colors: [Color.white.opacity(0.105), FlamioPalette.panel.opacity(0.94), accent.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(LinearGradient(colors: [accent.opacity(0.65), Color.white.opacity(0.08), FlamioPalette.orange.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                    .shadow(color: accent.opacity(0.16), radius: 18, y: 7)
            }
    }
}

extension View {
    func flamioCard(accent: Color = FlamioPalette.purple, radius: CGFloat = 24) -> some View { modifier(FlamioCard(accent: accent, radius: radius)) }
}

struct FlamioPrimaryButtonStyle: ButtonStyle {
    var color: Color = FlamioPalette.orange
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(LinearGradient(colors: [color, color.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.28), lineWidth: 1))
            .shadow(color: color.opacity(configuration.isPressed ? 0.12 : 0.42), radius: configuration.isPressed ? 5 : 16, y: 5)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.58), value: configuration.isPressed)
    }
}

enum FlamioSound {
    static func tap() { AudioServicesPlaySystemSound(1104) }
    static func success() { AudioServicesPlaySystemSound(1025) }
    static func feed() { AudioServicesPlaySystemSound(1306) }
    static func warning() { AudioServicesPlaySystemSound(1053) }
}

struct FlamioTabBar: View {
    @Binding var selection: Int
    private let tabs: [(String, String)] = [("Погода", "cloud.sun.fill"), ("Смены", "calendar"), ("Огонёк", "flame.fill"), ("Траты", "wallet.pass.fill")]
    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    FlamioSound.tap()
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.72)) { selection = i }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tabs[i].1).font(.system(size: 21, weight: .semibold))
                        Text(tabs[i].0).font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(selection == i ? FlamioPalette.orange : .white.opacity(0.86))
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background {
                        if selection == i {
                            RoundedRectangle(cornerRadius: 22).fill(Color.black.opacity(0.52))
                                .overlay(alignment: .top) { Capsule().fill(FlamioPalette.orange).frame(width: 38, height: 3).shadow(color: FlamioPalette.orange, radius: 8) }
                                .shadow(color: FlamioPalette.orange.opacity(0.20), radius: 14)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .background(Capsule().fill(FlamioPalette.panel.opacity(0.82)))
        .overlay(Capsule().stroke(LinearGradient(colors: [Color.white.opacity(0.30), FlamioPalette.purple.opacity(0.50), FlamioPalette.orange.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .shadow(color: .black.opacity(0.5), radius: 18, y: 8)
        .padding(.horizontal, 18).padding(.bottom, 5)
    }
}

struct FlamioScreenTitle: View {
    let title: String
    var subtitle: String? = nil
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(FlamioPalette.orange.opacity(0.22)).frame(width: 48, height: 48).blur(radius: 10)
                Image(systemName: title == "Траты" ? "wallet.pass.fill" : (title == "Смены" ? "flame.fill" : "sparkles"))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [FlamioPalette.gold, FlamioPalette.orange, .red.opacity(0.9)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: FlamioPalette.orange.opacity(0.75), radius: 12)
            }.frame(width: 50, height: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 31, weight: .bold, design: .rounded)).foregroundStyle(.white)
                if let subtitle { Text(subtitle).font(.system(size: 13, weight: .medium)).foregroundStyle(FlamioPalette.muted) }
            }
            Spacer(minLength: 0)
        }
    }
}
