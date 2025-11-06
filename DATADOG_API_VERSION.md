# Datadog API Version Compatibility

This document tracks the Datadog API version that doggonet is built against and tested with.

## Current API Version

**Target API Version:** Datadog Dashboard API v1
**Documentation Reference:** https://docs.datadoghq.com/api/latest/dashboards/
**Documentation Snapshot Date:** 2024-11-05 (to be verified and updated)
**Library Version:** doggonet 0.1.0

## API Endpoints Used

doggonet uses the following Datadog API v1 endpoints:

### Dashboard Operations
- `POST /api/v1/dashboard` - Create a new dashboard
- `GET /api/v1/dashboard/{dashboard_id}` - Get a dashboard by ID
- `PUT /api/v1/dashboard/{dashboard_id}` - Update an existing dashboard
- `DELETE /api/v1/dashboard/{dashboard_id}` - Delete a dashboard
- `GET /api/v1/dashboard` - List all dashboards

### Metrics Operations (optional)
- `GET /api/v1/metrics` - List active metrics
- `GET /api/v1/metrics/{metric_name}` - Get metric metadata

### Tags Operations (optional)
- `GET /api/v1/tags/hosts` - List all available tags

## Authentication

doggonet requires the following Datadog credentials:
- **DD_API_KEY**: API key with `dashboards_write` permission
- **DD_APP_KEY**: Application key
- **DD_SITE**: Datadog site (default: `datadoghq.com`)

### Required Permissions
- `dashboards_read` - For fetching and listing dashboards
- `dashboards_write` - For creating, updating, and deleting dashboards

For OAuth apps:
- `dashboards_read` authorization scope
- `dashboards_write` authorization scope

## Dashboard JSON Schema

### Supported Dashboard Properties

doggonet generates dashboard JSON compatible with Datadog Dashboard API v1 schema:

```json
{
  "title": "string (required)",
  "description": "string (optional)",
  "layout_type": "ordered | grid (required)",
  "widgets": [/* array of widget objects */],
  "template_variables": [/* array of template variable objects */],
  "tags": ["string"],
  "notify_list": ["string"],
  "reflow_type": "auto | fixed"
}
```

### Supported Widget Types

As of doggonet 0.2.0, the following widget types are implemented in `src/doggonet/lib/widgets.libsonnet`:

#### Core Visualization Widgets (9 widgets)
- ✅ **timeseries** - Time series charts (line, area, bars)
  - `src/doggonet/lib/widgets.libsonnet:timeseries()`
- ✅ **query_value** - Single value metrics (gauges/counters)
  - `src/doggonet/lib/widgets.libsonnet:queryValue()`
- ✅ **toplist** - Ranked list of metric values (top N)
  - `src/doggonet/lib/widgets.libsonnet:toplist()`
- ✅ **heatmap** - Heatmap visualization
  - `src/doggonet/lib/widgets.libsonnet:heatmap()`
- ✅ **change** - Change/comparison graphs
  - `src/doggonet/lib/widgets.libsonnet:change()`
- ✅ **distribution** - Distribution graphs (APM/tracing)
  - `src/doggonet/lib/widgets.libsonnet:distribution()`
- ✅ **table** - Table widget with multiple columns
  - `src/doggonet/lib/widgets.libsonnet:table()`
- ✅ **scatterplot** - Scatter plot for metric correlation
  - `src/doggonet/lib/widgets.libsonnet:scatterplot()`
- ✅ **treemap** - Hierarchical data visualization
  - `src/doggonet/lib/widgets.libsonnet:treemap()`

#### Chart Widgets (2 widgets)
- ✅ **pieChart** - Pie chart (sunburst type)
  - `src/doggonet/lib/widgets.libsonnet:pieChart()`
- ✅ **geomap** - Geographic map visualization
  - `src/doggonet/lib/widgets.libsonnet:geomap()`

#### Infrastructure & Service Widgets (3 widgets)
- ✅ **hostmap** - Infrastructure host map (hexagonal)
  - `src/doggonet/lib/widgets.libsonnet:hostmap()`
