---
title: data Repo Architecture
docType: reference
scope: repo
status: active
authoritative: true
owner: data
language: en
whenToUse:
  - when determining whether a data, schema, stylesheet, or release-note change belongs in this repository
  - when checking source-of-truth boundaries between data, TIDAS, tooling, product UI, and workspace integration
whenToUpdate:
  - when dataset payload ownership changes
  - when bundled schema or stylesheet assets are reorganized
  - when cross-repo ownership boundaries change
checkPaths:
  - AGENTS.md
  - .docpact/config.yaml
  - release.json
  - tiangong_lca_data/**
  - schemas/**
  - stylesheets/**
  - release_notes/**
  - .githooks/pre-push
  - scripts/docpact
  - scripts/docpact-gate.sh
  - scripts/install-git-hooks.sh
lastReviewedAt: 2026-06-01
lastReviewedCommit: 9b9324305515a2d77f2097a016e714802a9f2e66
related:
  - AGENTS.md
  - .docpact/config.yaml
  - docs/agents/repo-validation.md
---

# data Repo Architecture

`tiangong-lca-data` owns checked-in TianGong LCA dataset content and bundled reference assets that ship with the dataset package.

## Owned Surfaces

- `tiangong_lca_data/**` is the checked-in dataset payload and bundled package content.
- `schemas/**` contains schema reference files that travel with the data repository.
- `stylesheets/**` contains transformation or presentation assets that ship with the data repository.
- `release.json` is the machine-readable release version source for automated dataset releases.
- `release_notes/**` records versioned data release notes and release history.
- `README.md` and `wechat.jpg` are human-facing repository context and assets.

## Release Architecture

Dataset releases come from `main` commits that change `release.json`. The publish workflow creates the matching `v<version>` tag when needed, runs the docpact release gate, zips `tiangong_lca_data/**`, and creates a GitHub Release using `release_notes/v<version>.md`.

Manual `v*.*.*` tag pushes and workflow-dispatch runs for existing release tags remain recovery/backfill paths.

## Non-Owner Boundaries

- `tiangong-lca-next` owns application UI and product workflow behavior.
- `tidas` owns TIDAS specification truth.
- `tidas-tools` owns conversion, validation, and export tooling implementation.
- `lca-workspace` owns root integration state and submodule pointer updates.

Do not infer app behavior, TIDAS semantics, conversion logic, or workspace delivery completion from this repository alone.

## Integration Semantics

A merged PR in this repository is repo-complete only. If the dataset snapshot must ship through the workspace, the root workspace must deliberately update the `tiangong-lca-data` submodule pointer after merge.

## Local Docpact Push Gate

This repository has a versioned local `pre-push` hook under `.githooks/pre-push` that delegates to `scripts/docpact-gate.sh`. The gate resolves the CLI through `scripts/docpact`, so local agent shells do not need bare `docpact` on `PATH`. The hook is a local developer guard for docpact config validation and enforced doc-governance linting; ordinary PRs and pushes rely on the local gate; `.github/workflows/ai-doc-lint.yml` is manual-dispatch fallback for remote reproduction.
