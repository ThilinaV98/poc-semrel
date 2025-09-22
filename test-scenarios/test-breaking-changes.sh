#!/bin/bash

# Test Breaking Changes (Major Version Bump)
# This script tests how breaking changes trigger major version bumps

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${RED}=== Testing Breaking Changes (Major Version) ===${NC}"
echo "This will test different ways to trigger major version bumps"
echo ""

CURRENT_VERSION=$(node -p "require('./package.json').version")
echo -e "${CYAN}Current version: $CURRENT_VERSION${NC}"
echo ""

# Menu for breaking change type
echo "Select type of breaking change to test:"
echo "1) Using exclamation mark (feat!:)"
echo "2) Using BREAKING CHANGE in commit body"
echo "3) Multiple breaking changes in one release"
echo "4) Breaking change with migration guide"
read -p "Enter choice (1-4): " CHOICE

DATE=$(date +%d%m%y)
BRANCH_NAME=""

case $CHOICE in
  1)
    echo -e "\n${YELLOW}Testing: Exclamation mark method${NC}"
    BRANCH_NAME="feature/api-v3-breaking"
    
    git checkout main
    git pull origin main
    git checkout -b $BRANCH_NAME
    
    # Create breaking change
    cat > src/api-v3.js << 'EOF'
// API Version 3 - Breaking Changes
export const apiV3 = {
  // BREAKING: Changed response structure
  getUserById: async (id) => {
    // Old format: { user: {...} }
    // New format: { data: {...}, meta: {...} }
    return {
      data: {
        id,
        name: 'User Name',
        email: 'user@example.com'
      },
      meta: {
        version: '3.0.0',
        timestamp: new Date().toISOString()
      }
    };
  }
};
EOF
    
    git add src/api-v3.js
    git commit -m "feat(api)!: restructure API response format

The API response structure has been completely redesigned.
All endpoints now return data in a new format.

Migration required for all API consumers."
    
    echo -e "${GREEN}✓ Breaking change committed with '!' notation${NC}"
    ;;
    
  2)
    echo -e "\n${YELLOW}Testing: BREAKING CHANGE in commit body${NC}"
    BRANCH_NAME="feature/database-migration"
    
    git checkout main
    git pull origin main
    git checkout -b $BRANCH_NAME
    
    # Create database changes
    cat > src/database-v2.js << 'EOF'
// Database Schema V2 - Breaking Changes
export const schemaV2 = {
  users: {
    // BREAKING: Renamed fields
    id: 'UUID PRIMARY KEY',
    fullName: 'VARCHAR(255)', // was: name
    emailAddress: 'VARCHAR(255)', // was: email
    createdAt: 'TIMESTAMP', // was: created
    updatedAt: 'TIMESTAMP', // was: modified
    isActive: 'BOOLEAN DEFAULT true' // new required field
  }
};
EOF
    
    git add src/database-v2.js
    git commit -m "feat(database): implement new database schema

Completely restructured database schema for better performance.

BREAKING CHANGE: Database schema has been redesigned.
All table columns have been renamed and new required fields added.
Migration script required before deployment.

Migration steps:
1. Backup existing database
2. Run migration script: npm run migrate:v2
3. Verify data integrity
4. Update all queries in application code"
    
    echo -e "${GREEN}✓ Breaking change committed with BREAKING CHANGE keyword${NC}"
    ;;
    
  3)
    echo -e "\n${YELLOW}Testing: Multiple breaking changes${NC}"
    BRANCH_NAME="feature/major-overhaul"
    
    git checkout main
    git pull origin main
    git checkout -b $BRANCH_NAME
    
    # Breaking change 1: Authentication
    cat > src/auth-v2.js << 'EOF'
// Authentication V2 - Breaking Change
export const authV2 = {
  // BREAKING: Now requires OAuth2
  authenticate: async (token) => {
    // Old: Basic auth
    // New: OAuth2 only
    return { type: 'oauth2', token };
  }
};
EOF
    
    git add src/auth-v2.js
    git commit -m "feat(auth)!: migrate to OAuth2 authentication

BREAKING CHANGE: Basic authentication is no longer supported.
All clients must use OAuth2 for authentication."
    
    # Breaking change 2: Configuration
    cat > src/config-v2.js << 'EOF'
// Configuration V2 - Breaking Change
export const configV2 = {
  // BREAKING: New config structure
  app: {
    name: process.env.APP_NAME,
    version: process.env.APP_VERSION
  },
  // Old flat structure removed
};
EOF
    
    git add src/config-v2.js
    git commit -m "refactor(config)!: restructure configuration system

BREAKING CHANGE: Configuration now uses nested structure.
Environment variables have been renamed."
    
    # Breaking change 3: API deprecation
    cat > src/deprecated.js << 'EOF'
// Removed deprecated APIs
// The following endpoints have been REMOVED:
// - /api/v1/*
// - /legacy/*
// - /old/*
EOF
    
    git add src/deprecated.js
    git commit -m "feat(api)!: remove deprecated API endpoints

