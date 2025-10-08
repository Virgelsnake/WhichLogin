# PRD — “WhichLogin” (working title)
*A tiny macOS + Safari helper that remembers which sign-in method you last used on each site and nudges you next time.*

---

## 1) Summary

**Problem**  
Modern sites offer multiple Single Sign-On (SSO) options (Apple, Google, Microsoft, GitHub, Facebook) alongside email/password. It’s convenient on day one, but weeks later users often can’t remember which method they used.

**Solution (MVP)**  
A **macOS menu-bar app** with a **Safari Web Extension** that:
- Detects login pages and captures the **sign-in method actually used** (locally, no passwords).  
- Stores a domain → last-used-method mapping **securely on device**.  
- On future visits to that site, shows a **subtle in-page hint**: “You last signed in here with Apple.”  
- Lets users **override/edit** the method per site and **ignore** selected sites.

**Platforms (MVP):** macOS (Safari only).  
**Tech:** Swift/SwiftUI (macOS app), **Safari Web Extension** (TypeScript/JS + content scripts) with **App Group** storage shared between the app and extension. No cloud/backend.

---

## 2) Goals & Non-Goals

### Goals (MVP)
- Remember the **last sign-in method** per site (eTLD+1 level, e.g., `notion.so`).
- Detect common SSO providers: **Apple, Google, Microsoft, GitHub, Facebook, LinkedIn** and **Email/Password**, **Magic-Link/OTP**.
- Present a **low-friction reminder** on subsequent visits.
- Provide a simple **menu-bar UI** to view, search, edit, export/import mappings.
- Keep **all data local**; no collection of passwords, emails, or keystrokes.

### Non-Goals (for MVP)
- No Chrome/Firefox/Edge support (future).
- No iOS/iPadOS build (future).
- No integration with third-party password managers (future).
- No server syncing/analytics (future opt-in CloudKit/iCloud possible).
- No automatic account creation/auto-login.

---

## 3) Personas & Key User Stories

### Persona: Steve (busy pro, multi-site logins)
- *As a user,* when I visit a site’s login page, **I want to see which method I used last time**, so I don’t guess wrong.
- *As a user,* when I click a different method, **I want the app to update** the stored preference automatically.
- *As a user,* I want to **edit or clear** a site’s saved method and **ignore** certain sites (e.g., banking).
- *As a user,* I want **zero impact on security**: no passwords captured or transmitted.

**Acceptance hints**  
- Given a stored method for `example.com`, visiting its login page shows a hint within 300 ms.  
- Changing method updates storage immediately and shows “Updated”.

---

## 4) User Journey (Happy Path)

1. **Install & Onboard (macOS)**
   - User installs the app, sees a short privacy-first onboarding: local-only, no passwords collected.
   - App asks to **enable Safari Web Extension** (guided steps with deep link to Safari → Preferences → Extensions).

2. **First login on a site**
   - User lands on `example.com/login`. Content script detects a login context.
   - On button click (e.g., “Continue with Google”) or detected OAuth redirect, extension **records “Google”** for `example.com`.

3. **Return visit**
   - On next visit to `example.com/login`, a **non-intrusive banner** appears bottom-right:  
     “You last signed in here with **Google** · [Change] [Dismiss]”
   - Clicking **Change** reveals other detected options (if present) or opens the menu-bar app to change manually.

4. **Manage (menu-bar app)**
   - User can search sites, edit methods, export/import JSON, toggle “Ignore this site”, and tweak hint behaviour (size/timeout/position).

---

## 5) Scope

### In-Scope (MVP)
- macOS app (SwiftUI menu-bar) + Safari Web Extension.
- Detection of login pages + capture of selected SSO method.
- Local encrypted storage via **App Group** (shared container).
- Per-site settings: method, ignore, last seen, times seen.
- In-page hint UI injection (content script).
- Basic export/import (JSON).

### Out-of-Scope (MVP)
- Cross-browser support; iOS build; cloud sync; telemetry/analytics; password manager integrations; team/org features.

---

## 6) Functional Requirements

