extension AXUIElement {
    func debugPrint() {
        Swift.debugPrint(self)
        for name in attributeNames() {
            Swift.debugPrint(name, getValue(attributeName: name))
        }
    }
    
    func windowId() -> CGWindowID? {
        var windowId = CGWindowID(0)
        let error = _AXUIElementGetWindow(self, &windowId)
        if error == .success {
            return windowId
        } else {
            return nil
        }
    }

    static func getElement(pid: pid_t, position: CGPoint) -> AXUIElement? {
        let appElement = AXUIElementCreateApplication(pid)
        var element: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(appElement, Float(position.x), Float(position.y), &element)
        if error == .success {
            return element
        } else {
            return nil
        }
    }
}

extension AXUIElement {
    func children() -> [AXUIElement] {
        return getValue(attribute: NSAccessibility.Attribute.children) as? [AXUIElement] ?? []
    }
    
    func topLevelUIElement() -> AXUIElement? {
        let value = getValue(attribute: NSAccessibility.Attribute.topLevelUIElement)
        if value == nil {
            return nil
        } else {
            return (value as! AXUIElement)
        }
    }
    
    func windows() -> [AXUIElement] {
        return getValue(attribute: NSAccessibility.Attribute.windows) as? [AXUIElement] ?? []
    }
}

extension AXUIElement {
    func attributeNames() -> [String] {
        var value: CFArray?
        let result = AXUIElementCopyAttributeNames(self, &value)
        if result != .success || value == nil {
            return []
        }
        return value as! [String]
    }
    
    func getValue(attribute: NSAccessibility.Attribute) -> AnyObject? {
        return getValue(attributeName: attribute.rawValue)
    }
    
    func getValue(attributeName: String) -> AnyObject? {
        var value: AnyObject?
        let error = AXUIElementCopyAttributeValue(self, attributeName as CFString, &value)
        if error == .success {
            return value
        } else {
            return nil
        }
    }

    func setValue(attribute: NSAccessibility.Attribute, _ value: AnyObject) -> Bool {
        return setValue(attributeName: attribute.rawValue, value)
    }
    
    func setValue(attributeName: String, _ value: AnyObject) -> Bool {
        let error = AXUIElementSetAttributeValue(self, attributeName as CFString, value)
        return error == .success
    }
}
