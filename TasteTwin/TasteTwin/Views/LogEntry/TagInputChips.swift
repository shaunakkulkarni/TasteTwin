import SwiftUI

struct TagInputChips: View {
    @Binding var tags: [String]
    @Binding var text: String
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("Add tag", text: $text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.Colors.inputBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button("Add", action: onAdd)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.Colors.accentMuted)
            }

            if !tags.isEmpty {
                FlowLayout(tags) { tag in
                    HStack(spacing: 6) {
                        Text(tag)
                            .font(.caption)
                        Button {
                            tags.removeAll { $0 == tag }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(AppTheme.Colors.inputBackground, in: Capsule())
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let content: (Data.Element) -> Content

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8, alignment: .leading)], alignment: .leading, spacing: 8) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
            }
        }
    }
}
