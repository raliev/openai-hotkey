import Cocoa
import Carbon

class KeyInterceptor {
    private var eventTap: CFMachPort?
    
    private var textProcessor: TextProcessor


    init(textProcessor: TextProcessor) {
        self.textProcessor = textProcessor
 
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                     place: .headInsertEventTap,
                                     options: .defaultTap,
                                     eventsOfInterest: CGEventMask(eventMask),
                                     callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                                         if let refconUnwrapped = refcon {
                                             let interceptor = Unmanaged<KeyInterceptor>.fromOpaque(refconUnwrapped).takeUnretainedValue()
                                             print("Обработка события: \(type)")
                                             return interceptor.handleEvent(proxy: proxy, type: type, event: event)
                                         } else {
                                             return Unmanaged.passRetained(event)
                                         }
                                     },
                                     userInfo: Unmanaged.passUnretained(self).toOpaque())
        
        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }

    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if event.type == .keyDown {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            
            if keyCode == CGKeyCode(kVK_ANSI_R) && flags.contains(.maskCommand) && flags.contains(.maskAlternate) {
                captureAndReplaceText(prefix: "return only the rephrased text:")
                return nil;
            }
            
            if keyCode == CGKeyCode(kVK_ANSI_T) && flags.contains(.maskCommand) && flags.contains(.maskAlternate) {
                captureAndReplaceText(prefix: "return only the translated text:")
                return nil;
            }

            if keyCode == CGKeyCode(kVK_ANSI_G) && flags.contains(.maskCommand) && flags.contains(.maskAlternate) {
                captureAndReplaceText(prefix: "Return only the text with corrected grammatical errors (do not change the text if there are no errors; if there are, change minimally):")
                return nil;
            }
            
        }
        return Unmanaged.passRetained(event)
    }
    
    private func captureAndReplaceText(prefix: String) {
        let source = CGEventSource(stateID: .hidSystemState)
        let cmdC = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: true)
        cmdC?.flags = .maskCommand
        cmdC?.post(tap: .cghidEventTap)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let clipboardString = NSPasteboard.general.string(forType: .string) {
                
                self.textProcessor.processText(prefix, clipboardString) { response in
                                    DispatchQueue.main.async {
                                        // Обработка ответа и замена текста
                                        self.replaceSelectedText(with: response)
                                    }
                                }
                           
            }
        }
    }

    
    

    private func replaceSelectedText(with text: String) {
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Вставка нового текста вместо выделенного
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        let pasteEventDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
        pasteEventDown?.flags = .maskCommand
        pasteEventDown?.post(tap: .cghidEventTap)

        let pasteEventUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
        pasteEventUp?.flags = .maskCommand
        pasteEventUp?.post(tap: .cghidEventTap)
    }
}
