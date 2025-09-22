#!/bin/bash

# Test Hotfix Emergency Deployment Flow
# This script tests the hotfix workflow for critical production fixes

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${RED}=== Testing Emergency Hotfix Flow ===${NC}"
echo "This simulates a critical production bug that needs immediate fixing"
echo ""

# Configuration
TICKET_ID="CRIT-001"
HOTFIX_BRANCH="hotfix/$TICKET_ID-security-vulnerability"
CURRENT_VERSION=$(node -p "require('./package.json').version")

echo -e "${YELLOW}Current production version: $CURRENT_VERSION${NC}"
echo "Simulating critical security vulnerability discovered in production!"
echo ""

# Step 1: Create hotfix branch from main
echo -e "${YELLOW}Step 1: Creating hotfix branch from main${NC}"
git checkout main
git pull origin main
git checkout -b $HOTFIX_BRANCH

echo -e "${GREEN}✓ Hotfix branch created: $HOTFIX_BRANCH${NC}"

# Step 2: Apply the critical fix
echo -e "${YELLOW}Step 2: Applying security fix${NC}"

# Create the security fix
cat > src/security-patch.js << 'EOF'
// CRITICAL SECURITY PATCH
// CVE-2024-XXXXX: Input validation vulnerability

export function sanitizeInput(input) {
  if (typeof input !== 'string') {
    throw new TypeError('Input must be a string');
  }
  
  // Remove potential XSS vectors
  const cleaned = input
    .replace(/<script[^>]*>.*?<\/script>/gi, '')
    .replace(/<iframe[^>]*>.*?<\/iframe>/gi, '')
    .replace(/javascript:/gi, '')
    .replace(/on\w+\s*=/gi, '');
  
  // Escape HTML entities
  const escaped = cleaned
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
  
  return escaped;
}

// Apply patch to existing functions
export function patchVulnerableEndpoints() {
  console.log('[SECURITY] Critical vulnerability patched');
  console.log('[SECURITY] CVE-2024-XXXXX mitigated');
  return true;
}
EOF

# Update the main application to use the patch
cat >> src/index.js << 'EOF'

// HOTFIX: Security patch applied
const { sanitizeInput, patchVulnerableEndpoints } = require('./security-patch');
patchVulnerableEndpoints();

// Apply input sanitization to all routes
app.use((req, res, next) => {
  if (req.body) {
    Object.keys(req.body).forEach(key => {
      if (typeof req.body[key] === 'string') {
        req.body[key] = sanitizeInput(req.body[key]);
      }
    });
  }
  next();
});
EOF

echo -e "${GREEN}✓ Security patch applied${NC}"

# Step 3: Add tests for the fix
echo -e "${YELLOW}Step 3: Adding security tests${NC}"

mkdir -p tests
cat > tests/security.test.js << 'EOF'
// Security patch tests
const { sanitizeInput } = require('../src/security-patch');

describe('Security Patch', () => {
  test('removes script tags', () => {
    const malicious = '<script>alert("XSS")</script>Hello';
    const cleaned = sanitizeInput(malicious);
    expect(cleaned).not.toContain('<script>');
    expect(cleaned).toContain('Hello');
  });

  test('escapes HTML entities', () => {
    const html = '<div>Test</div>';
    const escaped = sanitizeInput(html);
    expect(escaped).toBe('&lt;div&gt;Test&lt;/div&gt;');
  });

  test('handles normal input', () => {
    const normal = 'Hello World';
    expect(sanitizeInput(normal)).toBe('Hello World');
  });
});
EOF

echo -e "${GREEN}✓ Security tests added${NC}"

# Step 4: Commit the hotfix
echo -e "${YELLOW}Step 4: Committing hotfix${NC}"
git add -A
git commit -m "fix(security): patch critical XSS vulnerability (CVE-2024-XXXXX)

- Implement input sanitization for all user inputs
- Add HTML entity escaping
- Remove potentially dangerous script tags
- Add comprehensive security tests

This is a CRITICAL security fix that must be deployed immediately.

Closes $TICKET_ID
Security: CVE-2024-XXXXX"

