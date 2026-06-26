#!/bin/bash

# Script to verify Firebase secrets setup
# Run this before committing to ensure no secrets are exposed

set -e

echo "🔍 Verifying Firebase Secrets Setup..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ALL_CHECKS_PASSED=true

# Check 1: Verify .gitignore includes params.local.toml
echo "📋 Check 1: Verifying .gitignore..."
if grep -q "params.local.toml" .gitignore; then
    echo -e "${GREEN}✓${NC} params.local.toml is in .gitignore"
else
    echo -e "${RED}✗${NC} params.local.toml is NOT in .gitignore!"
    ALL_CHECKS_PASSED=false
fi
echo ""

# Check 2: Verify params.toml doesn't contain actual secrets
echo "📋 Check 2: Verifying params.toml has no secrets..."
if grep -q "YOUR_API_KEY\|YOUR_PROJECT_ID\|AIzaSy" config/_default/params.toml 2>/dev/null; then
    if grep -q "AIzaSy" config/_default/params.toml; then
        echo -e "${RED}✗${NC} params.toml contains actual API keys!"
        ALL_CHECKS_PASSED=false
    else
        echo -e "${GREEN}✓${NC} params.toml contains only placeholders"
    fi
else
    echo -e "${YELLOW}⚠${NC} Could not verify params.toml content"
fi
echo ""

# Check 3: Verify params.local.toml exists for local development
echo "📋 Check 3: Verifying local config exists..."
if [ -f "config/_default/params.local.toml" ]; then
    echo -e "${GREEN}✓${NC} params.local.toml exists for local development"
else
    echo -e "${YELLOW}⚠${NC} params.local.toml not found (needed for local development)"
    echo "   Run: cp config/_default/params.local.toml.example config/_default/params.local.toml"
fi
echo ""

# Check 4: Verify params.local.toml is not staged for commit
echo "📋 Check 4: Verifying params.local.toml is not staged..."
if git ls-files --error-unmatch config/_default/params.local.toml 2>/dev/null; then
    echo -e "${RED}✗${NC} params.local.toml is tracked by Git!"
    echo "   Run: git rm --cached config/_default/params.local.toml"
    ALL_CHECKS_PASSED=false
else
    echo -e "${GREEN}✓${NC} params.local.toml is not tracked by Git"
fi
echo ""

# Check 5: Search for exposed secrets in Git history
echo "📋 Check 5: Searching for secrets in Git history..."
if git log -p --all | grep -q "AIzaSyDlTNRAx_0ygXlIWgXIsd7ReXc7HomiH20" 2>/dev/null; then
    echo -e "${RED}✗${NC} Found exposed Firebase API key in Git history!"
    echo "   This is a CRITICAL security issue."
    echo "   1. Rotate your Firebase API key immediately"
    echo "   2. Clean Git history using BFG Repo-Cleaner or git-filter-repo"
    ALL_CHECKS_PASSED=false
else
    echo -e "${GREEN}✓${NC} No exposed secrets found in Git history"
fi
echo ""

# Check 6: Verify GitHub workflow uses secrets
echo "📋 Check 6: Verifying GitHub workflow configuration..."
if grep -q "secrets.FIREBASE_API_KEY" .github/workflows/hugo.yaml; then
    echo -e "${GREEN}✓${NC} GitHub workflow uses secrets correctly"
else
    echo -e "${RED}✗${NC} GitHub workflow doesn't use secrets!"
    ALL_CHECKS_PASSED=false
fi
echo ""

# Check 7: Verify template file exists
echo "📋 Check 7: Verifying template file exists..."
if [ -f "config/_default/params.local.toml.example" ]; then
    echo -e "${GREEN}✓${NC} Template file exists"
else
    echo -e "${YELLOW}⚠${NC} Template file missing (params.local.toml.example)"
fi
echo ""

# Final Summary
echo "═══════════════════════════════════════"
if [ "$ALL_CHECKS_PASSED" = true ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo "Your setup is secure. Safe to commit."
    exit 0
else
    echo -e "${RED}✗ Some checks failed!${NC}"
    echo "Please fix the issues above before committing."
    exit 1
fi