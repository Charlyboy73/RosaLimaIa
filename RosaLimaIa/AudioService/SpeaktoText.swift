import Foundation
import Speech
import Combine

class SpeaktoText: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioSession: AVAudioSession?
    private var inactivityTimer: Timer?
    private var lastRecognizedText: String = ""
    
   

    @Published var recognizedText: String?
    @Published var isProcessing: Bool = false
    var onRecognitionStop: (() -> Void)?

    func start() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession?.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Couldn't configure the audio session properly")
            return
        }
        
        inputNode = audioEngine.inputNode
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es_MX"))
        
        print("Supports on device recognition: \(speechRecognizer?.supportsOnDeviceRecognition == true ? "✅" : "🔴")")

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable,
              let recognitionRequest = recognitionRequest,
              let inputNode = inputNode
        else {
            assertionFailure("Unable to start the speech recognition!")
            return
        }
        
        speechRecognizer.delegate = self
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                self.recognizedText = recognizedText
                self.resetInactivityTimerIfNeeded(with: recognizedText)
            }
            
            if error != nil || result?.isFinal == true {
                self.stop()
            }
        }

        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isProcessing = true
            resetInactivityTimer()
        } catch {
            print("Coudn't start audio engine!")
            stop()
        }
    }
    
    func stop() {
    
        recognitionTask?.cancel()
  
        audioEngine.stop()
        
        inputNode?.removeTap(onBus: 0)
        try? audioSession?.setActive(false)
        audioSession = nil
        inputNode = nil
        
        isProcessing = false
        
        recognitionRequest = nil
        recognitionTask = nil
        speechRecognizer = nil
        
        inactivityTimer?.invalidate()
        inactivityTimer = nil

        // Ejecutar la función callback si está definida
        //onRecognitionStop?()
    }
    
    private func resetInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self!.onRecognitionStop?()
            self?.stop()
            
        }
    }
    
    private func resetInactivityTimerIfNeeded(with recognizedText: String) {
        if recognizedText != lastRecognizedText {
            lastRecognizedText = recognizedText
            resetInactivityTimer()
        }
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("✅ Available")
        } else {
            print("🔴 Unavailable")
            recognizedText = "Text recognition unavailable. Sorry!"
            stop()
        }
    }
}
