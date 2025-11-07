"""Tests for Jsonnet compilation utilities."""

import json
import subprocess
from pathlib import Path
from unittest.mock import Mock, patch

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


def test_compile_with_cli_fallback(tmp_path, monkeypatch):
    """Test compilation falls back to CLI when _jsonnet is not available."""
    # Create test file
    test_file = tmp_path / "test.jsonnet"
    test_file.write_text('{ title: "Test", widgets: [] }')

    # Force ImportError by removing _jsonnet from sys.modules if present
    import sys
    _jsonnet_backup = sys.modules.get('_jsonnet')
    if '_jsonnet' in sys.modules:
        del sys.modules['_jsonnet']

    # Mock subprocess to return valid JSON
    mock_run = Mock()
    mock_result = Mock()
    mock_result.stdout = '{"title": "Test", "widgets": []}'
    mock_run.return_value = mock_result
    monkeypatch.setattr('doggonet.utils.jsonnet.subprocess.run', mock_run)

    # Also make sure _jsonnet import fails
    original_import = __import__
    def mock_import(name, *args, **kwargs):
        if name == '_jsonnet':
            raise ImportError("No module named '_jsonnet'")
        return original_import(name, *args, **kwargs)

    monkeypatch.setattr('builtins.__import__', mock_import)

    try:
        result = compile_jsonnet(test_file)

        assert result["title"] == "Test"
        assert mock_run.called
        # Verify jsonnet command was called with correct file
        call_args = mock_run.call_args[0][0]
        assert "jsonnet" in call_args
        assert str(test_file) in call_args
    finally:
        # Restore _jsonnet if it was there
        if _jsonnet_backup is not None:
            sys.modules['_jsonnet'] = _jsonnet_backup


def test_compile_cli_with_ext_vars(tmp_path, monkeypatch):
    """Test CLI fallback with external variables."""
    import sys
    _jsonnet_backup = sys.modules.get('_jsonnet')
    if '_jsonnet' in sys.modules:
        del sys.modules['_jsonnet']

    test_file = tmp_path / "test.jsonnet"
    test_file.write_text('{ title: "Test" }')

    mock_run = Mock()
    mock_result = Mock()
    mock_result.stdout = '{"title": "Test"}'
    mock_run.return_value = mock_result
    monkeypatch.setattr('doggonet.utils.jsonnet.subprocess.run', mock_run)

    original_import = __import__
    def mock_import(name, *args, **kwargs):
        if name == '_jsonnet':
            raise ImportError("No module named '_jsonnet'")
        return original_import(name, *args, **kwargs)

    monkeypatch.setattr('builtins.__import__', mock_import)

    try:
        compile_jsonnet(test_file, ext_vars={"env": "prod", "region": "us-west"})

        # Verify ext vars were passed correctly
        call_args = mock_run.call_args[0][0]
        assert "--ext-str" in call_args
        assert "env=prod" in call_args
        assert "region=us-west" in call_args
    finally:
        if _jsonnet_backup is not None:
            sys.modules['_jsonnet'] = _jsonnet_backup


def test_compile_cli_with_jpathdir(tmp_path, monkeypatch):
    """Test CLI fallback with jpath directories."""
    import sys
    _jsonnet_backup = sys.modules.get('_jsonnet')
    if '_jsonnet' in sys.modules:
        del sys.modules['_jsonnet']

    test_file = tmp_path / "test.jsonnet"
    test_file.write_text('{ title: "Test" }')
    lib_dir = tmp_path / "lib"
    lib_dir.mkdir()

    mock_run = Mock()
    mock_result = Mock()
    mock_result.stdout = '{"title": "Test"}'
    mock_run.return_value = mock_result
    monkeypatch.setattr('doggonet.utils.jsonnet.subprocess.run', mock_run)

    original_import = __import__
    def mock_import(name, *args, **kwargs):
        if name == '_jsonnet':
            raise ImportError("No module named '_jsonnet'")
        return original_import(name, *args, **kwargs)

    monkeypatch.setattr('builtins.__import__', mock_import)

    try:
        compile_jsonnet(test_file, jpathdir=[lib_dir])

        # Verify jpath was passed correctly
        call_args = mock_run.call_args[0][0]
        assert "-J" in call_args
        assert str(lib_dir) in call_args
    finally:
        if _jsonnet_backup is not None:
            sys.modules['_jsonnet'] = _jsonnet_backup


