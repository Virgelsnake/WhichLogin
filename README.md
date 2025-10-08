# WhichLogin

A macOS menu-bar app with Safari Web Extension that remembers which SSO sign-in method you used on each site and reminds you on return visits.

## Features

- 🔐 **Remember Login Methods**: Automatically detects and remembers which sign-in method you used (Apple, Google, Microsoft, GitHub, Facebook, LinkedIn, Email/Password, etc.)
- 🔔 **Smart Reminders**: Shows a subtle hint when you return to a login page
- 🔒 **Privacy-First**: All data stored locally with encryption, no cloud sync, no data collection
- 🎯 **Safari Integration**: Native Safari Web Extension for seamless detection
- 📊 **Track History**: View login history and statistics for each site
- 🎨 **Customizable**: Configure hint position, timeout, and behavior

## Requirements

- macOS 13.0 or later
- Safari 16.0 or later
- Xcode 16.0 or later (for building)

## Building

1. Clone the repository:
```bash
git clone https://github.com/Virgelsnake/WhichLogin.git
cd WhichLogin
```

2. Open the project in Xcode:
```bash
open WhichLogin.xcodeproj
```

3. Build and run:
   - Select the `WhichLogin` scheme
   - Choose your Mac as the destination
   - Press Cmd+R to build and run

## Enabling the Safari Extension

1. Launch WhichLogin app
2. Open Safari → Preferences → Extensions
3. Enable "WhichLogin Extension"
4. Grant necessary permissions when prompted

## Usage

### First Time on a Site
1. Visit a login page
2. Click your preferred sign-in method (e.g., "Continue with Google")
3. WhichLogin automatically records your choice

### Returning to a Site
1. Visit the same login page again
2. See a hint: "You last signed in here with **Google**"
3. Click your usual method with confidence

### Managing Sites
- Click the menu bar icon to view all tracked sites
- Search for specific sites
- Edit or delete individual site preferences
- Mark sites as "ignored" to disable hints
- Export/import your data as JSON

## Architecture

### Components

- **macOS App** (SwiftUI): Menu-bar interface and data management
- **Safari Extension**: Content script for detection and hint display
- **Shared Storage**: App Group container with encrypted data
- **Services**:
  - `StorageService`: Manages preferences with CryptoKit encryption
  - `DomainNormalizer`: Normalizes domains to eTLD+1

### Data Storage

- Location: App Group container (`group.com.virgelsnake.WhichLogin`)
- Encryption: AES-GCM with key stored in Keychain
- Format: JSON with Codable models

### Detection Methods

1. **Button Detection**: Scans for SSO provider buttons by text/aria labels
2. **OAuth Navigation**: Tracks navigation to known IdP domains
3. **Form Submission**: Detects email/password form submissions

## Privacy & Security

- ✅ **No passwords captured** - Only records which method was used
- ✅ **No network requests** - Everything stays on your device
- ✅ **Encrypted storage** - Data encrypted at rest with CryptoKit
- ✅ **App Sandbox** - Runs in sandboxed environment
- ✅ **No analytics** - Zero telemetry or tracking

## Development

### Project Structure

```
WhichLogin/
├── WhichLogin/              # macOS app
│   ├── Models/              # Data models
│   ├── Services/            # Business logic
│   ├── Views/               # SwiftUI views
│   └── Resources/           # Assets
├── WhichLoginExtension/     # Safari extension
│   ├── Resources/           # Extension files
│   │   ├── manifest.json
│   │   ├── background.js
│   │   └── content.js
│   └── SafariWebExtensionHandler.swift
├── WhichLoginTests/         # Unit tests
└── WhichLoginUITests/       # UI tests
```

### Running Tests

```bash
# Unit tests
xcodebuild test -scheme WhichLogin -destination 'platform=macOS'

# All tests
xcodebuild test -scheme WhichLogin -destination 'platform=macOS' -enableCodeCoverage YES
```

### Code Style

- SwiftFormat for formatting
- SwiftLint for linting (if configured)

## Roadmap

### Future Enhancements (Post-MVP)

- [ ] Chrome/Edge/Firefox extensions
- [ ] iOS/iPadOS Safari extension
- [ ] iCloud sync (opt-in)
- [ ] Password manager integration
- [ ] Visual button highlighting
- [ ] Custom deny-list for sensitive sites

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

Copyright © 2025 WhichLogin. All rights reserved.

## Support

For issues or questions:
- GitHub Issues: https://github.com/Virgelsnake/WhichLogin/issues

## Acknowledgments

Built following Apple's Safari Web Extension guidelines and macOS App Sandbox best practices.
