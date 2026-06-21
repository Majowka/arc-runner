# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Conventional Commits](https://www.conventionalcommits.org/).

## [Unreleased]

## [0.0.1] - 2026-06-20

### Added

- **feat (PR #9)**: Initialised aidevops and added automation workflow callers.
- **feat (PR #1)**: Installed gh CLI, jq, and python3 in runner image.
- **feat (no PR — direct commit)**: Added buildx wrapper for org-wide registry mirror config injection.

### Changed

- **chore (PR #20)**: Resynced 4 GitHub Actions workflow callers to canonical aidevops reusable-workflow pattern (GH#20649 + GH#20727):
  - `.github/workflows/issue-sync.yml` — DRIFTED/CALLER → CURRENT/CALLER
  - `.github/workflows/review-bot-gate.yml` — DRIFTED/CALLER → CURRENT/CALLER
  - `.github/workflows/maintainer-gate.yml` — DRIFTED/CALLER → CURRENT/CALLER
  - `.github/workflows/loc-badge.yml` — DRIFTED/CALLER → CURRENT/CALLER
  - All callers now delegate logic to the aidevops reusable workflow, eliminating drift.
- **chore (PR #18)**: Updated `actions/checkout` to v7.

### Fixed

- **fix (PR #17)**: Updated `maintainer-gate.yml` SHA pin to self-hosted runner default.
