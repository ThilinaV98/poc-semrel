# Semantic Release Manual Testing Guide

Complete manual testing guide for semantic-release implementation with custom branching strategy.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Testing Scenarios](#testing-scenarios)
4. [Version Verification](#version-verification)
5. [GitHub Actions Testing](#github-actions-testing)
6. [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

### Required Tools
```bash
# Check Git version (>= 2.0)
git --version

# Check Node.js (>= 18.0)
node --version

# Check npm (>= 9.0)
npm --version

# GitHub CLI (optional but recommended)
gh --version
```

### GitHub Setup
1. Create a new GitHub repository
2. Set up repository secrets:
   - `GITHUB_TOKEN` (automatically provided)
   - `NPM_TOKEN` (optional, for NPM publishing)

### Local Environment Setup
```bash
# Clone the repository
git clone git@github.com:ThilinaV98/poc-semrel.git
cd poc-semrel

# Install dependencies
npm install

# Configure Git
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

## ✔️ Pre-Test Validation

### Environment Verification
```bash
# Verify semantic-release installation
npx semantic-release --version
# Expected: 23.1.1 or higher

# Check configuration validity
npx semantic-release --dry-run --no-ci 2>&1 | head -20
# Should show: "Running semantic-release version 23.1.1"

# Verify SSH authentication
ssh -T git@github.com
# Expected: "Hi ThilinaV98! You've successfully authenticated..."

# Check current version
node -p "require('./package.json').version"
# Current: 2.0.1

# Verify branch configuration
cat .releaserc.json | jq '.branches[].name'
# Expected: "main", "dev", "release/...", "hotfix/*", "feature/*"
```

### GitHub Token Setup
```bash
# Create Personal Access Token (if not done)
# Go to: https://github.com/settings/tokens/new
# Scopes needed:
# - repo (Full control)
# - write:packages (if publishing to GitHub Packages)

# Set token for local testing
export GITHUB_TOKEN=ghp_your_token_here

# Verify token works
gh auth status
```

## 🚀 Initial Setup

### 1. Initialize Repository
```bash
# Initialize git repository
git init
git add .
git commit -m "feat: initial semantic-release setup"

# Set up remote
git remote add origin git@github.com:ThilinaV98/poc-semrel.git
git branch -M main
git push -u origin main

# Create dev branch
git checkout -b dev
git push -u origin dev
```

### 2. Configure Branch Protection (GitHub UI)
```
Repository → Settings → Branches → Add rule

For 'main':
- Require pull request reviews: ✓
- Dismiss stale pull request approvals: ✓
- Require status checks: ✓
- Include administrators: ✓

For 'dev':
- Require pull request reviews: ✓
- Require status checks: ✓
```

## 🧪 Testing Scenarios

> **Current Version**: 2.0.1 (as per package.json)
> **Note**: Adjust expected versions based on your current version

### Scenario 1: Feature Development (Minor Version)
**Expected**: 2.0.1 → 2.1.0

```bash
# Start from main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/add-user-auth

# Make changes
echo "// Authentication module" >> src/auth.js
git add src/auth.js
git commit -m "feat(auth): add JWT authentication system

- Implement JWT token generation
- Add user authentication middleware
- Create auth endpoints"

# Push and create PR to dev
git push -u origin feature/add-user-auth

# Via GitHub UI: Create PR to 'dev' branch
# After review and merge to dev

# Test on dev (creates pre-release)
# Should create: 1.1.0-dev.1

# Cherry-pick to release branch (if needed)
git checkout main
git checkout -b release/$(date +%d%m%y)-auth
npm run prepare-release 1.1.0 "Authentication features"
git push -u origin release/$(date +%d%m%y)-auth

# Create PR to main → Triggers v1.1.0 release
```

### Scenario 2: Hotfix (Patch Version)
**Expected**: 1.1.0 → 1.1.1

```bash
# Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/fix-001-critical-security

# Fix the issue
echo "// Security patch" >> src/security.js
git add src/security.js
git commit -m "fix(security): patch critical XSS vulnerability in user input

Closes #001"

# Push and create PR directly to main
git push -u origin hotfix/fix-001-critical-security

# Via GitHub UI: Create PR to 'main' branch
# After merge → Automatically releases v1.1.1

# Backport to dev
git checkout dev
git merge hotfix/fix-001-critical-security
git push origin dev
```

### Scenario 3: Breaking Change (Major Version)
**Expected**: 1.1.1 → 2.0.0

```bash
# Create feature with breaking change
git checkout main
git checkout -b feature/api-v2

# Make breaking changes
echo "// New API v2" >> src/api-v2.js
git add src/api-v2.js
git commit -m "feat(api)!: implement API v2 with new response format

BREAKING CHANGE: API response format has changed.
Old format: { data: [...] }
New format: { results: [...], meta: {...} }

Migration guide available in docs/migration-v2.md"

# Create release branch
git checkout main
git checkout -b release/$(date +%d%m%y)-v2-api
npm run prepare-release 2.0.0 "API v2 with breaking changes"

# Push and create PR
git push -u origin release/$(date +%d%m%y)-v2-api

# PR to main → Releases v2.0.0
```

### Scenario 4: Release with Custom Version
**Expected**: Custom version from release.json

```bash
# Create release branch
git checkout main
git checkout -b release/$(date +%d%m%y)-custom-version

# Prepare custom release
npm run prepare-release 3.5.0 "Custom feature release"

# Verify release.json
cat release.json
# Should show: "version": "3.5.0"

# Push branch
git push -u origin release/$(date +%d%m%y)-custom-version

# Each push creates RC tags:
# v3.5.0-rc-DDMMYY.timestamp

# Create PR to main
# After merge → Releases exactly v3.5.0
```

### Scenario 5: Multiple Fixes (Patch Versions)
**Expected**: Sequential patch bumps

```bash
# First fix
git checkout main
git checkout -b fix/bug-102-validation

echo "// Fix validation" >> src/validation.js
git add src/validation.js
git commit -m "fix(validation): correct email validation regex"
git push -u origin fix/bug-102-validation
# PR to main → v1.1.2

# Second fix
git checkout main
git checkout -b fix/bug-103-memory-leak

echo "// Fix memory leak" >> src/memory.js
git add src/memory.js
git commit -m "fix(memory): resolve memory leak in data processor"
git push -u origin fix/bug-103-memory-leak
# PR to main → v1.1.3
```

### Scenario 6: Pre-release Testing (Dev Channel)
**Expected**: Pre-release versions on dev branch

```bash
# Push to dev branch
git checkout dev
git pull origin dev

echo "// Experimental feature" >> src/experimental.js
git add src/experimental.js
git commit -m "feat(experimental): add experimental feature flag system"
git push origin dev

# Creates: 1.2.0-dev.1
# Next push: 1.2.0-dev.2
# And so on...
```

### Scenario 7: Release Candidate Testing
**Expected**: RC tags on release branches

```bash
# Create and push to release branch
git checkout main
git checkout -b release/$(date +%d%m%y)-rc-test

npm run prepare-release 4.0.0 "Major release candidate"
git push -u origin release/$(date +%d%m%y)-rc-test

# First push → v4.0.0-rc-DDMMYY.timestamp1
# Make changes
echo "// RC fix" >> src/rc-fix.js
git add src/rc-fix.js
git commit -m "fix: resolve issue found in RC testing"
git push

# Second push → v4.0.0-rc-DDMMYY.timestamp2
# Ready for production → PR to main → v4.0.0
```

### Scenario 8: Documentation Updates (Patch)
**Expected**: 1.0.0 → 1.0.1

```bash
git checkout main
git checkout -b fix/update-docs

# Update documentation
echo "## New Section" >> README.md
git add README.md
git commit -m "docs: improve installation instructions"
git push -u origin fix/update-docs

# PR to main → v1.0.1
```

### Scenario 9: Performance Improvements (Patch)
**Expected**: 1.0.1 → 1.0.2

```bash
git checkout main
git checkout -b fix/performance

echo "// Optimized algorithm" >> src/optimizer.js
git add src/optimizer.js
git commit -m "perf: optimize data processing algorithm

Reduces processing time by 40%"
git push -u origin fix/performance

# PR to main → v1.0.2
```

### Scenario 10: Chained Features in Release
**Expected**: Multiple features in one release

```bash
# Create release branch
git checkout main
git checkout -b release/$(date +%d%m%y)-multi-feature

# Feature 1
git checkout -b feature/payment-gateway
echo "// Payment module" >> src/payment.js
git add src/payment.js
git commit -m "feat(payment): add Stripe payment integration"
git push -u origin feature/payment-gateway

# Feature 2
git checkout release/$(date +%d%m%y)-multi-feature
git checkout -b feature/notifications
echo "// Notification service" >> src/notifications.js
git add src/notifications.js
git commit -m "feat(notifications): add email notification service"
git push -u origin feature/notifications

# Merge both features to release branch
git checkout release/$(date +%d%m%y)-multi-feature
git merge feature/payment-gateway
git merge feature/notifications

# Prepare release
npm run prepare-release 5.0.0 "Payment and notifications"
git push -u origin release/$(date +%d%m%y)-multi-feature

# PR to main → v5.0.0 with both features
```

## ✅ Version Verification

### Pre-Release Verification Commands
```bash
# Analyze commits since last release
npx semantic-release --dry-run --debug 2>&1 | grep "Analyzing commit"

# Check what would be released
npx semantic-release --dry-run --no-ci 2>&1 | grep -A 5 "next release version"

# Verify plugin loading
npx semantic-release --dry-run --no-ci 2>&1 | grep "Loaded plugin"
# Expected output:
# Loaded plugin "verifyConditions"
# Loaded plugin "analyzeCommits"
# Loaded plugin "verifyRelease"
# Loaded plugin "generateNotes"
# Loaded plugin "prepare"
# Loaded plugin "publish"
# Loaded plugin "addChannel"
# Loaded plugin "success"
# Loaded plugin "fail"
```

### Check Current Version
```bash
# From package.json
node -p "require('./package.json').version"

# From git tags
git describe --tags --abbrev=0

# All tags
git tag -l

# From running application
curl http://localhost:3000/version | jq
```

### Verify Changelog
```bash
# Check CHANGELOG.md after release
cat CHANGELOG.md

# Should contain:
# - Version number
# - Release date
# - Categorized changes
# - Commit links
```

### Verify GitHub Release
```bash
# Using GitHub CLI
gh release list

# View specific release
gh release view v1.1.0

# Via GitHub UI
# Repository → Releases
```

## 🎯 Simplified Workflow Testing

### Testing with the Simplified GitHub Actions

The workflow has been simplified to use npm scripts directly:

```yaml
# The new workflow simply runs:
- npm ci                    # Install dependencies
- npm test                 # Run tests
- npm run semantic-release # Handle all versioning
```

### Local Testing Before Push

```bash
# 1. Dry run to see what will happen
npm run semantic-release:dry-run

# 2. Check what commits will be analyzed
npx semantic-release --dry-run --debug 2>&1 | grep "Analyzing commit"

# 3. Verify next version
npx semantic-release --dry-run 2>&1 | grep "next release version"
```

### Workflow Behavior by Branch

| Branch | Trigger | Action | Result |
|--------|---------|--------|--------|
| `main` | Push/PR merge | Full release | New version tag |
| `dev` | Push | Pre-release | `x.y.z-dev.n` tag |
| `release/*` | Push | RC build | `x.y.z-rc.n` tag |
| `hotfix/*` | Push | Pre-release | `x.y.z-hotfix.n` tag |
| `feature/*` | Push | Pre-release | `x.y.z-feature.n` tag |

## 🔄 GitHub Actions Testing

### Trigger Workflow Manually
```bash
# Create test branch
git checkout -b test/workflow-trigger

# Make change
echo "test" >> test.txt
git add test.txt
git commit -m "test: trigger workflow"
git push -u origin test/workflow-trigger
```

### Monitor Workflow
```bash
# Using GitHub CLI
gh workflow view
gh run list
gh run view [run-id]

# Via GitHub UI
# Repository → Actions → Workflows
```

### Test Dry Run Locally
```bash
# Dry run (no changes)
npm run semantic-release:dry-run

# With debug output
DEBUG=semantic-release:* npm run semantic-release:dry-run

# Test specific branch
npx semantic-release --dry-run --branch feature/test
```

## 🔍 Version Bump Validation

### Commit Type → Version Bump Mapping

| Commit Type | Example | Version Change |
|-------------|---------|----------------|
| `feat` | `feat: add new feature` | Minor (1.0.0 → 1.1.0) |
| `fix` | `fix: resolve bug` | Patch (1.0.0 → 1.0.1) |
| `feat!` | `feat!: breaking change` | Major (1.0.0 → 2.0.0) |
| `docs` | `docs: update readme` | Patch (1.0.0 → 1.0.1) |
| `style` | `style: format code` | Patch (1.0.0 → 1.0.1) |
| `refactor` | `refactor: improve code` | Patch (1.0.0 → 1.0.1) |
| `perf` | `perf: optimize` | Patch (1.0.0 → 1.0.1) |
| `test` | `test: add tests` | Patch (1.0.0 → 1.0.1) |
| `build` | `build: update deps` | Patch (1.0.0 → 1.0.1) |
| `ci` | `ci: update workflow` | Patch (1.0.0 → 1.0.1) |
| `chore` | `chore: update config` | Patch (1.0.0 → 1.0.1) |

### Test Version Calculation
```bash
# Check what version would be released
npx semantic-release --dry-run | grep "next release version"

# Check commit analysis
npx semantic-release --dry-run --debug 2>&1 | grep "Analyzing commit"
```

## 🐛 Troubleshooting

### Simplified Workflow Issues

#### Workflow Not Running Semantic Release
```bash
# Error: semantic-release command not found
# Solution: Ensure semantic-release is in devDependencies
npm install --save-dev semantic-release

# Error: No configuration found
# Solution: Ensure .releaserc.json exists
ls -la .releaserc.json
```

#### GitHub Token Issues
```bash
# Error: GITHUB_TOKEN not available
# Solution: Token is auto-provided in GitHub Actions
# For local testing:
export GITHUB_TOKEN=ghp_your_token_here
```

### Common Issues & Solutions

#### 1. Authentication Failed
```bash
# Error: Authentication failed for 'https://github.com/ThilinaV98/poc-semrel.git/'
# Solution: Switch to SSH authentication
git remote set-url origin git@github.com:ThilinaV98/poc-semrel.git

# Verify SSH key is added
ssh -T git@github.com
# Expected: "Hi ThilinaV98! You've successfully authenticated"
```

#### 2. No GitHub Token
```bash
# Error: "No GitHub token specified"
# Solution: Create and set Personal Access Token

# For local testing
export GITHUB_TOKEN=ghp_your_token_here

# For CI/CD (GitHub Actions)
# Repository Settings → Secrets → Actions → New repository secret
# Name: GITHUB_TOKEN (usually auto-provided)
```

#### 3. Configuration Error
```bash
# Error: "Cannot find module './release-rules.js'"
# Solution: Configuration has been fixed, ensure using latest .releaserc.json

# Validate configuration
npx semantic-release --dry-run --no-ci 2>&1 | grep -i error

# Check for duplicate configurations
cat .releaserc.json | jq '.'
```

#### 4. Permission Denied
```bash
# Error: Permission denied to github-actions[bot]
# Solution: Check branch protection settings
# Ensure GITHUB_TOKEN has write permissions
```

#### 5. No Release Created
```bash
# Check commit messages
git log --oneline -10

# Verify commits follow convention
npx commitlint --from=HEAD~1

# Check branch configuration
npx semantic-release --dry-run --debug
```

#### 6. Wrong Version Bump
```bash
# Verify commit type
git show --format="%s" -s HEAD

# Check release rules in .releaserc.json
cat .releaserc.json | jq '.plugins[0][1].releaseRules'
```

#### 7. GitHub Actions Failing
```bash
# Check logs
gh run view --log

# Re-run failed jobs
gh run rerun [run-id]

# Debug locally
act -j release
```

## 📊 Testing Checklist

### ✅ Environment Setup
- [ ] Git version >= 2.0 (`git --version`)
- [ ] Node.js >= 18.0 (`node --version`)
- [ ] npm >= 9.0 (`npm --version`)
- [ ] GitHub CLI installed (`gh --version`)
- [ ] SSH authentication configured (`ssh -T git@github.com`)

### ✅ Repository Configuration
- [ ] Repository cloned with SSH URL
- [ ] Remote origin set to `git@github.com:ThilinaV98/poc-semrel.git`
- [ ] Main and dev branches created
- [ ] Branch protection rules configured
- [ ] GitHub Actions enabled
- [ ] Dependencies installed (`npm install`)
- [ ] Semantic-release version 23.1.1+ installed

### ✅ Authentication & Permissions
- [ ] SSH key added to GitHub account
- [ ] Personal Access Token created (if needed)
- [ ] GITHUB_TOKEN environment variable set
- [ ] Repository permissions verified
- [ ] CI/CD secrets configured

### ✅ Configuration Validation
- [ ] `.releaserc.json` valid (`npx semantic-release --dry-run --no-ci`)
- [ ] No duplicate configuration errors
- [ ] All plugins installed and loaded
- [ ] Branch configurations correct
- [ ] Repository URL matches (package.json and .releaserc.json)

### ✅ Version Bump Testing
- [ ] **Patch Release**: Test `fix:` commits (1.1.0 → 1.1.1)
- [ ] **Minor Release**: Test `feat:` commits (1.1.0 → 1.2.0)
- [ ] **Major Release**: Test breaking changes (1.1.0 → 2.0.0)
- [ ] **Custom Version**: Test with release.json
- [ ] **Pre-release**: Test on dev branch (1.2.0-dev.1)
- [ ] **RC Builds**: Test release branches (1.2.0-rc.1)

### ✅ Workflow Testing
- [ ] Feature branch → dev → release → main flow
- [ ] Hotfix → main direct flow
- [ ] Fix branch → main flow
- [ ] Multiple features in single release
- [ ] Branch validation scripts working
- [ ] Commit message validation

### ✅ CI/CD Validation
- [ ] GitHub Actions workflows trigger correctly
- [ ] Release workflow runs on main merge
- [ ] Branch protection workflow validates correctly
- [ ] RC tags generated on release branches
- [ ] Dry-run successful locally

### ✅ Output Verification
- [ ] Version incremented in package.json
- [ ] CHANGELOG.md generated/updated
- [ ] Git tags created and pushed
- [ ] GitHub release created with notes
- [ ] Commit includes [skip ci] to avoid loops
- [ ] Release notes categorized correctly

### ✅ Post-Release Validation
- [ ] Application reports correct version (`/version` endpoint)
- [ ] Feature flags update based on version
- [ ] No errors in GitHub Actions logs
- [ ] All branches synchronized correctly
- [ ] Documentation reflects current version

## 🎯 Quick Test Commands

```bash
# Quick patch release test
git checkout -b fix/quick-test
echo "fix" >> test.txt && git add test.txt
git commit -m "fix: test patch release"
git push -u origin fix/quick-test
# Create PR to main

# Quick minor release test
git checkout -b feature/quick-test
echo "feat" >> test.txt && git add test.txt
git commit -m "feat: test minor release"
git push -u origin feature/quick-test
# Create PR to dev, then release branch

# Quick major release test
git checkout -b feature/breaking-test
echo "breaking" >> test.txt && git add test.txt
git commit -m "feat!: test major release

BREAKING CHANGE: This is a breaking change"
git push -u origin feature/breaking-test
# Create release branch with v2.0.0
```

## 🚦 Test Execution Guide

### Step-by-Step Manual Test Process (Simplified Workflow)

```bash
# 1. Setup Environment
export GITHUB_TOKEN=ghp_your_token_here
cd /path/to/poc-semrel

# 2. Verify Current State
git status
git branch
node -p "require('./package.json').version"

# 3. Test Locally First
npm run semantic-release:dry-run

# 4. Create Test Commit
git checkout -b test/manual-$(date +%s)
echo "test content $(date)" > test-file.txt
git add test-file.txt
git commit -m "test: manual testing $(date)"

# 5. Test What Will Happen
npm run semantic-release:dry-run

# 6. Push to Trigger Workflow
git push -u origin test/manual-$(date +%s)

# 7. Monitor GitHub Actions
gh run list --limit 5
gh run watch  # Watch the current run

# 8. Verify Results
gh release list --limit 5
git fetch --tags
git tag -l | tail -5
```

### Simplified Workflow Commands

```bash
# All release logic is now in npm scripts:
npm run semantic-release          # Run release (CI/CD)
npm run semantic-release:dry-run  # Test locally

# The GitHub workflow just runs:
npm ci && npm test && npm run semantic-release
```

### Expected Test Results

| Test Type | Input | Expected Output | Validation |
|-----------|-------|-----------------|------------|
| Patch Release | `fix: bug fix` | 2.0.1 → 2.0.2 | Check tags |
| Minor Release | `feat: new feature` | 2.0.1 → 2.1.0 | Check CHANGELOG |
| Major Release | `feat!: breaking` | 2.0.1 → 3.0.0 | Check GitHub Release |
| Pre-release | Push to `dev` | 2.1.0-dev.1 | Check pre-release tag |
| RC Build | Push to `release/*` | 2.1.0-rc.1 | Check RC tag |
| No Release | `chore: update` | No version change | Verify no new tag |

## 📚 Additional Resources

- [Semantic Release Documentation](https://semantic-release.gitbook.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Project README](./README.md)
- [Local Testing Guide](./local-testing.md)
- [Troubleshooting Guide](./troubleshooting.md)
- [Compliance Report](./COMPLIANCE-REPORT.md)

---

Last Updated: September 2025 | Version: 3.0.0 | Status: Production-Ready with Simplified Workflow