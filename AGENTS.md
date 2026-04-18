# Agent Guidance

Read these files before making product-level changes, reviews, or roadmap recommendations:

1. `README.md`
2. `docs/product-vision.md`
3. `docs/product-state.md`
4. `docs/architecture.md`
5. `docs/decisions.md`
6. `docs/roadmap.md`
7. `docs/test-strategy.md`

## Product Boundary

This repository is a focused Office LTSC 2024 installer wrapper for managed Windows environments.

The current product is intentionally narrow:
- single branded installer: `Office 2024 LTSC Setup.exe`
- PowerShell + WinForms launcher
- Office Deployment Tool orchestration
- local payload discovery with download fallback
- current assumptions centered on 64-bit `en-us` Office LTSC 2024 media

Do not broaden the product scope implicitly during implementation or review. If work would expand the product into a general Office deployment platform, call that out explicitly as a product decision.

## Repo Rules

- Treat `Start-OfficeLTSC2024-Bundle.ps1` as the product core. Understand existing flow before modifying it.
- Treat the embedded bootstrap content and bundled `setup.exe` as sensitive runtime inputs. Do not replace or restructure them casually.
- Keep `README.md` concise and user-facing. Put durable product context in `docs/`.
- When behavior, scope, or constraints change, update the relevant file in `docs/` in the same change.
- Prefer preserving the current internal-tooling posture unless the user explicitly requests broader distribution or configurability.

## Review Focus

When reviewing this repository, prioritize:
- install-flow correctness
- payload validation assumptions
- user-facing exit and recovery paths
- packaging reproducibility
- documentation drift between code and `docs/`
