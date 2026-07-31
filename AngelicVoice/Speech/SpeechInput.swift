import Foundation
import AVFoundation
import Speech

/// マイク音声を SFSpeechRecognizer で文字起こしする。ユーザーの発話専用。
@MainActor
final class SpeechInput: ObservableObject {
    enum Status { case idle, listening, denied, unavailable }

    @Published private(set) var status: Status = .idle
    @Published private(set) var transcript: String = ""

    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    init() {
        let id = Locale.current.language.languageCode?.identifier == "ja" ? "ja-JP" : "en-US"
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: id))
    }

    /// 権限を要求して録音を開始。すでに録音中なら何もしない。
    func start() {
        guard status != .listening else { return }
        transcript = ""

        SFSpeechRecognizer.requestAuthorization { [weak self] auth in
            guard let self else { return }
            Task { @MainActor in
                guard auth == .authorized else { self.status = .denied; return }
                AVAudioApplication.requestRecordPermission { granted in
                    Task { @MainActor in
                        guard granted else { self.status = .denied; return }
                        self.beginSession()
                    }
                }
            }
        }
    }

    /// 録音を停止して、確定した文字列を返す。
    @discardableResult
    func stop() -> String {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.finish()
        request = nil
        task = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        if status == .listening { status = .idle }
        return transcript
    }

    private func beginSession() {
        guard let recognizer, recognizer.isAvailable else { status = .unavailable; return }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            status = .unavailable
            return
        }

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition {
            req.requiresOnDeviceRecognition = true
        }
        request = req

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            status = .unavailable
            return
        }
        status = .listening

        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stop()
                }
            }
        }
    }
}
