import SwiftUI

/// Host app. macOS needs one to carry the widget; it only seeds the to-do file and says hello.
@main
struct BrooklynCountdownApp: App {
    init() { PlanStore.seedIfNeeded() }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 8) {
                Text("Brooklyn Countdown").font(.system(size: 26, design: .serif).italic())
                Text("Add the widget from your desktop: right-click, Edit Widgets, search Brooklyn.")
                    .font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            .padding(40)
            .frame(width: 420)
        }
        .windowResizability(.contentSize)
    }
}
