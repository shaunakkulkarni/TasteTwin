# TasteTwin Technical Specification

**Author:** Shaunak Kulkarni
**Platform:** iOS
**Stack:** SwiftUI, SwiftData, MusicKit, Apple Foundation Models
**Version:** v1 MVP

---

## 1. Purpose

This document translates the TasteTwin PRD into a developer-ready technical specification for building a working iOS MVP in Xcode with Codex support. It defines the app architecture, domain model, service boundaries, key workflows, persistence model, AI pipeline orchestration, screen specifications, and implementation phases.

The goal is to make the app buildable in small, testable increments.

---

## 2. Technical Scope

The MVP includes:

* album search via MusicKit
* album detail and logging flow
* local persistence of albums, logs, taste dimensions, evidence, recommendations, and feedback
* Taste Twin profile generated from ratings, reviews, and tags
* single-item explainable recommendation flow
* receipts-backed explanation generation
* one-question uncertainty handling when recommendation confidence is low
* lightweight evaluation harness against baseline recommendation methods

The MVP does **not** include:

* social features
* cloud sync
* multi-user auth
* Android/web support
* large-scale collaborative filtering
* playlist generation

---

## 3. Recommended Architecture

Use a layered architecture with lightweight MVVM.

### 3.1 Layers

#### Presentation Layer

Responsible for SwiftUI screens, navigation, and view state.

Includes:

* Views
* ViewModels
* reusable UI components

#### Domain Layer

Responsible for business logic and orchestration.

Includes:

* logging workflow rules
* taste profile update logic
* recommendation ranking logic
* explanation verification rules
* uncertainty decision logic

#### Data Layer

Responsible for local persistence and repository access.

Includes:

* SwiftData models
* repository interfaces and implementations
* caching helpers

#### Integration Layer

Responsible for external frameworks and APIs.

Includes:

* MusicKit service
* Foundation Models wrapper
* optional embedding/similarity utilities

---

## 4. Project Structure

Recommended Xcode folder/module structure:

```text
TasteTwin/
├── App/
│   ├── TasteTwinApp.swift
│   ├── AppRouter.swift
│   └── AppEnvironment.swift
├── Models/
│   ├── Domain/
│   ├── Persistence/
│   └── DTOs/
├── Views/
│   ├── Home/
│   ├── Search/
│   ├── AlbumDetail/
│   ├── LogEntry/
│   ├── Profile/
│   ├── TasteTwin/
│   └── Recommendation/
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── SearchViewModel.swift
│   ├── AlbumDetailViewModel.swift
│   ├── LogEntryViewModel.swift
│   ├── ProfileViewModel.swift
│   ├── TasteTwinViewModel.swift
│   └── RecommendationViewModel.swift
├── Services/
│   ├── MusicCatalogService.swift
│   ├── TasteExtractionService.swift
│   ├── TasteProfileService.swift
│   ├── CandidateRetrievalService.swift
│   ├── RecommendationRankingService.swift
│   ├── ExplanationService.swift
│   ├── ExplanationVerificationService.swift
│   └── ClarifyingQuestionService.swift
├── Repositories/
│   ├── AlbumRepository.swift
│   ├── LogRepository.swift
│   ├── TasteRepository.swift
│   └── RecommendationRepository.swift
├── Persistence/
│   ├── SwiftDataStack.swift
│   └── SeedData.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions/
│   └── Formatting/
└── Tests/
    ├── Unit/
    └── Integration/
```

---

## 5. Technology Decisions

### 5.1 UI

* **SwiftUI** for all screens
* **NavigationStack** for navigation
* **Observable / ObservableObject** for MVVM state management

### 5.2 Persistence

* **SwiftData** for MVP
* Use `@Model` entities for persistence
* Use repository abstractions so SwiftData can be swapped later if needed

### 5.3 Music Metadata

* **MusicKit** for album search and album metadata retrieval
* Cache album metadata locally after fetch

### 5.4 AI

* Use **Apple Foundation Models** through a dedicated wrapper service
* Keep prompts structured and deterministic where possible
* Treat model output as candidate reasoning, not final truth
* Pass all generated explanation content through verification before display

### 5.5 Concurrency

* Use Swift Concurrency (`async/await`)
* All service calls should be async-safe
* Long-running AI work should update UI loading states explicitly

---

## 6. Domain Model

Below is the recommended MVP data model.

### 6.1 Album

Represents catalog metadata for a music album.

**Fields**

* `id: UUID`
* `appleMusicID: String`
* `title: String`
* `artistName: String`
* `releaseYear: Int?`
* `genreName: String?`
* `artworkURL: String?`
* `trackCount: Int?`
* `cachedAt: Date`

