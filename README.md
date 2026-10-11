# Brooklyn Countdown

A large macOS desktop widget: a calm countdown to a move to Brooklyn, a few to-dos you tick off in place, and a Brooklyn Bridge drawing that follows the weather.

## How it works

- `Shared/Plan.swift`: plan model, the `~/.brooklyn-countdown/todos.json` store, and the countdown wording ("about 9 weeks" until two weeks out, then plain days).
- `Widget/`: the widget, Brooklyn weather from Open-Meteo (free, no key), the bridge drawing, and the tap-to-tick App Intent.
- `App/`: a tiny host app. macOS needs one to carry a widget; it seeds the to-do file.
- To-dos have an optional `showFrom` date (yyyy-MM-dd) that keeps an item out of sight until it is near. At most three show at a time.

## Build

Requires Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

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

Work in progress. It builds, the logic is tested, and the widget registers with macOS and loads live weather. Still to confirm: tap-to-tick in the real widget, and how it renders in macOS monochrome widget style. `PlanStore.log` writes a temporary `debug.log` for diagnosing that and should be removed afterwards.