def test_compile_cli_not_found(tmp_path, monkeypatch):
    """Test error when jsonnet CLI is not installed."""
    import sys
    _jsonnet_backup = sys.modules.get('_jsonnet')
    if '_jsonnet' in sys.modules:
        del sys.modules['_jsonnet']

    test_file = tmp_path / "test.jsonnet"
    test_file.write_text('{ title: "Test" }')

    # Mock FileNotFoundError (jsonnet command not found)
    mock_run = Mock()
    mock_run.side_effect = FileNotFoundError("jsonnet not found")
    monkeypatch.setattr('doggonet.utils.jsonnet.subprocess.run', mock_run)

    original_import = __import__
    def mock_import(name, *args, **kwargs):
        if name == '_jsonnet':
            raise ImportError("No module named '_jsonnet'")
        return original_import(name, *args, **kwargs)

    monkeypatch.setattr('builtins.__import__', mock_import)

    try:
        with pytest.raises(RuntimeError, match="Jsonnet compiler not found"):
            compile_jsonnet(test_file)
    finally:
        if _jsonnet_backup is not None:
            sys.modules['_jsonnet'] = _jsonnet_backup


def test_compile_cli_compilation_error(tmp_path, monkeypatch):
    """Test CLI compilation error handling."""
    import sys
    _jsonnet_backup = sys.modules.get('_jsonnet')
    if '_jsonnet' in sys.modules:
        del sys.modules['_jsonnet']

    test_file = tmp_path / "test.jsonnet"
    test_file.write_text('{ invalid }')

    # Mock CalledProcessError (compilation failed)
    error = subprocess.CalledProcessError(1, "jsonnet", stderr="STATIC ERROR: syntax error")
    mock_run = Mock()
    mock_run.side_effect = error
    monkeypatch.setattr('doggonet.utils.jsonnet.subprocess.run', mock_run)

    original_import = __import__
    def mock_import(name, *args, **kwargs):
        if name == '_jsonnet':
            raise ImportError("No module named '_jsonnet'")
        return original_import(name, *args, **kwargs)

    monkeypatch.setattr('builtins.__import__', mock_import)

    try:
        with pytest.raises(RuntimeError, match="Jsonnet compilation failed"):
            compile_jsonnet(test_file)
    finally:
        if _jsonnet_backup is not None:
            sys.modules['_jsonnet'] = _jsonnet_backup


def test_compile_cli_invalid_json_output(tmp_path, monkeypatch):
    """Test error when CLI returns invalid JSON."""
    import sys
    _jsonnet_backup = sys.modules.get('_jsonnet')
    if '_jsonnet' in sys.modules:
        del sys.modules['_jsonnet']

    test_file = tmp_path / "test.jsonnet"
    test_file.write_text('{ title: "Test" }')

    # Mock subprocess returning invalid JSON
    mock_run = Mock()
    mock_result = Mock()
    mock_result.stdout = 'not valid json {'
    mock_run.return_value = mock_result
    monkeypatch.setattr('doggonet.utils.jsonnet.subprocess.run', mock_run)

    original_import = __import__
    def mock_import(name, *args, **kwargs):
        if name == '_jsonnet':
            raise ImportError("No module named '_jsonnet'")
        return original_import(name, *args, **kwargs)

    monkeypatch.setattr('builtins.__import__', mock_import)

    try:
        with pytest.raises(RuntimeError, match="Invalid JSON output from Jsonnet"):
            compile_jsonnet(test_file)
    finally:
        if _jsonnet_backup is not None:
            sys.modules['_jsonnet'] = _jsonnet_backup
