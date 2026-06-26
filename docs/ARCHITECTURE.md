# 🏗️ Firebase Secrets Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         LOCAL DEVELOPMENT                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Developer Machine                                                  │
│  ┌──────────────────────────────────────────────────────┐          │
│  │                                                       │          │
│  │  1. Clone Repository                                 │          │
│  │     ├── config/_default/params.toml (placeholders)   │          │
│  │     ├── config/_default/params.local.toml.example    │          │
│  │     └── .gitignore (includes params.local.toml)      │          │
│  │                                                       │          │
│  │  2. Create Local Config                              │          │
│  │     cp params.local.toml.example → params.local.toml │          │
│  │                                                       │          │
│  │  3. Add Firebase Secrets                             │          │
│  │     Edit params.local.toml with actual credentials   │          │
│  │                                                       │          │
│  │  4. Run Hugo                                          │          │
│  │     hugo server                                       │          │
│  │     │                                                 │          │
│  │     ├─ Loads: params.toml                            │          │
│  │     └─ Merges: params.local.toml ✅                  │          │
│  │                                                       │          │
│  │  5. Site Running with Firebase ✅                    │          │
│  │                                                       │          │
│  └──────────────────────────────────────────────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────┐
│                      PRODUCTION DEPLOYMENT                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  GitHub Repository                                                  │
│  ┌──────────────────────────────────────────────────────┐          │
│  │  Main Branch                                          │          │
│  │  ├── config/_default/params.toml (placeholders only)  │          │
│  │  ├── .github/workflows/hugo.yaml                      │          │
│  │  └── .gitignore                                       │          │
│  │                                                       │          │
│  │  ❌ NOT in repository:                                │          │
│  │     ├── params.local.toml                             │          │
│  │     └── config/production/params.toml                 │          │
│  └──────────────────────────────────────────────────────┘          │
│                          │                                          │
│                          │ Push to main                            │
│                          ▼                                          │
│  ┌──────────────────────────────────────────────────────┐          │
│  │  GitHub Actions Workflow                              │          │
│  │                                                       │          │
│  │  Step 1: Checkout Code                                │          │
│  │  ├── Clone repository                                 │          │
│  │  └── Initialize submodules                            │          │
│  │                                                       │          │
│  │  Step 2: Create Firebase Config                      │          │
│  │  ├── Read GitHub Secrets:                             │          │
│  │  │   ├─ FIREBASE_API_KEY                              │          │
│  │  │   ├─ FIREBASE_AUTH_DOMAIN                          │          │
│  │  │   ├─ FIREBASE_PROJECT_ID                           │          │
│  │  │   ├─ FIREBASE_STORAGE_BUCKET                       │          │
│  │  │   ├─ FIREBASE_MESSAGING_SENDER_ID                  │          │
│  │  │   └─ FIREBASE_APP_ID                               │          │
│  │  │                                                     │          │
│  │  └── Create config/production/params.toml ✅          │          │
│  │      (Only exists during build, never committed)      │          │
│  │                                                       │          │
│  │  Step 3: Build Site                                   │          │
│  │  ├── hugo build --environment production              │          │
│  │  │   ├─ Loads: params.toml                            │          │
│  │  │   └─ Merges: config/production/params.toml ✅      │          │
│  │  │                                                     │          │
│  │  └── Output: ./public/ (with embedded Firebase)       │          │
│  │                                                       │          │
│  │  Step 4: Deploy to GitHub Pages                      │          │
│  │  └── Upload ./public/ → GitHub Pages ✅               │          │
│  │                                                       │          │
│  └──────────────────────────────────────────────────────┘          │
│                          │                                          │
│                          ▼                                          │
│  ┌──────────────────────────────────────────────────────┐          │
│  │  GitHub Pages (https://yourdomain.github.io)         │          │
│  │  └── Static site with Firebase configuration ✅      │          │
│  └──────────────────────────────────────────────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────┐
│                        SECRETS STORAGE                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  GitHub Secrets (Encrypted at rest)                                 │
│  ┌──────────────────────────────────────────────────────┐          │
│  │  🔐 FIREBASE_API_KEY                                  │          │
│  │  🔐 FIREBASE_AUTH_DOMAIN                              │          │
│  │  🔐 FIREBASE_PROJECT_ID                               │          │
│  │  🔐 FIREBASE_STORAGE_BUCKET                           │          │
│  │  🔐 FIREBASE_MESSAGING_SENDER_ID                      │          │
│  │  🔐 FIREBASE_APP_ID                                   │          │
│  └──────────────────────────────────────────────────────┘          │
│           │                                                         │
│           │ Only accessible during workflow runs                   │
│           ▼                                                         │
│  GitHub Actions Runner (Temporary)                                  │
│  └── Secrets injected as environment variables                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Configuration File Priority

### Local Development
```
┌─────────────────────────────────────┐
│ Hugo Configuration Loading Order    │
├─────────────────────────────────────┤
│                                     │
│  1. config/_default/params.toml     │
│     └─ Base config (placeholders)   │
│                                     │
│  2. config/_default/params.local.toml│
│     └─ Overrides with real secrets │
│                                     │
│  Result: Working Firebase config ✅ │
│                                     │
└─────────────────────────────────────┘
```

### Production Build
```
┌─────────────────────────────────────┐
│ Hugo Configuration Loading Order    │
├─────────────────────────────────────┤
│                                     │
│  1. config/_default/params.toml     │
│     └─ Base config (placeholders)   │
│                                     │
│  2. config/production/params.toml   │
│     └─ Created from GitHub Secrets  │
│                                     │
│  Result: Working Firebase config ✅ │
│                                     │
└─────────────────────────────────────┘
```

## Security Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      Security Boundaries                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ❌ NEVER COMMITTED TO GIT                                      │
│  ┌───────────────────────────────────────────────────┐         │
│  │  • config/_default/params.local.toml              │         │
│  │  • config/production/params.toml                  │         │
│  │  • Any file with actual Firebase credentials     │         │
│  └───────────────────────────────────────────────────┘         │
│                                                                 │
│  ✅ SAFE TO COMMIT                                              │
│  ┌───────────────────────────────────────────────────┐         │
│  │  • config/_default/params.toml (placeholders)     │         │
│  │  • config/_default/params.local.toml.example      │         │
│  │  • .github/workflows/hugo.yaml                    │         │
│  │  • .gitignore                                      │         │
│  │  • Documentation files                            │         │
│  └───────────────────────────────────────────────────┘         │
│                                                                 │
│  🔐 ENCRYPTED IN GITHUB                                         │
│  ┌───────────────────────────────────────────────────┐         │
│  │  • GitHub Secrets (only in Settings)              │         │
│  │  • Accessible only during workflow runs           │         │
│  │  • Never exposed in logs or artifacts             │         │
│  └───────────────────────────────────────────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
Developer                Git Repository           GitHub Actions          GitHub Pages
    │                         │                          │                      │
    │  1. Clone               │                          │                      │
    ├────────────────────────>│                          │                      │
    │                         │                          │                      │
    │  2. Create local config │                          │                      │
    │  (params.local.toml)    │                          │                      │
    │                         │                          │                      │
    │  3. hugo server         │                          │                      │
    │  (uses local config)    │                          │                      │
    │         ✅              │                          │                      │
    │                         │                          │                      │
    │  4. git push            │                          │                      │
    ├────────────────────────>│                          │                      │
    │                         │                          │                      │
    │                         │  5. Trigger workflow     │                      │
    │                         ├─────────────────────────>│                      │
    │                         │                          │                      │
    │                         │                          │  6. Read GitHub      │
    │                         │                          │     Secrets 🔐       │
    │                         │                          │                      │
    │                         │                          │  7. Create production│
    │                         │                          │     config           │
    │                         │                          │                      │
    │                         │                          │  8. Build site       │
    │                         │                          │     (hugo build)     │
    │                         │                          │         ✅           │
    │                         │                          │                      │
    │                         │                          │  9. Deploy           │
    │                         │                          ├─────────────────────>│
    │                         │                          │                      │
    │                         │                          │                      │  10. Serve site
    │                         │                          │                      │      with Firebase
    │                         │                          │                      │          ✅
    │                         │                          │                      │
```

## Security Layers

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 1: Git Repository Protection                             │
│  ├─ .gitignore prevents committing secrets                      │
│  └─ Only placeholders in committed files                        │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  Layer 2: GitHub Secrets Encryption                             │
│  ├─ Secrets encrypted at rest                                   │
│  ├─ Only accessible during workflow runs                        │
│  └─ Automatically redacted in logs                              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  Layer 3: Temporary Build Environment                           │
│  ├─ Secrets injected only during build                          │
│  ├─ Production config created temporarily                       │
│  └─ Deleted after build completes                               │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  Layer 4: Firebase Security                                     │
│  ├─ API key restrictions (HTTP referrers)                       │
│  ├─ Firebase Security Rules                                     │
│  ├─ Firebase App Check (recommended)                            │
│  └─ Authentication requirements                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Verification Process

```
Before Commit                      During Build                    After Deploy
      │                                  │                                │
      │  Run verify script               │  GitHub Actions checks         │  Monitor Firebase
      │  ├─ Check .gitignore             │  ├─ Secrets available?         │  ├─ Usage patterns
      │  ├─ Check for secrets            │  ├─ Config created?            │  ├─ Unauthorized access
      │  ├─ Check Git history            │  ├─ Build successful?          │  └─ Security alerts
      │  └─ Verify workflow config       │  └─ Deploy successful?         │
      │          ✅                       │          ✅                     │         ✅
      ▼                                  ▼                                ▼
  Safe to commit                    Site deployed                    Site secure
```