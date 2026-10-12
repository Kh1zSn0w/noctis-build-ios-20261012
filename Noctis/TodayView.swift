import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: NoctisStore
    @State private var foodSheet = false
    @State private var weightSheet = false
    @State private var settingsSheet = false

    var body: some View {
        NoctisPage("MONDAY IS NOT REQUIRED", "Own today.") {
            Panel {
                VStack(alignment: .leading, spacing: 19) {
                    HStack {
                        Label("ENERGY CONTROL", systemImage: "bolt.fill")
                            .font(.system(size: 10, weight: .heavy)).tracking(1.6).foregroundStyle(N.cyan)
                        Spacer()
                        Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.abbreviated)).uppercased())
                            .font(.system(size: 9, weight: .semibold)).foregroundStyle(N.muted)
                    }
                    HStack(alignment: .center, spacing: 15) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(Int(store.todayIntake))").font(.system(size: 51, weight: .bold, design: .rounded))
                                .monospacedDigit().tracking(-3).contentTransition(.numericText())
                            Text("KCAL EATEN").font(.system(size: 10, weight: .bold)).tracking(1.5).foregroundStyle(N.muted)
                            Text("\(max(0, Int(store.calorieGoal - store.todayIntake))) remaining")
                                .font(.system(size: 13, weight: .medium)).foregroundStyle(N.cyan).padding(.top, 7)
                        }
                        Spacer()
                        ZStack {
                            Circle().stroke(Color.white.opacity(0.07), lineWidth: 12)
                            Circle().trim(from: 0, to: min(1, store.todayIntake / max(1, store.calorieGoal)))
                                .stroke(N.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            Image(systemName: "flame.fill").font(.system(size: 29)).foregroundStyle(N.cyan)
                        }.frame(width: 115, height: 115)
                    }
                    Divider().overlay(N.line)
                    HStack {
                        Metric(caption: "DAILY TARGET", value: "\(Int(store.calorieGoal))", unit: "kcal")
                        Metric(caption: "PROTEIN", value: "\(Int(store.todayProtein))", unit: "/ \(Int(store.profile.proteinGoal)) g")
                    }
                    ProgressTrack(percent: store.todayProtein / max(1, store.profile.proteinGoal))
                    PrimaryAction(title: "LOG FOOD", icon: "plus") { foodSheet = true }
                }
            }
            SectionName(title: "BODY / BASELINE", detail: "ESTIMATED, NOT MEASURED")
            HStack(spacing: 12) {
                Panel {
                    Metric(caption: "CURRENT WEIGHT", value: String(format: "%.1f", store.latestWeight), unit: "kg")
                    Button("LOG WEIGH-IN  +") { weightSheet = true }
                        .font(.system(size: 10, weight: .bold)).tracking(0.8).foregroundStyle(N.cyan).padding(.top, 12)
                }
                Panel {
                    Metric(caption: "DAILY TDEE", value: "\(Int(store.tdee))", unit: "kcal")
                    Button("EDIT BASELINE  ↗") { settingsSheet = true }
                        .font(.system(size: 10, weight: .bold)).tracking(0.8).foregroundStyle(N.cyan).padding(.top, 12)
                }
            }
            if store.weights.count > 1 {
                Panel {
                    SectionName(title: "WEIGHT TREND", detail: "LAST 7 DAYS AVG.")
                    Text(String(format: "%.1f KG", store.recentAverage))
                        .font(.system(size: 27, weight: .bold, design: .rounded)).padding(.top, 8)
                    Text("Use same-time morning weigh-ins; follow weekly averages, not single days.")
                        .font(.system(size: 12)).foregroundStyle(N.muted).padding(.top, 4)
                }
            }
            SectionName(title: "TODAY'S INTAKE", detail: "\(store.todayFoods.count) ENTRIES")
            if store.todayFoods.isEmpty {
                Panel {
                    HStack(spacing: 13) {
                        Image(systemName: "fork.knife").foregroundStyle(N.cyan)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nothing logged yet").font(.system(size: 15, weight: .semibold))
                            Text("Weigh your food for a stronger estimate.").font(.system(size: 12)).foregroundStyle(N.muted)
                        }
                    }
                }
            } else {
                Panel {
                    ForEach(store.todayFoods.reversed()) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.name).font(.system(size: 14, weight: .semibold))
                                Text(entry.grams > 0 ? "\(Int(entry.grams)) g · \(Int(entry.protein)) g protein" : "\(Int(entry.protein)) g protein")
                                    .font(.system(size: 11)).foregroundStyle(N.muted)
                            }
                            Spacer()
                            Text("\(Int(entry.calories))").font(.system(size: 15, weight: .bold, design: .rounded))
                        }.padding(.vertical, 6)
                        if entry.id != store.todayFoods.first?.id { Divider().overlay(N.line) }
                    }
                    Text("Swipe entries in log sheet to delete. Food values are approximations.")
                        .font(.system(size: 10)).foregroundStyle(N.muted).padding(.top, 4)
                }
            }
            SectionName(title: "TODAY'S MISSION")
            Panel {
                HStack(spacing: 13) {
                    Image(systemName: "target").font(.system(size: 25, weight: .light)).foregroundStyle(N.cyan)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Consistency beats intensity.").font(.system(size: 16, weight: .bold))
                        Text("Log honestly. Lift with intention. Sleep enough to recover.")
                            .font(.system(size: 12)).foregroundStyle(N.muted).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .sheet(isPresented: $foodSheet) { FoodSheet() }
        .sheet(isPresented: $weightSheet) { WeightSheet() }
        .sheet(isPresented: $settingsSheet) { ProfileSheet() }
    }
}

