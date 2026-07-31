import Foundation

struct ChatMessage: Identifiable {
    enum Role { case you, angel }
    let id = UUID()
    let role: Role
    let enochian: String   // 天使のみ
    let english: String
    let japanese: String

    static func you(_ text: String) -> ChatMessage {
        ChatMessage(role: .you, enochian: "", english: text, japanese: text)
    }

    static func angel(enochian: String, english: String, japanese: String) -> ChatMessage {
        ChatMessage(role: .angel, enochian: enochian, english: english, japanese: japanese)
    }
}

@MainActor
final class ConversationModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isThinking = false

    let availability: AngelSession.Availability
    private let angel = AngelSession()

    init() {
        availability = angel.availability
    }

    /// 起動時、天使が先に語りかける。
    func begin() {
        guard messages.isEmpty else { return }
        let c = Copy.current
        messages.append(.angel(
            enochian: EnochianRenderer.render(c.greetingEN),
            english: c.greetingEN,
            japanese: c.greetingJA
        ))
    }

    /// 求道者の言葉を送り、天使の応答を得る。
    func send(_ text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, !isThinking else { return }
        messages.append(.you(clean))
        isThinking = true
        Task {
            let reply = await angel.consult(clean)
            isThinking = false
            let en = reply.english.isEmpty ? "Peace be with you." : reply.english
            let ja = reply.japanese.isEmpty ? "安らかにあれ。" : reply.japanese
            messages.append(.angel(
                enochian: EnochianRenderer.render(en),
                english: en,
                japanese: ja
            ))
        }
    }
}
