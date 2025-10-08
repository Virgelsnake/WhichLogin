# Test Pages

Mock login pages for testing WhichLogin extension functionality.

## Pages

1. **login-multi-sso.html** - Login page with multiple SSO options (Apple, Google, Microsoft, GitHub, Facebook, LinkedIn) plus email/password
2. **login-email-only.html** - Simple email/password only login page

## Usage

### Local Testing

1. Start a local web server:
```bash
cd TestPages
python3 -m http.server 8000
```

2. Open Safari and navigate to:
   - http://localhost:8000/login-multi-sso.html
   - http://localhost:8000/login-email-only.html

3. Test the extension:
   - Click different SSO buttons to test detection
   - Submit the email/password form
   - Revisit the page to see the hint

### What to Test

- [ ] SSO button detection (Apple, Google, Microsoft, GitHub, Facebook, LinkedIn)
- [ ] Email/password form detection
- [ ] Login method recording
- [ ] Hint display on return visit
- [ ] Hint dismissal
- [ ] Hint timeout
- [ ] Different hint positions (via settings)
- [ ] Ignore site functionality

## Notes

These are simplified mock pages. Real-world login pages may have:
- More complex DOM structures
- Dynamic content loading
- iframes
- Shadow DOM
- Custom authentication flows

Test with real sites after basic functionality is verified.
