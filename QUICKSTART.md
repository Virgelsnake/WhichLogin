# WhichLogin - Quick Start Guide

Get WhichLogin running in **5 minutes**! ⚡

## Step 1: Build the App (2 minutes)

```bash
# Open the project
open WhichLogin.xcodeproj

# In Xcode:
# 1. Select "WhichLogin" scheme (top left)
# 2. Press Cmd+R to build and run
```

The app will launch and appear in your menu bar (look for a key icon 🔑).

## Step 2: Enable Safari Extension (1 minute)

1. Open **Safari**
2. Go to **Safari → Settings** (or Preferences)
3. Click **Extensions** tab
4. Find **WhichLogin Extension**
5. Check the box to enable it
6. Click **Allow** when prompted for permissions

## Step 3: Test It! (2 minutes)

### Quick Test with Mock Page

```bash
# In a new terminal:
cd TestPages
python3 -m http.server 8000
```

Then in Safari:

1. Navigate to: `http://localhost:8000/login-multi-sso.html`
2. Click **"Continue with Google"** button
3. Click the menu bar icon - you should see `localhost` listed
4. **Refresh the page** (Cmd+R)
5. You should see a hint: *"You last signed in here with **Google**"* 🎉

### Test with Real Site (Optional)

1. Go to `https://github.com/login`
2. Click any SSO button (don't actually log in!)
3. Check menu bar - `github.com` should appear
4. Revisit the page to see the hint

## That's It! ✅

You're now tracking login methods and getting helpful reminders.

---

## What to Try Next

### Customize Settings

1. Click menu bar icon
2. Click gear icon (⚙️)
3. Try:
   - Change hint position
   - Adjust timeout
   - Toggle hints on/off

### Manage Sites

1. Click menu bar icon
2. Click any site to:
   - Change the recorded method
   - Mark as "Ignored"
   - View history
   - Delete

### Export Your Data

1. Settings → Export Data
2. Save JSON file
3. Import later to restore

---

## Troubleshooting

**Extension not showing in Safari?**
- Make sure the app is running (check menu bar)
- Restart Safari
- Try disabling/re-enabling in Safari Settings

**Hints not appearing?**
- Check Settings → "Show hints on login pages" is ON
- Site might be marked as "Ignored"
- Check Safari Console for errors (right-click → Inspect Element → Console)

**Nothing detected?**
- Extension needs permissions - check Safari → Settings → Extensions
- Try refreshing the page
- Some custom login forms may not be detected (heuristic-based)

---

## Need More Help?

- **Full Setup Guide**: See `SETUP.md`
- **Documentation**: See `README.md`
- **Issues**: <https://github.com/Virgelsnake/WhichLogin/issues>

---

**Enjoy never forgetting your login method again!** 🎉
