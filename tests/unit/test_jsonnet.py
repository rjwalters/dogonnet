"""Tests for Jsonnet compilation utilities."""

import json
from pathlib import Path

import pytest

from doggonet.utils.jsonnet import compile_jsonnet, is_jsonnet_file, load_dashboard


def test_is_jsonnet_file():
    """Test Jsonnet file detection."""
    assert is_jsonnet_file(Path("test.jsonnet")) is True
    assert is_jsonnet_file(Path("test.libsonnet")) is True
    assert is_jsonnet_file(Path("test.json")) is False
    assert is_jsonnet_file(Path("test.txt")) is False


def test_compile_basic_dashboard(basic_dashboard):
    """Test compiling the basic example dashboard."""
    result = compile_jsonnet(basic_dashboard)

    # Verify it's valid JSON
    assert isinstance(result, dict)

    # Verify required dashboard fields
    assert "title" in result
    assert "layout_type" in result
    assert "widgets" in result

    # Verify title matches
    assert result["title"] == "Basic Dashboard"

    # Verify we have widgets
    assert len(result["widgets"]) > 0


def test_compile_with_external_vars(tmp_path):
    """Test compiling with external variables."""
    # Create a simple test file
    test_file = tmp_path / "test.jsonnet"
    test_file.write_text("""
    local env = std.extVar('env');
    {
      title: 'Dashboard - ' + env,
      layout_type: 'ordered',
      widgets: [],
    }
    """)

    result = compile_jsonnet(test_file, ext_vars={"env": "production"})

    assert result["title"] == "Dashboard - production"


def test_load_dashboard_jsonnet(basic_dashboard):
    """Test loading a Jsonnet dashboard."""
    result = load_dashboard(basic_dashboard)

    assert isinstance(result, dict)
    assert "title" in result
    assert "widgets" in result


def test_load_dashboard_json(tmp_path):
    """Test loading a JSON dashboard."""
    json_file = tmp_path / "test.json"
    test_data = {
        "title": "Test Dashboard",
        "layout_type": "ordered",
        "widgets": []
    }
    json_file.write_text(json.dumps(test_data))

    result = load_dashboard(json_file)

    assert result == test_data


def test_compile_invalid_jsonnet(tmp_path):
    """Test that invalid Jsonnet raises an error."""
    bad_file = tmp_path / "bad.jsonnet"
    bad_file.write_text("{ invalid syntax }")

    with pytest.raises(RuntimeError, match="(Jsonnet compilation failed|STATIC ERROR)"):
        compile_jsonnet(bad_file)
