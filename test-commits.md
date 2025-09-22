# Test Commit Messages

Sample commit messages for testing semantic-release version bumps.

## Valid Conventional Commits

### Features (Minor Version Bump: 1.0.0 → 1.1.0)

```bash
# Simple feature
git commit -m "feat: add user authentication"

# With scope
git commit -m "feat(auth): implement JWT token validation"

# With description
git commit -m "feat(api): add pagination to user endpoints

Implements cursor-based pagination for better performance
with large datasets"

# With issue reference
git commit -m "feat(payment): integrate Stripe payment gateway

Closes #123"

# Multiple features in one commit
git commit -m "feat(ui): add dashboard and analytics pages

- Implement real-time dashboard
- Add analytics charts
- Create export functionality

Resolves #100, #101"
```

### Bug Fixes (Patch Version Bump: 1.0.0 → 1.0.1)

```bash
# Simple fix
git commit -m "fix: resolve memory leak issue"

# With scope
git commit -m "fix(api): correct validation error in user endpoint"

# With detailed description
git commit -m "fix(database): resolve connection pool exhaustion

The connection pool was not properly releasing connections
after query timeout. This fix ensures all connections are
returned to the pool.

Fixes #456"

# Security fix
git commit -m "fix(security): patch XSS vulnerability in input handling

CVE-2024-12345"
```

### Breaking Changes (Major Version Bump: 1.0.0 → 2.0.0)

```bash
# Using exclamation mark
git commit -m "feat!: redesign API response format"

# With scope and exclamation
git commit -m "feat(api)!: change authentication from basic to OAuth2"

# Using BREAKING CHANGE footer
git commit -m "feat: implement new plugin system

BREAKING CHANGE: Plugin API has been completely redesigned.
Old plugins will not work with this version."

# Multiple breaking changes
git commit -m "refactor(core)!: complete architecture overhaul

BREAKING CHANGE: Multiple breaking changes in this release:
- API endpoints have been restructured
- Configuration format has changed
- Database schema requires migration
- Removed deprecated methods"

# With migration instructions
git commit -m "feat(api)!: update to REST API v3

BREAKING CHANGE: API v1 and v2 endpoints have been removed.

Migration guide:
1. Update all endpoint URLs from /api/v2/* to /api/v3/*
2. Update response parsing for new format
3. Regenerate API keys with new permissions model

See docs/migration-v3.md for details"
```

### Documentation (Patch Version Bump)

```bash
# Simple docs update
git commit -m "docs: update installation instructions"

# API documentation
git commit -m "docs(api): add examples for all endpoints"

# With details
git commit -m "docs: improve contribution guidelines

- Add code style guide
- Include PR template
- Update testing requirements"
```

### Performance Improvements (Patch Version Bump)

```bash
# Simple performance fix
git commit -m "perf: optimize database queries"

# With metrics
git commit -m "perf(api): reduce response time by 40%

Implemented caching layer for frequently accessed data"

# Algorithm optimization
git commit -m "perf(search): implement more efficient search algorithm

Replaces O(n²) algorithm with O(n log n) implementation"
```

### Code Refactoring (Patch Version Bump)

```bash
# Simple refactor
git commit -m "refactor: simplify authentication logic"

# Module refactor
git commit -m "refactor(utils): reorganize utility functions"

# With details
git commit -m "refactor(database): extract data access layer

Separates business logic from database operations
for better testability and maintainability"
```

### Style Changes (Patch Version Bump)

```bash
# Formatting
git commit -m "style: apply prettier formatting"

# Code style
git commit -m "style: fix eslint warnings"

# With scope
git commit -m "style(components): update to new naming convention"
```

### Tests (Patch Version Bump)

```bash
# Add tests
git commit -m "test: add unit tests for user service"

# Integration tests
git commit -m "test(api): add integration tests for auth endpoints"

# Test coverage
git commit -m "test: increase coverage to 85%

Added tests for:
- Error handling scenarios
- Edge cases in data validation
- Async operation timeouts"
```

### Build System (Patch Version Bump)

```bash
# Dependency update
git commit -m "build: update dependencies to latest versions"

# Build configuration
git commit -m "build(webpack): optimize bundle size"

# CI/CD
git commit -m "ci: add automated security scanning"
```

### Chores (Patch Version Bump)

```bash
# Maintenance
git commit -m "chore: update license year"

# Configuration
git commit -m "chore(config): update environment variables"

# Dependencies
git commit -m "chore(deps): bump axios from 0.21.1 to 0.21.2"
```

