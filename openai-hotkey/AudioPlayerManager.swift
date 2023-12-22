import AVFoundation

class AudioPlayerManager {
    var player: AVAudioPlayer?

    func playTicking() {
        guard let url = Bundle.main.url(forResource: "ticking", withExtension: "mp3") else {
                print("Error: Ticking audio file not found")
                return
            }

            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Error with playing the audio file: \(error)")
            }
    }

    func playAudioFile() {
        
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            guard let documentDirectory = urls.first else { return  }

            let fileURL = documentDirectory.appendingPathComponent("output.mp3")
                
            do {
                player = try AVAudioPlayer(contentsOf: fileURL)
                player?.play()
            } catch {
                print("Error with playing the audio file \(fileURL): \(error)")
            }
        }

    func stopAudio() {
        player?.stop()
   
    }
}
