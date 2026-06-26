# ⚡ Action Items: Complete Firebase Secrets Setup

**Status**: Setup files created ✅  
**Next**: You need to complete these action items

---

## 🚨 CRITICAL: Do These First (10 minutes)

### 1. Add GitHub Secrets (REQUIRED for production)

**Go to**: `https://github.com/papunmohanty/builderlog/settings/secrets/actions`

Click **"New repository secret"** and add these 6 secrets:

| Secret Name | Value |
|------------|-------|
| `FIREBASE_API_KEY` | `XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` |
| `FIREBASE_AUTH_DOMAIN` | `my-hugo-blog-xxxxx.firebaseapp.com` |
| `FIREBASE_PROJECT_ID` | `my-hugo-blog-xxxxx` |
| `FIREBASE_STORAGE_BUCKET` | `my-hugo-blog-xxxxx.firebasestorage.app` |
| `FIREBASE_MESSAGING_SENDER_ID` | `1111111111111111` |
| `FIREBASE_APP_ID` | `1:1111111111111111:web:xxxxxxxxxxxxxxxxxxxxx` |

**Verify**: You should see 6 secrets listed (values will be hidden)

---

### 2. Clean Git History (IMPORTANT for security)

⚠️ **Your Firebase API key is currently in Git history!**

Run these commands:

```bash
# Navigate to your repo
cd /Users/papun.mohanty/LearnSpace/MyBlogSpace/my_blowfishblog

# Option A: Using BFG Repo-Cleaner (easiest)
brew install bfg
bfg --replace-text <(echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX===>REMOVED_SECRET') .
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Option B: Using git-filter-repo (alternative)
pip3 install git-filter-repo
git filter-repo --replace-text <(echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX===>REMOVED_SECRET') --force
```

**After cleaning**:
```bash
# Force push to remote (rewrites history)
git push origin --force --all
git push origin --force --tags
```

---

### 3. Rotate Firebase API Key (RECOMMENDED)

Since the key was exposed, create a new one:

