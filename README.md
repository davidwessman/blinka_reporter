# Blinka reporter

- [What does this gem do?](#what-does-this-gem-do)
- [How do I install the gem?](#how-do-i-install-the-gem)
- [Which ruby testing frameworks are supported?](#which-ruby-testing-frameworks-are-supported)
- [What is Blinka?](#what-is-blinka)
- [How to send report to Blinka?](#how-to-send-report-to-blinka)
- [How can I report tests in TAP-format?](#how-can-i-report-tests-in-tap-format)

## What does this gem do?

It connects to [supported ruby testing frameworks](#which-ruby-testing-frameworks-are-supported) and outputs a report of all passing, failing and skipped tests into a json-format. This format can be used to report test results using the [ruby client](#how-to-send-report-to-blinka) to [Blinka](#what-is-blinka).

## How do I install the gem?

Run

```sh
gem install blinka-reporter
```

or add to your Gemfile

```ruby
gem 'blinka-repoter', '~> 0.1'
```

## Which ruby testing frameworks are supported?

- Minitest

> Please reach out for other frameworks or create a reporter yourself.

## What is Blinka?

Blinka is a web service developed by [@davidwessman](https://github.com/davidwessman) to store test results from CI and report interesting results back to Github, right in the pull request.

## How to send report to Blinka?

After the tests have run with environment variable `BLINKA_JSON=true` and the `blinka_report.json` file is populated, run in ruby:

```ruby
require 'blinka_client'
BlinkaClient.new.report
```

## How can I send report in Github Action?

Add a step to your Github Action Workflow after running tests:

```yaml
- name: Run tests
  env:
    BLINKA_JSON: true
  run: bundle exec rake test

- name: Report to Blinka
  if: ${{ always() }}
  env:
    BLINKA_COMMIT: ${{ github.event.pull_request.head.sha || github.sha }}
    BLINKA_REPOSITORY: davidwessman/blinka_reporter
    BLINKA_TAG: ""
    BLINKA_TEAM_ID: ${{ secrets.BLINKA_TEAM_ID }}
    BLINKA_TEAM_SECRET: ${{ secrets.BLINKA_TEAM_SECRET }}
  run: bundle exec rake blinka:report
```

`BLINKA_TAG` is optional and can be used to separate different reports, e.g. if using a build matrix.

## How can I report tests in TAP-format?

TAP-format ([Test anything protocol](https://testanything.org)) is used to parse tests results on for example Heroku CI.

Set `BLINKA_TAP` environment variable to any value to get a report:

```sh
$ BLINKA_TAP=true rake
Run options: --seed 33934

# Running:

..............

Finished in 0.002069s, 6766.5538 runs/s, 9666.5054 assertions/s.

14 runs, 20 assertions, 0 failures, 0 errors, 0 skips

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

It should format tests as TAP-format, it can be combined with `BLINKA_JSON=true` to still create the json-report which can be sent to Blinka.

# License

`blinka-reporter` is licensed under the MIT license, see [LICENSE](LICENSE) for details.
