import Foundation
import FoundationModels

/// オンデバイスの Foundation Models を天使の人格でラップする。
/// iOS 26 / Apple Intelligence 対応端末でのみ動く。未対応なら .unavailable。
@MainActor
final class AngelSession: ObservableObject {
    enum Availability { case ready, unavailable }

    @Published private(set) var availability: Availability = .unavailable

    private var session: LanguageModelSession?

    init() {
        switch SystemLanguageModel.default.availability {
        case .available:
            availability = .ready
            session = LanguageModelSession(instructions: Copy.current.persona)
        default:
            availability = .unavailable
        }
    }

    /// 求道者の言葉を受けて、天使の応答を英語ピボット＋日本語で返す。
    func consult(_ seekerText: String) async -> (english: String, japanese: String) {
        guard let session else {
            return ("", "")
        }
        let prompt = "The seeker says: \"\(seekerText)\". Answer now."
        var full = ""
        do {
            for try await partial in session.streamResponse(to: prompt) {
                full = partial.content
            }
        } catch {
            return ("", "")
        }
        return parse(full)
    }

    /// "EN: ...\nJA: ..." 形式を分解。崩れていても最善を返す。
    private func parse(_ text: String) -> (english: String, japanese: String) {
        var en = ""
        var ja = ""
        for line in text.split(whereSeparator: { $0 == "\n" }) {
            let s = line.trimmingCharacters(in: .whitespaces)
            if let r = s.range(of: "EN:", options: .caseInsensitive), r.lowerBound == s.startIndex {
                en = String(s[r.upperBound...]).trimmingCharacters(in: .whitespaces)
            } else if let r = s.range(of: "JA:", options: .caseInsensitive), r.lowerBound == s.startIndex {
                ja = String(s[r.upperBound...]).trimmingCharacters(in: .whitespaces)
            }
        }
        if en.isEmpty && ja.isEmpty {
            // フォーマット無視で返ってきた場合は全文を英語ピボット扱い。
            en = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if ja.isEmpty { ja = en }
        return (en, ja)
    }
}
