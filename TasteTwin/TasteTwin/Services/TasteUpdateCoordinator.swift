import Foundation

@MainActor
protocol TasteUpdateCoordinating {
    func processLog(_ logID: UUID) async
    func retryPending(limit: Int) async
    func retryFailed(limit: Int) async
    func processLogDeletion(_ logID: UUID) async
}

@MainActor
final class TasteUpdateCoordinator: TasteUpdateCoordinating {
    private let statusRepository: TasteUpdateStatusRepositoryProtocol
    private let logRepository: LogRepositoryProtocol
    private let albumRepository: AlbumRepositoryProtocol
    private let tasteRepository: TasteRepositoryProtocol
    private let extractionService: TasteExtractionServiceProtocol
    private let tasteProfileService: TasteProfileServiceProtocol

    init(
        statusRepository: TasteUpdateStatusRepositoryProtocol,
        logRepository: LogRepositoryProtocol,
        albumRepository: AlbumRepositoryProtocol,
        tasteRepository: TasteRepositoryProtocol,
        extractionService: TasteExtractionServiceProtocol,
        tasteProfileService: TasteProfileServiceProtocol
    ) {
        self.statusRepository = statusRepository
        self.logRepository = logRepository
        self.albumRepository = albumRepository
        self.tasteRepository = tasteRepository
        self.extractionService = extractionService
        self.tasteProfileService = tasteProfileService
    }

    func processLog(_ logID: UUID) async {
        do {
            try await statusRepository.markTasteUpdateStatus(logID: logID, status: .processing, errorMessage: nil)
        } catch {
            return
        }

        do {
            guard let log = try await logRepository.fetchLog(byID: logID) else {
                try await statusRepository.markTasteUpdateStatus(
                    logID: logID,
                    status: .failed,
                    errorMessage: "Log no longer exists."
                )
                return
            }

            guard let album = try await albumRepository.fetchAlbum(byID: log.albumID) else {
                try await statusRepository.markTasteUpdateStatus(
                    logID: logID,
                    status: .failed,
                    errorMessage: "Album metadata missing for this log."
                )
                return
            }

            let input = TasteExtractionInput(
                logEntryID: log.id,
                albumTitle: album.title,
                artistName: album.artistName,
                genreName: album.genreName,
                releaseYear: album.releaseYear,
                rating: log.rating,
                reviewText: log.reviewText,
                tags: log.tags
            )

            let output = try await extractionService.extractSignals(from: input)
            try await tasteProfileService.updateTasteProfile(with: output)
            try await statusRepository.markTasteUpdateStatus(logID: logID, status: .succeeded, errorMessage: nil)
        } catch {
            let attemptCount = (try? await statusRepository.fetchTasteUpdateAttemptCount(logID: logID)) ?? 0
            let shouldFail = attemptCount >= Constants.tasteUpdateMaxAutomaticAttempts
            try? await statusRepository.markTasteUpdateStatus(
                logID: logID,
                status: shouldFail ? .failed : .pending,
                errorMessage: error.localizedDescription
            )
        }
    }

    func retryPending(limit: Int) async {
        guard limit != 0 else { return }
        do {
            let pendingIDs = try await statusRepository.fetchPendingTasteUpdateLogIDs(limit: limit)
            for logID in pendingIDs {
                await processLog(logID)
            }
        } catch {
            // No-op for Phase 4.2: retry failures should not block app usage.
        }
    }

    func retryFailed(limit: Int) async {
        guard limit != 0 else { return }
        do {
            let failedIDs = try await statusRepository.fetchFailedTasteUpdateLogIDs(limit: limit)
            for logID in failedIDs {
                await processLog(logID)
            }
        } catch {
            // No-op for Phase 4.2: retry failures should not block app usage.
        }
    }

    func processLogDeletion(_ logID: UUID) async {
        do {
            let dimensionIDs = try await tasteRepository.fetchDimensionIDs(forLogEntryID: logID)
            let impactedIDs: [UUID]
            if dimensionIDs.isEmpty {
                impactedIDs = try await tasteRepository.fetchTopDimensions(limit: 0).map(\.id)
            } else {
                impactedIDs = dimensionIDs
            }

            for dimensionID in Set(impactedIDs) {
                _ = try await tasteRepository.recomputeDimensionAggregate(dimensionID: dimensionID)
            }
        } catch {
            // No-op for Phase 4.2: taste profile cleanup should not block log deletion UX.
        }
    }
}

@MainActor
struct UnimplementedTasteUpdateCoordinator: TasteUpdateCoordinating {
    func processLog(_ logID: UUID) async {}
    func retryPending(limit: Int) async {}
    func retryFailed(limit: Int) async {}
    func processLogDeletion(_ logID: UUID) async {}
}
