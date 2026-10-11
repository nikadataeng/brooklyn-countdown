import SwiftUI
import WidgetKit

struct BrooklynEntry: TimelineEntry {
    let date: Date
    let plan: Plan
    let sky: Sky
    let weatherLabel: String
    let tempF: Int

    var daysLeft: Int { Countdown.daysLeft(to: plan.moveDateValue, from: date) }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BrooklynEntry {
        BrooklynEntry(date: .now, plan: .starter, sky: .clear, weatherLabel: "Clear", tempF: 61)
    }

    func getSnapshot(in context: Context, completion: @escaping (BrooklynEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BrooklynEntry>) -> Void) {
        Task {
            let weather = await WeatherClient.current()
            let plan = PlanStore.load()
            let now = Date()
            let entry = BrooklynEntry(date: now, plan: plan, sky: weather.sky, weatherLabel: weather.label, tempF: weather.tempF)
            // Refresh every 30 minutes for weather, or at midnight if that comes first so the countdown rolls over.
            let midnight = Calendar.current.nextDate(after: now, matching: DateComponents(hour: 0, minute: 1), matchingPolicy: .nextTime) ?? now.addingTimeInterval(1800)
            let next = min(now.addingTimeInterval(1800), midnight)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }
}

@main
struct BrooklynCountdownWidget: Widget {
    let kind = "BrooklynCountdown"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LargeWidgetView(entry: entry)
        }
        .configurationDisplayName("Brooklyn Countdown")
        .description("A calm countdown to the move, with a few things to tick off.")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}
