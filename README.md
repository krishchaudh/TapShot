# TapShot

[![Build](https://github.com/krishchaudh/TapShot/actions/workflows/build.yml/badge.svg)](https://github.com/krishchaudh/TapShot/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/krishchaudh/TapShot)](https://github.com/krishchaudh/TapShot/releases/latest)
![macOS](https://img.shields.io/badge/macOS-10.13%2B-black)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue)](./LICENSE)

**Click the trackpad with three fingers → the macOS screenshot crosshair (⌘⇧4) appears.**

![Three fingers on a MacBook trackpad](demo.png)

A tiny macOS menu-bar app. No window, no settings to learn: one gesture, one shortcut.
Works on MacBook trackpads and the Magic Trackpad.

## Why

I take a lot of screenshots and ⌘⇧4 is an awkward stretch. I wanted *three-finger click → crosshair*
and assumed something off the shelf would do it:

- **macOS** has no "run a shortcut on a trackpad gesture" option.
- **Mac Mouse Fix** only remaps *mouse* buttons, not trackpad gestures.
- **BetterTouchTool** can do it, but it's a paid app for one gesture.

So TapShot does exactly that one thing. It's a fork of [MiddleClick](https://github.com/artginzburg/MiddleClick)
by Arthur Ginzburg, which already solved the hard part — counting fingers on the trackpad through Apple's
private `MultitouchSupport` framework. TapShot swaps what happens when the gesture fires: instead of
faking a scroll-wheel click, it presses ⌘⇧4 for you. The original middle-click behaviour is still in the
menu if you want it.

## Install

1. Download `TapShot.zip` from the [latest release](https://github.com/krishchaudh/TapShot/releases/latest)
   and unzip it.
2. Drag `TapShot.app` into `/Applications`.
3. The app isn't notarized (that needs a paid Apple developer account), so macOS blocks it the first time.
   Pick one:
   - **Terminal:** `xattr -dr com.apple.quarantine /Applications/TapShot.app`, then open the app.
   - **Settings:** open the app, click *Done* on the warning, then **System Settings → Privacy & Security**,
     scroll down → **Open Anyway**.
4. Give TapShot **Accessibility** permission when asked
   (System Settings → Privacy & Security → Accessibility → turn on TapShot).
   It needs this to see your clicks and to press ⌘⇧4.
5. Click the trackpad with three fingers. Crosshair.

It has no window — look for the small mouse icon in the menu bar. Tick **Launch at login** there so it's
always on.

## Tips & gotchas

- **Three-finger *tap*** (no physical click) also works when *Tap to click* is on in System Settings, or
  toggle it in TapShot's menu.
- **Dictionary popup fires too?** Trackpad settings → *Look up & data detectors* is set to
  "Tap with Three Fingers". Change it to "Force Click with One Finger" or off.
- **Three Finger Drag** users: set the finger count to 4 (menu → *Advanced*) or turn the drag off.
- **Want the old behaviour?** Menu → *Middle click* switches back to MiddleClick's scroll-wheel click.
- **Nothing happens after an update?** macOS sometimes keeps a stale Accessibility entry. Remove TapShot
  from the Accessibility list and add it again. More in [docs/troubleshooting.md](docs/troubleshooting.md).

## Build it yourself

Open `MiddleClick.xcodeproj` in Xcode and press Run — it's set to *Sign to Run Locally*, nothing to
configure. Or from Terminal:

```sh
make run
```

Every push to `main` builds the app on GitHub Actions (free macOS runners), and pushing a tag like `v1.0.1`
publishes a release with `TapShot.zip` attached — so you don't need Xcode to ship a build.

## How it works

```
trackpad frames ──▶ TouchHandler ──▶ "3 fingers down, ≤300 ms, barely moved"
                                             │
physical click ───▶ CGEventTap ──────────────┤  swallow the click
                                             ▼
                                     TriggerAction.screenshot
                                             │
                               ⌘↓  ⇧↓  4↓  4↑  ⇧↑  ⌘↑   (CGEvent, HID tap)
                                             ▼
                                 macOS shows the screenshot crosshair
```

- `MoreTouch/` — Swift wrapper around the private `MultitouchSupport.framework`; delivers per-finger
  touch frames.
- `MiddleClick/TouchHandler.swift` — decides whether the current touches count as a three-finger tap.
- `MiddleClick/Controller+Mouse.swift` — a `CGEventTap` on mouse buttons; if three fingers are resting on
  the trackpad when a physical click arrives, the click is swallowed and the action fires instead.
- `MiddleClick/TriggerAction.swift` — the new part. Posts the modifiers one at a time around the `4` key,
  the way a real keyboard would, because macOS system hotkeys are picky about that.

Things I learned building it: `CGEvent` injection, why the Accessibility permission exists, how
menu-bar-only apps work, and that Apple's private multitouch API is the only way to count fingers (which is
why this can never be on the App Store).

## Credits & license

Almost all of the gesture code is [MiddleClick](https://github.com/artginzburg/MiddleClick) by Arthur
Ginzburg and contributors. TapShot is GPL-3.0, same as MiddleClick — see [LICENSE](./LICENSE).
