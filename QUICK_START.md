# 🚀 Quick Start: Firebase Secrets Setup

## For New Developers

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
```

### 2️⃣ Set Up Local Firebase Config
```bash
# Copy the template
cp config/development/params.toml.example config/development/params.toml

# Edit and add your Firebase credentials
nano config/development/params.toml
```

### 3️⃣ Run Hugo Locally
```bash
# Hugo automatically uses development environment
hugo server

# Or explicitly specify:
hugo server --environment development
```

✅ **Done!** Your local site should now work with Firebase.

---

## For Repository Maintainers

### Setting Up GitHub Secrets (One-time setup)

1. **Go to GitHub Repository Settings**
   ```
   https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions
   ```

2. **Click "New repository secret"**

3. **Add these 6 secrets:**

   | Secret Name | Where to Find |
   |------------|---------------|
   | `FIREBASE_API_KEY` | Firebase Console → Project Settings → Web API Key |
   | `FIREBASE_AUTH_DOMAIN` | Firebase Console → Authentication → Sign-in method |
   | `FIREBASE_PROJECT_ID` | Firebase Console → Project Settings |
   | `FIREBASE_STORAGE_BUCKET` | Firebase Console → Storage |
   | `FIREBASE_MESSAGING_SENDER_ID` | Firebase Console → Cloud Messaging |
   | `FIREBASE_APP_ID` | Firebase Console → Project Settings → Your apps |

4. **Verify Setup**
   - Push a commit to `main` branch
   - Check GitHub Actions tab
   - Verify build completes successfully

---

## 🔐 Security Checklist

- [ ] `params.local.toml` is in `.gitignore`
- [ ] All 6 GitHub Secrets are configured
- [ ] Firebase Security Rules are set up
- [ ] Firebase App Check is enabled (recommended)
- [ ] API keys are restricted in Google Cloud Console
- [ ] No secrets in Git history (check: `git log -p | grep -i firebase`)

---

## 📁 What's Committed vs. What's Not

### ✅ Committed to Git (Safe)
```
✓ config/_default/params.toml (placeholders only)
✓ config/_default/params.local.toml.example (template)
✓ .gitignore (includes params.local.toml)
✓ .github/workflows/hugo.yaml (uses GitHub Secrets)
```

### ❌ NOT Committed (Contains Secrets)
```
✗ config/_default/params.local.toml
✗ config/production/params.toml (created at build time)
```

---

## 🆘 Troubleshooting

### Firebase not working locally?
```bash
# Check if params.local.toml exists
ls -la config/_default/params.local.toml

# If not, create it from template
cp config/_default/params.local.toml.example config/_default/params.local.toml
```

### Firebase not working in production?
1. Check GitHub Secrets are set: Settings → Secrets and variables → Actions
2. Check build logs: Actions tab → Latest workflow run
3. Verify the "Create Firebase config" step succeeded

### Accidentally committed secrets?
1. **Immediately** rotate credentials in Firebase Console
2. Update GitHub Secrets with new values
3. Clean Git history (see `FIREBASE_SECRETS_GUIDE.md`)

---

## 📚 Full Documentation

For detailed information, see:
- `docs/FIREBASE_SECRETS_GUIDE.md` - Complete guide
- `FIREBASE_SETUP.md` - Setup instructions
- `.github/workflows/hugo.yaml` - Deployment workflow