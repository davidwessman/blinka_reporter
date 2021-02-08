# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2021-02-08

### Changed

- BREAKING 🚨 - Require setting environment variable `BLINKA_JSON` to any value to generate `blinka_results.json` used for reporting to Blinka.

## [0.2.1] - 2021-02-08

### Changed

- Raise error if configuration to report to Blinka is missing when reporting.

## [0.2.0] - 2021-02-07

### Added

- Adds support for reporting test results in TAP-format.

## [0.1.1] - 2021-02-04

### Changed

- Correct the homepage on rubygems.

## [0.1.0] - 2021-02-03

### Added

- Support for adding tag to report using `BLINKA_TAG` environment variable.

### Removed

- No longer support `BLINKA_BRANCH`, use `BLINKA_TAG` instead.

## [0.0.3] - 2021-02-02

### Added

- Allow supplying which git commit sha to report.

## [0.0.2] - 2021-02-01

### Added

- Debug print for which commit hash was reported.

## [0.0.1] - 2021-01-31

### Added

- Setup LICENSE and CHANGELOG.

### Fixed

- Handle inconsistency in source_location of test result in Minitest for different versions.

[unreleased]: https://github.com/davidwessman/blinka_reporter/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/davidwessman/blinka_reporter/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/davidwessman/blinka_reporter/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.0.3...v0.1.0
[0.0.3]: https://github.com/davidwessman/blinka_reporter/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/davidwessman/blinka_reporter/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/davidwessman/blinka_reporter/releases/tag/v0.0.1