### 6.2 LogEntry

Represents a user’s album log.

**Fields**

* `id: UUID`
* `albumID: UUID`
* `rating: Double`
* `reviewText: String`
* `tags: [String]`
* `loggedAt: Date`
* `updatedAt: Date`

### 6.3 TasteDimension

Represents one dimension of the user’s inferred taste profile.

**Fields**

* `id: UUID`
* `name: String`
* `weight: Double`
* `confidence: Double`
* `summary: String`
* `updatedAt: Date`

### 6.4 TasteEvidence

Connects a taste dimension to a specific user log.

**Fields**

* `id: UUID`
* `tasteDimensionID: UUID`
* `logEntryID: UUID`
* `snippet: String`
* `evidenceType: String`
* `strength: Double`

### 6.5 Recommendation

Represents a generated album recommendation.

**Fields**

* `id: UUID`
* `albumID: UUID`
* `score: Double`
* `confidence: Double`
* `status: RecommendationStatus`
* `explanationText: String`
* `createdAt: Date`

### 6.6 RecommendationReceipt

Connects a recommendation explanation to supporting logs.

**Fields**

* `id: UUID`
* `recommendationID: UUID`
* `logEntryID: UUID`
* `snippet: String`
* `linkedDimension: String`

### 6.7 ClarifyingQuestion

Represents a single question asked during low-confidence recommendation.

**Fields**

* `id: UUID`
* `recommendationID: UUID`
* `questionText: String`
* `questionType: String`
* `answerValue: String?`
* `createdAt: Date`
* `answeredAt: Date?`

### 6.8 RecommendationFeedback

Represents the user’s response to a recommendation.

**Fields**

* `id: UUID`
* `recommendationID: UUID`
* `feedbackType: RecommendationFeedbackType`
* `createdAt: Date`

---

## 7. Enums and Shared Types

```swift
enum RecommendationStatus: String, Codable {
    case active
    case dismissed
    case saved
    case accepted
}

enum RecommendationFeedbackType: String, Codable {
    case liked
    case dismissed
    case savedForLater
    case listened
}

enum EvidenceType: String, Codable {
    case reviewSnippet
    case ratingSignal
    case tagSignal
}
```

---

## 8. SwiftData Persistence Models

Use separate persistence models from service DTOs.

### Relationships

* One `AlbumRecord` can have many `LogEntryRecord`
* One `TasteDimensionRecord` can have many `TasteEvidenceRecord`
* One `RecommendationRecord` can have many `RecommendationReceiptRecord`
* One `RecommendationRecord` can optionally have one `ClarifyingQuestionRecord`
* One `RecommendationRecord` can have many `RecommendationFeedbackRecord`

### Persistence Notes

* Keep album metadata snapshots local to avoid repeated API fetches
* Store tags as transformable array or serialized string for MVP simplicity
* Use timestamps on all mutable records

---

## 9. Core Services

Each service should do one job clearly.

### 9.1 MusicCatalogService

**Responsibility:** search and fetch album metadata from MusicKit

**Methods**

```swift
protocol MusicCatalogServiceProtocol {
    func searchAlbums(query: String) async throws -> [AlbumSearchResultDTO]
    func fetchAlbumDetails(appleMusicID: String) async throws -> AlbumDetailDTO
}
```

### 9.2 LogService

**Responsibility:** create, update, delete, and list logs

**Methods**

```swift
protocol LogServiceProtocol {
    func createLog(input: CreateLogInput) async throws -> LogEntry
    func updateLog(id: UUID, input: UpdateLogInput) async throws -> LogEntry
    func deleteLog(id: UUID) async throws
    func fetchRecentLogs(limit: Int) async throws -> [LogEntry]
}
```

### 9.3 TasteExtractionService

**Responsibility:** extract structured taste signals from a log using Foundation Models

**Input**

* rating
* review text
* tags
* album metadata

**Output**

* extracted signals
* suggested dimensions
* evidence snippets
* confidence per signal

**Methods**

```swift
protocol TasteExtractionServiceProtocol {
    func extractSignals(from input: TasteExtractionInput) async throws -> TasteExtractionOutput
}
```

### 9.4 TasteProfileService

**Responsibility:** update the persisted taste profile from extracted signals

**Methods**

```swift
protocol TasteProfileServiceProtocol {
    func updateTasteProfile(with output: TasteExtractionOutput) async throws
    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension]
}
```

### 9.5 CandidateRetrievalService

**Responsibility:** generate candidate albums for recommendation

Candidate sources for MVP:

