import SwiftUI

/// The Brooklyn Bridge, drawn in a 320 x 110 space so it matches the mockup exactly.
private struct BridgeLines: Shape {
    enum Weight { case main, thin }
    var weight: Weight

    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 320, sy = rect.height / 110
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy) }
        var path = Path()

        switch weight {
        case .main:
            for cx: CGFloat in [100, 220] {
                path.move(to: p(cx - 18, 88)); path.addLine(to: p(cx - 18, 20))
                path.addLine(to: p(cx + 18, 20)); path.addLine(to: p(cx + 18, 88))
                path.move(to: p(cx - 11, 88)); path.addLine(to: p(cx - 11, 52))
                path.addQuadCurve(to: p(cx, 32), control: p(cx - 11, 38))
                path.addQuadCurve(to: p(cx + 11, 52), control: p(cx + 11, 38))
                path.addLine(to: p(cx + 11, 88))
                path.move(to: p(cx - 9, 27))
                path.addQuadCurve(to: p(cx, 21.5), control: p(cx - 9, 22))
                path.addQuadCurve(to: p(cx + 9, 27), control: p(cx + 9, 22))
            }
            path.move(to: p(0, 80)); path.addQuadCurve(to: p(100, 20), control: p(52, 62))
            path.move(to: p(100, 20)); path.addQuadCurve(to: p(220, 20), control: p(160, 78))
            path.move(to: p(220, 20)); path.addQuadCurve(to: p(320, 80), control: p(268, 62))
            path.move(to: p(0, 88)); path.addLine(to: p(320, 88))

        case .thin:
            for cx: CGFloat in [100, 220] {
                for i in 1...5 {
                    let d = CGFloat(i) * 14
                    path.move(to: p(cx, 22)); path.addLine(to: p(cx - d, 88))
                    path.move(to: p(cx, 22)); path.addLine(to: p(cx + d, 88))
                }
            }
            // Suspenders land on the same quadratic cable as the span above.
            var x: CGFloat = 114
            while x <= 206 {
                let t = (x - 100) / 120
                let y = (1 - t) * (1 - t) * 20 + 2 * t * (1 - t) * 78 + t * t * 20
                path.move(to: p(x, y)); path.addLine(to: p(x, 88))
                x += 8
            }
            // Water
            for start: CGFloat in [6, 96, 190, 262] { wave(&path, from: start, y: 98, segments: start == 262 ? 2 : 3, p: p) }
            for start: CGFloat in [40, 150, 236] { wave(&path, from: start, y: 104, segments: start == 236 ? 1 : 2, p: p) }
        }
        return path
    }

    private func wave(_ path: inout Path, from x: CGFloat, y: CGFloat, segments: Int, p: (CGFloat, CGFloat) -> CGPoint) {
        path.move(to: p(x, y))
        for i in 0..<segments {
            let x0 = x + CGFloat(i) * 20
            let bend: CGFloat = i % 2 == 0 ? -4 : 4
            path.addQuadCurve(to: p(x0 + 20, y), control: p(x0 + 10, y + bend))
        }
    }
}

private struct RainLines: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 320, sy = rect.height / 110
        var path = Path()
        for r in 0..<34 {
            let x = CGFloat((r * 29) % 320), y = CGFloat((r * 53) % 78)
            path.move(to: CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy))
            path.addLine(to: CGPoint(x: rect.minX + (x - 3) * sx, y: rect.minY + (y + 10) * sy))
        }
        return path
    }
}

private struct SnowDots: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 320, sy = rect.height / 110
        var path = Path()
        for f in 0..<26 {
            let x = CGFloat((f * 47) % 320), y = CGFloat((f * 31) % 84)
            let r = (1.2 + CGFloat(f % 3) * 0.5) * sx
            path.addEllipse(in: CGRect(x: rect.minX + x * sx - r, y: rect.minY + y * sy - r, width: r * 2, height: r * 2))
        }
        return path
    }
}

struct BridgeScene: View {
    let sky: Sky

    var body: some View {
        GeometryReader { geo in
            // Stretch to whatever space the widget gives us: width and height scale independently, strokes stay fixed.
            let sx = geo.size.width / 320, sy = geo.size.height / 110, u = min(sx, sy)
            ZStack(alignment: .topLeading) {
                if sky == .clear {
                    Circle().fill(Color(hex: 0xE8B923, opacity: 0.42)).frame(width: 30 * u, height: 30 * u).position(x: 272 * sx, y: 32 * sy)
                }
                if sky == .dusk {
                    Circle().fill(Color(hex: 0x2F5D9B, opacity: 0.22)).frame(width: 26 * u, height: 26 * u).position(x: 268 * sx, y: 30 * sy)
                }
                ZStack {
                    BridgeLines(weight: .thin).stroke(sky.lineColor.opacity(sky.lineOpacity * 0.7), style: StrokeStyle(lineWidth: 0.7, lineCap: .round, lineJoin: .round))
                    BridgeLines(weight: .main).stroke(sky.lineColor.opacity(sky.lineOpacity), style: StrokeStyle(lineWidth: 1.1, lineCap: .round, lineJoin: .round))
                    // The yellow cab on the deck.
                    RoundedRectangle(cornerRadius: 1.6 * u).fill(Color(hex: 0xE8B923)).frame(width: 14 * u, height: 5.5 * u).position(x: 157 * sx, y: 88 * sy - 2.75 * u)
                    RoundedRectangle(cornerRadius: 1 * u).fill(Color(hex: 0xE8B923)).frame(width: 6 * u, height: 3 * u).position(x: 158 * sx, y: 88 * sy - 7 * u)
                }
                .opacity(sky == .fog ? 0.55 : 1)

                if sky == .rain {
                    RainLines().stroke(Color(hex: 0x2F5D9B, opacity: 0.4), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                }
                if sky == .snow {
                    SnowDots().fill(Color.white)
                    SnowDots().stroke(Color(hex: 0xAEBBD2), lineWidth: 0.6)
                }
                if sky == .fog {
                    LinearGradient(stops: [
                        .init(color: sky.fogColor.opacity(0), location: 0),
                        .init(color: sky.fogColor.opacity(0.85), location: 0.55),
                        .init(color: sky.fogColor.opacity(0.4), location: 1),
                    ], startPoint: .top, endPoint: .bottom)
                    .frame(width: geo.size.width, height: 98 * sy)
                    .offset(y: 12 * sy)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