- ✅ **serviceMap** - Service dependency map
  - `src/doggonet/lib/widgets.libsonnet:serviceMap()`
- ✅ **serviceSummary** - APM service summary (trace_service)
  - `src/doggonet/lib/widgets.libsonnet:serviceSummary()`

#### Monitoring & Alerting Widgets (5 widgets)
- ✅ **alertGraph** - Alert graph with thresholds
  - `src/doggonet/lib/widgets.libsonnet:alertGraph()`
- ✅ **alertValue** - Alert value display
  - `src/doggonet/lib/widgets.libsonnet:alertValue()`
- ✅ **checkStatus** - Service check status
  - `src/doggonet/lib/widgets.libsonnet:checkStatus()`
- ✅ **monitorSummary** - Monitor summary widget
  - `src/doggonet/lib/widgets.libsonnet:monitorSummary()`
- ✅ **slo** - SLO widget
  - `src/doggonet/lib/widgets.libsonnet:slo()`

#### Event & Log Widgets (4 widgets)
- ✅ **eventStream** - Event stream widget
  - `src/doggonet/lib/widgets.libsonnet:eventStream()`
- ✅ **eventTimeline** - Event timeline visualization
  - `src/doggonet/lib/widgets.libsonnet:eventTimeline()`
- ✅ **logStream** - Log stream widget
  - `src/doggonet/lib/widgets.libsonnet:logStream()`
- ✅ **list** - List widget for events/issues/logs
  - `src/doggonet/lib/widgets.libsonnet:list()`

#### Decoration & Content Widgets (4 widgets)
- ✅ **note** - Text/markdown widgets for documentation
  - `src/doggonet/lib/widgets.libsonnet:note()`
- ✅ **freeText** - Free-form text widget
  - `src/doggonet/lib/widgets.libsonnet:freeText()`
- ✅ **image** - Image widget
  - `src/doggonet/lib/widgets.libsonnet:image()`
- ✅ **iframe** - Embedded iframe widget
  - `src/doggonet/lib/widgets.libsonnet:iframe()`

#### Organization & Analytics Widgets (3 widgets)
- ✅ **group** - Widget groups for organization
  - `src/doggonet/lib/widgets.libsonnet:group()`
- ✅ **funnel** - Funnel analytics (RUM)
  - `src/doggonet/lib/widgets.libsonnet:funnel()`
- ✅ **powerpack** - Reusable widget templates
  - `src/doggonet/lib/widgets.libsonnet:powerpack()`

**Total Supported: 30 widgets**

#### Not Yet Supported (Specialized/Newer Widgets)
- ⏳ **sankey** - Sankey diagram (Product Analytics)
- ⏳ **retention** - Retention chart (Product Analytics)
- ⏳ **split_graph** - Split graph layout
- ⏳ **topology_map** - Topology map (may be alias of servicemap)
- ⏳ **profiling_flame_graph** - Profiling flame graph
- ⏳ **run_workflow** - Run workflow widget