* metadata-neighbor albums from same/similar genre
* albums adjacent to highly rated prior logs
* exploration bucket from underrepresented genres or eras

**Methods**

```swift
protocol CandidateRetrievalServiceProtocol {
    func retrieveCandidates(for profile: TasteProfileSnapshot) async throws -> [AlbumCandidate]
}
```

### 9.6 RecommendationRankingService

**Responsibility:** score and diversify candidates

**Methods**

```swift
protocol RecommendationRankingServiceProtocol {
    func rankCandidates(_ candidates: [AlbumCandidate], profile: TasteProfileSnapshot, history: RecommendationHistory) async throws -> [RankedAlbumCandidate]
}
```

### 9.7 ExplanationService

**Responsibility:** generate recommendation explanation and receipts

**Methods**

```swift
protocol ExplanationServiceProtocol {
    func generateExplanation(for recommendation: RankedAlbumCandidate, profile: TasteProfileSnapshot, supportingLogs: [LogEntry]) async throws -> GeneratedExplanation
}
```

### 9.8 ExplanationVerificationService

**Responsibility:** verify that every explanation claim is supported by actual evidence

**Methods**

```swift
protocol ExplanationVerificationServiceProtocol {
    func verify(_ explanation: GeneratedExplanation, against logs: [LogEntry], dimensions: [TasteDimension]) async throws -> VerifiedExplanation
}
```

### 9.9 ClarifyingQuestionService

**Responsibility:** generate and score whether a clarifying question should be asked

**Methods**

```swift
protocol ClarifyingQuestionServiceProtocol {
    func shouldAskQuestion(confidence: Double, profile: TasteProfileSnapshot) -> Bool
    func generateQuestion(for recommendation: RankedAlbumCandidate, profile: TasteProfileSnapshot) async throws -> ClarifyingQuestionDTO
}
```

---

## 10. Repository Layer

Repositories isolate SwiftData access from business logic.

### Recommended repositories

* `AlbumRepository`
* `LogRepository`
* `TasteRepository`
* `RecommendationRepository`

### Example

```swift
protocol AlbumRepositoryProtocol {
    func upsertAlbum(_ album: Album) async throws -> Album
    func fetchAlbum(byAppleMusicID id: String) async throws -> Album?
    func fetchAlbum(byID id: UUID) async throws -> Album?
}
```

---

## 11. Screen Specifications

## 11.1 Home Screen

**Purpose:** landing page showing recent logs and navigation to recommendation

**UI Elements**

* recent logs carousel/list
* CTA: search albums
* CTA: tonight’s pick
* lightweight summary card with total logs and top taste tag/dimension

**ViewModel responsibilities**

* fetch recent logs
* fetch lightweight profile summary
* route to search or recommendation

---

## 11.2 Search Screen

**Purpose:** search MusicKit catalog

**UI Elements**

* search field
* loading state
* result list
* empty state

**Behavior**

* debounce query input
* search when query length >= 2
* cache tapped album locally

**ViewModel responsibilities**

* call `MusicCatalogService`
* manage loading, error, empty, results states

---

## 11.3 Album Detail Screen

**Purpose:** show album metadata and let user log it

**UI Elements**

* artwork
* title
* artist
* year
* genre
* track count
* log button

**Behavior**

* fetch detail if not already cached
* navigate to log entry form

---

## 11.4 Log Entry Screen

**Purpose:** create or edit log entry

**UI Elements**

* rating control
* review text editor
* optional tags input
* save button

**Validation**

* rating required
* review optional but encouraged
* max tag count for MVP: 5

**Post-save workflow**

1. save log
2. run taste extraction
3. update taste profile
4. return user to feed/profile

---

## 11.5 Profile Screen

**Purpose:** show user log history and simple stats

**UI Elements**

* total logs
* average rating
* recent tags
* list of log entries

**Behavior**

* allow drill-in to log detail
* allow edit/delete from detail

---

## 11.6 Taste Twin Screen

**Purpose:** visualize inferred taste dimensions

**UI Elements**

* list or cards for top dimensions
* weight/progress visualization
* confidence indicator
* expandable evidence receipts

**Behavior**

* sort by weight descending
* hide very low-confidence dimensions by default

---

## 11.7 Tonight’s Pick Screen

**Purpose:** show a recommendation with explanation and receipts

**UI Elements**

* hero album card
* why-you’ll-like-this explanation
* receipts section
* feedback actions: like, dismiss, save
* optional clarifying question block

**Behavior**

* if low confidence, show question before finalizing recommendation state
* rerank recommendation after answer submission

---

## 12. End-to-End Workflows

