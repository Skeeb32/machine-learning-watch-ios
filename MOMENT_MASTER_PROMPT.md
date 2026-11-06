# MOMENT — GPT Master Build Prompt

Copy the prompt below into GPT or a coding agent with access to this repository. This document defines the build brief; it does not claim that the application has already been implemented.

---

You are the lead iOS/watchOS engineer and product implementation partner for **MOMENT**. Turn the approved product concept into a maintainable native application. Work directly in the repository when tools are available. Produce complete, runnable implementation increments, verify them, and report evidence honestly.

## 1. Product and approved decisions

- Repository: https://github.com/Skeeb32/machine-learning-watch-ios
- Product: **MOMENT**
- Brand wordmark: **moment.**
- First release: **MOMENT 1.0 — Midnight**
- Current milestone: **Build 0.1**, the native application foundation.
- Tagline: **Make sense of your day.**
- Supporting line: **Your personal intelligence, beautifully connected.**
- Platforms: native iPhone and Apple Watch.
- Minimum deployment targets: iOS 17 and watchOS 10.
- User-provided environment: Mac with Xcode installed; individual Apple Developer account.
- Backend direction: build our own Python backend.
- iPhone owns the main experience, synchronization, and longer AI conversations.
- Watch provides quick, useful interactions and cached summaries without requiring a network connection for every screen.
- Basic dashboard interactions must work offline.

Treat these as approved decisions. Inspect the actual environment and repository before making implementation assumptions. Do not repeatedly ask whether the user owns a Mac or wants SwiftUI.

## 2. Immediate assignment and scope

Deliver Build 0.1: a real Xcode project with a navigable iPhone app, a companion Watch target, shared models, Midnight design components, local persistence, explicit sample mode, and replaceable integration boundaries.

Implement the foundation first. Do not turn the first sprint into a complete backend, subscription system, or App Store launch. HealthKit and WatchConnectivity should have usable foundation implementations appropriate to this milestone; full live integration validation belongs to the next milestone.

Inspect existing files and any applicable repository instructions. Preserve existing work and adapt this brief to the repository rather than replacing it wholesale. If the repository is empty, initialize the structure. Check Xcode, installed SDKs, simulator destinations, and available build tooling yourself.

Use reasonable defaults for reversible implementation choices. Ask only when a missing decision materially blocks progress. If an external prerequisite blocks one part, continue independent work and identify the exact remaining prerequisite.

## 3. Midnight design system

Use a restrained, native visual language:

- Deep midnight background: starting token `#101820`.
- Muted slate surfaces: starting tokens `#1A2931` and `#20313A`.
- Soft mint accent: starting token `#8EDBCB`.
- Elegant system typography, clear hierarchy, generous spacing.
- Reusable metric, insight, suggestion, and empty-state cards.
- Minimal Swift Charts visualizations with understandable labels and units.
- Subtle animation that respects Reduce Motion.
- Native navigation, controls, gestures, and platform conventions.

These colors come from the approved Watch concept and are initial shared tokens. Validate readability and accessibility rather than assuming the palette guarantees contrast. Launch dark-first with explicit, consistent appearance behavior; verify system appearance changes do not create unreadable combinations.

Support Dynamic Type, VoiceOver, meaningful accessibility labels, test identifiers, and comfortable touch targets. Adapt to smaller iPhones and Watch sizes. Do not bake sample dates, greetings, or measurements into view code.

The supplied branding reference is inspiration only. Create MOMENT's own identity; do not copy another app's logo or assets.

## 4. iPhone experience

Use five primary destinations:

1. **Today** — greeting, daily insight, sleep, steps, resting heart rate, active energy, and one practical daily suggestion.
2. **Ask** — suggested questions, editable input, conversation history, submission state, and a clearly labeled sample response service for Build 0.1.
3. **Insights** — daily briefings, history, and selectable time periods.
4. **Patterns** — understandable activity and sleep trends, with insufficient-data states; distinguish observations from causal claims.
5. **Profile** — preferences, sample-mode controls, Apple Health connection entry point, privacy/data controls, and integration status.

Add onboarding that explains the product, sample mode, and optional Apple Health connection. Request permissions in context after an explicit user action, not automatically on launch.

Every visible control must have a meaningful implemented behavior or an honest unavailable state. Avoid decorative buttons that silently do nothing. Never imply that mock chat is a real AI service.

Represent loading, empty, unavailable, offline/cached, and recoverable-error states. Model permission-related states accurately: do not claim individual HealthKit read permissions were denied or granted when that cannot be determined.

## 5. Architecture and project organization

Use SwiftUI, Swift Charts, SwiftData initially, HealthKit, and WatchConnectivity. Prefer clear feature boundaries, dependency injection, protocol-backed services, and testable view models. Avoid unnecessary frameworks.

