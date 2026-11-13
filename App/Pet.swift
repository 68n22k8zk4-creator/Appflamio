import SwiftUI

// MARK: - Flamio (нарисованный персонаж)
struct FlameShape: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        p.addCurve(to: CGPoint(x: w * 0.92, y: h * 0.62),
                   control1: CGPoint(x: w * 0.62, y: h * 0.22), control2: CGPoint(x: w * 0.95, y: h * 0.35))
        p.addCurve(to: CGPoint(x: w * 0.5, y: h),
                   control1: CGPoint(x: w * 0.9, y: h * 0.88), control2: CGPoint(x: w * 0.7, y: h))
        p.addCurve(to: CGPoint(x: w * 0.08, y: h * 0.62),
                   control1: CGPoint(x: w * 0.3, y: h), control2: CGPoint(x: w * 0.1, y: h * 0.88))
        p.addCurve(to: CGPoint(x: w * 0.5, y: 0),
                   control1: CGPoint(x: w * 0.05, y: h * 0.4), control2: CGPoint(x: w * 0.38, y: h * 0.3))
        p.closeSubpath()
        return p
    }
}

struct SmileShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addQuadCurve(to: CGPoint(x: r.width, y: 0), control: CGPoint(x: r.width / 2, y: r.height * 2))
        return p
    }
}

struct FlamioView: View {
    let size: CGFloat

    var eye: some View {
        ZStack {
            Circle().fill(Color(red: 0.15, green: 0.05, blue: 0.1)).frame(width: size * 0.1, height: size * 0.1)
            Circle().fill(Color.white).frame(width: size * 0.035, height: size * 0.035)
                .offset(x: size * 0.015, y: -size * 0.02)
        }
    }

    var body: some View {
        ZStack {
            Circle().fill(FlamioPalette.orange.opacity(0.22)).frame(width: size * 0.78, height: size * 0.78).blur(radius: size * 0.16)
            Image("FlamioFox")
                .resizable()
                .scaledToFit()
                .frame(width: size * 1.02, height: size * 1.02)
                .shadow(color: FlamioPalette.orange.opacity(0.45), radius: size * 0.10, y: size * 0.04)
            Text("✨").font(.system(size: size * 0.17)).offset(x: size * 0.39, y: -size * 0.30)
            Text("✦").font(.system(size: size * 0.13)).foregroundStyle(FlamioPalette.gold).offset(x: -size * 0.40, y: size * 0.02)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Гардероб
enum Wardrobe {
    struct Slot: Identifiable {
        let id: String
        let name: String
        let items: [String]
    }
    static let slots = [
        Slot(id: "hat", name: "Шапки", items: ["🎩", "🧢", "👑", "🎓", "👒", "⛑️", "🎀", "🪖"]),
        Slot(id: "face", name: "Очки", items: ["🕶️", "👓", "🥽", "😷"]),
        Slot(id: "neck", name: "Шея", items: ["🧣", "🎀", "📿", "🔔"]),
        Slot(id: "body", name: "Одежда", items: ["🧥", "🦺", "👕", "🥼", "👘"]),
        Slot(id: "bling", name: "Украшения", items: ["💎", "⭐", "🏅", "💍", "🌸", "🦋"])
    ]
}

struct PetAvatar: View {
    let s: Settings
    var size: CGFloat = 180
    @State private var bob = false
    @State private var blink = false

    @ViewBuilder func acc(_ slot: String, x: CGFloat, y: CGFloat, f: CGFloat) -> some View {
        if let e = s.outfit[slot], !e.isEmpty {
            Text(e).font(.system(size: size * f)).offset(x: size * x, y: size * y)
        }
    }

    var body: some View {
        ZStack {
            if s.petStyle == "emoji" {
                Text(s.petEmoji).font(.system(size: size * 0.7))
            } else {
                FlamioView(size: size)
            }
            acc("body", x: 0, y: 0.34, f: 0.36)
            acc("neck", x: 0, y: 0.22, f: 0.28)
            acc("face", x: 0, y: 0.06, f: 0.34)
            acc("hat", x: 0, y: -0.36, f: 0.34)
            acc("bling", x: 0.3, y: 0.3, f: 0.2)
        }
        .frame(width: size, height: size)
            .scaleEffect(bob ? 1.035 : 0.975)
            .offset(y: bob ? -5 : 4)
            .shadow(color: FlamioPalette.orange.opacity(0.30), radius: bob ? 24 : 14, y: 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.15).repeatForever(autoreverses: true)) { bob = true }
            }
            .accessibilityLabel("Питомец Flamio")
    }
}

struct WardrobeView: View {
    @EnvironmentObject var store: Store
    @State private var slot = "hat"

