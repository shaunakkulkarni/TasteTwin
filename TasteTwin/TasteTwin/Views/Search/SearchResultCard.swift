import SwiftUI

struct SearchResultCard: View {
    let album: AlbumSearchResultDTO

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: album.artworkURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.Colors.inputBackground)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
            }
            .frame(width: 86, height: 86)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(album.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineLimit(2)
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    if let year = album.releaseYear {
                        Text(String(year))
                    }
                    if let genre = album.genreName {
                        Text(genre)
                            .lineLimit(1)
                    }
                }
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
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
