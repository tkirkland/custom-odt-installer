# Decisions

## Decision Log

This file records product and architecture choices that shape the repository.

## Current Decisions

### Narrow Product Scope

Decision:
- keep the product focused on a single approved Office LTSC 2024 installer workflow

Reason:
- reduces operational ambiguity
- keeps UX simple
- lowers maintenance burden

Trade-off:
- less flexible than a generalized Office deployment tool

### Script-Centric Launcher

Decision:
- use a PowerShell + WinForms launcher as the product core

Reason:
- aligns with the runtime environment
- fits ODT orchestration needs
- packages cleanly with `ps2exe`

Trade-off:
- large script files are harder to maintain than more modular application structures

### ODT As Execution Engine

Decision:
- rely on Microsoft’s Office Deployment Tool for download and configure operations

Reason:
- avoids reimplementing Office deployment logic
- keeps behavior aligned with Microsoft tooling

Trade-off:
- runtime success depends on external tooling behavior and payload validity

### Local Payload First

Decision:
- search for existing Office payloads before downloading new media

Reason:
- reduces unnecessary download time
- supports offline or semi-offline deployment scenarios

Trade-off:
- payload validation rules must stay accurate and intentionally narrow

### Current Payload Constraint

Decision:
- validate against a 64-bit `en-us` LTSC-style payload layout

Reason:
- keeps the current product predictable
- matches the intended deployment scenario

Trade-off:
- excludes broader locale and architecture support

### Artifact-First Distribution

Decision:
- distribute the packaged executable rather than asking end users to run scripts manually

Reason:
- simplifies end-user execution
- improves consistency
- supports branded delivery

Trade-off:
- packaging becomes part of the product surface and must remain reproducible

## Decision Rule For Future Work

Any change that affects SKU coverage, language support, architecture support, distribution model, or installer complexity should be treated as a product decision and documented here.
