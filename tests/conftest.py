"""Pytest configuration and fixtures."""

from pathlib import Path

import pytest


@pytest.fixture
def example_dir():
    """Path to examples directory."""
    return Path(__file__).parent.parent / "examples"


@pytest.fixture
def basic_dashboard(example_dir):
    """Path to basic example dashboard."""
    return example_dir / "basic.jsonnet"


@pytest.fixture
def mock_datadog_credentials(monkeypatch):
    """Mock Datadog credentials for testing."""
    monkeypatch.setenv("DD_API_KEY", "test_api_key")
    monkeypatch.setenv("DD_APP_KEY", "test_app_key")
    monkeypatch.setenv("DD_SITE", "datadoghq.com")
