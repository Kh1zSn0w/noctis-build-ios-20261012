import SwiftUI

struct WordEntry: Identifiable {
    let id: Int
    let text: String
    let arabic: String?
    let origin: String
    let category: String
}

struct WordsView: View {
    @State private var category = "ALL"
    @State private var index = 0
    private let entries: [WordEntry] = [
        .init(id: 0, text: "Allah does not change the condition of a people until they change what is in themselves.",
              arabic: "إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنْفُسِهِمْ",
              origin: "QUR'AN · AR-RA'D 13:11 · EXCERPT", category: "FAITH"),
        .init(id: 1, text: "And that each person will only have what they endeavoured towards.",
              arabic: "وَأَنْ لَيْسَ لِلْإِنْسَانِ إِلَّا مَا سَعَىٰ",
              origin: "QUR'AN · AN-NAJM 53:39", category: "FAITH"),
        .init(id: 2, text: "With hardship comes ease.",
              arabic: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
              origin: "QUR'AN · ASH-SHARH 94:6", category: "FAITH"),
        .init(id: 3, text: "Your mood is not in command. Your decisions are.",
              arabic: nil, origin: "NOCTIS · ORIGINAL", category: "DISCIPLINE"),
        .init(id: 4, text: "Build a life your impulses cannot overthrow.",
              arabic: nil, origin: "NOCTIS · ORIGINAL", category: "POWER"),
        .init(id: 5, text: "What you repeat is what you become. Choose the repetition.",
              arabic: nil, origin: "NOCTIS · ORIGINAL", category: "DISCIPLINE"),
        .init(id: 6, text: "Never mistake a quiet season for a wasted one. Sharpen the blade.",
              arabic: nil, origin: "NOCTIS · ORIGINAL", category: "POWER"),
        .init(id: 7, text: "You are allowed to be tired. You are not obliged to surrender.",
              arabic: nil, origin: "NOCTIS · ORIGINAL", category: "DISCIPLINE"),
        .init(id: 8, text: "And those who strive for Us, We will surely guide them to Our ways.",
              arabic: "وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا",
              origin: "QUR'AN · AL-'ANKABUT 29:69 · EXCERPT", category: "FAITH"),
        .init(id: 9, text: "A stronger future is purchased with smaller choices nobody sees.",
              arabic: nil, origin: "NOCTIS · ORIGINAL", category: "POWER"),
        .init(id: 10, text: "Let them see the result. Not the negotiations it took to get there.",
              arabic: nil, origin: "NOCTIS · ORIGINAL", category: "POWER")
    ]
    private var filtered: [WordEntry] { category == "ALL" ? entries : entries.filter { $0.category == category } }
    private var shown: WordEntry { filtered[index % filtered.count] }

    var body: some View {
        NoctisPage("WORDS WORTH CARRYING", "The code.") {
            HStack(spacing: 8) {
                ForEach(["ALL", "FAITH", "DISCIPLINE", "POWER"], id: \.self) { cat in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) { category = cat; index = 0 }
                    } label: {
                        Text(cat).font(.system(size: 10, weight: .heavy)).tracking(0.5)
                            .foregroundStyle(cat == category ? .white : N.muted)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(cat == category ? N.blue : N.panel, in: RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain)
                }
            }
            Panel {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("NOCTIS / \(shown.category)").font(.system(size: 10, weight: .black)).tracking(1.8).foregroundStyle(N.cyan)
                        Spacer()
                        Image(systemName: "quote.opening").font(.system(size: 20)).foregroundStyle(N.cyan)
                    }
                    if let arabic = shown.arabic {
                        Text(arabic).font(.system(size: 31, weight: .semibold))
                            .multilineTextAlignment(.center).frame(maxWidth: .infinity)
                            .environment(\.layoutDirection, .rightToLeft)
                            .padding(.vertical, 18)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(shown.text)
                        .font(.system(size: shown.arabic == nil ? 31 : 22, weight: .semibold, design: .serif))
                        .tracking(-0.4).fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, minHeight: shown.arabic == nil ? 245 : 110, alignment: .center)
                        .multilineTextAlignment(.center)
                    Rectangle().fill(N.blue).frame(width: 42, height: 3)
                    Text(shown.origin)
                        .font(.system(size: 10, weight: .heavy)).tracking(1.1).foregroundStyle(N.muted)
                    PrimaryAction(title: "ANOTHER LINE", icon: "arrow.right") {
                        withAnimation(.easeInOut(duration: 0.22)) { index += 1 }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }.padding(.vertical, 10)
            }
            HStack {
                Text("\(index % filtered.count + 1) / \(filtered.count)")
                    .font(.system(size: 11, weight: .bold)).monospacedDigit().foregroundStyle(N.muted)
                Spacer()
                Text("POWER IS PRACTICED").font(.system(size: 10, weight: .heavy)).tracking(1.3).foregroundStyle(N.cyan)
            }.padding(.horizontal, 4)
            Text("Scripture excerpts are attributed. All other lines are original NOCTIS writing, not historical quotations.")
                .font(.system(size: 11)).foregroundStyle(N.muted)
        }
    }
}
