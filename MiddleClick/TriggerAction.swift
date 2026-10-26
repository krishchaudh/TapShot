import Carbon.HIToolbox
import CoreGraphics
import Foundation

/// What happens when the user clicks or taps with the configured number of fingers.
enum TriggerAction: String, CaseIterable {
  /// Press ⌘⇧4 so macOS shows the screenshot crosshair.
  case screenshot
  /// Behave like the original MiddleClick: emulate a scroll-wheel click.
  case middleClick

  var title: String {
    switch self {
    case .screenshot: return "Take screenshot (⌘⇧4)"
    case .middleClick: return "Middle click"
    }
  }

  @MainActor static var current: TriggerAction {
    get { TriggerAction(rawValue: Config.shared.action) ?? .screenshot }
    set { Config.shared.action = newValue.rawValue }
  }

  /// Fire this action. `location` is only used by `.middleClick`.
  func perform(at location: CGPoint) {
    switch self {
    case .screenshot:
      Self.postKeyboardShortcut(
        key: CGKeyCode(kVK_ANSI_4), flags: [.maskCommand, .maskShift])
    case .middleClick:
      Self.postMouseEvent(type: .otherMouseDown, button: .center, location: location)
      Self.postMouseEvent(type: .otherMouseUp, button: .center, location: location)
    }
  }

  // MARK: - Event posting

  /// Posts the modifier keys one by one around the main key, the way a real keyboard
  /// would. System hotkeys (like the screenshot ones) are picky about this.
  private static func postKeyboardShortcut(key: CGKeyCode, flags: CGEventFlags) {
    let source = CGEventSource(stateID: .hidSystemState)
    let modifiers: [(CGKeyCode, CGEventFlags)] = [
      (CGKeyCode(kVK_Command), .maskCommand),
      (CGKeyCode(kVK_Shift), .maskShift),
      (CGKeyCode(kVK_Option), .maskAlternate),
      (CGKeyCode(kVK_Control), .maskControl),
    ].filter { flags.contains($0.1) }

    var activeFlags: CGEventFlags = []
    for (code, flag) in modifiers {
      activeFlags.insert(flag)
      postKey(code, down: true, flags: activeFlags, source: source)
    }

    postKey(key, down: true, flags: activeFlags, source: source)
    postKey(key, down: false, flags: activeFlags, source: source)

    for (code, flag) in modifiers.reversed() {
      activeFlags.remove(flag)
      postKey(code, down: false, flags: activeFlags, source: source)
    }
  }

  private static func postKey(
    _ code: CGKeyCode, down: Bool, flags: CGEventFlags, source: CGEventSource?
  ) {
    guard let event = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: down) else {
      log.error("Failed to create keyboard event for key code \(code)")
      return
    }
    event.flags = flags
    event.post(tap: .cghidEventTap)
  }

  private static func postMouseEvent(
    type: CGEventType, button: CGMouseButton, location: CGPoint
  ) {
    CGEvent(
      mouseEventSource: nil, mouseType: type, mouseCursorPosition: location,
      mouseButton: button
    )?.post(tap: .cghidEventTap)
  }
}
