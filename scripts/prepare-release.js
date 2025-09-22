#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Get command line arguments
const args = process.argv.slice(2);
const version = args[0];
const description = args[1] || 'Release preparation';

if (!version) {
  console.error('❌ Usage: npm run prepare-release <version> [description]');
  console.error('Example: npm run prepare-release 2.1.0 "New payment features"');
  process.exit(1);
}

// Validate version format
if (!/^\d+\.\d+\.\d+$/.test(version)) {
  console.error('❌ Invalid version format. Must be X.Y.Z (e.g., 2.1.0)');
  process.exit(1);
}

// Get current branch
let currentBranch;
try {
  currentBranch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf8' }).trim();
} catch (error) {
  console.error('❌ Failed to get current branch:', error.message);
  process.exit(1);
}

// Check if we're on a release branch
if (!currentBranch.startsWith('release/')) {
  console.error(`❌ This script must be run from a release branch.`);
  console.error(`Current branch: ${currentBranch}`);
  console.error(`\nTo create a release branch:`);
  console.error(`git checkout -b release/$(date +%d%m%y)-${description.toLowerCase().replace(/\s+/g, '-')}`);
  process.exit(1);
}

// Create release.json
const releaseInfo = {
  version: version,
  releaseDate: new Date().toISOString().split('T')[0],
  rcBuildCounter: 0,
  lastRCTag: '',
  description: description,
  branch: currentBranch,
  preparedBy: process.env.USER || 'unknown',
  preparedAt: new Date().toISOString()
};

// Write release.json
const releaseJsonPath = path.join(process.cwd(), 'release.json');
try {
  fs.writeFileSync(releaseJsonPath, JSON.stringify(releaseInfo, null, 2) + '\n');
  console.log('✅ Created release.json:');
  console.log(JSON.stringify(releaseInfo, null, 2));
} catch (error) {
  console.error('❌ Failed to create release.json:', error.message);
  process.exit(1);
}

// Stage and commit the file
try {
  execSync('git add release.json');
  execSync(`git commit -m "chore: prepare release ${version}" -m "${description}"`);
  console.log(`\n✅ Committed release.json for version ${version}`);
} catch (error) {
  console.error('⚠️ Failed to commit (may already be committed):', error.message);
}

console.log('\n📋 Next steps:');
console.log('1. Review and test your changes');
console.log('2. Push the branch: git push -u origin ' + currentBranch);
console.log('3. Create a Pull Request to main branch');
console.log('4. After PR approval and merge, version ' + version + ' will be released');
console.log('\n💡 RC builds will be automatically created when you push to this branch');