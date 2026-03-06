import SwiftUI

struct AlbumHeroCard: View {
    let album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AsyncImage(url: URL(string: album.artworkURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.Colors.inputBackground)
                    .overlay {
                        Image(systemName: "music.note.list")
                            .font(.title2)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(album.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(album.artistName)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                HStack(spacing: 12) {
                    if let year = album.releaseYear {
                        Label(String(year), systemImage: "calendar")
                    }
                    if let genre = album.genreName {
                        Label(genre, systemImage: "guitars")
                    }
                    if let trackCount = album.trackCount {
                        Label("\(trackCount)", systemImage: "music.note")
                    }
                }
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .lineLimit(1)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous)
                .fill(AppTheme.Colors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous)
                        .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                )
        )
    }
}
