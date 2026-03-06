Below is a PRD version of your proposal, rewritten to be build-oriented and specific enough to use as the foundation for Codex and Xcode.

You can paste this into a doc as your working PRD.

---

# TasteTwin PRD

**Product Requirements Document**
**Author:** Shaunak Kulkarni
**Product:** TasteTwin
**Platform:** iOS
**Version:** v1 MVP
**Status:** Draft

## 1. Product Overview

TasteTwin is an iOS app for tracking album listening, rating, and reviewing music, with an AI-powered recommendation layer that learns a user’s taste from their logs. The app combines a music diary experience similar to Letterboxd with a personalized “Taste Twin” that explains recommendations using the user’s own prior ratings and reviews as evidence.

The core value proposition is not just recommending albums, but making those recommendations feel understandable and trustworthy. Every recommendation should answer: **Why this album for me, specifically?**

---

## 2. Purpose

The purpose of TasteTwin is to help users:

* log and reflect on what they listen to
* build a structured profile of their music taste over time
* receive personalized album recommendations
* understand the reasoning behind those recommendations through receipts tied to their own listening history

This project will result in a working iOS prototype demonstrating album logging, taste modeling, and explainable recommendations using Apple-native technologies.

---

## 3. Problem Statement

Music recommendation products often feel opaque. Users may get repetitive or low-fit recommendations without understanding why those picks were made. This creates three problems:

1. **Low trust**
   Users do not know why a recommendation appeared and cannot tell whether the system actually understands their preferences.

2. **Weak personalization with sparse data**
   Many recommendation systems need large amounts of behavior data before they become useful. Early recommendations can feel generic.

3. **Poor explanation quality**
   Even when recommendations are accurate, explanations are often vague and not grounded in the user’s own listening history.

TasteTwin solves this by using ratings and short-form reviews to infer taste signals, then generating recommendations with evidence-backed reasoning.

---

## 4. Product Vision

Create a music logging app where the user’s reviews are not just stored, but turned into a dynamic taste profile that powers transparent, explainable recommendations.

---

## 5. Goals

### MVP Goals

The MVP must deliver the following:

* Search for albums and save them to a personal library
* Log a listen with:

  * rating
  * short review
  * optional tags
* Display a profile/feed of logged albums
* Generate a Taste Twin profile showing:

  * top taste dimensions
  * confidence per dimension
  * supporting evidence from prior logs
* Show one recommendation at a time on a “Tonight’s Pick” screen
* Explain recommendations using receipts from the user’s prior reviews/logs
* Ask one clarifying question when recommendation confidence is low
* Capture recommendation feedback to improve future results

### Learning Goals

The prototype should also demonstrate:

* how short reviews can be converted into structured taste signals
* whether explainable recommendations feel more useful than baseline recommendations
* whether one lightweight clarifying question improves perceived relevance

---

## 6. Non-Goals for MVP

The MVP will **not** include:

* social following, comments, likes, or public profiles
* playlist creation or full song-level tracking
* Android or web support
* advanced collaborative filtering across a large user base
* long-form editorial content
* multi-step conversational recommendation flows
* real-time syncing across multiple devices
* production-grade analytics infrastructure

---

## 7. Target User

### Primary User

A music enthusiast who already enjoys logging opinions about albums and wants discovery to feel more personal and more explainable.

### Secondary User

A casual listener who wants better album recommendations without having to provide a lot of explicit setup data.

### Key User Characteristics

* enjoys rating or reviewing albums
* values taste identity and self-expression
* wants discovery beyond generic popular recommendations
* is willing to provide lightweight feedback if it improves future recommendations

---

## 8. Core User Stories

### Logging

* As a user, I want to search for an album so I can log it.
* As a user, I want to rate an album and leave a short review so the app can learn my taste.
* As a user, I want to add optional tags so I can describe what stood out to me.

### Profile / Library

* As a user, I want to see my logged albums in one place so I can track my listening history.
* As a user, I want to revisit past reviews so I can reflect on how my taste changes over time.