1. **Detect login context**
   - Heuristics (any of):
     - Presence of form with `input[type="email"|"text"]` + `input[type="password"]`.
     - Buttons/links containing text alt/title/aria: “Sign in with”, “Continue with”, “Log in with” + provider keyword.
     - Observed navigation to known IdP hosts (e.g., `appleid.apple.com`, `accounts.google.com`, `login.microsoftonline.com`, `github.com/login/oauth`, `www.facebook.com/v*/*oauth*`, `www.linkedin.com/oauth/*`).
2. **Capture chosen method**
   - Attach click listeners to provider buttons; on click, record provider.
   - Fallback: watch for navigation to known IdP domains within same tab.
3. **Map site → method**
   - Key by **eTLD+1** of top-level page (e.g., logging on from `app.notion.so` maps to `notion.so`).  
   - Store: `site`, `lastMethod`, `history[]`, `lastSeenAt`, `timesSeen`, `ignored`.
4. **Reminder on revisit**
   - Inject minimal **banner** (ARIA-accessible; dismissible; remembers dismissal for the session).
5. **User controls**
   - Menu-bar app: table list, search, edit method, toggle ignore, export/import JSON, “clear all”.
   - Per-site “Never show again” from the banner (sets ignored).
6. **Accessibility & Localisation**
   - Keyboard-navigable hint; VoiceOver labels; localisable strings (EN-GB initially).
7. **Performance**
   - Content script ≤ ~50 KB minified; inject only on likely login pages (URL patterns + heuristics).  
   - Hint renders ≤ 300 ms from DOMContentLoaded.

---

## 7) Non-Functional Requirements

- **Privacy & Security**: No passwords/keystrokes captured; no network transmission. Data is **local only**.  
- **Storage**: Encrypt sensitive blobs with **CryptoKit**; file protection `NSFileProtectionComplete`.  
- **Sandboxing**: App Sandbox enabled; **App Group** for shared container with extension.  
- **Reliability**: If heuristics fail, no crash; simply don’t show a hint.  
- **Updatability**: Provider patterns are table-driven to update without code changes (local JSON).

---

## 8) Architecture Overview

```
+-------------------+       Messaging (runtime)       +---------------------------+
| Safari Web        | <--------------------------------> | macOS Host App (SwiftUI) |
| Extension (TS/JS) |  browser.runtime.sendMessage      |  Menu-bar UI              |
|  - Content script |  + App Group shared storage       |  Persistence / Crypto     |
|  - Background     |  (shared container)               |  Settings & Export/Import |
+-------------------+                                   +---------------------------+
             |                                      
             | Inject hint / detect IdP
             v
        Web page DOM
```

- **Extension**: Content script detects login forms & provider buttons; background script handles domain normalisation (eTLD+1) and writes to shared store through native messaging (if needed) or writes to the shared file directly if permitted (preferred: message app to write).  
- **macOS App**: Menu-bar app (SwiftUI) reads/writes storage, hosts preferences, provides onboarding, and manages allow/ignore lists.

---

## 9) Tech Choices & Rationale

- **Safari Web Extension** over standalone app-only detection  
  - Only reliable, privacy-respecting way to inspect page DOM in Safari.  
  - Apple-blessed approach; portable later to iOS Safari.
- **SwiftUI + AppKit (menu-bar)**  
  - Modern UI with minimal footprint; NSStatusBar for menu-bar presence.
- **App Groups**  
  - Safe data sharing between app and extension.
- **CryptoKit**  
  - Simple, modern encryption at rest for the store (even though data is low-sensitivity).
- **Core Data or SQLite**  
  - Start with **Core Data** for speed; model is simple (one main entity + history). JSON export covers portability.
- **eTLD+1 handling**  
  - Bundle Public Suffix List and resolve via a small Swift helper to avoid mis-grouping subdomains.

---

## 10) Data Model (Core Data)

