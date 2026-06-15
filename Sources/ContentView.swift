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
                        Text("Webhook Trigger URL:")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        TextField("https://...", text: $networkMonitor.webhookUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .padding(.bottom, 5)
                            
                        Text("Gib 'test' ein, um zufällige Alarme zu simulieren.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Button(action: {
                        networkMonitor.toggleListening()
                    }) {
                        HStack {
                            Image(systemName: networkMonitor.isListening ? "stop.fill" : "play.fill")
                            Text(networkMonitor.isListening ? "Listening stoppen" : "Alarm aktivieren")
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
