import Cocoa

class TextExtractor {
    func getSelectedText(completion: @escaping (String?) -> Void) {
        let focusedWindow = AXUIElementCreateSystemWide()
        
        guard let focusedElement = self.getFocusedElement(from: focusedWindow) else {
            print("failed")
            completion(nil)
            return
        }
        print("extracted" )

        // Получаем значение атрибута AXSelectedText
        var value: AnyObject?
        let error = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextAttribute as CFString, &value)
        if error == .success, let selectedText = value as? String {
            print("extracted: \(selectedText)")
            completion(selectedText)
            
        } else {
            completion(nil)
        }
    }

    private func getFocusedElement(from window: AXUIElement) -> AXUIElement? {
        var focusedElement: AnyObject?
        let error = AXUIElementCopyAttributeValue(window, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        if error == .success {
            return focusedElement as! AXUIElement?
        }
        return nil
    }

}
