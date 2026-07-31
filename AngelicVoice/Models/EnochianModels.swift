import Foundation

// MARK: - Enochian Letter
struct EnochianLetter: Identifiable, Hashable {
    let id = UUID()
    let glyph: String      // Unicode/display character
    let name: String        // Letter name (romanized)
    let nameJa: String      // カタカナ読み
    let english: String     // English equivalent
    let value: Int          // Numerical value
    let meaning: String     // Symbolic meaning (English)
    let meaningJa: String   // Symbolic meaning (Japanese)
}

// MARK: - Enochian Word
struct EnochianWord: Identifiable, Hashable {
    let id = UUID()
    let enochian: String
    let english: String
    let englishJa: String   // Japanese translation
    let notes: String
    let notesJa: String     // Japanese notes

    func hash(into hasher: inout Hasher) {
        hasher.combine(enochian)
    }

    static func == (lhs: EnochianWord, rhs: EnochianWord) -> Bool {
        lhs.enochian == rhs.enochian
    }
}

// MARK: - Enochian Call
struct EnochianCall: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let titleJa: String     // Japanese title
    let lines: [CallLine]
}

struct CallLine: Identifiable {
    let id = UUID()
    let enochian: String
    let english: String
    let japanese: String    // Japanese translation of english line
}