## 12.1 Search to Log Workflow

1. User enters query on Search screen
2. `MusicCatalogService.searchAlbums` returns results
3. User taps album
4. Album detail loads
5. User taps log
6. User enters rating/review/tags
7. `LogService.createLog` persists log
8. `TasteExtractionService.extractSignals` runs
9. `TasteProfileService.updateTasteProfile` persists dimension updates
10. Feed/Profile refreshes

## 12.2 Recommendation Workflow

1. User opens Tonight’s Pick
2. Taste profile snapshot is fetched
3. Candidate albums are retrieved
4. Candidates are ranked and diversified
5. Top recommendation is selected
6. Explanation is generated
7. Explanation is verified against actual logs
8. Recommendation is displayed
9. If confidence is low, ask one clarifying question
10. Rerank and regenerate explanation if answered

---

## 13. AI Pipeline Specification

## 13.1 Taste Extraction Prompt Design

Use structured output. The model should return JSON-like fields, not freeform narrative only.

### Input payload

* album title
* artist
* genre
* year
* rating
* review text
* user tags

### Output schema

```json
{
  "signals": [
    {
      "dimension": "production_style",
      "label": "polished production",
      "direction": "positive",
      "confidence": 0.82,
      "evidence_snippet": "loved the glossy production"
    }
  ],
  "summary": "User tends to like emotionally direct albums with polished production and strong vocals."
}
```

### Constraints

* Only use evidence present in input review, rating, tags, and metadata
* Do not invent user preferences not supported by input
* Keep dimensions within fixed taxonomy for MVP

---

## 13.2 Fixed Taste Dimension Taxonomy

For MVP, use a fixed taxonomy to simplify storage and UI.

Recommended dimensions:

* mood
* energy
* productionStyle
* vocalFocus
* lyricFocus
* experimentation
* instrumentalRichness
* genreOpenness
* eraAffinity
* replayability

Each extracted signal should map into one of these dimensions.

---

## 13.3 Recommendation Candidate Strategy

Because MVP will not have a large collaborative dataset, candidate retrieval should be pragmatic.

### Retrieval buckets

1. **Similarity bucket**

   * albums close in genre, artist adjacency, or metadata profile to highly rated logs
2. **Expansion bucket**

   * albums slightly adjacent to the user’s established taste dimensions
3. **Exploration bucket**

   * albums that score lower on similarity but improve discovery diversity

Recommended candidate count before ranking: 20–40

---

## 13.4 Ranking Formula

Use a transparent weighted score for MVP.

```text
FinalScore =
  (0.40 * TasteDimensionMatch)
+ (0.25 * ReviewSignalMatch)
+ (0.15 * MetadataSimilarity)
+ (0.10 * NoveltyBonus)
+ (0.10 * ExplorationFit)
- (0.20 * RepetitionPenalty)
```

These weights can be tuned later.

---

## 13.5 Diversity Constraints

Apply at ranking time.

### Rules

* avoid same artist as last 3 recommendations
* penalize same genre if genre was recommended repeatedly
* add novelty bonus for underrepresented eras
* keep exploration within acceptable confidence range

---

## 13.6 Explanation Generation Rules

Explanation must be:

* 2–3 bullets max
* specific
* plain language
* grounded in user history

### Explanation structure

* Bullet 1: strongest taste match
* Bullet 2: supporting album/review pattern
* Bullet 3: optional novelty angle

### Example internal output

```json
{
  "bullets": [
    {
      "claim": "You tend to like lush, emotionally direct pop albums with big vocal performances.",
      "supporting_log_ids": ["...", "..."]
    }
  ]
}
```

---

## 13.7 Verification Rules

The verification step enforces trust.

### Verification checks

* every claim must map to one or more stored log entries
* every claim must map to at least one taste dimension or explicit tag/review snippet
* unsupported adjectives or preferences must be removed
* if verification fails, regenerate or simplify

### Fallback behavior

If generated explanation is too broad:

* show direct receipts only
* reduce explanation complexity

---

## 13.8 Clarifying Question Logic

Ask one question only when:

* profile confidence is low
* top two candidate albums score too closely
* explanation support is weak but recoverable

### Question design rules

* one decision at a time
* answerable in one tap if possible
* directly useful for reranking

### Supported question types

* A/B preference
* mood selection
* energy level preference
* familiar vs exploratory choice

---

## 14. ViewModel Responsibilities

## 14.1 SearchViewModel

* manage search text
* debounce input
* call search service
* expose `[AlbumSearchResultDTO]`
* manage loading/error state

## 14.2 LogEntryViewModel