struct FoodSheet: View {
    @EnvironmentObject private var store: NoctisStore
    @Environment(\.dismiss) private var dismiss
    @State private var selection = FoodItem.catalog[0].name
    @State private var grams = "150"
    @State private var customName = ""
    @State private var customCalories = ""
    @State private var customProtein = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Weighed food · per 100g reference") {
                    Picker("Food", selection: $selection) {
                        ForEach(FoodItem.catalog) { f in Text(f.name).tag(f.name) }
                    }
                    TextField("Grams", text: $grams).keyboardType(.decimalPad)
                    if let item = FoodItem.catalog.first(where: { $0.name == selection }) {
                        let n = max(0, Double(grams) ?? 0) / 100
                        Text("\(Int(item.calories * n)) kcal · \(Int(item.protein * n)) g protein")
                    }
                    Button("Add weighed food") {
                        if let f = FoodItem.catalog.first(where: { $0.name == selection }) {
                            store.addFood(f, grams: Double(grams) ?? 0); dismiss()
                        }
                    }.fontWeight(.bold)
                }
                Section("Custom entry · use nutrition label") {
                    TextField("Name", text: $customName)
                    TextField("Calories for serving", text: $customCalories).keyboardType(.decimalPad)
                    TextField("Protein in grams", text: $customProtein).keyboardType(.decimalPad)
                    Button("Add custom entry") {
                        store.addCustomFood(customName, calories: Double(customCalories) ?? -1, protein: Double(customProtein) ?? -1)
                        dismiss()
                    }.fontWeight(.bold)
                }
                Section("Today's entries") {
                    ForEach(store.todayFoods) { entry in
                        HStack { Text(entry.name); Spacer(); Text("\(Int(entry.calories)) kcal").foregroundStyle(N.muted) }
                    }.onDelete { offsets in
                        let list = store.todayFoods
                        let ids = Set(offsets.map { list[$0].id })
                        store.foods.removeAll { ids.contains($0.id) }
                    }
                }
                Section { Text("Estimates vary by brands, cooking method and portion measurement. Weigh foods and use the package label when possible.").font(.footnote) }
            }
            .navigationTitle("Food ledger").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
        .preferredColorScheme(.dark)
    }
}

struct WeightSheet: View {
    @EnvironmentObject private var store: NoctisStore
    @Environment(\.dismiss) private var dismiss
    @State private var kg = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("New weigh-in") {
                    TextField("Weight in kg", text: $kg).keyboardType(.decimalPad)
                    Button("Save weight") {
                        if let x = Double(kg), (30...350).contains(x) { store.addWeight(x); dismiss() }
                    }.fontWeight(.bold)
                }
                Section("Past weigh-ins") {
                    ForEach(store.weights.reversed()) { x in
                        HStack {
                            Text(x.date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            Text(String(format: "%.1f kg", x.kg))
                        }
                    }
                }
            }.navigationTitle("Bodyweight")
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
                .onAppear { kg = String(format: "%.1f", store.profile.weight) }
        }.preferredColorScheme(.dark)
    }
}

struct ProfileSheet: View {
    @EnvironmentObject private var store: NoctisStore
    @Environment(\.dismiss) private var dismiss
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var tdee = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Measurements") {
                    Picker("Formula", selection: $store.profile.sex) {
                        Text("Male").tag("Male"); Text("Female").tag("Female")
                    }
                    TextField("Age (years)", text: $age).keyboardType(.numberPad)
                    TextField("Height (cm)", text: $height).keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $weight).keyboardType(.decimalPad)
                }
                Section("Activity factor") {
                    Picker("Usual daily activity", selection: $store.profile.activity) {
                        Text("Sedentary · 1.2").tag(1.2)
                        Text("Light · 1.375").tag(1.375)
                        Text("Moderate · 1.55").tag(1.55)
                        Text("Very active · 1.725").tag(1.725)
                    }
                }
                Section("TDEE estimate") {
                    Text("\(Int(store.tdee)) kcal/day · Mifflin-St Jeor + activity factor")
                    TextField("Custom TDEE override (0 = formula)", text: $tdee).keyboardType(.decimalPad)
                    Text("TDEE is an estimate. Adjust using 2 to 4 weeks of weight trends and intake records.").font(.footnote)
                }
                Section {
                    Button("Save baseline") {
                        if let x = Int(age), (16...100).contains(x) { store.profile.age = x }
                        if let x = Double(height), (120...230).contains(x) { store.profile.height = x }
                        if let x = Double(weight), (30...350).contains(x) { store.addWeight(x) }
                        store.profile.customTDEE = max(0, Double(tdee) ?? 0)
                        dismiss()
                    }.fontWeight(.bold)
                }
            }.navigationTitle("Your baseline")
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
        .onAppear {
            age = "\(store.profile.age)"; height = "\(Int(store.profile.height))"
            weight = String(format: "%.1f", store.profile.weight)
            tdee = store.profile.customTDEE == 0 ? "0" : "\(Int(store.profile.customTDEE))"
        }
        .preferredColorScheme(.dark)
    }
}
