# doggonet TODO - Production Readiness

Prioritized task list for making doggonet production-ready for 1.0 release.

## 🔥 Critical (Week 1) - Blockers for 1.0

### Testing Foundation
- [ ] **Set up pytest infrastructure**
  - Create `tests/` directory structure
  - Add `tests/conftest.py` with fixtures
  - Configure pytest in `pyproject.toml`
  - Set up coverage reporting (`pytest-cov`)

- [ ] **Unit tests for core modules (target: 80%+ coverage)**
  - [ ] `tests/test_client_dashboard.py` - API client tests
    - Test create/update/delete/get/list methods
    - Mock API responses with `responses` or `pytest-mock`
    - Test error handling (404, 401, rate limits)
  - [ ] `tests/test_utils_jsonnet.py` - Jsonnet compilation
    - Test successful compilation
    - Test error handling (invalid jsonnet, missing files)
    - Test external variables
  - [ ] `tests/test_cli_main.py` - CLI commands
    - Test each command with mocked client
    - Test --help output
    - Test error messages

- [ ] **Widget validation tests**
  - [ ] `tests/test_widgets.py` - Test each widget produces valid JSON
  - [ ] Test all 9 widget types compile
  - [ ] Validate output against expected structure

### Documentation
- [ ] **Complete API reference**
  - Document all public Python functions
  - Add docstring examples for complex functions
  - Generate API docs (Sphinx or MkDocs)

- [ ] **Update README**
  - Add installation instructions
  - Add authentication setup
  - Add quick examples
  - Add badges (tests, coverage, PyPI)

### CI/CD
- [ ] **GitHub Actions workflow**
  - [ ] `.github/workflows/test.yml` - Run tests on push/PR
    - Test matrix: Python 3.10, 3.11, 3.12
    - Run on Linux, macOS
    - Upload coverage to codecov.io
  - [ ] `.github/workflows/lint.yml` - Linting
    - ruff check
    - ruff format --check
    - mypy (when ready)

## 🎯 High Priority (Week 2) - Quality & Reliability

### Type Safety
- [ ] **Add complete type annotations**
  - [ ] `src/doggonet/client/dashboard.py`
  - [ ] `src/doggonet/utils/jsonnet.py`
  - [ ] `src/doggonet/cli/main.py`
  - Enable mypy strict mode
  - Fix all type errors

### Error Handling
- [ ] **Create custom exception hierarchy**
  - [ ] `src/doggonet/exceptions.py`
    - `DoggonetError` (base)
    - `CompilationError`
    - `APIError`
    - `AuthenticationError`
    - `ValidationError`
  - Update all code to use custom exceptions
  - Improve error messages with actionable suggestions

### Integration Tests
- [ ] **Datadog API integration tests (optional, requires test account)**
  - [ ] `tests/integration/test_dashboard_api.py`
  - Use VCR.py to record/replay API calls
  - Test create → update → delete workflow
  - Test rate limiting handling

### Security
- [ ] **Security audit**
  - Run `pip-audit` on dependencies
  - Add pre-commit hooks (gitleaks or detect-secrets)
  - Review credential handling
  - Add security documentation

## 📊 Medium Priority (Week 3) - Completeness

### Widget Coverage
- [ ] **Audit widget implementations**
  - Manually test each of the 9 widgets against Datadog
  - Verify JSON output matches Datadog's schema
  - Fix any discrepancies
  - Add screenshots to docs

- [ ] **Widget documentation**
  - [ ] Update `docs/WIDGETS.md` with all 9 widgets
  - Add examples for each widget
  - Document all options
  - Add visual examples

### Examples
- [ ] **Verify and expand examples**
  - Test all 3 example dashboards
  - Add more comprehensive examples
  - Add example with template variables
  - Add example with external vars

### Presets Audit
- [ ] **Review presets library**
  - Check which presets exist
  - Verify they use correct widgets
  - Update `docs/PRESETS.md`

## 🔧 Nice to Have (Week 4+) - Polish

### Advanced Features
- [ ] **Template variables support**
  - Implement in layouts
  - Add examples
  - Document usage

- [ ] **Dashboard cloning**
  - Add `doggonet clone <id>` command
  - Download and convert to Jsonnet

- [ ] **Batch operations**
  - Support pushing multiple dashboards
  - Parallel uploads with rate limiting

### Developer Experience
- [ ] **Pre-commit hooks**
  - Add `.pre-commit-config.yaml`
  - Configure ruff, mypy, gitleaks
  - Document setup in CONTRIBUTING.md