### Taste Twin

* As a user, I want to see the traits the app thinks define my taste so I can judge whether it understands me.
* As a user, I want each taste trait to show evidence from my own logs so I trust the profile.

### Recommendations

* As a user, I want a recommendation that clearly tells me why I might like it.
* As a user, I want the explanation to reference albums and reviews I already logged.
* As a user, I want to answer one clarifying question when the app is unsure so it can improve the recommendation.

### Feedback

* As a user, I want to react to a recommendation so the app can refine future picks.

---

## 9. MVP Features

## 9.1 Album Search

Users can search for albums using Apple Music catalog metadata.

### Requirements

* Search by album title, artist, or both
* Display album art, album title, artist, year, and genre where available
* User can tap a result to view album details
* User can start a log from the album detail screen

### Acceptance Criteria

* User can find and open an album detail page in under 3 taps from search
* Search results return relevant albums with usable metadata
* Album can be saved or logged from result/detail views

---

## 9.2 Log a Listen

Users can log an album by submitting a rating, short review, and optional tags.

### Requirements

* Rating input required
* Review text optional but strongly encouraged
* Optional custom tags
* Log saves album metadata snapshot with the review
* Each saved log triggers taste signal extraction

### Acceptance Criteria

* User can create a log in one short flow
* Saved logs appear in profile/feed immediately
* Taste extraction runs after log creation
* User can edit or delete their log

---

## 9.3 Profile / Feed

Users can browse their listening history.

### Requirements

* Reverse chronological feed of logged albums
* Each entry shows album art, title, artist, rating, review preview, and date logged
* Tap into a full log detail screen
* Basic profile summary:

  * total albums logged
  * average rating
  * top tags or recent activity

### Acceptance Criteria

* Feed loads stored logs reliably
* Log details preserve rating, review, tags, and album metadata
* User can navigate from feed to full log details

---

## 9.4 Taste Twin Screen

The app visualizes the user’s inferred music taste.

### Requirements

* Show 8–12 taste dimensions
* Each dimension includes:

  * label
  * weight/strength
  * confidence score
  * supporting evidence from prior logs
* Evidence should reference exact albums and snippets from prior reviews
* Dimensions update over time as new logs are added

### Example Taste Dimensions

These are placeholders and can evolve during implementation:

* mood / emotional tone
* energy
* production style
* vocal preference
* lyric focus
* experimentation / boundary-pushing
* instrumental richness
* genre openness
* era preference
* replayability / immediacy

### Acceptance Criteria

* Screen clearly surfaces top taste dimensions
* At least one supporting receipt exists for each displayed high-confidence dimension
* User can understand why a dimension is present

---

## 9.5 Tonight’s Pick Recommendation

The app recommends one album at a time.

### Requirements

* Show one featured recommendation
* Include:

  * album art
  * title
  * artist
  * year
  * genre
  * concise recommendation explanation
  * receipts from prior logs
* Explanation should reference specific prior albums, reviews, or tags
* User can:

  * like the recommendation
  * dismiss it
  * save it for later
  * log it after listening

### Acceptance Criteria

* Recommendation explanation is understandable and specific
* Receipts are tied to real user logs
* Recommendation updates after feedback or a clarifying answer

---

## 9.6 Clarifying Question Mechanism

When model confidence is low, the app asks one short question.

### Requirements

* Ask only when confidence drops below threshold
* Question should be specific and preference-revealing
* Prefer multiple-choice or short-tap responses for speed
* Answer is stored and used to rerank recommendation candidates

### Example Questions

* What mattered more here: vocals or production?
* Are you looking for something more energetic tonight?
* Do you want something similar to this vibe or more exploratory?

### Acceptance Criteria

* App asks at most one clarifying question in the recommendation flow
* Recommendation reranks after answer submission
* User feels the question is relevant and not random

---

## 10. User Experience Principles

The UX should feel:

* **fast** — low friction logging
* **personal** — language should feel tied to the user’s own taste
* **transparent** — recommendations must show reasoning
* **lightweight** — avoid dense setup or lengthy onboarding
* **reflective** — make music logging feel rewarding even without recommendations

