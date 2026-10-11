import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: BrooklynEntry

    private var phrase: CountdownPhrase { CountdownPhrase(daysLeft: entry.daysLeft) }
    private var visible: (shown: [Todo], later: Todo?) { entry.plan.visible(on: entry.date, limit: 3) }
    private let ink = Color(hex: 0x111111)
    private let muted = Color(hex: 0x6A6A66)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            countdown
                .padding(.horizontal, 18)
                .padding(.top, 18)

            BridgeScene(sky: entry.sky)
                .frame(maxWidth: .infinity, minHeight: 80, maxHeight: .infinity)
                .padding(.top, 4)

            todos
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 16)
        }
        .foregroundStyle(ink)
        .containerBackground(for: .widget) { entry.sky.gradient }
    }

    private var countdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 7) {
                if let word = phrase.word {
                    Text(word).font(.system(size: 38, weight: .regular, design: .serif).italic())
                } else {
                    if let pre = phrase.pre { caps(pre, size: 9.5) }
                    Text(phrase.number ?? "").font(.system(size: 58, weight: .regular, design: .serif).italic())
                    Text(phrase.unit ?? "").font(.system(size: 21, weight: .regular, design: .serif).italic())
                }
            }
            caps("Until Brooklyn · Dec 14", size: 9.5).padding(.top, 9)
            Text("\(entry.weatherLabel) · \(entry.tempF)°")
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(muted)
                .padding(.top, 7)
        }
    }

    @ViewBuilder
    private var todos: some View {
        let v = visible
        if v.shown.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text("Nothing pressing.").font(.system(size: 21, weight: .regular, design: .serif).italic())
                Text("Go get a bagel.").font(.system(size: 11, weight: .medium)).foregroundStyle(muted)
            }
            .padding(.top, 6)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                caps("Soon", size: 9.5, weight: .bold).padding(.bottom, 6)
                ForEach(v.shown) { todo in
                    Button(intent: ToggleTodoIntent(todoID: todo.id)) {
                        HStack(spacing: 9) {
                            Circle().strokeBorder(ink, lineWidth: 1.3).frame(width: 15, height: 15)
                            Text(todo.title).font(.system(size: 12, weight: .medium)).lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 5)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                if let later = v.later {
                    Text("Later: \(later.title.prefix(1).lowercased() + later.title.dropFirst())")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(muted)
                        .lineLimit(1)
                        .padding(.top, 8)
                }
            }
        }
    }

    private func caps(_ text: String, size: CGFloat, weight: Font.Weight = .semibold) -> some View {
        Text(text.uppercased()).font(.system(size: size, weight: weight)).tracking(size * 0.12)
    }
}
