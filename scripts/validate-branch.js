#!/usr/bin/env node

const { execSync } = require('child_process');

// Get current branch
let currentBranch;
try {
  currentBranch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf8' }).trim();
} catch (error) {
  console.error('❌ Failed to get current branch:', error.message);
  process.exit(1);
}

console.log(`\n🔍 Validating branch: ${currentBranch}\n`);

// Define valid patterns
const patterns = {
  main: /^main$/,
  dev: /^dev$/,
  feature: /^feature\/[a-z0-9-]+$/,
  release: /^release\/\d{6}(-\d+)?-[a-z0-9-]+$/,
  hotfix: /^hotfix\/[a-z0-9]+-[a-z0-9-]+$/,
  fix: /^fix\/[a-z0-9]+-[a-z0-9-]+$/,
  refact: /^refact\/[a-z0-9-]+-[a-z0-9-]+$/
};

// Check branch validity
let isValid = false;
let branchType = '';

for (const [type, pattern] of Object.entries(patterns)) {
  if (pattern.test(currentBranch)) {
    isValid = true;
    branchType = type;
    break;
  }
}

if (isValid) {
  console.log(`✅ Valid ${branchType} branch: ${currentBranch}`);

  // Provide merge guidance
  console.log('\n📋 Merge rules for this branch type:');

  switch (branchType) {
    case 'main':
      console.log('  - Protected branch');
      console.log('  - Can receive merges from: release/*, hotfix/*, fix/*');
      console.log('  - Requires PR approval');
      break;
    case 'dev':
      console.log('  - Integration branch');
      console.log('  - Can receive merges from: feature/*, fix/*, refact/*');
      console.log('  - Never merges to release branches');
      break;
    case 'feature':
      console.log('  - Merges to: dev (always), release/* (if targeted)');
      console.log('  - Created from: main');
      break;
    case 'release':
      console.log('  - Merges to: main (when ready)');
      console.log('  - Can receive: feature/*, fix/* (cherry-picked)');
      console.log('  - Remember to create/update release.json');
      break;
    case 'hotfix':
      console.log('  - Emergency fix branch');
      console.log('  - Merges to: main (direct), then backport to dev and active release/*');
      break;
    case 'fix':
      console.log('  - Bug fix branch');
      console.log('  - Merges to: dev, release/*, or main (based on urgency)');
      break;
    case 'refact':
      console.log('  - Code refactoring branch');
      console.log('  - Merges to: dev (standard), release/* (if needed)');
      break;
  }

  // Check for uncommitted changes
  try {
    const status = execSync('git status --porcelain', { encoding: 'utf8' });
    if (status) {
      console.log('\n⚠️ Warning: You have uncommitted changes');
      console.log('Run "git status" to see details');
    }
  } catch (error) {
    // Ignore errors
  }

} else {
  console.error(`❌ Invalid branch name: ${currentBranch}`);
  console.error('\n📋 Valid branch patterns:');
  console.error('  - main (protected)');
  console.error('  - dev (integration)');
  console.error('  - feature/ticket-description');
  console.error('  - release/DDMMYY[-n]-description');
  console.error('  - hotfix/ticket-critical-description');
  console.error('  - fix/ticket-description');
  console.error('  - refact/component-description');
  console.error('\n💡 Examples:');
  console.error('  - feature/add-payment-gateway');
  console.error('  - release/091025-v2-payments');
  console.error('  - hotfix/fix-123-critical-auth-bug');
  console.error('  - fix/bug-456-validation-error');
  console.error('  - refact/auth-service-cleanup');
  process.exit(1);
}

console.log('\n');