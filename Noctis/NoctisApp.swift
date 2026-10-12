import SwiftUI

@main struct NoctisApp: App {
    @StateObject private var store = NoctisStore()
    var body: some Scene {
        WindowGroup {
            AppRoot().environmentObject(store).preferredColorScheme(.dark)
        }
    }
}

enum AppSection: String, CaseIterable {
    case today = "Today", train = "Train", cut = "Cut", relapse = "Relapse", focus = "Focus", words = "Words"
    var symbol: String {
        switch self {
        case .today: "square.grid.2x2.fill"
        case .train: "dumbbell.fill"
        case .cut: "flame.fill"
        case .relapse: "shield.lefthalf.filled"
        case .focus: "scope"
        case .words: "quote.opening"
        }
    }
}

struct AppRoot: View {
    @State private var tab: AppSection = .today
    var body: some View {
        ZStack {
            N.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "hand.raised.fingers.spread.fill")
                        .foregroundStyle(N.cyan).font(.system(size: 13, weight: .semibold))
                    Text("N O C T I S").font(.system(size: 12, weight: .black, design: .rounded)).tracking(2).foregroundStyle(N.white)
                    Spacer()
                    Circle().fill(N.blue).frame(width: 5, height: 5)
                    Text("DO THE WORK").font(.system(size: 9, weight: .heavy)).tracking(1.6).foregroundStyle(N.muted)
                }.padding(.horizontal, 22).frame(height: 40)
                Group {
                    switch tab {
                    case .today: TodayView()
                    case .train: TrainView()
                    case .cut: CutView()
                    case .relapse: RelapseView()
                    case .focus: FocusView()
                    case .words: WordsView()
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(tab)
                    .transition(.opacity.combined(with: .offset(y: 9)))
                dock
            }
        }.tint(N.cyan)
    }
    private var dock: some View {
        HStack(spacing: 0) {
            ForEach(AppSection.allCases, id: \.self) { item in
                Button {
                    withAnimation(.easeOut(duration: 0.21)) { tab = item }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 19, weight: tab == item ? .semibold : .regular))
                            .symbolRenderingMode(.hierarchical)
                            .frame(height: 23)
                        Text(item.rawValue.uppercased()).font(.system(size: 8, weight: .heavy)).tracking(0.4)
                    }.foregroundStyle(tab == item ? N.white : N.muted)
                        .frame(maxWidth: .infinity).frame(height: 57)
                        .background {
                            if tab == item { RoundedRectangle(cornerRadius: 17).fill(N.blue.opacity(0.42)) }
                        }
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6).padding(.vertical, 6)
        .noctisGlass(24).padding(.horizontal, 11)
        .padding(.bottom, 3)
        .background(N.bg.opacity(0.96))
    }
}
