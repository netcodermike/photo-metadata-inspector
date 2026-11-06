# Validation

Authoring date: November 6, 2026. Host: Windows. Target: macOS 13+.

## Local result

macOS/Swift unavailable on authoring host. CI builds and inspects a real generated PNG; GUI acceptance remains manual.

## Reproducible checks

The GitHub Actions workflow builds/runs the following on `macos-latest`:

```sh
swift build -c release
swift run -c release PhotoMetadata --self-test
```

## Manual acceptance

Open multiple image types, inspect nested properties, switch files, submit/clear filters, test an unreadable image, and inspect full exported text.

A workflow file is not evidence of a passing run. Observed CI run links and source commits are recorded after publication. Native GUI, sound, sleep/resume, and platform permissions require direct target-platform acceptance even when model tests pass.

## Observed CI result

Passed: [target-platform build/check](https://github.com/netcodermike/photo-metadata-inspector/actions/runs/42204155602). Source commit: `e41724753a5a5fb8872257a787d4d517f5677300`. Later documentation-only changes do not alter the tested implementation. The reproducible commands above identify test scope; native GUI/audio/permissions are not implied by compilation.
