#!/usr/bin/env node
/**
 * Updates the application version across mobile (apps/mobile/pubspec.yaml)
 * and backend (backend/pyproject.toml) during semantic-release prepare step.
 *
 * Usage: node scripts/bump-version.mjs <nextVersion> [--dry-run]
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, '..');

const args = process.argv.slice(2);
const nextVersion = args.find((arg) => !arg.startsWith('--'));
const isDryRun = args.includes('--dry-run');

if (!nextVersion) {
  console.error('Usage: node scripts/bump-version.mjs <nextVersion> [--dry-run]');
  process.exit(1);
}

// 1. Update apps/mobile/pubspec.yaml (semver+buildNumber)
const pubspecPath = path.join(rootDir, 'apps/mobile/pubspec.yaml');
const pubspecContent = fs.readFileSync(pubspecPath, 'utf8');
const pubspecVersionRegex = /^(version:\s*)(\d+\.\d+\.\d+(?:-[\w.]+)?)(?:\+(\d+))?(\s*)$/m;
const pubspecMatch = pubspecContent.match(pubspecVersionRegex);

if (!pubspecMatch) {
  console.error('Could not find version field in apps/mobile/pubspec.yaml');
  process.exit(1);
}

const currentBuild = pubspecMatch[3] ? parseInt(pubspecMatch[3], 10) : 0;
const nextBuild = currentBuild + 1;
const nextPubspecVersion = `${nextVersion}+${nextBuild}`;
const updatedPubspec = pubspecContent.replace(
  pubspecVersionRegex,
  `$1${nextPubspecVersion}$4`,
);

// 2. Update backend/pyproject.toml
const pyprojectPath = path.join(rootDir, 'backend/pyproject.toml');
const pyprojectContent = fs.readFileSync(pyprojectPath, 'utf8');
const pyprojectVersionRegex = /^(version\s*=\s*")([^"]+)(")$/m;
const pyprojectMatch = pyprojectContent.match(pyprojectVersionRegex);

if (!pyprojectMatch) {
  console.error('Could not find version field in backend/pyproject.toml');
  process.exit(1);
}

const updatedPyproject = pyprojectContent.replace(
  pyprojectVersionRegex,
  `$1${nextVersion}$3`,
);

if (isDryRun) {
  console.log(`[dry-run] apps/mobile/pubspec.yaml: ${pubspecMatch[2]}+${currentBuild} -> ${nextPubspecVersion}`);
  console.log(`[dry-run] backend/pyproject.toml: ${pyprojectMatch[2]} -> ${nextVersion}`);
} else {
  fs.writeFileSync(pubspecPath, updatedPubspec, 'utf8');
  fs.writeFileSync(pyprojectPath, updatedPyproject, 'utf8');
  console.log(`Updated apps/mobile/pubspec.yaml -> ${nextPubspecVersion}`);
  console.log(`Updated backend/pyproject.toml -> ${nextVersion}`);
}

