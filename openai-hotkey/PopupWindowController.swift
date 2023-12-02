import SwiftUI
import AppKit

class PopupWindowController: NSObject {
    static let shared = PopupWindowController()
    var popupWindow: NSWindow?
    
    var audioPlayerManager = AudioPlayerManager()


    func showWindow() {
        let popupContentView = NSHostingView(rootView: PopupView(isPresented: .constant(true), stopAction: {
            self.audioPlayerManager.stopAudio()
            self.hideWindow()
            print("stopping audio");
        }))

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.contentView = popupContentView
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.popupWindow = window
    }
    
    func playAudio() {
            audioPlayerManager.playAudioFile()
        }

    func hideWindow() {
        popupWindow?.close()
    }
}
