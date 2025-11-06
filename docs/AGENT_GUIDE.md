# LLM Agent Guide for doggonet

**Purpose:** Help LLM agents create beautiful Datadog dashboards from user metrics quickly and correctly.

## Quick Start for LLMs

When a user asks to create a dashboard, follow this process:

1. **Identify metric types** from user's tags/metrics
2. **Choose appropriate widgets** using the mapping below
3. **Apply smart layouts** from templates
4. **Use presets** for common patterns

## Metric Type → Widget Mapping

### Counter Metrics (always increasing)
**Examples:** `requests.count`, `errors.total`, `events.processed`

**Best widget:** `timeseries` with `.as_rate()` or `barChart`
```jsonnet
// Convert counter to rate (requests per second)
widgets.timeseries('Request Rate', 'sum:requests.count{*}.as_rate()', {
  display_type: 'bars',
  palette: 'purple'
})
```

### Gauge Metrics (point-in-time values)
**Examples:** `cpu.usage`, `memory.percent`, `queue.length`, `users.active`

**Best widget:** `timeseries` for trends, `queryValue` for current value
```jsonnet
// Trend over time
widgets.timeseries('CPU Usage', 'avg:system.cpu.user{*}')

// Current value
widgets.queryValue('Active Users', 'sum:users.active{*}', {
  precision: 0,
  aggregator: 'last'
})
```

### Percentage Metrics (0-100)
**Examples:** `cpu.percent`, `memory.pct_usable`, `success.rate`

**Best widget:** `queryValue` or `timeseries` with markers
```jsonnet
widgets.timeseries('Success Rate', 'avg:success.rate{*}', {
  yaxis: { min: 0, max: 100 },
  custom_unit: '%',
  markers: [
    { value: 'y = 99', display_type: 'ok dashed', label: 'SLO: 99%' }
  ]
})
```

### Latency/Duration Metrics (milliseconds, seconds)
**Examples:** `response.time`, `request.duration`, `latency.p99`

**Best widget:** `timeseries` with percentiles or `distribution`
```jsonnet
// Multiple percentiles
widgets.timeseries('Latency Percentiles', {
  queries: [
    { query: 'p50:request.duration{*}', name: 'p50' },
    { query: 'p95:request.duration{*}', name: 'p95' },
    { query: 'p99:request.duration{*}', name: 'p99' }
  ]
}, {
  custom_unit: 'ms',
  markers: [
    { value: 'y = 200', display_type: 'ok dashed', label: 'Target' },
    { value: 'y = 500', display_type: 'warning dashed', label: 'Warn' }
  ]
})
```

### Error Metrics
**Examples:** `errors.count`, `failures.rate`, `exceptions.total`

**Best widget:** `timeseries` with error styling, or error rate calculation
```jsonnet
// Error rate from counts
widgets.timeseries('Error Rate', {
  queries: [
    { query: 'sum:errors{*}.as_rate()', name: 'errors' },
    { query: 'sum:requests{*}.as_rate()', name: 'requests' }
  ],
  formulas: [
    { formula: '(errors / requests) * 100', alias: 'Error %' }
  ]
}, {
  display_type: 'bars',
  palette: 'warm',
  custom_unit: '%',
  markers: [
    { value: 'y = 1', display_type: 'warning dashed' },
    { value: 'y = 5', display_type: 'error dashed' }
  ]
})
```

### Distribution Metrics (histograms)
**Examples:** Trace spans, APM metrics

**Best widget:** `distribution` or `heatmap`
```jsonnet
widgets.distribution('Request Duration Distribution', 'trace.duration{service:web}', {
  stat: 'p95'
})
```

### Top-N Rankings
**Examples:** Hosts by CPU, services by requests, endpoints by errors

**Best widget:** `toplist`
```jsonnet
widgets.toplist('Top Services by Requests', 'sum:requests{*} by {service}')
widgets.toplist('Slowest Endpoints', 'avg:latency{*} by {endpoint}')
```

### Categorical Breakdowns
**Examples:** Requests by region, users by country, errors by type

**Best widget:** `pieChart` or `treemap`
```jsonnet
widgets.pieChart('Requests by Region', 'sum:requests{*} by {region}')
widgets.treemap('Storage by Service', 'sum:storage.bytes{*} by {service}')
```