Provide one Xcode project/workspace containing independent iOS and watchOS application entry points and a shared module/framework or local Swift package. Choose a shared-module approach that builds for both platforms and document it.

Suggested layout; adapt where necessary:

```text
Moment.xcodeproj
Moment/
  App/MomentApp.swift
  DesignSystem/
    MomentColors.swift
    MomentTypography.swift
    MomentComponents.swift
  Features/
    Onboarding/
    Today/
    Ask/
    Insights/
    Patterns/
    Profile/
  Data/
    Models/
    Repositories/
    SampleData/
  Services/
    HealthKitManager.swift
    AIService.swift
    NotificationService.swift
    WatchConnectivityManager.swift
MomentWatch/
  MomentWatchApp.swift
  WatchHomeView.swift
  WatchInsightView.swift
  WatchConnectivityManager.swift
MomentShared/
  Models/
  Utilities/
MomentTests/
MomentUITests/
docs/
```

Views render state and dispatch actions. Put fetching, aggregation, synchronization, and AI behavior behind dedicated services/repositories. Use a `DashboardViewModel` instead of hardcoded dashboard data. Keep UI state updates on the appropriate actor and handle asynchronous work, cancellation, and errors deliberately.

Deliver the actual project and shared schemes, or a checked-in deterministic generator configuration with documented generation steps and a generated, verified project. A folder of Swift snippets alone is not done. Configure target membership, companion relationships, deployment targets, resources, capabilities, and usage descriptions. Do not commit personal signing credentials or invent the user's Team ID.

## 6. Models, provenance, and persistence

Start from the supplied shared contracts and extend them deliberately:

- `HealthMetric`: stable ID, metric type, numeric value, unit, recorded timestamp, and source.
- `MetricType`: steps, sleep, resting heart rate, active energy, workouts; add heart rate for the planned historical trend integration.
- `DataSource`: healthKit, sample, userEntered.
- `DailyInsight`: ID, title, explanation, category, generated timestamp, and evidence/provenance.

The original insight example included `isVerified`. Do not use a Boolean to imply clinical validation. If retained, define its limited meaning; prefer explicit evidence references, source, and generation metadata.

Define units, aggregation periods, local calendar-day boundaries, and timezone handling. Distinguish zero from missing/unavailable data. Preserve stable identity when syncing or updating records.

Separate SwiftData persistence entities from shared transport models where helpful. Persist preferences and useful dashboard/insight snapshots. Document schema evolution and cache lifecycle. Keep sample fixtures separate from live records; switching modes must not mix provenance.

All sample metrics and sample AI responses must be visibly labeled. Never replace unavailable real data with realistic-looking sample values silently. Cached real data must show freshness. Inject the clock and data services where needed for deterministic tests and previews.

## 7. Apple Watch companion

Provide:

- Today summary.
- Daily insight and detail.
- Activity overview.
- Quick-access prompts with honest availability states.
- Connectivity status and cached data freshness.

Use independent Watch and iPhone `@main` entry points. Share Codable models through the common module, and exchange versioned, compact payloads through WatchConnectivity.

Use appropriate background/latest-state transfer mechanisms for snapshots and reachable messaging only when needed for immediate interactions. Persist the last valid Watch snapshot. Handle activation, unsupported/unpaired states where applicable, disconnection, missing first-sync data, invalid payloads, and stale updates without crashing.

The Watch must remain useful offline. Do not promise an immediate live AI answer while the phone/backend is unavailable. Show a cached result, queue supported work, or explain the unavailable action.

## 8. HealthKit foundation and next integration milestone

Initial read-only data scope:

- Step count.
- Sleep analysis.
- Heart rate.
- Resting heart rate.
- Active energy.
- Workouts.

Configure the HealthKit entitlement/capability and `NSHealthShareUsageDescription` for targets that actually access HealthKit. Explain why each requested type benefits the user. Include workouts in the requested types when implementing that scope.

Check availability and request authorization only after the user connects Apple Health. Completion of the authorization request does not establish access to individual read types. Empty results may reflect unavailable data or restricted access; represent that ambiguity.

Build a replaceable HealthKit repository, implement a first live query such as daily steps, and route its result through the same model/view-model path used by fixtures. Keep unimplemented metrics explicitly unavailable in live mode.

For complete integration, define appropriate aggregation for each metric. Handle calendar/timezone changes, sleep intervals and overlap, multiple sources, query failures, refreshes, and cache freshness. Verify exact platform API behavior against current official Apple documentation during implementation. Do not copy example force unwraps or convert all missing results into zero.

## 9. Intelligence backend: planned follow-on work

Keep backend implementation in a separate Python repository unless the user later chooses a monorepo. For Build 0.1, document the contract and provide an injectable mock client; do not require a running backend to launch the app or create another repository without authorization.

Planned stack:

