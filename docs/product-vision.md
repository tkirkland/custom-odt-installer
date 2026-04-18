# Product Vision

## Summary

`office-installer` exists to provide a controlled, branded way to install Microsoft Office LTSC 2024 in managed Windows environments without asking end users to work directly with the Office Deployment Tool.

The product packages a guided launcher around ODT so that installation behavior is repeatable, constrained, and easier for non-technical users to execute correctly.

## Problem

Raw ODT-based installs are operationally flexible but unfriendly:
- they require configuration authoring or prebuilt XML
- they expose more deployment complexity than most end users should see
- they make it easy to run the wrong command or use the wrong payload location
- they do not provide a branded, guided install experience

This project solves that by wrapping ODT in a single executable with a narrow, opinionated workflow.

## Intended Users

- internal IT operators
- managed-environment users following organization-specific install guidance
- teams distributing approved Office LTSC 2024 media and wanting a simpler launcher

This is not currently positioned as a general-purpose public Office installer.

## Product Goals

- Provide a single executable entry point for Office LTSC 2024 installation.
- Warn users about activation expectations before install begins.
- Detect usable Office payloads automatically when available.
- Download payloads when local media is missing.
- Let users choose which supported Office apps to include.
- Keep packaging repeatable and easy to reproduce.

## Non-Goals

- Support every Office SKU, language, or channel.
- Act as a general Office deployment management platform.
- Replace enterprise fleet tooling such as centralized endpoint management.
- Add telemetry, account systems, or cloud control planes.

## Current Positioning

The current product should be treated as a reliable internal deployment utility with a polished launcher, not as a broad installer platform.

## Success Criteria

The product is successful when:
- a user can start from the packaged executable and complete installation without editing XML manually
- a valid local payload is discovered automatically when present
- missing payloads can be downloaded and then installed in the same guided flow
- app selection remains understandable and constrained
- packaging and regression validation remain repeatable

## Strategic Fork

Future work should be evaluated against one explicit choice:

1. Keep the product narrow and highly reliable for one approved deployment scenario.
2. Expand the product into a configurable Office deployment utility with more SKU, language, and policy support.

That choice should be made intentionally. The current repository favors option 1.
