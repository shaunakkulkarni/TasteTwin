import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var query = ""
    @Query(sort: \AlbumRecord.title)
    private var albums: [AlbumRecord]

    private var filteredAlbums: [AlbumRecord] {
        guard !query.isEmpty else { return albums }
        return albums.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artistName.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        List(filteredAlbums) { album in
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.headline)
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let genre = album.genreName {
                    Text(genre)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .navigationTitle("Search")
        .searchable(text: $query, prompt: "Album or artist")
    }
}

#Preview {
    SearchView()
        .modelContainer(AppEnvironment.preview().modelContainer)
        .environment(\.appEnvironment, .preview())
}