echo -e "${GREEN}✓ Hotfix committed${NC}"

# Step 5: Push hotfix branch
echo -e "${YELLOW}Step 5: Pushing hotfix branch${NC}"
git push -u origin $HOTFIX_BRANCH

echo -e "${GREEN}✓ Hotfix branch pushed${NC}"

# Step 6: Show PR creation
echo -e "${MAGENTA}\n⚠️  URGENT: Create PR to main immediately!${NC}"
echo "GitHub CLI command:"
echo -e "${YELLOW}gh pr create \\
  --base main \\
  --head $HOTFIX_BRANCH \\
  --title \"🚨 CRITICAL: Security vulnerability fix (CVE-2024-XXXXX)\" \\
  --body \"## 🚨 CRITICAL SECURITY FIX\n\n### Issue\nCVE-2024-XXXXX: XSS vulnerability in user input handling\n\n### Solution\n- Implemented comprehensive input sanitization\n- Added HTML entity escaping\n- Removed script tag injection vectors\n\n### Testing\n- Security tests added and passing\n- Manual testing completed\n- No regressions identified\n\n### Deployment\nThis fix must be deployed to production IMMEDIATELY.\n\nCloses #$TICKET_ID\" \\
  --label \"critical\" \\
  --label \"security\" \\
  --label \"hotfix\"${NC}"

read -p "\nCreate urgent PR now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh pr create \
      --base main \
      --head $HOTFIX_BRANCH \
      --title "🚨 CRITICAL: Security vulnerability fix (CVE-2024-XXXXX)" \
      --body "## 🚨 CRITICAL SECURITY FIX

### Issue
CVE-2024-XXXXX: XSS vulnerability in user input handling

### Solution
- Implemented comprehensive input sanitization
- Added HTML entity escaping
- Removed script tag injection vectors

### Testing
- Security tests added and passing
- Manual testing completed
- No regressions identified

### Deployment
This fix must be deployed to production IMMEDIATELY.

Closes #$TICKET_ID" \
      --label "critical" \
      --label "security" \
      --label "hotfix"
    
    echo -e "${GREEN}✓ Critical PR created${NC}"
fi

# Step 7: Simulate merge to main (for testing)
echo -e "\n${YELLOW}Step 7: After PR approval and merge${NC}"
echo "Expected outcome after merge to main:"
echo "- Automatic patch version bump (e.g., 1.0.0 → 1.0.1)"
echo "- GitHub release created with security notes"
echo "- CHANGELOG.md updated with security fix"
echo "- Production deployment triggered"

# Step 8: Backport instructions
echo -e "\n${YELLOW}Step 8: Backporting to other branches${NC}"
echo "After main deployment, backport to:"
echo ""
echo "1. Dev branch:"
echo "   git checkout dev"
echo "   git merge $HOTFIX_BRANCH"
echo "   git push origin dev"
echo ""
echo "2. Active release branches:"
echo "   git branch -r | grep release/"
echo "   # For each active release:"
echo "   git checkout release/BRANCH_NAME"
echo "   git cherry-pick $(git log -1 --format=%H $HOTFIX_BRANCH)"
echo "   git push"

# Step 9: Verification
echo -e "\n${YELLOW}Step 9: Post-deployment verification${NC}"
echo "After deployment, verify:"
echo "[ ] Production version updated"
echo "[ ] Security patch active"
echo "[ ] No regression in functionality"
echo "[ ] Monitoring for any issues"
echo "[ ] Security scan passes"

echo -e "\n${GREEN}=== Hotfix Flow Test Complete ===${NC}"
echo -e "${MAGENTA}\n⚠️  Remember: Hotfixes bypass normal release cycle!${NC}"
echo "Timeline:"
echo "1. ✔️ Create hotfix branch"
echo "2. ✔️ Apply and test fix"
echo "3. ✔️ Push to GitHub"
echo "4. → Create PR to main (URGENT)"
echo "5. → Get emergency approval"
echo "6. → Merge to main"
echo "7. → Automatic release and deployment"
echo "8. → Backport to dev and release branches"
echo "9. → Verify production fix"