# BrowserSwitch

A lightweight macOS menu bar app that acts as your default browser and lets you choose which browser opens each link via a quick keyboard-driven overlay.

Tired of links from Slack, Mail, or your IDE always opening in the wrong browser? BrowserSwitch sits between the link and your browsers — when something tries to open a URL, a small overlay appears so you can pick the right one.

## Features

- **Default browser replacement** — registers as the system handler for `http` and `https`
- **Fast overlay UI** — appears at your cursor with a clean, blurred panel
- **Keyboard-first** — arrow keys, number keys (1–4), Return to confirm, Esc to cancel
- **Remembers your last choice** — pre-selects the browser you used last
- **Menu bar only** — no Dock icon, no clutter (`LSUIElement`)
- **Lightweight** — pure Swift / SwiftUI / AppKit, no dependencies

## Supported Browsers

- Google Chrome
- Firefox
- Firefox Developer Edition
- Safari

Browsers that aren't installed appear dimmed and can't be selected.

## Requirements

- macOS 14 or later
- Xcode 15+ (for building from source)

## Installation

### Build from source

```bash
git clone https://github.com/jeffrey200/BrowserSwitch.git
cd BrowserSwitch
./build-release.sh
```

The script builds a Release configuration and installs the app to `~/Applications/BrowserSwitch.app`.

### Set as default browser

1. Open BrowserSwitch from `~/Applications`
2. Click the globe icon in the menu bar
3. Choose **Set as Default Browser**
4. Confirm the system prompt

Alternatively, launch the app once with the flag:

```bash
open -a BrowserSwitch --args --set-default-browser
```

## Usage

Click any link anywhere on your Mac. The overlay appears at your current screen — pick a browser:

- **← / →** — move selection
- **1–4** — pick a browser directly
- **Return / Enter** — open in the selected browser
- **Esc** — cancel
- **Click** — pick with the mouse

## Menu Bar Options

- **Test Overlay** — opens `https://example.com` to preview the overlay
- **Set as Default Browser** — re-runs the registration prompt
- **Quit BrowserSwitch**

## Debugging

Launch with a specific URL to test routing:

```bash
open -a BrowserSwitch --args --debug-url "https://github.com"
```

## Privacy

BrowserSwitch makes no network requests, collects no telemetry, and stores only the bundle identifier of your last-used browser in `UserDefaults`. URLs are passed directly to the browser you choose and never logged or persisted.
