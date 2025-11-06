# doggonet 🐶

[![Tests](https://github.com/rjwalters/dogonnet/actions/workflows/test.yml/badge.svg)](https://github.com/rjwalters/dogonnet/actions/workflows/test.yml)
[![Lint](https://github.com/rjwalters/dogonnet/actions/workflows/lint.yml/badge.svg)](https://github.com/rjwalters/dogonnet/actions/workflows/lint.yml)
[![codecov](https://codecov.io/gh/rjwalters/dogonnet/branch/main/graph/badge.svg)](https://codecov.io/gh/rjwalters/dogonnet)
[![PyPI version](https://badge.fury.io/py/doggonet.svg)](https://badge.fury.io/py/doggonet)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Datadog dashboard templating library using Jsonnet - because good dashboards deserve good tools!

## Overview

`doggonet` is a Python library that provides a Jsonnet-based templating system for creating Datadog dashboards programmatically. Think of it as [grafonnet-lib](https://github.com/grafana/grafonnet-lib) for Datadog.

## Features

- **Jsonnet Templates**: Write dashboards as code using Jsonnet
- **38 Widget Types**: 100% coverage of all Datadog dashboard widgets
- **Reusable Components**: Pre-built widgets and layouts for common patterns
- **Type-Safe**: Pydantic models for dashboard definitions
- **CLI Tools**: Push, fetch, export, and manage dashboards
- **Rich Presets**: Opinionated defaults for beautiful dashboards
- **AI-Friendly**: Comprehensive guides for LLM agents to create dashboards from natural language

## AI Agent Support 🤖

`doggonet` is designed to be easily used by AI agents like Claude, ChatGPT, and others. We provide:

- **[Agent Guide](docs/AGENT_GUIDE.md)** - Comprehensive guide for AI agents with metric-to-widget mapping, decision trees, and templates
- **[Cookbook](docs/COOKBOOK.md)** - Copy-paste recipes for common dashboard patterns (Golden Signals, RED metrics, business KPIs)
- **Progressive Disclosure** - Simple one-liners to complex configurations
- **Semantic Documentation** - Every widget has usage examples and common patterns

**Example AI prompts that work:**
- "Create a golden signals dashboard for my payment-api service"
- "Make a business dashboard with revenue, signups, and conversion rate"
- "Show me CPU and memory trends for my infrastructure"

## Installation

```bash
pip install doggonet
```

## Quick Start

### Create a Dashboard with Jsonnet

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';

doggonet.dashboard.new(
  title='My Service Dashboard',
  tags=['service:my-service'],
)
.addRow(
  doggonet.row.new(title='Key Metrics')
  .addPanel(
    doggonet.widgets.timeseries(
      title='Request Rate',
      queries=['avg:http.requests{service:my-service}']
    )
  )
  .addPanel(
    doggonet.widgets.timeseries(
      title='Error Rate',
      queries=['avg:http.errors{service:my-service}']
    )
  )
)
```

### Push to Datadog

```bash
# Compile and push
doggonet push my-dashboard.jsonnet

# Export without pushing
doggonet compile my-dashboard.jsonnet > output.json

# Fetch existing dashboard
doggonet fetch my-dashboard-id > existing.json
```

## Library Structure

- `doggonet.lib.widgets` - Widget builders (timeseries, query_value, heatmap, etc.)
- `doggonet.lib.layouts` - Layout utilities (rows, columns, grid)
- `doggonet.lib.presets` - Opinionated presets for common patterns
- `doggonet.client` - Datadog API client
- `doggonet.cli` - Command-line tools

## Documentation

See [docs/](docs/) for detailed documentation:

**For AI Agents & Users:**
- [Agent Guide](docs/AGENT_GUIDE.md) - Complete guide for AI agents with templates, patterns, and decision trees
- [Cookbook](docs/COOKBOOK.md) - Copy-paste recipes for common use cases
- [Widget Reference](docs/WIDGETS.md) - All 38 widgets with examples
- [Preset Catalog](docs/PRESETS.md) - Pre-configured common patterns
- [Layout Guide](docs/LAYOUTS.md) - Dashboard organization and positioning

**For Developers:**
- [Design Philosophy](docs/DESIGN.md) - Architecture and principles
- [API Version](DATADOG_API_VERSION.md) - Datadog API compatibility

## Examples

Check out [examples/](examples/) for sample dashboards:
- [examples/basic.jsonnet](examples/basic.jsonnet) - Simple dashboard with timeseries widgets
- [examples/service-health.jsonnet](examples/service-health.jsonnet) - Complete service health monitoring
- [examples/infrastructure.jsonnet](examples/infrastructure.jsonnet) - Infrastructure monitoring (CPU, memory, disk)
- [examples/golden-signals.jsonnet](examples/golden-signals.jsonnet) - Google SRE Golden Signals (latency, traffic, errors, saturation)

## Development

```bash
# Install development dependencies
pip install -e ".[dev]"

# Run tests
pytest

# Run linter
ruff check .

# Format code
ruff format .
```

## License

MIT

## Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Acknowledgments

Inspired by [grafonnet-lib](https://github.com/grafana/grafonnet-lib) for Grafana.
