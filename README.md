# custom-odt-installer

A custom Microsoft Office LTSC 2024 installer built around the Office Deployment Tool (ODT).

This project packages a Windows Forms launcher that:

- shows an initial activation warning
- lets the user choose which Office apps to install
- generates an ODT configuration file from the embedded template
- runs the embedded `setup.exe` with the generated configuration

The project is intended for environments that already have a prepared Office payload available on local media or in a working directory.

## What This Repo Contains

- [Start-OfficeLTSC2024-Bundle.ps1](Start-OfficeLTSC2024-Bundle.ps1)
  - the main launcher source
  - contains the embedded ODT bootstrap executable and embedded XML template
- [build-office-bundle.ps1](build-office-bundle.ps1)
  - builds the packaged `.exe` using `ps2exe`
- [configuration.template.xml](configuration.template.xml)
  - the human-readable source template that corresponds to the embedded XML configuration
- [tests/Start-OfficeLTSC2024-Bundle.Tests.ps1](tests/Start-OfficeLTSC2024-Bundle.Tests.ps1)
  - regression checks for config escaping, bundled-file extraction validation, build bootstrap behavior, dialog close handling, payload download flow, and package naming
- [.github/workflows/build-office-bundle.yml](.github/workflows/build-office-bundle.yml)
  - GitHub Actions workflow that installs `ps2exe`, builds the launcher, and uploads the packaged `.exe`

## What Is Not Included

The runtime Office payload under `Office/` is intentionally excluded from the public repo.

Why:

- the payload is too large for a practical GitHub repo
- the local payload in this project contains multi-gigabyte stream files
- the launcher is designed to locate Office media at runtime rather than require those files to live in the source repository

The built launcher expects an Office payload directory that looks like this at runtime:

```text
Office/
  Data/
    v64.cab
    <version-folder>/
      stream.x64.en-us.dat
      ...
```

## Runtime Behavior

When the launcher starts, it:

1. shows the initial activation warning dialog
2. if the user closes the initial warning dialog with `X`, it asks for confirmation before exiting
3. decodes the embedded ODT bootstrap files into a temp working directory
4. validates that extraction succeeded
5. searches for an existing Office payload in the launch directory and mounted filesystem roots
6. if no payload is found, prompts the user to download Office files into the temp working directory
7. if the user closes the download prompt with `X`, it asks for confirmation before exiting
8. after a valid payload is available, shows the app-selection UI
9. writes a temporary ODT configuration file
10. launches `setup.exe /configure`
11. if the payload was downloaded into temp and install succeeds, asks whether to keep the downloaded Office files by moving `temp\Office` to `.\Office`

### Payload Discovery

The launcher checks for a valid payload by probing:

1. the current launch directory
2. mounted filesystem roots

A valid payload currently means:

- `Office\Data\v64.cab` exists
- a versioned `Office\Data\<version>` directory exists
- that version directory contains `stream.x64.en-us.dat`

This project is therefore aimed at 64-bit English Office LTSC 2024 media.

## Default Installed Apps

The embedded configuration currently targets:

- `ProPlus2024Volume`
- channel `PerpetualVL2024`
- language `en-us`

The template excludes these apps by default:

- `Lync`
- `PowerPoint`
- `Publisher`

The launcher then lets the end user enable or disable supported apps interactively before installation.

## Local Build

Build requirements:

- Windows PowerShell or PowerShell on Windows
- internet access to PowerShell Gallery on first build

Build command:

```powershell
./build-office-bundle.ps1
```

The build script will:

- install `ps2exe` automatically if `Invoke-ps2exe` is not available
- import `ps2exe`
- build `Office 2024 LTSC Setup.exe`

## Tests

Run the regression checks with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Start-OfficeLTSC2024-Bundle.Tests.ps1
```

The tests currently verify:

- XML attribute escaping for payload paths
- bundled-file extraction validation
- build bootstrap behavior for `ps2exe`
- GitHub Actions workflow coverage for build artifact generation
- initial warning dialog `X` close confirmation behavior
- missing-payload download prompt and temp download/install flow
- optional post-install retention of downloaded Office files
- package/UI naming for `Office 2024 LTSC Setup`

## GitHub Actions

The workflow at `.github/workflows/build-office-bundle.yml`:

- runs on `windows-latest`
- installs `ps2exe`
- runs `build-office-bundle.ps1`
- uploads `Office 2024 LTSC Setup.exe` as a workflow artifact

This keeps the repo small while still allowing reproducible CI builds.

## Important Notes

- The packaged `.exe` is ignored in git and should be treated as a build artifact.
- The packaged output name is `Office 2024 LTSC Setup.exe`.
- The Office payload is not included in this public repo.
- The launcher embeds its own ODT bootstrap executable and configuration template, but it still needs the Office installation media at runtime.
- The current payload validation is intentionally narrow and expects the media layout described above.

## Suggested Repo Workflow

For source changes:

1. update the PowerShell source
2. run the test script
3. rebuild locally if you need to test the packaged `.exe`
4. push changes
5. use the GitHub Actions artifact for CI-built packages if needed
