// Service Health Dashboard Example
//
// This example demonstrates a comprehensive service health dashboard
// using presets for quick setup with smart defaults.

local doggonet = import '../src/doggonet/lib/main.libsonnet';

local layouts = doggonet.layouts;
local widgets = doggonet.widgets;
local presets = doggonet.presets;

local service = 'my-service';

layouts.grid(
  'Service Health - ' + service,
  std.flattenArrays([
    // Row 1: Top-level gauges
    layouts.row(0, [
      presets.requestCountGauge(
        'Total Requests',
        'sum:http.requests{service:' + service + '}.as_count()'
      ),
      presets.errorRateGauge(
        'Error Rate',
        'sum:http.errors{service:' + service + '}.as_rate() / sum:http.requests{service:' + service + '}.as_rate()'
      ),
      presets.latencyGauge(
        'P95 Latency',
        'p95:http.request.duration{service:' + service + '}'
      ),
      presets.activeUsersGauge(
        'Active Users',
        'sum:users.active{service:' + service + '}'
      ),
    ], height=2),

    // Row 2: Request and error trends
    layouts.row(2, [
      presets.requestRateTimeseries(
        'Request Rate',
        'sum:http.requests{service:' + service + '}.as_rate()'
      ),
      presets.errorRateTimeseries(
        'Error Rate',
        'sum:http.errors{service:' + service + '}.as_rate()'
      ),
    ], height=3),

    // Row 3: Performance metrics
    layouts.row(5, [
      presets.latencyTimeseries(
        'Request Latency',
        'avg:http.request.duration{service:' + service + '}'
      ),
      presets.requestRateTimeseries(
        'Throughput',
        'sum:http.requests{service:' + service + '}.as_rate()'
      ),
    ], height=3),

    // Row 4: Resource usage
    layouts.row(8, [
      presets.cpuTimeseries(
        'CPU Usage',
        'avg:system.cpu.user{service:' + service + '}'
      ),
      presets.memoryTimeseries(
        'Memory Usage',
        'avg:system.mem.used{service:' + service + '}'
      ),
      widgets.timeseries(
        'Disk Usage',
        'avg:system.disk.used{service:' + service + '}',
        { display_type: 'area', palette: 'purple' }
      ),
    ], height=3),

    // Row 5: Top endpoints
    layouts.row(11, [
      widgets.toplist(
        'Top Endpoints by Request Count',
        'sum:http.requests{service:' + service + '} by {endpoint}.as_count()',
        { limit: 10 }
      ),
      widgets.toplist(
        'Top Endpoints by Error Rate',
        'sum:http.errors{service:' + service + '} by {endpoint}.as_rate()',
        { limit: 10 }
      ),
    ], height=4),
  ]),
  {
    description: 'Comprehensive health monitoring for ' + service,
    tags: ['service:' + service, 'type:health'],
  }
)
