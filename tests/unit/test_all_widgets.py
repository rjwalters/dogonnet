"""Tests for all widget types to ensure they compile correctly."""

from pathlib import Path

import pytest

from doggonet.utils.jsonnet import compile_jsonnet


@pytest.fixture
def src_dir():
    """Get the src directory for imports."""
    return Path(__file__).parent.parent.parent / "src"


def test_all_38_widgets_compile(tmp_path, src_dir):
    """Test that all 38 widget types compile without errors."""

    # Create a comprehensive test dashboard with all widget types
    test_file = tmp_path / "all_widgets.jsonnet"
    test_file.write_text("""
    local widgets = import 'doggonet/lib/widgets.libsonnet';

    {
      title: 'All Widgets Test',
      layout_type: 'ordered',
      widgets: [
        // Core Visualization (11)
        widgets.timeseries('Timeseries', 'avg:system.cpu{*}'),
        widgets.queryValue('Query Value', 'sum:requests{*}'),
        widgets.toplist('Top List', 'avg:cpu{*} by {host}'),
        widgets.heatmap('Heatmap', 'avg:latency{*}'),
        widgets.change('Change', 'avg:memory{*}'),
        widgets.distribution('Distribution', 'trace.duration{*}'),
        widgets.table('Table', ['avg:cpu{*}', 'avg:mem{*}']),
        widgets.scatterplot('Scatter', 'avg:cpu{*}', 'avg:mem{*}'),
        widgets.treemap('Treemap', 'sum:requests{*} by {service}'),
        widgets.barChart('Bar Chart', 'sum:requests{*} by {status}'),
        widgets.wildcard('Wildcard', { mark: 'bar', encoding: { x: { field: 'x' } } }),

        // Charts (2)
        widgets.pieChart('Pie Chart', 'sum:requests{*} by {service}'),
        widgets.geomap('Geomap', 'avg:users{*} by {country}'),

        // Infrastructure & Services (4)
        widgets.hostmap('Hostmap', 'avg:system.cpu{*}'),
        widgets.serviceMap('Service Map', { service: 'my-service', env: 'prod' }),
        widgets.serviceSummary('Service Summary', 'web-app', 'prod'),
        widgets.topologyMap('Topology Map', 'web-service'),

        // Monitoring & Alerting (6)
        widgets.alertGraph('Alert Graph', 'monitor_123'),
        widgets.alertValue('Alert Value', 'monitor_456'),
        widgets.checkStatus('Check Status', 'app.ok'),
        widgets.monitorSummary('Monitor Summary', 'env:prod'),
        widgets.slo('SLO', 'slo_abc123'),
        widgets.runWorkflow('Run Workflow', 'workflow_xyz'),

        // Events & Logs (4)
        widgets.eventStream('Event Stream', 'source:app status:error'),
        widgets.eventTimeline('Event Timeline', 'source:deployments'),
        widgets.logStream('Log Stream', 'service:web-app status:error'),
        widgets.list('List', 'status:open', 'issue'),

        // Decoration (4)
        widgets.note('# Section Header'),
        widgets.freeText('Custom Text', { fontSize: '24', textAlign: 'center' }),
        widgets.image('https://example.com/logo.png'),
        widgets.iframe('https://example.com/dashboard'),

        // Organization (4)
        widgets.group('Group', [widgets.note('Grouped note')]),
        widgets.powerpack('powerpack_123'),
        widgets.splitGraph('Split Graph', 'avg:cpu{*}', 'host'),

        // Product Analytics (3)
        widgets.funnel('Funnel', 'source:rum @view.name:*'),
        widgets.sankey('Sankey', 'source:rum @view.name:*'),
        widgets.retention('Retention', '@action.name:signup', '@action.name:login'),

        // Performance (1)
        widgets.profilingFlameGraph('Flame Graph', 'runtime:python service:api'),
      ],
    }
    """)

    # Compile and verify
    result = compile_jsonnet(test_file, jpathdir=[src_dir])

    # Verify it's valid JSON
    assert isinstance(result, dict)
    assert result["title"] == "All Widgets Test"
    assert "widgets" in result

    # Verify we have all 38 widgets
    assert len(result["widgets"]) == 38

    # Verify each widget has required structure
    for widget in result["widgets"]:
        assert "definition" in widget
        assert "type" in widget["definition"]


