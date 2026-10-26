import CoreGraphics
import Foundation
import CoreFoundation

extension Controller {
  private static let state = GlobalState.shared
  private static let kCGMouseButtonCenter = Int64(CGMouseButton.center.rawValue)

  static let mouseEventHandler = CGEventController {
    _, type, event, _ in

    let returnedEvent = Unmanaged.passUnretained(event)
    guard !AppUtils.isIgnoredAppBundle() else { return returnedEvent }

    let action = TriggerAction.current

    if state.threeDown && (type == .leftMouseDown || type == .rightMouseDown) {
      state.wasThreeDown = true
      state.threeDown = false
      state.naturalMiddleClickLastTime = Date()

      switch action {
      case .middleClick:
        event.type = .otherMouseDown
        event.setIntegerValueField(.mouseEventButtonNumber, value: kCGMouseButtonCenter)
      case .screenshot:
        let location = event.location
        DispatchQueue.main.async { action.perform(at: location) }
        return nil // swallow the physical click so nothing else reacts to it
      }
    }

    if state.wasThreeDown && (type == .leftMouseUp || type == .rightMouseUp) {
      state.wasThreeDown = false

      switch action {
      case .middleClick:
        event.type = .otherMouseUp
        event.setIntegerValueField(.mouseEventButtonNumber, value: kCGMouseButtonCenter)
      case .screenshot:
        return nil
      }
    }
    return returnedEvent
  }
}
