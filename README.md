# Photo Metadata Inspector

Browse image metadata locally, filter property paths, switch between selected files, and export a full text report.

[![Build and verify](https://github.com/netcodermike/photo-metadata-inspector/actions/workflows/verify.yml/badge.svg)](https://github.com/netcodermike/photo-metadata-inspector/actions/workflows/verify.yml)

**Language:** Swift · **Platform:** macOS 13+ · **App type:** Native Mac photo inspection app

First-release learning implementation, with explicit scope below. This is one independently runnable app, not a placeholder in a combined repository.

## Features

- Multi-image file picker, up to 100 files per selection.
- Nested property flattening into searchable dotted paths.
- Image container count and read-only metadata display.
- Explicit full-report export, with a reminder about sensitive metadata.

## Requirements

macOS 13+ with Xcode command-line tools supporting Swift 5.9+. Uses AppKit, ImageIO, CoreGraphics, and UniformTypeIdentifiers; no external packages.

## Quick start

```sh
git clone https://github.com/netcodermike/photo-metadata-inspector.git
cd photo-metadata-inspector
swift build
swift run PhotoMetadata
# Run from Xcode by opening Package.swift if preferred.
```

Commands run from the repository root. Lines marked for a particular operating system apply only there. Language tools are prerequisites, not installed by the app. Close desktop windows normally; terminal/server apps stop with Ctrl+C unless their usage notes say otherwise.

## Example workflow

Open a synthetic PNG and a photo with EXIF. Select each filename, type Pixel or ISO and press Return, then export a full report. Confirm export contains all metadata even when the display filter is active.

## Architecture, configuration, and data

`App.swift` implements read-only CGImageSource inspection, recursive property flattening, and an AppKit window. Keys are sorted, dictionary nesting uses dots, and array positions use brackets. The first image’s properties are displayed alongside container image count. Filtering is applied when the search field action is submitted (Return). Reports remain in memory until an explicit text export; original files are never modified. The main entry/delegate run on Swift’s main actor. --self-test creates a real PNG with CoreGraphics/ImageIO and checks metadata extraction plus nested flattening without opening the app UI.

## Verification

Build with the quick-start command where needed, then run:

```sh
swift run PhotoMetadata --self-test
```

Manual acceptance: Open multiple image types, inspect nested properties, switch files, submit/clear filters, test an unreadable image, and inspect full exported text.

See [validation record](docs/VALIDATION.md) for observed checks and their limits. CI results verify only what the workflow runs; they do not establish native GUI correctness or production readiness.

## Limitations and next steps

First image/frame only; no thumbnail preview, metadata editing/stripping, comparisons, batch export, cloud service, or directory scan. File reading occurs synchronously and large/unusual images can make the UI unresponsive. Unsupported formats produce per-file errors. A selection over 100 files is truncated. Metadata may include GPS, device identifiers, and personal details; full-report export includes them even if filtered from view.

## Troubleshooting

Install Xcode command-line tools if Swift/SDKs are missing. The app requires a Mac graphical session; --self-test does not. Press Return after typing a filter. Missing EXIF/GPS may simply mean the image has none. Export writes the full selected report to the chosen file and may replace it.

## Source map

- `Package.swift`
- `Sources/PhotoMetadata/App.swift`

## Development and license

Read [contributing](CONTRIBUTING.md) before changing the app, and [security/privacy](SECURITY.md) before supplying private data. Use synthetic fixtures for tests. No telemetry, paid API key, or account is required by the app itself. Dependencies, when present, are stated in Requirements.

[MIT license](LICENSE), copyright 2026 netcodermike.
