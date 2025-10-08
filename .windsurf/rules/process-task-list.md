---
trigger: manual
---

# Cascade Workflow Template: Generating a Task List from a PRD (Swift/Xcode — iOS & macOS)
_Last updated: 2025-10-08_

## Goal

Guide **Cascade** (Windsurf IDE) to create an **actionable, implementation-ready task list** for a **Swift/Xcode** project targeting **iOS** and/or **macOS**. The output must map cleanly to an Xcode project with Swift Packages and XCTest targets, enabling junior developers to proceed confidently.

---

## The Process: Your Step-by-Step Instructions

**1. Receive the PRD File**
- The user will provide a reference to a specific PRD file (e.g., `@prd-feature-name.md`).

**2. Analyse the PRD**
- Read and analyse functional requirements, user stories, non‑functional constraints, and technical considerations.
- Extract: target platform(s) (iOS/iPadOS/macOS), minimum OS versions, SwiftUI/UIKit/AppKit usage, dependencies (SPM), data flows, API contracts, signing/entitlements.

**3. Phase 1: Generate High‑Level Parent Tasks**
- From the analysis, propose **3–7 parent tasks** that cover the full feature or project scope (e.g., Project Setup, Feature Implementation, Data Layer, UI Layer, Testing, Release Readiness).
- Present these parent tasks to the user first.
- **Ask for confirmation before proceeding** using the exact prompt:

> I have generated the high‑level tasks based on the PRD. Ready to generate the detailed sub‑tasks? Please respond with 'Go' to proceed.

**4. Wait for User Confirmation**
- **Pause** and wait for an explicit 'Go'. Do **not** generate sub‑tasks until confirmation is received.

**5. Phase 2: Generate Detailed Sub‑Tasks**
- Break down each parent task into **small, verifiable steps** suitable for junior developers.
- Each sub‑task should be specific and testable (e.g., “Create `NetworkService` using `URLSession` to GET `/api/data` and decode into `MetricsResponse` with `JSONDecoder`.”).

**6. Identify Relevant Files and Provide Notes**
- List the **Xcode targets** and **files** to be created or modified.
- Prefer a clear folder structure, e.g.:
  - `AppName/AppNameApp.swift` (SwiftUI app entry)
  - `AppName/Features/Dashboard/DashboardView.swift`
  - `AppName/Services/Network/NetworkService.swift`
  - `AppName/Models/MetricsResponse.swift`
  - `AppName/Resources/Assets.xcassets`
  - `AppNameTests/…` (XCTest)
  - `AppNameUITests/…` (XCUITest)
  - `Packages/DesignSystem` (optional Swift package)
- Add a **Notes** section for build/run commands, test commands, or simulator selection.

**7. Assemble and Save the Final Task List**
- Combine parent tasks, sub‑tasks, relevant files, and notes into one Markdown document following the **Required Output Format**.
- Save the generated document in the `/tasks/` directory with filename: `/tasks/[prd-file-name]-tasks.md` (where `[prd-file-name]` matches the base name of the input PRD file).

---

## Required Output Format

The generated task list **must** follow this structure. Use iOS/macOS‑appropriate files, commands, and test tooling.

```markdown
## Relevant Files

- `AppName/AppNameApp.swift` — SwiftUI app entry point.
- `AppName/Services/Network/NetworkService.swift` — URLSession client with request/response helpers.
- `AppName/Features/Dashboard/DashboardView.swift` — Main dashboard UI (SwiftUI).
- `AppName/Models/MetricsResponse.swift` — Codable model for `/metrics` API.
- `AppNameTests/NetworkServiceTests.swift` — Unit tests (XCTest) for networking.
- `AppNameUITests/DashboardUITests.swift` — UI tests (XCUITest) for critical flows.

### Notes

- Build (project):  
  `xcodebuild -project AppName.xcodeproj -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build`
- Build (workspace):  
  `xcodebuild -workspace AppName.xcworkspace -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build`
- Test:  
  `xcodebuild test -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'`
- Lint/format (if configured):  
  `swiftformat .` and `swiftlint --strict`
- List simulators:  
  `xcrun simctl list devices`

## Tasks

- [ ] 1.0 **Parent Task:** Project & Dependencies
  - [ ] 1.1 Confirm minimum OS targets (e.g., iOS 16.0, macOS 13.0) and update project settings.
  - [ ] 1.2 Add Swift Package dependencies via **Xcode → Project → Package Dependencies** with pinned versions.
  - [ ] 1.3 Create base folders (`Features/`, `Services/`, `Models/`, `Resources/`).
  - [ ] 1.4 Ensure schemes are **Shared** for CI (Manage Schemes → Shared).

- [ ] 2.0 **Parent Task:** Data Layer
  - [ ] 2.1 Implement `NetworkService` using `URLSession` with async/await.
  - [ ] 2.2 Define `MetricsResponse: Codable` and decoding strategy.
  - [ ] 2.3 Add error types and user‑visible error messages policy.

- [ ] 3.0 **Parent Task:** UI Layer (SwiftUI)
  - [ ] 3.1 Create `DashboardView` with loading/error/loaded states.
  - [ ] 3.2 Bind to a `DashboardViewModel` (observable) that fetches metrics on appear.
  - [ ] 3.3 Accessibility: support Dynamic Type and VoiceOver labels.

- [ ] 4.0 **Parent Task:** Testing
  - [ ] 4.1 Add unit tests for `NetworkService` (mock URLProtocol).
  - [ ] 4.2 Add UI tests for `DashboardView` happy‑path and error state.
  - [ ] 4.3 Configure CI to run `xcodebuild test` on each PR.

- [ ] 5.0 **Parent Task:** Release Readiness
  - [ ] 5.1 Ensure bundle IDs, signing team, and entitlements are set.
  - [ ] 5.2 Prepare App Store metadata checklist and privacy nutrition entries.
  - [ ] 5.3 Archive locally and verify build logs are clean.

```

---

## Quality & Consistency Rules

- Prefer **Swift Concurrency** (async/await) and annotate UI entry points with `@MainActor` where appropriate.
- Use **SPM** for dependencies; avoid mixing CocoaPods and SPM for the same target.
- Pin versions with semantic constraints and record them in the README/PRD.
- Keep sub‑tasks **small, testable, and verifiable** for junior developers.
- Use **XCTest/XCUITest** (not pytest) and Xcode/`xcodebuild` commands suitable for iOS/macOS.