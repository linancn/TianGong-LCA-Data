---
title: data Validation Guide
docType: guide
scope: repo
status: active
authoritative: true
owner: data
language: en
whenToUse:
  - when selecting validation for data, schema, stylesheet, release-note, or documentation-governance changes
  - when recording proof for repository-local docpact governance changes
whenToUpdate:
  - when a canonical validation command is added
  - when data or asset validation expectations change
  - when docpact governance rules or CI behavior change
checkPaths:
  - AGENTS.md
  - .docpact/config.yaml
  - .github/workflows/ai-doc-lint.yml
  - tiangong_lca_data/**
  - schemas/**
  - stylesheets/**
  - release_notes/**
  - .githooks/pre-push
  - scripts/docpact
  - scripts/docpact-gate.sh
  - scripts/install-git-hooks.sh
lastReviewedAt: 2026-05-08
lastReviewedCommit: 7268905de463f749fabe020317c573c7f061c5b5
related:
  - AGENTS.md
  - .docpact/config.yaml
  - docs/agents/repo-architecture.md
---

# data Validation Guide

This repository is content-oriented and does not currently define a single checked-in green-bar wrapper such as `npm test`, `cargo test`, or `pytest`.

## Required Validation Shape

- Data payload changes require direct review of the touched files under `tiangong_lca_data/**`.
- Schema and stylesheet changes require reviewing the affected bundled assets and any data-package expectations they imply.
- Release-note changes require checking that the narrative matches the data snapshot being shipped.
- Documentation-governance changes require docpact validation.

## Docpact Validation

Run these commands for governance changes:

```bash
scripts/docpact validate-config --root . --strict
scripts/docpact lint --root . --base origin/main --head HEAD --mode enforce
```

The repository PR workflow runs the same docpact config validation and PR-shaped lint gate.

## Future Automation

If this repository gains a canonical data validation wrapper later, update this file, `AGENTS.md`, and `.docpact/config.yaml` in the same change.

## Local Docpact Push Gate

Install the versioned local hook once per checkout:

```bash
./scripts/install-git-hooks.sh
```

The `pre-push` hook runs `scripts/docpact-gate.sh`, which delegates CLI lookup to `scripts/docpact` and performs strict config validation plus enforced lint before the push leaves the machine. The wrapper checks `DOCPACT_BIN`, Cargo install locations, Homebrew install locations, and then `PATH`, so local agent shells should not fail only because bare `docpact` is unavailable. The default comparison base is `origin/main`. Override it for unusual stacks with `DOCPACT_BASE_REF=<ref>` or `scripts/docpact-gate.sh --base <ref>`. The gate writes its detailed report to a temporary file so normal pushes do not create `.docpact/runs/` artifacts.