- [ ] **Development container**
  - Add `.devcontainer/devcontainer.json`
  - Include all dev dependencies
  - VSCode integration

### Performance
- [ ] **Benchmark compilation**
  - Profile large dashboard compilation
  - Optimize if needed
  - Document performance characteristics

## 📚 Documentation Improvements

### User Guide
- [ ] **Tutorial series**
  - Getting started (5 min)
  - Building your first dashboard
  - Advanced patterns
  - CI/CD integration

- [ ] **Migration guides**
  - From manual JSON
  - From Terraform
  - From other tools

### API Documentation
- [ ] **Auto-generate Python docs**
  - Set up Sphinx or MkDocs
  - Configure autodoc
  - Deploy to GitHub Pages or Read the Docs

- [ ] **Jsonnet library reference**
  - Searchable widget reference
  - Interactive examples
  - Cross-references

## 🚀 Release Preparation

### Pre-release Checklist
- [ ] All P0 tests passing
- [ ] 80%+ code coverage
- [ ] All examples working
- [ ] Documentation complete
- [ ] CHANGELOG.md updated
- [ ] Version bumped to 1.0.0

### Publishing
- [ ] **PyPI publishing**
  - [ ] Create PyPI account/token
  - [ ] Test build: `python -m build`
  - [ ] Test upload to TestPyPI
  - [ ] Upload to PyPI
  - [ ] Verify installation: `pip install doggonet`

- [ ] **GitHub Release**
  - Create GitHub release
  - Tag version
  - Upload release notes
  - Link to PyPI package

## 🔍 Ongoing Maintenance

### Regular Tasks
- [ ] **Quarterly Datadog API review**
  - Check for new widgets
  - Check for deprecations
  - Update DATADOG_API_VERSION.md

- [ ] **Dependency updates**
  - Review Dependabot PRs
  - Update dependencies quarterly
  - Test compatibility

- [ ] **Community engagement**
  - Respond to issues
  - Review PRs
  - Update roadmap

## Quick Wins (Do These First!)

These can be done quickly and provide immediate value:

1. **Create tests directory structure** (15 min)
   ```bash
   mkdir -p tests/{unit,integration}
   touch tests/conftest.py tests/__init__.py
   ```

2. **Add pytest configuration** (10 min)
   Update `pyproject.toml` with pytest config

3. **First unit test** (30 min)
   Write one test for `compile_jsonnet()` function

4. **Add GitHub Actions test workflow** (30 min)
   Copy basic workflow from another project

5. **Add README badges** (15 min)
   Add test status, Python version, license badges

6. **Create CHANGELOG.md** (15 min)
   Start tracking changes for 0.1.0 → 1.0.0

## Estimated Timeline

- **Week 1 (Critical)**: ~20-30 hours
  - Testing foundation: 10 hours
  - Core unit tests: 8 hours
  - CI/CD setup: 4 hours
  - Documentation: 4 hours

- **Week 2 (High Priority)**: ~15-20 hours
  - Type annotations: 6 hours
  - Error handling: 4 hours
  - Integration tests: 6 hours
  - Security audit: 3 hours

- **Week 3 (Medium Priority)**: ~15-20 hours
  - Widget audit: 8 hours
  - Examples: 4 hours
  - Documentation: 6 hours

- **Week 4 (Polish)**: ~10-15 hours
  - Advanced features: 8 hours
  - Developer experience: 4 hours
  - Performance: 3 hours

**Total Estimated Effort**: 60-85 hours for 1.0 release

## Dependencies Between Tasks

```
Testing Foundation
  ↓
Unit Tests → CI/CD Setup → Type Annotations
  ↓                            ↓
Integration Tests      Error Handling
  ↓                            ↓
Widget Audit               Security Audit
  ↓                            ↓
Documentation Updates    Pre-release Checklist
  ↓                            ↓
        PyPI Publishing
```

## Notes

- Focus on P0 items first - they're blockers for 1.0
- Run tests frequently during development
- Document as you go
- Get early feedback from users on examples
- Consider a 0.2.0 beta release before 1.0

## Success Metrics for 1.0

- [ ] 80%+ test coverage
- [ ] All examples work without errors
- [ ] Zero critical bugs
- [ ] Complete documentation
- [ ] Positive feedback from 3+ early adopters
- [ ] All widgets produce valid Datadog JSON
- [ ] Published to PyPI
- [ ] CI/CD passing on all platforms
