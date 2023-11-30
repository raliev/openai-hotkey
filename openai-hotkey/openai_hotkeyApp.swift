import SwiftUI


struct ContentView: View {
    @State private var apiKey = UserDefaults.standard.string(forKey: "APIKey") ?? ""

    var body: some View {
        VStack {
            TextField("API Key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save") {
                UserDefaults.standard.set(apiKey, forKey: "APIKey")
            }
        }
        .padding()
        .onAppear {
            apiKey = UserDefaults.standard.string(forKey: "APIKey") ?? ""
        }
    }
}


@main
struct openai_hotkeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var interceptor: KeyInterceptor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.interceptor = KeyInterceptor(textProcessor: TextProcessor())
    }
}
