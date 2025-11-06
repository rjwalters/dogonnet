# doggonet Cookbook

**Copy-paste recipes for common dashboard patterns.**

## Table of Contents

1. [Single Metric Widgets](#single-metric-widgets)
2. [Calculated Metrics](#calculated-metrics)
3. [Complete Dashboards](#complete-dashboards)
4. [Advanced Patterns](#advanced-patterns)

---

## Single Metric Widgets

### Request Rate (Counter → Rate)
```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local widgets = doggonet.widgets;

widgets.timeseries(
  'Requests per Second',
  'sum:http.requests{*}.as_rate()',
  {
    display_type: 'bars',
    palette: 'purple',
    custom_unit: 'req/s'
  }
)
```

### Error Rate Percentage
```jsonnet
widgets.timeseries(
  'Error Rate %',
  {
    queries: [
      { query: 'sum:http.errors{*}.as_rate()', name: 'errors' },
      { query: 'sum:http.requests{*}.as_rate()', name: 'requests' }
    ],
    formulas: [
      { formula: '(errors / requests) * 100', alias: 'Error %' }
    ]
  },
  {
    display_type: 'bars',
    palette: 'warm',
    custom_unit: '%',
    markers: [
      { value: 'y = 0.1', display_type: 'ok dashed', label: 'Target: < 0.1%' },
      { value: 'y = 1', display_type: 'warning dashed', label: 'Warning: 1%' },
      { value: 'y = 5', display_type: 'error dashed', label: 'Critical: 5%' }
    ]
  }
)
```

### Latency Percentiles
```jsonnet
widgets.timeseries(
  'Response Time Percentiles',
  {
    queries: [
      { query: 'p50:trace.duration{service:web}', name: 'p50' },
      { query: 'p95:trace.duration{service:web}', name: 'p95' },
      { query: 'p99:trace.duration{service:web}', name: 'p99' }
    ]
  },
  {
    custom_unit: 'ms',
    palette: 'purple',
    line_width: 'thick',
    markers: [
      { value: 'y = 200', display_type: 'ok dashed', label: 'SLO: 200ms' },
      { value: 'y = 500', display_type: 'warning dashed', label: 'Degraded' }
    ]
  }
)
```

### Current Active Users
```jsonnet
widgets.queryValue(
  'Active Users',
  'count_nonzero:users.active{*}',
  {
    precision: 0,
    aggregator: 'last',
    autoscale: true  // Show 1.2K instead of 1200
  }
)
```

### CPU Usage with Threshold
```jsonnet
widgets.timeseries(
  'CPU Usage %',
  'avg:system.cpu.user{*}',
  {
    display_type: 'area',
    palette: 'warm',
    custom_unit: '%',
    yaxis: { min: 0, max: 100 },
    markers: [
      { value: 'y = 80', display_type: 'warning dashed', label: 'High' },
      { value: 'y = 95', display_type: 'error dashed', label: 'Critical' }
    ]
  }
)
```

### Memory Usage (Calculated)
```jsonnet
widgets.timeseries(
  'Memory Usage %',
  {
    queries: [
      { query: 'avg:system.mem.used{*}', name: 'used' },
      { query: 'avg:system.mem.total{*}', name: 'total' }
    ],
    formulas: [
      { formula: '(used / total) * 100', alias: 'Memory %' }
    ]
  },
  {
    custom_unit: '%',
    yaxis: { min: 0, max: 100 },
    markers: [
      { value: 'y = 80', display_type: 'warning dashed' }
    ]
  }
)
```

### Top Services by Requests
```jsonnet
widgets.toplist(
  'Busiest Services',
  'sum:requests{*}.as_rate() by {service}'
)
```

### Revenue Gauge
```jsonnet
widgets.queryValue(
  'Today\'s Revenue',
  'sum:revenue.usd{*}',
  {
    precision: 2,
    custom_unit: '$',
    aggregator: 'sum',
    autoscale: false  // Always show full number for money
  }
)
```

---

## Calculated Metrics

### Success Rate (Inverted Error Rate)
```jsonnet
widgets.queryValue(
  'Success Rate',
  {
    queries: [
      { query: 'sum:requests.success{*}', name: 'success' },
      { query: 'sum:requests.total{*}', name: 'total' }
    ],
    formulas: [
      { formula: '(success / total) * 100' }
    ]
  },
  {
    precision: 2,
    custom_unit: '%'
  }
)
```

### Conversion Rate
```jsonnet
widgets.queryValue(
  'Signup → Purchase Conversion',
  {
    queries: [
      { query: 'sum:conversions.purchase{*}', name: 'purchases' },
      { query: 'sum:events.signup{*}', name: 'signups' }
    ],
    formulas: [
      { formula: '(purchases / signups) * 100' }
    ]
  },
  {
    precision: 1,
    custom_unit: '%'
  }
)
```

### Availability (Uptime %)
```jsonnet
widgets.timeseries(
  'Service Availability',
  {
    queries: [
      { query: 'sum:healthcheck.success{*}', name: 'success' },
      { query: 'sum:healthcheck.total{*}', name: 'total' }
    ],
    formulas: [
      { formula: '(success / total) * 100', alias: 'Uptime %' }
    ]
  },
  {
    custom_unit: '%',
    yaxis: { min: 95, max: 100 },
    markers: [
      { value: 'y = 99.9', display_type: 'ok dashed', label: 'SLA: 99.9%' }
    ]
  }
)
```

### Cache Hit Ratio
```jsonnet
widgets.queryValue(
  'Cache Hit Rate',
  {
    queries: [
      { query: 'sum:cache.hits{*}', name: 'hits' },
      { query: 'sum:cache.requests{*}', name: 'total' }
    ],
    formulas: [
      { formula: '(hits / total) * 100' }
    ]
  },
  {
    precision: 1,
    custom_unit: '%'
  }
)
```

### Throughput (Bytes per Second)
```jsonnet
widgets.timeseries(
  'Network Throughput',
  'sum:network.bytes_sent{*}.as_rate()',
  {
    custom_unit: 'B/s',
    autoscale: true  // Will show MB/s, GB/s automatically
  }
)
```

---

## Complete Dashboards

### Recipe: Minimal Service Dashboard
**3 rows, 7 widgets - perfect for microservices**

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local widgets = doggonet.widgets;

// Variables (replace these)
local service = 'web-api';
local metrics = {
  requests: 'sum:requests{service:' + service + '}',
  errors: 'sum:errors{service:' + service + '}',
  latency: 'p95:latency{service:' + service + '}'
};

layouts.grid(
  service + ' Dashboard',
  std.flattenArrays([
    // Row 1: Key metrics
    layouts.row(0, [
      widgets.queryValue('Requests/min', metrics.requests + '.as_rate()', {
        precision: 0,
        autoscale: true
      }),
      widgets.queryValue('Error Rate', {
        queries: [
          { query: metrics.errors + '.as_rate()', name: 'errors' },
          { query: metrics.requests + '.as_rate()', name: 'requests' }
        ],
        formulas: [{ formula: '(errors / requests) * 100' }]
      }, {
        precision: 2,
        custom_unit: '%'
      }),
      widgets.queryValue('P95 Latency', metrics.latency, {
        precision: 0,
        custom_unit: 'ms'
      }),
    ], height=2),

    // Row 2: Request & Error trends
    layouts.row(2, [
      widgets.timeseries('Request Rate', metrics.requests + '.as_rate()', {
        display_type: 'bars',
        palette: 'purple'
      }),
      widgets.timeseries('Error Rate %', {
        queries: [
          { query: metrics.errors + '.as_rate()', name: 'errors' },
          { query: metrics.requests + '.as_rate()', name: 'requests' }
        ],
        formulas: [{ formula: '(errors / requests) * 100' }]
      }, {
        display_type: 'bars',
        palette: 'warm',
        custom_unit: '%'
      }),
    ], height=3),

    // Row 3: Latency
    layouts.row(5, [
      widgets.timeseries('Latency', {
        queries: [
          { query: 'p50:latency{service:' + service + '}', name: 'p50' },
          { query: 'p95:latency{service:' + service + '}', name: 'p95' },
          { query: 'p99:latency{service:' + service + '}', name: 'p99' }
        ]
      }, {
        custom_unit: 'ms',
        markers: [
          { value: 'y = 200', display_type: 'ok dashed', label: 'SLO' }
        ]
      }),
    ], height=3),
  ]),
  {
    description: 'Service health monitoring for ' + service
  }
)
```

### Recipe: Golden Signals Dashboard
**Comprehensive SRE dashboard**

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local widgets = doggonet.widgets;

local service = 'payment-api';

layouts.grid(
  'Golden Signals: ' + service,
  std.flattenArrays([
    // Header
    [layouts.fullWidth(0, widgets.note('# Golden Signals Dashboard\nLatency • Traffic • Errors • Saturation', {
      background_color: 'blue',
      font_size: '18',
      text_align: 'center'
    }), height=1)],

    // Latency
    [layouts.fullWidth(1, widgets.note('## Latency'), height=1)],
    layouts.row(2, [
      widgets.timeseries('Response Time', {
        queries: [
          { query: 'p50:latency{service:' + service + '}', name: 'p50' },
          { query: 'p95:latency{service:' + service + '}', name: 'p95' },
          { query: 'p99:latency{service:' + service + '}', name: 'p99' }
        ]
      }, {
        custom_unit: 'ms',
        palette: 'purple',
        markers: [
          { value: 'y = 200', display_type: 'ok dashed', label: 'SLO: 200ms' },
          { value: 'y = 500', display_type: 'warning dashed', label: 'Degraded' }
        ]
      }),
    ], height=3),

    // Traffic
    [layouts.fullWidth(5, widgets.note('## Traffic'), height=1)],
    layouts.row(6, [
      widgets.timeseries('Request Rate', 'sum:requests{service:' + service + '}.as_rate()', {
        display_type: 'bars',
        palette: 'cool'
      }),
    ], height=3),

    // Errors
    [layouts.fullWidth(9, widgets.note('## Errors'), height=1)],
    layouts.row(10, [
      widgets.timeseries('Error Rate', {
        queries: [
          { query: 'sum:errors{service:' + service + '}.as_rate()', name: 'errors' },
          { query: 'sum:requests{service:' + service + '}.as_rate()', name: 'requests' }
        ],
        formulas: [{ formula: '(errors / requests) * 100' }]
      }, {
        display_type: 'bars',
        palette: 'warm',
        custom_unit: '%',
        markers: [
          { value: 'y = 1', display_type: 'warning dashed' },
          { value: 'y = 5', display_type: 'error dashed' }
        ]
      }),
    ], height=3),

    // Saturation
    [layouts.fullWidth(13, widgets.note('## Saturation'), height=1)],
    layouts.row(14, [
      widgets.timeseries('CPU', 'avg:system.cpu.user{service:' + service + '}', {
        custom_unit: '%',
        yaxis: { min: 0, max: 100 },
        markers: [{ value: 'y = 80', display_type: 'warning dashed' }]
      }),
      widgets.timeseries('Memory', {
        queries: [
          { query: 'avg:system.mem.used{service:' + service + '}', name: 'used' },
          { query: 'avg:system.mem.total{service:' + service + '}', name: 'total' }
        ],
        formulas: [{ formula: '(used / total) * 100' }]
      }, {
        custom_unit: '%',
        yaxis: { min: 0, max: 100 },
        markers: [{ value: 'y = 80', display_type: 'warning dashed' }]
      }),
    ], height=3),
  ])
)
```

### Recipe: Business Metrics Dashboard
**Revenue, conversions, user activity**

```jsonnet
local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local widgets = doggonet.widgets;

layouts.grid(
  'Business KPIs',
  std.flattenArrays([
    // Top-level KPIs
    layouts.row(0, [
      widgets.queryValue('Daily Revenue', 'sum:revenue.usd{*}', {
        precision: 2,
        custom_unit: '$',
        aggregator: 'sum'
      }),
      widgets.queryValue('New Customers', 'sum:signups.completed{*}', {
        precision: 0,
        aggregator: 'sum'
      }),
      widgets.queryValue('Conversion Rate', {
        queries: [
          { query: 'sum:conversions{*}', name: 'conversions' },
          { query: 'sum:visitors{*}', name: 'visitors' }
        ],
        formulas: [{ formula: '(conversions / visitors) * 100' }]
      }, {
        precision: 2,
        custom_unit: '%'
      }),
      widgets.queryValue('Daily Active Users', 'count_nonzero:users.active{*}', {
        precision: 0,
        aggregator: 'last',
        autoscale: true
      }),
    ], height=2),

    // Trends
    layouts.row(2, [
      widgets.timeseries('Revenue Trend', 'sum:revenue.usd{*}', {
        display_type: 'bars',
        custom_unit: '$',
        palette: 'green'
      }),
      widgets.change('User Growth', 'count_nonzero:users.active{*}', {
        compare_to: 'day_before',
        increase_good: true,
        show_present: true
      }),
    ], height=3),

    // Funnel
    layouts.row(5, [
      widgets.toplist('Top Products by Revenue', 'sum:revenue.usd{*} by {product}'),
      widgets.pieChart('Revenue by Region', 'sum:revenue.usd{*} by {region}'),
    ], height=3),
  ])
)
```

---

## Advanced Patterns

### Multi-Environment Comparison
```jsonnet
local envs = ['prod', 'staging', 'dev'];

widgets.timeseries(
  'Request Rate by Environment',
  {
    queries: [
      { query: 'sum:requests{env:' + env + '}.as_rate()', name: env }
      for env in envs
    ]
  },
  {
    display_type: 'line',
    show_legend: true
  }
)
```

### Anomaly Detection with Bands
```jsonnet
widgets.timeseries(
  'Request Rate (with anomalies)',
  'anomalies(sum:requests{*}.as_rate(), "basic", 2)',
  {
    display_type: 'area',
    palette: 'cool'
  }
)
```

### Forecast Widget
```jsonnet
widgets.timeseries(
  '7-Day Forecast',
  'forecast(avg:users.active{*}, "linear", 7)',
  {
    display_type: 'line'
  }
)
```

### SLO Tracking
```jsonnet
widgets.slo(
  'API Availability SLO',
  'slo_id_from_datadog',  // Get from Datadog UI
  {
    view_type: 'detail',
    time_windows: ['7d', '30d', '90d']
  }
)
```

### Service Map
```jsonnet
widgets.serviceMap(
  'Service Dependencies',
  { service: 'web-api', env: 'production' }
)
```

### Geographic Distribution
```jsonnet
widgets.geomap(
  'Users by Country',
  'sum:users.active{*} by {country}',
  {
    view: {
      focus: 'WORLD'
    }
  }
)
```

---

## Tips & Tricks

### Use Consistent Color Schemes
```jsonnet
local colors = {
  success: 'green',
  neutral: 'purple',
  warning: 'orange',
  error: 'warm',
  info: 'cool'
};

widgets.timeseries('Success Rate', query, { palette: colors.success })
widgets.timeseries('Error Rate', query, { palette: colors.error })
```

### Extract Common Queries
```jsonnet
local queries = {
  service: 'web-api',
  requests: function(service) 'sum:requests{service:' + service + '}',
  errors: function(service) 'sum:errors{service:' + service + '}',
  latency: function(service, percentile='p95') percentile + ':latency{service:' + service + '}'
};

// Then use:
widgets.timeseries('Requests', queries.requests(queries.service) + '.as_rate()')
```

### Reusable Widget Functions
```jsonnet
local makeErrorRateWidget = function(service)
  widgets.timeseries(
    service + ' Error Rate',
    {
      queries: [
        { query: 'sum:errors{service:' + service + '}.as_rate()', name: 'errors' },
        { query: 'sum:requests{service:' + service + '}.as_rate()', name: 'requests' }
      ],
      formulas: [{ formula: '(errors / requests) * 100' }]
    },
    { custom_unit: '%', palette: 'warm' }
  );

// Use for multiple services
layouts.row(0, [
  makeErrorRateWidget('web'),
  makeErrorRateWidget('api'),
  makeErrorRateWidget('worker')
])
```

---

## Common Metric Patterns

| Metric Pattern | Example | Widget Type | Query Modifier |
|----------------|---------|-------------|----------------|
| Counter | `requests.count` | timeseries | `.as_rate()` |
| Gauge | `users.active` | queryValue | none |
| Percentage | `cpu.percent` | timeseries | none, set yaxis 0-100 |
| Duration | `request.duration` | timeseries | none, set unit to 'ms' |
| Money | `revenue.usd` | queryValue | precision: 2, unit: '$' |
| Boolean | `service.healthy` | checkStatus | none |
| Distribution | `trace.duration` | distribution | none |
| Rate calculation | errors/total | timeseries | use formulas |

---

For more details, see:
- [LLM Guide](LLM_GUIDE.md) - Comprehensive guide for AI agents
- [Widget Reference](WIDGETS.md) - All 38 widgets
- [Preset Catalog](PRESETS.md) - Pre-configured patterns
- [Layout Guide](LAYOUTS.md) - Dashboard organization
