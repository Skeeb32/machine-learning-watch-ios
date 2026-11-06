import SwiftUI
public enum Midnight {
    public static let background = Color(red: 16/255, green: 24/255, blue: 32/255)
    public static let surface = Color(red: 26/255, green: 41/255, blue: 49/255)
    public static let elevated = Color(red: 32/255, green: 49/255, blue: 58/255)
    public static let mint = Color(red: 142/255, green: 219/255, blue: 203/255)
}
public struct MomentCard<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Midnight.surface, in: RoundedRectangle(cornerRadius: 24))
    }
}
public struct SourceBadge: View {
    let source: DataSource
    public init(_ source: DataSource) { self.source = source }
    public var body: some View {
        Label(source == .sample ? "SAMPLE DATA" : "APPLE HEALTH", systemImage: source == .sample ? "sparkles" : "heart")
            .font(.caption2.weight(.semibold)).tracking(1.4).foregroundStyle(Midnight.mint)
    }
}
