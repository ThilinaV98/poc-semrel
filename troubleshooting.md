# Troubleshooting Guide

Common issues and solutions for semantic-release implementation.

## Table of Contents

1. [Release Issues](#release-issues)
2. [GitHub Actions Issues](#github-actions-issues)
3. [Version Issues](#version-issues)
4. [Branch Issues](#branch-issues)
5. [Permission Issues](#permission-issues)
6. [Configuration Issues](#configuration-issues)
7. [Recovery Procedures](#recovery-procedures)

## Release Issues

### No Release Created

#### Symptoms
- Pipeline runs successfully but no release is created
- No new tags or GitHub releases appear

#### Diagnosis
```bash
# Check if commits follow convention
git log --oneline -10

# Verify commit messages
npx commitlint --from=HEAD~5

# Test semantic-release locally
npx semantic-release --dry-run --debug
```

#### Solutions

1. **Invalid commit messages**
```bash
# Fix last commit message
git commit --amend -m "fix: correct commit format"

# Fix multiple commits
git rebase -i HEAD~3
# Change 'pick' to 'reword' for commits to fix
```

2. **No release-worthy commits**
```bash
# Check what commits are analyzed
npx semantic-release --dry-run | grep "Analyzing commit"

# Ensure you have feat/fix commits since last release
git log --format=%s v1.0.0..HEAD | grep -E "^(feat|fix)"
```

3. **Wrong branch**
```bash
# Verify you're on a release branch
git branch --show-current

# Check branch configuration
cat .releaserc.json | jq '.branches'
```

### Release Created with Wrong Version

#### Symptoms
- Version doesn't match expected bump
- Major version when expecting minor

#### Solutions

1. **Check commit messages for breaking changes**
```bash
# Look for breaking change indicators
git log --grep="BREAKING" --oneline
git log --format=%B | grep -E "BREAKING CHANGE|!"
```

2. **Verify release rules**
```bash
# Check configuration
cat .releaserc.json | jq '.plugins[0][1].releaseRules'

# Test specific commit
echo "feat: test" | npx commitlint
```

3. **Custom version from release.json**
```bash
# Check if release.json exists
cat release.json

# Remove if not needed
git rm release.json
git commit -m "chore: remove release.json"
```

## GitHub Actions Issues

### Workflow Not Triggering

#### Symptoms
- Push to branch doesn't trigger workflow
- PR merge doesn't start release

#### Diagnosis
```bash
# Check workflow triggers
cat .github/workflows/release.yml | grep -A5 "on:"

# Verify branch name
git branch --show-current

# Check GitHub Actions status
gh workflow list
gh run list
```

#### Solutions

1. **Enable GitHub Actions**
```bash
# Via GitHub UI
# Settings → Actions → General → Actions permissions
# Select "Allow all actions"
```

2. **Fix workflow file**
```yaml
# Ensure correct trigger configuration
on:
  push:
    branches:
      - main
      - dev
      - 'release/**'
      - 'hotfix/**'
```

3. **Check branch protection**
```bash
# May prevent direct pushes
# Settings → Branches → Check rules
```

### Workflow Failing

#### Symptoms
- Red X on commit
- Error in Actions tab

#### Common Errors and Fixes

1. **Permission denied**
```yaml
# Add permissions to workflow
permissions:
  contents: write
  issues: write
  pull-requests: write
  id-token: write
```

2. **npm ci failing**
```bash
# Delete and regenerate lock file
rm package-lock.json
npm install
git add package-lock.json
git commit -m "fix: regenerate lock file"
```

3. **Semantic-release error**
```bash
# Check logs
gh run view --log | grep ERROR

# Common fix: Clear npm cache
npm cache clean --force
```

## Version Issues

### Version Conflicts

#### Symptoms
```
Error: EINVALIDNEXTVERSION
The next release version is lower than the current one
```

#### Solutions

1. **Check existing tags**
```bash
# List all tags
git tag -l | sort -V

# Delete incorrect local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
```

2. **Reset to correct version**
```bash
# Update package.json manually
npm version 2.0.0 --no-git-tag-version
git add package.json package-lock.json
git commit -m "fix: correct version to 2.0.0"
```

### Duplicate Version Tags

#### Symptoms
- Multiple tags for same version
- Conflicting releases

#### Solutions
```bash
# List duplicate tags
git tag -l | sort | uniq -d

# Delete duplicates
git tag -d v1.0.0-duplicate
git push origin --delete v1.0.0-duplicate

# Fetch clean tags
git fetch --tags --prune-tags
```

## Branch Issues

### Invalid Branch Name

#### Symptoms
```
❌ Invalid branch name: my-branch
Branch name must follow the pattern
```

#### Solutions

1. **Rename local branch**
```bash
# Rename current branch
git branch -m feature/valid-name

# Or from different branch
git branch -m old-name feature/new-name
```

2. **Update remote**
```bash
# Push with new name
git push origin -u feature/valid-name

# Delete old remote branch
git push origin --delete old-name
```

### Merge Conflicts with release.json

#### Symptoms
- Conflicts when merging release branch
- release.json has conflicts

#### Solutions
```bash
# Always take the version from release branch
git checkout --theirs release.json
git add release.json

# Or manually edit
vim release.json
# Fix conflicts
git add release.json
git commit -m "fix: resolve release.json conflicts"
```

## Permission Issues

### GITHUB_TOKEN Insufficient Permissions

#### Symptoms
```
Error: HttpError: Resource not accessible by integration
```

#### Solutions

1. **For protected branches**
```bash
# Create Personal Access Token
# GitHub → Settings → Developer settings → PAT

# Add to repository secrets
# Repository → Settings → Secrets → Actions
# Name: PERSONAL_ACCESS_TOKEN
```

2. **Update workflow**
```yaml
- uses: actions/checkout@v4
  with:
    token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
```

### NPM Publish Failing

#### Symptoms
```
npm ERR! 401 Unauthorized
```

#### Solutions

1. **Generate NPM token**
```bash
# Login to npm
npm login

# Create token
npm token create --read-only=false
```

2. **Add to GitHub secrets**
```bash
# Via GitHub UI
# Settings → Secrets → Actions → New repository secret
# Name: NPM_TOKEN
# Value: npm_xxxxxxxxxxxx
```

## Configuration Issues

### Semantic-Release Not Finding Config

#### Symptoms
```
Error: No configuration found
```

#### Solutions

1. **Check file name**
```bash
# Must be one of:
ls -la .releaserc*
# .releaserc
# .releaserc.json
# .releaserc.yaml
# .releaserc.yml
# .releaserc.js
# release.config.js
```

2. **Validate JSON**
```bash
# Check for syntax errors
cat .releaserc.json | jq '.'

# Online validator
# jsonlint.com
```

### Plugin Not Working

#### Symptoms
- Changelog not generated
- GitHub release not created

#### Solutions

1. **Check plugin installation**
```bash
# Verify installed
npm ls @semantic-release/changelog
npm ls @semantic-release/github

# Reinstall if needed
npm install --save-dev @semantic-release/changelog
```

2. **Check plugin order**
```json
{
  "plugins": [
    "@semantic-release/commit-analyzer",    // 1st
    "@semantic-release/release-notes-generator", // 2nd
    "@semantic-release/changelog",          // 3rd
    "@semantic-release/npm",               // 4th
    "@semantic-release/git",               // 5th
    "@semantic-release/github"             // 6th
  ]
}
```

## Recovery Procedures

### Rollback Failed Release

#### Steps
```bash
# 1. Identify problem release
git tag -l | grep v2.0.0

# 2. Delete tag locally
git tag -d v2.0.0

# 3. Delete tag remotely
git push origin --delete v2.0.0

# 4. Delete GitHub release
gh release delete v2.0.0 --yes

# 5. Revert commits if needed
git revert HEAD
git push

# 6. Fix and re-release
git commit -m "fix: correct the issue"
git push
```

### Fix Incorrect Version in package.json

#### Steps
```bash
# 1. Checkout main
git checkout main
git pull

# 2. Correct version
npm version 1.0.0 --no-git-tag-version

# 3. Commit
git add package.json package-lock.json
git commit -m "fix: correct version in package.json [skip ci]"

# 4. Push
git push origin main
```

### Reset Release Branch

#### When release branch is corrupted
```bash
# 1. Delete local branch
git branch -D release/091025-broken

# 2. Delete remote branch
git push origin --delete release/091025-broken

# 3. Create fresh from main
git checkout main
git pull
git checkout -b release/091025-fixed

# 4. Prepare release
npm run prepare-release 2.0.0 "Fixed release"

# 5. Push
git push -u origin release/091025-fixed
```

### Emergency Hotfix When CI/CD is Broken

#### Manual release process
```bash
# 1. Create hotfix locally
git checkout main
git checkout -b hotfix/emergency-fix
# Make fixes
git add .
git commit -m "fix: emergency fix"

# 2. Manually bump version
npm version patch

# 3. Create tag
git tag -a v1.0.1 -m "Emergency release v1.0.1"

# 4. Push everything
git push origin hotfix/emergency-fix --tags

# 5. Create release manually
gh release create v1.0.1 \
  --title "Emergency Release v1.0.1" \
  --notes "Emergency fix for critical issue"

# 6. Merge to main manually
git checkout main
git merge hotfix/emergency-fix
git push
```

## Debugging Commands

### Information Gathering
```bash
# Current version
node -p "require('./package.json').version"

# All tags
git tag -l | sort -V

# Recent commits
git log --oneline -10

# Branch status
git status
git branch -a

# Workflow runs
gh run list
gh run view [run-id] --log

# Check semantic-release config
npx semantic-release --dry-run --debug 2>&1 | less
```

### Testing Commands
```bash
# Test commit message
echo "feat: test" | npx commitlint

# Test semantic-release
npx semantic-release --dry-run

# Test with debug
DEBUG=semantic-release:* npx semantic-release --dry-run

# Test specific branch
npx semantic-release --dry-run --branch feature/test
```

### Cleanup Commands
```bash
# Clean node modules
rm -rf node_modules package-lock.json
npm install

# Clean git
git gc --prune=now
git remote prune origin

# Reset to remote
git fetch origin
git reset --hard origin/main

# Clean Docker (if using)
docker system prune -a
```

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `EINVALIDNEXTVERSION` | Version conflict | Check existing tags, clear duplicates |
| `ERELEASEBRANCH` | Wrong branch | Ensure on configured release branch |
| `HttpError: 401` | Auth failure | Check GITHUB_TOKEN permissions |
| `ENOPERMISSION` | Permissions | Update workflow permissions |
| `ENOCONFIG` | Missing config | Create .releaserc.json |
| `EPLUGINERROR` | Plugin failure | Reinstall plugins, check order |
| `ENOGITHUB` | GitHub API error | Check token, API limits |
| `ENOCOMMITS` | No commits to analyze | Ensure conventional commits exist |

## Getting Help

### Resources
- [Semantic Release Docs](https://semantic-release.gitbook.io/)
- [GitHub Actions Docs](https://docs.github.com/actions)
- [Project Issues](https://github.com/yourusername/poc-semrel/issues)

### Debug Information to Collect
When reporting issues, include:
```bash
# Version info
node --version
npm --version
npx semantic-release --version

# Config
cat .releaserc.json

# Recent commits
git log --oneline -10

# Error output
npx semantic-release --dry-run --debug 2>&1 > debug.log
```

---

Last Updated: September 2025