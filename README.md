# Blinka reporter

## What does this gem do?

Generate a test results report for Minitest or interpret a junit-report from Rspec.
These results can then be [reported](#how-to-send-report-to-blinka) to [Blinka](#what-is-blinka) which posts your test results directly in your Github Pull Requests.

## How do I install the gem?

Run

```sh
gem install blinka-reporter
```

or add to your Gemfile

```ruby
gem 'blinka-reporter', '~> 0.7.0'
```

## Which ruby testing frameworks are supported?

- Minitest
- Rspec

> Please reach out for other frameworks or create a reporter yourself.

## What is Blinka?

Blinka is a web service developed by [@davidwessman](https://github.com/davidwessman) to store test results from CI and report interesting results back to Github, right in the pull request.

## How to generate test report in the right format?

### Minitest

```sh
BLINKA_PATH=./tests.json bundle exec rails test
```

Output as `./tests.json`.

### Rspec

Make sure [rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter) is installed.

```sh
bundle exec rspec --formatter RspecJunitFormatter --out ./rspec.xml
```

## How to send report to Blinka?

1. Output your test results as described [above](#how-to-generate-test-report-in-the-right-format).
1. `bundle exec blinka_reporter --path {./blinka_results.json,./rspec.xml} --blinka --team-id <BLINKA_TEAM_ID> --team-secret <BLINKA_TEAM_SECRET> --repository davidwessman/blinka_reporter`

## How can I send report in Github Action?

Add a step to your Github Action Workflow after running tests:

```yaml
- name: Minitest
  env:
    BLINKA_JSON: true
  run: bundle exec rake test

- name: Report minitest to Blinka
  run: |
    bundle exec blinka_reporter \
      --path ./blinka_results.json \
      --blinka \
      --commit ${{ github.event.pull_request.head.sha || github.sha }} \
      --repository davidwessman/blinka_reporter \
      --team-id ${{ secrets.BLINKA_TEAM_ID }} \
      --team-secret ${{ secrets.BLINKA_TEAM_SECRET }}
```

```yaml
- name: Rspec
  run: bundle exec rspec --formatter RspecJunitFormatter --out ./rspec.xml
- name: Report minitest to Blinka
  run: |
    bundle exec blinka_reporter \
      --path ./rspec.xml \
      --blinka \
      --commit ${{ github.event.pull_request.head.sha || github.sha }} \
      --repository davidwessman/blinka_reporter \
      --team-id ${{ secrets.BLINKA_TEAM_ID }} \
      --team-secret ${{ secrets.BLINKA_TEAM_SECRET }}
```

`--tag` is optional and can be used to separate different reports, for example when using a build matrix.

## How to make multiple test runs into one report?

For example when running tests in parallel you might need to run system tests separately.
Output the test results to different paths with `BLINKA_PATH`.

```yaml
- name: System tests
  env:
    BLINKA_PATH: ./system_tests.json
    PARALLEL_WORKERS: 1
  run: bundle exec rails test:system

- name: Tests
  env:
    BLINKA_JSON: ./tests.json
  run: bundle exec rails test

- name: Report to Blinka
  run: |
    bundle exec blinka_reporter \
      --path ./system_tests.json \
      --path ./tests.json \
      --blinka \
      --commit ${{ github.event.pull_request.head.sha || github.sha }} \
      --repository davidwessman/blinka_reporter \
      --team-id ${{ secrets.BLINKA_TEAM_ID }} \
      --team-secret ${{ secrets.BLINKA_TEAM_SECRET }}
```

## How can I report tests in TAP-format?

TAP-format ([Test anything protocol](https://testanything.org)) is used to parse tests results on for example Heroku CI.

Generate your test results like [above](#how-to-generate-test-report-in-the-right-format),
replace `<path>` with your json or xml file.

```sh
bundle exec blinka_reporter --tap --path <path>

TAP version 13
1..14
ok 1 - test/test_blinka_minitest.rb - test_message
ok 2 - test/test_blinka_minitest.rb - test_image
ok 3 - test/test_blinka_minitest.rb - test_image_no_file
ok 4 - test/test_blinka_minitest.rb - test_report_with_image
ok 5 - test/test_blinka_minitest.rb - test_line
ok 6 - test/test_blinka_minitest.rb - test_backtrace
ok 7 - test/test_blinka_minitest.rb - test_line_no_failure
ok 8 - test/test_blinka_minitest.rb - test_report
ok 9 - test/test_blinka_minitest.rb - test_backtrace_no_failure
ok 10 - test/test_blinka_minitest.rb - test_kind_no_folder
ok 11 - test/test_blinka_minitest.rb - test_result
ok 12 - test/test_blinka_minitest.rb - test_kind
ok 13 - test/test_blinka_minitest.rb - test_message_no_failure
ok 14 - test/test_blinka_minitest.rb - test_source_location
```

# Development

## Release new version

1. Update version in [`CHANGELOG.md`](./CHANGELOG.md) and include changes.
1. Update version in [`lib/blinka_reporter/version.rb`](./lib/blinka_reporter/version.rb).
1. Create pull request and merge to default branch.
1. `gem build blinka_reporter.gemspec` (make sure it matches the bumped version).
1. `gem push blinka-reporter-{version}.gem` (had to use `--otp` because I could not enter it when prompted).
1. Create a release and tag on Github for history.

# License

`blinka-reporter` is licensed under the MIT license, see [LICENSE](LICENSE) for details.
