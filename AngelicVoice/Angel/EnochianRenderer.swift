import Foundation

/// 英語ピボット文を、収録済みエノク語辞典（EnochianData）で語ごとにエノク語（ラテン翻字）へ変換する。
/// 辞典にない語はそのまま大文字で残す（エノク語もラテン翻字で表記されるため自然に馴染む）。
enum EnochianRenderer {

    /// english（EnochianWord.english）→ enochian の逆引き。
    /// "show yourselves" のような句は全体キーと、意味語ごとのキーの両方に登録。
    private static let lookup: [String: String] = {
        var map: [String: String] = [:]
        // 語彙を補うための基礎対応（頻出語）。既存辞典の意味に沿って割り当てる。
        let base: [String: String] = [
            "i": "OL", "me": "OL", "my": "OZIEN", "we": "AAIOM", "us": "AAIOM",
            "you": "VORSG", "your": "VORSG", "yourself": "AMIRAN", "yourselves": "ZAMRAN",
            "and": "OD", "the": "DS", "of": "DS", "is": "ZIRDO", "am": "ZIRDO", "are": "CHIS",
            "not": "GE", "for": "LAP", "which": "DS", "in": "ZOMD", "over": "VORS",
            "god": "IAD", "lord": "ENAY", "light": "LOHOLO", "fire": "MALPRG", "flame": "PRGE",
            "truth": "VAOAN", "justice": "BALT", "wisdom": "ANANAEL", "knowledge": "IADNAH",
            "heart": "ZOL", "hands": "ZOL", "voice": "FAAIP", "voices": "FAAIP",
            "come": "ZACAR", "move": "ZACAR", "arise": "TORZU", "rise": "TORZUL",
            "show": "ZAMRAN", "open": "ODO", "behold": "MICMA", "see": "MICMA",
            "creation": "QAAN", "earth": "CAOSG", "heaven": "CALZ", "sun": "ROR", "moon": "GRAA",
            "peace": "ZORGE", "friendly": "ZORGE", "kind": "ZORGE", "faith": "GONO",
            "mind": "MANIN", "soul": "GIGIPAH", "breath": "GIGIPAH", "life": "GIGIPAH",
            "power": "LONSA", "strong": "MICAOLZ", "mighty": "MICAOLZ", "reign": "SONF",
            "beginning": "IAOD", "end": "UL", "mystery": "CICLE", "mysteries": "CICLE",
            "beauty": "TURBS", "become": "NOAR", "understand": "OM", "shine": "LOHOLO",
            "balance": "PIAP", "circle": "COMSELH", "descend": "UNIGLAG", "wings": "VPAAH",
            "winds": "ZONG", "wind": "ZONG", "measure": "HOLQ", "creator": "QAAL",
            "servant": "NOCO", "true": "HOATH", "highest": "IAIDA", "eternal": "IOIAD",
        ]
        for (k, v) in base { map[k] = v }
        // 収録辞典から english の各語を割り当て（既存キーは上書きしない＝基礎対応を優先）。
        for w in EnochianData.dictionary {
            let phrase = w.english.lowercased()
            for token in phrase.split(separator: " ") {
                let key = String(token).trimmingCharacters(in: .punctuationCharacters)
                if key.count >= 2 && map[key] == nil {
                    map[key] = w.enochian
                }
            }
        }
        return map
    }()

    /// 英語ピボット文をエノク語（ラテン翻字・大文字）に変換して返す。
    static func render(_ english: String) -> String {
        let tokens = english.split(whereSeparator: { $0 == " " || $0 == "\n" })
        var out: [String] = []
        for raw in tokens {
            let cleaned = raw.lowercased().trimmingCharacters(in: .punctuationCharacters)
            guard !cleaned.isEmpty else { continue }
            if let hit = lookup[cleaned] {
                out.append(hit)
            } else {
                out.append(cleaned.uppercased())
            }
        }
        return out.joined(separator: " ")
    }
}