#### Action Items
- [x] **Audit Datadog docs for complete widget list** (#4)
- [x] **Implement core widget types** (#5)
- [ ] **Verify all implemented widgets produce valid Datadog JSON** (#1)
- [ ] **Add integration tests for each widget type** (#2)
- [ ] **Add specialized Product Analytics widgets (sankey, retention)** (#6)
- [ ] **Add profiling and workflow widgets** (#7)

See [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md) for widget coverage audit details.

## Layout Types

### Supported
- ✅ **ordered** (free-form) - Widgets positioned automatically
- ✅ **grid** - Grid-based layout with explicit positioning

### Not Yet Supported
- ❌ **split** - Split layout (newer feature)

## Known API Limitations

### Dashboard Lists API
The Dashboard Lists API v1 (`/api/v1/dashboard/lists`) is being deprecated in favor of v2.
- **Current status:** Not implemented in doggonet
- **Future plan:** Will implement v2 endpoint when adding dashboard list support

### Rate Limiting
Datadog API has rate limits (typically 1000 requests per hour per organization):
- doggonet implements exponential backoff retry logic
- Default: 3 retries with 1-second initial delay

### API Changes to Monitor

#### Deprecation Notices
1. **Dashboard Lists v1 → v2**: Datadog recommends using v2 endpoints
2. **Widget schema changes**: Datadog occasionally updates widget schemas
3. **Authentication changes**: Monitor for OAuth scope updates

## Version Compatibility Matrix

| doggonet Version | Datadog API | Python | Jsonnet | Widgets Supported | Notes |
|------------------|-------------|--------|---------|-------------------|-------|
| 0.1.0 | v1 | 3.10+ | 0.20+ | 9 | Initial release |
| 0.2.0 | v1 | 3.10+ | 0.20+ | 30 | Comprehensive widget coverage expansion |
| TBD | v1/v2 | 3.10+ | 0.20+ | 36+ | Dashboard Lists v2 + Product Analytics widgets |

## Testing Against Datadog API

### Integration Test Strategy

doggonet integration tests should:
1. **Use a dedicated test organization** to avoid polluting production
2. **Clean up test dashboards** after each test run
3. **Record API responses** (using VCR.py) to avoid rate limits
4. **Test against both US and EU sites** for regional compatibility

### API Mock Server (Future)

For offline development, consider:
- Creating a mock Datadog API server
- Recording real API responses for playback
- Validating dashboard JSON against Datadog's schema

## Monitoring API Changes

### Recommended Practices

1. **Subscribe to Datadog API changelog**
   - https://docs.datadoghq.com/api/latest/changelog/

2. **Monitor Datadog API client updates**
   - Python client: https://github.com/DataDog/datadog-api-client-python
   - Watch for deprecation warnings

3. **Regular compatibility testing**
   - Run integration tests quarterly
   - Test new Datadog features as they're released
   - Validate examples still work

4. **Community feedback**
   - Monitor issues for API compatibility problems
   - Encourage users to report schema mismatches

## Versioning Policy

doggonet follows semantic versioning:

- **MAJOR**: Breaking API changes, incompatible schema changes
- **MINOR**: New widget support, new features (backward compatible)
- **PATCH**: Bug fixes, documentation updates

### When to Bump Versions

- **Major bump**: Required when Datadog makes breaking changes to v1 API
- **Minor bump**: Adding new widget types, new Datadog features
- **Patch bump**: Bug fixes in existing widget implementations

## References

### Official Documentation
- Dashboard API: https://docs.datadoghq.com/api/latest/dashboards/
- Widgets: https://docs.datadoghq.com/dashboards/widgets/
- API Authentication: https://docs.datadoghq.com/api/latest/authentication/
- Rate Limiting: https://docs.datadoghq.com/api/latest/rate-limits/

### Community Resources
- Datadog API Python Client: https://github.com/DataDog/datadog-api-client-python
- Datadog Terraform Provider: https://registry.terraform.io/providers/DataDog/datadog/latest/docs
- grafonnet-lib (inspiration): https://github.com/grafana/grafonnet-lib

## Update History

| Date | Version | Changes | Updated By |
|------|---------|---------|------------|
| 2024-11-05 | 0.1.0 | Initial documentation | Initial Setup |
| 2025-11-06 | 0.2.0 | Expanded widget coverage from 9 to 30 widgets:<br>- Added visualization widgets (scatter_plot, pie_chart, treemap, geomap)<br>- Added monitoring widgets (alert_graph, alert_value, check_status, monitor_summary, slo)<br>- Added infrastructure widgets (hostmap, service_map, service_summary)<br>- Added event/log widgets (event_stream, event_timeline, log_stream, list)<br>- Added decoration widgets (free_text, image, iframe)<br>- Added analytics widgets (funnel, powerpack) | Claude Code |

---

**Next Review Date:** 2026-02-06 (Quarterly review recommended)

**Maintainer Note:** This document should be reviewed and updated whenever:
1. A new doggonet version is released
2. Datadog announces API changes
3. New widget types are added
4. Integration tests reveal compatibility issues