1. **Go to**: [Firebase Console](https://console.firebase.google.com/project/my-hugo-blog-xxxxx/settings/general)
2. **Scroll to**: "Your apps" → Web app
3. **Click**: "Delete" on the old config (or note it down)
4. **Click**: "Add app" or regenerate API key
5. **Copy**: New credentials
6. **Update**:
   - GitHub Secrets (all 6)
   - `config/_default/params.local.toml` (local development)

---

## ✅ Regular Tasks (5 minutes)

### 4. Set Up Local Development

```bash
# Create local config from template
cp config/_default/params.local.toml.example config/_default/params.local.toml

# Edit and add your Firebase credentials
nano config/_default/params.local.toml
# Or use your preferred editor:
# code config/_default/params.local.toml
# vim config/_default/params.local.toml
```

**Add these values** to `params.local.toml`:
```toml
[firebase]
apiKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  # Or new key if rotated
authDomain = "my-hugo-blog-xxxxx.firebaseapp.com"
projectId = "my-hugo-blog-xxxxx"
storageBucket = "my-hugo-blog-xxxxx.firebasestorage.app"
messagingSenderId = "1111111111111111"
appId = "1:1111111111111111:web:xxxxxxxxxxxxxxxxxxxxx"  # Or new ID if rotated
```

---

### 5. Verify Setup

```bash
# Run verification script
chmod +x scripts/verify-secrets-setup.sh
./scripts/verify-secrets-setup.sh
```

**Expected output**:
```
✓ params.local.toml is in .gitignore
✓ params.toml contains only placeholders
✓ params.local.toml exists for local development
✓ params.local.toml is not tracked by Git
✓ No exposed secrets found in Git history  # After cleaning
✓ GitHub workflow uses secrets correctly
✓ Template file exists
✓ All critical checks passed!
```

---

### 6. Test Locally

```bash
# Start Hugo server
hugo server

# Open in browser
open http://localhost:1313/builderlog/

# Verify Firebase is working
# Check browser console for Firebase initialization
```

---

### 7. Commit and Push

```bash
# Check what will be committed
git status

# Should see:
# - .gitignore (modified)
# - config/_default/params.toml (modified)
# - New documentation files
# - Updated workflow file
#
# Should NOT see:
# - params.local.toml (it's gitignored)

# Stage all changes
git add .

# Commit
git commit -m "feat: implement secure Firebase secrets management

- Move Firebase secrets to GitHub Secrets for production
- Use params.local.toml for local development (gitignored)
- Update GitHub Actions workflow to inject secrets at build time
- Add comprehensive documentation and verification tools
- Clean Git history to remove exposed credentials

Security improvements:
- Secrets no longer committed to repository
- GitHub Secrets used for CI/CD
- Added verification script
- Created setup documentation

Files added:
- docs/FIREBASE_SECRETS_GUIDE.md
- docs/ARCHITECTURE.md
- FIREBASE_SETUP.md
- QUICK_START.md
- SECURITY_SUMMARY.md
- ACTION_ITEMS.md
- scripts/verify-secrets-setup.sh
- config/_default/params.local.toml.example

Files modified:
- .gitignore (added params.local.toml)
- config/_default/params.toml (removed secrets, added placeholders)
- .github/workflows/hugo.yaml (inject secrets at build time)"

# Push to GitHub
git push origin main
```

---

### 8. Verify Production Deployment

1. **Watch GitHub Actions**:
   - Go to: `https://github.com/papunmohanty/builderlog/actions`
   - Click on the latest workflow run
   - Verify all steps succeed (especially "Create Firebase config")

2. **Check Deployed Site**:
   - Visit: `https://papunmohanty.github.io/builderlog/`
   - Open browser DevTools → Console
   - Verify Firebase initializes without errors

3. **Test Firebase Features**:
   - Try any Firebase-dependent features (likes, views, etc.)
   - Check Firebase Console for activity

---

## 📋 Complete Checklist

Mark these off as you complete them:

### Critical (Must Do)
- [ ] Added all 6 GitHub Secrets
- [ ] Cleaned Git history (removed exposed API key)
- [ ] Rotated Firebase API key (recommended)
- [ ] Created `params.local.toml` from template
- [ ] Added credentials to `params.local.toml`
- [ ] Ran verification script successfully
- [ ] Committed changes
- [ ] Pushed to GitHub

### Verification (Important)
- [ ] Verified local `hugo server` works
- [ ] Verified GitHub Actions build succeeds
- [ ] Verified deployed site works
- [ ] Verified Firebase functionality works
- [ ] Checked browser console for errors
- [ ] Reviewed GitHub Actions logs

### Documentation (Good to Know)
- [ ] Read `docs/FIREBASE_SECRETS_GUIDE.md`
- [ ] Read `QUICK_START.md`
- [ ] Bookmarked `SECURITY_SUMMARY.md`
- [ ] Understand the architecture (see `docs/ARCHITECTURE.md`)

### Security (Best Practices)
- [ ] Enabled Firebase Security Rules
- [ ] Enabled Firebase App Check (recommended)
- [ ] Restricted API key in Google Cloud Console
- [ ] Set up monitoring in Firebase Console
- [ ] Documented incident (if secrets were exposed)

---

## 🆘 Troubleshooting

### Issue: Verification script fails
```bash
# Fix permissions
chmod +x scripts/verify-secrets-setup.sh

# Run again
./scripts/verify-secrets-setup.sh
```

### Issue: Local Hugo server can't find Firebase config
```bash
# Make sure params.local.toml exists
ls -la config/_default/params.local.toml

# If not, create it
cp config/_default/params.local.toml.example config/_default/params.local.toml
```

### Issue: GitHub Actions build fails
1. Check that all 6 GitHub Secrets are set
2. Check workflow logs for specific error
3. Verify secret names match exactly (case-sensitive)

### Issue: BFG or git-filter-repo not installed
```bash
# Install BFG
brew install bfg

# OR install git-filter-repo
pip3 install git-filter-repo
```

---

## 📞 Need Help?

1. **Check documentation**:
   - `docs/FIREBASE_SECRETS_GUIDE.md` - Comprehensive guide
   - `QUICK_START.md` - Quick reference
   - `docs/ARCHITECTURE.md` - System architecture

2. **Run verification**:
   ```bash
   ./scripts/verify-secrets-setup.sh
   ```

3. **Check logs**:
   - Local: Check terminal output
   - Production: Check GitHub Actions logs
   - Firebase: Check Firebase Console

---

## ⏱️ Time Estimates

- **Add GitHub Secrets**: 5 minutes
- **Clean Git history**: 5 minutes
- **Rotate Firebase key**: 10 minutes
- **Set up local config**: 2 minutes
- **Verify and commit**: 5 minutes

**Total**: ~30 minutes

---

**Current Status**: ⏳ Waiting for you to complete action items  
**Next Step**: Add GitHub Secrets (Step 1)

**Last Updated**: $(date)