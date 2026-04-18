#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const MARKDOWN_METADATA_KEYS = [
  'docType',
  'scope',
  'status',
  'authoritative',
  'owner',
  'language',
  'whenToUse',
  'whenToUpdate',
  'checkPaths',
  'lastReviewedAt',
  'lastReviewedCommit',
];

const YAML_METADATA_KEYS = ['lastReviewedAt', 'lastReviewedCommit'];

export function normalizePath(value) {
  return value.replace(/\\/g, '/').replace(/^\.\//, '').replace(/\/+/g, '/');
}

export function escapeRegex(value) {
  return value.replace(/[|\\{}()[\]^$+?.]/g, '\\$&');
}

export function globToRegExp(pattern) {
  const normalized = normalizePath(pattern);
  let output = '^';

  for (let index = 0; index < normalized.length; index += 1) {
    const char = normalized[index];
    const next = normalized[index + 1];

    if (char === '*') {
      if (next === '*') {
        output += '.*';
        index += 1;
      } else {
        output += '[^/]*';
      }
      continue;
    }

    if (char === '?') {
      output += '[^/]';
      continue;
    }

    output += escapeRegex(char);
  }

  output += '$';
  return new RegExp(output);
}

export function matchesPattern(filePath, pattern) {
  return globToRegExp(pattern).test(normalizePath(filePath));
}

export function parseJsonCompatibleYaml(text, sourceLabel) {
  try {
    return JSON.parse(text);
  } catch (error) {
    throw new Error(
      `${sourceLabel} is not valid JSON-compatible YAML. Phase 1 contract files must use JSON-compatible YAML syntax. ${error.message}`,
    );
  }
}

export function loadJsonCompatibleYaml(absPath, sourceLabel = absPath) {
  return parseJsonCompatibleYaml(readFileSync(absPath, 'utf8'), sourceLabel);
}

export function parseFrontmatterKeys(text) {
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
  if (!match) {
    return new Set();
  }

  return new Set(
    Array.from(match[1].matchAll(/^([A-Za-z][A-Za-z0-9]*)\s*:/gm), (result) => result[1]),
  );
}

export function missingMarkdownMetadata(text) {
  const keys = parseFrontmatterKeys(text);
  return MARKDOWN_METADATA_KEYS.filter((key) => !keys.has(key));
}

export function missingYamlMetadata(text, sourceLabel) {
  const parsed = parseJsonCompatibleYaml(text, sourceLabel);
  return YAML_METADATA_KEYS.filter((key) => !(key in parsed));
}

export function isKeyMarkdownDoc(relPath) {
  const normalized = normalizePath(relPath);
  return (
    path.posix.basename(normalized) === 'AGENTS.md' ||
    ((normalized.startsWith('ai/') || normalized.includes('/ai/')) && normalized.endsWith('.md'))
  );
}

export function isKeyYamlContract(relPath) {
  const normalized = normalizePath(relPath);
  return normalized.endsWith('.yaml') && (normalized.startsWith('ai/') || normalized.includes('/ai/'));
}

export function detectImpactLayout(rootDir) {
  if (existsSync(path.join(rootDir, 'ai', 'doc-impact-map.yaml'))) {
    return 'workspace';
  }
  if (existsSync(path.join(rootDir, 'ai', 'doc-impact.yaml'))) {
    return 'repo';
  }
  return 'none';
}

export function listImpactFiles(rootDir) {
  const layout = detectImpactLayout(rootDir);

  if (layout === 'repo') {
    return [
      {
        absPath: path.join(rootDir, 'ai', 'doc-impact.yaml'),
        relPath: 'ai/doc-impact.yaml',
        baseDir: '',
      },
    ];
  }

  if (layout !== 'workspace') {
    return [];
  }

  const rootImpact = path.join(rootDir, 'ai', 'doc-impact-map.yaml');
  const results = [
    {
      absPath: rootImpact,
      relPath: 'ai/doc-impact-map.yaml',
      baseDir: '',
    },
  ];

  for (const entry of readdirSync(rootDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) {
      continue;
    }
    if (entry.name.startsWith('.')) {
      continue;
    }

    const repoImpact = path.join(rootDir, entry.name, 'ai', 'doc-impact.yaml');
    if (!existsSync(repoImpact)) {
      continue;
    }

    results.push({
      absPath: repoImpact,
      relPath: normalizePath(path.join(entry.name, 'ai', 'doc-impact.yaml')),
      baseDir: entry.name,
    });
  }

  return results;
}

export function loadImpactFiles(rootDir) {
  return listImpactFiles(rootDir).flatMap(({ absPath, relPath, baseDir }) => {
    const parsed = loadJsonCompatibleYaml(absPath, relPath);
    const rules = Array.isArray(parsed.rules) ? parsed.rules : [];

    return rules.map((rule) => ({
      source: relPath,
      baseDir,
      rule,
    }));
  });
}

export function resolveRulePath(baseDir, relPattern) {
  if (!baseDir) {
    return normalizePath(relPattern);
  }
  return normalizePath(path.posix.join(baseDir, relPattern));
}

export function matchRules(changedPaths, loadedRules) {
  const matches = [];

  for (const changedPath of changedPaths) {
    for (const loaded of loadedRules) {
      const triggers = Array.isArray(loaded.rule.triggers) ? loaded.rule.triggers : [];
      if (
        triggers.some((trigger) =>
          matchesPattern(changedPath, resolveRulePath(loaded.baseDir, trigger.path)),
        )
      ) {
        matches.push({
          changedPath,
          source: loaded.source,
          rule: loaded.rule,
          baseDir: loaded.baseDir,
        });
      }
    }
  }

  return matches;
}

export function collectExpectedDocs(matches) {
  const expected = new Map();

  for (const match of matches) {
    const requiredDocs = Array.isArray(match.rule.requiredDocs) ? match.rule.requiredDocs : [];
    for (const doc of requiredDocs) {
      const fullPath = resolveRulePath(match.baseDir, doc.path);
      if (!expected.has(fullPath)) {
        expected.set(fullPath, {
          path: fullPath,
          rules: new Set(),
          changedPaths: new Set(),
          modes: new Set(),
        });
      }

      const entry = expected.get(fullPath);
      entry.rules.add(match.rule.id);
      entry.changedPaths.add(match.changedPath);
      entry.modes.add(doc.mode);
    }
  }

  return expected;
}

export function parseArgs(argv) {
  const options = {
    rootDir: process.cwd(),
    mode: 'warn',
    files: [],
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];

    if (arg === '--root') {
      options.rootDir = argv[index + 1];
      index += 1;
      continue;
    }
    if (arg === '--mode') {
      options.mode = argv[index + 1];
      index += 1;
      continue;
    }
    if (arg === '--base') {
      options.base = argv[index + 1];
      index += 1;
      continue;
    }
    if (arg === '--head') {
      options.head = argv[index + 1];
      index += 1;
      continue;
    }
    if (arg === '--files') {
      options.files = argv[index + 1]
        .split(',')
        .map((value) => normalizePath(value.trim()))
        .filter(Boolean);
      index += 1;
      continue;
    }
    if (arg === '--help') {
      options.help = true;
      continue;
    }

    throw new Error(`Unknown argument: ${arg}`);
  }

  return options;
}

