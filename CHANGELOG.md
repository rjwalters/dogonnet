# Changelog

All notable changes to doggonet will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- AI Agent Support with comprehensive guides
- AGENT_GUIDE.md - Complete guide for LLMs to create dashboards
- COOKBOOK.md - Copy-paste recipes for common patterns
- Golden Signals dashboard example
- Metric-to-widget mapping guide
- Dashboard templates (Service Health, Infrastructure, Business, Golden Signals, RED)
- 20+ new tests (coverage: 48.92% → 73.74%)
- Full test coverage for client and utils modules

### Changed
- README.md now highlights AI/LLM-friendliness
- Examples README with better descriptions
- Documentation reorganized for AI agents vs developers

### Fixed
- Improved test coverage across all modules
- All linting issues resolved

## [0.1.0] - 2024-11-05

### Added
- Initial alpha release
- **100% widget coverage** - All 38 Datadog widget types supported
  - Core visualization: timeseries, queryValue, toplist, heatmap, change, distribution, table, scatterplot, treemap, barChart, wildcard
  - Charts: pieChart, geomap
  - Infrastructure: hostmap, serviceMap, serviceSummary, topologyMap
  - Monitoring: alertGraph, alertValue, checkStatus, monitorSummary, slo, runWorkflow
  - Events/logs: eventStream, eventTimeline, logStream, list
  - Decoration: note, freeText, image, iframe
  - Organization: group, powerpack, splitGraph
  - Analytics: funnel, sankey, retention
  - Profiling: profilingFlameGraph

- **Jsonnet Library** (`src/doggonet/lib/`)
  - widgets.libsonnet - All 38 widget types
  - layouts.libsonnet - Grid and ordered layouts with helpers
  - presets.libsonnet - Pre-configured common patterns
  - main.libsonnet - Unified import

- **Python Client** (`src/doggonet/client/`)
  - DatadogDashboardClient - Full CRUD operations
  - Authentication with DD_API_KEY, DD_APP_KEY, DD_SITE
  - Dashboard list, create, update, delete, exists
  - Metrics and tags operations

- **CLI Tools** (`src/doggonet/cli/`)
  - `doggonet push` - Upload dashboard to Datadog
  - `doggonet fetch` - Download dashboard from Datadog
  - `doggonet list` - List all dashboards
  - `doggonet delete` - Delete dashboard
  - `doggonet compile` - Compile Jsonnet to JSON
  - `doggonet view` - Pretty-print dashboard JSON

- **Documentation**
  - README.md - Quick start and overview
  - docs/index.md - Main documentation hub
  - docs/WIDGETS.md - Complete widget reference with examples
  - docs/LAYOUTS.md - Layout and positioning guide
  - docs/PRESETS.md - Preset catalog
  - docs/DESIGN.md - Architecture and design philosophy
  - CONTRIBUTING.md - Contribution guidelines
  - DATADOG_API_VERSION.md - API compatibility tracking

- **Examples**
  - basic.jsonnet - Simple dashboard with timeseries
  - service-health.jsonnet - Comprehensive service monitoring
  - infrastructure.jsonnet - Infrastructure dashboard (CPU, memory, disk)

- **Testing Infrastructure**
  - pytest with 56 tests
  - Test coverage reporting with codecov
  - Unit tests for CLI, client, jsonnet compilation
  - Widget compilation tests for all 38 widgets
  - GitHub Actions CI/CD

- **Development Tools**
  - ruff for linting and formatting
  - mypy for type checking
  - pytest for testing
  - GitHub Actions workflows for tests and lint

### Technical Details
- Python 3.10+ required
- Dependencies: click, rich, requests, jsonnet
- MIT License
- Fully typed Python code
- Comprehensive test suite

## Release History

- **0.1.0** (2024-11-05) - Initial alpha release with 100% widget coverage

---

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality (backward compatible)
- **PATCH** version for bug fixes (backward compatible)

### Alpha/Beta Releases
- **0.1.x** - Alpha releases (API may change)
- **0.2.x** - Beta releases (API stabilizing)
- **1.0.0** - First stable release (API stable)

## Links

- [PyPI](https://pypi.org/project/doggonet/)
- [GitHub](https://github.com/rjwalters/dogonnet)
- [Documentation](https://github.com/rjwalters/dogonnet#readme)
- [Issue Tracker](https://github.com/rjwalters/dogonnet/issues)
