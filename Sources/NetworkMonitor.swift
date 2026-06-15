import Foundation

class NetworkMonitor: NSObject, ObservableObject, URLSessionDataDelegate {
    @Published var isListening = false
    @Published var topic: String = "" 
    
    private var session: URLSession?
    private var task: URLSessionDataTask?

    func toggleListening() {
        isListening.toggle()
        if isListening {
            startListening()
        } else {
            stopListening()
        }
    }
    
    private func startListening() {
        let cleanTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")
        guard !cleanTopic.isEmpty else {
            isListening = false
            return
        }
        
        // Wir nutzen den kostenlosen Service "ntfy.sh" als Bridge!
        // Endpunkt liefert einen durchgehenden JSON-Stream bei neuen Nachrichten.
        let urlString = "https://ntfy.sh/\(cleanTopic)/json"
        guard let url = URL(string: urlString) else { return }
        
        let configuration = URLSessionConfiguration.default
        // Timeout extrem hoch setzen, da es ein konstanter Stream ist
        configuration.timeoutIntervalForRequest = TimeInterval(Int.max)
        configuration.timeoutIntervalForResource = TimeInterval(Int.max)
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        task = session?.dataTask(with: url)
        task?.resume()
        print("Lausche auf ntfy Topic: \(urlString)")
    }
    
    private func stopListening() {
        task?.cancel()
        session?.invalidateAndCancel()
        task = nil
        session = nil
        print("Lauschen beendet.")
    }
    
    // MARK: - URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let stringData = String(data: data, encoding: .utf8) else { return }
        print("Eingehende Daten: \(stringData)")
        
        // ntfy schickt "keepalive" (leer) und "message" (bei echten Triggern)
        if stringData.contains("\"event\":\"message\"") || stringData.contains("\"event\": \"message\"") {
            DispatchQueue.main.async {
                CallManager.shared.triggerFakeCall(callerName: "🚨 RUST SMART ALARM 🚨")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Verbindung getrennt: \(error.localizedDescription)")
            // Auto-Reconnect falls wir noch lauschen sollten
            DispatchQueue.main.async {
                if self.isListening {
                    print("Versuche Reconnect...")
                    self.startListening()
                }
            }
        }
    }
}
