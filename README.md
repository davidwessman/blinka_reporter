# Blinka reporter

- [What does this gem do?](#what-does-this-gem-do)
- [How do I install the gem?](#how-do-i-install-the-gem)
- [Which ruby testing frameworks are supported?](#which-ruby-testing-frameworks-are-supported)
- [What is Blinka?](#what-is-blinka)
- [How to send report to Blinka?](#how-to-send-report-to-blinka)

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

After the tests have run and the `blinka_report.json` file is populated, run in ruby:

```ruby
require 'blinka_client'
BlinkaClient.new.report
```

## How can I send report in Github Action?

Add a step to your Github Action Workflow after running tests:

```yaml
- name: Report to Blinka
  if: ${{ always() }}
  env:
    BLINKA_TAG: ""
    BLINKA_REPOSITORY: davidwessman/blinka_reporter
    BLINKA_TEAM_ID: ${{ secrets.BLINKA_TEAM_ID }}
    BLINKA_TEAM_SECRET: ${{ secrets.BLINKA_TEAM_SECRET }}
    BLINKA_COMMIT: ${{ github.event.pull_request.head.sha || github.sha }}
  run: |
    bundle exec rake blinka:report
```

`BLINKA_TAG` is optional and can be used to separate different reports, e.g. if using a build matrix.

# License

`blinka-reporter` is licensed under the MIT license, see [LICENSE](LICENSE) for details.
