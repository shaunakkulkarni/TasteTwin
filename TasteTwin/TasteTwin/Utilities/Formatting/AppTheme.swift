import SwiftUI

enum AppTheme {
    enum Colors {
        static let background = Color(red: 0.06, green: 0.07, blue: 0.09)
        static let card = Color(red: 0.12, green: 0.13, blue: 0.16)
        static let cardBorder = Color.white.opacity(0.06)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.72)
        static let textTertiary = Color.white.opacity(0.52)
        static let accentMuted = Color(red: 0.62, green: 0.68, blue: 0.78)
        static let inputBackground = Color.white.opacity(0.06)
        static let success = Color(red: 0.48, green: 0.74, blue: 0.64)
        static let danger = Color(red: 0.84, green: 0.42, blue: 0.42)
    }

    enum Layout {
        static let cardRadius: CGFloat = 20
        static let contentPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 20
        static let cardSpacing: CGFloat = 14
    }
}