BREAKING CHANGE: All v1 and legacy API endpoints have been removed.
Clients must migrate to v3 API immediately."
    
    echo -e "${GREEN}✓ Multiple breaking changes committed${NC}"
    ;;
    
  4)
    echo -e "\n${YELLOW}Testing: Breaking change with migration guide${NC}"
    BRANCH_NAME="feature/plugin-system-v2"
    
    git checkout main
    git pull origin main
    git checkout -b $BRANCH_NAME
    
    # Create plugin system changes
    cat > src/plugins-v2.js << 'EOF'
// Plugin System V2 - Complete Redesign
export class PluginSystemV2 {
  constructor() {
    this.plugins = new Map();
  }
  
  // BREAKING: New plugin interface
  register(plugin) {
    // Old: plugin.init()
    // New: plugin.setup(context)
    if (!plugin.setup || !plugin.name || !plugin.version) {
      throw new Error('Invalid plugin format');
    }
    this.plugins.set(plugin.name, plugin);
  }
}
EOF
    
    # Create migration guide
    cat > MIGRATION-V2.md << 'EOF'
# Migration Guide: v1.x to v2.0

## Breaking Changes

### Plugin System
The plugin system has been completely redesigned.

#### Before (v1.x):
```javascript
const plugin = {
  init() { ... },
  execute() { ... }
};
```

#### After (v2.0):
```javascript
const plugin = {
  name: 'my-plugin',
  version: '1.0.0',
  setup(context) { ... },
  execute(params) { ... }
};
```

### Migration Steps
1. Update all plugin definitions
2. Add required `name` and `version` fields
3. Rename `init` to `setup`
4. Update plugin registration calls
5. Test all plugins thoroughly

### Timeline
- v1.x support ends: 3 months from v2.0 release
- Migration tools available at: github.com/project/migration-tools
EOF
    
    git add src/plugins-v2.js MIGRATION-V2.md
    git commit -m "feat(plugins)!: complete plugin system redesign

Redesigned plugin system for better performance and extensibility.

BREAKING CHANGE: Plugin interface has completely changed.
All existing plugins must be updated to work with v2.0.

See MIGRATION-V2.md for detailed migration instructions.

Key changes:
- Plugins now require name and version fields
- init() method renamed to setup(context)
- New plugin lifecycle hooks
- Async plugin loading support

Migration tools available to help with the transition."
    
    echo -e "${GREEN}✓ Breaking change with migration guide committed${NC}"
    ;;
esac

# Push the branch
echo -e "\n${YELLOW}Pushing branch with breaking changes${NC}"
git push -u origin $BRANCH_NAME

echo -e "${GREEN}✓ Branch pushed: $BRANCH_NAME${NC}"

# Create release branch for major version
echo -e "\n${YELLOW}Creating release branch for major version${NC}"

# Calculate next major version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
NEXT_MAJOR=$((MAJOR + 1))
NEXT_VERSION="${NEXT_MAJOR}.0.0"

RELEASE_BRANCH="release/$DATE-v${NEXT_MAJOR}-major"

git checkout main
git checkout -b $RELEASE_BRANCH

# Cherry-pick the breaking changes
echo -e "${YELLOW}Cherry-picking breaking changes to release branch${NC}"
COMMITS=$(git log --format="%H" origin/$BRANCH_NAME --reverse | head -n 10)
for COMMIT in $COMMITS; do
  git cherry-pick $COMMIT 2>/dev/null || true
done

# Prepare release
echo -e "${YELLOW}Preparing major release${NC}"
npm run prepare-release $NEXT_VERSION "Major release with breaking changes"

# Show release summary
echo -e "\n${CYAN}=== Release Summary ===${NC}"
echo -e "Current Version: ${CURRENT_VERSION}"
echo -e "Next Version: ${RED}${NEXT_VERSION}${NC} (MAJOR)"
echo -e "Release Branch: ${RELEASE_BRANCH}"
echo ""
echo "Breaking Changes:"
git log --format="- %s" main..$RELEASE_BRANCH | grep -E "(feat|refactor|fix).*!"
echo ""

# Push release branch
git push -u origin $RELEASE_BRANCH

echo -e "\n${GREEN}=== Breaking Changes Test Complete ===${NC}"
echo ""
echo "Next steps:"
echo "1. Create PR from $RELEASE_BRANCH to main"
echo "2. Review all breaking changes carefully"
echo "3. Ensure migration guide is complete"
echo "4. Notify all API consumers about major version"
echo "5. After merge, version ${RED}${NEXT_VERSION}${NC} will be released"
echo ""
echo -e "${RED}⚠️  Warning: Major version releases may break existing clients!${NC}"
echo "Ensure:"
echo "- [ ] Migration guide is provided"
echo "- [ ] Deprecation notices were given in advance"
echo "- [ ] Breaking changes are documented"
echo "- [ ] Rollback plan is ready"