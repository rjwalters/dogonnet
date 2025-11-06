# doggonet Documentation

Comprehensive Jsonnet-based framework for creating and managing Datadog dashboards with LLM-friendly documentation.

## Quick Start

```bash
# Install doggonet
pip install doggonet

# Create a new dashboard using presets
cat > my_dashboard.jsonnet <<'EOF'
local doggonet = import 'doggonet/lib/main.libsonnet';

local layouts = doggonet.layouts;
local presets = doggonet.presets;

layouts.grid(
  'My Service Dashboard',
  std.flattenArrays([
    // Key metrics
    layouts.row(0, [
      presets.activeUsersGauge('Active Users', 'sum:users.active{*}'),
      presets.requestCountGauge('Requests', 'sum:requests{*}'),
      presets.errorRateGauge('Error Rate', 'avg:errors.rate{*}'),
      presets.latencyGauge('Latency', 'avg:latency{*}'),
    ], height=2),

    // Performance trends
    layouts.row(2, [
      presets.cpuTimeseries('CPU', 'avg:system.cpu{*}'),
      presets.memoryTimeseries('Memory', 'avg:system.mem{*}'),
    ], height=3),
  ]),
  { description: 'Service health monitoring' }
)
EOF

# Push to Datadog
doggonet push my_dashboard.jsonnet
```

## Architecture

The dashboard system uses a 4-level hierarchy:

```
Level 1: Primitives (lib/widgets.libsonnet)
    ↓ Basic building blocks
Level 2: Presets (lib/presets.libsonnet)
    ↓ Common patterns with smart defaults
Level 3: Custom Components (your .libsonnet files)
    ↓ Business-specific widgets
Level 4: Dashboards (your .jsonnet files)
    ↓ Complete dashboards
```

### Key Features

- **Progressive Disclosure**: Simple one-liners to complex configurations
- **LLM-Friendly**: Extensive inline documentation with @tags
- **Type-Safe**: Documented enums prevent common errors
- **Maintainable**: Automatic positioning, no manual coordinates
- **Composable**: Mix and match components freely

## Library Structure

- **[Widgets](WIDGETS.md)** - Primitive widget builders (timeseries, query_value, heatmap, etc.)
- **[Layouts](LAYOUTS.md)** - Layout and positioning helpers (grid, row, column)
- **[Presets](PRESETS.md)** - Pre-configured common patterns with smart defaults
- **[Design](DESIGN.md)** - Architecture and design philosophy

## CLI Commands

doggonet provides a comprehensive CLI for dashboard management:

```bash
# Push a dashboard to Datadog
doggonet push my_dashboard.jsonnet

# Fetch an existing dashboard
doggonet fetch abc-123-def > existing.json

# List all dashboards
doggonet list

# Compile Jsonnet to JSON (without pushing)
doggonet compile my_dashboard.jsonnet > output.json

# View dashboard locally
doggonet view my_dashboard.jsonnet

# Delete a dashboard
doggonet delete abc-123-def
```

## Authentication

doggonet uses environment variables for Datadog authentication:

```bash
export DD_API_KEY="your-api-key"
export DD_APP_KEY="your-app-key"
export DD_SITE="datadoghq.com"  # Optional, defaults to datadoghq.com
```

Alternatively, pass them as CLI options:

```bash
doggonet push my_dashboard.jsonnet --api-key YOUR_KEY --app-key YOUR_KEY
```

## Examples

Check out the [examples/](../examples/) directory for sample dashboards:

- **basic.jsonnet** - Simple dashboard with timeseries widgets
- **service-health.jsonnet** - Service health monitoring
- **infrastructure.jsonnet** - Infrastructure monitoring

## Advanced Usage

### Custom Components

Create reusable components for your specific use case:

```jsonnet
// my_components.libsonnet
local widgets = import 'doggonet/lib/widgets.libsonnet';

{
  // Custom widget for your specific metrics
  myServiceHealth(title, service)::
    widgets.timeseries(
      title,
      'avg:myapp.health{service:' + service + '}',
      {
        display_type: 'area',
        palette: 'green',
        markers: [{ value: 'y = 0.95', display_type: 'error dashed' }],
      }
    ),
}
```

### External Variables

Use external variables for environment-specific dashboards:

```bash
doggonet compile dashboard.jsonnet --ext-str env=production
```

```jsonnet
// dashboard.jsonnet
local env = std.extVar('env');
local doggonet = import 'doggonet/lib/main.libsonnet';

doggonet.dashboard.new('My Dashboard - ' + env)
  .addWidget(...)
```

## Contributing

Contributions welcome! Please see [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

MIT
