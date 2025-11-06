# doggonet 🐶

A Datadog dashboard templating library using Jsonnet - because good dashboards deserve good tools!

## Overview

`doggonet` is a Python library that provides a Jsonnet-based templating system for creating Datadog dashboards programmatically. Think of it as [grafonnet-lib](https://github.com/grafana/grafonnet-lib) for Datadog.

## Features

- **Jsonnet Templates**: Write dashboards as code using Jsonnet
- **Reusable Components**: Pre-built widgets and layouts for common patterns
- **Type-Safe**: Pydantic models for dashboard definitions
- **CLI Tools**: Push, fetch, export, and manage dashboards
- **Rich Presets**: Opinionated defaults for beautiful dashboards

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
- [Widget Reference](docs/WIDGETS.md)
- [Layout Guide](docs/LAYOUTS.md)
- [Preset Catalog](docs/PRESETS.md)
- [API Reference](docs/API.md)

## Examples

Check out [examples/](examples/) for sample dashboards:
- [examples/basic.jsonnet](examples/basic.jsonnet) - Simple dashboard
- [examples/service-health.jsonnet](examples/service-health.jsonnet) - Service health dashboard
- [examples/infrastructure.jsonnet](examples/infrastructure.jsonnet) - Infrastructure monitoring

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
