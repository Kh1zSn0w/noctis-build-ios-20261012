import SwiftUI
import Combine

struct FocusView: View {
    @EnvironmentObject private var store: NoctisStore
    @State private var chosen = 20
    @State private var remaining = 20 * 60
    @State private var running = false
    @State private var completed = false
    @State private var phase = 0
    private let ticks = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let phases = [
        ("01", "LOWER THE NOISE", "Remove short-form feeds from your home screen. Disable nonessential notifications."),
        ("02", "REBUILD FRICTION", "No phone for the first 30 minutes after waking. Keep it outside your work space."),
        ("03", "TRAIN SUSTAINED WORK", "Single-task for 10–30 minutes. Read, study, code or train without switching."),
        ("04", "LEARN TO BE BORED", "Take one walk without headphones or a screen. Let attention settle."),
        ("05", "PROTECT THE BASE", "Consistent sleep, movement, daylight and real-world contact matter more than hacks.")
    ]
    var body: some View {
        NoctisPage("ATTENTION IS A MUSCLE", "Reclaim focus.") {
            Panel {
                VStack(alignment: .leading, spacing: 18) {
                    Text("DEEP WORK / TIMER").font(.system(size: 10, weight: .heavy)).tracking(1.9).foregroundStyle(N.cyan)
                    Text(String(format: "%02d:%02d", remaining / 60, remaining % 60))
                        .font(.system(size: 65, weight: .thin, design: .rounded)).monospacedDigit()
                    ProgressTrack(percent: Double(chosen * 60 - remaining) / Double(chosen * 60))
                    HStack(spacing: 9) {
                        ForEach([10, 20, 30], id: \.self) { minute in
                            Button {
                                guard !running else { return }
                                chosen = minute
                                remaining = minute * 60
                                completed = false
                            } label: {
                                Text("\(minute) MIN")
                                    .font(.system(size: 11, weight: .heavy)).tracking(0.8)
                                    .frame(maxWidth: .infinity).frame(height: 41)
                                    .background(chosen == minute ? N.blue : N.panel, in: RoundedRectangle(cornerRadius: 12))
                            }.buttonStyle(.plain)
                        }
                    }
                    PrimaryAction(title: running ? "PAUSE SESSION" : (remaining == chosen * 60 ? "START FOCUS" : "RESUME FOCUS"),
                                  icon: running ? "pause.fill" : "play.fill") { running.toggle() }
                    if !running && remaining < chosen * 60 {
                        Button("Reset timer") { remaining = chosen * 60; completed = false }
                            .font(.system(size: 11, weight: .bold)).foregroundStyle(N.muted)
                    }
                }
            }
            HStack(spacing: 12) {
                Panel { Metric(caption: "MINUTES TODAY", value: "\(store.focusToday)") }
                Panel { Metric(caption: "TOTAL HOURS", value: String(format: "%.1f", Double(store.focusTotal) / 60)) }
            }
            SectionName(title: "THE ATTENTION REBUILD", detail: "FIVE PRACTICES")
            Panel {
                VStack(alignment: .leading, spacing: 9) {
                    ForEach(phases.indices, id: \.self) { idx in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) { phase = idx }
                        } label: {
                            HStack(alignment: .top, spacing: 11) {
                                Text(phases[idx].0).font(.system(size: 12, weight: .heavy))
                                    .foregroundStyle(phase == idx ? N.cyan : N.muted).frame(width: 24)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(phases[idx].1).font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(N.white)
                                    if phase == idx {
                                        Text(phases[idx].2).font(.system(size: 12)).foregroundStyle(N.muted)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                Spacer()
                                Image(systemName: phase == idx ? "minus" : "plus")
                                    .font(.system(size: 11, weight: .bold)).foregroundStyle(N.muted)
                            }.padding(.vertical, 8)
                        }.buttonStyle(.plain)
                        if idx != phases.count - 1 { Divider().overlay(N.line) }
                    }
                }
            }
            Panel {
                Text("NO INSTANT REWIRING. REAL ADAPTATION.")
                    .font(.system(size: 11, weight: .heavy)).tracking(1.2).foregroundStyle(N.cyan)
                Text("Attention can improve with repeated practice, better sleep and less interruption. There is no medically established fastest brain-reset timetable. Start small, repeat daily.")
                    .font(.system(size: 13)).foregroundStyle(N.muted).padding(.top, 9)
            }
        }
        .onReceive(ticks) { _ in
            if running && remaining > 0 {
                remaining -= 1
                if remaining == 0 {
                    running = false
                    store.focus.append(FocusLog(minutes: chosen))
                    completed = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
        .alert("FOCUS COMPLETE", isPresented: $completed) {
            Button("Done") { remaining = chosen * 60 }
        } message: { Text("Another distraction-free session logged.") }
    }
}
