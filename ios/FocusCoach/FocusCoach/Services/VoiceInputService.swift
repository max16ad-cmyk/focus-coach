//
//  VoiceInputService.swift
//  FocusCoach
//
//  Einfacher Speech-to-Text Service - Nur Spracherkennung, keine Parsing-Logik
//

import Foundation
import Combine
import Speech
import AVFoundation

@MainActor
class VoiceInputService: NSObject, ObservableObject {
    static let shared = VoiceInputService()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var isListening = false
    @Published var recognizedText = "" // Live-Transkription während des Sprechens
    @Published var audioLevel: CGFloat = 0.0 // Für Wellen-Animation
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        requestAuthorization()
    }
    
    /// Fragt Berechtigung für Spracherkennung an
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
            }
        }
    }
    
    /// Startet Spracherkennung - gibt Live-Updates über recognizedText
    func startListening() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            AppLogger.shared.error("❌ Speech recognizer not available")
            return
        }
        
        guard authorizationStatus == .authorized else {
            AppLogger.shared.error("❌ Speech recognition not authorized")
            requestAuthorization()
            return
        }
        
        // Stoppe vorherige Erkennung
        stopListening()
        
        // Audio Session Setup
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            AppLogger.shared.error("❌ Audio session setup failed: \(error)")
            return
        }
        
        // Recognition Request
        let request = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest = request
        request.shouldReportPartialResults = true // WICHTIG: Live-Updates
        
        // Audio Engine Setup
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Format validieren
        let formatToUse: AVAudioFormat
        if recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 {
            formatToUse = recordingFormat
        } else {
            guard let fallbackFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
                AppLogger.shared.error("❌ Could not create fallback format")
                stopListening()
                return
            }
            formatToUse = fallbackFormat
        }
        
        // Install tap - mit Audio-Level-Messung
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: formatToUse) { [weak self] buffer, _ in
            guard let self = self else { return }
            request.append(buffer)
            
            // Audio-Level für Wellen-Animation - VERBESSERTE Messung
            guard let channelData = buffer.floatChannelData else { return }
            let channelDataValue = channelData.pointee
            let frameLength = Int(buffer.frameLength)
            
            // Berechne RMS (Root Mean Square) Schritt für Schritt
            var sum: Float = 0.0
            for i in 0..<frameLength {
                let sample = channelDataValue[i]
                sum += sample * sample
            }
            let rms = sqrt(sum / Float(frameLength))
            
            // Normalisierung mit stärkerer Multiplikation für bessere Sichtbarkeit
            let normalizedLevel = min(1.0, max(0.0, CGFloat(rms) * 25.0))
            
            DispatchQueue.main.async {
                self.audioLevel = normalizedLevel
            }
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isListening = true
            recognizedText = "" // Reset
        } catch {
            AppLogger.shared.error("❌ Audio engine start failed: \(error)")
            return
        }
        
        // Start Recognition - KONTINUIERLICH mit Live-Updates
        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let newText = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.recognizedText = newText // Live-Update
                }
            }
            
            // Nur bei kritischen Fehlern stoppen
            if let error = error {
                let errorCode = (error as NSError).code
                if errorCode != 216 { // 216 = cancelled (OK)
                    AppLogger.shared.warning("⚠️ Speech recognition error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Stoppt Spracherkennung
    func stopListening() {
        audioLevel = 0.0
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
        
        // Audio Session zurücksetzen
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
