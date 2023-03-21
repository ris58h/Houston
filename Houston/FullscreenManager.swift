import Cocoa

class FullscreenManager {
    private static let fullscreenAttribute = NSAccessibility.Attribute(rawValue: "AXFullScreen")

    private static let maxAttempts = 2
    private static let attemptDelay = 0.5
    
    static func start() {
        debugPrint("FullscreenManager start")
        //TODO: feature switch
        NSWorkspace.shared.notificationCenter.addObserver(FullscreenManager.self, selector: #selector(FullscreenManager.activeSpaceChanged), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
    }
    
    @objc private static func activeSpaceChanged() {
        //TODO: feature switch
        exitFullscreenWindows()
    }
    
    //TODO: add a way to exclude some apps
    private static func exitFullscreenWindows() {
        let fullscreenWindows = fullscreenWindowsByPid()
        debugPrint("fullscreenWindows", fullscreenWindows)
        for fw in fullscreenWindows {
            FullscreenManager.exitFullscreen(processId: fw.key, windowIds: fw.value)
        }
    }

    private static func fullscreenWindowsByPid() -> [Int: Set<Int>] {
        var result: [Int: Set<Int>] = [:]
        let displays = CGSCopyManagedDisplaySpaces(CGSMainConnectionID()) as! [NSDictionary]
        for display in displays {
            let spaces = display["Spaces"] as! [NSDictionary]
            for space in spaces {
                if FullscreenManager.isFullscreen(space) {
                    let windowId = FullscreenManager.windowId(space)
                    let processId = FullscreenManager.processId(space)
                    if let windowId = windowId, let processId = processId {
                        if result[processId] == nil {
                            result[processId] = []
                        }
                        result[processId]?.insert(windowId)
                    }
                }
            }
        }
        return result
    }

    private static func isFullscreen(_ space: NSDictionary) -> Bool {
        let type = space["type"] as? Int
        return type == 4
    }

    private static func windowId(_ space: NSDictionary) -> Int? {
        return space["fs_wid"] as? Int
    }

    private static func processId(_ space: NSDictionary) -> Int? {
        return space["pid"] as? Int
    }

    private static func exitFullscreen(processId: Int, windowIds: Set<Int>) {
        let appElement = AXUIElementCreateApplication(pid_t(processId))
        for windowId in windowIds {
            exitFullscreen(appElement: appElement, windowId: windowId, numAttempts: maxAttempts)
        }
    }
    
    private static func exitFullscreen(appElement: AXUIElement, windowId: Int, numAttempts: Int) {
        if numAttempts <= 0 {
            return
        }
        let exited = exitFullscreen(appElement: appElement, windowId: windowId)
        debugPrint("exitFullscreen", maxAttempts - numAttempts + 1, windowId, exited)
        if !exited {
            DispatchQueue.main.asyncAfter(deadline: .now() + attemptDelay) {
                exitFullscreen(appElement: appElement, windowId: windowId, numAttempts: numAttempts - 1)
            }
        }
    }
    
    private static func exitFullscreen(appElement: AXUIElement, windowId: Int) -> Bool {
        let window = appElement.windows().first {
            if let wid = $0.windowId(), wid == windowId {
                return true
            } else {
                return false
            }
        }
        if window == nil {
            return false
        } else {
            _ = window?.setValue(attribute: fullscreenAttribute, false as CFBoolean)
            return true
        }
    }
}
