import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \LogEntryRecord.loggedAt, order: .reverse)
    private var logs: [LogEntryRecord]

    private var averageRating: Double {
        guard !logs.isEmpty else { return 0 }
        return logs.map(\.rating).reduce(0, +) / Double(logs.count)
    }

    private var recentTags: [String] {
        Array(Set(logs.flatMap(\.tags))).sorted().prefix(6).map { $0 }
    }

    var body: some View {
        List {
            Section("Stats") {
                LabeledContent("Total Logs", value: "\(logs.count)")
                LabeledContent("Average Rating", value: String(format: "%.2f", averageRating))
            }

            Section("Recent Tags") {
                if recentTags.isEmpty {
                    Text("No tags yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recentTags, id: \.self) { tag in
                        Text(tag)
                    }
                }
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView()
        .modelContainer(AppEnvironment.preview().modelContainer)
        .environment(\.appEnvironment, .preview())
}
