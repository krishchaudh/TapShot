# TapShot

**Click or tap the trackpad with three fingers → the macOS screenshot crosshair (⌘⇧4) appears.**

Works on MacBook trackpads and the Magic Trackpad. Lives in the menu bar, no window.

TapShot is a fork of [MiddleClick](https://github.com/artginzburg/MiddleClick) by Arthur Ginzburg
(GPL-3.0). MiddleClick already did the hard part — reading finger count from the trackpad through
Apple's private `MultitouchSupport` framework — so TapShot only swaps what happens when the gesture
fires: instead of faking a scroll-wheel click it presses ⌘⇧4 for you. The original middle-click
behaviour is still there as an option in the menu.

## Install

1. Download `TapShot.zip` from the [latest release](https://github.com/krishchaudh/TapShot/releases/latest)
   and unzip it.
2. Drag `TapShot.app` into `/Applications`.
3. The app is not notarized (no paid Apple developer account), so macOS will refuse to open it the first time.
   Either:
   - open **Terminal** and run `xattr -dr com.apple.quarantine /Applications/TapShot.app`, then open the app, or
   - open the app, dismiss the warning, then go to **System Settings → Privacy & Security**, scroll down and click **Open Anyway**.
4. When asked, give TapShot **Accessibility** permission
   (System Settings → Privacy & Security → Accessibility → turn on TapShot). It needs this to see clicks and to press ⌘⇧4.
5. Click the trackpad with three fingers. Crosshair.

Tick **Launch at login** in the menu-bar icon so it's always on.

### Tips

- Three-finger *tap* (no physical click) also works if "Tap to click" is on in System Settings.
  If **Look up & data detectors** is set to "Tap with Three Fingers" in Trackpad settings, turn it off or
  the dictionary popup will fire too.
- If you use **Three Finger Drag**, change TapShot's finger count to 4 (menu → Advanced) or turn the drag off.
- Menu → **Middle click** switches back to the original MiddleClick behaviour.

## Build it yourself

Open `MiddleClick.xcodeproj` in Xcode and press Run — it's set to "Sign to Run Locally", nothing to configure.
Or from Terminal: `make run`.

Every push to `main` also builds the app on GitHub Actions; pushing a tag like `v1.0.0` publishes a release with `TapShot.zip`.

## How it works (the short version)

- `MoreTouch/` — Swift wrapper around the private `MultitouchSupport.framework`; delivers per-finger
  touch frames.
- `MiddleClick/TouchHandler.swift` — decides whether the current touches are a "three-finger tap"
  (fingers down ≤ 300 ms, barely moved).
- `MiddleClick/Controller+Mouse.swift` — a `CGEventTap` on mouse buttons; if three fingers are resting on
  the trackpad when a physical click arrives, the click is swallowed and the action fires instead.
- `MiddleClick/TriggerAction.swift` — the action itself. For screenshots it posts ⌘ down, ⇧ down,
  `4` down/up, ⇧ up, ⌘ up as `CGEvent`s, which macOS treats like a real keyboard press.

## License

GPL-3.0, same as MiddleClick. See [LICENSE](./LICENSE).
