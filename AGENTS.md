---
title: data AI Working Guide
docType: contract
scope: repo
status: active
authoritative: true
owner: data
language: en
whenToUse:
  - when a task may change checked-in TianGong LCA dataset content, bundled schemas, bundled stylesheets, or release-note content
  - when routing work from the workspace root into tiangong-lca-data
  - when deciding whether a change belongs here, in tidas-tools, in tiangong-lca-next-docs, or in lca-workspace
whenToUpdate:
  - when repo ownership or source-of-truth boundaries change
  - when the repo gains a canonical validation workflow or packaging rule
  - when repo-local docpact governance or source docs change
checkPaths:
  - AGENTS.md
  - README.md
  - .docpact/config.yaml
  - docs/agents/**
  - schemas/**
  - stylesheets/**
  - release_notes/**
  - tiangong_lca_data/**
  - wechat.jpg
  - .githooks/**
  - scripts/docpact
  - scripts/docpact-gate.sh
  - scripts/install-git-hooks.sh
lastReviewedAt: 2026-05-08
lastReviewedCommit: 7268905de463f749fabe020317c573c7f061c5b5
related:
  - .docpact/config.yaml
  - docs/agents/repo-architecture.md
  - docs/agents/repo-validation.md
  - README.md
---

# AGENTS.md — data AI Working Guide

`tiangong-lca-data` owns checked-in TianGong LCA dataset content plus bundled reference assets that ship with the dataset package. Start here when the task may change data files, schema assets, or release-note content.

## AI Load Order

Load docs in this order:

1. `AGENTS.md`
2. `.docpact/config.yaml`
3. `docs/agents/repo-architecture.md`
4. `docs/agents/repo-validation.md`
5. `README.md` only when you need human-facing product or download context

Do not start by inferring ownership from the workspace root or from downstream consumers.

## Repo Ownership

This repo owns:

- `tiangong_lca_data/**` for checked-in dataset payloads and bundled data-package content
- `schemas/**` for bundled schema reference files that travel with the dataset repository
- `stylesheets/**` for bundled transformation or presentation assets that ship with the data package
- `release_notes/**` for versioned data release notes
- `README.md` and `wechat.jpg` for human-facing repository context

This repo does not own:

- application UI, workflow behavior, or frontend routing
- TIDAS specification truth, conversion logic, or export tooling implementation
- root workspace integration and submodule pointer updates

Route those tasks to:

- `tiangong-lca-next` for frontend product behavior
- `tidas` for TIDAS specification truth
- `tidas-tools` for conversion, validation, and export tooling logic
- `lca-workspace` for root integration after merge

## Branch Facts

- GitHub default branch: `main`
- True daily trunk: `main`
- Routine branch base: `main`
- Routine PR base: `main`

## Runtime Facts

- This repo is content-oriented; it does not currently define one canonical checked-in validation wrapper like `npm run lint` or `pytest`
- Validation is therefore change-scoped: review touched data assets directly and verify structural expectations against bundled schema/style assets when relevant
- Repo-local documentation governance is encoded in `.docpact/config.yaml` and enforced locally by the pre-push docpact gate; `.github/workflows/ai-doc-lint.yml` is manual-dispatch fallback
- For documentation-governance changes, run `scripts/docpact validate-config --root . --strict` and `scripts/docpact lint --root . --base origin/main --head HEAD --mode enforce`
- If future automation is added, document it in `AGENTS.md`, `.docpact/config.yaml`, and `docs/agents/repo-validation.md` in the same change

## Hard Boundaries

- Do not invent app behavior, API behavior, or solver semantics in this repo.
- Do not move dataset-package ownership into `tidas`, `tidas-tools`, or `tiangong-lca-next`.
- Do not treat a merged child PR here as workspace-delivery complete if the root repo still needs a submodule bump.

## Workspace Integration

A merged PR in `tiangong-lca-data` is repo-complete, not delivery-complete.

If the data change must ship through the workspace:

1. merge the child PR into `tiangong-lca-data`
2. update the `lca-workspace` submodule pointer deliberately
3. run any later workspace-level validation that depends on the new data snapshot

## Local Docpact Push Gate

Install the versioned local hook once per checkout:

```bash
./scripts/install-git-hooks.sh
```

The `pre-push` hook runs `scripts/docpact-gate.sh`, which delegates CLI lookup to `scripts/docpact` and performs strict config validation plus enforced lint before the push leaves the machine. The wrapper checks `DOCPACT_BIN`, Cargo install locations, Homebrew install locations, and then `PATH`, so local agent shells should not fail only because bare `docpact` is unavailable. The default comparison base is `origin/main`. Override it for unusual stacks with `DOCPACT_BASE_REF=<ref>` or `scripts/docpact-gate.sh --base <ref>`. The gate writes its detailed report to a temporary file so normal pushes do not create `.docpact/runs/` artifacts.
