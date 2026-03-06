import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \LogEntryRecord.loggedAt, order: .reverse)
    private var recentLogs: [LogEntryRecord]

    @Query private var dimensions: [TasteDimensionRecord]

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Total Logs", value: "\(recentLogs.count)")
                if let topDimension = dimensions.sorted(by: { $0.weight > $1.weight }).first {
                    LabeledContent("Top Dimension", value: topDimension.name)
                }
            }

            Section("Recent Logs") {
                if recentLogs.isEmpty {
                    Text("No logs yet. Start from Search.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recentLogs.prefix(5)) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.album?.title ?? "Unknown Album")
                                .font(.headline)
                            Text(log.album?.artistName ?? "Unknown Artist")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Rating: \(log.rating, specifier: "%.1f")")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Home")
    }
}

#Preview {
    HomeView()
        .modelContainer(AppEnvironment.preview().modelContainer)
        .environment(\.appEnvironment, .preview())
}
