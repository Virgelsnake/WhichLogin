# Swift/Xcode Product Requirements Document (PRD) — iOS & macOS
_Last updated: 2025-10-08_

## 1) Overview
**Purpose.** Define an implementable, testable specification for a Swift-based application targeting **iOS** and/or **macOS**, suitable for inexperienced developers.
**Primary tools.** Xcode (latest stable), Swift (latest stable on selected deployment targets), Swift Package Manager.

## 2) Scope
### 2.1 In scope
- Native Swift app(s) for:
  - iOS and/or iPadOS
  - macOS (Catalyst or AppKit)
- SwiftUI-first UI (UIKit/AppKit where necessary)
- Local persistence, networking, and basic offline handling

### 2.2 Out of scope
- watchOS, tvOS, visionOS (unless explicitly justified and agreed)
- Cross‑platform frameworks unrelated to Apple platforms

## 3) Target Platforms & Devices
### 3.1 Platforms (tick all that apply)
- [ ] iOS
- [ ] iPadOS
- [ ] macOS (choose one: **Catalyst** / **AppKit**)

> If targeting multiple platforms, specify shared vs platform‑specific features explicitly.

### 3.2 Minimum Deployment Targets (required)
- iOS: **16.0+** (example)
- iPadOS: **16.0+** (example)
- macOS: **13.0+** (example)

> Align API usage (e.g., Swift Concurrency, SwiftUI features) with these versions.

## 4) Functional Requirements
### 4.1 User Stories
- _As a \<persona\>, I want \<capability\> so that \<outcome\>._
- Include acceptance criteria (Given/When/Then).

### 4.2 Feature List
- Feature A …
- Feature B …
- Platform variations (if any).

## 5) Non‑functional Requirements
- Performance targets (e.g., cold start under 2s on iPhone 12)
- Accessibility (Dynamic Type, VoiceOver, colour contrast WCAG AA)
- Privacy and security (no PII in logs, App Transport Security, Keychain usage)
- Localisation (if applicable)

## 6) Architecture & Tech Choices
### 6.1 UI Framework
- **Preferred:** SwiftUI
- **Fallbacks:** UIKit (iOS/iPadOS), AppKit (macOS) for missing controls
- **Navigation:** NavigationStack (iOS/iPadOS 16+), split view where suitable.

### 6.2 Concurrency
- **Swift Concurrency (async/await, Task, MainActor)** aligned to minimum OS versions.
- Avoid legacy completion‑handlers unless integrating older libraries.

### 6.3 Modularisation
- Use Swift Packages for shared modules (e.g., Networking, Models, DesignSystem).
- Avoid mixing SPM and CocoaPods for the **same target**. Prefer SPM. If the project already uses CocoaPods, keep consistent or plan a structured migration.

### 6.4 Dependencies (SPM)
- Pin versions with semantic constraints (e.g., `.upToNextMajor(from: "1.4.0")`).
- Record chosen versions here and in `README.md`.
- Add via **Xcode → Project → Package Dependencies** (do **not** create a top‑level `Package.swift` for app projects unless building a Swift package).

### 6.5 Configuration
- Use Xcode build configurations: `Debug`, `Release` (and `Beta`/`Staging` if needed).
- Use `.xcconfig` files for environment values; never hard‑code secrets in source.

## 7) Data & Integrations
- Data model outline (entities/relationships)
- Storage: Core Data / SQLite / File system (state rationale)
- Networking: URLSession (default) or library X pinned via SPM
- API endpoints, auth method (OAuth 2.0 / Sign in with Apple, etc.)
- Error handling policy and user messaging

## 8) Testing Strategy
- **Unit tests:** XCTest targets per module, >80% for core logic
- **UI tests:** XCUITest for critical flows
- **Snapshot tests:** optional (SwiftSnapshotTesting)
- **Static analysis:** SwiftLint + SwiftFormat (document rules)
- **Continuous Integration:** `xcodebuild` on CI with workspace/project as applicable

## 9) Build, Run, and CI/CD
### 9.1 Local build (examples)
- **Workspace (CocoaPods/multi‑project):**
  ```
  xcodebuild -workspace App.xcworkspace -scheme App     -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build
  ```
- **Project (no workspace):**
  ```
  xcodebuild -project App.xcodeproj -scheme App     -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build
  ```

> Use `xcrun simctl list devices` to choose a simulator available locally.

### 9.2 Test
```
xcodebuild test -scheme App   -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

### 9.3 Lint/Format (run in CI)
```
swiftformat .
swiftlint --strict
```

### 9.4 Distribution
- **iOS/iPadOS:** TestFlight → App Store
- **macOS App Store:** Notarisation handled by App Store submission flow
- **macOS outside the store:** Developer ID signing + **Notarisation** + **Hardened Runtime**; **App Sandbox** entitlements as required

## 10) Code Signing & Provisioning (required)
- Team ID: …
- Bundle ID(s): …
- Automatic vs Manual signing: …
- Entitlements:
  - iOS: Push Notifications, Background Modes (if needed)
  - macOS: App Sandbox categories, Hardened Runtime
- Keychain access groups (if any)

## 11) Analytics & Logging
- Add analytics provider or OSLog categories (no PII)
- Crash reporting: Xcode Organizer/Crashlytics (if used)

## 12) Accessibility & QA
- Accessibility checklist
- Test devices and simulators matrix
- Beta feedback channels (TestFlight notes, in‑app feedback)

## 13) Release Readiness
- App Store metadata (name, subtitle, keywords, privacy nutrition labels)
- Screenshots per device class (use Xcode’s screenshot tooling)
- Versioning: SemVer for app and modules
- Release checklist (signing, tests green, changelog)