## Dashboard Templates for Common Use Cases

### Template 1: Service Health Dashboard
**When to use:** User has a microservice with basic metrics

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local presets = doggonet.presets;

layouts.grid(
  'Service Health: {{SERVICE_NAME}}',
  std.flattenArrays([
    // Row 1: Key metrics (gauges)
    layouts.row(0, [
      presets.requestCountGauge('Total Requests', 'sum:requests{service:{{SERVICE}}}'),
      presets.errorRateGauge('Error Rate', 'avg:errors.rate{service:{{SERVICE}}}'),
      presets.latencyGauge('P95 Latency', 'p95:latency{service:{{SERVICE}}}'),
      presets.activeUsersGauge('Active Users', 'sum:users.active{service:{{SERVICE}}}'),
    ], height=2),

    // Row 2: Request trends
    layouts.row(2, [
      presets.requestRateTimeseries('Request Rate', 'sum:requests{service:{{SERVICE}}}.as_rate()'),
      presets.errorRateTimeseries('Error Trend', 'avg:errors.rate{service:{{SERVICE}}}'),
    ], height=3),

    // Row 3: Performance
    layouts.row(5, [
      presets.latencyTimeseries('Latency', 'p95:latency{service:{{SERVICE}}}'),
      presets.successRateTimeseries('Success Rate', '((sum:requests{service:{{SERVICE}}} - sum:errors{service:{{SERVICE}}}) / sum:requests{service:{{SERVICE}}}) * 100'),
    ], height=3),

    // Row 4: Top endpoints
    layouts.row(8, [
      presets.topServicesByRequests('Top Endpoints', 'sum:requests{service:{{SERVICE}}} by {endpoint}'),
      presets.topEndpointsByLatency('Slowest Endpoints', 'avg:latency{service:{{SERVICE}}} by {endpoint}'),
    ], height=3),
  ])
)
```

**LLM Prompt:** "Create a service health dashboard for my-api service"

### Template 2: Infrastructure Dashboard
**When to use:** User wants to monitor servers/containers

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local presets = doggonet.presets;

layouts.grid(
  'Infrastructure Monitoring',
  std.flattenArrays([
    // System resources
    layouts.row(0, [
      presets.cpuTimeseries('CPU Usage', 'avg:system.cpu.user{*}'),
      presets.memoryTimeseries('Memory Usage', 'avg:system.mem.pct_usable{*}'),
    ], height=3),

    // Network & Disk
    layouts.row(3, [
      presets.networkThroughput('Network In', 'avg:system.net.bytes_rcvd{*}'),
      presets.networkThroughput('Network Out', 'avg:system.net.bytes_sent{*}'),
    ], height=3),

    // Top hosts
    layouts.row(6, [
      presets.topHostsByCPU('Top Hosts by CPU', 'avg:system.cpu.user{*} by {host}'),
      presets.topHostsByMemory('Top Hosts by Memory', 'avg:system.mem.used{*} by {host}'),
    ], height=3),
  ])
)
```

**LLM Prompt:** "Create an infrastructure dashboard for my EC2 instances"

### Template 3: Business Metrics Dashboard
**When to use:** User has business KPIs (revenue, signups, conversions)

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local presets = doggonet.presets;
local widgets = doggonet.widgets;

