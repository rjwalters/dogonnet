"""Tests for CLI commands."""

from click.testing import CliRunner

from dogonnet.cli.main import main


def test_cli_help():
    """Test that --help works."""
    runner = CliRunner()
    result = runner.invoke(main, ["--help"])

    assert result.exit_code == 0
    assert "dogonnet" in result.output
    assert "Datadog dashboard templating" in result.output


def test_cli_version():
    """Test that --version works."""
    runner = CliRunner()
    result = runner.invoke(main, ["--version"])

    assert result.exit_code == 0
    assert "0.1.0" in result.output


def test_compile_command(basic_dashboard):
    """Test compile command."""
    runner = CliRunner()
    result = runner.invoke(main, ["compile", str(basic_dashboard)])

    assert result.exit_code == 0
    assert "Basic Dashboard" in result.output


def test_view_command(basic_dashboard):
    """Test view command."""
    runner = CliRunner()
    result = runner.invoke(main, ["view", str(basic_dashboard)])

    assert result.exit_code == 0
    assert "Dashboard Preview" in result.output
    assert "Basic Dashboard" in result.output


def test_compile_nonexistent_file():
    """Test compile with nonexistent file."""
    runner = CliRunner()
    result = runner.invoke(main, ["compile", "nonexistent.jsonnet"])

    assert result.exit_code != 0


def test_view_json_file(tmp_path):
    """Test view with JSON file (not Jsonnet)."""
    json_file = tmp_path / "test.json"
    json_file.write_text('{"title": "Test", "layout_type": "ordered", "widgets": []}')

    runner = CliRunner()
    result = runner.invoke(main, ["view", str(json_file)])

    assert result.exit_code == 0
    assert "Test" in result.output
