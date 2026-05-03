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
lastReviewedAt: 2026-05-03
lastReviewedCommit: c7983661d396c5341acb1428ce77aa2e9c2e6b5e
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
docpact validate-config --root . --strict
docpact lint --root . --base origin/main --head HEAD --mode enforce
```

The repository PR workflow runs the same docpact config validation and PR-shaped lint gate.

## Future Automation

If this repository gains a canonical data validation wrapper later, update this file, `AGENTS.md`, and `.docpact/config.yaml` in the same change.
