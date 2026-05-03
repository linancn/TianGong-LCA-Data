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
  - tiangong_lca_data/**
  - schemas/**
  - stylesheets/**
  - release_notes/**
lastReviewedAt: 2026-05-03
lastReviewedCommit: c7983661d396c5341acb1428ce77aa2e9c2e6b5e
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
- `release_notes/**` records versioned data release notes and release history.
- `README.md` and `wechat.jpg` are human-facing repository context and assets.

## Non-Owner Boundaries

- `tiangong-lca-next` owns application UI and product workflow behavior.
- `tidas` owns TIDAS specification truth.
- `tidas-tools` owns conversion, validation, and export tooling implementation.
- `lca-workspace` owns root integration state and submodule pointer updates.

Do not infer app behavior, TIDAS semantics, conversion logic, or workspace delivery completion from this repository alone.

## Integration Semantics

A merged PR in this repository is repo-complete only. If the dataset snapshot must ship through the workspace, the root workspace must deliberately update the `tiangong-lca-data` submodule pointer after merge.
