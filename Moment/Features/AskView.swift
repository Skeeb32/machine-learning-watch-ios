import SwiftUI
import MomentShared
struct AskView: View {
    @StateObject private var model = ChatViewModel()
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            SourceBadge(.sample)
                            Text("A little perspective.").font(.system(.largeTitle, design: .serif))
                            Text("Explore a sample conversation. Live AI is not connected, and no health data is sent to a server.").foregroundStyle(.secondary)
                            ForEach(["How was my sleep?", "What does my activity look like?"], id: \.self) { prompt in
                                Button { model.input = prompt; Task { await model.send() } } label: {
                                    Label(prompt, systemImage: "arrow.up.left").font(.subheadline).frame(maxWidth: .infinity, alignment: .leading).padding(14).background(Midnight.surface, in: RoundedRectangle(cornerRadius: 16))
                                }.disabled(model.isSending)
                            }
                            ForEach(model.messages) { message in
                                MomentCard {
                                    Text(message.isUser ? "YOU" : "MOMENT · SAMPLE").font(.caption2.weight(.semibold)).foregroundStyle(Midnight.mint)
                                    Text(message.text).textSelection(.enabled)
                                }.id(message.id)
                            }
                            if model.isSending { ProgressView("Preparing sample response…") }
                            if let error = model.error { Text(error).foregroundStyle(.orange) }
                        }.padding(22)
                    }.onChange(of: model.messages.count) { _, _ in if let id = model.messages.last?.id { proxy.scrollTo(id, anchor: .bottom) } }
                }
                HStack(alignment: .bottom) {
                    TextField("Ask a question…", text: $model.input, axis: .vertical).lineLimit(1...4).textFieldStyle(.plain).padding(14).background(Midnight.surface, in: RoundedRectangle(cornerRadius: 18)).accessibilityIdentifier("chatInput")
                    Button { Task { await model.send() } } label: { Image(systemName: "arrow.up").font(.title3.bold()).frame(width: 44, height: 44) }
                        .buttonStyle(.borderedProminent).clipShape(Circle()).accessibilityLabel("Send question")
                        .disabled(model.isSending || model.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }.padding(16)
            }.background(Midnight.background).navigationTitle("Ask MOMENT")
        }
    }
}