layouts.grid(
  'Business Metrics',
  std.flattenArrays([
    // Key business metrics
    layouts.row(0, [
      widgets.queryValue('Daily Revenue', 'sum:revenue.usd{*}', {
        precision: 2,
        custom_unit: '$',
        aggregator: 'sum'
      }),
      widgets.queryValue('New Signups', 'sum:signups.count{*}', {
        precision: 0,
        aggregator: 'sum'
      }),
      presets.conversionRateGauge('Conversion Rate', '(sum:conversions{*} / sum:visitors{*}) * 100'),
      widgets.queryValue('DAU', 'count:users.active{*}', {
        precision: 0,
        aggregator: 'last'
      }),
    ], height=2),

    // Trends
    layouts.row(2, [
      presets.revenueTimeseries('Revenue Trend', 'sum:revenue.usd{*}'),
      presets.userGrowthChange('User Growth', 'sum:users.active{*}'),
    ], height=3),
  ])
)
```

**LLM Prompt:** "Create a business dashboard with revenue and conversion metrics"

### Template 4: Golden Signals (Google SRE)
**When to use:** User mentions "golden signals", "SRE metrics", "four signals"

The four golden signals are:
1. **Latency** - How long requests take
2. **Traffic** - How many requests
3. **Errors** - How many failures
4. **Saturation** - How full the system is

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local widgets = doggonet.widgets;

layouts.grid(
  'Golden Signals: {{SERVICE}}',
  std.flattenArrays([
    // Header
    [layouts.fullWidth(0, widgets.note('# Golden Signals Dashboard\n\nThe four critical metrics for monitoring service health.'), height=1)],

    // 1. Latency
    [layouts.fullWidth(1, widgets.note('## 1. Latency'), height=1)],
    layouts.row(2, [
      widgets.queryValue('P50 Latency', 'p50:latency{service:{{SERVICE}}}', {
        custom_unit: 'ms',
        precision: 0
      }),
      widgets.queryValue('P95 Latency', 'p95:latency{service:{{SERVICE}}}', {
        custom_unit: 'ms',
        precision: 0
      }),
      widgets.queryValue('P99 Latency', 'p99:latency{service:{{SERVICE}}}', {
        custom_unit: 'ms',
        precision: 0
      }),
    ], height=2),
    layouts.row(4, [
      widgets.timeseries('Latency Percentiles', {
        queries: [
          { query: 'p50:latency{service:{{SERVICE}}}', name: 'p50' },
          { query: 'p95:latency{service:{{SERVICE}}}', name: 'p95' },
          { query: 'p99:latency{service:{{SERVICE}}}', name: 'p99' }
        ]
      }, { custom_unit: 'ms' }),
    ], height=3),

    // 2. Traffic
    [layouts.fullWidth(7, widgets.note('## 2. Traffic'), height=1)],
    layouts.row(8, [
      widgets.timeseries('Request Rate', 'sum:requests{service:{{SERVICE}}}.as_rate()', {
        display_type: 'bars',
        palette: 'cool'
      }),
    ], height=3),

    // 3. Errors
    [layouts.fullWidth(11, widgets.note('## 3. Errors'), height=1)],
    layouts.row(12, [
      widgets.timeseries('Error Rate', {
        queries: [
          { query: 'sum:errors{service:{{SERVICE}}}.as_rate()', name: 'errors' },
          { query: 'sum:requests{service:{{SERVICE}}}.as_rate()', name: 'requests' }
        ],
        formulas: [
          { formula: '(errors / requests) * 100', alias: 'Error %' }
        ]
      }, {
        custom_unit: '%',
        markers: [
          { value: 'y = 1', display_type: 'warning dashed', label: 'Warning' },
          { value: 'y = 5', display_type: 'error dashed', label: 'Critical' }
        ]
      }),
    ], height=3),

    // 4. Saturation
    [layouts.fullWidth(15, widgets.note('## 4. Saturation'), height=1)],
    layouts.row(16, [
      widgets.timeseries('CPU Saturation', 'avg:system.cpu.user{service:{{SERVICE}}}', {
        yaxis: { min: 0, max: 100 },
        custom_unit: '%',
        markers: [
          { value: 'y = 80', display_type: 'warning dashed' }
        ]
      }),
      widgets.timeseries('Memory Saturation', 'avg:system.mem.pct_usable{service:{{SERVICE}}}', {
        yaxis: { min: 0, max: 100 },
        custom_unit: '%',
        markers: [
          { value: 'y = 80', display_type: 'warning dashed' }
        ]
      }),
    ], height=3),
  ])
)
```

**LLM Prompts:**
- "Create a golden signals dashboard"
- "Make me an SRE dashboard with the four signals"
- "Show me latency, traffic, errors, and saturation"

### Template 5: RED Metrics (Rate, Errors, Duration)
**When to use:** User mentions "RED metrics", "microservices monitoring"

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local presets = doggonet.presets;

