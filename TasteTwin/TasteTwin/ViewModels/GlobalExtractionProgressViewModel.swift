import Foundation
import Observation

@MainActor
@Observable
final class GlobalExtractionProgressViewModel {
    var isExtractionInFlight = false
    var shouldShowProgressBar = false
    var progressValue = 0.0

    private var statusRepository: TasteUpdateStatusRepositoryProtocol
    private var progressSessionTask: Task<Void, Never>?
    private let userDefaults: UserDefaults

    init(
        statusRepository: TasteUpdateStatusRepositoryProtocol,
        userDefaults: UserDefaults = .standard
    ) {
        self.statusRepository = statusRepository
        self.userDefaults = userDefaults
    }

    func configure(statusRepository: TasteUpdateStatusRepositoryProtocol) {
        self.statusRepository = statusRepository
    }

    func refreshAndBeginIfNeeded() async {
        await refreshStatusSummary()
        if isExtractionInFlight || consumeRecentLogSaveSignal() {
            beginProgressSession()
        }
    }

    func beginProgressSession() {
        progressSessionTask?.cancel()
        progressSessionTask = Task { @MainActor in
            let startedAt = Date()
            shouldShowProgressBar = true
            progressValue = max(progressValue, 0.08)

            await refreshStatusSummary()
            var baselineInFlight = max(1, currentInFlightCount)

            while !Task.isCancelled {
                await refreshStatusSummary()
                let currentInFlight = currentInFlightCount
                baselineInFlight = max(baselineInFlight, currentInFlight)

                if currentInFlight > 0 {
                    let completed = Double(baselineInFlight - currentInFlight) / Double(max(1, baselineInFlight))
                    progressValue = min(0.92, max(0.08, completed))
                } else {
                    progressValue = 1.0
                    let elapsed = Date().timeIntervalSince(startedAt)
                    if elapsed >= Constants.tasteTwinProgressMinVisibleSeconds {
                        shouldShowProgressBar = false
                        progressValue = 0
                        break
                    }
                    try? await Task.sleep(for: .milliseconds(100))
                }

                try? await Task.sleep(for: .milliseconds(Constants.tasteTwinProgressPollMilliseconds))
            }
        }
    }

    private var currentInFlightCount: Int {
        let summary = statusSummary ?? .empty
        return summary.pendingCount + summary.processingCount
    }

    private var statusSummary: TasteUpdateStatusSummary?

    private func refreshStatusSummary() async {
        do {
            statusSummary = try await statusRepository.fetchTasteUpdateStatusSummary()
        } catch {
            statusSummary = .empty
        }
        isExtractionInFlight = currentInFlightCount > 0
    }

    private func consumeRecentLogSaveSignal() -> Bool {
        let now = Date().timeIntervalSince1970
        let savedAt = userDefaults.double(forKey: Constants.lastLogSaveTimestampDefaultsKey)
        guard savedAt > 0, (now - savedAt) <= Constants.tasteTwinRecentSaveSignalWindowSeconds else {
            return false
        }

        userDefaults.set(0, forKey: Constants.lastLogSaveTimestampDefaultsKey)
        return true
    }
}
