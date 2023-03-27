import Cocoa

class SwipeManager {
    private static let accVelXThreshold: Float = 0.07
    private static let debounceTimeBeforeActivation: Double = 0.07

    private static var eventTap: CFMachPort? = nil
    private static var accVelX: Float = 0
    private static var prevTouchPositions: [String: NSPoint] = [:]

    private static func listener(_ swipeType: SwipeType) {
        switch swipeType {
        case .twoFingers(let direction):
            switch Dock.currentActivity() {
            case .some(.missionControl):
                switch direction {
                case .left:
                    Dock.MissionControl.nextSpace()
                case .right:
                    Dock.MissionControl.prevSpace()
                }
            case .some(.appExpose):
                //TODO: don't switch app if cursor is over recents
                switch direction {
                case .left:
                    Dock.AppExpose.nextApp()
                case .right:
                    Dock.AppExpose.prevApp()
                }
            default:
                break
            }
        }
    }

    static func start() {
        //TODO: feature switch
        if eventTap != nil {
            debugPrint("SwipeManager is already started")
            return
        }
        debugPrint("SwipeManager start")
        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: NSEvent.EventTypeMask.gesture.rawValue,
            callback: { proxy, type, cgEvent, userInfo in
                return SwipeManager.eventHandler(proxy: proxy, eventType: type, cgEvent: cgEvent, userInfo: userInfo)
            },
            userInfo: nil
        )
        if eventTap == nil {
            debugPrint("SwipeManager couldn't create event tap")
            return
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(nil, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
        CGEvent.tapEnable(tap: eventTap!, enable: true)
    }
    
    private static func eventHandler(proxy: CGEventTapProxy, eventType: CGEventType, cgEvent: CGEvent, userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        if eventType.rawValue == NSEvent.EventType.gesture.rawValue, let nsEvent = NSEvent(cgEvent: cgEvent) {
            touchEventHandler(nsEvent)
        } else if (eventType == .tapDisabledByUserInput || eventType == .tapDisabledByTimeout) {
            CGEvent.tapEnable(tap: eventTap!, enable: true)
        }
        return Unmanaged.passUnretained(cgEvent)
    }
    
    private static func touchEventHandler(_ nsEvent: NSEvent) {
        let touches = nsEvent.allTouches()

        if touches.isEmpty {
            return
        }
        let touchesCount = touches.allSatisfy({ $0.phase == .ended }) ? 0 : touches.count

        if touchesCount != 2 {
            // Not enough swiping.
            if abs(accVelX) > accVelXThreshold {
                gesture()
            }
            clearState()
            return
        }

        let velX = SwipeManager.horizontalSwipeVelocity(touches: touches)
        // We don't care about non-horizontal swipes.
        if velX == nil {
            return
        }

        accVelX += velX!
    }
    
    private static func clearState() {
        accVelX = 0
        prevTouchPositions.removeAll()
    }
    
    private static func gesture() {
        let direction: SwipeType.Direction = accVelX < 0 ? .left : .right
        listener(.twoFingers(direction: direction))
    }

    private static func horizontalSwipeVelocity(touches: Set<NSTouch>) -> Float? {
        var allRight = true
        var allLeft = true
        var sumVelX = Float(0)
        var sumVelY = Float(0)
        for touch in touches {
            let (velX, velY) = touchVelocity(touch)
            allRight = allRight && velX >= 0
            allLeft = allLeft && velX <= 0
            sumVelX += velX
            sumVelY += velY

            if touch.phase == .ended {
                prevTouchPositions.removeValue(forKey: "\(touch.identity)")
            } else {
                prevTouchPositions["\(touch.identity)"] = touch.normalizedPosition
            }
        }
        // All fingers should move in the same direction.
        if !allRight && !allLeft {
            return nil
        }

        let velX = sumVelX / Float(touches.count)
        let velY = sumVelY / Float(touches.count)
        // Only horizontal swipes are interesting.
        if abs(velX) <= abs(velY) {
            return nil
        }

        return velX
    }
    
    private static func touchVelocity(_ touch: NSTouch) -> (Float, Float) {
        guard let prevPosition = prevTouchPositions["\(touch.identity)"] else {
            return (0, 0)
        }
        let position = touch.normalizedPosition
        return (Float(position.x - prevPosition.x), Float(position.y - prevPosition.y))
    }

    enum SwipeType {
        case twoFingers(direction: Direction)

        enum Direction {
            case left
            case right
        }
    }
}