---

## 11. End-to-End User Flow

## 11.1 First-Time User Flow

1. User opens app
2. User sees intro/value proposition
3. User is prompted to search and log their first album
4. After 2–3 logs, the Taste Twin begins to populate
5. User visits Tonight’s Pick and gets first explainable recommendation

## 11.2 Returning User Flow

1. User opens app
2. Lands on home/feed or recommendation screen
3. Logs a new album or reviews current recommendation
4. Taste Twin updates
5. Future recommendations improve

---

## 12. Functional Requirements

## 12.1 Search and Metadata

* The system must query album metadata from Apple Music / MusicKit
* The system must store enough metadata locally to support repeat access
* The system must gracefully handle missing fields

## 12.2 Logging

* The system must persist logs locally
* The system must associate logs with album records
* The system must allow edits and deletes
* The system must timestamp each log

## 12.3 Taste Extraction

* The system must convert ratings, review text, and tags into structured taste signals
* The system must update the user taste profile after each new log
* The system must store confidence and evidence per dimension

## 12.4 Recommendation Generation

* The system must retrieve candidate albums
* The system must rank by taste fit
* The system must apply diversity constraints
* The system must generate explanation text
* The system must attach receipts from actual user logs

## 12.5 Verification

* The system must check whether each explanation claim is supported by user evidence
* Unsupported claims should be removed or rewritten before display

## 12.6 Clarifying Question

* The system must detect low-confidence recommendation states
* The system must generate a single relevant question
* The system must rerank candidates after the user answers

---

## 13. AI / Recommendation System Design

## 13.1 Inputs

* rating
* short review text
* user tags
* album metadata
* prior recommendation feedback
* clarifying-question responses

## 13.2 Pipeline

### Step 1: Ingest Log

On every log save, collect:

* album ID
* album title
* artist
* genre
* year
* rating
* review text
* tags
* timestamp

### Step 2: Extract Taste Signals

Use Apple Foundation Models to infer structured signals from the user’s review and rating.

Example outputs:

* high-energy production
* melodic vocals
* introspective lyrics
* polished pop production
* preference for darker mood
* dislike of bloated tracklists

### Step 3: Update Taste Twin

Map extracted signals into a fixed dimension set.
For each dimension, store:

* weight
* confidence
* supporting evidence
* last updated timestamp

### Step 4: Retrieve Candidate Albums

Build recommendation candidates using:

* genre similarity
* metadata overlap
* embedding similarity if available
* optionally curated exploration candidates

### Step 5: Rank and Diversify

Rank with a scoring model that balances:

* taste match
* novelty
* artist diversity
* era diversity
* exploration factor

### Step 6: Explain and Verify

Generate concise “why you’ll like this” bullets.
Then run a verification pass that ensures each bullet is grounded in actual evidence from the user’s history.

### Step 7: Handle Uncertainty

If confidence is below threshold:

* ask one clarifying question
* update preference state
* rerank
* regenerate explanation

---

## 14. Recommendation Logic

A simple MVP ranking formula could be:

**Recommendation Score = Taste Match + Review Signal Match + Novelty Bonus - Repetition Penalty**

### Inputs to ranking

* similarity to positively rated albums
* similarity to review-derived taste traits
* diversity from recently recommended artists/albums
* user feedback history
* optional session context from clarifying question

### Diversity rules

* avoid repeating same artist too often
* avoid recommending only one era or one genre cluster
* inject a small exploration bucket for cold start

---

## 15. Explanation Requirements

This is one of the most important product requirements.

Every recommendation explanation must:

* be concise
* be understandable by a non-technical user
* reference the user’s own prior listening history
* avoid generic statements not supported by evidence
* separate actual evidence from model inference

### Good explanation example

“You seem to respond well to glossy, emotionally direct pop with strong vocal performances. You rated *Melodrama* highly and mentioned loving albums with dramatic production and big emotional payoff. This pick leans in that same direction.”

