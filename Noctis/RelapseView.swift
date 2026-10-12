import SwiftUI
import Combine

struct RelapseView: View {
    @EnvironmentObject private var store: NoctisStore
    @State private var rescuing = false
    @State private var showSlip = false
    var body: some View {
        NoctisPage("BREAK THE AUTOMATIC LOOP", "Take control.") {
            Panel {
                VStack(alignment: .leading, spacing: 16) {
                    Label("THE NEXT 90 SECONDS", systemImage: "shield.fill")
                        .font(.system(size: 10, weight: .black)).tracking(1.7).foregroundStyle(N.cyan)
                    Text("An urge is a signal.\nNot an order.")
                        .font(.system(size: 31, weight: .heavy, design: .rounded))
                        .tracking(-0.7).fixedSize(horizontal: false, vertical: true)
                    Text("When you feel pulled toward porn, compulsive scrolling, or another habit, interrupt the pattern before you negotiate with it.")
                        .font(.system(size: 13)).foregroundStyle(N.muted).fixedSize(horizontal: false, vertical: true)
                    PrimaryAction(title: "I'M TEMPTED", icon: "hand.raised.fill") { rescuing = true }
                }
            }
            SectionName(title: "RECOVERY LEDGER")
            HStack(spacing: 12) {
                Panel { Metric(caption: "URGES INTERRUPTED", value: "\(store.resistanceCount)") }
                Panel { Metric(caption: "TIMES YOU CHECKED IN", value: "\(store.urges.count)") }
            }
            SectionName(title: "INTERRUPT THE TRIGGER")
            Panel {
                tip("01", "Leave the room.", "Change your physical environment before the urge gets stronger.")
                Divider().overlay(N.line)
                tip("02", "Remove frictionless access.", "Put the phone across the room; use built-in Screen Time limits or content restrictions.")
                Divider().overlay(N.line)
                tip("03", "Choose a replacement.", "Walk, shower, pray, stretch, or contact a trusted person.")
                Divider().overlay(N.line)
                tip("04", "Reset without shame.", "A slip is data. Record the trigger and plan the next interruption.")
            }
            Button { showSlip = true } label: {
                HStack {
                    Text("LOG A SLIP / RESET")
                    Spacer()
                    Image(systemName: "square.and.pencil")
                }.font(.system(size: 11, weight: .heavy)).tracking(1).foregroundStyle(N.muted)
                    .padding(17).noctisGlass(15)
            }.buttonStyle(.plain)
            Text("This is a self-help tool, not a treatment. If compulsive behavior seriously affects daily life, consider qualified professional support.")
                .font(.system(size: 11)).foregroundStyle(N.muted)
        }
        .fullScreenCover(isPresented: $rescuing) { UrgeRescue() }
        .confirmationDialog("A slip does not erase progress.", isPresented: $showSlip) {
            Button("Record slip and restart") { store.urges.append(UrgeLog(trigger: "Self-reported slip", interrupted: false)) }
            Button("Cancel", role: .cancel) { }
        } message: { Text("Observe what happened without self-punishment. The next action matters.") }
    }
    private func tip(_ n: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Text(n).font(.system(size: 11, weight: .black)).foregroundStyle(N.cyan).frame(width: 26)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 14, weight: .semibold))
                Text(text).font(.system(size: 12)).foregroundStyle(N.muted).fixedSize(horizontal: false, vertical: true)
            }
        }.padding(.vertical, 7)
    }
}

struct UrgeRescue: View {
    @EnvironmentObject private var store: NoctisStore
    @Environment(\.dismiss) private var dismiss
    @State private var remaining = 90
    @State private var active = false
    @State private var trigger = "Adult content"
    @State private var beat = false
    private let ticks = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            N.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 21) {
                HStack {
                    Text("THE INTERRUPTION").font(.system(size: 11, weight: .black)).tracking(2.1).foregroundStyle(N.cyan)
                    Spacer()
                    Button { dismiss() } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 27)).foregroundStyle(N.muted) }
                }
                Spacer(minLength: 0)
                Text("DO NOT\nNEGOTIATE.")
                    .font(.system(size: 48, weight: .black, design: .rounded)).tracking(-2)
                    .minimumScaleFactor(0.7).fixedSize(horizontal: false, vertical: true)
                Text("Put the phone down. Feet on the floor. Breathe slowly. Let the feeling crest and fall.")
                    .font(.system(size: 15)).foregroundStyle(N.muted)
                HStack {
                    Spacer()
                    ZStack {
                        Circle().stroke(N.blue.opacity(0.22), lineWidth: 1)
                            .frame(width: 242, height: 242)
                        Circle().stroke(N.blue.opacity(0.40), lineWidth: 1)
                            .frame(width: 207, height: 207)
                        Circle().fill(N.blue.opacity(0.14))
                            .frame(width: 170, height: 170)
                            .scaleEffect(beat ? 1.1 : 0.78)
                        VStack(spacing: 5) {
                            Text("\(remaining)").font(.system(size: 73, weight: .thin, design: .rounded))
                                .monospacedDigit()
                            Text("SECONDS").font(.system(size: 10, weight: .black)).tracking(2.0).foregroundStyle(N.cyan)
                        }
                    }.padding(.vertical, 15)
                    Spacer()
                }
                ProgressTrack(percent: Double(90 - remaining) / 90)
                Text(remaining > 60 ? "PHASE 1  /  BREATHE OUT LONGER THAN IN" :
                    remaining > 30 ? "PHASE 2  /  STAND AND CHANGE ROOMS" :
                    "PHASE 3  /  CHOOSE THE NEXT GOOD ACTION")
                    .font(.system(size: 10, weight: .heavy)).tracking(1.15).foregroundStyle(N.cyan)
                    Picker("Trigger", selection: $trigger) {
                        Text("Adult content").tag("Adult content")
                        Text("Compulsive scrolling").tag("Compulsive scrolling")
                        Text("Other impulse").tag("Other impulse")
                    }.pickerStyle(.segmented)
                    .font(.system(size: 11))
                Spacer(minLength: 0)
                if !active && remaining == 90 {
                    PrimaryAction(title: "START 90-SECOND RESET", icon: "play.fill") {
                        active = true
                        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { beat = true }
                    }
                } else if remaining > 0 {
                    PrimaryAction(title: "PAUSE / RESUME", icon: active ? "pause.fill" : "play.fill") { active.toggle() }
                } else {
                    PrimaryAction(title: "I INTERRUPTED THE URGE", icon: "checkmark.shield.fill") {
                        store.urges.append(UrgeLog(trigger: trigger, interrupted: true))
                        dismiss()
                    }
                }
                Text("If the urge persists, restart the reset and contact someone supportive. You choose your next action.")
                    .font(.system(size: 11)).foregroundStyle(N.muted)
                    .multilineTextAlignment(.center).frame(maxWidth: .infinity)
            }.padding(25).padding(.vertical, 20)
        }
        .onReceive(ticks) { _ in
            if active && remaining > 0 { remaining -= 1 }
            if remaining == 0 { active = false }
        }
        .preferredColorScheme(.dark)
    }
}
