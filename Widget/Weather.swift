import Foundation

struct WeatherSnapshot {
    var sky: Sky
    var label: String
    var tempF: Int
}

/// Brooklyn weather from Open-Meteo (free, no key). Falls back to the last good reading, then a quiet overcast.
enum WeatherClient {
    private struct Response: Decodable {
        struct Current: Decodable {
            var temperature_2m: Double
            var weather_code: Int
            var is_day: Int
        }
        var current: Current
    }

    private static let defaults = UserDefaults.standard

    static func current() async -> WeatherSnapshot {
        if let fresh = await fetch() {
            defaults.set(fresh.sky.rawValue, forKey: "sky")
            defaults.set(fresh.label, forKey: "label")
            defaults.set(fresh.tempF, forKey: "temp")
            return fresh
        }
        if let raw = defaults.string(forKey: "sky"), let sky = Sky(rawValue: raw) {
            return WeatherSnapshot(sky: sky, label: defaults.string(forKey: "label") ?? "Overcast", tempF: defaults.integer(forKey: "temp"))
        }
        return WeatherSnapshot(sky: .fog, label: "Overcast", tempF: 55)
    }

    private static func fetch() async -> WeatherSnapshot? {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=40.693&longitude=-73.99&current=temperature_2m,weather_code,is_day&temperature_unit=fahrenheit&timezone=America%2FNew_York"
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let current = try JSONDecoder().decode(Response.self, from: data).current
            let mapped = Sky.from(code: current.weather_code, isDay: current.is_day == 1)
            return WeatherSnapshot(sky: mapped.sky, label: mapped.label, tempF: Int(current.temperature_2m.rounded()))
        } catch {
            return nil
        }
    }
}
