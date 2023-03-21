class Dock {
    static func pid() -> pid_t? {
        return NSWorkspace.shared.runningApplications.first {
            $0.bundleIdentifier == "com.apple.dock"
        }?.processIdentifier
    }
    
    static func currentActivity() -> Activity? {
        var hasLayer17Window = false
        var hasLayer18Window = false
        for window in CGWindow.windows(.optionOnScreenOnly).filter({ $0.ownerName() == "Dock" }) {
            let windowLayer = window.layer()
            if windowLayer == 17 {
                hasLayer17Window = true
            }
            if windowLayer == 18 {
                hasLayer18Window = true
            }
        }
        if hasLayer17Window {
            return .missionControl
        }
        if hasLayer18Window {
            return .appExpose
        }
        return nil
    }
    
    enum Activity {
        case missionControl
        case appExpose
        case appSwitcher
    }
    
    class MissionControl {
        static func prevSpace() {
            debugPrint("prevSpace")
//            Spaces.focusPrevSpace()
        }

        static func nextSpace() {
            debugPrint("nextSpace")
//            Spaces.focusNextSpace()
        }
    }
    
    class AppExpose {
        static func prevApp() {
            postKeyEvent(key: tabKey, down: true, flags: [.maskShift])
            postKeyEvent(key: tabKey, down: false, flags: [.maskShift])
        }
        
        static func nextApp() {
            postKeyEvent(key: tabKey, down: true)
            postKeyEvent(key: tabKey, down: false)
        }
    }
    
    private static let tabKey = CGKeyCode(0x30);
    private static let leftArrowKey = CGKeyCode(0x7B);
    private static let rightArrowKey = CGKeyCode(0x7C);
    
    private static func postKeyEvent(key: CGKeyCode, down: Bool, flags: CGEventFlags? = nil) {
        let event = CGEvent(
            keyboardEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
            virtualKey: CGKeyCode(key),
            keyDown: down)
        if flags != nil {
            event?.flags = flags!
        }
        event?.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
