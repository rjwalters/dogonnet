"""Tests for Datadog client."""

from unittest.mock import Mock, patch

import pytest
import requests

from dogonnet.client.dashboard import DatadogDashboardClient, get_datadog_credentials


def test_get_credentials_from_env(mock_datadog_credentials):
    """Test getting credentials from environment."""
    api_key, app_key, site = get_datadog_credentials()

    assert api_key == "test_api_key"
    assert app_key == "test_app_key"
    assert site == "datadoghq.com"


def test_get_credentials_missing(monkeypatch):
    """Test error when credentials are missing."""
    monkeypatch.delenv("DD_API_KEY", raising=False)
    monkeypatch.delenv("DD_APP_KEY", raising=False)

    with pytest.raises(ValueError, match="Missing required credentials"):
        get_datadog_credentials()


def test_client_initialization(mock_datadog_credentials):
    """Test client initialization."""
    client = DatadogDashboardClient()

    assert client.api_key == "test_api_key"
    assert client.app_key == "test_app_key"
    assert client.site == "datadoghq.com"
    assert client.base_url == "https://api.datadoghq.com/api"


def test_client_with_custom_credentials():
    """Test client with explicitly provided credentials."""
    client = DatadogDashboardClient(api_key="custom_api", app_key="custom_app", site="datadoghq.eu")

    assert client.api_key == "custom_api"
    assert client.app_key == "custom_app"
    assert client.site == "datadoghq.eu"
    assert client.base_url == "https://api.datadoghq.eu/api"


def test_client_partial_credentials_uses_env_site(monkeypatch):
    """Test that site is pulled from env when only api/app keys are provided."""
    monkeypatch.setenv("DD_SITE", "datadoghq.eu")

    client = DatadogDashboardClient(api_key="custom_api", app_key="custom_app")

    assert client.site == "datadoghq.eu"
    assert client.base_url == "https://api.datadoghq.eu/api"


def test_create_session():
    """Test session creation with proper headers."""
    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    assert client._session.headers["DD-API-KEY"] == "test_key"
    assert client._session.headers["DD-APPLICATION-KEY"] == "test_app"
    assert client._session.headers["Content-Type"] == "application/json"


@patch("dogonnet.client.dashboard.requests.Session")
def test_list_dashboards(mock_session_class):
    """Test listing dashboards."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {
        "dashboards": [{"id": "dash-123", "title": "Test Dashboard 1"}, {"id": "dash-456", "title": "Test Dashboard 2"}]
    }
    mock_session.get.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    dashboards = client.list_dashboards()

    assert len(dashboards) == 2
    assert dashboards[0]["id"] == "dash-123"
    assert dashboards[1]["title"] == "Test Dashboard 2"
    mock_session.get.assert_called_once_with("https://api.datadoghq.com/api/v1/dashboard")


@patch("dogonnet.client.dashboard.requests.Session")
def test_get_dashboard(mock_session_class):
    """Test getting a specific dashboard."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {"id": "dash-123", "title": "Test Dashboard", "widgets": []}
    mock_session.get.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    dashboard = client.get_dashboard("dash-123")

    assert dashboard["id"] == "dash-123"
    assert dashboard["title"] == "Test Dashboard"
    mock_session.get.assert_called_once_with("https://api.datadoghq.com/api/v1/dashboard/dash-123")


@patch("dogonnet.client.dashboard.requests.Session")
def test_dashboard_exists_true(mock_session_class):
    """Test checking if dashboard exists (returns True)."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.status_code = 200
    mock_session.get.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    exists = client.dashboard_exists("dash-123")

    assert exists is True


@patch("dogonnet.client.dashboard.requests.Session")
def test_dashboard_exists_false(mock_session_class):
    """Test checking if dashboard exists (returns False)."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.status_code = 404
    mock_session.get.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    exists = client.dashboard_exists("dash-999")

    assert exists is False


@patch("dogonnet.client.dashboard.requests.Session")
def test_dashboard_exists_handles_exception(mock_session_class):
    """Test dashboard_exists handles exceptions gracefully."""
    # Setup mock to raise exception
    mock_session = Mock()
    mock_session.get.side_effect = requests.exceptions.RequestException("Connection error")
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    exists = client.dashboard_exists("dash-123")

    assert exists is False


