// doggonet - Datadog dashboard templating library
// Main entry point for the Jsonnet library
//
// Usage:
//   local doggonet = import 'doggonet/lib/main.libsonnet';
//
//   doggonet.dashboard.new('My Dashboard')
//     .addWidget(doggonet.widgets.timeseries('CPU', 'avg:system.cpu{*}'))
//

{
  // Import all library modules
  widgets:: import 'widgets.libsonnet',
  layouts:: import 'layouts.libsonnet',
  presets:: import 'presets.libsonnet',

  // Convenience aliases for common patterns
  dashboard:: self.layouts.dashboard,
  row:: self.layouts.row,

  // Version information
  version:: '0.1.0',
}
