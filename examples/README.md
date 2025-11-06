# doggonet Examples

This directory contains example dashboards demonstrating various features of doggonet.

## Examples

### basic.jsonnet
A simple dashboard showing the most basic usage:
- Timeseries widgets for CPU and memory
- Request and error rate metrics
- Simple grid layout

**Usage:**
```bash
# Compile to JSON
doggonet compile basic.jsonnet > basic.json

# Push to Datadog
doggonet push basic.jsonnet

# View locally
doggonet view basic.jsonnet
```

### service-health.jsonnet
A comprehensive service health dashboard:
- Top-level gauges for key metrics
- Request and error rate trends
- Performance metrics (latency, throughput)
- Resource usage (CPU, memory, disk)
- Top endpoints by request/error count

This example demonstrates using presets for quick setup with smart defaults.

**Usage:**
```bash
# Edit to replace 'my-service' with your service name
# Then push to Datadog
doggonet push service-health.jsonnet
```

### infrastructure.jsonnet
Infrastructure monitoring dashboard:
- EC2 instance metrics
- Load balancer metrics
- RDS database metrics
- Network and disk I/O
- Top instances by resource usage

**Usage:**
```bash
doggonet push infrastructure.jsonnet
```

### golden-signals.jsonnet
**The Four Golden Signals from Google SRE:**

A comprehensive dashboard following Google SRE best practices with the four critical metrics for service health:

1. **Latency** - How long requests take (p50, p95, p99 percentiles)
2. **Traffic** - Request throughput and rate
3. **Errors** - Error rate and counts by type
4. **Saturation** - System resource usage (CPU, memory, connections)

**Features:**
- Clean section headers for each signal
- SLO markers on relevant metrics
- Top lists for debugging (error types, resource-heavy hosts)
- Template variables for easy service/env switching

**Usage:**
```bash
# Edit the service and env variables at the top
# Then compile and push
doggonet push golden-signals.jsonnet
```

**AI Prompt:** "Create a golden signals dashboard for my payment-api service"

## Customizing Examples

All examples are designed to be customized for your specific use case:

1. **Replace metric names**: Change the metric queries to match your metrics
2. **Adjust service names**: Update service tags and filters
3. **Add/remove widgets**: Modify the widget arrays to fit your needs
4. **Change layouts**: Adjust row heights and widget positioning

## Creating Your Own Dashboards

Use these examples as templates for your own dashboards:

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';

local layouts = doggonet.layouts;
local widgets = doggonet.widgets;
local presets = doggonet.presets;

// Your custom dashboard here
layouts.grid(
  'My Dashboard',
  std.flattenArrays([
    layouts.row(0, [
      widgets.timeseries('My Metric', 'avg:my.metric{*}'),
    ], height=3),
  ])
)
```

## Environment-Specific Dashboards

You can use external variables to create environment-specific dashboards:

```jsonnet
local env = std.extVar('env');  // production, staging, etc.
local doggonet = import 'doggonet/lib/main.libsonnet';

doggonet.layouts.grid(
  'My Dashboard - ' + env,
  // widgets filtered by env...
)
```

Compile with:
```bash
doggonet compile my_dashboard.jsonnet --ext-str env=production
```

## Need Help?

- See the [docs/](../docs/) directory for comprehensive documentation
- Check out [WIDGETS.md](../docs/WIDGETS.md) for all available widgets
- Read [PRESETS.md](../docs/PRESETS.md) for pre-configured patterns
