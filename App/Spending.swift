import SwiftUI

struct SpendingView: View {
    @EnvironmentObject var store: Store
    @State private var month = Date()
    @State private var adding = false

    var body: some View {
        let d = store.data
        let lang = d.settings.language
        let cal = appCal(lang)
        let spent = d.monthSpend(month)
        let manual = d.monthIncome(month)
        let fromShifts = d.monthPay(month)
        let earned = manual + fromShifts
        let by = d.spendByCat(month)
        let items = d.entries(in: month).sorted { $0.date > $1.date }
        let limit = max(earned, 10000)
        let progress = min(spent / limit, 1)
        NavigationStack {
            ScrollView {
                VStack(spacing: 19) {
                    HStack {
                        FlamioScreenTitle(title: "Траты", subtitle: "Контролируй свои расходы 💜")
                        Button { adding = true; FlamioSound.tap() } label: {
                            Image(systemName: "plus").font(.system(size: 20, weight: .semibold)).foregroundStyle(FlamioPalette.orange)
                                .frame(width: 48, height: 48).background(.ultraThinMaterial, in: Circle())
                                .overlay(Circle().stroke(FlamioPalette.orange.opacity(0.45), lineWidth: 1))
                        }
                    }.padding(.top, 8)
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "calendar").foregroundStyle(FlamioPalette.purple)
                            Text("В этом месяце").font(.subheadline).foregroundStyle(FlamioPalette.muted)
                            Spacer()
                            HStack(spacing: 14) {
                                Button { month = cal.date(byAdding: .month, value: -1, to: month) ?? month; FlamioSound.tap() } label: { Image(systemName: "chevron.left") }
                                Text(monthTitle(month, lang)).font(.caption.weight(.semibold))
                                Button { month = cal.date(byAdding: .month, value: 1, to: month) ?? month; FlamioSound.tap() } label: { Image(systemName: "chevron.right") }
                            }.foregroundStyle(FlamioPalette.orange)
                        }
                        ZStack(alignment: .trailing) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(d.m(spent)).font(.system(size: 39, weight: .bold, design: .rounded)).foregroundStyle(.white).contentTransition(.numericText())
                                Text("Твои расходы под контролем").font(.caption).foregroundStyle(FlamioPalette.muted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 110)
                            PetAvatar(s: d.settings, size: 138).offset(x: 10, y: 8).opacity(0.96)
                        }
                        .frame(height: 125)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.10))
                                Capsule().fill(LinearGradient(colors: [FlamioPalette.purple, FlamioPalette.orange], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: max(8, geo.size.width * progress))
                                    .shadow(color: FlamioPalette.orange.opacity(0.45), radius: 8)
                            }
                        }.frame(height: 10)
                        HStack {
                            Text("Лимит: \(d.m(limit))").font(.caption).foregroundStyle(FlamioPalette.muted)
                            Spacer()
                            Text("\(Int(progress * 100))%").font(.caption.bold()).foregroundStyle(FlamioPalette.orange)
                        }
                    }.padding(19).flamioCard(accent: FlamioPalette.orange, radius: 27)
                    HStack(spacing: 10) {
                        miniStat("Расходов", d.m(spent), "chart.bar.fill", FlamioPalette.purple)
                        miniStat("Покупок", "\(items.count)", "tag.fill", FlamioPalette.orange)
                        miniStat("Средний чек", d.m(items.isEmpty ? 0 : spent / Double(items.count)), "wallet.pass.fill", FlamioPalette.purple)
                    }
                    if !by.isEmpty {
                        VStack(alignment: .leading, spacing: 13) {
                            Text("Расходы по категориям").font(.headline).foregroundStyle(.white)
                            ForEach(by.sorted { $0.value > $1.value }, id: \.key) { item in
                                VStack(spacing: 7) {
                                    HStack {
                                        Text(Cats.find(item.key).emoji)
                                        Text(Cats.find(item.key).name).font(.subheadline).foregroundStyle(.white)
                                        Spacer()
                                        Text(d.m(item.value)).font(.caption.weight(.semibold)).foregroundStyle(FlamioPalette.muted)
                                    }
                                    GeometryReader { g in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(Color.white.opacity(0.08))
                                            Capsule().fill(LinearGradient(colors: [FlamioPalette.purple, FlamioPalette.orange], startPoint: .leading, endPoint: .trailing))
                                                .frame(width: max(5, g.size.width * item.value / max(spent, 1)))
                                        }
                                    }.frame(height: 6)
                                }
                            }
                        }.padding(17).flamioCard()
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        HStack { Text("История").font(.title3.bold()).foregroundStyle(.white); Spacer(); Text("Все операции  ›").font(.caption.weight(.semibold)).foregroundStyle(FlamioPalette.purple) }
                        if items.isEmpty {
                            Text("Пока нет операций. Нажми +, чтобы добавить первую.").font(.caption).foregroundStyle(FlamioPalette.muted).padding(.vertical, 12)
                        }
                        ForEach(items) { e in
                            HStack(spacing: 12) {
                                Text(e.shownEmoji).font(.system(size: 22)).frame(width: 48, height: 48).background(FlamioPalette.purple.opacity(0.22), in: RoundedRectangle(cornerRadius: 15))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(e.note.isEmpty ? Cats.find(e.cat).name : e.note).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                                    Text(e.date, format: .dateTime.day().month(.abbreviated)).font(.caption).foregroundStyle(FlamioPalette.muted)
                                }
                                Spacer()
                                Text((e.isIncome ? "+" : "−") + d.m(e.amount)).font(.subheadline.bold()).foregroundStyle(e.isIncome ? Color.green : .white)
                            }.padding(12).flamioCard(accent: e.isIncome ? .green : FlamioPalette.purple, radius: 18)
                            .contextMenu { Button(role: .destructive) { store.data.expenses.removeAll { $0.id == e.id } } label: { Label("Удалить", systemImage: "trash") } }
                        }
                    }
                }.padding(.horizontal, 17).padding(.bottom, 110)
            }
            .scrollIndicators(.hidden)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $adding) { AddEntry().preferredColorScheme(.dark) }
        }
    }

    func miniStat(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(title).font(.caption2).foregroundStyle(FlamioPalette.muted)
            Text(value).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.white).lineLimit(1).minimumScaleFactor(0.7)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(12).flamioCard(accent: color, radius: 19)
    }
}

struct AddEntry: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State private var income = false
    @State private var amount: Double?
    @State private var cat = "food"
    @State private var note = ""
    @State private var emoji = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Picker("", selection: $income) {
                    Text("Расход").tag(false)
                    Text("Доход").tag(true)
                }
                .pickerStyle(.segmented)
                .onChange(of: income) { _, v in cat = v ? "salary" : "food" }

                TextField("Сумма", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 28, weight: .light))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(income ? Cats.income : Cats.expense) { c in
                        Button { cat = c.id } label: {
                            VStack(spacing: 4) {
                                Text(c.emoji).font(.title2)
                                Text(c.name).font(.caption2).lineLimit(1)
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .background(cat == c.id ? Color.accentColor.opacity(0.25) : Color.gray.opacity(0.1),
                                        in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                EmojiField(title: "Свой эмодзи (необязательно)", text: $emoji)
                TextField("Заметка", text: $note)
                DatePicker("Дата", selection: $date, displayedComponents: .date)
            }
            .navigationTitle(income ? "Новый доход" : "Новый расход")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        if let a = amount, a > 0 {
                            store.data.expenses.append(Expense(date: date, amount: a, cat: cat, note: note,
                                                               income: income, emoji: emoji.isEmpty ? nil : emoji))
                            FlamioSound.success()
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
