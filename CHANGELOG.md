# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2024-09-03

Dropped support for Ruby 2.7

### Fixed

- missing `ostruct` dependency in newer Ruby versions

## [1.1.0] - 2022-03-27

### Added

- Basic support for custom version classes
- Rollback functionality
- Track item functionality

### Fixed

- `LoadError` with data source `ActiveRecord`
- `bin/setup` being considered a gem executable

## [1.0.0] - 2022-03-26

Initial release.