    var body: some View {
        let cur = Wardrobe.slots.first { $0.id == slot } ?? Wardrobe.slots[0]
        ScrollView {
            VStack(spacing: 18) {
                PetAvatar(s: store.data.settings, size: 200)
                Picker("", selection: $slot) {
                    ForEach(Wardrobe.slots) { Text($0.name).tag($0.id) }
                }
                .pickerStyle(.menu)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    Button { store.data.settings.outfit[slot] = nil } label: {
                        Image(systemName: "xmark").frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    ForEach(cur.items, id: \.self) { e in
                        Button { store.data.settings.outfit[slot] = e } label: {
                            Text(e).font(.system(size: 30)).frame(maxWidth: .infinity, minHeight: 56)
                                .background(store.data.settings.outfit[slot] == e ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.12),
                                            in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Гардероб")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PetAppearance: View {
    @EnvironmentObject var store: Store
    let presets = ["🦊", "🐱", "🐶", "🐼", "🐰", "🦁", "🐸", "🐵", "🐧", "🦄", "🐲", "🐹", "🐻", "🐨", "👾", "🤖", "👻", "🐥"]

    var body: some View {
        Form {
            Section {
                HStack { Spacer(); PetAvatar(s: store.data.settings, size: 150); Spacer() }
            }
            Section("Имя") { TextField("Имя", text: $store.data.settings.petName) }
            Section("Персонаж") {
                Picker("Вид", selection: $store.data.settings.petStyle) {
                    Text("Flamio").tag("flamio")
                    Text("Эмодзи").tag("emoji")
                }
                .pickerStyle(.segmented)
                if store.data.settings.petStyle == "emoji" {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                        ForEach(presets, id: \.self) { e in
                            Button { store.data.settings.petEmoji = e } label: { Text(e).font(.title) }.buttonStyle(.plain)
                        }
                    }
                    EmojiField(title: "Любой эмодзи", text: $store.data.settings.petEmoji, presets: [])
                }
            }
            Section {
                NavigationLink("Гардероб") { WardrobeView() }
                Button("Снять всё") { store.data.settings.outfit = [:] }
            }
        }
        .navigationTitle("Питомец")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Pet screen
struct PetView: View {
    @EnvironmentObject var store: Store
    @State private var feed = false
    @State private var games = false
    @State private var wardrobe = false
    @State private var reaction = ""
    @State private var showHeart = false

    var body: some View {
        let d = store.data
        let best = d.bestFood()
        let yesterday = appCal(d.settings.language).date(byAdding: .day, value: -1, to: .now) ?? .now
        NavigationStack {
            ScrollView {
                VStack(spacing: 19) {
                    FlamioScreenTitle(title: "Огонёк", subtitle: "Твой верный питомец ♡")
                        .padding(.top, 8)
                    ZStack {
                        Circle().fill(FlamioPalette.purple.opacity(0.32)).frame(width: 300, height: 300).blur(radius: 42)
                        Circle().stroke(FlamioPalette.purple.opacity(0.32), lineWidth: 1).frame(width: 255, height: 255)
                        Circle().stroke(FlamioPalette.orange.opacity(0.25), lineWidth: 1).frame(width: 285, height: 285)
                        Ellipse().fill(FlamioPalette.orange.opacity(0.42)).frame(width: 220, height: 24).blur(radius: 15).offset(y: 91)
                        Ellipse().stroke(FlamioPalette.orange.opacity(0.65), lineWidth: 2).frame(width: 215, height: 27).shadow(color: FlamioPalette.orange, radius: 12).offset(y: 91)
                        PetAvatar(s: d.settings, size: 245)
                        if showHeart {
                            Text("💖").font(.system(size: 34)).offset(x: 88, y: -72)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 300)
                    .onTapGesture {
                        FlamioSound.success()
                        withAnimation(.spring()) { showHeart = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { withAnimation { showHeart = false } }
                    }
                    VStack(spacing: 5) {
                        Text(d.settings.petName).font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(.white)
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill").foregroundStyle(FlamioPalette.orange).shadow(color: FlamioPalette.orange, radius: 8)
                            Text("\(d.streak)").font(.system(size: 39, weight: .bold, design: .rounded)).foregroundStyle(.white)
                            Text("дней подряд").font(.subheadline).foregroundStyle(FlamioPalette.muted)
                        }
                        Text(d.streakAlive ? "Серия сохранена! Так держать ✨" : "Покорми или поиграй сегодня")
                            .font(.caption).foregroundStyle(FlamioPalette.muted)
                        if !reaction.isEmpty { Text(reaction).font(.caption.weight(.semibold)).foregroundStyle(FlamioPalette.gold).transition(.opacity) }
                    }
                    HStack(spacing: 12) {
                        Button { feed = true; FlamioSound.tap() } label: {
                            Label("Покормить", systemImage: "fork.knife").font(.system(size: 16, weight: .bold)).frame(maxWidth: .infinity).padding(.vertical, 17)
                        }.buttonStyle(FlamioPrimaryButtonStyle(color: FlamioPalette.orange))
                        Button { games = true; FlamioSound.tap() } label: {
                            Label("Играть", systemImage: "gamecontroller.fill").font(.system(size: 16, weight: .bold)).frame(maxWidth: .infinity).padding(.vertical, 17)
                        }.buttonStyle(FlamioPrimaryButtonStyle(color: FlamioPalette.purple))
                    }
                    Button { wardrobe = true; FlamioSound.tap() } label: {
                        Label("Гардероб питомца", systemImage: "tshirt.fill").font(.subheadline.weight(.semibold)).foregroundStyle(FlamioPalette.muted)
                            .frame(maxWidth: .infinity).padding(.vertical, 12).flamioCard(radius: 18)
                    }.buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack { Text("Лучшее сейчас").font(.headline).foregroundStyle(.white); Spacer(); Text("Рекомендация").font(.caption2).foregroundStyle(FlamioPalette.gold) }
                        HStack(spacing: 12) {
                            Text(best.emoji).font(.system(size: 38)).frame(width: 58, height: 58).background(FlamioPalette.orange.opacity(0.14), in: RoundedRectangle(cornerRadius: 17))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(best.name).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                                Text("Порадуй своего питомца").font(.caption).foregroundStyle(FlamioPalette.muted)
                            }
                            Spacer()
                            Button("Дать") { give(best) }.font(.subheadline.bold()).padding(.horizontal, 17).padding(.vertical, 10)
                                .background(FlamioPalette.orange.opacity(0.20), in: Capsule()).foregroundStyle(FlamioPalette.orange)
                        }
                    }.padding(16).flamioCard(accent: FlamioPalette.orange)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Вчера").font(.caption).foregroundStyle(FlamioPalette.muted)
                            Text("Угощения и забота").font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                        }
                        Spacer()
                        let f = d.feeds(on: yesterday)
                        Text(f.isEmpty ? "—" : f.map(\.emoji).joined()).font(.title2)
                    }.padding(17).flamioCard()
                    NavigationLink { PetInfo() } label: {
                        HStack { Text("Всё о питомце"); Image(systemName: "arrow.up.right") }
                            .font(.subheadline.weight(.semibold)).foregroundStyle(FlamioPalette.purple).padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 18).padding(.bottom, 110)
            }
            .scrollIndicators(.hidden)
            .toolbar(.hidden, for: .navigationBar)
            .background(Color.clear)
            .sheet(isPresented: $feed) { FeedSheet { give($0) } }
            .sheet(isPresented: $games) { GamesList() }
            .sheet(isPresented: $wardrobe) {
                NavigationStack { WardrobeView().toolbar { ToolbarItem(placement: .confirmationAction) { Button("Готово") { wardrobe = false } } }
                }.preferredColorScheme(.dark)
            }
        }
    }

    func give(_ f: Food) {
        store.log("feed", f.emoji)
        FlamioSound.feed()
        withAnimation(.spring()) { reaction = f.health > 0 ? "Ням! Очень вкусно 😋" : (f.health < 0 ? "В следующий раз выберем полезнее" : "Спасибо! 💜") }
    }
}

struct FeedSheet: View {
    @Environment(\.dismiss) var dismiss
    let pick: (Food) -> Void

    var body: some View {
        NavigationStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 14) {
                ForEach(Foods.all) { f in
                    Button { pick(f); dismiss() } label: {
                        VStack(spacing: 4) {
                            Text(f.emoji).font(.system(size: 40))
                            Text(f.name).font(.caption)
                            Circle().fill(f.health > 0 ? Color.green : (f.health < 0 ? Color.red : Color.orange))
                                .frame(width: 6, height: 6)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .foregroundStyle(.white)
                        .background(FlamioPalette.panel, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(FlamioPalette.purple.opacity(0.45), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Чем накормить?")
            .toolbarBackground(FlamioPalette.bg, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationBackground(FlamioPalette.bg)
    }
}

struct PetInfo: View {
    @EnvironmentObject var store: Store

    var body: some View {
        let d = store.data
        let cal = appCal(d.settings.language)
        let days = (0..<7).map { cal.date(byAdding: .day, value: -$0, to: .now) ?? .now }
        let lastFed = d.petLogs.last { $0.kind == "feed" }?.date
        List {
            Section("Сегодня") {
                HStack {
                    Text("Последнее кормление")
                    Spacer()
                    if let lastFed { Text(lastFed, style: .relative).foregroundStyle(.secondary) } else { Text("—") }
                }
                HStack { Text("Кормлений"); Spacer(); Text("\(d.feeds(on: .now).count)").foregroundStyle(.secondary) }
                HStack { Text("Игр"); Spacer(); Text("\(d.plays(on: .now))").foregroundStyle(.secondary) }
            }
            Section("Питание за неделю") {
                ForEach(days, id: \.self) { day in
                    HStack {
                        Text(day, format: .dateTime.weekday(.abbreviated)).frame(width: 40, alignment: .leading)
                        Text(d.feeds(on: day).map(\.emoji).joined())
                        Spacer()
                        if let h = d.dayHealth(day) {
                            Circle().fill(h > 0.5 ? Color.green : (h > -0.5 ? Color.orange : Color.red))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
            }
            Section("Лучшая еда") {
                Text(Foods.all.sorted { $0.health > $1.health }.prefix(5).map(\.emoji).joined(separator: "  ")).font(.title2)
                Text("Больше овощей, фруктов и белка. Фастфуд и сладкое — редко.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Всего") {
                HStack { Text("Кормлений"); Spacer(); Text("\(d.petLogs.filter { $0.kind == "feed" }.count)").foregroundStyle(.secondary) }
                HStack { Text("Игр"); Spacer(); Text("\(d.petLogs.filter { $0.kind == "play" }.count)").foregroundStyle(.secondary) }
            }
        }
        .navigationTitle("Инфо")
        .navigationBarTitleDisplayMode(.inline)
    }
}
