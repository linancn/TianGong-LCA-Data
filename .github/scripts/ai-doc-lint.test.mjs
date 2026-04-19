import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';

import {
  collectExpectedDocs,
  detectImpactLayout,
  globToRegExp,
  isKeyMarkdownDoc,
  loadImpactFiles,
  matchRules,
  missingMarkdownMetadata,
  missingYamlMetadata,
  normalizePath,
} from './ai-doc-lint.mjs';

test('normalizePath and globToRegExp support repo-relative matching', () => {
  assert.equal(normalizePath('.\\tiangong-lca-next\\config\\routes.ts'), 'tiangong-lca-next/config/routes.ts');
  assert.equal(globToRegExp('tiangong-lca-next/**').test('tiangong-lca-next/config/routes.ts'), true);
  assert.equal(globToRegExp('ai/*.md').test('ai/quality-rubric.md'), true);
  assert.equal(globToRegExp('ai/*.md').test('ai/nested/file.md'), false);
});

test('detectImpactLayout distinguishes workspace and repo roots', () => {
  const tempDir = mkdtempSync(path.join(os.tmpdir(), 'ai-doc-lint-layout-'));
  mkdirSync(path.join(tempDir, 'ai'), { recursive: true });

  assert.equal(detectImpactLayout(tempDir), 'none');

  writeFileSync(path.join(tempDir, 'ai', 'doc-impact.yaml'), JSON.stringify({ version: 1 }));
  assert.equal(detectImpactLayout(tempDir), 'repo');

  writeFileSync(path.join(tempDir, 'ai', 'doc-impact-map.yaml'), JSON.stringify({ version: 1 }));
  assert.equal(detectImpactLayout(tempDir), 'workspace');
});

test('isKeyMarkdownDoc excludes YAML contract files', () => {
  assert.equal(isKeyMarkdownDoc('ai/quality-rubric.md'), true);
  assert.equal(isKeyMarkdownDoc('AGENTS.md'), true);
  assert.equal(isKeyMarkdownDoc('ai/workspace.yaml'), false);
});

test('missingMarkdownMetadata detects absent frontmatter keys', () => {
  const text = `---
title: Example
docType: contract
scope: workspace
status: draft
authoritative: false
owner: lca-workspace
language: en
whenToUse:
  - x
whenToUpdate:
  - y
checkPaths:
  - ai/**
lastReviewedAt: 2026-04-18
---

# Example
`;

  assert.deepEqual(missingMarkdownMetadata(text), ['lastReviewedCommit']);
});

test('missingYamlMetadata detects absent top-level review fields', () => {
  const text = JSON.stringify({ version: 1, lastReviewedAt: '2026-04-18' });
  assert.deepEqual(missingYamlMetadata(text, 'ai/example.yaml'), ['lastReviewedCommit']);
});

test('loadImpactFiles, matchRules, and collectExpectedDocs resolve repo-local paths', () => {
  const tempDir = mkdtempSync(path.join(os.tmpdir(), 'ai-doc-lint-'));
  mkdirSync(path.join(tempDir, 'ai'), { recursive: true });
  mkdirSync(path.join(tempDir, 'subrepo', 'ai'), { recursive: true });

  writeFileSync(
    path.join(tempDir, 'ai', 'doc-impact-map.yaml'),
    JSON.stringify(
      {
        version: 1,
        lastReviewedAt: '2026-04-18',
        lastReviewedCommit: 'abc',
        rules: [
          {
            id: 'root-rule',
            scope: 'workspace',
            repo: 'lca-workspace',
            triggers: [{ path: 'AGENTS.md', kind: 'doc-contract' }],
            requiredDocs: [{ path: 'ai/workspace.yaml', mode: 'review_or_update' }],
            reason: 'root',
          },
        ],
      },
      null,
      2,
    ),
  );

  writeFileSync(
    path.join(tempDir, 'subrepo', 'ai', 'doc-impact.yaml'),
    JSON.stringify(
      {
        version: 1,
        lastReviewedAt: '2026-04-18',
        lastReviewedCommit: 'abc',
        rules: [
          {
            id: 'repo-rule',
            scope: 'repo',
            repo: 'subrepo',
            triggers: [{ path: 'src/**', kind: 'code' }],
            requiredDocs: [{ path: 'ai/task-router.md', mode: 'review_or_update' }],
            reason: 'repo',
          },
        ],
      },
      null,
      2,
    ),
  );

  const loadedRules = loadImpactFiles(tempDir);
  const matches = matchRules(['AGENTS.md', 'subrepo/src/index.ts'], loadedRules);
  const expectedDocs = collectExpectedDocs(matches);

  assert.equal(loadedRules.length, 2);
  assert.equal(matches.length, 2);
  assert.deepEqual([...expectedDocs.keys()].sort(), ['ai/workspace.yaml', 'subrepo/ai/task-router.md']);
});

test('loadImpactFiles supports repo-root mode', () => {
  const tempDir = mkdtempSync(path.join(os.tmpdir(), 'ai-doc-lint-repo-'));
  mkdirSync(path.join(tempDir, 'ai'), { recursive: true });

  writeFileSync(
    path.join(tempDir, 'ai', 'doc-impact.yaml'),
    JSON.stringify(
      {
        version: 1,
        lastReviewedAt: '2026-04-18',
        lastReviewedCommit: 'abc',
        rules: [
          {
            id: 'repo-rule',
            scope: 'repo',
            repo: 'example',
            triggers: [{ path: 'src/**', kind: 'code' }],
            requiredDocs: [{ path: 'ai/validation.md', mode: 'review_or_update' }],
            reason: 'repo-root',
          },
        ],
      },
      null,
      2,
    ),
  );

  const loadedRules = loadImpactFiles(tempDir);
  const matches = matchRules(['src/index.ts'], loadedRules);
  const expectedDocs = collectExpectedDocs(matches);

  assert.equal(loadedRules.length, 1);
  assert.equal(matches.length, 1);
  assert.deepEqual([...expectedDocs.keys()], ['ai/validation.md']);
});
