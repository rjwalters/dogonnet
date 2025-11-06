// Basic Dashboard Example
//
// This example shows the simplest way to create a Datadog dashboard
// with a few timeseries widgets.

local doggonet = import '../src/doggonet/lib/main.libsonnet';

local layouts = doggonet.layouts;
local widgets = doggonet.widgets;

layouts.grid(
  'Basic Dashboard',
  std.flattenArrays([
    // Row 1: Key metrics
    layouts.row(0, [
      widgets.timeseries(
        'CPU Usage',
        'avg:system.cpu.user{*}',
        { display_type: 'area', palette: 'warm' }
      ),
      widgets.timeseries(
        'Memory Usage',
        'avg:system.mem.used{*}',
        { display_type: 'area', palette: 'cool' }
      ),
    ], height=3),

    // Row 2: Request metrics
    layouts.row(3, [
      widgets.timeseries(
        'Request Rate',
        'sum:http.requests{*}.as_rate()',
        { display_type: 'bars' }
      ),
      widgets.timeseries(
        'Error Rate',
        'sum:http.errors{*}.as_rate()',
        { display_type: 'line', palette: 'red' }
      ),
    ], height=3),
  ]),
  {
    description: 'Basic system and application metrics',
    tags: ['team:platform', 'env:production'],
  }
)
