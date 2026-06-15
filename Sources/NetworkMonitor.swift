import Foundation

class NetworkMonitor: ObservableObject {
    @Published var isListening = false
    @Published var webhookUrl: String = ""
    
    private var timer: Timer?

    func toggleListening() {
        isListening.toggle()
        if isListening {
            startPolling()
        } else {
            stopPolling()
        }
    }
    
    private func startPolling() {
        // Hier würde normalerweise eine echte Verbindung zu Rust+, 
        // einem WebSocket oder FCM (Firebase Cloud Messaging) aufgebaut werden.
        // Für dieses Beispiel simulieren wir einen Trigger, wenn die URL "test" enthält.
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.checkServer()
        }
    }
    
    private func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkServer() {
        guard !webhookUrl.isEmpty else { return }
        
        if webhookUrl.lowercased().contains("test") {
            let random = Int.random(in: 1...5)
            if random == 1 {
                DispatchQueue.main.async {
                    CallManager.shared.triggerFakeCall(callerName: "🚨 RAID DETECTED 🚨")
                }
            }
        }
    }
}
