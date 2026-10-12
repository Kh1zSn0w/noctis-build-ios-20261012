import SwiftUI

enum N {
    static let bg = Color(red: 0.018, green: 0.028, blue: 0.056)
    static let panel = Color(red: 0.042, green: 0.066, blue: 0.125)
    static let blue = Color(red: 0.16, green: 0.39, blue: 0.92)
    static let cyan = Color(red: 0.46, green: 0.69, blue: 1)
    static let muted = Color(red: 0.57, green: 0.64, blue: 0.75)
    static let line = Color.white.opacity(0.095)
    static let white = Color(red: 0.94, green: 0.96, blue: 1)
    static let amber = Color(red: 1, green: 0.74, blue: 0.36)
}

extension View {
    @ViewBuilder func noctisGlass(_ radius: CGFloat = 24) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(N.blue.opacity(0.13)), in: .rect(cornerRadius: radius))
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(N.line, lineWidth: 0.75))
        } else {
            self.background(N.panel.opacity(0.92), in: RoundedRectangle(cornerRadius: radius))
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(N.line, lineWidth: 0.75))
        }
    }
}

struct Panel<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
    var body: some View { content.padding(19).frame(maxWidth: .infinity, alignment: .leading).noctisGlass(24) }
}

struct SectionName: View {
    var title: String
    var detail: String? = nil
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.uppercased()).font(.system(size: 11, weight: .heavy, design: .rounded)).tracking(2.0).foregroundStyle(N.muted)
            Spacer()
            if let detail { Text(detail).font(.system(size: 11, weight: .medium)).foregroundStyle(N.muted) }
        }.padding(.horizontal, 2)
    }
}

struct PrimaryAction: View {
    let title: String
    var icon: String = "arrow.up.right"
    var destructive: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title.uppercased()).font(.system(size: 13, weight: .black, design: .rounded)).tracking(1.15)
                Spacer()
                Image(systemName: icon).font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(.white).padding(.horizontal, 19).frame(height: 53)
            .background(destructive ? Color(red: 0.48, green: 0.15, blue: 0.20) : N.blue, in: RoundedRectangle(cornerRadius: 17))
        }.buttonStyle(.plain)
    }
}

struct Metric: View {
    let caption: String
    let value: String
    var unit: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(caption.uppercased()).tracking(1.4).font(.system(size: 10, weight: .bold)).foregroundStyle(N.muted)
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(value).font(.system(size: 28, weight: .bold, design: .rounded)).monospacedDigit()
                Text(unit).font(.system(size: 11, weight: .medium)).foregroundStyle(N.muted)
            }.minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProgressTrack: View {
    var percent: Double
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule().fill(N.blue).frame(width: max(0, g.size.width * min(1, max(0, percent))))
            }
        }.frame(height: 7).accessibilityLabel("Progress \(Int(max(0, min(1, percent)) * 100)) percent")
    }
}

struct NoctisPage<Content: View>: View {
    let kicker: String
    let title: String
    let content: Content
    init(_ kicker: String, _ title: String, @ViewBuilder content: () -> Content) {
        self.kicker = kicker; self.title = title; self.content = content()
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(kicker.uppercased()).font(.system(size: 10, weight: .heavy)).tracking(3).foregroundStyle(N.cyan)
                    Text(title).font(.system(size: 39, weight: .bold, design: .rounded)).tracking(-1.8).foregroundStyle(N.white)
                }.padding(.top, 14)
                content
            }.padding(.horizontal, 20).padding(.bottom, 35)
        }
    }
}

struct NumberField: View {
    var label: String
    @Binding var text: String
    var suffix: String
    var body: some View {
        HStack {
            Text(label).font(.system(size: 13, weight: .semibold)).foregroundStyle(N.white)
            Spacer()
            TextField("0", text: $text).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .foregroundStyle(N.white).frame(width: 90)
            Text(suffix).font(.system(size: 12)).foregroundStyle(N.muted).frame(width: 36, alignment: .trailing)
        }.padding(.vertical, 9)
    }
}
