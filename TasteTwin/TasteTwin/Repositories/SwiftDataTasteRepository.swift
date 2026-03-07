import Foundation
import SwiftData

@MainActor
final class SwiftDataTasteRepository: TasteRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func upsertDimension(_ dimension: TasteDimension) async throws -> TasteDimension {
        if let existing = try await fetchDimensionRecord(named: dimension.name) {
            existing.weight = dimension.weight
            existing.confidence = dimension.confidence
            existing.summary = dimension.summary
            existing.updatedAt = dimension.updatedAt
            try modelContext.save()
            return existing.asDomain()
        }

        if let byID = try await fetchDimensionRecord(byID: dimension.id) {
            byID.name = dimension.name
            byID.weight = dimension.weight
            byID.confidence = dimension.confidence
            byID.summary = dimension.summary
            byID.updatedAt = dimension.updatedAt
            try modelContext.save()
            return byID.asDomain()
        }

        let record = TasteDimensionRecord(
            id: dimension.id,
            name: dimension.name,
            weight: dimension.weight,
            confidence: dimension.confidence,
            summary: dimension.summary,
            updatedAt: dimension.updatedAt
        )
        modelContext.insert(record)
        try modelContext.save()
        return record.asDomain()
    }

    func saveEvidence(_ evidence: TasteEvidence) async throws -> TasteEvidence {
        let dimension = try await fetchDimensionRecord(byID: evidence.tasteDimensionID)
        let logEntry = try await fetchLogRecord(byID: evidence.logEntryID)

        guard let dimension, let logEntry else {
            throw SwiftDataTasteRepositoryError.relatedRecordMissing
        }

        if let existing = try await fetchEvidenceRecord(byID: evidence.id) {
            existing.tasteDimension = dimension
            existing.logEntry = logEntry
            existing.snippet = evidence.snippet
            existing.evidenceType = evidence.evidenceType
            existing.weightContribution = evidence.weightContribution
            existing.strength = evidence.strength
            try modelContext.save()
            guard let mapped = existing.asDomain() else {
                throw SwiftDataTasteRepositoryError.relatedRecordMissing
            }
            return mapped
        }

        let record = TasteEvidenceRecord(
            id: evidence.id,
            tasteDimension: dimension,
            logEntry: logEntry,
            snippet: evidence.snippet,
            evidenceType: evidence.evidenceType,
            weightContribution: evidence.weightContribution,
            strength: evidence.strength
        )
        modelContext.insert(record)
        try modelContext.save()
        guard let mapped = record.asDomain() else {
            throw SwiftDataTasteRepositoryError.relatedRecordMissing
        }
        return mapped
    }

    func fetchDimension(named name: String) async throws -> TasteDimension? {
        try await fetchDimensionRecord(named: name)?.asDomain()
    }

    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension] {
        let descriptor = FetchDescriptor<TasteDimensionRecord>(
            sortBy: [
                SortDescriptor(\TasteDimensionRecord.weight, order: .reverse),
                SortDescriptor(\TasteDimensionRecord.updatedAt, order: .reverse)
            ]
        )
        let records = try modelContext.fetch(descriptor)
        let dimensions = records.map { $0.asDomain() }
        guard limit > 0 else { return dimensions }
        return Array(dimensions.prefix(limit))
    }

    func fetchEvidence(forDimensionID id: UUID) async throws -> [TasteEvidence] {
        let descriptor = FetchDescriptor<TasteEvidenceRecord>(sortBy: [SortDescriptor(\TasteEvidenceRecord.strength, order: .reverse)])
        return try modelContext.fetch(descriptor)
            .filter { $0.tasteDimension?.id == id }
            .compactMap { $0.asDomain() }
    }

    func fetchDimensionIDs(forLogEntryID id: UUID) async throws -> [UUID] {
        let descriptor = FetchDescriptor<TasteEvidenceRecord>()
        let evidence = try modelContext.fetch(descriptor)
        let dimensionIDs = evidence
            .filter { $0.logEntry?.id == id }
            .compactMap { $0.tasteDimension?.id }
        return Array(Set(dimensionIDs))
    }

    func deleteEvidence(forLogEntryID id: UUID) async throws {
        let descriptor = FetchDescriptor<TasteEvidenceRecord>()
        let evidence = try modelContext.fetch(descriptor)
            .filter { $0.logEntry?.id == id }

        guard !evidence.isEmpty else { return }
        for item in evidence {
            modelContext.delete(item)
        }
        try modelContext.save()
    }

    func recomputeDimensionAggregate(dimensionID: UUID) async throws -> TasteDimension? {
        guard let dimension = try await fetchDimensionRecord(byID: dimensionID) else {
            return nil
        }

        let descriptor = FetchDescriptor<TasteEvidenceRecord>(sortBy: [SortDescriptor(\TasteEvidenceRecord.strength, order: .reverse)])
        let evidence = try modelContext.fetch(descriptor)
            .filter { $0.tasteDimension?.id == dimensionID }

        guard !evidence.isEmpty else {
            modelContext.delete(dimension)
            try modelContext.save()
            return nil
        }

        let weightAverage = evidence.map(\.weightContribution).reduce(0, +) / Double(evidence.count)
        let confidenceAverage = evidence.map(\.strength).reduce(0, +) / Double(evidence.count)

        dimension.weight = clamp(weightAverage)
        dimension.confidence = clamp(confidenceAverage)
        dimension.updatedAt = .now

        if dimension.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let strongest = evidence.first {
            dimension.summary = "Inferred from: \"\(String(strongest.snippet.prefix(120)))\""
        }

        try modelContext.save()
        return dimension.asDomain()
    }

    private func fetchDimensionRecord(byID id: UUID) async throws -> TasteDimensionRecord? {
        let descriptor = FetchDescriptor<TasteDimensionRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }

    private func fetchDimensionRecord(named name: String) async throws -> TasteDimensionRecord? {
        let descriptor = FetchDescriptor<TasteDimensionRecord>(predicate: #Predicate { $0.name == name })
        return try modelContext.fetch(descriptor).first
    }

    private func fetchLogRecord(byID id: UUID) async throws -> LogEntryRecord? {
        let descriptor = FetchDescriptor<LogEntryRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }

    private func fetchEvidenceRecord(byID id: UUID) async throws -> TasteEvidenceRecord? {
        let descriptor = FetchDescriptor<TasteEvidenceRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }

    private func clamp(_ value: Double) -> Double {
        min(1.0, max(0.0, value))
    }
}

enum SwiftDataTasteRepositoryError: Error {
    case relatedRecordMissing
}

private extension TasteDimensionRecord {
    func asDomain() -> TasteDimension {
        TasteDimension(
            id: id,
            name: name,
            weight: weight,
            confidence: confidence,
            summary: summary,
            updatedAt: updatedAt
        )
    }
}

private extension TasteEvidenceRecord {
    func asDomain() -> TasteEvidence? {
        guard let dimensionID = tasteDimension?.id, let logID = logEntry?.id else {
            return nil
        }

        return TasteEvidence(
            id: id,
            tasteDimensionID: dimensionID,
            logEntryID: logID,
            snippet: snippet,
            evidenceType: evidenceType,
            weightContribution: weightContribution,
            strength: strength
        )
    }
}
