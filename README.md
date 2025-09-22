# POC Semantic Release

A comprehensive proof-of-concept implementation of semantic-release with a sophisticated branching strategy and GitHub Actions CI/CD pipeline.

## 🚀 Features

- **Automated Semantic Versioning**: Automatic version management based on commit messages
- **Custom Branching Strategy**: Support for feature, release, hotfix, and fix branches
- **GitHub Actions Integration**: Fully automated CI/CD pipeline
- **Release Candidates**: Automatic RC builds for release branches
- **Branch Protection**: Enforcement of merge rules and naming conventions
- **Express Demo App**: Simple API demonstrating version management

## 📋 Table of Contents

- [Installation](#installation)
- [Branching Strategy](#branching-strategy)
- [Version Management](#version-management)
- [Commit Convention](#commit-convention)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Usage Examples](#usage-examples)
- [API Endpoints](#api-endpoints)
- [Scripts](#scripts)
- [Configuration](#configuration)

## 🛠️ Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/poc-semrel.git
cd poc-semrel

# Install dependencies
npm install

# Start the demo application
npm start
```

## 🌳 Branching Strategy

### Protected Branches

#### `main` (Production)
- **Direct pushes**: Disabled
- **Allowed merges**: `release/*`, `hotfix/*`, `fix/*` (with approval)
- **Version**: Always reflects current production version
- **Protection**: Required PR reviews, passing status checks

#### `dev` (Integration)
- **Direct pushes**: Disabled
- **Allowed merges**: `feature/*`, `fix/*`, `refact/*`
- **Purpose**: Integration testing before release
- **Version**: Pre-release versions with `dev` tag

### Working Branches

#### `feature/*` - New Features
```bash
# Create feature branch
git checkout -b feature/ticket-id-description

# Merge to dev (always)
git checkout dev
git merge feature/ticket-id-description

# Cherry-pick to release (if needed)
git checkout release/091025-payments
git cherry-pick <commit-hash>
```

#### `release/DDMMYY[-n]-description` - Release Preparation
```bash
# Create release branch
git checkout -b release/091025-payments

# Prepare release
npm run prepare-release 2.1.0 "Payment features"

# Creates release.json with version info
# RC tags are automatically generated on push
```

#### `hotfix/*` - Emergency Fixes
```bash
# Create from main
git checkout main
git checkout -b hotfix/ticket-critical-bug

# Merge directly to main
git checkout main
git merge hotfix/ticket-critical-bug

# Backport to dev and active releases
git checkout dev
git merge hotfix/ticket-critical-bug
```

#### `fix/*` - Bug Fixes
```bash
# Create fix branch
git checkout -b fix/ticket-id-bug-description

# Merge based on urgency:
# - To dev (standard)
# - To release/* (for inclusion in release)
# - To main (urgent fixes)
```

#### `refact/*` - Code Refactoring
```bash
# Create refactor branch
git checkout -b refact/auth-module-cleanup

# Merge to dev (standard)
git checkout dev
git merge refact/auth-module-cleanup
```

## 📊 Version Management

### Semantic Versioning Rules

| Version Part | When to Bump | Example |
|-------------|--------------|---------|
| MAJOR (X.0.0) | Breaking API changes | 1.0.0 → 2.0.0 |
| MINOR (x.Y.0) | New features (backward-compatible) | 1.0.0 → 1.1.0 |
| PATCH (x.y.Z) | Bug fixes, minor improvements | 1.0.0 → 1.0.1 |

### Version Determination

| Merge Scenario | Version Bump | Determined By |
|----------------|--------------|---------------|
| `release/*` → `main` | As defined in release.json | Release manager |
| `hotfix/*` → `main` | Patch (+0.0.1) | Automatic |
| `fix/*` → `main` | Patch (+0.0.1) | Automatic |
| `feature/*` → `main` | Based on commits | Commit analyzer |

### Release.json Structure

```json
{
  "version": "2.1.0",
  "releaseDate": "2025-09-10",
  "rcBuildCounter": 3,
  "lastRCTag": "v2.1.0-rc-091025.1726345678",
  "description": "Payment features release"
}
```

## 📝 Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Commit Types

| Type | Description | Version Bump |
|------|-------------|--------------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | PATCH |
| `style` | Code style (formatting) | PATCH |
| `refactor` | Code refactoring | PATCH |
| `perf` | Performance improvement | PATCH |
| `test` | Adding tests | PATCH |
| `build` | Build system changes | PATCH |
| `ci` | CI/CD changes | PATCH |
| `chore` | Other changes | PATCH |
| `revert` | Revert previous commit | PATCH |

### Breaking Changes

Add `BREAKING CHANGE:` in commit body or `!` after type:

```bash
feat!: remove deprecated API endpoints

BREAKING CHANGE: The /api/v1/* endpoints have been removed.
Use /api/v2/* instead.
```

### Examples

```bash
# Feature
feat(auth): add OAuth2 login support

# Bug fix
fix(api): resolve memory leak in user service

# Breaking change
feat(api)!: change response format for /users endpoint

# With scope
docs(readme): update installation instructions

# Multi-line with breaking change
feat(payments): add Stripe integration

Implements Stripe payment processing for subscriptions.
Includes webhook handling and error recovery.

BREAKING CHANGE: Payment API now requires API version header
```

## 🔄 GitHub Actions Workflows

### Release Workflow (`.github/workflows/release.yml`)

Triggers on:
- Push to `main`, `dev`, `release/*`, `hotfix/*`
- Merged PRs to `main`

Features:
- Branch validation
- Semantic version determination
- Automated releases with changelog
- RC tag generation for release branches
- GitHub release creation

### Branch Protection Workflow (`.github/workflows/branch-protection.yml`)

Enforces:
- Branch naming conventions
- Merge rules (which branches can merge where)
- Commit message format
- Release.json validation for release branches

## 💻 Usage Examples

### Creating a New Feature

```bash
# 1. Create feature branch
git checkout -b feature/user-authentication

# 2. Make changes and commit
git add .
git commit -m "feat(auth): implement JWT authentication"

# 3. Push and create PR to dev
git push -u origin feature/user-authentication
# Create PR via GitHub UI → dev branch

# 4. After dev testing, cherry-pick to release if needed
git checkout release/091025-auth
git cherry-pick <commit-hash>
```

### Preparing a Release

```bash
# 1. Create release branch
git checkout main
git checkout -b release/091025-v2-features

# 2. Prepare release (creates release.json)
npm run prepare-release 2.0.0 "Major feature update"

# 3. Push branch (triggers RC builds)
git push -u origin release/091025-v2-features

# 4. Each push creates RC tags: v2.0.0-rc-091025.1726345678

# 5. Create PR to main when ready
# After merge, v2.0.0 is automatically released
```

### Emergency Hotfix

```bash
# 1. Create hotfix from main
git checkout main
git checkout -b hotfix/fix-123-critical-security

# 2. Fix and commit
git add .
git commit -m "fix: patch critical security vulnerability"

# 3. Push and create PR to main
git push -u origin hotfix/fix-123-critical-security
# Merge to main triggers patch release (e.g., 1.0.0 → 1.0.1)

# 4. Backport to dev and active releases
git checkout dev
git merge hotfix/fix-123-critical-security
```

## 🌐 API Endpoints

The demo Express application provides these endpoints:

### Core Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Welcome message with version |
| `/health` | GET | Health check with uptime |
| `/version` | GET | Detailed version information |
| `/api/features` | GET | Feature flags based on version |

### User API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/users` | GET | List sample users |
| `/api/users` | POST | Create new user |

### Example Responses

```bash
# Get version info
curl http://localhost:3000/version

{
  "version": "1.0.0",
  "major": "1",
  "minor": "0",
  "patch": "0",
  "build": "local",
  "branch": "main",
  "timestamp": "2025-09-22T10:00:00Z"
}

# Check feature flags
curl http://localhost:3000/api/features

{
  "features": {
    "newDashboard": false,      # Available in v2+
    "advancedAnalytics": false, # Available in v2.1+
    "betaFeatures": false,      # Available in RC/beta
    "experimentalApi": false    # Available in dev/feature
  },
  "version": "1.0.0"
}
```

## 📜 Scripts

### Package.json Scripts

```bash
# Start the application
npm start

# Run semantic-release (CI/CD)
npm run semantic-release

# Dry-run semantic-release (testing)
npm run semantic-release:dry-run

# Prepare a release (creates release.json)
npm run prepare-release <version> [description]

# Validate current branch
npm run validate-branch

# Run tests
npm test
```

### Helper Scripts

#### prepare-release.js
- Creates `release.json` with version info
- Must be run from a release branch
- Commits the file automatically

#### validate-branch.js
- Checks branch naming convention
- Shows merge rules for current branch
- Warns about uncommitted changes

## ⚙️ Configuration

### .releaserc.json

Configures semantic-release with:
- Custom branch configurations
- Release rules for commit types
- Plugins for changelog, npm, git, and GitHub
- Pre-release channels (dev, rc, hotfix, feature)

### Environment Variables

```bash
# Application
PORT=3000
NODE_ENV=production

# CI/CD (set by GitHub Actions)
GITHUB_TOKEN=<token>
NPM_TOKEN=<token>
BUILD_NUMBER=<number>
COMMIT_SHA=<sha>
BRANCH_NAME=<branch>
```

### GitHub Secrets Required

Set these in your repository settings:

- `GITHUB_TOKEN`: Automatically provided by GitHub Actions
- `NPM_TOKEN`: (Optional) For NPM publishing

## 🔒 Security Considerations

1. **Protected Branches**: Configure branch protection rules in GitHub
2. **PR Reviews**: Require reviews for main branch merges
3. **Status Checks**: Ensure CI passes before merge
4. **Secrets**: Never commit sensitive data or tokens
5. **Dependencies**: Regular updates with `npm audit`

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request to `dev` branch

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Semantic Release](https://github.com/semantic-release/semantic-release)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://github.com/features/actions)

## 📞 Support

For questions or issues:
- Create an issue in GitHub
- Check existing documentation
- Review the [semantic-release docs](https://semantic-release.gitbook.io/)

---

**Version**: 1.0.0 | **Last Updated**: September 2025# poc-semrel
