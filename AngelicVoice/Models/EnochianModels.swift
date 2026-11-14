import Foundation

// MARK: - Enochian Letter
struct EnochianLetter: Identifiable, Hashable {
    let order: Int          // position in Dee's table
    let name: String        // Dee's name for the letter
    let nameJa: String      // カタカナ読み
    let latin: String       // Latin value; the EnochianDee font draws the glyph for it
    let alternates: String  // later equivalents (K for Veh, Y/J for Gon, U/W for Van)
    let gdValue: Int        // number in later Golden Dawn / Crowley tables
    var id: Int { order }

    /// "C / K", "I / Y / J"
    var latinLabel: String { ([latin] + alternates.map(String.init)).joined(separator: " / ") }
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
