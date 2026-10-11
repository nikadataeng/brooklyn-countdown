import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

/// The five moods from the mockup. Muted film tones, one drawing, one weather word.
enum Sky: String {
    case clear, rain, snow, fog, dusk

    var gradient: LinearGradient {
        let stops: [UInt32]
        switch self {
        case .clear: stops = [0xFCFBF7, 0xF5ECD6, 0xEDDDB3]
        case .rain:  stops = [0xEFF1F3, 0xDDE2E8, 0xC9D1DB]
        case .snow:  stops = [0xF9FAFC, 0xECF0F6, 0xDEE5EF]
        case .fog:   stops = [0xF4F4F2, 0xE9E9E6, 0xDBDBD7]
        case .dusk:  stops = [0xEDEBF1, 0xD5D7E5, 0xBAC1D9]
        }
        return LinearGradient(colors: stops.map { Color(hex: $0) }, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var lineColor: Color {
        switch self {
        case .snow, .fog: return Color(hex: 0x333333)
        default: return Color(hex: 0x111111)
        }
    }

    var lineOpacity: Double {
        switch self {
        case .clear: return 0.8
        case .rain: return 0.72
        case .snow: return 0.66
        case .fog: return 0.55
        case .dusk: return 0.78
        }
    }

    var fogColor: Color { Color(hex: 0xF4F4F2) }

    /// Open-Meteo WMO weather code -> mood and the word shown under the countdown.
    static func from(code: Int, isDay: Bool) -> (sky: Sky, label: String) {
        switch code {
        case 0: return isDay ? (.clear, "Clear") : (.dusk, "Clear evening")
        case 1, 2: return isDay ? (.clear, code == 1 ? "Mostly clear" : "Partly cloudy") : (.dusk, "Clear evening")
        case 3: return (.fog, "Overcast")
        case 45, 48: return (.fog, "Fog")
        case 51...57: return (.rain, "Drizzle")
        case 61...67, 80...82: return (.rain, "Rain")
        case 71...77, 85, 86: return (.snow, "Snow")
        case 95...99: return (.rain, "Thunderstorms")
        default: return (.fog, "Overcast")
        }
    }
}