@patch("dogonnet.client.dashboard.requests.Session")
def test_create_dashboard(mock_session_class):
    """Test creating a dashboard."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {"id": "dash-new", "title": "New Dashboard"}
    mock_session.post.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    dashboard_json = {
        "title": "New Dashboard",
        "widgets": [],
        "id": "should-be-removed",  # Should be stripped
        "created_at": "timestamp",  # Should be stripped
    }

    result = client.create_dashboard(dashboard_json)

    assert result["id"] == "dash-new"
    # Verify stripped fields
    call_args = mock_session.post.call_args
    posted_json = call_args[1]["json"]
    assert "id" not in posted_json
    assert "created_at" not in posted_json
    assert posted_json["title"] == "New Dashboard"


@patch("dogonnet.client.dashboard.requests.Session")
def test_update_dashboard(mock_session_class):
    """Test updating a dashboard."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {"id": "dash-123", "title": "Updated Dashboard"}
    mock_session.put.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    dashboard_json = {
        "title": "Updated Dashboard",
        "widgets": [],
        "modified_at": "timestamp",  # Should be stripped
        "author_handle": "user@example.com",  # Should be stripped
    }

    result = client.update_dashboard("dash-123", dashboard_json)

    assert result["title"] == "Updated Dashboard"
    # Verify stripped fields
    call_args = mock_session.put.call_args
    posted_json = call_args[1]["json"]
    assert "modified_at" not in posted_json
    assert "author_handle" not in posted_json


@patch("dogonnet.client.dashboard.requests.Session")
def test_delete_dashboard(mock_session_class):
    """Test deleting a dashboard."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {"deleted_dashboard_id": "dash-123"}
    mock_session.delete.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    result = client.delete_dashboard("dash-123")

    assert result["deleted_dashboard_id"] == "dash-123"
    mock_session.delete.assert_called_once_with("https://api.datadoghq.com/api/v1/dashboard/dash-123")


@patch("dogonnet.client.dashboard.requests.Session")
def test_list_metrics(mock_session_class):
    """Test listing metrics."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {"metrics": ["system.cpu.user", "system.mem.used", "app.requests"]}
    mock_session.get.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    metrics = client.list_metrics()

    assert len(metrics) == 3
    assert "system.cpu.user" in metrics
    # Verify metrics are sorted
    assert metrics == sorted(metrics)


@patch("dogonnet.client.dashboard.requests.Session")
def test_list_metrics_with_search(mock_session_class):
    """Test listing metrics with search filter."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {"metrics": ["system.cpu.user", "system.mem.used", "app.requests"]}
    mock_session.get.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    metrics = client.list_metrics(search="system")

    assert len(metrics) == 2
    assert "system.cpu.user" in metrics
    assert "system.mem.used" in metrics
    assert "app.requests" not in metrics


@patch("dogonnet.client.dashboard.requests.Session")
def test_get_metric_metadata(mock_session_class):
    """Test getting metric metadata."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {"metric": "system.cpu.user", "type": "gauge", "description": "CPU usage"}
    mock_session.get.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    metadata = client.get_metric_metadata("system.cpu.user")

    assert metadata["metric"] == "system.cpu.user"
    assert metadata["type"] == "gauge"
    mock_session.get.assert_called_once_with("https://api.datadoghq.com/api/v1/metrics/system.cpu.user")


@patch("dogonnet.client.dashboard.requests.Session")
def test_list_tags(mock_session_class):
    """Test listing tags."""
    # Setup mock
    mock_session = Mock()
    mock_response = Mock()
    mock_response.json.return_value = {"tags": {"env": ["prod", "staging"], "service": ["web", "api"]}}
    mock_session.get.return_value = mock_response
    mock_session_class.return_value = mock_session

    client = DatadogDashboardClient(api_key="test_key", app_key="test_app", site="datadoghq.com")

    tags = client.list_tags()

    assert "tags" in tags
    assert tags["tags"]["env"] == ["prod", "staging"]
    mock_session.get.assert_called_once_with("https://api.datadoghq.com/api/v1/tags/hosts")