### Receipt examples

* “You rated *Album X* 4.5 stars”
* “In your review of *Album Y*, you wrote: ‘loved the layered production and melancholy mood’”
* “You tagged *Album Z* with ‘dreamy’ and ‘late night’”

### Verification rule

If an explanation bullet cannot point to a real stored receipt, it should not be shown.

---

## 16. Data Model

Below is a practical MVP data model.

## 16.1 Entities

### User

* id
* displayName
* createdAt

### Album

* id
* appleMusicID
* title
* artistName
* releaseYear
* genre
* artworkURL
* trackCount
* metadataLastFetchedAt

### LogEntry

* id
* userID
* albumID
* rating
* reviewText
* tags
* loggedAt
* updatedAt

### TasteDimension

* id
* userID
* name
* weight
* confidence
* summary
* updatedAt

### TasteEvidence

* id
* tasteDimensionID
* logEntryID
* evidenceSnippet
* evidenceType
* strength

### Recommendation

* id
* userID
* albumID
* recommendationDate
* score
* confidence
* explanationText
* status

### RecommendationReceipt

* id
* recommendationID
* logEntryID
* snippet
* linkedDimension

### ClarifyingQuestion

* id
* recommendationID
* questionText
* questionType
* answerValue
* answeredAt

### RecommendationFeedback

* id
* recommendationID
* feedbackType
* createdAt

---

## 17. Screens

## 17.1 Home / Feed

Purpose: view recent logs and quick access to recommendation

Core elements:

* recent activity feed
* CTA to log an album
* CTA to view Tonight’s Pick

## 17.2 Search

Purpose: find albums

Core elements:

* search bar
* result list
* album cards

## 17.3 Album Detail

Purpose: view album metadata and start a log

Core elements:

* artwork
* title/artist/year/genre
* log button

## 17.4 Log Entry Screen

Purpose: submit rating, review, tags

Core elements:

* rating control
* review text input
* optional tags
* save action

## 17.5 Profile

Purpose: view user stats and history

Core elements:

* profile summary
* total logs
* average rating
* recent logs

## 17.6 Taste Twin

Purpose: visualize user taste model

Core elements:

* top dimensions
* confidence indicators
* receipts/evidence

## 17.7 Tonight’s Pick

Purpose: show recommendation and reasoning

Core elements:

* album hero card
* “why this fits you”
* receipts
* like / dismiss / save / answer question

---

## 18. Success Metrics

For the prototype, success should be measured with lightweight product and model metrics.

## Product Metrics

* number of albums logged per user
* percentage of users who view Taste Twin
* percentage of users who engage with a recommendation
* recommendation save rate
* recommendation like rate

## AI Quality Metrics

* explanation faithfulness score
* recommendation relevance rating
* rerank improvement after clarifying question
* diversity across recommended artists/genres/eras

## Suggested MVP Evaluation

Compare TasteTwin recommendations against a baseline such as:

* genre-only recommendation
* popularity-based recommendation
* simple metadata similarity

Then collect user ratings on:

* relevance
* novelty
* explanation usefulness
* trust

---

## 19. Baseline Comparisons

To satisfy the “basic evaluation vs baseline methods” goal, compare against at least two simple baselines:

### Baseline A: Genre Similarity

Recommend albums from the user’s highest-rated genres.

### Baseline B: Metadata Similarity

Recommend albums similar in year/genre/artist adjacency to positively rated albums.

### TasteTwin System

Use review text + rating + tags + receipts-backed explanation logic.

### Evaluation Questions

* Which method produces higher perceived relevance?
* Which method feels more trustworthy?
* Does explanation quality increase acceptance?

---

## 20. Edge Cases and Failure Handling

### Cold Start

Problem: too few logs

Handling:

* encourage first 3–5 logs
* use broader metadata-based picks early
* ask clarifying question sooner
* mark low-confidence states internally

### Weak Review Text

Problem: user only leaves ratings

Handling:

* use ratings + tags
* prompt optional micro-tagging
* use softer explanation language

