import SwiftUI
import CocoaLumberjackSwift


struct ContentView: View {
    @State private var apiKey = UserDefaults.standard.string(forKey: "APIKey") ?? ""

    @State private var showingPopup = false
    @State private var audioPlayerManager = AudioPlayerManager()
    
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            TextField("API Key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save") {
                UserDefaults.standard.set(apiKey, forKey: "APIKey")
            }
            
            if viewModel.showingPopup {
                PopupView(isPresented: $viewModel.showingPopup, stopAction: {
                        viewModel.audioPlayerManager.stopAudio()
                    })
                    .frame(width: 200, height: 100) 
                    .background(Color.white)
                        }
            
        }
        .padding()
        .onAppear {
            apiKey = UserDefaults.standard.string(forKey: "APIKey") ?? ""
        }
    }
    
    func showPopupAndPlayAudio() {
            showingPopup = true
            audioPlayerManager.playAudioFile()
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
    var eventTapCheckTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.interceptor = KeyInterceptor(textProcessor: TextProcessor(), audioPlayerManager: AudioPlayerManager())
        
        eventTapCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                    self?.interceptor?.checkAndReactivateEventTap()
                }
        
        DDLog.add(DDOSLogger.sharedInstance)
                
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
        if let fileLogger = DDLog.allLoggers.first(where: { $0 is DDFileLogger }) as? DDFileLogger {
            print("LOGS: \(fileLogger.currentLogFileInfo?.filePath ?? "not found")")
        }
        
        
    }
    
    
}