def test_widget_categories():
    """Test that widgets are organized into correct categories."""

    widget_counts = {
        "core_viz": 11,
        "charts": 2,
        "infrastructure": 4,
        "monitoring": 6,
        "events_logs": 4,
        "decoration": 4,
        "organization": 3,
        "analytics": 3,
        "performance": 1,
    }

    total = sum(widget_counts.values())
    assert total == 38, f"Expected 38 total widgets, got {total}"


@pytest.mark.parametrize(
    "widget_type,widget_call",
    [
        # Core Visualization
        ("timeseries", "widgets.timeseries('Test', 'avg:cpu{*}')"),
        ("query_value", "widgets.queryValue('Test', 'sum:requests{*}')"),
        ("toplist", "widgets.toplist('Test', 'avg:cpu{*} by {host}')"),
        ("heatmap", "widgets.heatmap('Test', 'avg:latency{*}')"),
        ("change", "widgets.change('Test', 'avg:memory{*}')"),
        ("distribution", "widgets.distribution('Test', 'trace.duration{*}')"),
        ("table", "widgets.table('Test', ['avg:cpu{*}'])"),
        ("scatterplot", "widgets.scatterplot('Test', 'avg:cpu{*}', 'avg:mem{*}')"),
        ("treemap", "widgets.treemap('Test', 'sum:requests{*} by {service}')"),
        ("bar_chart", "widgets.barChart('Test', 'sum:requests{*}')"),
        ("wildcard", "widgets.wildcard('Test', { mark: 'bar' })"),
        # Charts
        ("pie_chart", "widgets.pieChart('Test', 'sum:requests{*} by {service}')"),
        ("geomap", "widgets.geomap('Test', 'avg:users{*} by {country}')"),
        # Infrastructure
        ("hostmap", "widgets.hostmap('Test', 'avg:system.cpu{*}')"),
        ("service_map", "widgets.serviceMap('Test', { service: 'app' })"),
        ("trace_service", "widgets.serviceSummary('Test', 'app', 'prod')"),
        ("topology_map", "widgets.topologyMap('Test', 'my-service')"),
        # Monitoring
        ("alert_graph", "widgets.alertGraph('Test', 'monitor_123')"),
        ("alert_value", "widgets.alertValue('Test', 'monitor_456')"),
        ("check_status", "widgets.checkStatus('Test', 'app.ok')"),
        ("monitor_summary", "widgets.monitorSummary('Test', 'env:prod')"),
        ("slo", "widgets.slo('Test', 'slo_123')"),
        ("run_workflow", "widgets.runWorkflow('Test', 'workflow_xyz')"),
        # Events & Logs
        ("event_stream", "widgets.eventStream('Test', 'source:app')"),
        ("event_timeline", "widgets.eventTimeline('Test', 'source:deploy')"),
        ("log_stream", "widgets.logStream('Test', 'service:app')"),
        ("list_stream", "widgets.list('Test', 'status:open', 'issue')"),
        # Decoration
        ("note", "widgets.note('# Header')"),
        ("free_text", "widgets.freeText('Text', { fontSize: '16' })"),
        ("image", "widgets.image('https://example.com/img.png')"),
        ("iframe", "widgets.iframe('https://example.com')"),
        # Organization
        ("group", "widgets.group('Test', [widgets.note('Note')])"),
        ("powerpack", "widgets.powerpack('powerpack_123')"),
        ("split_graph", "widgets.splitGraph('Test', 'avg:cpu{*}', 'host')"),
        # Product Analytics
        ("funnel", "widgets.funnel('Test', 'source:rum @view.name:*')"),
        ("sankey", "widgets.sankey('Test', 'source:rum @view.name:*')"),
        ("retention", "widgets.retention('Test', '@action:signup', '@action:login')"),
        # Performance
        ("profiling_flame_graph", "widgets.profilingFlameGraph('Test', 'runtime:python')"),
    ],
)
def test_individual_widget_compilation(tmp_path, src_dir, widget_type, widget_call):
    """Test that each individual widget type compiles correctly."""

    test_file = tmp_path / f"test_{widget_type}.jsonnet"
    test_file.write_text(f"""
    local widgets = import 'doggonet/lib/widgets.libsonnet';

    {{
      title: 'Test Dashboard',
      layout_type: 'ordered',
      widgets: [
        {widget_call}
      ],
    }}
    """)

    result = compile_jsonnet(test_file, jpathdir=[src_dir])

    assert isinstance(result, dict)
    assert len(result["widgets"]) == 1
    assert "definition" in result["widgets"][0]
    assert "type" in result["widgets"][0]["definition"]
