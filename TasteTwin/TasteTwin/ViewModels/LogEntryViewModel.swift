import Foundation
import Observation

@MainActor
@Observable
final class LogEntryViewModel {
    enum Mode {
        case create
        case edit(UUID)
    }

    let album: Album
    let mode: Mode

    var rating: Double = 0
    var reviewText = ""
    var tags: [String] = []
    var tagInput = ""
    var isSaving = false
    var errorMessage: String?

    private var existingLog: LogEntry?
    private var logRepository: LogRepositoryProtocol
    private var tasteUpdateCoordinator: TasteUpdateCoordinating

    init(
        album: Album,
        mode: Mode,
        logRepository: LogRepositoryProtocol,
        tasteUpdateCoordinator: TasteUpdateCoordinating
    ) {
        self.album = album
        self.mode = mode
        self.logRepository = logRepository
        self.tasteUpdateCoordinator = tasteUpdateCoordinator
    }

    func configure(
        logRepository: LogRepositoryProtocol,
        tasteUpdateCoordinator: TasteUpdateCoordinating
    ) {
        self.logRepository = logRepository
        self.tasteUpdateCoordinator = tasteUpdateCoordinator
    }

    var navigationTitle: String {
        switch mode {
        case .create:
            return "Log Album"
        case .edit:
            return "Edit Log"
        }
    }

    func loadIfNeeded() async {
        guard case .edit(let logID) = mode, existingLog == nil else { return }
        do {
            guard let log = try await logRepository.fetchLog(byID: logID) else { return }
            existingLog = log
            rating = log.rating
            reviewText = log.reviewText
            tags = log.tags
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard tags.count < Constants.maxTagCount else {
            errorMessage = "You can add up to \(Constants.maxTagCount) tags."
            return
        }

        guard !tags.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            tagInput = ""
            return
        }

        tags.append(trimmed)
        tagInput = ""
        errorMessage = nil
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        errorMessage = nil
    }

    func save() async -> Bool {
        guard rating > 0 else {
            errorMessage = "Rating is required."
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let now = Date()
            let persistedLog: LogEntry
            switch mode {
            case .create:
                let entry = LogEntry(
                    id: UUID(),
                    albumID: album.id,
                    rating: rating,
                    reviewText: reviewText.trimmingCharacters(in: .whitespacesAndNewlines),
                    tags: tags,
                    loggedAt: now,
                    updatedAt: now
                )
                persistedLog = try await logRepository.createLog(entry)
            case .edit(let id):
                let originalLoggedAt = existingLog?.loggedAt ?? now
                let entry = LogEntry(
                    id: id,
                    albumID: album.id,
                    rating: rating,
                    reviewText: reviewText.trimmingCharacters(in: .whitespacesAndNewlines),
                    tags: tags,
                    loggedAt: originalLoggedAt,
                    updatedAt: now
                )
                persistedLog = try await logRepository.updateLog(entry)
            }

            Task { @MainActor in
                await tasteUpdateCoordinator.processLog(persistedLog.id)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
