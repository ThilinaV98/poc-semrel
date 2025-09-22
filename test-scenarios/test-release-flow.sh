#!/bin/bash

# Test Release Branch with Custom Version Flow
# This script tests custom version releases using release.json

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Testing Release Branch with Custom Version ===${NC}"
echo "This will test custom version release via release.json"
echo ""

# Get custom version from user
read -p "Enter target version (e.g., 2.5.0): " CUSTOM_VERSION
if [[ ! $CUSTOM_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Invalid version format. Use X.Y.Z${NC}"
    exit 1
fi

read -p "Enter release description: " DESCRIPTION
DATE=$(date +%d%m%y)
RELEASE_BRANCH="release/$DATE-custom-$CUSTOM_VERSION"

# Step 1: Create release branch from main
echo -e "${YELLOW}Step 1: Creating release branch from main${NC}"
git checkout main
git pull origin main
git checkout -b $RELEASE_BRANCH

echo -e "${GREEN}✓ Created branch: $RELEASE_BRANCH${NC}"

# Step 2: Add some features to the release
echo -e "${YELLOW}Step 2: Adding features to release${NC}"

# Feature 1: API Enhancement
cat > src/api-v2.js << 'EOF'
// API Version 2 Enhancements
export const apiV2 = {
  version: '2.0',
  endpoints: {
    users: '/api/v2/users',
    products: '/api/v2/products',
    orders: '/api/v2/orders'
  },
  features: {
    pagination: true,
    filtering: true,
    sorting: true,
    caching: true
  }
};
EOF

git add src/api-v2.js
git commit -m "feat(api): add API v2 endpoints with enhanced features"

# Feature 2: Performance Improvement
cat > src/cache.js << 'EOF'
// Caching Module
export class CacheManager {
  constructor() {
    this.cache = new Map();
    this.ttl = 3600000; // 1 hour
  }

  set(key, value) {
    this.cache.set(key, {
      value,
      timestamp: Date.now()
    });
  }

  get(key) {
    const item = this.cache.get(key);
    if (!item) return null;
    
    if (Date.now() - item.timestamp > this.ttl) {
      this.cache.delete(key);
      return null;
    }
    
    return item.value;
  }
}
EOF

git add src/cache.js
git commit -m "perf(cache): implement caching system for API responses"

echo -e "${GREEN}✓ Added features to release${NC}"

# Step 3: Prepare release with custom version
echo -e "${YELLOW}Step 3: Preparing release with version $CUSTOM_VERSION${NC}"

# Use the npm script to create release.json
npm run prepare-release "$CUSTOM_VERSION" "$DESCRIPTION"

# Step 4: Display release.json
echo -e "${YELLOW}Step 4: Release configuration${NC}"
echo -e "${BLUE}release.json contents:${NC}"
cat release.json | jq '.'

# Step 5: Push release branch
echo -e "${YELLOW}Step 5: Pushing release branch${NC}"
git push -u origin $RELEASE_BRANCH

echo -e "${GREEN}✓ Release branch pushed${NC}"
echo "GitHub Actions will create RC tag: v$CUSTOM_VERSION-rc-$DATE.$(date +%s)"

# Step 6: Simulate RC testing
echo -e "${YELLOW}Step 6: Simulating RC testing${NC}"
read -p "Press enter to simulate RC testing and fixes..."

# Add a fix during RC testing
echo "// RC fix for issue #456" >> src/api-v2.js
git add src/api-v2.js
git commit -m "fix: resolve issue found during RC testing"
git push

echo -e "${GREEN}✓ RC fix applied (new RC tag will be created)${NC}"

# Step 7: Show release readiness
echo -e "${YELLOW}Step 7: Release Summary${NC}"
echo -e "${BLUE}Branch:${NC} $RELEASE_BRANCH"
echo -e "${BLUE}Version:${NC} $CUSTOM_VERSION"
echo -e "${BLUE}Description:${NC} $DESCRIPTION"
echo -e "${BLUE}Features:${NC}"
git log --oneline main..$RELEASE_BRANCH

# Step 8: Create PR command
echo -e "${YELLOW}Step 8: Creating Pull Request${NC}"
echo "To create PR via GitHub CLI:"
echo -e "${BLUE}gh pr create \\
  --base main \\
  --head $RELEASE_BRANCH \\
  --title \"Release v$CUSTOM_VERSION: $DESCRIPTION\" \\
  --body \"## Release v$CUSTOM_VERSION\n\n$DESCRIPTION\n\n### Features\n- API v2 implementation\n- Caching system\n\n### Testing\n- RC testing completed\n- All checks passing\"${NC}"

read -p "Create PR now? (requires gh CLI) (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh pr create \
      --base main \
      --head $RELEASE_BRANCH \
      --title "Release v$CUSTOM_VERSION: $DESCRIPTION" \
      --body "## Release v$CUSTOM_VERSION

$DESCRIPTION

### Features
- API v2 implementation
- Caching system

### Testing
- RC testing completed
- All checks passing"
    
    echo -e "${GREEN}✓ Pull request created${NC}"
    echo "After PR is merged to main, version $CUSTOM_VERSION will be released!"
fi

echo ""
echo -e "${GREEN}=== Release Flow Test Complete ===${NC}"
echo "Next steps:"
echo "1. Review and approve the PR"
echo "2. Merge to main"
echo "3. Version $CUSTOM_VERSION will be automatically released"
echo "4. release.json will be automatically cleaned up"
echo "5. Check GitHub Releases for v$CUSTOM_VERSION"