layouts.grid(
  'RED Metrics: {{SERVICE}}',
  std.flattenArrays([
    // Rate
    [layouts.fullWidth(0, widgets.note('## Rate - Request throughput'), height=1)],
    layouts.row(1, [
      presets.requestRateTimeseries('Request Rate', 'sum:requests{service:{{SERVICE}}}.as_rate()'),
    ], height=3),

    // Errors
    [layouts.fullWidth(4, widgets.note('## Errors - Failed requests'), height=1)],
    layouts.row(5, [
      presets.errorRateTimeseries('Error Rate', 'avg:errors.rate{service:{{SERVICE}}}'),
    ], height=3),

    // Duration
    [layouts.fullWidth(8, widgets.note('## Duration - Response times'), height=1)],
    layouts.row(9, [
      presets.latencyTimeseries('Latency P95', 'p95:latency{service:{{SERVICE}}}'),
    ], height=3),
  ])
)
```

## Decision Tree: Choosing the Right Widget

```
Start: What do you want to show?

├─ A single current value?
│  ├─ Yes → Use queryValue
│  │  ├─ Is it a percentage? → Set custom_unit: '%'
│  │  ├─ Is it money? → Set custom_unit: '$', precision: 2
│  │  └─ Is it a count? → Set precision: 0, autoscale: true
│  └─ No → Continue
│
├─ Trends over time?
│  ├─ Yes → Use timeseries
│  │  ├─ Is it a counter? → Add .as_rate() to query
│  │  ├─ Need SLO thresholds? → Add markers array
│  │  └─ Multiple percentiles? → Use queries array
│  └─ No → Continue
│
├─ Ranked list (top 10)?
│  ├─ Yes → Use toplist
│  └─ No → Continue
│
├─ Comparison across categories?
│  ├─ Yes → Use pieChart or treemap
│  │  ├─ Few categories (< 10)? → pieChart
│  └─ Many categories? → treemap
│
├─ Distribution/histogram?
│  ├─ Yes → Use distribution or heatmap
│  │  ├─ APM traces? → distribution
│  └─ General metrics? → heatmap
│
├─ Period-over-period change?
│  ├─ Yes → Use change
│  │  ├─ Increase is good? → Set increase_good: true
│  └─ Decrease is good? → Set increase_good: false
│
└─ Correlation between two metrics?
   └─ Yes → Use scatterplot
