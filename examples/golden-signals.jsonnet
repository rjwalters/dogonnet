// Golden Signals Dashboard - The 4 critical metrics for service health
// Based on Google SRE best practices
//
// Replace 'payment-api' with your service name

local doggonet = import 'doggonet/lib/main.libsonnet';
local layouts = doggonet.layouts;
local widgets = doggonet.widgets;

// Configuration
local service = 'payment-api';
local env = 'production';

// Build filter
local filter = '{service:' + service + ',env:' + env + '}';

layouts.grid(
  'Golden Signals: ' + service,
  std.flattenArrays([
    // Header
    [layouts.fullWidth(0, widgets.note(
      '# Golden Signals Dashboard\n\n' +
      'The four critical metrics: **Latency** • **Traffic** • **Errors** • **Saturation**\n\n' +
      'Service: `' + service + '` | Environment: `' + env + '`',
      {
        background_color: 'blue',
        font_size: '18',
        text_align: 'center'
      }
    ), height=2)],

    // Signal 1: LATENCY
    [layouts.fullWidth(2, widgets.note('## 1. Latency\nHow long do requests take?', {
      background_color: 'gray',
      font_size: '16'
    }), height=1)],

    // Latency gauges
    layouts.row(3, [
      widgets.queryValue('P50 Latency', 'p50:request.duration' + filter, {
        precision: 0,
        custom_unit: 'ms',
        aggregator: 'avg'
      }),
      widgets.queryValue('P95 Latency', 'p95:request.duration' + filter, {
        precision: 0,
        custom_unit: 'ms',
        aggregator: 'avg'
      }),
      widgets.queryValue('P99 Latency', 'p99:request.duration' + filter, {
        precision: 0,
        custom_unit: 'ms',
        aggregator: 'avg'
      }),
    ], height=2),

    // Latency trend
    layouts.row(5, [
      widgets.timeseries('Latency Percentiles', {
        queries: [
          { query: 'p50:request.duration' + filter, name: 'p50' },
          { query: 'p95:request.duration' + filter, name: 'p95' },
          { query: 'p99:request.duration' + filter, name: 'p99' }
        ]
      }, {
        custom_unit: 'ms',
        palette: 'purple',
        line_width: 'thick',
        show_legend: true,
        markers: [
          { value: 'y = 200', display_type: 'ok dashed', label: 'SLO: 200ms' },
          { value: 'y = 500', display_type: 'warning dashed', label: 'Degraded: 500ms' },
          { value: 'y = 1000', display_type: 'error dashed', label: 'Critical: 1s' }
        ]
      }),
    ], height=3),

    // Signal 2: TRAFFIC
    [layouts.fullWidth(8, widgets.note('## 2. Traffic\nHow many requests are we serving?', {
      background_color: 'gray',
      font_size: '16'
    }), height=1)],

    // Traffic gauge
    layouts.row(9, [
      widgets.queryValue('Requests/min', 'sum:http.requests' + filter + '.as_rate() * 60', {
        precision: 0,
        aggregator: 'avg',
        autoscale: true
      }),
      widgets.queryValue('Peak RPS', 'max:http.requests' + filter + '.as_rate()', {
        precision: 0,
        aggregator: 'max',
        custom_unit: 'req/s',
        autoscale: true
      }),
    ], height=2),

    // Traffic trend
    layouts.row(11, [
      widgets.timeseries('Request Rate', 'sum:http.requests' + filter + '.as_rate()', {
        display_type: 'bars',
        palette: 'cool',
        custom_unit: 'req/s'
      }),
    ], height=3),

    // Signal 3: ERRORS
    [layouts.fullWidth(14, widgets.note('## 3. Errors\nHow many requests are failing?', {
      background_color: 'gray',
      font_size: '16'
    }), height=1)],

    // Error gauges
    layouts.row(15, [
      widgets.queryValue('Error Rate', {
        queries: [
          { query: 'sum:http.errors' + filter + '.as_rate()', name: 'errors' },
          { query: 'sum:http.requests' + filter + '.as_rate()', name: 'requests' }
        ],
        formulas: [
          { formula: '(errors / requests) * 100', alias: 'Error %' }
        ]
      }, {
        precision: 2,
        custom_unit: '%',
        aggregator: 'avg'
      }),
      widgets.queryValue('Total Errors/min', 'sum:http.errors' + filter + '.as_rate() * 60', {
        precision: 0,
        aggregator: 'avg',
        autoscale: true
      }),
    ], height=2),

    // Error trend
    layouts.row(17, [
      widgets.timeseries('Error Rate %', {
        queries: [
          { query: 'sum:http.errors' + filter + '.as_rate()', name: 'errors' },
          { query: 'sum:http.requests' + filter + '.as_rate()', name: 'requests' }
        ],
        formulas: [
          { formula: '(errors / requests) * 100', alias: 'Error %' }
        ]
      }, {
        display_type: 'bars',
        palette: 'warm',
        custom_unit: '%',
        markers: [
          { value: 'y = 0.1', display_type: 'ok dashed', label: 'Target: < 0.1%' },
          { value: 'y = 1', display_type: 'warning dashed', label: 'Warning: 1%' },
          { value: 'y = 5', display_type: 'error dashed', label: 'Critical: 5%' }
        ]
      }),
      widgets.toplist('Top Error Types', 'sum:http.errors' + filter + ' by {error_type}'),
    ], height=3),

    // Signal 4: SATURATION
    [layouts.fullWidth(20, widgets.note('## 4. Saturation\nHow full is the system?', {
      background_color: 'gray',
      font_size: '16'
    }), height=1)],

    // Saturation gauges
    layouts.row(21, [
      widgets.queryValue('Avg CPU %', 'avg:system.cpu.user' + filter, {
        precision: 1,
        custom_unit: '%',
        aggregator: 'avg'
      }),
      widgets.queryValue('Avg Memory %', {
        queries: [
          { query: 'avg:system.mem.used' + filter, name: 'used' },
          { query: 'avg:system.mem.total' + filter, name: 'total' }
        ],
        formulas: [
          { formula: '(used / total) * 100' }
        ]
      }, {
        precision: 1,
        custom_unit: '%',
        aggregator: 'avg'
      }),
      widgets.queryValue('Active Connections', 'avg:connections.active' + filter, {
        precision: 0,
        aggregator: 'avg',
        autoscale: true
      }),
    ], height=2),

    // Saturation trends
    layouts.row(23, [
      widgets.timeseries('CPU Saturation', 'avg:system.cpu.user' + filter, {
        display_type: 'area',
        palette: 'warm',
        custom_unit: '%',
        yaxis: { min: 0, max: 100 },
        markers: [
          { value: 'y = 80', display_type: 'warning dashed', label: 'High: 80%' },
          { value: 'y = 95', display_type: 'error dashed', label: 'Critical: 95%' }
        ]
      }),
      widgets.timeseries('Memory Saturation', {
        queries: [
          { query: 'avg:system.mem.used' + filter, name: 'used' },
          { query: 'avg:system.mem.total' + filter, name: 'total' }
        ],
        formulas: [
          { formula: '(used / total) * 100', alias: 'Memory %' }
        ]
      }, {
        display_type: 'area',
        palette: 'purple',
        custom_unit: '%',
        yaxis: { min: 0, max: 100 },
        markers: [
          { value: 'y = 80', display_type: 'warning dashed', label: 'High: 80%' },
          { value: 'y = 90', display_type: 'error dashed', label: 'Critical: 90%' }
        ]
      }),
    ], height=3),

    // Top hosts by resource usage
    layouts.row(26, [
      widgets.toplist('Top Hosts by CPU', 'avg:system.cpu.user' + filter + ' by {host}'),
      widgets.toplist('Top Hosts by Memory', 'avg:system.mem.used' + filter + ' by {host}'),
    ], height=3),
  ]),
  {
    description: 'Golden Signals monitoring for ' + service + ' (' + env + ')',
    template_variables: [
      {
        name: 'service',
        prefix: 'service',
        default: service
      },
      {
        name: 'env',
        prefix: 'env',
        default: env
      }
    ]
  }
)
