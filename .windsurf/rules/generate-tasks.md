
# Process: Turn a PRD into an Actionable Task List (Swift/Xcode — iOS & macOS)
_Last updated: 2025-10-08_

## Objective
Convert a Swift/Xcode PRD into a clear, verifiable task list that junior developers can execute inside **Xcode** with **Swift**, **SPM**, and **XCTest/XCUITest**.

## Inputs
- PRD file (Markdown)
- Target platforms (iOS / iPadOS / macOS) and **minimum OS versions**
- Repository URL and existing Xcode project (if any)

## Outputs
- Markdown task list with:
  - Parent tasks (3–7)
  - Detailed sub-tasks (small, testable steps)
  - Relevant Xcode **targets**, **files**, and **folder structure**
  - Notes section with **xcodebuild** commands and simulator guidance

## Step-by-Step Process

1. **Ingest PRD**
   - Identify platform(s), minimum OS targets, SwiftUI/UIKit/AppKit usage, dependencies (SPM), API endpoints, data models, and entitlements.

2. **Draft Parent Tasks (3–7)**
   - Example parents: Project & Dependencies, Data Layer, UI Layer, Testing, Release Readiness.
   - Present to requester and wait for explicit **“Go”** before detailing sub-tasks.

3. **Generate Detailed Sub-Tasks**
   - Decompose each parent into verifiable, incremental items using Swift Concurrency (`async/await`) and SwiftUI where applicable.
   - Include acceptance checks (what proves the task is done).

4. **Map Files and Targets**
   - Propose folders and file names:
     - `AppName/AppNameApp.swift` (SwiftUI entry)
     - `AppName/Features/<Feature>/...`
     - `AppName/Services/Network/NetworkService.swift`
     - `AppName/Models/<Model>.swift`
     - `AppName/Resources/Assets.xcassets`
     - `AppNameTests/...` (XCTest)
     - `AppNameUITests/...` (XCUITest)
     - `Packages/DesignSystem` (optional Swift package)

5. **Notes & Commands**
   - Build (project): `xcodebuild -project AppName.xcodeproj -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build`
   - Build (workspace): `xcodebuild -workspace AppName.xcworkspace -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build`
   - Test: `xcodebuild test -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'`
   - Lint/format: `swiftformat .` and `swiftlint --strict`
   - Simulators: `xcrun simctl list devices`

## Required Output Format (Template)

```markdown
## Relevant Files
- `AppName/AppNameApp.swift` — SwiftUI app entry point.
- `AppName/Services/Network/NetworkService.swift` — URLSession client (async/await).
- `AppName/Features/Dashboard/DashboardView.swift` — SwiftUI view with loading/error/loaded states.
- `AppName/Models/MetricsResponse.swift` — Codable model for `/metrics` API.
- `AppNameTests/NetworkServiceTests.swift` — Unit tests for networking.
- `AppNameUITests/DashboardUITests.swift` — UI tests for the main flow.

### Notes
- Build (project): `xcodebuild -project AppName.xcodeproj -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build`
- Build (workspace): `xcodebuild -workspace AppName.xcworkspace -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build`
- Test: `xcodebuild test -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'`
- Lint/format: `swiftformat .` and `swiftlint --strict`
- Simulators: `xcrun simctl list devices`

## Tasks
- [ ] 1.0 **Parent Task:** Project & Dependencies
  - [ ] 1.1 Confirm minimum OS targets and update project settings.
  - [ ] 1.2 Add SPM dependencies with pinned versions via Xcode.
  - [ ] 1.3 Ensure schemes are **Shared** for CI.
  - [ ] 1.4 Configure `.xcconfig` for environments/secrets (no hard-coded keys).

- [ ] 2.0 **Parent Task:** Data Layer
  - [ ] 2.1 Implement `NetworkService` using `URLSession` and async/await.
  - [ ] 2.2 Define Codable models and decoding strategy.
  - [ ] 2.3 Add error types and user-facing error policy.

- [ ] 3.0 **Parent Task:** UI Layer (SwiftUI)
  - [ ] 3.1 Create `DashboardView` + `DashboardViewModel` with states.
  - [ ] 3.2 Accessibility: Dynamic Type, VoiceOver labels.
  - [ ] 3.3 Add previews in Xcode canvas for key screens.

- [ ] 4.0 **Parent Task:** Testing
  - [ ] 4.1 Unit tests for `NetworkService` with mock URLProtocol.
  - [ ] 4.2 UI tests for happy-path and error state.
  - [ ] 4.3 Run `xcodebuild test` in CI on each PR.

- [ ] 5.0 **Parent Task:** Release Readiness
  - [ ] 5.1 Set Team, Bundle IDs, and entitlements (Push, App Sandbox for macOS as required).
  - [ ] 5.2 Prepare App Store metadata and privacy nutrition labels.
  - [ ] 5.3 Archive and validate build; verify TestFlight (iOS/macOS App Store as appropriate).
```

## Quality Rules
- Prefer **SPM**; avoid mixing CocoaPods and SPM for the same target.
- Use **Swift Concurrency** and mark UI entry points with `@MainActor` when needed.
- Keep tasks small, verifiable, and suitable for juniors.
- Use **XCTest/XCUITest** and `xcodebuild` for automation.
