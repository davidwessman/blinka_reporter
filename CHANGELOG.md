# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.1] - 2023-02-19

- Handles empty test results.

## [0.7.0] - 2022-03-06

- Support multiple `--path` calls to combine results from multiple files.
- Replaces `BLINKA_JSON` and `BLINKA_APPEND` with `BLINKA_PATH`.
- Adds all reporter options as CLI-options instead of using environment variables. -`BLINKA_REPOSITORY` => `--repository`

## [0.6.1] - 2022-02-27

- Rspec
  - Improve handling of newlines in backtrace
  - Adds more testing
  - Handles multiple screenshot tags

## [0.6.0] - 2022-02-20

- Adds support for Rspec.
- Remove support for `BLINKA_REPORT`, instead use `bundle exec blinka-reporter --blinka` for reporting.
- Remove `BLINKA_TAP` and replace with `bundle exec blinka-reporter --tap`.
- Restructure gem internals.
- Support Rspec screenshots.

## [0.5.2] - 2022-02-01

- Require MFA for pushing to [Rubygems](https://guides.rubygems.org/mfa-requirement-opt-in/)

## [0.5.1] - 2022-02-01

- Look for screenshots in `Capybara.save_path` to allow different output folders for screenshots.
  - For example a Rails application can be configured with `Capybara.save_path = ENV.fetch('CAPYBARA_ARTIFACTS', './tmp/capybara')` which can then be overriden in CI.

## [0.5.0] - 2022-01-21

### Added

- `BLINKA_APPEND` allows multiple test-runs to be appended to the same JSON-file.

## [0.4.0] - 2021-03-27

### Changed

- Change tempus of failing results from `failed` to `fail`.

## [0.3.6] - 2021-03-25

### Changed

- Removes dependency on mimemagic.
- Only allow images of `jpeg` or `png` format, handles their mime-types by extension.

## [0.3.5] - 2021-03-11

### Changed

- Move commit and tag to JSON-report instead of setting in the reporting client.
  This allows the report to be made by a general script instead of in the test environment. In preparation of supporting Github Actions without access to secrets.

## [0.3.4] - 2021-02-24

### Changed

- Reported test cases now include the line in the file where they are defined, previously the line number was connected to the backtrace.

## [0.3.3] - 2021-02-13

### Added

- Use `HEROKU_TEST_RUN_COMMIT_VERSION` defined on Heroku CI when reporting test results to Blinka.

## [0.3.2] - 2021-02-12

### Fixed

- Allow to report with `BLINKA_REPORT` while using in tests `WebMock`.

## [0.3.1] - 2021-02-12

### Added

- Setting `BLINKA_REPORT` with credentials allow report to be sent to Blinka directly at the end of the test run.

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

[unreleased]: https://github.com/davidwessman/blinka_reporter/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/davidwessman/blinka_reporter/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.5.2...v0.6.0
[0.5.2]: https://github.com/davidwessman/blinka_reporter/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/davidwessman/blinka_reporter/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.3.6...v0.4.0
[0.3.6]: https://github.com/davidwessman/blinka_reporter/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/davidwessman/blinka_reporter/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/davidwessman/blinka_reporter/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/davidwessman/blinka_reporter/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/davidwessman/blinka_reporter/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/davidwessman/blinka_reporter/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/davidwessman/blinka_reporter/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/davidwessman/blinka_reporter/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/davidwessman/blinka_reporter/compare/v0.0.3...v0.1.0
[0.0.3]: https://github.com/davidwessman/blinka_reporter/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/davidwessman/blinka_reporter/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/davidwessman/blinka_reporter/releases/tag/v0.0.1
