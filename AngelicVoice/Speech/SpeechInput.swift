import Foundation
import AVFoundation
import Speech

/// マイク音声を SFSpeechRecognizer で文字起こしする。ユーザーの発話専用。
@MainActor
final class SpeechInput: ObservableObject {
    /// failed = 録音・認識を始められなかった（画面で理由を伝え、文字入力を案内する）
    enum Status { case idle, listening, denied, failed }

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
        teardown()
        if status == .listening { status = .idle }
        return transcript
    }

    private func teardown() {
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func fail() {
        teardown()
        status = .failed
    }

    private func beginSession() {
        guard let recognizer, recognizer.isAvailable else { fail(); return }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            fail()
            return
        }

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        // オンデバイス認識を強制しない。音声認識のモデルが端末に無い場合や
        // 音声入力がオフの端末では、強制すると即座に失敗する（2.1 で却下された原因）。
        req.requiresOnDeviceRecognition = false
        request = req

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else { fail(); return }
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            fail()
            return
        }
        status = .listening

        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                // 停止ボタンで終えたあとのキャンセル通知は無視する
                guard self.status == .listening else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if error != nil && self.transcript.isEmpty {
                    self.fail()
                } else if error != nil || (result?.isFinal ?? false) {
                    self.stop()
                }
            }
        }
    }
}
