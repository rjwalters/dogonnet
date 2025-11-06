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

As of doggonet 0.1.0, the following widget types are implemented in `src/doggonet/lib/widgets.libsonnet`:

#### Fully Supported (9 widgets)
- ✅ **timeseries** - Time series charts (line, area, bars)
  - `src/doggonet/lib/widgets.libsonnet:timeseries()`
- ✅ **query_value** - Single value metrics (gauges/counters)
  - `src/doggonet/lib/widgets.libsonnet:queryValue()`
- ✅ **toplist** - Ranked list of metric values (top N)
  - `src/doggonet/lib/widgets.libsonnet:toplist()`
- ✅ **note** - Text/markdown widgets for documentation
  - `src/doggonet/lib/widgets.libsonnet:note()`
- ✅ **heatmap** - Heatmap visualization
  - `src/doggonet/lib/widgets.libsonnet:heatmap()`
- ✅ **change** - Change/comparison graphs
  - `src/doggonet/lib/widgets.libsonnet:change()`
- ✅ **distribution** - Distribution graphs
  - `src/doggonet/lib/widgets.libsonnet:distribution()`
- ✅ **table** - Table widget with multiple columns
  - `src/doggonet/lib/widgets.libsonnet:table()`
- ✅ **group** - Widget groups for organization
  - `src/doggonet/lib/widgets.libsonnet:group()`

#### Not Yet Supported (Need to verify against Datadog API)
- ❌ **event_stream** - Event stream widget
- ❌ **event_timeline** - Event timeline
- ❌ **alert_graph** - Alert graphs
- ❌ **alert_value** - Alert value widget
- ❌ **check_status** - Check status widget
- ❌ **hostmap** - Hostmap widget
- ❌ **service_map** - Service map
- ❌ **slo** - SLO widget
- ❌ **scatter_plot** - Scatter plot
- ❌ **treemap** - Treemap widget
- ❌ **pie_chart** - Pie chart
- ❌ **sunburst** - Sunburst chart
- ❌ **geomap** - Geographic map
- ❌ **funnel** - Funnel chart
- ❌ **monitor_summary** - Monitor summary
- ❌ **log_stream** - Log stream
- ❌ **trace_service** - Trace service widget
- ❌ **list** - List widget
- ❌ **iframe** - Embedded iframe

#### Action Items
- [ ] **Verify all implemented widgets produce valid Datadog JSON** (#1)
- [ ] **Add integration tests for each widget type** (#2)
- [ ] **Create tracking issue for unsupported widgets** (#3)
- [ ] **Audit Datadog docs for complete widget list** (#4)

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

| doggonet Version | Datadog API | Python | Jsonnet | Notes |
|------------------|-------------|--------|---------|-------|
| 0.1.0 | v1 | 3.10+ | 0.20+ | Initial release |
| TBD | v1 | 3.10+ | 0.20+ | Widget coverage expansion |
| TBD | v1/v2 | 3.10+ | 0.20+ | Dashboard Lists v2 support |

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

---

**Next Review Date:** 2025-02-05 (Quarterly review recommended)

**Maintainer Note:** This document should be reviewed and updated whenever:
1. A new doggonet version is released
2. Datadog announces API changes
3. New widget types are added
4. Integration tests reveal compatibility issues
