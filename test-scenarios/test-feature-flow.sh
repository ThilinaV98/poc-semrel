#!/bin/bash

# Test Feature Branch Flow
# This script tests the complete feature development workflow

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Testing Feature Branch Flow ===${NC}"
echo "This will test: feature → dev → release → main"
echo ""

# Configuration
FEATURE_NAME="test-payment-integration"
VERSION="1.2.0"
DATE=$(date +%d%m%y)

# Step 1: Create feature branch
echo -e "${YELLOW}Step 1: Creating feature branch${NC}"
git checkout main
git pull origin main
git checkout -b feature/$FEATURE_NAME

# Step 2: Make feature changes
echo -e "${YELLOW}Step 2: Making feature changes${NC}"
cat > src/payment.js << 'EOF'
// Payment Integration Module
export class PaymentProcessor {
  constructor() {
    this.provider = 'Stripe';
  }

  async processPayment(amount, currency) {
    console.log(`Processing ${amount} ${currency} via ${this.provider}`);
    return { success: true, transactionId: Date.now() };
  }
}
EOF

# Step 3: Commit with conventional commit message
echo -e "${YELLOW}Step 3: Committing changes${NC}"
git add src/payment.js
git commit -m "feat(payment): add Stripe payment integration

- Implement PaymentProcessor class
- Add support for multiple currencies
- Include transaction ID generation

Closes #123"

# Step 4: Push feature branch
echo -e "${YELLOW}Step 4: Pushing feature branch${NC}"
git push -u origin feature/$FEATURE_NAME

echo -e "${GREEN}✓ Feature branch created and pushed${NC}"
echo ""
echo "Next steps:"
echo "1. Create PR to 'dev' branch via GitHub UI"
echo "2. After merge to dev, it will create a pre-release"
echo ""

# Step 5: Simulate merge to dev (local)
read -p "Press enter to simulate merge to dev..."
echo -e "${YELLOW}Step 5: Simulating merge to dev${NC}"
git checkout dev
git pull origin dev
git merge feature/$FEATURE_NAME --no-ff -m "Merge pull request #124 from feature/$FEATURE_NAME"
echo -e "${GREEN}✓ Merged to dev (pre-release will be created)${NC}"

# Step 6: Create release branch
read -p "Press enter to create release branch..."
echo -e "${YELLOW}Step 6: Creating release branch${NC}"
git checkout main
git checkout -b release/$DATE-payments

# Cherry-pick from feature
git cherry-pick $(git log --format="%H" -n 1 feature/$FEATURE_NAME)

# Step 7: Prepare release
echo -e "${YELLOW}Step 7: Preparing release${NC}"
npm run prepare-release $VERSION "Payment integration release"

# Step 8: Push release branch
echo -e "${YELLOW}Step 8: Pushing release branch${NC}"
git push -u origin release/$DATE-payments

echo -e "${GREEN}✓ Release branch created with version $VERSION${NC}"
echo "RC tags will be created automatically"
echo ""

# Step 9: Show final status
echo -e "${YELLOW}Step 9: Final Status${NC}"
echo "Current branches:"
git branch -a | grep -E "(feature|release|dev|main)"
echo ""
echo "Recent commits:"
git log --oneline -5
echo ""

echo -e "${GREEN}=== Feature Flow Test Complete ===${NC}"
echo "To complete the release:"
echo "1. Create PR from release/$DATE-payments to main"
echo "2. After merge, version $VERSION will be released"
echo "3. Check GitHub Releases for the new version"

# Cleanup option
read -p "Clean up test branches? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git checkout main
    git branch -D feature/$FEATURE_NAME 2>/dev/null || true
    git push origin --delete feature/$FEATURE_NAME 2>/dev/null || true
    echo -e "${GREEN}✓ Cleanup complete${NC}"
fi