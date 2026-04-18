# Architecture

## Overview

The product is built as a single-script launcher around the Office Deployment Tool, then packaged into a Windows executable with `ps2exe`.

Core flow:
- package PowerShell launcher as a desktop executable
- embed bootstrap/runtime content in the launcher
- generate ODT configuration at runtime
- invoke `setup.exe` in `/download` or `/configure` mode

## Main Components

### `Start-OfficeLTSC2024-Bundle.ps1`

This is the product core. It is responsible for:
- launcher startup
- theme and dialog behavior
- payload validation
- XML generation
- ODT process invocation
- user app selection
- download fallback flow
- post-install retention behavior

### `configuration.template.xml`

This is the human-readable source template for ODT configuration defaults. It defines:
- source path placeholder
- Office client edition
- channel
- product ID
- language
- default excluded apps

### `setup.exe`

This is the ODT setup bootstrap used by the launcher at runtime. It should be treated as a bundled runtime dependency.

### `build-office-bundle.ps1`

This script packages the PowerShell launcher into:
- `Office 2024 LTSC Setup.exe`

It installs and imports `ps2exe`, sets executable metadata, and produces the deliverable used for distribution.

### `.github/workflows/build-office-bundle.yml`

This workflow provides the supported packaging path in CI. It:
- runs on `windows-latest`
- installs pinned `ps2exe`
- runs the build script
- uploads the packaged executable as an artifact

## Runtime Flow

1. Launcher starts and initializes UI/theme state.
2. Launcher warns about activation requirements.
3. Embedded runtime content is written into a working directory.
4. Payload discovery runs against the launch directory and filesystem roots.
5. If payload is missing, the launcher can generate a download XML and call ODT download mode.
6. The app chooser reflects template-driven exclusions.
7. The launcher writes the final configuration XML.
8. ODT configure mode is executed.
9. Downloaded payload can optionally be retained in the launch directory after success.

## Key Constraints

- architecture is intentionally script-centric
- product logic is mostly concentrated in one file
- payload validation is narrow by design
- ODT is the execution engine; this repo orchestrates rather than replaces it

## Change Guidance

When changing architecture:
- preserve the user-visible install flow unless intentionally redesigning it
- do not casually alter payload validation assumptions without updating product docs
- keep packaging reproducible
- update documentation when product boundaries or runtime contracts change