* hold rating, review, tags form state
* validate inputs
* save log
* trigger taste update pipeline

## 14.3 TasteTwinViewModel

* fetch top dimensions
* fetch evidence per dimension
* format confidence display

## 14.4 RecommendationViewModel

* orchestrate recommendation pipeline
* show loading state while generating
* handle clarifying question flow
* submit feedback actions

---

## 15. DTOs and Input/Output Shapes

## 15.1 CreateLogInput

```swift
struct CreateLogInput {
    let album: Album
    let rating: Double
    let reviewText: String
    let tags: [String]
}
```

## 15.2 TasteExtractionInput

```swift
struct TasteExtractionInput {
    let albumTitle: String
    let artistName: String
    let genreName: String?
    let releaseYear: Int?
    let rating: Double
    let reviewText: String
    let tags: [String]
}
```

## 15.3 TasteSignalDTO

```swift
struct TasteSignalDTO: Codable {
    let dimension: String
    let label: String
    let direction: String
    let confidence: Double
    let evidenceSnippet: String
}
```

## 15.4 GeneratedExplanation

```swift
struct GeneratedExplanation {
    let bullets: [ExplanationBullet]
}

struct ExplanationBullet {
    let claim: String
    let supportingLogIDs: [UUID]
    let linkedDimension: String?
}
```

---

## 16. Error Handling

### Principles

* never block logging because AI fails
* recommendation can degrade gracefully
* explainable UI should fall back to simpler states instead of blank screens

### Examples

* if MusicKit fetch fails: show cached album if available, else error state
* if extraction fails after log save: keep log, mark taste update pending
* if recommendation explanation verification fails: show reduced evidence-only explanation
* if clarifying question generation fails: skip question and show best available recommendation

---

## 17. Performance Considerations

### MVP priorities

* logging must feel instant
* profile/feed fetch should use local storage only
* AI updates can happen immediately after save but should show a non-blocking loading state if needed
* cache album metadata aggressively

### Suggested thresholds

* search response should feel near-real-time
* taste extraction should run in background task after log creation
* recommendation generation should complete within a user-tolerable loading state window

---

## 18. Privacy and Data Handling

For MVP:

* user data stored locally on device
* no external user account required
* user reviews and logs are private
* only album metadata fetched from MusicKit

If any AI calls leave device in future versions, that must be explicitly documented and gated.

---

## 19. Analytics for Prototype

Use lightweight local metrics or debug logging.

Track:

* logs created
* recommendations generated
* recommendations liked/dismissed/saved
* clarifying questions asked/answered
* baseline vs TasteTwin comparison results

For class/demo use, these can be stored locally or exported manually.

---

## 20. Testing Strategy

## 20.1 Unit Tests

Cover:

* log validation
* taste profile update mapping
* recommendation score calculation
* diversity penalty logic
* explanation verification rules

## 20.2 Integration Tests

Cover:

* search → detail → log save flow
* log save → extraction → taste update flow
* recommendation → explanation → verification flow
* low-confidence → clarifying question → rerank flow

## 20.3 Manual QA Scenarios

* create first log with rating only
* create log with review and tags
* verify Taste Twin updates after multiple logs
* verify recommendation explanation references real prior logs
* verify recommendation changes after answering clarifying question

---

## 21. Build Order

## Phase 1: Foundation

* create Xcode project
* set up SwiftData models
* set up navigation shell
* seed preview/sample data

## Phase 2: Search and Logging

* implement MusicKit search
* build album detail screen
* build log entry screen
* persist logs and cached albums

## Phase 3: Profile and Feed

* build recent logs feed
* build log detail screen
* implement edit/delete log

## Phase 4: Taste Twin

* implement fixed dimension taxonomy
* build extraction service wrapper
* persist dimensions and evidence
* build Taste Twin screen

## Phase 5: Recommendation Engine

* implement candidate retrieval
* implement ranking formula
* create recommendation persistence and UI

## Phase 6: Explanation and Verification

* generate explanation bullets
* attach receipts
* verify claims
* add fallback behavior

## Phase 7: Clarifying Question

* implement low-confidence detection
* generate question
* rerank recommendation on answer

## Phase 8: Evaluation Harness

* implement baseline recommendation methods
* add comparison logging
* prepare demo script

---

## 22. Definition of Technical Completion

The MVP technical implementation is complete when:

* albums can be searched and cached locally
* logs can be created, edited, deleted, and displayed
* taste dimensions update from saved logs
* recommendation candidates can be retrieved and ranked
* one recommendation can be shown with verified receipts
* one clarifying question can rerank recommendation output
* baseline comparison logic exists for demo/testing

---