### Reverts (Patch Version Bump)

```bash
# Revert a commit
git commit -m "revert: undo changes from commit abc123

This reverts commit abc123def456789
Reason: Caused performance regression in production"
```

## Multi-line Commit Messages

### Complex Feature
```bash
git commit -m "feat(shopping-cart): implement complete shopping cart system

This commit introduces a full-featured shopping cart:

Features:
- Add/remove items
- Update quantities
- Apply discount codes
- Calculate taxes
- Save cart state

Technical details:
- Uses Redux for state management
- Persists to localStorage
- Server-side validation
- Real-time price updates

API endpoints added:
- POST /api/cart/add
- DELETE /api/cart/remove
- PUT /api/cart/update
- POST /api/cart/discount

Closes #200, #201, #202"
```

### Complex Breaking Change
```bash
git commit -m "feat(auth)!: migrate from session-based to JWT authentication

This commit completely overhauls the authentication system.

Changes:
- Remove session-based auth
- Implement JWT tokens
- Add refresh token mechanism
- Update all protected routes

BREAKING CHANGE: Session-based authentication is no longer supported.
All API clients must be updated to use JWT tokens.

Migration steps:
1. Update client to store JWT instead of session cookie
2. Include Authorization header in all requests
3. Implement token refresh logic
4. Update error handling for 401 responses

The old /api/login endpoint is deprecated and will be removed in v3.0.0.
Use /api/auth/token instead.

Security improvements:
- Tokens expire after 15 minutes
- Refresh tokens expire after 7 days
- Implements rate limiting on auth endpoints

Fixes #150, #151
Closes #175"
```

## Invalid Commit Messages (Will Not Trigger Release)

```bash
# No conventional commit type
git commit -m "updated readme"
git commit -m "small fix"
git commit -m "changes"
git commit -m "WIP"

# Wrong format
git commit -m "Fixed: user bug"  # Should be "fix: user bug"
git commit -m "FEAT - new feature"  # Should be "feat: new feature"
git commit -m "[feat] add feature"  # Should be "feat: add feature"

# Missing colon
git commit -m "feat add new feature"
git commit -m "fix resolved bug"

# Capital letters (should be lowercase)
git commit -m "FEAT: add feature"
git commit -m "Fix: resolve issue"
```

## Commit Message Tips

### DO ✅
- Use present tense ("add" not "added")
- Use imperative mood ("fix" not "fixes")
- Keep first line under 72 characters
- Add body for complex changes
- Reference issues when applicable
- Include BREAKING CHANGE when needed
- Be specific and descriptive

### DON'T ❌
- Use past tense ("added feature")
- Be vague ("fix stuff", "update code")
- Mix multiple changes in one commit
- Forget conventional commit format
- Use uppercase for type (FEAT, FIX)
- Include sensitive information
- Make commits too large

## Testing Commit Messages

### Test what version will be released
```bash
# Check commit format
npx commitlint --from HEAD~1 --to HEAD

# Dry run to see version
npx semantic-release --dry-run

# Test specific commit message
echo "feat: test feature" | npx commitlint
```

### Amend last commit message
```bash
# Fix the last commit message
git commit --amend -m "fix: correct commit message format"

# Add to last commit
git add forgotten-file.js
git commit --amend --no-edit
```

### Interactive rebase to fix old commits
```bash
# Fix last 3 commits
git rebase -i HEAD~3
# Change 'pick' to 'reword' for commits to fix
# Save and update commit messages
```

## Quick Reference

| Type | Description | Version Change | Example |
|------|-------------|----------------|---------|
| `feat` | New feature | Minor | `feat: add login` |
| `fix` | Bug fix | Patch | `fix: resolve crash` |
| `docs` | Documentation | Patch | `docs: update API` |
| `style` | Formatting | Patch | `style: fix indent` |
| `refactor` | Code change | Patch | `refactor: simplify` |
| `perf` | Performance | Patch | `perf: optimize query` |
| `test` | Tests | Patch | `test: add unit tests` |
| `build` | Build system | Patch | `build: update webpack` |
| `ci` | CI/CD | Patch | `ci: add GitHub action` |
| `chore` | Maintenance | Patch | `chore: update deps` |
| `revert` | Revert commit | Patch | `revert: undo abc123` |

Add `!` or `BREAKING CHANGE:` for major version bumps.