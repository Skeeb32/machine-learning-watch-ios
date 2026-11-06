# moment.

**Make sense of your day.** Native iPhone + Apple Watch · Midnight · Build 0.1

MOMENT is a local-first SwiftUI foundation for a personal wellbeing companion. This milestone includes five iPhone destinations, onboarding, a Watch companion, SwiftData snapshots, a real daily-step HealthKit query, and clearly labeled sample data/chat. Live AI, historical HealthKit integrations, accounts, notifications, complications, and subscriptions are future work.

## Open in Xcode

1. Open `Moment.xcodeproj`.
2. Select the **Moment** scheme and an iPhone simulator, then Run.
3. Start with **Explore MOMENT**. Use **Profile → Connect Apple Health** for the daily-step integration, or keep sample mode enabled.
4. For Watch, install a compatible watchOS simulator runtime in **Xcode → Settings → Components**, create a Watch simulator, and select **MomentWatch**. Pair a compatible iPhone/Watch simulator to exercise connectivity.

Minimum versions: iOS 17 and watchOS 10. Project generation requires XcodeGen only when changing `project.yml`; the generated project is checked in. The shared module is a local Swift package with no external dependencies.

For physical devices, select your Apple development team on both targets, set unique bundle identifiers if necessary, and preserve the Watch companion identifier relationship. Provision HealthKit for the iPhone target. No signing identity is committed.

```sh
xcodegen generate
xcodebuild -project Moment.xcodeproj -scheme Moment \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Moment.xcodeproj -scheme MomentWatch \
  -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO build
# Replace the destination with a simulator listed by xcrun simctl list devices available.
xcodebuild -project Moment.xcodeproj -scheme Moment \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.5' test
```

Do not pass a global `-sdk iphonesimulator` override when building the iPhone scheme: it embeds a watchOS app that needs its own platform SDK.

## What works

- Midnight colors, shared cards, system typography, dark appearance, and Dynamic Type layouts.
- Today, Ask, Insights, Patterns, and Profile navigation.
- Sample dashboard, 7/30-day charts, suggested and typed sample chat.
- Persistent sample/live mode and suggestion preference; separate SwiftData snapshots by source.
- Read-only, on-demand Apple Health step authorization and daily cumulative query.
- Watch summary, insight details, activity, quick-prompt availability explanations, and optional sample preview.
- Versioned latest-state WatchConnectivity payloads with an on-Watch persisted cache.

No API key or network backend is required. Chat is in memory and clears when the process exits. Chat is always a sample interaction, including when Today is using live steps.

## Data behavior

Unavailable values are shown as `—`, never silently replaced by zero or sample data. Sample and HealthKit snapshots occupy separate cache records. A failed live refresh may retain a previously loaded live snapshot; timestamps and a refresh error make the fallback visible. Mode changes clear the displayed snapshot before requesting the new source.

HealthKit request completion does not prove read access was granted. This build requests **steps only**, because other health queries are not implemented. Sleep, resting heart rate, and active energy remain unavailable in live mode. No health context is sent to an AI service.

Daily steps use the device calendar's start of day and cumulative statistics through the query time. Historical day grouping, sleep overlap/source handling, and robust background refresh are deferred. Pull to refresh Today after a date/timezone change.

The Watch receives compact full snapshots using `updateApplicationContext`. Delivery is managed by the OS and is not immediate or guaranteed within a specific time. A Watch without a first sync shows setup guidance. It can explicitly preview samples offline. Cached snapshots older than one hour are labeled cached; the exact update timestamp is always shown.

SwiftData schema v1 stores one encoded snapshot per source. A payload version guards incompatible data. Future persistent model changes should introduce an explicit versioned migration plan. No automatic backup/cloud synchronization is configured by the app. Uninstalling the app removes its local store; the Watch has a separate cache that must also be removed by uninstalling the Watch app. Account-wide deletion is not implemented because no accounts exist yet.

## Layout

- `Moment/`: iPhone app, feature views, view models, persistence, HealthKit, mock AI.
- `MomentWatch/`: standalone SwiftUI Watch entry point and views.
- `MomentShared/`: local package for Codable models, sample fixtures, design primitives, connectivity.
- `MomentTests/`: model/provenance, persistence, mode-switch and chat tests.
- `MomentUITests/`: onboarding, five-tab navigation, and sample chat smoke test.
- `docs/`: validation notes and backend roadmap.

## Remaining before release

Add production branding/app icons, inspect VoiceOver and largest text sizes on devices, validate HealthKit with authorized and unavailable records, test paired Watch delivery/reconnection, and implement additional health queries. The app is an engineering foundation, not a production medical product or completed AI service. See [validation](docs/VALIDATION.md) and the [master prompt](MOMENT_MASTER_PROMPT.md).
