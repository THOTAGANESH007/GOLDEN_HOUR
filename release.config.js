/**
 * Semantic Release Configuration for Golden Hour
 * Follows Conventional Commits specification.
 * Automatically analyzes commits, computes semantic version, generates release notes,
 * updates CHANGELOG.md, and creates GitHub releases with compiled artifacts.
 */
module.exports = {
  branches: [
    'main',
    { name: 'next-updates', prerelease: 'rc' },
  ],
  plugins: [
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'conventionalcommits',
        releaseRules: [
          { type: 'feat', release: 'minor' },
          { type: 'fix', release: 'patch' },
          { type: 'perf', release: 'patch' },
          { type: 'docs', scope: 'README', release: 'patch' },
          { type: 'refactor', release: 'patch' },
          { type: 'style', release: false },
          { type: 'test', release: false },
          { type: 'chore', release: false },
        ],
      },
    ],
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits',
        presetConfig: {
          types: [
            { type: 'feat', section: 'Features' },
            { type: 'fix', section: 'Bug Fixes' },
            { type: 'perf', section: 'Performance Improvements' },
            { type: 'refactor', section: 'Code Refactoring' },
            { type: 'docs', section: 'Documentation' },
            { type: 'chore', section: 'Maintenance', hidden: true },
          ],
        },
      },
    ],
    [
      '@semantic-release/changelog',
      {
        changelogFile: 'CHANGELOG.md',
      },
    ],
    [
      '@semantic-release/exec',
      {
        prepareCmd: 'node scripts/bump-version.mjs ${nextRelease.version}',
      },
    ],
    [
      '@semantic-release/git',
      {
        assets: [
          'CHANGELOG.md',
          'apps/mobile/pubspec.yaml',
          'backend/pyproject.toml',
        ],
        message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}',
      },
    ],
    [
      '@semantic-release/github',
      {
        assets: [
          {
            path: 'apps/mobile/build/app/outputs/flutter-apk/app-release.apk',
            label: 'Golden Hour APK (v${nextRelease.version})',
          },
          {
            path: 'apps/mobile/build/app/outputs/bundle/release/app-release.aab',
            label: 'Golden Hour AppBundle AAB (v${nextRelease.version})',
          },
        ],
      },
    ],
  ],
};

