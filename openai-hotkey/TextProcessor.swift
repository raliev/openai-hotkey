import Foundation

class TextProcessor {
    func processText(_ prefix: String, _ text: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let apiKey = UserDefaults.standard.string(forKey: "APIKey") ?? ""
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": "\(prefix) \(text)"
                ]
            ],
            "temperature": 0.7
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        print("sending \(body)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                  print("HTTP Status Code: \(httpResponse.statusCode)")
                  print("HTTP Response Headers: \(httpResponse.allHeaderFields)")
              }
            if let responseText = try? JSONDecoder().decode(ChatGPTResponse.self, from: data) {
                let resp = responseText.choices.first?.message.content

                    // Логгирование ответа от ChatGPT
                    print("ChatGPT Response: \(resp ?? "Пустой ответ")")

                    completion(resp ?? "")
                } else {
                    // Логгирование сырого ответа, если не удалось декодировать
                    let rawResponseString = String(data: data, encoding: .utf8) ?? "can't decode the response"
                    print("Response: \(rawResponseString)")
                }
        }
        task.resume()
    }
}

struct ChatGPTResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }

        let index: Int
        let message: Message
        let finish_reason: String
    }

    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    let system_fingerprint: String?

    struct Usage: Codable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
}
