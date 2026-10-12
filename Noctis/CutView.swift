import SwiftUI

struct CutView: View {
    @EnvironmentObject private var store: NoctisStore
    @State private var showQuiz = false
    @State private var targetProtein = 150.0
    var body: some View {
        NoctisPage("STRATEGY OVER STARVATION", "The cut.") {
            Panel {
                HStack(alignment: .top, spacing: 18) {
                    Button { showQuiz = true } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 23).fill(N.blue.opacity(0.30)).frame(width: 106, height: 119)
                            Image(systemName: "skull.fill").font(.system(size: 64, weight: .ultraLight))
                                .foregroundStyle(N.white)
                            Image(systemName: "arrow.up.right.circle.fill")
                                .font(.system(size: 21)).foregroundStyle(N.cyan)
                                .offset(x: 42, y: -50)
                        }
                    }.buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CUT PROTOCOL / 01").font(.system(size: 10, weight: .black)).tracking(1.5).foregroundStyle(N.cyan)
                        Text("Define the deficit.").font(.system(size: 22, weight: .heavy, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Tap the skull to answer the cut assessment and set a sustainable aggressive target.")
                            .font(.system(size: 12)).foregroundStyle(N.muted).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            SectionName(title: "YOUR DAILY PROTOCOL")
            Panel {
                VStack(alignment: .leading, spacing: 19) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("DAILY CALORIE TARGET").font(.system(size: 10, weight: .heavy)).tracking(1.7).foregroundStyle(N.muted)
                            Text("\(Int(store.calorieGoal))").font(.system(size: 55, weight: .bold, design: .rounded))
                                .monospacedDigit().tracking(-2)
                            Text("kcal / day").font(.system(size: 11)).foregroundStyle(N.muted)
                        }
                        Spacer()
                        Image(systemName: "scope").font(.system(size: 49, weight: .ultraLight)).foregroundStyle(N.cyan)
                    }
                    Divider().overlay(N.line)
                    HStack {
                        Metric(caption: "TDEE", value: "\(Int(store.tdee))", unit: "kcal")
                        Metric(caption: "PLANNED GAP", value: "\(Int(store.tdee - store.calorieGoal))", unit: "kcal")
                    }
                    ProgressTrack(percent: store.todayIntake / max(1, store.calorieGoal))
                    HStack {
                        Text("TODAY'S INTAKE").font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(N.muted)
                        Spacer()
                        Text("\(Int(store.todayIntake)) / \(Int(store.calorieGoal))")
                            .font(.system(size: 12, weight: .bold, design: .rounded)).monospacedDigit()
                    }
                }
            }
            SectionName(title: "DEFICIT INTENSITY", detail: "\(Int(store.profile.cutPercent * 100))%")
            Panel {
                VStack(alignment: .leading, spacing: 11) {
                    Slider(value: $store.profile.cutPercent, in: 0.10...0.25, step: 0.01).tint(N.cyan)
                    HStack {
                        Text("STEADY · 10%"); Spacer(); Text("DEMANDING · 25%")
                    }.font(.system(size: 9, weight: .heavy)).tracking(0.5).foregroundStyle(N.muted)
                    Text("Do not chase the lowest possible calories. A larger deficit can compromise recovery, concentration and training.")
                        .font(.system(size: 12)).foregroundStyle(N.muted)
                }
            }
            SectionName(title: "NON-NEGOTIABLES")
            Panel {
                protocolLine("01", "Lift and retain strength", "Resistance training 3–5 days weekly, recover between hard sessions.")
                Divider().overlay(N.line)
                protocolLine("02", "Keep protein consistent", "Spread your daily protein across meals.")
                Divider().overlay(N.line)
                protocolLine("03", "Measure weekly trends", "Compare 7-day averages, not one scale reading.")
                Divider().overlay(N.line)
                protocolLine("04", "Protect sleep", "Extreme restriction and sleep loss are not a shortcut.")
            }
            Panel {
                Label("SAFETY LIMIT", systemImage: "cross.circle.fill")
                    .font(.system(size: 11, weight: .heavy)).tracking(1).foregroundStyle(N.amber)
                Text("Targets are general estimates, not medical prescriptions. Seek clinical guidance for faster loss, medication use, faintness, dizziness, or a history of disordered eating. Avoid drastic restriction.")
                    .font(.system(size: 12)).foregroundStyle(N.muted).padding(.top, 5)
            }
        }.sheet(isPresented: $showQuiz) { CutQuiz() }
    }
    private func protocolLine(_ num: String, _ title: String, _ sub: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(num).font(.system(size: 12, weight: .heavy)).foregroundStyle(N.cyan).frame(width: 25)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 14, weight: .bold))
                Text(sub).font(.system(size: 12)).foregroundStyle(N.muted)
            }
        }.padding(.vertical, 6)
    }
}

