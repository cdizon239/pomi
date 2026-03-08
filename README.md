# pomi

A minimal macOS menu bar Pomodoro timer built in Swift.

## Download

Available on the [Mac App Store](https://apps.apple.com/app/pomi). Requires **macOS 13+**.

## Features

- Lives in your menu bar (no dock icon)
- Red tomato icon
- 25-minute focus sessions (configurable: 25, 35, 45, or 60 minutes)
- 5-minute break automatically after each focus session
- Countdown timer displayed in the menu bar
- Plays a gentle sound when timer completes
- Popup alert with option to start break/next session
- Duration picker submenu

## Usage

1. Click the tomato icon in the menu bar
2. Select **Start Focus** to begin a 25-minute session
3. When the timer completes, a sound plays and an alert offers to start a break
4. Use **Focus Duration** submenu to change session length
5. Click **Stop** to cancel a running timer

## Build from Source

Requires macOS 13+ and Swift 5.10+.

```bash
./scripts/build_app.sh
cp -R pomi.app /Applications/
```

## Project Structure

```
Sources/pomi/
  main.swift               # App entry point, sets up NSApplication
  AppDelegate.swift         # Application delegate
  PomodoroTimer.swift       # Timer logic (focus/break states, countdown)
  StatusBarController.swift # Menu bar UI, tomato icon, alert handling
scripts/
  build_app.sh             # Builds pomi.app bundle
  generate_icon.swift      # Generates AppIcon.icns from code
```

## Privacy

pomi does not collect, store, or transmit any data. See [Privacy Policy](PRIVACY.md).