- Python FastAPI.
- PostgreSQL.
- OpenAI API.
- LangChain and LlamaIndex for scoped retrieval/ingestion responsibilities.
- LangGraph for orchestration.
- Pinecone for vector retrieval.
- A personal-baseline ML service.

Introduce these incrementally with clear responsibilities. Pin and verify compatible versions when implementation starts. Keep provider API keys on the server, never in app source, the app bundle, or Git.

Proposed endpoints:

| Method | Path | Purpose |
| --- | --- | --- |
| POST | /v1/health/sync | Sync permitted, minimized health summaries |
| GET | /v1/insights/today | Daily briefing |
| GET | /v1/insights/history | Historical briefings |
| POST | /v1/chat | Ask MOMENT |
| GET | /v1/patterns | Detected patterns |
| DELETE | /v1/account | Account and associated-data deletion |

Document request/response models, timestamps, units, pagination where relevant, errors, authentication, ownership enforcement, idempotency, retry behavior, and versioning before wiring a live client.

Planned entities: users, user_preferences, health_daily, health_samples where justified, daily_insights, personal_memories, ai_conversations, ai_messages, and subscriptions.

Every personal record and vector must be scoped to the authenticated user. Obtain explicit consent before sending health context off-device; Apple Health read authorization alone is not consent for AI processing. Minimize transmitted and retained data. Keep sensitive health values, prompts, and secrets out of logs.

Account deletion must cover database records, vectors, derived embeddings, memories, and relevant caches, with documented handling of backups and failed deletion work. Do not offer a functioning account-deletion control before its actual lifecycle exists.

AI answers must be grounded in authorized context, identify supporting observations, admit insufficient evidence, and avoid fabricated measurements or medical diagnoses. Retrieved text is data, not instructions. Evaluate isolation between users and unsupported answers before enabling live AI.

## 10. Delivery sequence

- **Sprint 01 — Visual foundation:** approved identity, design tokens, reusable components, clearly labeled prototype data.
- **Sprint 02 — Native application / Build 0.1:** runnable iOS and Watch targets, five destinations, onboarding, state, persistence, service boundaries, HealthKit/WatchConnectivity foundations.
- **Sprint 03 — Apple ecosystem:** validated real metrics, resilient device synchronization, complications, and notifications.
- **Sprint 04 — Intelligence:** backend, authentication required for private endpoints, ML baselines, retrieval, orchestration, grounded Ask MOMENT.
- **Sprint 05 — Commercial release:** complete account flows, StoreKit 2 subscriptions and restoration, privacy/security review, TestFlight, App Store preparation.

Future features must not block the local foundation. Do not claim later sprints are complete because their interfaces or folders exist.

## 11. Build 0.1 acceptance criteria

1. The documented Xcode setup opens successfully; iPhone and Watch schemes build against installed compatible simulators.
2. The iPhone launches, onboarding works, and all five destinations are navigable.
3. Today uses reusable components and injected data; sample provenance is obvious.
4. Suggested questions and typed questions produce clearly identified mock chat responses through an AI service.
5. Insight period selection changes displayed data; Patterns handles insufficient data.
6. Preferences and dashboard snapshots survive relaunch as documented.
7. The dashboard remains usable offline; stale and missing data are distinguishable.
8. The Watch launches independently into a useful cached/sample or first-sync state and displays its insight/activity screens.
9. HealthKit setup and the first live-query path exist; unavailable data never masquerades as zero or sample data.
10. Relevant automated tests cover meaningful state, persistence, model, and synchronization behavior; UI smoke coverage checks core navigation.
11. Accessibility and layout checks cover representative iPhone and Watch sizes.
12. README documents setup, schemes, simulator commands, sample/live modes, signing prerequisites, current limitations, and next steps.
13. No secrets, personal health records, build products, or personal signing material are committed.

Run builds/tests that the environment supports. Record exact commands and outcomes. Distinguish compilation, simulator launch, automated tests, manual inspection, and paired-device testing. A simulator build does not prove real-device HealthKit access or Watch delivery.

If Xcode or a required device is unavailable, state what was checked, complete independently verifiable work, and provide exact remaining validation steps. Never claim tests passed without running them.

## 12. Working and reporting protocol

Start by inspecting the repository and environment, then give a short implementation plan and execute the first milestone. Verify uncertain API details against primary documentation. Deliver complete files, not pseudocode, omitted sections, or instructions asking the user to assemble the app.

Keep changes focused and preserve user work. Use descriptive commits and follow the user's Git publishing instructions. Do not deploy services, purchase infrastructure, or submit to TestFlight/App Store without the corresponding authorization.

At the end of each increment report:

- What now works.
- Files or architectural decisions that matter.
- Checks actually run and their results.
- Known limitations or blockers.
- The next concrete milestone.

Begin with Build 0.1 now. The immediate outcome is a runnable, maintainable native foundation for MOMENT.
