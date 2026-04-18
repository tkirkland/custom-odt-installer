# Test Strategy

## Purpose

This repository uses regression-style PowerShell tests to protect key product contracts in the installer workflow.

The goal is not to simulate a full Office installation. The goal is to catch drift in the launcher’s expected behavior and packaging assumptions.

## Current Coverage

The current test suite verifies:
- XML attribute escaping behavior
- bundled-file extraction validation
- build-script bootstrap expectations
- GitHub Actions packaging expectations
- initial warning dialog close-confirmation behavior
- missing-payload download prompt and flow expectations
- post-install payload retention behavior
- product naming consistency

## What The Tests Are Good At

- protecting important behavioral contracts in the launcher script
- detecting accidental changes to packaging workflow assumptions
- keeping naming and distribution behavior stable
- verifying that key user-exit paths remain intentional

## What The Tests Do Not Prove

The current suite does not fully prove:
- that a live Office install succeeds on a target machine
- that all supported app combinations behave correctly in real installations
- that every payload discovery edge case works across all environments
- that Microsoft tooling behavior will remain unchanged outside the repo

## Testing Philosophy

For this repo, prioritize tests that:
- pin business-critical flow decisions
- detect accidental narrowing or broadening of product behavior
- keep build and packaging assumptions explicit
- remain fast enough to run routinely

## Recommended Next Additions

- direct checks for app-selection to `ExcludeApp` generation
- more explicit payload discovery edge-case tests
- checks for documentation-sensitive assumptions when feasible

## Operational Verification

For high-confidence releases, combine regression tests with manual validation:
- build the packaged executable
- exercise payload discovery
- exercise missing-payload download flow
- verify final `setup.exe /configure` handoff in a representative environment

That manual verification is complementary to the automated suite, not a replacement for it.
