import Foundation
import CallKit
import AVFoundation
import AudioToolbox

class CallManager: NSObject, ObservableObject, CXProviderDelegate {
    static let shared = CallManager()
    private var provider: CXProvider!
    private let callController = CXCallController()

    override init() {
        super.init()
        let configuration = CXProviderConfiguration()
        configuration.includesCallsInRecents = true
        configuration.supportsVideo = false
        // Wenn eine Custom MP3 im Bundle wäre:
        // configuration.ringtoneSound = "gottlos_laut.mp3"
        
        provider = CXProvider(configuration: configuration)
        provider.setDelegate(self, queue: nil)
    }

    func triggerFakeCall(callerName: String = "🚨 RUST RAID ALARM 🚨") {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: callerName)
        update.hasVideo = false

        let uuid = UUID()
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("CallKit Error: \(error.localizedDescription)")
            } else {
                print("Call triggered successfully.")
            }
        }
    }

    // MARK: - CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {}

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        // Wenn der Anruf angenommen wird, startet der "gottlose" Alarm-Sound!
        SirenPlayer.shared.playGottlosenSound()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        SirenPlayer.shared.stop()
    }
}

class SirenPlayer {
    static let shared = SirenPlayer()
    private var engine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    
    func playGottlosenSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .alarm, options: [.duckOthers, .overrideMutedMicrophoneInterruption])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Error: \(error)")
        }
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Engine Start Error: \(error)")
            return
        }
        
        let sampleRate = Float(format.sampleRate)
        let duration: Float = 2.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(format.channelCount))
        let data = channels[0]
        
        var currentPhase: Float = 0.0
        
        // Generiere einen absolut nervigen Square-Wave Sirenensound (wechselt zwischen 800Hz und 1200Hz)
        for i in 0..<Int(frameCount) {
            let mod = sin(Float(i) / sampleRate * 2.0 * .pi * 4.0) // 4 Hz Modulation
            let freq = 1000.0 + mod * 400.0 
            let phaseInc = (2.0 * .pi * freq) / sampleRate
            
            // Square Wave für maximale Lautstärke und Hässlichkeit (Clipping Style)
            data[i] = sin(currentPhase) > 0 ? 1.0 : -1.0
            currentPhase += phaseInc
            if currentPhase > 2.0 * .pi { currentPhase -= 2.0 * .pi }
        }
        
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        playerNode.play()
        
        // Zusätzliche Vibration
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func stop() {
        playerNode.stop()
        engine.stop()
    }
}
