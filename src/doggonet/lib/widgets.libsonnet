// Widget library - Primitive widget builders for Datadog dashboards
// Inspired by Grafana's Grafonnet
//
// This library provides LLM-friendly, progressively-disclosed widget builders.
// Each widget follows the pattern: simple string query → options object → advanced object
//
// Documentation conventions:
// - @widget: Widget type name
// - @purpose: What this widget is used for
// - @simple: Simplest usage with just title and query
// - @options: Common customization options
// - @advanced: Full control with complex queries/formulas
// - @enum: Valid values for an option
// - @related: Similar or related widgets
// - @docs: Link to Datadog documentation
//
// Example search keywords for LLMs:
// - "timeseries chart line graph" → timeseries()
// - "single number metric gauge" → queryValue()
// - "ranked list top n" → toplist()
// - "text header markdown note" → note()
// - "heatmap density" → heatmap()

{
  // ========== TIMESERIES WIDGET ==========
  //
  // @widget: timeseries
  // @purpose: Display metric trends over time as lines, bars, or areas
  // @use_cases: CPU usage, memory trends, request rates, latency over time
  //
  // @simple: widgets.timeseries('CPU Usage', 'avg:system.cpu{*}')
  //
  // @options: Customize appearance and behavior
  //   - display_type: 'line' | 'bars' | 'area' (default: 'line')
  //   - palette: 'dog_classic' | 'warm' | 'cool' | 'purple' | 'orange' | 'gray' (default: 'dog_classic')
  //   - line_type: 'solid' | 'dashed' | 'dotted' (default: 'solid')
  //   - line_width: 'thin' | 'normal' | 'thick' (default: 'normal')
  //   - show_legend: true | false (default: false)
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //   - markers: Array of reference lines (e.g., SLO thresholds)
  //
  // @example_moderate:
  //   widgets.timeseries('CPU Usage', 'avg:system.cpu{*}', {
  //     display_type: 'area',
  //     palette: 'warm',
  //     show_legend: true,
  //   })
  //
  // @example_advanced:
  //   widgets.timeseries('CPU Usage', 'avg:system.cpu{*}', {
  //     markers: [
  //       { label: 'Warning', value: 'y = 80', display_type: 'warning dashed' },
  //       { label: 'Critical', value: 'y = 95', display_type: 'error dashed' },
  //     ],
  //   })
  //
  // @related: queryValue, heatmap, distribution
  // @docs: https://docs.datadoghq.com/dashboards/widgets/timeseries/
  //
  timeseries(title, query, options={}):: {
    definition: {
      type: 'timeseries',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      show_legend: if std.objectHas(options, 'show_legend') then options.show_legend else false,
      legend_layout: 'auto',
      legend_columns: ['avg', 'min', 'max', 'value', 'sum'],
      time: {},
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'timeseries',
          style: {
            order_by: 'values',
            palette: if std.objectHas(options, 'palette') then options.palette else 'dog_classic',
            line_type: if std.objectHas(options, 'line_type') then options.line_type else 'solid',
            line_width: if std.objectHas(options, 'line_width') then options.line_width else 'normal',
          },
          display_type: if std.objectHas(options, 'display_type') then options.display_type else 'line',
        },
      ],
      [if std.objectHas(options, 'markers') then 'markers']: options.markers,
    },
  },

  // ========== QUERY VALUE WIDGET ==========
  //
  // @widget: queryValue
  // @purpose: Display a single metric value as a large number (gauge/counter)
  // @use_cases: Current request count, active users, error rate, uptime percentage
  //
  // @simple: widgets.queryValue('Active Users', 'sum:app.users.active{*}')
  //
  // @options: Customize display and aggregation
  //   - precision: Number of decimal places (default: 2)
  //   - aggregator: 'avg' | 'sum' | 'min' | 'max' | 'last' (default: 'avg')
  //   - autoscale: true (default) | false - automatic unit scaling (e.g., 1000 → 1K)
  //   - custom_unit: Custom unit string (e.g., 'req/s', '%', 'ms')
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.queryValue('Error Rate', 'avg:app.errors.rate{*}', {
  //     precision: 1,
  //     custom_unit: '%',
  //     autoscale: false,
  //   })
  //
  // @example_advanced:
  //   widgets.queryValue('Total Requests', 'sum:app.requests{*}', {
  //     precision: 0,
  //     aggregator: 'sum',
  //     autoscale: true,
  //   })
  //
  // @related: timeseries, change, toplist
  // @docs: https://docs.datadoghq.com/dashboards/widgets/query_value/
  //
  queryValue(title, query, options={}):: {
    definition: {
      type: 'query_value',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      precision: if std.objectHas(options, 'precision') then options.precision else 2,
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
              aggregator: if std.objectHas(options, 'aggregator') then options.aggregator else 'avg',
            },
          ],
          response_format: 'scalar',
        },
      ],
      autoscale: if std.objectHas(options, 'autoscale') then options.autoscale else true,
      [if std.objectHas(options, 'custom_unit') then 'custom_unit']: options.custom_unit,
    },
  },

  // ========== TOPLIST WIDGET ==========
  //
  // @widget: toplist
  // @purpose: Display ranked list of metric values (top N)
  // @use_cases: Top hosts by CPU, busiest services, highest error rates
  //
  // @simple: widgets.toplist('Top Hosts by CPU', 'avg:system.cpu{*} by {host}')
  //
  // @options: Customize display
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.toplist('Busiest Services', 'sum:requests{*} by {service}', {
  //     title_size: '18',
  //   })
  //
  // @related: queryValue, table, heatmap
  // @docs: https://docs.datadoghq.com/dashboards/widgets/top_list/
  //
  toplist(title, query, options={}):: {
    definition: {
      type: 'toplist',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'scalar',
        },
      ],
    },
  },

  // ========== NOTE WIDGET ==========
  //
  // @widget: note
  // @purpose: Display text, markdown, or section headers
  // @use_cases: Dashboard titles, section dividers, documentation, alerts
  //
  // @simple: widgets.note('## Performance Metrics')
  //
  // @options: Customize appearance
  //   - background_color: 'white' (default) | 'blue' | 'purple' | 'gray' | 'yellow' | 'red'
  //   - font_size: '14' (default) | '16' | '18' | '20'
  //   - text_align: 'left' (default) | 'center' | 'right'
  //   - vertical_align: 'top' (default) | 'center' | 'bottom'
  //   - show_tick: false (default) | true - show pointer arrow
  //   - tick_pos: '50%' (default) - position of pointer arrow
  //   - tick_edge: 'left' (default) | 'right' | 'top' | 'bottom'
  //   - has_padding: true (default) | false
  //
  // @example_moderate:
  //   widgets.note('## System Health', {
  //     background_color: 'blue',
  //     font_size: '18',
  //     text_align: 'center',
  //   })
  //
  // @example_advanced:
  //   widgets.note('**Alert**: High CPU usage detected\n\nCheck logs for details', {
  //     background_color: 'red',
  //     show_tick: true,
  //     tick_edge: 'left',
  //   })
  //
  // @related: group (for organizing widgets)
  // @docs: https://docs.datadoghq.com/dashboards/widgets/note/
  //
  note(content, options={}):: {
    definition: {
      type: 'note',
      content: content,
      background_color: if std.objectHas(options, 'background_color') then options.background_color else 'white',
      font_size: if std.objectHas(options, 'font_size') then options.font_size else '14',
      text_align: if std.objectHas(options, 'text_align') then options.text_align else 'left',
      vertical_align: if std.objectHas(options, 'vertical_align') then options.vertical_align else 'top',
      show_tick: if std.objectHas(options, 'show_tick') then options.show_tick else false,
      tick_pos: if std.objectHas(options, 'tick_pos') then options.tick_pos else '50%',
      tick_edge: if std.objectHas(options, 'tick_edge') then options.tick_edge else 'left',
      has_padding: if std.objectHas(options, 'has_padding') then options.has_padding else true,
    },
  },

  // ========== HEATMAP WIDGET ==========
  //
  // @widget: heatmap
  // @purpose: Display metric distribution as a density plot (color intensity)
  // @use_cases: Latency distributions, request duration patterns, host metrics
  //
  // @simple: widgets.heatmap('Request Latency', 'avg:request.duration{*} by {host}')
  //
  // @options: Customize display
  //   - palette: 'dog_classic' (default) | 'warm' | 'cool' | 'purple' | 'orange'
  //   - show_legend: true (default) | false
  //   - legend_size: '0' (default) | '2' | '4' | '8'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //   - include_zero: true (default) | false - Y-axis starts at zero
  //   - scale: 'linear' (default) | 'log' | 'sqrt'
  //
  // @example_moderate:
  //   widgets.heatmap('Response Time Distribution', 'avg:response.time{*}', {
  //     palette: 'warm',
  //     show_legend: true,
  //   })
  //
  // @related: timeseries, distribution, toplist
  // @docs: https://docs.datadoghq.com/dashboards/widgets/heatmap/
  //
  heatmap(title, query, options={}):: {
    definition: {
      type: 'heatmap',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      show_legend: if std.objectHas(options, 'show_legend') then options.show_legend else true,
      legend_size: if std.objectHas(options, 'legend_size') then options.legend_size else '0',
      time: {},
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'timeseries',
          style: {
            palette: if std.objectHas(options, 'palette') then options.palette else 'dog_classic',
          },
        },
      ],
      yaxis: {
        include_zero: if std.objectHas(options, 'include_zero') then options.include_zero else true,
        scale: if std.objectHas(options, 'scale') then options.scale else 'linear',
      },
    },
  },

  // ========== CHANGE WIDGET ==========
  //
  // @widget: change
  // @purpose: Display metric change compared to a previous time period
  // @use_cases: Day-over-day changes, week-over-week trends, growth metrics
  //
  // @simple: widgets.change('Daily Active Users Change', 'avg:users.active{*}')
  //
  // @options: Customize comparison
  //   - compare_to: 'hour_before' (default) | 'day_before' | 'week_before' | 'month_before'
  //   - increase_good: true (default) | false - green for increase vs decrease
  //   - order_by: 'change' (default) | 'name' | 'present' | 'past'
  //   - order_dir: 'desc' (default) | 'asc'
  //   - show_present: true (default) | false - show current value
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.change('Weekly Revenue Growth', 'sum:revenue{*}', {
  //     compare_to: 'week_before',
  //     increase_good: true,
  //   })
  //
  // @example_advanced:
  //   widgets.change('Error Rate Change', 'avg:errors.rate{*}', {
  //     compare_to: 'day_before',
  //     increase_good: false,  // Increase in errors is bad
  //     order_by: 'change',
  //   })
  //
  // @related: queryValue, timeseries
  // @docs: https://docs.datadoghq.com/dashboards/widgets/change/
  //
  change(title, query, options={}):: {
    definition: {
      type: 'change',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      time: {},
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'scalar',
          compare_to: if std.objectHas(options, 'compare_to') then options.compare_to else 'hour_before',
          increase_good: if std.objectHas(options, 'increase_good') then options.increase_good else true,
          order_by: if std.objectHas(options, 'order_by') then options.order_by else 'change',
          order_dir: if std.objectHas(options, 'order_dir') then options.order_dir else 'desc',
          show_present: if std.objectHas(options, 'show_present') then options.show_present else true,
        },
      ],
    },
  },

  // ========== DISTRIBUTION WIDGET ==========
  //
  // @widget: distribution
  // @purpose: Display histogram of metric distribution (APM/tracing focused)
  // @use_cases: Request latency histogram, span duration distribution
  //
  // @simple: widgets.distribution('Latency Distribution', 'avg:trace.duration{*}')
  //
  // @options: Customize APM query and display
  //   - stat: 'avg' (default) | 'p50' | 'p75' | 'p90' | 'p95' | 'p99' | 'max'
  //   - service: Service name filter (required for APM)
  //   - env: Environment filter
  //   - operation_name: Operation name filter
  //   - primary_tag_value: Primary tag value (default: '*')
  //   - palette: 'dog_classic' (default) | 'warm' | 'cool' | 'purple' | 'orange'
  //   - show_legend: false (default) | true
  //   - include_zero: true (default) | false - X-axis starts at zero
  //   - scale: 'linear' (default) | 'log' | 'sqrt'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.distribution('Request Duration', 'avg:trace.duration{*}', {
  //     service: 'web-api',
  //     env: 'production',
  //     palette: 'warm',
  //   })
  //
  // @note: This widget is primarily for APM/tracing data
  // @related: heatmap, timeseries
  // @docs: https://docs.datadoghq.com/dashboards/widgets/distribution/
  //
  distribution(title, query, options={}):: {
    definition: {
      type: 'distribution',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      show_legend: if std.objectHas(options, 'show_legend') then options.show_legend else false,
      time: {},
      requests: [
        {
          query: {
            stat: if std.objectHas(options, 'stat') then options.stat else 'avg',
            data_source: 'apm_resource_stats',
            name: 'query1',
            service: if std.objectHas(options, 'service') then options.service else '',
            env: if std.objectHas(options, 'env') then options.env else '',
            primary_tag_value: if std.objectHas(options, 'primary_tag_value') then options.primary_tag_value else '*',
            operation_name: if std.objectHas(options, 'operation_name') then options.operation_name else '',
          },
          request_type: 'histogram',
          style: {
            palette: if std.objectHas(options, 'palette') then options.palette else 'dog_classic',
          },
        },
      ],
      xaxis: {
        include_zero: if std.objectHas(options, 'include_zero') then options.include_zero else true,
        scale: if std.objectHas(options, 'scale') then options.scale else 'linear',
      },
      yaxis: {
        include_zero: true,
        scale: 'linear',
      },
    },
  },

  // ========== TABLE WIDGET ==========
  //
  // @widget: table
  // @purpose: Display metrics in tabular format with multiple columns
  // @use_cases: Multi-metric comparisons, service health matrices, resource inventories
  //
  // @simple: widgets.table('Service Health', 'avg:service.requests{*} by {service}')
  //
  // @options: Customize table display
  //   - has_search_bar: 'auto' (default) | 'always' | 'never'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate (single query):
  //   widgets.table('Top Services', 'avg:requests{*} by {service}', {
  //     has_search_bar: 'always',
  //   })
  //
  // @example_advanced (multiple queries with aliases):
  //   widgets.table('Service Metrics', [
  //     { query: 'avg:requests{*} by {service}', alias: 'Requests', aggregator: 'sum' },
  //     { query: 'avg:errors{*} by {service}', alias: 'Errors', aggregator: 'sum' },
  //     { query: 'avg:latency{*} by {service}', alias: 'Latency', aggregator: 'avg' },
  //   ])
  //
  // @note: Can accept single query string or array of query objects
  // @related: toplist, queryValue
  // @docs: https://docs.datadoghq.com/dashboards/widgets/table/
  //
  table(title, queries, options={}):: {
    definition: {
      type: 'query_table',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      time: {},
      requests: [
        {
          formulas: if std.isArray(queries) then [
            { formula: 'query%d' % (i + 1), alias: if std.isObject(q) && std.objectHas(q, 'alias') then q.alias else null }
            for i in std.range(0, std.length(queries) - 1)
            for q in [queries[i]]
          ] else [{ formula: 'query1' }],
          queries: if std.isArray(queries) then [
            {
              data_source: 'metrics',
              name: 'query%d' % (i + 1),
              query: if std.isObject(q) then q.query else q,
              aggregator: if std.isObject(q) && std.objectHas(q, 'aggregator') then q.aggregator else 'avg',
            }
            for i in std.range(0, std.length(queries) - 1)
            for q in [queries[i]]
          ] else [
            {
              data_source: 'metrics',
              name: 'query1',
              query: queries,
              aggregator: 'avg',
            },
          ],
          response_format: 'scalar',
        },
      ],
      has_search_bar: if std.objectHas(options, 'has_search_bar') then options.has_search_bar else 'auto',
    },
  },

  // ========== GROUP WIDGET ==========
  //
  // @widget: group
  // @purpose: Container for organizing related widgets into sections
  // @use_cases: Logical grouping, collapsible sections, visual organization
  //
  // @simple: widgets.group('Database Metrics', [widget1, widget2, widget3])
  //
  // @options: Customize group appearance
  //   - layout_type: 'ordered' (default) | 'free' - grid vs free positioning
  //   - background_color: 'vivid_blue' (default) | 'vivid_purple' | 'vivid_pink' | 'vivid_orange' | 'vivid_yellow' | 'vivid_green' | 'gray'
  //   - show_title: true (default) | false
  //
  // @example_moderate:
  //   widgets.group('API Metrics', [
  //     requestsWidget,
  //     latencyWidget,
  //     errorsWidget,
  //   ], {
  //     background_color: 'vivid_purple',
  //   })
  //
  // @example_advanced:
  //   widgets.group('Infrastructure', infrastructureWidgets, {
  //     layout_type: 'free',
  //     background_color: 'gray',
  //     show_title: true,
  //   })
  //
  // @related: note (for section headers)
  // @docs: https://docs.datadoghq.com/dashboards/widgets/group/
  //
  group(title, widgets, options={}):: {
    definition: {
      type: 'group',
      title: title,
      layout_type: if std.objectHas(options, 'layout_type') then options.layout_type else 'ordered',
      widgets: widgets,
      background_color: if std.objectHas(options, 'background_color') then options.background_color else 'vivid_blue',
      show_title: if std.objectHas(options, 'show_title') then options.show_title else true,
    },
  },

  // ========== SCATTER PLOT WIDGET ==========
  //
  // @widget: scatterplot
  // @purpose: Display correlation between two metrics as scatter plot
  // @use_cases: Resource correlation, metric relationships, outlier detection
  //
  // @simple: widgets.scatterplot('CPU vs Memory', 'avg:system.cpu{*}', 'avg:system.mem{*}')
  //
  // @options: Customize plot appearance
  //   - color_by_groups: [] - List of tag keys to color by
  //   - xaxis: { scale: 'linear' | 'log' | 'sqrt', include_zero: true | false }
  //   - yaxis: { scale: 'linear' | 'log' | 'sqrt', include_zero: true | false }
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.scatterplot('Resource Usage', 'avg:cpu{*}', 'avg:memory{*}', {
  //     color_by_groups: ['host', 'env'],
  //   })
  //
  // @related: timeseries, heatmap
  // @docs: https://docs.datadoghq.com/dashboards/widgets/scatter_plot/
  //
  scatterplot(title, x_query, y_query, options={}):: {
    definition: {
      type: 'scatterplot',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      time: {},
      requests: {
        x: {
          formulas: [{ formula: 'query1', dimension: 'x' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: x_query,
              aggregator: 'avg',
            },
          ],
        },
        y: {
          formulas: [{ formula: 'query1', dimension: 'y' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: y_query,
              aggregator: 'avg',
            },
          ],
        },
      },
      [if std.objectHas(options, 'color_by_groups') then 'color_by_groups']: options.color_by_groups,
      xaxis: if std.objectHas(options, 'xaxis') then options.xaxis else {
        scale: 'linear',
        include_zero: true,
      },
      yaxis: if std.objectHas(options, 'yaxis') then options.yaxis else {
        scale: 'linear',
        include_zero: true,
      },
    },
  },

  // ========== PIE CHART WIDGET ==========
  //
  // @widget: sunburstWidget
  // @purpose: Display proportional breakdown of metrics as pie chart
  // @use_cases: Resource distribution, percentage breakdown, category comparison
  //
  // @simple: widgets.pieChart('Traffic by Service', 'sum:requests{*} by {service}')
  //
  // @options: Customize chart appearance
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //   - legend: { type: 'automatic' | 'inline' | 'none' }
  //
  // @example_moderate:
  //   widgets.pieChart('Errors by Status', 'sum:errors{*} by {status_code}', {
  //     legend: { type: 'inline' },
  //   })
  //
  // @related: treemap, sunburst, toplist
  // @docs: https://docs.datadoghq.com/dashboards/widgets/pie_chart/
  //
  pieChart(title, query, options={}):: {
    definition: {
      type: 'sunburst',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      time: {},
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'scalar',
        },
      ],
      legend: if std.objectHas(options, 'legend') then options.legend else {
        type: 'automatic',
      },
    },
  },

  // ========== TREEMAP WIDGET ==========
  //
  // @widget: treemap
  // @purpose: Display hierarchical data as nested rectangles
  // @use_cases: Resource hierarchies, nested categories, proportional breakdown
  //
  // @simple: widgets.treemap('Storage by Volume', 'sum:disk.used{*} by {volume,host}')
  //
  // @options: Customize treemap appearance
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.treemap('Memory by Container', 'avg:container.memory{*} by {container_name,pod}')
  //
  // @related: pieChart, sunburst, toplist
  // @docs: https://docs.datadoghq.com/dashboards/widgets/treemap/
  //
  treemap(title, query, options={}):: {
    definition: {
      type: 'treemap',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      time: {},
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'scalar',
        },
      ],
    },
  },

  // ========== GEOMAP WIDGET ==========
  //
  // @widget: geomap
  // @purpose: Display metrics on geographic map
  // @use_cases: Geographic distribution, location-based metrics, regional analysis
  //
  // @simple: widgets.geomap('Requests by Country', 'sum:requests{*} by {country}')
  //
  // @options: Customize map display
  //   - view: { focus: 'WORLD' | 'US' | 'EU' | 'ASIA' }
  //   - style: { palette: 'dog_classic' | 'warm' | 'cool' | 'purple' | 'orange' }
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.geomap('User Distribution', 'sum:users{*} by {country}', {
  //     view: { focus: 'WORLD' },
  //     style: { palette: 'warm' },
  //   })
  //
  // @related: hostmap, toplist
  // @docs: https://docs.datadoghq.com/dashboards/widgets/geomap/
  //
  geomap(title, query, options={}):: {
    definition: {
      type: 'geomap',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      time: {},
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'scalar',
        },
      ],
      view: if std.objectHas(options, 'view') then options.view else {
        focus: 'WORLD',
      },
      style: if std.objectHas(options, 'style') then options.style else {
        palette: 'dog_classic',
      },
    },
  },

  // ========== HOSTMAP WIDGET ==========
  //
  // @widget: hostmap
  // @purpose: Display infrastructure hosts as hexagonal map
  // @use_cases: Infrastructure overview, host health, resource utilization
  //
  // @simple: widgets.hostmap('Host CPU Usage', 'avg:system.cpu.user{*}')
  //
  // @options: Customize hostmap display
  //   - group: ['host', 'availability-zone'] - Grouping tags
  //   - scope: ['env:production'] - Filter scope
  //   - style: { palette: 'green_to_orange' | 'yellow_to_red' | 'YlOrRd' | 'hostmap_blues' }
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.hostmap('Production Hosts', 'avg:system.load.1{*}', {
  //     group: ['availability-zone', 'instance-type'],
  //     scope: ['env:production'],
  //     style: { palette: 'green_to_orange' },
  //   })
  //
  // @related: geomap, toplist
  // @docs: https://docs.datadoghq.com/dashboards/widgets/hostmap/
  //
  hostmap(title, query, options={}):: {
    definition: {
      type: 'hostmap',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: {
        fill: {
          q: query,
        },
      },
      [if std.objectHas(options, 'group') then 'group']: options.group,
      [if std.objectHas(options, 'scope') then 'scope']: options.scope,
      style: if std.objectHas(options, 'style') then options.style else {
        palette: 'green_to_orange',
      },
    },
  },

  // ========== ALERT GRAPH WIDGET ==========
  //
  // @widget: alert_graph
  // @purpose: Display monitor alert graph with thresholds
  // @use_cases: Monitor visualization, alert tracking, threshold display
  //
  // @simple: widgets.alertGraph('CPU Alert', 'avg:system.cpu{*}')
  //
  // @options: Customize alert visualization
  //   - viz_type: 'timeseries' (default) | 'toplist'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.alertGraph('Memory Alert', 'avg:system.mem.used{*}', {
  //     viz_type: 'timeseries',
  //   })
  //
  // @related: alert_value, monitor_summary
  // @docs: https://docs.datadoghq.com/dashboards/widgets/alert_graph/
  //
  alertGraph(title, query, options={}):: {
    definition: {
      type: 'alert_graph',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      alert_id: '',
      viz_type: if std.objectHas(options, 'viz_type') then options.viz_type else 'timeseries',
      time: {},
    },
  },

  // ========== ALERT VALUE WIDGET ==========
  //
  // @widget: alert_value
  // @purpose: Display current alert status as single value
  // @use_cases: Alert status, current state, threshold monitoring
  //
  // @simple: widgets.alertValue('Error Rate Alert', 'avg:errors{*}')
  //
  // @options: Customize alert value display
  //   - precision: 2 (default) - Decimal places
  //   - unit: 'auto' (default) | 'custom' - Unit display
  //   - text_align: 'left' (default) | 'center' | 'right'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.alertValue('Disk Alert', 'avg:disk.used{*}', {
  //     precision: 1,
  //     unit: 'auto',
  //   })
  //
  // @related: alert_graph, query_value, monitor_summary
  // @docs: https://docs.datadoghq.com/dashboards/widgets/alert_value/
  //
  alertValue(title, query, options={}):: {
    definition: {
      type: 'alert_value',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      alert_id: '',
      precision: if std.objectHas(options, 'precision') then options.precision else 2,
      unit: if std.objectHas(options, 'unit') then options.unit else 'auto',
      text_align: if std.objectHas(options, 'text_align') then options.text_align else 'left',
    },
  },

  // ========== CHECK STATUS WIDGET ==========
  //
  // @widget: check_status
  // @purpose: Display service check status
  // @use_cases: Service health, check monitoring, uptime tracking
  //
  // @simple: widgets.checkStatus('Service Health', 'http.can_connect')
  //
  // @options: Customize check status display
  //   - grouping: 'check' (default) | 'cluster'
  //   - group: 'host' | 'service' | etc - Grouping tag
  //   - group_by: [] - List of tags to group by
  //   - tags: ['*'] (default) - Filter tags
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.checkStatus('HTTP Checks', 'http.can_connect', {
  //     grouping: 'cluster',
  //     group_by: ['host', 'env'],
  //     tags: ['env:production'],
  //   })
  //
  // @related: monitor_summary, alert_value
  // @docs: https://docs.datadoghq.com/dashboards/widgets/check_status/
  //
  checkStatus(title, check, options={}):: {
    definition: {
      type: 'check_status',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      check: check,
      grouping: if std.objectHas(options, 'grouping') then options.grouping else 'check',
      [if std.objectHas(options, 'group') then 'group']: options.group,
      [if std.objectHas(options, 'group_by') then 'group_by']: options.group_by,
      tags: if std.objectHas(options, 'tags') then options.tags else ['*'],
    },
  },

  // ========== MONITOR SUMMARY WIDGET ==========
  //
  // @widget: manage_status
  // @purpose: Display summary of monitor statuses
  // @use_cases: Monitor overview, alert summary, team dashboards
  //
  // @simple: widgets.monitorSummary('All Monitors', 'status:alert')
  //
  // @options: Customize monitor summary
  //   - color_preference: 'background' (default) | 'text'
  //   - display_format: 'counts' | 'countsAndList' (default) | 'list'
  //   - hide_zero_counts: true (default) | false
  //   - show_last_triggered: false (default) | true
  //   - summary_type: 'monitors' (default) | 'groups' | 'combined'
  //   - sort: 'status,asc' (default) | 'name,asc' | 'triggered,desc'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.monitorSummary('Critical Monitors', 'status:alert priority:1', {
  //     display_format: 'countsAndList',
  //     show_last_triggered: true,
  //   })
  //
  // @related: check_status, alert_value
  // @docs: https://docs.datadoghq.com/dashboards/widgets/monitor_summary/
  //
  monitorSummary(title, query, options={}):: {
    definition: {
      type: 'manage_status',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      query: query,
      color_preference: if std.objectHas(options, 'color_preference') then options.color_preference else 'background',
      display_format: if std.objectHas(options, 'display_format') then options.display_format else 'countsAndList',
      hide_zero_counts: if std.objectHas(options, 'hide_zero_counts') then options.hide_zero_counts else true,
      show_last_triggered: if std.objectHas(options, 'show_last_triggered') then options.show_last_triggered else false,
      summary_type: if std.objectHas(options, 'summary_type') then options.summary_type else 'monitors',
      sort: if std.objectHas(options, 'sort') then options.sort else 'status,asc',
    },
  },

  // ========== SLO WIDGET ==========
  //
  // @widget: slo
  // @purpose: Display Service Level Objective status and trends
  // @use_cases: SLO tracking, reliability metrics, error budgets
  //
  // @simple: widgets.slo('API Availability SLO', 'slo_id_here')
  //
  // @options: Customize SLO display
  //   - view_type: 'detail' (default) | 'overview'
  //   - time_windows: ['7d', '30d', '90d'] - Time windows to display
  //   - show_error_budget: true (default) | false
  //   - view_mode: 'overall' (default) | 'component'
  //   - global_time_target: '0' (default) | '7d' | '30d' | '90d'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.slo('Service Availability', 'abc123', {
  //     view_type: 'detail',
  //     time_windows: ['7d', '30d'],
  //     show_error_budget: true,
  //   })
  //
  // @related: monitor_summary, alert_value
  // @docs: https://docs.datadoghq.com/dashboards/widgets/slo/
  //
  slo(title, slo_id, options={}):: {
    definition: {
      type: 'slo',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      slo_id: slo_id,
      view_type: if std.objectHas(options, 'view_type') then options.view_type else 'detail',
      time_windows: if std.objectHas(options, 'time_windows') then options.time_windows else ['7d', '30d', '90d'],
      show_error_budget: if std.objectHas(options, 'show_error_budget') then options.show_error_budget else true,
      view_mode: if std.objectHas(options, 'view_mode') then options.view_mode else 'overall',
      global_time_target: if std.objectHas(options, 'global_time_target') then options.global_time_target else '0',
    },
  },

  // ========== SERVICE MAP WIDGET ==========
  //
  // @widget: servicemap
  // @purpose: Display service dependencies and flow
  // @use_cases: Microservice architecture, dependency mapping, service health
  //
  // @simple: widgets.serviceMap('Service Dependencies', 'web-api')
  //
  // @options: Customize service map
  //   - filters: ['env:production'] - Service filters
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.serviceMap('Production Services', 'web-api', {
  //     filters: ['env:production', 'team:backend'],
  //   })
  //
  // @related: hostmap, service_summary
  // @docs: https://docs.datadoghq.com/dashboards/widgets/service_map/
  //
  serviceMap(title, service, options={}):: {
    definition: {
      type: 'servicemap',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      service: service,
      [if std.objectHas(options, 'filters') then 'filters']: options.filters,
    },
  },

  // ========== SERVICE SUMMARY WIDGET ==========
  //
  // @widget: trace_service
  // @purpose: Display APM service summary with key metrics
  // @use_cases: Service health, APM overview, request/error/latency tracking
  //
  // @simple: widgets.serviceSummary('API Service', 'web-api', 'production')
  //
  // @options: Customize service summary
  //   - span_name: 'servlet.request' - Specific span to track
  //   - show_hits: true (default) | false
  //   - show_errors: true (default) | false
  //   - show_latency: true (default) | false
  //   - show_breakdown: true (default) | false
  //   - show_distribution: true (default) | false
  //   - show_resource_list: true (default) | false
  //   - size_format: 'small' | 'medium' (default) | 'large'
  //   - display_format: 'one_column' (default) | 'two_column' | 'three_column'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.serviceSummary('API Overview', 'web-api', 'prod', {
  //     show_breakdown: true,
  //     display_format: 'two_column',
  //   })
  //
  // @related: serviceMap, timeseries
  // @docs: https://docs.datadoghq.com/dashboards/widgets/service_summary/
  //
  serviceSummary(title, service, env, options={}):: {
    definition: {
      type: 'trace_service',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      env: env,
      service: service,
      [if std.objectHas(options, 'span_name') then 'span_name']: options.span_name,
      show_hits: if std.objectHas(options, 'show_hits') then options.show_hits else true,
      show_errors: if std.objectHas(options, 'show_errors') then options.show_errors else true,
      show_latency: if std.objectHas(options, 'show_latency') then options.show_latency else true,
      show_breakdown: if std.objectHas(options, 'show_breakdown') then options.show_breakdown else true,
      show_distribution: if std.objectHas(options, 'show_distribution') then options.show_distribution else true,
      show_resource_list: if std.objectHas(options, 'show_resource_list') then options.show_resource_list else true,
      size_format: if std.objectHas(options, 'size_format') then options.size_format else 'medium',
      display_format: if std.objectHas(options, 'display_format') then options.display_format else 'one_column',
    },
  },

  // ========== EVENT STREAM WIDGET ==========
  //
  // @widget: event_stream
  // @purpose: Display stream of events matching a query
  // @use_cases: Deployment tracking, alert history, audit logs
  //
  // @simple: widgets.eventStream('Deployments', 'tags:deployment')
  //
  // @options: Customize event stream
  //   - event_size: 's' (default) | 'l' - Small or large event display
  //   - tags_execution: 'and' (default) | 'or' - Tag matching logic
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.eventStream('Production Alerts', 'priority:high env:production', {
  //     event_size: 'l',
  //   })
  //
  // @related: event_timeline, log_stream
  // @docs: https://docs.datadoghq.com/dashboards/widgets/event_stream/
  //
  eventStream(title, query, options={}):: {
    definition: {
      type: 'event_stream',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      query: query,
      event_size: if std.objectHas(options, 'event_size') then options.event_size else 's',
      tags_execution: if std.objectHas(options, 'tags_execution') then options.tags_execution else 'and',
    },
  },

  // ========== EVENT TIMELINE WIDGET ==========
  //
  // @widget: event_timeline
  // @purpose: Display events as timeline visualization
  // @use_cases: Deployment timeline, incident tracking, change history
  //
  // @simple: widgets.eventTimeline('Deploy Timeline', 'tags:deployment')
  //
  // @options: Customize event timeline
  //   - tags_execution: 'and' (default) | 'or' - Tag matching logic
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.eventTimeline('Change Events', 'source:jenkins,github', {
  //     tags_execution: 'or',
  //   })
  //
  // @related: event_stream, timeseries
  // @docs: https://docs.datadoghq.com/dashboards/widgets/event_timeline/
  //
  eventTimeline(title, query, options={}):: {
    definition: {
      type: 'event_timeline',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      query: query,
      tags_execution: if std.objectHas(options, 'tags_execution') then options.tags_execution else 'and',
    },
  },

  // ========== LOG STREAM WIDGET ==========
  //
  // @widget: log_stream
  // @purpose: Display live stream of log entries
  // @use_cases: Error tracking, application logs, debugging
  //
  // @simple: widgets.logStream('Error Logs', 'status:error service:web-api')
  //
  // @options: Customize log stream
  //   - columns: ['host', 'service'] - Columns to display
  //   - show_date_column: true (default) | false
  //   - show_message_column: true (default) | false
  //   - message_display: 'inline' (default) | 'expanded-md' | 'expanded-lg'
  //   - sort: { column: 'time', order: 'desc' }
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.logStream('Application Errors', 'status:error', {
  //     columns: ['host', 'service', 'message'],
  //     message_display: 'expanded-md',
  //   })
  //
  // @related: event_stream, list
  // @docs: https://docs.datadoghq.com/dashboards/widgets/log_stream/
  //
  logStream(title, query, options={}):: {
    definition: {
      type: 'log_stream',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      query: query,
      [if std.objectHas(options, 'columns') then 'columns']: options.columns,
      show_date_column: if std.objectHas(options, 'show_date_column') then options.show_date_column else true,
      show_message_column: if std.objectHas(options, 'show_message_column') then options.show_message_column else true,
      message_display: if std.objectHas(options, 'message_display') then options.message_display else 'inline',
      [if std.objectHas(options, 'sort') then 'sort']: options.sort,
    },
  },

  // ========== LIST WIDGET ==========
  //
  // @widget: list_stream
  // @purpose: Display list of events, issues, or logs
  // @use_cases: Issue tracking, audit lists, filtered event lists
  //
  // @simple: widgets.list('Open Issues', 'status:open', 'issue')
  //
  // @options: Customize list widget
  //   - source: 'issue' | 'logs' | 'rum' | 'event' | 'audit'
  //   - columns: [] - Columns to display
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.list('Security Audit', 'resource_type:api_key', 'audit', {
  //     columns: ['timestamp', 'user', 'action'],
  //   })
  //
  // @related: log_stream, event_stream
  // @docs: https://docs.datadoghq.com/dashboards/widgets/list/
  //
  list(title, query, source, options={}):: {
    definition: {
      type: 'list_stream',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          columns: if std.objectHas(options, 'columns') then options.columns else [],
          query: {
            data_source: source,
            query_string: query,
          },
          response_format: 'event_list',
        },
      ],
    },
  },

  // ========== FREE TEXT WIDGET ==========
  //
  // @widget: free_text
  // @purpose: Display free-form text with customization
  // @use_cases: Headers, instructions, custom formatting
  //
  // @simple: widgets.freeText('Dashboard Title', 'My Dashboard')
  //
  // @options: Customize text display
  //   - color: '#000000' - Text color (hex)
  //   - font_size: '36' (default) | '48' | '60' | '72'
  //   - text_align: 'left' | 'center' (default) | 'right'
  //
  // @example_moderate:
  //   widgets.freeText('Section Header', 'Production Metrics', {
  //     color: '#FF6B6B',
  //     font_size: '48',
  //     text_align: 'center',
  //   })
  //
  // @related: note, image
  // @docs: https://docs.datadoghq.com/dashboards/widgets/free_text/
  //
  freeText(title, text, options={}):: {
    definition: {
      type: 'free_text',
      text: text,
      color: if std.objectHas(options, 'color') then options.color else '#000000',
      font_size: if std.objectHas(options, 'font_size') then options.font_size else '36',
      text_align: if std.objectHas(options, 'text_align') then options.text_align else 'center',
    },
  },

  // ========== IMAGE WIDGET ==========
  //
  // @widget: image
  // @purpose: Display image from URL
  // @use_cases: Logos, diagrams, architecture illustrations
  //
  // @simple: widgets.image('https://example.com/diagram.png')
  //
  // @options: Customize image display
  //   - sizing: 'fit' (default) | 'fill' | 'center' | 'tile' | 'zoom'
  //   - margin: 'small' | 'medium' (default) | 'large'
  //   - has_background: true (default) | false
  //   - has_border: true (default) | false
  //   - vertical_align: 'top' | 'center' (default) | 'bottom'
  //   - horizontal_align: 'left' | 'center' (default) | 'right'
  //
  // @example_moderate:
  //   widgets.image('https://example.com/arch.png', {
  //     sizing: 'fit',
  //     has_border: false,
  //   })
  //
  // @related: note, free_text
  // @docs: https://docs.datadoghq.com/dashboards/widgets/image/
  //
  image(url, options={}):: {
    definition: {
      type: 'image',
      url: url,
      sizing: if std.objectHas(options, 'sizing') then options.sizing else 'fit',
      margin: if std.objectHas(options, 'margin') then options.margin else 'medium',
      has_background: if std.objectHas(options, 'has_background') then options.has_background else true,
      has_border: if std.objectHas(options, 'has_border') then options.has_border else true,
      vertical_align: if std.objectHas(options, 'vertical_align') then options.vertical_align else 'center',
      horizontal_align: if std.objectHas(options, 'horizontal_align') then options.horizontal_align else 'center',
    },
  },

  // ========== IFRAME WIDGET ==========
  //
  // @widget: iframe
  // @purpose: Embed external content via iframe
  // @use_cases: External dashboards, documentation, web content
  //
  // @simple: widgets.iframe('https://example.com/dashboard')
  //
  // @options: No additional options
  //
  // @example_moderate:
  //   widgets.iframe('https://grafana.example.com/d/abc123')
  //
  // @related: image, note
  // @docs: https://docs.datadoghq.com/dashboards/widgets/iframe/
  //
  iframe(url, options={}):: {
    definition: {
      type: 'iframe',
      url: url,
    },
  },

  // ========== FUNNEL WIDGET ==========
  //
  // @widget: funnel
  // @purpose: Display conversion funnel analytics
  // @use_cases: User journeys, conversion tracking, drop-off analysis
  //
  // @simple: widgets.funnel('Signup Funnel', [query1, query2, query3])
  //
  // @options: Customize funnel display
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.funnel('Purchase Flow', [
  //     'source:rum @view.name:"product-page"',
  //     'source:rum @view.name:"cart"',
  //     'source:rum @view.name:"checkout"',
  //   ])
  //
  // @related: timeseries, distribution
  // @docs: https://docs.datadoghq.com/dashboards/widgets/funnel/
  //
  funnel(title, queries, options={}):: {
    local queryArray = if std.isArray(queries) then queries else [queries],
    definition: {
      type: 'funnel',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          query: {
            data_source: 'rum',
            query_string: q,
          },
          request_type: 'funnel',
        }
        for q in queryArray
      ],
    },
  },

  // ========== POWERPACK WIDGET ==========
  //
  // @widget: powerpack
  // @purpose: Reusable widget group template
  // @use_cases: Standardized widget sets, template reuse
  //
  // @simple: widgets.powerpack('powerpack_id_here')
  //
  // @options: Customize powerpack
  //   - template_variables: {} - Variable overrides
  //
  // @example_moderate:
  //   widgets.powerpack('abc123', {
  //     template_variables: { service: 'web-api', env: 'prod' },
  //   })
  //
  // @related: group
  // @docs: https://docs.datadoghq.com/dashboards/widgets/powerpack/
  //
  powerpack(powerpack_id, options={}):: {
    definition: {
      type: 'powerpack',
      powerpack_id: powerpack_id,
      [if std.objectHas(options, 'template_variables') then 'template_variables']: options.template_variables,
    },
  },

  // ========== BAR CHART WIDGET ==========
  //
  // @widget: bar_chart
  // @purpose: Display categorical data comparison with vertical bars
  // @use_cases: Service comparison, tag-based comparisons, category analysis
  //
  // @simple: widgets.barChart('Requests by Service', 'sum:requests{*} by {service}')
  //
  // @options: Customize bar chart display
  //   - palette: 'dog_classic' (default) | 'warm' | 'cool' | 'purple' | 'orange' | 'gray'
  //   - xaxis: { scale: 'linear' | 'log' | 'sqrt' }
  //   - yaxis: { scale: 'linear' | 'log' | 'sqrt', include_zero: true | false }
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.barChart('Response Time by Endpoint', 'avg:response.time{*} by {endpoint}', {
  //     palette: 'warm',
  //     yaxis: { scale: 'linear', include_zero: true },
  //   })
  //
  // @note: Bar charts use categorical axes (vs timeseries temporal axes)
  // @related: toplist, treemap, timeseries
  // @docs: https://docs.datadoghq.com/dashboards/widgets/bar_chart/
  //
  barChart(title, query, options={}):: {
    definition: {
      type: 'bar_chart',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'scalar',
        },
      ],
      xaxis: if std.objectHas(options, 'xaxis') then options.xaxis else {
        scale: 'linear',
      },
      yaxis: if std.objectHas(options, 'yaxis') then options.yaxis else {
        scale: 'linear',
        include_zero: true,
      },
      style: {
        palette: if std.objectHas(options, 'palette') then options.palette else 'dog_classic',
      },
    },
  },

  // ========== WILDCARD WIDGET ==========
  //
  // @widget: wildcard
  // @purpose: Create custom visualizations using Vega-Lite grammar
  // @use_cases: Custom charts, advanced visualizations, unique data representations
  //
  // @simple: widgets.wildcard('Custom Viz', vegaLiteSpec)
  //
  // @options: Customize wildcard widget
  //   - spec: Vega-Lite specification object (required)
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.wildcard('Custom Chart', {
  //     mark: 'bar',
  //     encoding: {
  //       x: { field: 'service', type: 'nominal' },
  //       y: { field: 'count', type: 'quantitative' },
  //     },
  //   })
  //
  // @note: Requires Vega-Lite spec knowledge. See Datadog docs for extensions.
  // @related: Custom visualizations, advanced graphing
  // @docs: https://docs.datadoghq.com/dashboards/widgets/wildcard/
  //
  wildcard(title, spec, options={}):: {
    definition: {
      type: 'wildcard',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      spec: spec,
    },
  },

  // ========== SPLIT GRAPH WIDGET ==========
  //
  // @widget: split_graph
  // @purpose: Create repeating graphs - one per tag value
  // @use_cases: Per-service graphs, per-host visualization, multi-instance monitoring
  //
  // @simple: widgets.splitGraph('Metrics per Service', 'avg:cpu{*} by {service}', 'service')
  //
  // @options: Customize split graph
  //   - size: 'xs' | 'sm' | 'md' (default) | 'lg' - Size of individual graphs
  //   - limit: 10 (default) - Maximum number of graphs to display
  //   - sort: { order: 'desc' | 'asc', by: 'value' | 'name' }
  //   - split_config: { split_dimensions: [{ one_graph_per: 'tag_key' }] }
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.splitGraph('CPU per Host', 'avg:system.cpu{*} by {host}', 'host', {
  //     size: 'sm',
  //     limit: 20,
  //     sort: { order: 'desc', by: 'value' },
  //   })
  //
  // @related: timeseries, group
  // @docs: https://docs.datadoghq.com/dashboards/widgets/split_graph/
  //
  splitGraph(title, query, split_by, options={}):: {
    definition: {
      type: 'split_graph',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          formulas: [{ formula: 'query1' }],
          queries: [
            {
              data_source: 'metrics',
              name: 'query1',
              query: query,
            },
          ],
          response_format: 'timeseries',
        },
      ],
      split_config: if std.objectHas(options, 'split_config') then options.split_config else {
        split_dimensions: [{ one_graph_per: split_by }],
        limit: if std.objectHas(options, 'limit') then options.limit else 10,
        sort: if std.objectHas(options, 'sort') then options.sort else { order: 'desc', by: 'value' },
      },
      size: if std.objectHas(options, 'size') then options.size else 'md',
    },
  },

  // ========== TOPOLOGY MAP WIDGET ==========
  //
  // @widget: topology_map
  // @purpose: Display service relationships and data flow
  // @use_cases: Service dependencies, architecture visualization, data flow mapping
  //
  // @simple: widgets.topologyMap('Service Map', 'my-service')
  //
  // @options: Customize topology map
  //   - filters: ['env:production'] - Filter services
  //   - data_source: 'service_map' | 'event_stream' | 'network'
  //   - custom_links: [] - Custom link configurations
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.topologyMap('Production Services', 'web-api', {
  //     filters: ['env:production', 'team:backend'],
  //     data_source: 'service_map',
  //   })
  //
  // @related: serviceMap, serviceSummary
  // @docs: https://docs.datadoghq.com/dashboards/widgets/topology_map/
  //
  topologyMap(title, service, options={}):: {
    definition: {
      type: 'topology_map',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          query: {
            data_source: if std.objectHas(options, 'data_source') then options.data_source else 'service_map',
            service: service,
            [if std.objectHas(options, 'filters') then 'filters']: options.filters,
          },
          request_type: 'topology',
        },
      ],
      [if std.objectHas(options, 'custom_links') then 'custom_links']: options.custom_links,
    },
  },

  // ========== SANKEY WIDGET ==========
  //
  // @widget: sankey
  // @purpose: Display user flow and pathways (Product Analytics)
  // @use_cases: User journey visualization, navigation flow, conversion paths
  //
  // @simple: widgets.sankey('User Flow', 'source:rum @view.name:*')
  //
  // @options: Customize sankey diagram
  //   - show_n_views: 5 (default) - Number of views per step
  //   - sort_by: 'session_count' (default) | 'view_count'
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.sankey('Checkout Flow', 'source:rum @view.name:checkout*', {
  //     show_n_views: 10,
  //     sort_by: 'session_count',
  //   })
  //
  // @note: Requires Product Analytics / RUM data
  // @related: funnel, retention
  // @docs: https://docs.datadoghq.com/dashboards/widgets/sankey/
  //
  sankey(title, query, options={}):: {
    definition: {
      type: 'sankey',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          query: {
            data_source: 'rum',
            query_string: query,
          },
          request_type: 'sankey',
        },
      ],
      show_n_views: if std.objectHas(options, 'show_n_views') then options.show_n_views else 5,
      sort_by: if std.objectHas(options, 'sort_by') then options.sort_by else 'session_count',
    },
  },

  // ========== RETENTION WIDGET ==========
  //
  // @widget: retention
  // @purpose: Measure user retention over time (Product Analytics)
  // @use_cases: User engagement tracking, cohort analysis, feature stickiness
  //
  // @simple: widgets.retention('User Retention', 'start_event', 'return_event')
  //
  // @options: Customize retention analysis
  //   - retention_type: 'n_day' (default) | 'unbounded'
  //   - period: 'daily' (default) | 'weekly' | 'monthly'
  //   - cohort_size: 'all' (default) | number - Cohort size to analyze
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.retention('Feature Adoption', '@view.name:signup', '@action.name:feature_used', {
  //     retention_type: 'n_day',
  //     period: 'weekly',
  //   })
  //
  // @note: Requires Product Analytics with usr.id attribute set
  // @related: funnel, sankey
  // @docs: https://docs.datadoghq.com/dashboards/widgets/retention/
  //
  retention(title, start_event, return_event, options={}):: {
    definition: {
      type: 'retention',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          query: {
            data_source: 'rum',
            start_event: start_event,
            return_event: return_event,
          },
          request_type: 'retention',
        },
      ],
      retention_type: if std.objectHas(options, 'retention_type') then options.retention_type else 'n_day',
      period: if std.objectHas(options, 'period') then options.period else 'daily',
      [if std.objectHas(options, 'cohort_size') then 'cohort_size']: options.cohort_size,
    },
  },

  // ========== RUN WORKFLOW WIDGET ==========
  //
  // @widget: run_workflow
  // @purpose: Trigger automated workflows from dashboard
  // @use_cases: Incident response, automated remediation, manual triggers
  //
  // @simple: widgets.runWorkflow('Restart Service', 'workflow_id_here')
  //
  // @options: Customize workflow widget
  //   - inputs: [] - Array of workflow inputs { name: 'param', value: '$var' }
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.runWorkflow('Scale Cluster', 'abc123', {
  //     inputs: [
  //       { name: 'Environment', value: '$env.value' },
  //       { name: 'Replicas', value: '$replicas.value' },
  //     ],
  //   })
  //
  // @related: monitor_summary, alert_value
  // @docs: https://docs.datadoghq.com/dashboards/widgets/run_workflow/
  //
  runWorkflow(title, workflow_id, options={}):: {
    definition: {
      type: 'run_workflow',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      workflow_id: workflow_id,
      [if std.objectHas(options, 'inputs') then 'inputs']: options.inputs,
    },
  },

  // ========== PROFILING FLAME GRAPH WIDGET ==========
  //
  // @widget: profiling_flame_graph
  // @purpose: Visualize stack traces and performance profiling
  // @use_cases: Performance analysis, hotspot identification, CPU/memory profiling
  //
  // @simple: widgets.profilingFlameGraph('CPU Profile', 'service:web-api')
  //
  // @options: Customize flame graph
  //   - profile_type: 'cpu' (default) | 'memory' | 'wall' | 'goroutines'
  //   - env: 'production' - Environment filter
  //   - service: Service name filter
  //   - version: Version filter
  //   - operation_name: Operation to profile
  //   - title_size: '16' (default) | '18' | '20'
  //   - title_align: 'left' (default) | 'center' | 'right'
  //
  // @example_moderate:
  //   widgets.profilingFlameGraph('Memory Hotspots', 'service:web-api env:prod', {
  //     profile_type: 'memory',
  //     env: 'production',
  //     service: 'web-api',
  //   })
  //
  // @note: Requires Continuous Profiler enabled
  // @related: serviceSummary, distribution
  // @docs: https://docs.datadoghq.com/dashboards/widgets/profiling_flame_graph/
  //
  profilingFlameGraph(title, query, options={}):: {
    definition: {
      type: 'profiling_flame_graph',
      title: title,
      title_size: if std.objectHas(options, 'title_size') then options.title_size else '16',
      title_align: if std.objectHas(options, 'title_align') then options.title_align else 'left',
      requests: [
        {
          profile_type: if std.objectHas(options, 'profile_type') then options.profile_type else 'cpu',
          query: {
            data_source: 'profiling',
            query_string: query,
            [if std.objectHas(options, 'env') then 'env']: options.env,
            [if std.objectHas(options, 'service') then 'service']: options.service,
            [if std.objectHas(options, 'version') then 'version']: options.version,
            [if std.objectHas(options, 'operation_name') then 'operation_name']: options.operation_name,
          },
        },
      ],
    },
  },
}
