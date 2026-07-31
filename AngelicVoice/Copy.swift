import Foundation

/// 日英の文言を一箇所に集約。Locale で ja / それ以外=en を選ぶ。
struct Copy {
    let title: String
    let subtitle: String
    let intro: String            // 冒頭の案内
    let listening: String        // 録音中ラベル
    let tapToSpeak: String       // マイク案内
    let thinking: String         // 天使が応答生成中
    let unavailableTitle: String // AI非対応端末の見出し
    let unavailableBody: String
    let permissionDenied: String
    let angelLabel: String
    let youLabel: String
    let persona: String          // Foundation Models への人格指示（英語で与える）
    let greetingEN: String       // 起動時の天使の第一声（英語ピボット）
    let greetingJA: String       // その日本語訳

    static let ja = Copy(
        title: "天使の声",
        subtitle: "Angelic Voice",
        intro: "静かに話しかけてください。天使が古の言葉で答えます。",
        listening: "聴いています…",
        tapToSpeak: "タップして話す",
        thinking: "天使が言葉を編んでいます…",
        unavailableTitle: "この端末では天使と交信できません",
        unavailableBody: "Apple Intelligence に対応した端末（iOS 26）が必要です。",
        permissionDenied: "マイクと音声認識の許可が必要です。設定から有効にしてください。",
        angelLabel: "天使",
        youLabel: "あなた",
        persona: personaText,
        greetingEN: "Move and show yourself. Speak, and I will answer.",
        greetingJA: "動きて姿を現せ。語れ、我が答えよう。"
    )

    static let en = Copy(
        title: "Angelic Voice",
        subtitle: "天使の声",
        intro: "Speak softly. The angel answers in the ancient tongue.",
        listening: "Listening…",
        tapToSpeak: "Tap to speak",
        thinking: "The angel is weaving words…",
        unavailableTitle: "This device cannot commune",
        unavailableBody: "A device with Apple Intelligence (iOS 26) is required.",
        permissionDenied: "Microphone and speech recognition access are required. Enable them in Settings.",
        angelLabel: "Angel",
        youLabel: "You",
        persona: personaText,
        greetingEN: "Move and show yourself. Speak, and I will answer.",
        greetingJA: "動きて姿を現せ。語れ、我が答えよう。"
    )

    static var current: Copy {
        Locale.current.language.languageCode?.identifier == "ja" ? .ja : .en
    }

    /// 天使の人格。占い断定を明確に禁止し、象徴的で穏やかな短文に限定する。
    private static let personaText = """
    You are an angelic messenger who speaks the old Enochian tongue. \
    A seeker speaks to you. Answer with a single short message: gentle, symbolic, timeless. \
    Keep it to at most twelve simple English words, plain vocabulary. \
    You are atmospheric and poetic, never a fortune teller. \
    Never predict the future, never state what will happen, never give medical, legal, or financial advice, \
    never make definite claims about the seeker's fate or health. \
    If asked to foretell, gently turn the answer toward reflection and inner light instead. \
    Reply with exactly two lines and nothing else:
    EN: <the short English message>
    JA: <a natural Japanese translation of that message>
    """
}
