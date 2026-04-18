# Product State

## Current State

The repository currently ships a PowerShell + WinForms launcher that wraps the Office Deployment Tool for Office LTSC 2024 installation.

Primary entry points:
- `Start-OfficeLTSC2024-Bundle.ps1`
- `build-office-bundle.ps1`
- `configuration.template.xml`

Primary packaged output:
- `Office 2024 LTSC Setup.exe`

## User Flow

At runtime, the product currently:

1. shows an activation warning dialog
2. confirms before exiting when the warning dialog is closed without proceeding
3. extracts bundled runtime files into a working directory
4. looks for a valid Office payload in the launch directory
5. searches filesystem roots for a valid Office payload if not found locally
6. prompts the user to download Office files if no payload is found
7. validates the downloaded payload
8. shows an app-selection interface
9. generates a temporary ODT configuration file
10. runs `setup.exe /configure`
11. optionally offers to retain downloaded Office files in the launch directory after successful install

## Product Assumptions

The current product state is intentionally constrained:
- Office LTSC 2024 oriented
- 64-bit payload expectation
- `en-us` payload validation expectation
- ODT-driven install and download flow
- local media first, download second

## Supported App Selection Surface

The launcher currently exposes choices for:
- Word
- Excel
- Outlook
- PowerPoint
- OneNote
- Access
- Publisher
- Skype for Business

Default exclusions are inherited from the template and then made user-adjustable in the launcher.

## Distribution State

The supported distribution path is a packaged executable produced by GitHub Actions or the local build helper script.

The repository is source-first:
- source files are tracked
- the packaged installer is treated as a build artifact
- the Office payload directory is ignored by git

## Quality State

The repository has regression coverage for:
- XML attribute escaping
- bundled-file extraction validation
- build/bootstrap expectations
- workflow artifact expectations
- initial close-confirmation behavior
- missing-payload download flow
- post-install payload retention flow
- product naming consistency

This is good coverage for behavioral contracts, but it is not the same as full end-to-end installation validation against live Office installs.

## Current Risks

- product flexibility is limited by hard-coded assumptions
- the launcher core is concentrated in a large script with embedded bootstrap content
- live install behavior still depends on Microsoft tooling and payload correctness outside normal unit-style regression testing
- documentation can drift unless updated alongside behavior changes

## Recommended Operating Posture

Treat the current product as a narrow, reliable internal utility. Expand scope only through explicit product decisions.
