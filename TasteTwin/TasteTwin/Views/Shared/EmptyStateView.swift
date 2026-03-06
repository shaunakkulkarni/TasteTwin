import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "music.note.list")
                .font(.title3)
                .foregroundStyle(AppTheme.Colors.textTertiary)

            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
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
