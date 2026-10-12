import SwiftUI

struct TrainView: View {
    @EnvironmentObject private var store: NoctisStore
    @State private var selected = "Incline dumbbell press"
    @State private var sets = "3"
    @State private var reps = "8"
    @State private var kg = "24"
    private let exercises = [
        "Incline dumbbell press", "Flat bench press", "Shoulder press",
        "Lateral raise", "Lat pulldown", "Chest-supported row", "Pull-up",
        "Biceps curl", "Triceps extension", "Squat", "Leg press",
        "Romanian deadlift", "Leg curl", "Calf raise", "Deadlift", "Other"
    ]
    var body: some View {
        NoctisPage("FORGED THROUGH REPETITION", "The iron.") {
            Panel {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TRAINING LOG").font(.system(size: 10, weight: .black)).tracking(2).foregroundStyle(N.cyan)
                        Text("\(store.todayLifts.reduce(0) { $0 + $1.sets })")
                            .font(.system(size: 65, weight: .bold, design: .rounded)).tracking(-3)
                        Text("SETS LOGGED TODAY").font(.system(size: 10, weight: .bold)).tracking(1.4).foregroundStyle(N.muted)
                    }
                    Spacer()
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 50, weight: .ultraLight)).foregroundStyle(N.cyan).padding(.top, 15)
                }
                HStack(spacing: 12) {
                    Metric(caption: "EXERCISES", value: "\(store.todayLifts.count)")
                    Metric(caption: "ALL-TIME SESSIONS", value: "\(Set(store.lifts.map { Calendar.current.startOfDay(for: $0.date) }).count)")
                }.padding(.top, 15)
            }
            SectionName(title: "ADD A SET BLOCK")
            Panel {
                VStack(alignment: .leading, spacing: 15) {
                    Text("EXERCISE").font(.system(size: 10, weight: .bold)).foregroundStyle(N.muted).tracking(1.5)
                    Picker("Exercise", selection: $selected) {
                        ForEach(exercises, id: \.self) { Text($0).tag($0) }
                    }.tint(N.white)
                    Divider().overlay(N.line)
                    HStack(spacing: 13) {
                        numberInput("SETS", text: $sets)
                        numberInput("REPS", text: $reps)
                        numberInput("KG", text: $kg)
                    }
                    PrimaryAction(title: "SAVE WORK", icon: "plus") {
                        guard let s = Int(sets), let r = Int(reps), let w = Double(kg),
                              (1...20).contains(s), (1...100).contains(r), (0...500).contains(w) else { return }
                        store.lifts.append(LiftLog(exercise: selected, sets: s, reps: r, kg: w))
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                }
            }
            SectionName(title: "RECENT WORK", detail: "\(store.lifts.count) ENTRIES")
            if store.lifts.isEmpty {
                Panel { Text("Your first logged set starts the record.").font(.system(size: 13)).foregroundStyle(N.muted) }
            } else {
                Panel {
                    ForEach(store.lifts.suffix(12).reversed()) { entry in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(N.cyan).font(.system(size: 17))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.exercise).font(.system(size: 13, weight: .semibold))
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(size: 10)).foregroundStyle(N.muted)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 3) {
                                Text("\(entry.sets) × \(entry.reps)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                Text("\(Int(entry.kg)) kg").font(.system(size: 11)).foregroundStyle(N.muted)
                            }
                        }.padding(.vertical, 6)
                    }
                }
            }
            Panel {
                HStack(alignment: .top, spacing: 13) {
                    Image(systemName: "figure.strengthtraining.traditional").font(.system(size: 22)).foregroundStyle(N.cyan)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TRAIN TO KEEP MUSCLE").font(.system(size: 12, weight: .heavy)).tracking(1)
                        Text("During a cut, prioritize progressive resistance training, protein and adequate recovery. This log tracks volume, not imaginary calories burned.")
                            .font(.system(size: 12)).foregroundStyle(N.muted)
                    }
                }
            }
        }
    }
    private func numberInput(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 10, weight: .heavy)).tracking(1.4).foregroundStyle(N.muted)
            TextField("0", text: text).keyboardType(.decimalPad)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .padding(12).background(N.bg, in: RoundedRectangle(cornerRadius: 13))
        }.frame(maxWidth: .infinity)
    }
}
