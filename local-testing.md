# Local Testing Guide for Semantic Release

Complete guide for testing semantic-release locally without GitHub Actions.

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Dry Run Testing](#dry-run-testing)
3. [Docker Testing](#docker-testing)
4. [Mock GitHub API](#mock-github-api)
5. [Local CI Testing](#local-ci-testing)
6. [Debugging Tools](#debugging-tools)

## Environment Setup

### Required Environment Variables

Create a `.env.local` file for testing:

```bash
# .env.local
GITHUB_TOKEN=ghp_your_personal_access_token
NPM_TOKEN=npm_your_npm_token  # Optional
CI=true  # Simulate CI environment
GITHUB_REPOSITORY=username/repo-name
GITHUB_REF=refs/heads/main
GITHUB_SHA=abc123def456
GITHUB_ACTOR=your-username
```

### Load Environment for Testing

```bash
# Load environment variables
export $(cat .env.local | xargs)

# Or use direnv
echo "dotenv .env.local" > .envrc
direnv allow
```

## Dry Run Testing

### Basic Dry Run

```bash
# Test semantic-release without making changes
npm run semantic-release:dry-run

# Or directly
npx semantic-release --dry-run
```

### Test Specific Branch

```bash
# Test release from feature branch
npx semantic-release --dry-run --branch feature/test-branch

# Test release from release branch
npx semantic-release --dry-run --branch release/091025-test

# Test with custom config
npx semantic-release --dry-run --extends ./test-config/.releaserc.json
```

### Verbose Output for Debugging

```bash
# Enable debug output
DEBUG=semantic-release:* npx semantic-release --dry-run

# Specific debug categories
DEBUG=semantic-release:commit-analyzer npx semantic-release --dry-run
DEBUG=semantic-release:github npx semantic-release --dry-run

# Maximum verbosity
npx semantic-release --dry-run --debug
```

### Test Version Calculation

```bash
# See what version would be generated
npx semantic-release --dry-run | grep "next release version"

# Analyze specific commits
npx semantic-release --dry-run --from=HEAD~5 --to=HEAD
```

## Docker Testing

### Create Docker Environment

```dockerfile
# Dockerfile.test
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# Set CI environment
ENV CI=true
ENV GITHUB_REPOSITORY=test/repo
ENV GITHUB_REF=refs/heads/main

# Run semantic-release
CMD ["npx", "semantic-release", "--dry-run"]
```

### Build and Run Docker Test

```bash
# Build test image
docker build -f Dockerfile.test -t semrel-test .

# Run dry run in Docker
docker run --rm \
  -e GITHUB_TOKEN=$GITHUB_TOKEN \
  -e NPM_TOKEN=$NPM_TOKEN \
  semrel-test

# Interactive debugging
docker run --rm -it \
  -e GITHUB_TOKEN=$GITHUB_TOKEN \
  -v $(pwd):/app \
  semrel-test sh
```

### Docker Compose Setup

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  semantic-release:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - NPM_TOKEN=${NPM_TOKEN}
      - CI=true
      - DEBUG=semantic-release:*
    volumes:
      - .:/app
      - /app/node_modules
    command: npx semantic-release --dry-run
```

Run with:
```bash
docker-compose -f docker-compose.test.yml up
```

## Mock GitHub API

### Using Mock Server

```javascript
// mock-github-server.js
const express = require('express');
const app = express();

app.use(express.json());

// Mock releases endpoint
app.get('/repos/:owner/:repo/releases', (req, res) => {
  res.json([
    {
      tag_name: 'v1.0.0',
      name: 'Release v1.0.0',
      created_at: '2025-01-01T00:00:00Z'
    }
  ]);
});

// Mock create release
app.post('/repos/:owner/:repo/releases', (req, res) => {
  console.log('Would create release:', req.body);
  res.json({
    id: 1,
    tag_name: req.body.tag_name,
    name: req.body.name,
    body: req.body.body,
    html_url: `https://github.com/${req.params.owner}/${req.params.repo}/releases/tag/${req.body.tag_name}`
  });
});

// Mock tags endpoint
app.get('/repos/:owner/:repo/tags', (req, res) => {
  res.json([
    {
      name: 'v1.0.0',
      commit: { sha: 'abc123' }
    }
  ]);
});

app.listen(3001, () => {
  console.log('Mock GitHub API running on http://localhost:3001');
});
```

### Run Tests with Mock

```bash
# Start mock server
node mock-github-server.js &

# Configure semantic-release to use mock
GITHUB_API_URL=http://localhost:3001 \
GITHUB_TOKEN=mock-token \
npx semantic-release --dry-run

# Stop mock server
kill %1
```

## Local CI Testing

### Using Act (GitHub Actions Local)

```bash
# Install act
brew install act  # macOS
# Or: curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# List available workflows
act -l

# Run release workflow locally
act push -j release

# Run with secrets
act push -j release -s GITHUB_TOKEN=$GITHUB_TOKEN

# Run specific event
act pull_request -j validate-pr

# Debug mode
act push -j release --verbose
```

### Create Test Workflow

```yaml
# .github/workflows/test-local.yml
name: Test Local

on:
  workflow_dispatch:

jobs:
  test-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx semantic-release --dry-run
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Debugging Tools

### 1. Commit Analysis

```bash
# Test commit analyzer
cat << EOF | npx @semantic-release/commit-analyzer
feat: new feature
fix: bug fix
BREAKING CHANGE: major change
EOF

# Analyze local commits
git log --format=%B -n 10 | npx @semantic-release/commit-analyzer
```

### 2. Test Release Notes Generation

```bash
# Generate release notes for commits
npx @semantic-release/release-notes-generator \
  --commits '[{"message": "feat: add feature"}, {"message": "fix: fix bug"}]'
```

### 3. Configuration Validation

```javascript
// validate-config.js
const config = require('./.releaserc.json');

console.log('Branches:', config.branches);
console.log('Plugins:', config.plugins.map(p =>
  Array.isArray(p) ? p[0] : p
));

// Validate branch patterns
const testBranches = [
  'main',
  'dev',
  'release/091025-test',
  'hotfix/fix-123',
  'feature/new-feature'
];

testBranches.forEach(branch => {
  const matches = config.branches.some(b => {
    if (typeof b === 'string') return b === branch;
    if (b.name.includes('*')) {
      const pattern = b.name.replace('*', '.*');
      return new RegExp(pattern).test(branch);
    }
    return b.name === branch;
  });
  console.log(`${branch}: ${matches ? '✓' : '✗'}`);
});
```

### 4. Local Git Testing

```bash
# Create test repository
mkdir test-repo && cd test-repo
git init
git remote add origin https://github.com/test/repo.git

# Add test commits
echo "test" > file.txt
git add file.txt
git commit -m "feat: initial commit"

echo "fix" >> file.txt
git add file.txt
git commit -m "fix: resolve issue"

# Test semantic-release
npx semantic-release --dry-run --no-ci
```

### 5. Script Testing

```bash
# Test branch validation
./scripts/validate-branch.js

# Test release preparation
npm run prepare-release 2.0.0 "Test release" -- --dry-run

# Test with different branches
git checkout -b feature/test
./scripts/validate-branch.js

git checkout -b release/091025-test
npm run prepare-release 3.0.0 "Test"
```

## Testing Scenarios

### Test Patch Release

```bash
# Create test commit
git add .
git commit -m "fix: test patch release"

# Dry run
npx semantic-release --dry-run

# Should show: The next release version is 1.0.1
```

### Test Minor Release

```bash
# Create feature commit
git add .
git commit -m "feat: test minor release"

# Dry run
npx semantic-release --dry-run

# Should show: The next release version is 1.1.0
```

### Test Major Release

```bash
# Create breaking change
git add .
git commit -m "feat!: test major release

BREAKING CHANGE: This is a breaking change"

# Dry run
npx semantic-release --dry-run

# Should show: The next release version is 2.0.0
```

### Test Pre-release

```bash
# Switch to dev branch
git checkout dev

# Test pre-release
npx semantic-release --dry-run --branch dev

# Should show: The next release version is 1.1.0-dev.1
```

### Test Custom Version

```bash
# Create release.json
echo '{"version": "5.0.0"}' > release.json

# Test with custom version
npx semantic-release --dry-run

# Should detect and use version from release.json
```

## Troubleshooting Local Tests

### Common Issues

#### No releases created
```bash
# Check if commits follow convention
git log --oneline | head -10

# Verify commit format
npx commitlint --from HEAD~1

# Check branch configuration
cat .releaserc.json | jq '.branches'
```

#### Authentication errors
```bash
# Verify token
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user

# Check token permissions
gh auth status
```

#### Wrong version calculated
```bash
# Check commit types
git log --format=%s | head -10

# Test commit analyzer
echo "your commit message" | npx commitlint
```

#### CI environment issues
```bash
# Force CI mode
CI=true npx semantic-release --dry-run

# Disable CI check
npx semantic-release --dry-run --no-ci
```

## Testing Checklist

### Before Testing
- [ ] Install all dependencies: `npm ci`
- [ ] Set up environment variables
- [ ] Configure Git: `git config user.name` and `user.email`
- [ ] Create test branches if needed

### During Testing
- [ ] Test dry run on main branch
- [ ] Test dry run on feature branch
- [ ] Test dry run on release branch
- [ ] Test with debug output
- [ ] Test commit analysis
- [ ] Test version calculation
- [ ] Test with custom configuration

### After Testing
- [ ] Clean up test branches
- [ ] Remove test commits if needed
- [ ] Clear test artifacts
- [ ] Document any issues found

## Quick Commands

```bash
# Quick dry run
npx semantic-release --dry-run

# Dry run with debug
DEBUG=semantic-release:* npx semantic-release --dry-run

# Test specific branch
npx semantic-release --dry-run --branch test-branch

# Test without CI
npx semantic-release --dry-run --no-ci

# Test with custom config
npx semantic-release --dry-run --extends ./custom-config.json

# Full debug output
npx semantic-release --dry-run --debug 2>&1 | tee debug.log
```

## Resources

- [Semantic Release CLI Options](https://semantic-release.gitbook.io/semantic-release/usage/cli)
- [Debugging Guide](https://semantic-release.gitbook.io/semantic-release/support/troubleshooting)
- [Environment Variables](https://semantic-release.gitbook.io/semantic-release/usage/ci-configuration)

---

Last Updated: September 2025