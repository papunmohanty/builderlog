# Firebase Setup Guide

## Local Development

1. Copy the example config file:
   ```bash
   cp config/_default/params.local.toml.example config/_default/params.local.toml
   ```

2. Fill in your Firebase credentials in `config/_default/params.local.toml`

3. The `params.local.toml` file is ignored by git and won't be committed

## Production Deployment (GitHub Pages)

For GitHub Actions deployment, you have two options:

### Option 1: Using GitHub Secrets (Recommended)

1. Go to your GitHub repository Settings → Secrets and variables → Actions
2. Add these secrets:
   - `FIREBASE_API_KEY`
   - `FIREBASE_AUTH_DOMAIN`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_STORAGE_BUCKET`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_APP_ID`

3. Update your GitHub Actions workflow to use these secrets

### Option 2: Create production config (Not recommended for public repos)

Create `config/production/params.toml` with your production Firebase config.
This file should also be added to `.gitignore` if it contains secrets.

## Security Notes

⚠️ **NEVER commit these files to git:**
- `config/_default/params.local.toml`
- `config/production/params.toml` (if it contains secrets)

✅ **Safe to commit:**
- `config/_default/params.toml` (with placeholder values)
- `config/_default/params.local.toml.example` (template only)

## Firebase Security

Note: Firebase client-side API keys are meant to be public to some extent, but you should:

1. **Enable App Check** in Firebase Console to prevent unauthorized usage
2. **Set up Firebase Security Rules** to protect your data
3. **Restrict API key usage** in Google Cloud Console:
   - Go to Google Cloud Console
   - Navigate to APIs & Services → Credentials
   - Edit your API key
   - Add restrictions (HTTP referrers for web apps)

## Hugo Config Priority

Hugo loads config files in this order (later files override earlier ones):
1. `config/_default/params.toml`
2. `config/_default/params.local.toml` (local development)
3. `config/production/params.toml` (production build)

This allows you to keep secrets separate from your main config.