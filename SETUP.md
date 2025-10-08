# WhichLogin - Setup & Testing Guide

## Prerequisites

- macOS 13.0 or later
- Xcode 16.0 or later
- Safari 16.0 or later

## Building the Application

### 1. Clone and Build

```bash
git clone https://github.com/Virgelsnake/WhichLogin.git
cd WhichLogin
open WhichLogin.xcodeproj
```

### 2. Configure Code Signing (Optional for Development)

The project is currently configured for **ad-hoc signing** (no developer account required).

For **proper distribution**, you'll need to:

1. Open `WhichLogin.xcodeproj` in Xcode
2. Select the `WhichLogin` target
3. Go to "Signing & Capabilities"
4. Select your Team
5. Update Bundle IDs if needed
6. Enable App Groups: `group.com.virgelsnake.WhichLogin`
7. Repeat for `WhichLoginExtension` target

### 3. Build and Run

In Xcode:
- Select the `WhichLogin` scheme
- Choose "My Mac" as destination
- Press `Cmd+R` to build and run

Or via command line:

```bash
xcodebuild -project WhichLogin.xcodeproj \
  -scheme WhichLogin \
  -destination 'platform=macOS' \
  build
```

## Enabling the Safari Extension

### Step 1: Launch the App

1. Build and run WhichLogin
2. The app will appear in your menu bar (key icon)
3. Keep the app running

### Step 2: Enable in Safari

1. Open Safari
2. Go to **Safari → Settings** (or Preferences)
3. Click **Extensions** tab
4. Find **WhichLogin Extension** in the list
5. Check the box to enable it
6. Click **Turn On** if prompted

### Step 3: Grant Permissions

1. Safari may ask for permissions to access websites
2. Choose **Allow** or **Always Allow**
3. You can manage permissions per-site later

## Testing the Extension

### Quick Test with Mock Pages

1. Start a local web server:

```bash
cd TestPages
python3 -m http.server 8000
```

2. Open Safari and navigate to:
   - <http://localhost:8000/login-multi-sso.html>

3. Test the workflow:
   - Click "Continue with Google" button
   - Check the menu bar app - you should see `localhost` added
   - Refresh the page
   - You should see a hint: "You last signed in here with **Google**"

### Testing Different Scenarios

#### Test SSO Detection

1. Open `login-multi-sso.html`
2. Click different SSO buttons:
   - Continue with Apple
   - Continue with Microsoft
   - Continue with GitHub
3. Each click should record the method
4. Revisit to see the hint updates

#### Test Email/Password

1. Open `login-email-only.html`
2. Fill in email and password
3. Click "Sign In"
4. Should record as "Email/Password"

#### Test Hint Customization

1. Click menu bar icon
2. Click gear icon (Settings)
3. Try different options:
   - Toggle "Show hints on login pages"
   - Change hint position
   - Adjust timeout
4. Test changes on mock pages

#### Test Site Management

1. Click menu bar icon
2. View tracked sites
3. Click a site to edit:
   - Change login method
   - Toggle "Ignore this site"
   - View history
   - Delete site

## Testing with Real Sites

### Recommended Test Sites

1. **GitHub** (<https://github.com/login>)
   - Has multiple SSO options
   - Easy to test without actual login

2. **Notion** (<https://www.notion.so/login>)
   - Multiple providers
   - Good for testing domain normalization

3. **Medium** (<https://medium.com/m/signin>)
   - Google, Facebook, Email options

### Testing Workflow

1. Navigate to a login page
2. **Don't actually log in** - just click the SSO button
3. The extension should detect the click
4. Check the menu bar app to verify recording
5. Revisit the page to see the hint

## Troubleshooting

### Extension Not Appearing in Safari

- Make sure WhichLogin app is running
- Restart Safari
- Check Safari → Settings → Extensions
- Try disabling and re-enabling the extension

### Hints Not Showing

1. Check Settings in the app:
   - Is "Show hints on login pages" enabled?
   - Is the site marked as "Ignored"?

2. Check Safari Console:
   - Right-click page → Inspect Element
   - Go to Console tab
   - Look for WhichLogin messages

3. Check Extension Permissions:
   - Safari → Settings → Extensions → WhichLogin
   - Ensure permissions are granted

### Detection Not Working

1. Open Safari Console on the login page
2. Look for messages like:
   - "WhichLogin content script loaded"
   - "Login page detected"
   - "Provider button clicked: google"

3. If no messages appear:
   - Extension may not be injecting
   - Check extension is enabled
   - Try refreshing the page

### Data Not Persisting

1. Check file permissions:

```bash
ls -la ~/Library/Application\ Support/WhichLogin/
```

2. Check for encryption key in Keychain:
   - Open Keychain Access app
   - Search for "WhichLoginEncryptionKey"

### Build Errors

#### Code Signing Errors

If you see entitlements errors:
- The project uses ad-hoc signing by default
- For App Store distribution, configure proper signing
- For development, the current setup should work

#### Missing Dependencies

```bash
# Regenerate Xcode project
xcodegen generate

# Clean build
xcodebuild clean -project WhichLogin.xcodeproj -scheme WhichLogin
```

## Running Tests

### Unit Tests

```bash
xcodebuild test \
  -project WhichLogin.xcodeproj \
  -scheme WhichLogin \
  -destination 'platform=macOS'
```

Or in Xcode:
- Press `Cmd+U`

### Manual Testing Checklist

- [ ] App launches and appears in menu bar
- [ ] Safari extension can be enabled
- [ ] Extension detects login pages
- [ ] SSO button clicks are recorded
- [ ] Email/password form submission is recorded
- [ ] Hints appear on return visits
- [ ] Hints can be dismissed
- [ ] Hints auto-dismiss after timeout
- [ ] Site list shows all tracked sites
- [ ] Search filters sites correctly
- [ ] Edit site changes are saved
- [ ] Ignore site prevents hints
- [ ] Delete site removes entry
- [ ] Export creates JSON file
- [ ] Import restores data
- [ ] Settings changes persist

## Development Tips

### Debugging the Extension

1. Enable Safari Developer menu:
   - Safari → Settings → Advanced
   - Check "Show Develop menu in menu bar"

2. Inspect extension:
   - Develop → Web Extension Background Pages → WhichLogin
   - View console logs and errors

3. Inspect content script:
   - Right-click on any page → Inspect Element
   - Console will show content script logs

### Viewing Stored Data

```bash
# View preferences file (encrypted)
cat ~/Library/Application\ Support/WhichLogin/site_preferences.json

# View settings file (plain JSON)
cat ~/Library/Application\ Support/WhichLogin/settings.json
```

### Resetting All Data

```bash
# Remove all stored data
rm -rf ~/Library/Application\ Support/WhichLogin/

# Remove encryption key from Keychain
security delete-generic-password -l "WhichLoginEncryptionKey"
```

## Next Steps

1. **Test thoroughly** with the mock pages
2. **Try real websites** (without actually logging in)
3. **Customize settings** to your preference
4. **Report issues** on GitHub if you find bugs
5. **Contribute** improvements via pull requests

## Known Limitations (MVP)

- macOS only (no iOS/iPadOS)
- Safari only (no Chrome/Firefox)
- No cloud sync (local storage only)
- No password manager integration
- Heuristic-based detection (may miss some custom login forms)

## Support

- GitHub Issues: <https://github.com/Virgelsnake/WhichLogin/issues>
- Documentation: See README.md and PRIVACY.md
