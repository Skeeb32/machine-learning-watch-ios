import Foundation
import Combine
protocol AIService {
    func reply(to question: String) async throws -> String
}
struct SampleAIService: AIService {
    func reply(to question: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(350))
        if question.lowercased().contains("sleep") { return "This is a sample response: the demo shows 7h 12m of sleep. Real sleep analysis is not connected yet. A consistent bedtime can be a useful routine to explore." }
        if question.lowercased().contains("activ") || question.lowercased().contains("step") { return "This is a sample response: the demo shows 8,420 steps. A short walk during a break is one simple way to add movement. This is not an analysis of your health records." }
        return "This is a sample conversation. MOMENT's live AI is not connected yet, so I cannot evaluate your question or your personal health data. Try the sleep or activity example to explore the interface." }
}
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
@MainActor final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input = ""
    @Published private(set) var isSending = false
    @Published var error: String?
    private let service: any AIService
    init(service: any AIService = SampleAIService()) { self.service = service }
    func send() async {
        let question = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isSending else { return }
        input = ""; error = nil; isSending = true
        messages.append(ChatMessage(text: question, isUser: true))
        defer { isSending = false }
        do { messages.append(ChatMessage(text: try await service.reply(to: question), isUser: false)) }
        catch { self.error = "Could not load the sample response. Please try again." }
    }
}
