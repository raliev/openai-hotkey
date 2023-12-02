import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var showingPopup = false
    var audioPlayerManager = AudioPlayerManager()

    init() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("StartAudioPlayback"), object: nil, queue: .main) { [weak self] _ in
            self?.showPopupAndPlayAudio()
        }
    }

    func showPopupAndPlayAudio() {
        //showingPopup = true
        PopupWindowController.shared.showWindow()
        PopupWindowController.shared.playAudio()
    }
}