**Entity: SiteLoginPreference**
- `id`: UUID
- `site`: String (eTLD+1; e.g., `notion.so`)
- `lastMethod`: Enum (`apple|google|microsoft|github|facebook|linkedin|email_password|magic_link|sms_otp|other`)
- `history`: [ (method: Enum, timestamp: Date) ] (serialised JSON)
- `lastSeenAt`: Date
- `timesSeen`: Int
- `ignored`: Bool (default false)

**Entity: Settings**
- `showHint`: Bool (default true)
- `hintPosition`: Enum (`bottom_right` default)
- `hintTimeoutMs`: Int (default 6000)
- `language`: String (`en-GB`)

---

## 11) Detection Heuristics (MVP)

**A. DOM Button/Text detection (content script)**  
- Query buttons/links with innerText/aria/alt/title matching regex:  
  `/(sign\s*in|log\s*in|continue)\s*(with|via)\s*(apple|google|microsoft|github|facebook|linkedin)/i`
- Provider mapping table checks brand keywords and common CSS classes (e.g., `apple-sign-in-button`, `gsi_material_button`, `signin-with-github`).

**B. OAuth Host detection (navigation/webRequest)**  
- If the tab navigates to one of:
  - `appleid.apple.com/auth/*`
  - `accounts.google.com/o/oauth2/*`
  - `login.microsoftonline.com/*`
  - `github.com/login/oauth/*`
  - `www.facebook.com/*oauth*`
  - `www.linkedin.com/oauth/*`
- Record provider for the **originating site** (previous page’s eTLD+1).  
- If neither A nor B triggers but a `password` field is submitted, record `email_password`.

**C. Magic-Link/OTP heuristic**
- Presence of “Send magic link” / “Email me a link” or one-time code inputs; record `magic_link` or `sms_otp`.

Fallback: if ambiguous, don’t record (safety > guess).

---

## 12) UX Spec (MVP)

**In-page Hint (content script)**
- Placement: bottom-right (12px margin), rounded, subtle shadow.
- Copy: `You last signed in here with **Apple**.`  
  Buttons: `[Change] [Dismiss]`.
- Keyboard: `Esc` dismisses; `Tab` focuses buttons; aria-live polite.
- Theme: auto light/dark based on page `prefers-color-scheme` where available.

**Menu-bar App**
- Status icon: simple key/checkmark glyph.
- Views:
  - **Home**: search box + table (`Site`, `Last Method`, `Last Seen`, `Ignored`, `Times Seen`).
  - **Edit Drawer**: change method via picker; toggle ignore; view history.
  - **Settings**: hint behaviour; export/import JSON; reset.
  - **Onboarding**: 3 steps with animation → enable extension guide.

---

## 13) Permissions & Privacy

- **Safari extension permissions**: `activeTab`, host permissions for `*://*/*` (can be user-granted per site at runtime).  
- **No network calls** from extension or app (MVP).  
- **Privacy Notice** (first-run + settings): explains local-only storage, no collection of credentials or personal data.  
- **Sensitive sites**: built-in deny-list (e.g., major banks) + user custom deny-list.

---

## 14) Security Notes

- **No password fields read** or stored; no keystroke listeners.  
- **Data at rest**: encrypted blob within App Group container using symmetric key stored in Keychain (kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly).  
- **Tamper safety**: JSON export excludes Keychain key; imports only plain mappings.

---

## 15) Testing & QA

**Unit tests (Swift)**
- eTLD+1 normalisation.  
- Persistence + encryption round-trip.  
- Import/export fidelity.

**Extension tests (TS/JS)**
- DOM detector against mock pages (fixtures):
  - Email/password only.
  - Google/Apple/Microsoft/GitHub buttons.
  - Magic-link flows.
- OAuth host detector with synthetic navigation events.

**Manual scenarios**
- First-time detection, reminder rendering, method switch, ignore site, export/import.

**Mock pages**  
- Host simple static fixtures locally (e.g., `http://localhost:3000/login-google.html`, `login-apple.html`, `login-email.html`) with realistic markup.

---

## 16) Milestones

**M0 — Skeleton (3–4 days)**
- Menu-bar app shell (SwiftUI), Core Data model, App Group, basic list UI.
- Safari Web Extension scaffolding; message bridge.

