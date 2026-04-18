# Roadmap

## Current Direction

The current roadmap should prioritize reliability, clarity, and maintainability over feature expansion.

## Near-Term Priorities

### 1. Documentation Stability

- keep product docs aligned with code behavior
- require doc updates when runtime flow or scope changes
- make future repo reviews faster and more consistent

### 2. Installer Reliability

- preserve clean exit and recovery paths
- keep payload discovery and download fallback predictable
- avoid silent behavior changes in the launcher flow

### 3. Packaging Reproducibility

- keep build metadata and output naming stable
- keep GitHub Actions packaging trustworthy
- preserve pinned packaging dependencies where appropriate

### 4. Test Coverage Improvements

- add more focused tests around app-selection generation
- add more focused tests around payload discovery edge cases
- document gaps that cannot be covered with current regression checks

## Mid-Term Options

These are options, not commitments:
- support additional approved payload layouts
- support additional locales
- improve script maintainability by extracting non-embedded logic into clearer units
- add stronger validation/reporting around payload mismatch cases

## Not Planned By Default

Unless explicitly requested, the roadmap does not assume:
- public consumer distribution
- broad SKU/channel matrix support
- telemetry or analytics systems
- cloud-managed deployment orchestration
- turning this repo into a general Office admin platform

## Trigger For Replanning

Revisit the roadmap when one of these changes:
- a new Office product/channel must be supported
- multi-language support becomes required
- installer UX must change materially
- packaging/distribution requirements change
- the single-script architecture becomes a maintenance bottleneck
