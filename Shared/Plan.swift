import Foundation

struct Todo: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var done: Bool = false
    /// yyyy-MM-dd. Before this date the item stays out of sight.
    var showFrom: String?
}

struct Plan: Codable {
    var moveDate: String
    var todos: [Todo]

    static let starter = Plan(moveDate: "2026-12-14", todos: [
        Todo(id: "tours", title: "Book video building tours"),
        Todo(id: "cats", title: "Ask about cat fees"),
        Todo(id: "movers", title: "Pick movers or shipping", showFrom: "2026-11-02"),
        Todo(id: "notice", title: "Give notice on SF lease", showFrom: "2026-11-02"),
        Todo(id: "mail", title: "Set up mail forwarding", showFrom: "2026-11-23"),
        Todo(id: "travel", title: "Plan the cats' travel day", showFrom: "2026-11-23"),
    ])

    var moveDateValue: Date { DayFormat.date(moveDate) ?? .now }

    /// Up to `limit` near items, plus the next undone item after them (shown as one quiet "Later" line).
    func visible(on day: Date, limit: Int) -> (shown: [Todo], later: Todo?) {
        let open = todos.filter { !$0.done }
        let near = open.filter { todo in
            guard let from = todo.showFrom, let date = DayFormat.date(from) else { return true }
            return date <= day
        }
        let shown = Array(near.prefix(limit))
        let later = open.first { candidate in !shown.contains(where: { $0.id == candidate.id }) }
        return (shown, later)
    }
}

enum DayFormat {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    static func date(_ string: String) -> Date? { formatter.date(from: string) }
}

/// The plan lives in a plain file so the widget, the host app and Claude can all edit it.
/// Both targets are sandboxed, so they reach it through a home-relative-path entitlement.
enum PlanStore {
    static var directory: URL {
        let home: String
        if let entry = getpwuid(getuid()), let dir = entry.pointee.pw_dir {
            home = String(cString: dir)
        } else {
            home = NSHomeDirectory()
        }
        return URL(fileURLWithPath: home).appendingPathComponent(".brooklyn-countdown", isDirectory: true)
    }
    static var fileURL: URL { directory.appendingPathComponent("todos.json") }

    /// TEMPORARY diagnostics: appended to ~/.brooklyn-countdown/debug.log. Remove once ticking is confirmed.
    static func log(_ message: String) {
        let line = "\(Date()) [\(ProcessInfo.processInfo.processName)] \(message)\n"
        let url = directory.appendingPathComponent("debug.log")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(Data(line.utf8))
            try? handle.close()
        } else {
            try? line.write(to: url, atomically: false, encoding: .utf8)
        }
    }

    static func load() -> Plan {
        let data: Data
        do { data = try Data(contentsOf: fileURL) } catch {
            log("load FAILED to read \(fileURL.path): \(error)")
            return .starter
        }
        guard let plan = try? JSONDecoder().decode(Plan.self, from: data) else {
            log("load FAILED to decode")
            return .starter
        }
        log("load ok, \(plan.todos.filter { !$0.done }.count) open")
        return plan
    }

    static func save(_ plan: Plan) {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            try encoder.encode(plan).write(to: fileURL, options: .atomic)
            log("save ok")
        } catch {
            log("save FAILED: \(error)")
        }
    }

    static func seedIfNeeded() {
        if !FileManager.default.fileExists(atPath: fileURL.path) { save(.starter) }
    }

    static func toggle(_ id: String) {
        log("toggle requested for \(id)")
        var plan = load()
        guard let index = plan.todos.firstIndex(where: { $0.id == id }) else { log("toggle: id not found"); return }
        plan.todos[index].done.toggle()
        save(plan)
    }
}

struct CountdownPhrase {
    var pre: String?
    var number: String?
    var unit: String?
    var word: String?

    /// "about 9 weeks" until two weeks out, then plain days. Never a ticking clock.
    init(daysLeft d: Int) {
        if d > 14 { pre = "about"; number = String(Int((Double(d) / 7).rounded())); unit = "weeks" }
        else if d > 1 { number = String(d); unit = "days" }
        else if d == 1 { word = "tomorrow" }
        else { word = "today" }
    }
}

enum Countdown {
    static func daysLeft(to moveDate: Date, from now: Date = .now) -> Int {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: cal.startOfDay(for: moveDate)).day ?? 0
        return max(0, days)
    }
}