struct CutQuiz: View {
    @EnvironmentObject private var store: NoctisStore
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var sleep = 1
    @State private var training = 1
    @State private var dietHistory = 1
    @State private var appetite = 1
    @State private var weeks = 1
    private let questions: [(String, String, [String])] = [
        ("HOW IS YOUR SLEEP?", "Recovery dictates how hard you can push.",
         ["Under 6 hours / poor", "6–7 hours / variable", "7–9 hours / consistent"]),
        ("ARE YOU LIFTING?", "Muscle retention comes first.",
         ["Not consistently", "2–3 sessions weekly", "4+ sessions weekly"]),
        ("RECENT DIETING?", "Repeated restriction increases fatigue and food preoccupation.",
         ["Exhausted / frequent crashes", "Mixed consistency", "Currently well recovered"]),
        ("HUNGER CONTROL?", "A harsh cut is not a test of willpower.",
         ["Often overwhelming", "Manageable", "Usually stable"]),
        ("TIME HORIZON?", "Slower plans are easier to sustain.",
         ["Under 4 weeks", "4–8 weeks", "More than 8 weeks"])
    ]
    private var answers: [Int] { [sleep, training, dietHistory, appetite, weeks] }
    private var recommendation: Double {
        if sleep == 0 || dietHistory == 0 || appetite == 0 { return 0.12 }
        let total = answers.reduce(0, +)
        return total >= 8 ? 0.23 : total >= 6 ? 0.20 : 0.16
    }
    var body: some View {
        ZStack {
            N.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 23) {
                HStack {
                    Text("NOCTIS / CUT ASSESSMENT").font(.system(size: 10, weight: .heavy)).tracking(2).foregroundStyle(N.cyan)
                    Spacer()
                    Button { dismiss() } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 25)).foregroundStyle(N.muted) }
                }
                ProgressTrack(percent: Double(step + 1) / 6)
                if step < questions.count {
                    Text("0\(step + 1) / 05").font(.system(size: 11, weight: .heavy)).foregroundStyle(N.muted)
                    Text(questions[step].0).font(.system(size: 37, weight: .black, design: .rounded))
                    Text(questions[step].1).font(.system(size: 15)).foregroundStyle(N.muted)
                    VStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { idx in
                            Button {
                                switch step {
                                case 0: sleep = idx
                                case 1: training = idx
                                case 2: dietHistory = idx
                                case 3: appetite = idx
                                default: weeks = idx
                                }
                            } label: {
                                HStack {
                                    Text(questions[step].2[idx]).font(.system(size: 14, weight: .semibold))
                                    Spacer()
                                    Image(systemName: answers[step] == idx ? "largecircle.fill.circle" : "circle")
                                        .foregroundStyle(answers[step] == idx ? N.cyan : N.muted)
                                }.padding(18)
                                    .background(answers[step] == idx ? N.blue.opacity(0.27) : N.panel,
                                                in: RoundedRectangle(cornerRadius: 18))
                            }.buttonStyle(.plain)
                        }
                    }
                } else {
                    Text("YOUR PROTOCOL").font(.system(size: 36, weight: .black, design: .rounded))
                    Text("Suggested starting deficit").font(.system(size: 14)).foregroundStyle(N.muted)
                    Text("\(Int(recommendation * 100))%").font(.system(size: 73, weight: .bold, design: .rounded))
                        .foregroundStyle(N.cyan)
                    Text("\(Int(max(store.profile.sex == "Male" ? 1500 : 1200, store.tdee * (1 - recommendation)))) kcal / day")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("This is an initial estimate, not a personalized clinical assessment. Reassess after 2–4 weeks. If sleep, hunger, or mood worsen, ease the deficit.")
                        .font(.system(size: 14)).foregroundStyle(N.muted)
                }
                Spacer()
                PrimaryAction(title: step < 5 ? "CONTINUE" : "APPLY MY PLAN", icon: step < 5 ? "arrow.right" : "checkmark") {
                    if step < 5 { withAnimation(.easeInOut(duration: 0.24)) { step += 1 } }
                    else { store.profile.cutPercent = recommendation; dismiss() }
                }
                if step > 0 && step < 6 {
                    Button("Back") { withAnimation { step -= 1 } }
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(N.muted).frame(maxWidth: .infinity)
                }
            }.padding(26).padding(.top, 15).padding(.bottom, 15)
        }.preferredColorScheme(.dark)
    }
}
