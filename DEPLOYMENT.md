# WhichLogin - Deployment Guide

## Distribution Options

WhichLogin can be distributed in three ways:

1. **Direct Distribution** (Developer ID, notarized)
2. **Mac App Store**
3. **Open Source / Self-Build**

## Option 1: Direct Distribution (Recommended for MVP)

### Prerequisites

- Apple Developer Account ($99/year)
- Developer ID Application certificate
- Developer ID Installer certificate (for .pkg)

### Step 1: Configure Code Signing

1. Open `project.yml`
2. Update settings:

```yaml
settings:
  base:
    DEVELOPMENT_TEAM: "YOUR_TEAM_ID"
    CODE_SIGN_STYLE: Automatic
    CODE_SIGN_IDENTITY: "Developer ID Application"
    ENABLE_HARDENED_RUNTIME: YES
```

3. Regenerate project:

```bash
xcodegen generate
```

4. In Xcode, for both targets:
   - Select your Team
   - Enable **Hardened Runtime**
   - Enable **App Sandbox**
   - Add **App Groups** entitlement: `group.com.yourteam.WhichLogin`

### Step 2: Update Bundle IDs

Update in `project.yml`:

```yaml
PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.WhichLogin
# Extension:
PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.WhichLogin.Extension
```

### Step 3: Archive the App

```bash
xcodebuild archive \
  -project WhichLogin.xcodeproj \
  -scheme WhichLogin \
  -archivePath ./build/WhichLogin.xcarchive \
  -destination 'generic/platform=macOS'
```

Or in Xcode:
- Product → Archive
- Wait for archive to complete
- Organizer window will open

### Step 4: Export for Distribution

```bash
xcodebuild -exportArchive \
  -archivePath ./build/WhichLogin.xcarchive \
  -exportPath ./build/export \
  -exportOptionsPlist ExportOptions.plist
```

Create `ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

### Step 5: Notarize the App

```bash
# Create a zip for notarization
ditto -c -k --keepParent ./build/export/WhichLogin.app WhichLogin.zip

# Submit for notarization
xcrun notarytool submit WhichLogin.zip \
  --apple-id "your@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple the notarization ticket
xcrun stapler staple ./build/export/WhichLogin.app
```

### Step 6: Create DMG (Optional)

```bash
# Install create-dmg if needed
brew install create-dmg

# Create DMG
create-dmg \
  --volname "WhichLogin" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "WhichLogin.app" 175 120 \
  --hide-extension "WhichLogin.app" \
  --app-drop-link 425 120 \
  "WhichLogin.dmg" \
  "./build/export/WhichLogin.app"
```

### Step 7: Distribute

- Upload to your website
- Share download link
- Users can drag to Applications folder

## Option 2: Mac App Store

### Prerequisites

- Apple Developer Account
- Mac App Store distribution certificate
- App Store provisioning profile

### Additional Requirements

1. **App Store entitlements** (more restrictive):
   - No hardened runtime exceptions
   - Stricter sandbox rules
   - May need additional permissions

2. **App Store metadata**:
   - App name, description, keywords
   - Screenshots (required sizes)
   - Privacy policy URL
   - Support URL
   - App icon (all sizes)

3. **App Review preparation**:
   - Demo account (if needed)
   - Review notes
   - Test instructions

### Steps

1. Configure for App Store in `project.yml`:

```yaml
settings:
  base:
    CODE_SIGN_IDENTITY: "Apple Distribution"
    PROVISIONING_PROFILE_SPECIFIER: "WhichLogin App Store"
```

2. Archive and export for App Store:

```bash
xcodebuild -exportArchive \
  -archivePath ./build/WhichLogin.xcarchive \
  -exportPath ./build/appstore \
  -exportOptionsPlist ExportOptionsAppStore.plist
```

3. Upload via Xcode Organizer or Transporter app

4. Submit for review in App Store Connect

### App Store Review Considerations

- **Privacy**: Emphasize local-only storage, no data collection
- **Functionality**: Provide clear demo/test instructions
- **Safari Extension**: Explain permissions needed
- **Value**: Demonstrate clear user benefit

## Option 3: Open Source / Self-Build

Current setup supports this:

1. Users clone repository
2. Open in Xcode
3. Build and run
4. Enable extension in Safari

### Documentation for Users

Include in README:
- Build instructions
- Safari extension setup
- Troubleshooting guide

## Post-Deployment

### Version Updates

1. Update version in `project.yml`:

```yaml
MARKETING_VERSION: "1.1.0"
CURRENT_PROJECT_VERSION: "2"
```

2. Update changelog
3. Rebuild and redistribute

### Analytics (Optional)

For future versions, consider:
- Crash reporting (Sentry, Crashlytics)
- Anonymous usage stats (with user consent)
- Update checking mechanism

### Support Channels

Set up:
- GitHub Issues for bug reports
- Discussion forum or Discord
- Email support
- FAQ/Knowledge base

## Security Checklist

Before distribution:

- [ ] Code signing configured correctly
- [ ] Hardened Runtime enabled
- [ ] App Sandbox enabled
- [ ] Entitlements minimized (only what's needed)
- [ ] No hardcoded secrets or API keys
- [ ] Encryption keys properly stored in Keychain
- [ ] File permissions set correctly
- [ ] Network access disabled (as per design)
- [ ] Privacy policy published
- [ ] Open source code reviewed

## Testing Before Release

- [ ] Fresh install on clean macOS system
- [ ] Test on minimum supported macOS version (13.0)
- [ ] Test Safari extension enablement flow
- [ ] Test all core features
- [ ] Test upgrade from previous version (if applicable)
- [ ] Test uninstall/reinstall
- [ ] Verify no data leaks
- [ ] Check performance and memory usage
- [ ] Accessibility testing (VoiceOver, keyboard navigation)

## Release Checklist

- [ ] Version number updated
- [ ] Changelog updated
- [ ] Documentation updated
- [ ] Tests passing
- [ ] Code signed
- [ ] Notarized (if direct distribution)
- [ ] DMG/installer created
- [ ] Release notes written
- [ ] GitHub release created
- [ ] Download links updated
- [ ] Announcement prepared

## Rollback Plan

If issues are discovered post-release:

1. Remove download links
2. Post notice about issue
3. Fix bug in new version
4. Test thoroughly
5. Release hotfix version
6. Notify users of update

## Legal Considerations

- [ ] Privacy policy published and linked
- [ ] Terms of service (if applicable)
- [ ] Open source license (MIT, Apache, etc.)
- [ ] Third-party licenses acknowledged
- [ ] Trademark considerations
- [ ] GDPR/CCPA compliance (even though local-only)

## Future Distribution Enhancements

- **Auto-updates**: Implement Sparkle framework
- **Beta channel**: TestFlight or separate beta builds
- **Homebrew cask**: For easy installation via `brew install`
- **Multiple languages**: Localization for international users

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [App Sandbox Guide](https://developer.apple.com/documentation/security/app_sandbox)
- [Safari Extension Guide](https://developer.apple.com/documentation/safariservices/safari_web_extensions)
