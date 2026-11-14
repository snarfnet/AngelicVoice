import SwiftUI

struct ContentView: View {
    @StateObject private var convo = ConversationModel()
    @StateObject private var speech = SpeechInput()
    @State private var typed = ""
    @FocusState private var typing: Bool

    private let copy = Copy.current

    var body: some View {
        ZStack {
            StarfieldBackground()

            switch convo.availability {
            case .ready:
                conversationView
            case .unavailable:
                unavailableView
            }
        }
        .onAppear { convo.begin() }
        // 録音が終わったら（停止ボタンでも、認識が自然に終わっても）、聞き取った言葉を送る
        .onChange(of: speech.status) { old, new in
            if old == .listening && new == .idle { convo.send(speech.transcript) }
        }
    }

    // MARK: - 交信画面

    private var conversationView: some View {
        VStack(spacing: 0) {
            header

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(convo.messages) { message in
                            messageRow(message)
                                .id(message.id)
                        }

                        if convo.isThinking {
                            thinkingRow
                                .id("thinking")
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                }
                .onChange(of: convo.messages.count) { _, _ in
                    scrollToBottom(proxy)
                }
                .onChange(of: convo.isThinking) { _, _ in
                    scrollToBottom(proxy)
                }
            }

            micBar
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text(copy.title)
                .font(.system(size: 26, weight: .light))
                .foregroundColor(Celestial.starWhite)
                .tracking(4)

            Text(copy.subtitle)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Celestial.faintStar)
                .tracking(2)

            SacredDivider()
                .padding(.horizontal, 40)
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    // MARK: - メッセージ

    @ViewBuilder
    private func messageRow(_ message: ChatMessage) -> some View {
        switch message.role {
        case .angel:
            angelCard(message)
        case .you:
            youBubble(message)
        }
    }

    private func angelCard(_ message: ChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(copy.angelLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Celestial.angelGold.opacity(0.8))
                .tracking(3)

            // エノク文字（ディーの字形）
            Text(message.enochian)
                .font(EnochianFont.font(26))
                .foregroundColor(Celestial.runeGlow)
                .lineSpacing(6)
                .celestialGlow(Celestial.glowBlue)

            // エノク語（ローマ字）
            Text(message.enochian)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(Celestial.runeGlow)
                .tracking(2)
                .celestialGlow(Celestial.glowBlue)

            // 日本語
            Text(message.japanese)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Celestial.starWhite)

            // 英語ピボット（控えめ）
            Text(message.english)
                .font(.system(size: 13, weight: .light))
                .italic()
                .foregroundColor(Celestial.faintStar)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private func youBubble(_ message: ChatMessage) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(copy.youLabel)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Celestial.glowCyan.opacity(0.7))
                .tracking(2)

            Text(message.english)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Celestial.silver)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Celestial.nebula.opacity(0.5))
                )
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var thinkingRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14))
                .foregroundColor(Celestial.angelGold.opacity(0.8))
            Text(copy.thinking)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Celestial.faintStar)
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    // MARK: - マイク

    private var micBar: some View {
        VStack(spacing: 10) {
            if speech.status == .listening {
                Text(speech.transcript.isEmpty ? copy.listening : speech.transcript)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Celestial.starWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
            } else if speech.status == .denied || speech.status == .failed {
                Text(speech.status == .denied ? copy.permissionDenied : copy.speechFailed)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Celestial.angelGold.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Button(action: toggleMic) {
                ZStack {
                    Circle()
                        .fill(
                            speech.status == .listening
                                ? Celestial.glowCyan.opacity(0.35)
                                : Celestial.deepIndigo.opacity(0.7)
                        )
                        .frame(width: 72, height: 72)
                        .overlay(
                            Circle().stroke(
                                speech.status == .listening ? Celestial.glowCyan : Celestial.glowBlue.opacity(0.5),
                                lineWidth: 1.5
                            )
                        )

                    Image(systemName: speech.status == .listening ? "waveform" : "mic.fill")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(speech.status == .listening ? Celestial.glowCyan : Celestial.runeGlow)
                }
                .celestialGlow(speech.status == .listening ? Celestial.glowCyan : Celestial.glowBlue)
            }
            .disabled(convo.isThinking)

            Text(speech.status == .listening ? copy.listening : copy.tapToSpeak)
                .font(.system(size: 11, weight: .light))
                .foregroundColor(Celestial.faintStar)
                .tracking(1)

            textInput
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
    }

    /// 声が使えない時・使いたくない時のための文字入力。
    private var textInput: some View {
        HStack(spacing: 8) {
            TextField(copy.typeHere, text: $typed)
                .focused($typing)
                .submitLabel(.send)
                .onSubmit(sendTyped)
                .font(.system(size: 15))
                .foregroundColor(Celestial.starWhite)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 18).fill(Celestial.deepIndigo.opacity(0.7)))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Celestial.glowBlue.opacity(0.3), lineWidth: 1))
            Button(action: sendTyped) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(typed.trimmingCharacters(in: .whitespaces).isEmpty ? Celestial.faintStar.opacity(0.4) : Celestial.glowCyan)
            }
            .disabled(typed.trimmingCharacters(in: .whitespaces).isEmpty || convo.isThinking)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    private func sendTyped() {
        let text = typed
        typed = ""
        typing = false
        convo.send(text)
    }

    private func toggleMic() {
        switch speech.status {
        case .listening:
            speech.stop()   // the transcript is sent from onChange(of: speech.status)
        default:
            speech.start()
        }
    }

    // MARK: - 非対応端末

    private var unavailableView: some View {
        VStack(spacing: 18) {
            Image(systemName: "moon.stars")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(Celestial.runeGlow.opacity(0.7))
                .celestialGlow(Celestial.glowBlue)

            Text(copy.unavailableTitle)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(Celestial.starWhite)
                .multilineTextAlignment(.center)

            Text(copy.unavailableBody)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Celestial.faintStar)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .glassCard()
        .padding(30)
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            if convo.isThinking {
                proxy.scrollTo("thinking", anchor: .bottom)
            } else if let last = convo.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