export function getChangedPaths({ rootDir, base, head, files }) {
  if (files.length > 0) {
    return [...new Set(files)];
  }

  if (!base || !head) {
    throw new Error('Pass either --files or both --base and --head.');
  }

  const output = execFileSync('git', ['diff', '--name-only', `${base}...${head}`], {
    cwd: rootDir,
    encoding: 'utf8',
  });

  return [...new Set(output.split(/\r?\n/).map((value) => normalizePath(value.trim())).filter(Boolean))];
}

export function buildDocProblems({ rootDir, changedPaths }) {
  const problems = [];

  for (const relPath of changedPaths) {
    const absPath = path.join(rootDir, relPath);
    if (!existsSync(absPath)) {
      continue;
    }

    if (isKeyMarkdownDoc(relPath)) {
      const missing = missingMarkdownMetadata(readFileSync(absPath, 'utf8'));
      if (missing.length > 0) {
        problems.push({
          type: 'missing-metadata',
          path: relPath,
          message: `Missing Markdown metadata keys: ${missing.join(', ')}`,
        });
      }
      continue;
    }

    if (isKeyYamlContract(relPath)) {
      const missing = missingYamlMetadata(readFileSync(absPath, 'utf8'), relPath);
      if (missing.length > 0) {
        problems.push({
          type: 'missing-metadata',
          path: relPath,
          message: `Missing YAML metadata keys: ${missing.join(', ')}`,
        });
      }
    }
  }

  return problems;
}

export function buildMissingDocProblems({ changedPaths, expectedDocs }) {
  const changed = new Set(changedPaths);
  const problems = [];

  for (const entry of expectedDocs.values()) {
    if (changed.has(entry.path)) {
      continue;
    }

    problems.push({
      type: 'missing-review',
      path: entry.path,
      message: `Expected reviewed doc was not touched. Triggered by ${Array.from(entry.changedPaths).join(', ')} via rule(s): ${Array.from(entry.rules).join(', ')}`,
    });
  }

  return problems;
}

export function formatProblem(problem) {
  return `- [${problem.type}] ${problem.path}: ${problem.message}`;
}

export function emitProblems(problems, mode) {
  if (problems.length === 0) {
    console.log('AI doc lint: no problems found.');
    return;
  }

  const heading =
    mode === 'enforce' ? 'AI doc lint found blocking problems:' : 'AI doc lint found warnings:';
  const annotationLevel = mode === 'enforce' ? 'error' : 'warning';
  console.log(heading);
  for (const problem of problems) {
    console.log(formatProblem(problem));
    if (process.env.GITHUB_ACTIONS) {
      console.log(`::${annotationLevel} file=${problem.path}::${problem.message}`);
    }
  }
}

export function run(options) {
  const changedPaths = getChangedPaths(options);
  if (changedPaths.length === 0) {
    console.log('AI doc lint: no changed paths to inspect.');
    return { problems: [], changedPaths, matchedRules: [] };
  }

  const loadedRules = loadImpactFiles(options.rootDir);
  const matchedRules = matchRules(changedPaths, loadedRules);
  const expectedDocs = collectExpectedDocs(matchedRules);
  const problems = [
    ...buildMissingDocProblems({ changedPaths, expectedDocs }),
    ...buildDocProblems({ rootDir: options.rootDir, changedPaths }),
  ];

  emitProblems(problems, options.mode);

  if (options.mode === 'enforce' && problems.length > 0) {
    process.exitCode = 1;
  }

  return { problems, changedPaths, matchedRules };
}

function printHelp() {
  console.log(`Usage: node .github/scripts/ai-doc-lint.mjs [--mode warn|enforce] [--base <sha> --head <sha> | --files <csv>] [--root <dir>]`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const options = parseArgs(process.argv.slice(2));
    if (options.help) {
      printHelp();
      process.exit(0);
    }
    run(options);
  } catch (error) {
    console.error(`AI doc lint error: ${error.message}`);
    process.exit(2);
  }
}
