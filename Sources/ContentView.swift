import SwiftUI

struct ContentView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "speaker.wave.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                        .shadow(color: .red, radius: 10, x: 0, y: 0)
                        .padding(.top, 20)
                    
                    Text("Rust Raid Alarm")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("Dein Handy wird dich wecken. Garantiert.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Geheimes ntfy Topic (z.B. mein_alarm_99):")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        TextField("mein_geheimer_rust_alarm_123", text: $networkMonitor.topic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.bottom, 5)
                            
                        Text("Trigger über HTTP POST an:\nhttps://ntfy.sh/\(networkMonitor.topic.isEmpty ? "DEIN_TOPIC" : networkMonitor.topic)")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Button(action: {
                        networkMonitor.toggleListening()
                    }) {
                        HStack {
                            Image(systemName: networkMonitor.isListening ? "stop.fill" : "play.fill")
                            Text(networkMonitor.isListening ? "Listening stoppen" : "Alarm scharfstellen")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(networkMonitor.isListening ? Color.red : Color.green)
                        .cornerRadius(15)
                        .shadow(color: networkMonitor.isListening ? .red : .green, radius: 10, x: 0, y: 0)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        CallManager.shared.triggerFakeCall(callerName: "🚨 TEST RAID 🚨")
                    }) {
                        HStack {
                            Image(systemName: "phone.fill.arrow.down.left")
                            Text("Test Gottlosen Anruf 📞")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(15)
                        .shadow(color: .orange, radius: 5, x: 0, y: 0)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
