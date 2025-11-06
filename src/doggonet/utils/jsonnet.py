"""Jsonnet compilation utilities."""

import json
import subprocess
from pathlib import Path
from typing import Any


def compile_jsonnet(
    source_file: Path,
    ext_vars: dict[str, str] | None = None,
    jpathdir: list[Path] | None = None,
) -> dict[str, Any]:
    """Compile a Jsonnet file to JSON.

    Args:
        source_file: Path to Jsonnet file
        ext_vars: External variables to pass to Jsonnet
        jpathdir: List of directories to search for imports

    Returns:
        Compiled JSON as dict

    Raises:
        RuntimeError: If jsonnet compilation fails
    """
    # Try to use _jsonnet library first (faster)
    try:
        import _jsonnet

        ext_vars = ext_vars or {}
        jpathdir = jpathdir or []

        # Convert Path objects to strings for _jsonnet
        jpath_strs = [str(p) for p in jpathdir]

        json_str = _jsonnet.evaluate_file(
            str(source_file),
            ext_vars=ext_vars,
            jpathdir=jpath_strs
        )
        return json.loads(json_str)
    except ImportError:
        pass

    # Fall back to jsonnet CLI
    try:
        cmd = ["jsonnet", str(source_file)]

        # Add external variables
        if ext_vars:
            for key, value in ext_vars.items():
                cmd.extend(["--ext-str", f"{key}={value}"])

        # Add jpath directories
        if jpathdir:
            for jpath in jpathdir:
                cmd.extend(["-J", str(jpath)])

        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return json.loads(result.stdout)

    except FileNotFoundError:
        raise RuntimeError(
            "Jsonnet compiler not found. Install with: pip install jsonnet\n"
            "Or install the jsonnet CLI from: https://github.com/google/go-jsonnet"
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Jsonnet compilation failed:\n{e.stderr}")
    except json.JSONDecodeError as e:
        raise RuntimeError(f"Invalid JSON output from Jsonnet: {e}")


def is_jsonnet_file(file_path: Path) -> bool:
    """Check if a file is a Jsonnet file based on extension."""
    return file_path.suffix in [".jsonnet", ".libsonnet"]


def load_dashboard(file_path: Path) -> dict[str, Any]:
    """Load a dashboard from JSON or Jsonnet file.

    Args:
        file_path: Path to dashboard file

    Returns:
        Dashboard JSON as dict
    """
    if is_jsonnet_file(file_path):
        return compile_jsonnet(file_path)
    else:
        with open(file_path) as f:
            return json.load(f)