**M1 — Detection & Store (4–6 days)**
- DOM & OAuth host detection (Google/Apple/Microsoft/GitHub).  
- Record/update mapping; domain normaliser.

**M2 — Hint UI & Controls (3–5 days)**
- Injected hint banner with change/dismiss; per-site ignore.  
- Settings: enable/disable hint; export/import JSON.

**M3 — Hardening & A11y (3–4 days)**
- Accessibility pass, localisations stub, deny-list, performance tidy.  
- QA on a list of 10 popular sites.

---

## 17) Risks & Mitigations

- **Heuristic drift** (sites change markup) → Keep provider patterns table-driven; add multiple matchers.  
- **Permission friction in Safari** → Onboarding flows with clear “why” and per-site enablement.  
- **False positives** (non-login pages) → Conservative triggers (forms + keywords + nav patterns).  
- **App Review (future)** → No credential handling; clear value; complies with 2.5.x, 5.x policies.

---

## 18) Future Roadmap (post-MVP)

- **Browsers**: Chrome/Edge/Firefox extensions.  
- **iOS/iPadOS**: Safari Web Extension on iOS 15+.  
- **Sync**: iCloud/CloudKit (opt-in).  
- **Password manager bridges**: surface “last method” within item notes via user-initiated copy/paste helpers.  
- **Smart autosuggest**: highlight the matching SSO button in-page.

---

## 19) Implementation Notes (Dev Aids)

**Provider Patterns (seed list)**
- Apple → `appleid.apple.com` or text: “Sign in with Apple”.
- Google → `accounts.google.com` or text: “Continue with Google”.
- Microsoft → `login.microsoftonline.com`, `live.com`.
- GitHub → `github.com/login/oauth`.
- Facebook → `facebook.com/*oauth*`.
- LinkedIn → `linkedin.com/oauth`.

**Content Script (pseudo)**
```js
// 1) Detect login context
const isLogin = !!document.querySelector('input[type="password"], button,[aria-label*="sign in"], [aria-label*="log in"]');

// 2) Wire provider buttons
const map = [
  { key:'apple',      rx:/apple/i },
  { key:'google',     rx:/google/i },
  { key:'microsoft',  rx:/microsoft|azure/i },
  { key:'github',     rx:/github/i },
  { key:'facebook',   rx:/facebook/i },
  { key:'linkedin',   rx:/linkedin/i },
];
document.querySelectorAll('button,a').forEach(el=>{
  const text = (el.textContent||'') + ' ' + (el.getAttribute('aria-label')||'') + ' ' + (el.getAttribute('title')||'');
  for (const p of map) {
    if (p.rx.test(text)) el.addEventListener('click', ()=> record(p.key));
  }
});

// 3) Observe navigation to known IdPs (background script handles webNavigation, sends message to content)
// onMessage('idpNavigated', ({provider}) => record(provider));

// 4) Show hint if we have a record
getStoredMethodForSite().then(m => m && injectHint(m));
```

**Domain Normalisation**  
- Use bundled Public Suffix List; resolve eTLD+1 for `window.location.hostname`.

---

## 20) Deliverables (MVP)

- **Xcode workspace** containing:
  - `WhichLogin.app` (macOS menu-bar, SwiftUI).
  - `WhichLoginExtension` (Safari Web Extension).
- **README** with build/run steps and Safari extension enablement guide.
- **Fixtures**: local mock login pages.
- **Unit/UI tests** suite.
- **Privacy policy** (local-only, no data collection).
- **JSON schema** for export/import.

---

## 21) Success Metrics (qualitative for MVP)

- Users report **no more guesswork** on ≥80% of revisited sites with SSO options.  
- **<300 ms** hint render time on cached pages.  
- **Zero** instances of password or PII capture in code audit.

---

## 22) Open Questions (track in backlog)

- Should we ship with an **initial ignore list** (banks, HMRC, NHS) and allow users to opt-in per site?  
- Do we highlight the matching SSO button visually (border/pulse) for quicker recognition?  
- Add **manual quick-set** from the hint (“I used email this time”) without reloading?
