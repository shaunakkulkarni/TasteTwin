import SwiftUI

struct LogCardView: View {
    let item: LogDisplayItem

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: item.artworkURL ?? "")) { image in
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
            .frame(width: 82, height: 82)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.albumTitle)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineLimit(2)

                Text(item.artistName)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text("\(item.rating, specifier: "%.1f")")
                    Text(item.loggedAt, format: .dateTime.month().day().year())
                }
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)

                Text(item.reviewPreview)
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
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
