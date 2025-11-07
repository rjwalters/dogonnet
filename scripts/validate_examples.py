#!/usr/bin/env python3
"""
Validate that all example Jsonnet files compile correctly.

This script:
1. Finds all .jsonnet files in the examples/ directory
2. Compiles each one using doggonet
3. Validates the output has required Datadog dashboard fields
4. Reports success/failure

Usage:
    python scripts/validate_examples.py
"""

import sys
from pathlib import Path

from doggonet.utils.jsonnet import compile_jsonnet


def validate_dashboard_json(dashboard: dict, filename: str) -> list[str]:
    """Validate that dashboard JSON has required fields.

    Returns list of error messages (empty if valid).
    """
    errors = []

    # Required top-level fields
    if 'title' not in dashboard:
        errors.append(f"{filename}: Missing required field 'title'")
    if 'widgets' not in dashboard:
        errors.append(f"{filename}: Missing required field 'widgets'")
    if 'layout_type' not in dashboard:
        errors.append(f"{filename}: Missing required field 'layout_type'")

    # Validate types
    if 'widgets' in dashboard and not isinstance(dashboard['widgets'], list):
        errors.append(f"{filename}: 'widgets' must be a list")

    if 'layout_type' in dashboard and dashboard['layout_type'] not in ['ordered', 'grid']:
        errors.append(f"{filename}: 'layout_type' must be 'ordered' or 'grid'")

    # Validate widgets
    if 'widgets' in dashboard:
        for i, widget in enumerate(dashboard['widgets']):
            if not isinstance(widget, dict):
                errors.append(f"{filename}: Widget {i} is not a dictionary")
                continue

            if 'definition' not in widget:
                errors.append(f"{filename}: Widget {i} missing 'definition'")

    return errors


def main():
    """Main validation logic."""
    examples_dir = Path('examples')

    if not examples_dir.exists():
        print(f"Error: {examples_dir} directory not found")
        return 1

    # Find all .jsonnet files
    jsonnet_files = sorted(examples_dir.glob('*.jsonnet'))

    if not jsonnet_files:
        print(f"Warning: No .jsonnet files found in {examples_dir}")
        return 0

    print('=' * 70)
    print('VALIDATING EXAMPLES')
    print('=' * 70)
    print()

    success_count = 0
    total_widgets = 0
    all_errors = []

    for jsonnet_file in jsonnet_files:
        filename = jsonnet_file.name
        try:
            # Compile
            result = compile_jsonnet(jsonnet_file)

            # Validate
            errors = validate_dashboard_json(result, filename)

            if errors:
                print(f'✗ {filename}')
                for error in errors:
                    print(f'  - {error}')
                    all_errors.append(error)
                print()
                continue

            # Success!
            title = result.get('title', 'No title')
            widget_count = len(result.get('widgets', []))
            layout = result.get('layout_type', 'unknown')

            print(f'✓ {filename}')
            print(f'  Title:   {title}')
            print(f'  Layout:  {layout}')
            print(f'  Widgets: {widget_count}')
            print()

            success_count += 1
            total_widgets += widget_count

        except Exception as e:
            print(f'✗ {filename}')
            print(f'  Compilation Error: {str(e)[:500]}')
            print()
            all_errors.append(f"{filename}: {str(e)}")

    # Summary
    print('=' * 70)
    print(f'RESULTS: {success_count}/{len(jsonnet_files)} examples valid')

    if success_count == len(jsonnet_files):
        print(f'Total widgets: {total_widgets}')
        print('Status: ✓ ALL EXAMPLES VALID')
        print('=' * 70)
        return 0
    else:
        print(f'Failed: {len(jsonnet_files) - success_count}')
        print(f'Errors: {len(all_errors)}')
        print('Status: ✗ VALIDATION FAILED')
        print('=' * 70)
        return 1


if __name__ == '__main__':
    sys.exit(main())
