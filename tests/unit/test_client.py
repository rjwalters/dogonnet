"""Tests for Datadog client."""


import pytest

from doggonet.client.dashboard import DatadogDashboardClient, get_datadog_credentials


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
    client = DatadogDashboardClient(
        api_key="custom_api",
        app_key="custom_app",
        site="datadoghq.eu"
    )

    assert client.api_key == "custom_api"
    assert client.app_key == "custom_app"
    assert client.site == "datadoghq.eu"
    assert client.base_url == "https://api.datadoghq.eu/api"