```

## Common Patterns & Recipes

### Pattern: Error Rate from Counts
```jsonnet
// Calculate error rate when you have error and total counts
widgets.timeseries('Error Rate %', {
  queries: [
    { query: 'sum:errors{*}.as_rate()', name: 'errors' },
    { query: 'sum:requests{*}.as_rate()', name: 'total' }
  ],
  formulas: [
    { formula: '(errors / total) * 100', alias: 'Error %' }
  ]
}, { custom_unit: '%' })
```

### Pattern: Availability Calculation
```jsonnet
// Calculate uptime percentage
widgets.queryValue('Availability', {
  queries: [
    { query: 'sum:checks.ok{*}', name: 'ok' },
    { query: 'sum:checks.total{*}', name: 'total' }
  ],
  formulas: [
    { formula: '(ok / total) * 100' }
  ]
}, {
  precision: 2,
  custom_unit: '%'
})
```

### Pattern: Rate from Counter
```jsonnet
// Always use .as_rate() for counters
widgets.timeseries('Events per Second', 'sum:events.count{*}.as_rate()')
```

### Pattern: Memory Usage Percentage
```jsonnet
// Calculate percentage from used/total
widgets.timeseries('Memory Usage %', {
  queries: [
    { query: 'avg:memory.used{*}', name: 'used' },
    { query: 'avg:memory.total{*}', name: 'total' }
  ],
  formulas: [
    { formula: '(used / total) * 100' }
  ]
}, {
  yaxis: { min: 0, max: 100 },
  custom_unit: '%'
})
```

### Pattern: Apdex Score
```jsonnet
// Application Performance Index
widgets.queryValue('Apdex Score', {
  queries: [
    { query: 'sum:requests.satisfied{*}', name: 'satisfied' },
    { query: 'sum:requests.tolerable{*}', name: 'tolerable' },
    { query: 'sum:requests.total{*}', name: 'total' }
  ],
  formulas: [
    { formula: '(satisfied + (tolerable / 2)) / total' }
  ]
}, { precision: 2 })
```

## LLM Prompt Examples

### Effective Prompts
✅ "Create a dashboard for my web-api service showing request rate, error rate, and latency"
✅ "I have CPU and memory metrics for my hosts, show me system health"
✅ "Make a business dashboard with revenue (revenue.usd), signups (signups.count), and conversion rate"
✅ "Golden signals dashboard for my payment-service"
✅ "Show me the top 10 endpoints by request count and their error rates"

### What LLMs Should Ask
When a user request is ambiguous, ask:

1. **What metrics do you have?**
   - "What's the metric name for requests?" → `requests.count` or `http.requests`
   - "Do you track errors separately?" → `errors.count` vs derived from status codes

2. **What's your service/tag structure?**
   - "What tag identifies your service?" → `service:web-api`
   - "Do you filter by environment?" → `env:production`

3. **What's the metric type?**
   - "Is this a counter (always increasing) or gauge (point-in-time)?"
   - This determines if we use `.as_rate()`

4. **What are you optimizing for?**
   - User experience? → Focus on latency, errors
   - Cost? → Focus on resource utilization
   - Business? → Focus on conversion, revenue

## Quick Reference: Widget Parameters

### Most Common Options Across All Widgets

```jsonnet
{
  // Display styling
  display_type: 'line' | 'area' | 'bars',  // timeseries
  palette: 'cool' | 'warm' | 'purple' | 'orange',

  // Value formatting
  custom_unit: 'ms' | '%' | '$' | 'req/s',
  precision: 0,  // decimal places
  autoscale: true,  // 1000 → 1K

  // Aggregation
  aggregator: 'avg' | 'sum' | 'min' | 'max' | 'last',

  // Thresholds/SLOs
  markers: [
    { value: 'y = 100', display_type: 'ok dashed', label: 'Target' },
    { value: 'y = 200', display_type: 'warning dashed', label: 'Warn' },
    { value: 'y = 500', display_type: 'error dashed', label: 'Critical' }
  ],

  // Axes
  yaxis: { min: 0, max: 100, scale: 'linear' | 'log' }
}
```

## Anti-Patterns (What NOT to Do)

❌ **Don't use counters without .as_rate()**
```jsonnet
// BAD - counter will just keep going up
widgets.timeseries('Requests', 'sum:requests.count{*}')

// GOOD - show rate per second
widgets.timeseries('Requests/sec', 'sum:requests.count{*}.as_rate()')
```

❌ **Don't forget to set units**
```jsonnet
// BAD - users see "245" without context
widgets.queryValue('Latency', 'avg:latency{*}')

// GOOD - clear that it's milliseconds
widgets.queryValue('Latency', 'avg:latency{*}', { custom_unit: 'ms' })
```

❌ **Don't hardcode service names when using templates**
```jsonnet
// BAD - only works for one service
'sum:requests{service:web-api}'

// GOOD - use variables
'sum:requests{service:' + service + '}'
```

❌ **Don't put too many widgets in one row**
```jsonnet
// BAD - widgets will be too narrow
layouts.row(0, [w1, w2, w3, w4, w5, w6], height=2)

// GOOD - 3-4 widgets max per row
layouts.row(0, [w1, w2, w3, w4], height=2)
```

## Success Checklist

When creating a dashboard for a user, ensure:

- [ ] All metrics have appropriate units (`ms`, `%`, `$`, etc.)
- [ ] Counters use `.as_rate()`
- [ ] Percentages have `yaxis: { min: 0, max: 100 }`
- [ ] SLO thresholds are added where appropriate (error rates, latency)
- [ ] Widget titles are descriptive ("Request Rate" not "Metric 1")
- [ ] Layout is organized by logical sections (use note widgets as headers)
- [ ] Color palettes are consistent (errors = warm, success = cool)
- [ ] No more than 4 widgets per row
- [ ] Dashboard has a clear title and description

## Further Reading

- [Full Widget Reference](WIDGETS.md) - All 38 widgets with detailed examples
- [Preset Catalog](PRESETS.md) - Pre-configured common patterns
- [Layout Guide](LAYOUTS.md) - Organizing widgets effectively
- [Design Philosophy](DESIGN.md) - Architecture and principles
