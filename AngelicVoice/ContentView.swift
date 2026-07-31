import SwiftUI

struct ContentView: View {
    @StateObject private var convo = ConversationModel()
    @StateObject private var speech = SpeechInput()

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

            // エノク語（主）
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
            } else if speech.status == .denied {
                Text(copy.permissionDenied)
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
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
    }

    private func toggleMic() {
        switch speech.status {
        case .listening:
            let text = speech.stop()
            convo.send(text)
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
