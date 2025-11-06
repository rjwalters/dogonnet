# Example Validation Guide

## Quick Validation

To validate all examples locally:

```bash
python scripts/validate_examples.py
```

Expected output:
```
======================================================================
VALIDATING EXAMPLES
======================================================================

✓ basic.jsonnet
  Title:   Basic Dashboard
  Layout:  ordered
  Widgets: 4

✓ golden-signals.jsonnet
  Title:   Golden Signals: payment-api
  Layout:  ordered
  Widgets: 23

✓ infrastructure.jsonnet
  Title:   Infrastructure Overview
  Layout:  ordered
  Widgets: 19

✓ service-health.jsonnet
  Title:   Service Health - my-service
  Layout:  ordered
  Widgets: 13

======================================================================
RESULTS: 4/4 examples valid
Total widgets: 59
Status: ✓ ALL EXAMPLES VALID
======================================================================
```

## Manual Validation

### Compile a Single Example

```bash
# Using CLI
doggonet compile examples/basic.jsonnet

# Using Python
python -c "
from pathlib import Path
from doggonet.utils.jsonnet import compile_jsonnet
result = compile_jsonnet(Path('examples/basic.jsonnet'))
print(result['title'])
"
```

### Validate Example Output

```bash
# Compile and validate JSON structure
doggonet compile examples/basic.jsonnet > output.json
python -c "
import json
with open('output.json') as f:
    data = json.load(f)
    assert 'title' in data
    assert 'widgets' in data
    assert 'layout_type' in data
    print('✓ Valid Datadog dashboard JSON')
"
```

## What Gets Validated

The validation script checks:

### 1. Compilation
- ✅ Jsonnet file compiles without errors
- ✅ No syntax errors
- ✅ All imports resolve correctly
- ✅ All functions exist

### 2. Required Fields
- ✅ `title` - Dashboard title
- ✅ `widgets` - Widget array
- ✅ `layout_type` - Layout type (ordered/grid)

### 3. Data Types
- ✅ `widgets` is a list
- ✅ `layout_type` is string ('ordered' or 'grid')
- ✅ Each widget is a dictionary
- ✅ Each widget has a `definition` field

### 4. Widget Structure
- ✅ Widgets have proper structure
- ✅ Widget definitions exist
- ✅ No malformed widgets

## CI/CD Integration

Examples are automatically validated on every commit:

- **Workflow:** `.github/workflows/test.yml`
- **Step:** "Validate examples"
- **Runs:** After tests, before coverage upload
- **Fails build if:** Any example doesn't compile

## Common Errors & Fixes

### Error: "field does not exist"

```
RUNTIME ERROR: field does not exist: requestTimeseries
```

**Fix:** Check function name in `src/doggonet/lib/presets.libsonnet`
- Use `requestRateTimeseries` not `requestTimeseries`
- Use `errorRateTimeseries` not `errorTimeseries`

### Error: "too many args"

```
RUNTIME ERROR: too many args, function has 2 parameter(s)
```

**Fix:** Preset functions only take 2 parameters (title, query), not 3
```jsonnet
// ✗ Wrong - passing options as 3rd parameter
presets.cpuTimeseries('CPU', 'avg:cpu{*}', { show_legend: true })

// ✓ Correct - only title and query
presets.cpuTimeseries('CPU', 'avg:cpu{*}')
```

### Error: "couldn't open import"

```
RUNTIME ERROR: couldn't open import "doggonet/lib/main.libsonnet"
```

**Fix:** Make sure package is installed correctly
```bash
pip install -e ".[dev]"
```

The library path is automatically added by `compile_jsonnet()` function.

## Testing New Examples

When creating a new example:

1. **Create the file** in `examples/`
   ```bash
   touch examples/my-new-example.jsonnet
   ```

2. **Test compilation**
   ```bash
   doggonet compile examples/my-new-example.jsonnet
   ```

3. **Run full validation**
   ```bash
   python scripts/validate_examples.py
   ```

4. **Verify output structure**
   - Has title
   - Has widgets array
   - Has layout_type
   - All widgets have definitions

## Validation in Development

### Pre-commit Hook (Optional)

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
python scripts/validate_examples.py
if [ $? -ne 0 ]; then
    echo "Example validation failed. Fix examples before committing."
    exit 1
fi
```

### Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Watch Mode

For continuous validation during development:

```bash
# Install watchdog
pip install watchdog

# Watch examples directory
watchmedo shell-command \
    --patterns="*.jsonnet" \
    --recursive \
    --command='python scripts/validate_examples.py' \
    examples/
```

## Troubleshooting

### All Examples Fail

1. Check Python environment:
   ```bash
   which python
   pip list | grep doggonet
   ```

2. Reinstall package:
   ```bash
   pip install -e ".[dev]"
   ```

3. Check jsonnet installation:
   ```bash
   python -c "import _jsonnet; print('jsonnet OK')"
   ```

### One Example Fails

1. Compile it directly to see full error:
   ```bash
   doggonet compile examples/failing-example.jsonnet 2>&1
   ```

2. Check for typos in function names

3. Verify all imports exist

4. Check preset function signatures in `src/doggonet/lib/presets.libsonnet`

## Best Practices

### When Writing Examples

1. **Test early and often** - Don't wait until the end to compile
2. **Use existing patterns** - Look at working examples first
3. **Check preset signatures** - Verify parameter count
4. **Validate output** - Make sure JSON structure is correct
5. **Add comments** - Explain what the example demonstrates

### Available Preset Functions

Check what's actually available:
```bash
grep "^\s\+[a-z]" src/doggonet/lib/presets.libsonnet | head -20
```

Common presets:
- `cpuTimeseries(title, query)`
- `memoryTimeseries(title, query)`
- `errorRateTimeseries(title, query)`
- `latencyTimeseries(title, query)`
- `requestRateTimeseries(title, query)`
- `diskUsageGauge(title, query)` (gauge only, no timeseries)

For anything else, use `widgets.timeseries()` directly.

## Success Metrics

All examples should:
- ✅ Compile without errors
- ✅ Produce valid Datadog JSON
- ✅ Demonstrate clear use cases
- ✅ Include helpful comments
- ✅ Use realistic metric names
- ✅ Follow consistent patterns

---

**Current Status:** ✅ 4/4 examples valid (100%)

**Last Validated:** [Auto-updated by CI]

**Total Widgets:** 59 across all examples
