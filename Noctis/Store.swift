import Foundation
import SwiftUI

struct Profile: Codable {
    var age = 22
    var height = 175.0
    var weight = 107.0
    var sex = "Male"
    var activity = 1.45
    var cutPercent = 0.20
    var customTDEE = 0.0
    var proteinGoal = 150.0
}
struct FoodItem: Identifiable {
    let name: String
    let calories: Double
    let protein: Double
    var id: String { name }
    static let catalog: [FoodItem] = [
        .init(name: "Chicken breast, cooked", calories: 165, protein: 31),
        .init(name: "Whole egg", calories: 143, protein: 12.6),
        .init(name: "Potato, baked", calories: 93, protein: 2.5),
        .init(name: "Greek yogurt, plain", calories: 73, protein: 10),
        .init(name: "Bread, whole wheat", calories: 247, protein: 13),
        .init(name: "Olive oil", calories: 884, protein: 0),
        .init(name: "Banana", calories: 89, protein: 1.1),
        .init(name: "Whey protein powder", calories: 400, protein: 80),
        .init(name: "Rice, cooked", calories: 130, protein: 2.7),
        .init(name: "Beef, lean cooked", calories: 217, protein: 27),
        .init(name: "Cucumber", calories: 15, protein: 0.7),
        .init(name: "Almonds", calories: 579, protein: 21)
    ]
}
struct FoodLog: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var name: String
    var grams: Double
    var calories: Double
    var protein: Double
}
struct WeightLog: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var kg: Double
}
struct LiftLog: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var exercise: String
    var sets: Int
    var reps: Int
    var kg: Double
}
struct UrgeLog: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var trigger: String
    var interrupted: Bool
}
struct FocusLog: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var minutes: Int
}

final class NoctisStore: ObservableObject {
    @Published var profile: Profile { didSet { save() } }
    @Published var foods: [FoodLog] { didSet { save() } }
    @Published var weights: [WeightLog] { didSet { save() } }
    @Published var lifts: [LiftLog] { didSet { save() } }
    @Published var urges: [UrgeLog] { didSet { save() } }
    @Published var focus: [FocusLog] { didSet { save() } }
    init() {
        let d = UserDefaults.standard
        func load<T: Decodable>(_ key: String, _ fallback: T) -> T {
            guard let data = d.data(forKey: "noctis." + key),
                  let result = try? JSONDecoder().decode(T.self, from: data) else { return fallback }
            return result
        }
        profile = load("profile", Profile())
        foods = load("foods", [])
        weights = load("weights", [])
        lifts = load("lifts", [])
        urges = load("urges", [])
        focus = load("focus", [])
    }
    private func save() {
        let e = JSONEncoder()
        func put<T: Encodable>(_ key: String, _ value: T) {
            if let data = try? e.encode(value) {
                UserDefaults.standard.set(data, forKey: "noctis." + key)
            }
        }
        put("profile", profile)
        put("foods", foods)
        put("weights", weights)
        put("lifts", lifts)
        put("urges", urges)
        put("focus", focus)
    }
    var bmr: Double {
        let p = profile
        return 10 * p.weight + 6.25 * p.height - 5 * Double(p.age) + (p.sex == "Male" ? 5 : -161)
    }
    var tdee: Double {
        if profile.customTDEE > 0 { return profile.customTDEE }
        return max(1000, bmr * profile.activity)
    }
    var calorieGoal: Double {
        let floor = profile.sex == "Male" ? 1500.0 : 1200.0
        return min(tdee, max(floor, (tdee * (1 - profile.cutPercent)).rounded()))
    }
    var todayFoods: [FoodLog] { foods.filter { Calendar.current.isDateInToday($0.date) } }
    var todayIntake: Double { todayFoods.reduce(0) { $0 + $1.calories } }
    var todayProtein: Double { todayFoods.reduce(0) { $0 + $1.protein } }
    var todayLifts: [LiftLog] { lifts.filter { Calendar.current.isDateInToday($0.date) } }
    var focusToday: Int { focus.filter { Calendar.current.isDateInToday($0.date) }.reduce(0) { $0 + $1.minutes } }
    var latestWeight: Double { weights.max { $0.date < $1.date }?.kg ?? profile.weight }
    var recentAverage: Double {
        let recent = weights.filter { $0.date > Date().addingTimeInterval(-7 * 86400) }
        return recent.isEmpty ? profile.weight : recent.map(\.kg).reduce(0, +) / Double(recent.count)
    }
    var resistanceCount: Int { urges.filter(\.interrupted).count }
    var focusTotal: Int { focus.reduce(0) { $0 + $1.minutes } }
    func addFood(_ item: FoodItem, grams: Double) {
        guard grams > 0, grams < 10000 else { return }
        let factor = grams / 100
        foods.append(FoodLog(name: item.name, grams: grams, calories: item.calories * factor, protein: item.protein * factor))
    }
    func addCustomFood(_ name: String, calories: Double, protein: Double) {
        guard !name.isEmpty, calories >= 0, protein >= 0 else { return }
        foods.append(FoodLog(name: name, grams: 0, calories: calories, protein: protein))
    }
    func addWeight(_ kg: Double) {
        guard (30...350).contains(kg) else { return }
        weights.append(WeightLog(kg: kg))
        profile.weight = kg
    }
}
