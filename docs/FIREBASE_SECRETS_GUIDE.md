# 🔐 Firebase Secrets Management Guide

This guide explains how Firebase secrets are managed securely in this project for both local development and production deployment.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Local Development Setup](#local-development-setup)
3. [GitHub Actions Deployment](#github-actions-deployment)
4. [Security Best Practices](#security-best-practices)
5. [Troubleshooting](#troubleshooting)

---

## Overview

### The Problem
Firebase credentials were previously stored directly in `config/_default/params.toml`, which meant they were committed to Git and visible in the repository history.

### The Solution
- **Local Development**: Use `params.local.toml` (gitignored)
- **Production Build**: Inject secrets via GitHub Actions using GitHub Secrets
- **Git Repository**: Only store placeholder values

---

## Local Development Setup

### 1. Copy the Template

```bash
cp config/_default/params.local.toml.example config/_default/params.local.toml
```

### 2. Add Your Firebase Credentials

Edit `config/_default/params.local.toml` and add your actual Firebase credentials:

```toml
[firebase]
apiKey = "YOUR_ACTUAL_API_KEY"
authDomain = "your-project.firebaseapp.com"
projectId = "your-project-id"
storageBucket = "your-project.firebasestorage.app"
messagingSenderId = "YOUR_SENDER_ID"
appId = "YOUR_APP_ID"
```

### 3. Run Hugo Locally

```bash
hugo server
```

Hugo will automatically merge:
1. `config/_default/params.toml` (base config with placeholders)
2. `config/_default/params.local.toml` (your actual secrets)

⚠️ **Important**: `params.local.toml` is in `.gitignore` and will NEVER be committed to Git.

---

## GitHub Actions Deployment

### How It Works

1. **GitHub Secrets Store**: Your Firebase credentials are stored as encrypted secrets in GitHub
2. **Build Time Injection**: During the build process, GitHub Actions creates a temporary config file
3. **Production Build**: Hugo uses the injected secrets to build your site
4. **Deployment**: The built site (with embedded Firebase config) is deployed to GitHub Pages

### Workflow Steps

Here's what happens in `.github/workflows/hugo.yaml`:

```yaml
# Step 1: Create production config with secrets
- name: Create Firebase config
  run: |
    mkdir -p config/production
    cat > config/production/params.toml << EOF
    [firebase]
    apiKey = "${{ secrets.FIREBASE_API_KEY }}"
    authDomain = "${{ secrets.FIREBASE_AUTH_DOMAIN }}"
    # ... other secrets
    EOF

# Step 2: Build with production environment
- name: Build
  run: |
    hugo build \
      --environment production \
      --baseURL "${{ steps.pages.outputs.base_url }}/"
```

### Setting Up GitHub Secrets

1. **Navigate to Your Repository**
   - Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`

2. **Add These Secrets** (click "New repository secret" for each):

   | Secret Name | Description | Example Value |
   |------------|-------------|---------------|
   | `FIREBASE_API_KEY` | Firebase Web API Key | `AIzaSy...` |
   | `FIREBASE_AUTH_DOMAIN` | Firebase Auth Domain | `project.firebaseapp.com` |
   | `FIREBASE_PROJECT_ID` | Firebase Project ID | `my-project-id` |
   | `FIREBASE_STORAGE_BUCKET` | Firebase Storage Bucket | `project.firebasestorage.app` |
   | `FIREBASE_MESSAGING_SENDER_ID` | FCM Sender ID | `123456789` |
   | `FIREBASE_APP_ID` | Firebase App ID | `1:123:web:abc` |

3. **Verify Secrets Are Set**
   - You should see 6 secrets listed (values are hidden)

---

## Security Best Practices

### ✅ DO

1. **Use GitHub Secrets** for production credentials
2. **Add `params.local.toml` to `.gitignore`**
3. **Use Firebase Security Rules** to protect your database
4. **Enable Firebase App Check** to prevent unauthorized access
5. **Restrict API keys** in Google Cloud Console
6. **Rotate secrets** if they're ever exposed
7. **Use environment-specific configs** (development vs. production)

### ❌ DON'T

1. **Never commit** actual secrets to Git
2. **Never share** your `params.local.toml` file
3. **Never expose** GitHub Secrets in logs or error messages
4. **Don't use production secrets** in development
5. **Don't hardcode** secrets in source code

---

## Config Loading Order

Hugo loads configuration in this order (later files override earlier ones):

### Local Development
```
1. config/_default/params.toml          (base config, placeholders)
2. config/_default/params.local.toml    (your actual secrets, gitignored)
```

### Production Build (GitHub Actions)
```
1. config/_default/params.toml          (base config, placeholders)
2. config/production/params.toml        (created at build time from GitHub Secrets)
```

---

## File Structure

```
project/
├── .gitignore                                    # Ignores params.local.toml
├── config/
│   └── _default/
│       ├── params.toml                          # ✅ Committed (placeholders only)
│       ├── params.local.toml                    # ❌ Never committed (your secrets)
│       └── params.local.toml.example            # ✅ Committed (template)
├── .github/
│   └── workflows/
│       └── hugo.yaml                            # ✅ Committed (uses GitHub Secrets)
└── docs/
    └── FIREBASE_SECRETS_GUIDE.md                # ✅ This file
```

---

## Troubleshooting

### Issue: Firebase not working locally

**Solution**: Make sure you've created `params.local.toml` with your actual credentials.

```bash
cp config/_default/params.local.toml.example config/_default/params.local.toml
# Edit params.local.toml and add your Firebase credentials
```

### Issue: Firebase not working in production

**Solution**: Verify GitHub Secrets are set correctly.

1. Go to: Settings → Secrets and variables → Actions
2. Verify all 6 Firebase secrets are present
3. Re-run the GitHub Actions workflow

### Issue: Build fails with "Firebase config not found"

**Solution**: Check that the workflow creates the production config:

```yaml
- name: Create Firebase config
  run: |
    mkdir -p config/production
    cat > config/production/params.toml << EOF
    # ... config here
```

### Issue: Secrets exposed in Git history

**Solution**: You need to clean Git history and rotate secrets.

1. **Clean Git history** (use BFG Repo Cleaner or git-filter-repo)
2. **Rotate Firebase credentials** in Firebase Console
3. **Update GitHub Secrets** with new credentials

---

## Firebase Security Configuration

### 1. Enable App Check

```javascript
// In your Firebase config
import { initializeAppCheck, ReCaptchaV3Provider } from "firebase/app-check";

const appCheck = initializeAppCheck(app, {
  provider: new ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
  isTokenAutoRefreshEnabled: true
});
```

### 2. Configure Security Rules

**Firestore Example**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Restrict API Keys

1. Go to Google Cloud Console
2. Navigate to: APIs & Services → Credentials
3. Edit your API key
4. Add HTTP referrer restrictions:
   - `https://yourdomain.com/*`
   - `https://*.github.io/*` (for GitHub Pages)

---

## Additional Resources

- [Hugo Configuration](https://gohugo.io/getting-started/configuration/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firebase App Check](https://firebase.google.com/docs/app-check)

---

## Questions?

If you have questions about this setup, please:

1. Check this guide first
2. Review the example files
3. Check GitHub Actions logs for build errors
4. Verify Firebase Console settings

---

**Last Updated**: 2025
**Author**: Your Name