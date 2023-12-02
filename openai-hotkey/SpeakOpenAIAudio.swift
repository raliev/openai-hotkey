import SwiftUI

class SpeakOpenAIAudio {
    func convertTextToAudio(text: String, voice: String, completion: @escaping (URL?) -> Void) {

        
        let apiKey = UserDefaults.standard.string(forKey: "APIKey") ?? ""
        
        let urlString = "https://api.openai.com/v1/audio/speech"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }


        let requestBody: [String: Any] = [
            "model": "tts-1",
            "input": text,
            "voice": voice
        ]
        let requestData = try? JSONSerialization.data(withJSONObject: requestBody)


        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")


        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let audioData = data, error == nil else {
                completion(nil)
                return
            }


            let fileURL = self.saveAudioToFile(audioData: audioData)
            completion(fileURL)
        }
        task.resume()
    }

    private func saveAudioToFile(audioData: Data) -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else { return nil }

        let fileURL = documentDirectory.appendingPathComponent("output.mp3")
        print("temp file is \(fileURL)")
        do {
            try audioData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error with wriing the file: \(error)")
            return nil
        }
    }
}
