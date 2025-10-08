# Master Implementation Guide — Swift/Xcode (iOS & macOS)
_Last updated: 2025-10-08_

This guide standardises day‑to‑day development tasks for Swift projects in Xcode targeting iOS and macOS.

## 1) Project Setup
- Install **Xcode (latest stable)** from the Mac App Store.
- Ensure command‑line tools: `xcode-select --install`
- Confirm Swift/Xcode versions: `xcodebuild -version`, `swift --version`

### 1.1 Repos & Branching
- Default branches: `main`, `develop`
- Feature branches: `feature/<ticket>`, PRs require 1 review + CI green.

## 2) Dependency Management (SPM preferred)
- Add dependencies via **Xcode → Project → Package Dependencies**.
- **Do not** create a top‑level `Package.swift` for app projects unless you are building a library/package.
- Version pinning: use `.upToNextMajor(from: "x.y.z")` and document in `README.md`.
- Avoid mixing CocoaPods and SPM for the same target.

## 3) Targets & Schemes
- Create schemes per app and per test target; mark Shared (Manage Schemes → Shared) for CI.
- Configurations: `Debug`, `Release`, optional `Beta/Staging`.

## 4) Build & Run
### 4.1 xcodebuild (choose one)
- **Workspace present (CocoaPods/multi‑project):**
  ```
  xcodebuild -workspace <Name>.xcworkspace -scheme <Scheme>     -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build
  ```
- **Project only:**
  ```
  xcodebuild -project <Name>.xcodeproj -scheme <Scheme>     -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build
  ```

List simulators: `xcrun simctl list devices`

### 4.2 Testing
```
xcodebuild test -scheme <Scheme>   -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

## 5) Linting & Formatting
- **SwiftFormat**: enforce style — run `swiftformat .`
- **SwiftLint**: static checks — run `swiftlint --strict`
- Add both to CI; fail the build on violations.

## 6) Concurrency & Threads
- Prefer **Swift Concurrency** (async/await, Task, actors).
- Annotate UI code with `@MainActor` where appropriate.
- Avoid mixing GCD and async/await in the same flow unless necessary.

## 7) UI Frameworks
- **SwiftUI** first; use UIKit (iOS/iPadOS) or AppKit (macOS) if needed.
- Previews: Use **Xcode’s SwiftUI canvas**. Browser previews are **not supported**.
- Navigation: `NavigationStack` / `NavigationSplitView`.

## 8) Configuration & Secrets
- `.xcconfig` files for environment flags.
- Never commit API keys; use Keychain and CI secrets.

## 9) Code Signing & Provisioning
- Set Team, Bundle IDs, and capabilities per target.
- iOS/iPadOS distribution via TestFlight → App Store.
- macOS distribution:
  - **App Store:** standard submission.
  - **Outside the store:** Developer ID, **Notarisation**, **Hardened Runtime**, **App Sandbox** as appropriate.

## 10) Accessibility
- Support Dynamic Type, VoiceOver, colour contrast.
- Test with Accessibility Inspector.

## 11) Logging & Analytics
- Use `os.Logger` with categories. No PII in logs.
- Crash reporting via Xcode Organizer or third‑party (e.g., Crashlytics).

## 12) CI/CD Notes
- Cache SPM to speed builds.
- Export archives via `xcodebuild -exportArchive` or Fastlane (optional).
- Keep CI images aligned with local Xcode version.

## 13) Troubleshooting
- Simulator not found: run `xcrun simctl create` or pick an available device.
- Duplicate symbols: check for mixed dependency managers on the same target.
- Build fails after dependency change: clean (`Shift+Cmd+K`), resolve packages, re‑build.

## 14) Mac‑specific Requirements
- State whether the macOS app is **Catalyst** or **AppKit**.
- Identify entitlements needed for App Sandbox.
- Document any Hardened Runtime exceptions.

---
**Appendix A — Useful Commands**
```
# Clean build
xcodebuild -scheme <Scheme> clean build

# Unit tests with result bundle
xcodebuild test -scheme <Scheme>   -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'   -resultBundlePath TestResults.xcresult

# List available destinations
xcodebuild -showdestinations -scheme <Scheme>
```

**Appendix B — Template Swift Package Entry**
```swift
.package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
         .upToNextMajor(from: "1.12.0"))
```