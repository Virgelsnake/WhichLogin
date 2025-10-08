# Privacy Policy - WhichLogin

**Last Updated: October 8, 2025**

## Overview

WhichLogin is designed with privacy as a core principle. This document explains our approach to data handling and privacy.

## Data Collection

**WhichLogin collects NO personal data.**

Specifically, we do NOT collect, store, or transmit:
- Passwords
- Email addresses
- Usernames
- Keystrokes
- Personal information
- Browsing history (beyond login page visits)
- Analytics or telemetry

## What We Store Locally

WhichLogin stores the following information **locally on your device only**:

1. **Domain names** of websites where you've logged in (e.g., "example.com")
2. **Login method used** (e.g., "Google", "Apple", "Email/Password")
3. **Timestamps** of when you last visited each login page
4. **Visit counts** for each site
5. **User preferences** (hint settings, ignored sites)

## Data Storage

- **Location**: All data is stored in an App Group container on your Mac
- **Encryption**: Data is encrypted at rest using Apple's CryptoKit (AES-GCM)
- **Encryption Key**: Stored securely in macOS Keychain with device-only access
- **File Protection**: Complete file protection (data inaccessible when device is locked)

## Data Transmission

**WhichLogin makes ZERO network requests.**

- No data is sent to external servers
- No cloud synchronization (in MVP version)
- No analytics or crash reporting to third parties
- The Safari extension communicates only with the local macOS app

## Permissions

### Safari Extension Permissions

- **Active Tab**: Required to detect login pages and show hints
- **Host Permissions** (`*://*/*`): Required to work on all websites
  - Used ONLY for login detection
  - No data is extracted beyond detecting login method selection

### macOS App Permissions

- **App Sandbox**: Enabled for security
- **App Group**: For sharing data between app and extension
- **File Access**: User-selected files only (for export/import)
- **Network**: DISABLED - app makes no network requests

## Third-Party Services

WhichLogin does NOT use any third-party services, SDKs, or analytics platforms.

## Data Retention

- Data is retained indefinitely until you delete it
- You can delete individual sites or clear all data at any time
- Uninstalling the app removes all stored data

## User Control

You have complete control over your data:

1. **View**: See all tracked sites in the menu-bar app
2. **Edit**: Change recorded login methods
3. **Delete**: Remove individual sites or clear all data
4. **Ignore**: Mark sites to disable tracking
5. **Export**: Export your data as JSON
6. **Import**: Import previously exported data

## Children's Privacy

WhichLogin does not knowingly collect data from anyone, including children under 13.

## Changes to Privacy Policy

We may update this privacy policy. Changes will be reflected in the "Last Updated" date above.

## Open Source

WhichLogin's code is open source. You can review exactly what data is collected and how it's handled:
https://github.com/Virgelsnake/WhichLogin

## Contact

For privacy questions or concerns:
- GitHub Issues: https://github.com/Virgelsnake/WhichLogin/issues

## Compliance

WhichLogin is designed to comply with:
- Apple App Store Review Guidelines
- macOS App Sandbox requirements
- Safari Web Extension policies
- GDPR principles (data minimization, user control)
- CCPA principles (transparency, user rights)

## Your Rights

Since all data is stored locally on your device:
- You have complete ownership of your data
- You can access all data through the app interface
- You can export your data at any time
- You can delete all data at any time
- No data is shared with us or third parties

---

**Summary**: WhichLogin is a privacy-first tool. All data stays on your device, encrypted and under your control. We collect no personal information and make no network requests.