### Missing Metadata

Problem: Apple Music data incomplete

Handling:

* store partial album record
* show fallback UI copy
* still allow logging

### Low Confidence Recommendation

Problem: not enough evidence

Handling:

* ask one question
* widen candidate pool
* use transparent explanation language

### Unsupported Explanation

Problem: generated rationale lacks receipts

Handling:

* drop unsupported claim
* regenerate explanation
* fall back to simpler evidence-only wording

---

## 21. Technical Requirements

## Client

* SwiftUI for UI
* SwiftData or Core Data for local persistence
* MusicKit / Apple Music API for album metadata
* Apple Foundation Models for extraction and explanation generation
* local caching for album metadata and recommendation state

## Architectural Preference

A clean architecture for MVP should include:

* presentation layer
* domain/recommendation layer
* persistence layer
* API/music metadata layer
* AI/taste modeling layer

## Offline / Cache Considerations

* cache recent album metadata
* preserve user logs offline
* show graceful fallback when recommendation refresh cannot run

---

## 22. Suggested App Architecture

A practical folder/module layout for Xcode:

* `App`
* `Models`
* `Views`
* `ViewModels`
* `Services`

  * `MusicKitService`
  * `TasteExtractionService`
  * `RecommendationService`
  * `ExplanationService`
  * `VerificationService`
* `Persistence`
* `Utilities`

This keeps the app buildable and easy to evolve.

---

## 23. MVP Build Sequence

This is the order I’d use to build it.

### Phase 1: Core App Foundation

* set up SwiftUI app
* define models
* configure persistence
* build navigation structure

### Phase 2: Search + Logging

* integrate MusicKit search
* build album detail
* build log entry flow
* save logs locally

### Phase 3: Profile + Feed

* build feed UI
* build log detail
* enable edit/delete

### Phase 4: Taste Twin

* implement dimension model
* extract signals from logs
* display dimensions and evidence

### Phase 5: Recommendation Engine

* build candidate retrieval
* add ranking and diversity logic
* create recommendation UI

### Phase 6: Explanation + Verification

* generate explanation
* attach receipts
* block unsupported claims

### Phase 7: Clarifying Question

* add low-confidence trigger
* ask one question
* rerank recommendation

### Phase 8: Evaluation Harness

* baseline comparisons
* manual tester script
* simple metrics logging

---

## 24. Open Decisions

These should be finalized before coding deeply:

1. **Persistence choice**
   SwiftData is likely the easiest starting point for MVP unless you need more custom control.

2. **Taste dimension taxonomy**
   Decide whether dimensions are fixed from day one or partially flexible.

3. **Recommendation source breadth**
   Decide whether candidates come only from MusicKit search/catalog metadata or also from a small precomputed local candidate pool.

4. **How much AI runs on device vs app-controlled orchestration**
   This affects latency, explainability structure, and implementation complexity.

5. **User account scope**
   Single local user for MVP is simplest.

---

## 25. Risks

### Product Risks

* logging may feel like work before recommendation value is clear
* recommendation quality may not feel strong with very sparse data

### Technical Risks

* Foundation Models integration may require simplification
* MusicKit constraints may affect retrieval depth
* explanation verification may be trickier than generation itself

### Mitigation

* keep MVP narrow
* prioritize receipts-first explanations
* use simple baselines early
* ship with one-user local prototype assumptions

---

## 26. Definition of Done

The MVP is complete when:

* a user can search for an album and log it
* logs persist locally and appear in a feed
* Taste Twin displays top taste dimensions with evidence
* the app generates at least one explainable recommendation
* recommendation explanations cite prior user logs
* the app asks one clarifying question when confidence is low
* user feedback can be captured on recommendations
* the recommendation flow can be demonstrated end-to-end in a prototype demo

---

## 27. One-Sentence Product Statement

TasteTwin is a music diary and recommendation app that turns your album reviews into an explainable AI taste profile, then uses that profile to deliver personalized album picks with receipts from your own listening history.

---


