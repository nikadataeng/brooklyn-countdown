# Brooklyn Countdown

A calm macOS desktop widget for a big move. It shows how long is left, a few things to do, and a Brooklyn Bridge that changes with the weather.

Built to be the opposite of an anxious to-do app: no red badges, no overdue counts, no ticking clock.

## What it does

- **Gentle countdown.** "About 9 weeks" until two weeks out, then plain days, then "tomorrow" and "today".
- **A few things at a time.** Shows at most three to-dos, and only ones that are near. One quiet "Later" line hints at what's next.
- **Tick things off in the widget.** Tap a circle and it's done. No app to open.
- **Weather-driven art.** A single-line drawing of the Brooklyn Bridge, with a yellow taxi on the deck, changes with live Brooklyn weather: clear, rain, snow, fog or evening.

## How it was made

1. Designed the behavior first, then built HTML mockups of every size and weather.
2. Restyled the mockups after a design reference (clean white and black, soft retro serif, muted film tones).
3. Wrote the widget in SwiftUI and WidgetKit with an App Intent for tap-to-tick.
4. Tested the countdown wording, to-do pacing and weather mapping, then built it with Xcode.

## How it works

| Piece | What it does |
| --- | --- |
| `Shared/Plan.swift` | Plan model, countdown wording, and the to-do file at `~/.brooklyn-countdown/todos.json` |
| `Widget/` | The widget, Open-Meteo weather (free, no key), the bridge drawing, and the tick-off intent |
| `App/` | A tiny host app, since macOS needs one to carry a widget |

To-dos are plain JSON, so you can edit them by hand. An optional `showFrom` date (yyyy-MM-dd) keeps an item hidden until it's near.

## Build

Needs Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project BrooklynCountdown.xcodeproj -scheme BrooklynCountdown \
  -configuration Debug -derivedDataPath build \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=YES DEVELOPMENT_TEAM= build
cp -R build/Build/Products/Debug/BrooklynCountdown.app ~/Applications/
open ~/Applications/BrooklynCountdown.app
```

Then right-click the desktop, choose Edit Widgets, and add Brooklyn Countdown (large).

## Status

Work in progress. Working: it builds, the logic is tested, and the widget registers with macOS and loads live weather. Still to confirm: tap-to-tick in the real widget, and how it renders in macOS's monochrome widget style. `PlanStore.log` writes a temporary `debug.log` for that and will be removed.
