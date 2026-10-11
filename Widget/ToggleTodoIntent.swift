import AppIntents
import WidgetKit

/// Runs when a circle in the widget is tapped. Flips the item in todos.json and refreshes.
struct ToggleTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "Tick off a to-do"
    static var isDiscoverable: Bool { false }

    @Parameter(title: "To-do ID")
    var todoID: String

    init() {}
    init(todoID: String) { self.todoID = todoID }

    func perform() async throws -> some IntentResult {
        PlanStore.toggle(todoID)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
