# Production Readiness Checklist

This checklist tracks the work needed to make dogonnet production-grade.

## Documentation & API Versioning

### Datadog API Compatibility
- [ ] **Document Datadog API version target**
  - Research and document which Datadog Dashboard API version we're targeting
  - Reference: https://docs.datadoghq.com/api/latest/dashboards/
  - Current status: Using v1 Dashboard API (needs verification)
  - Action: Add `DATADOG_API_VERSION.md` documenting:
    - API version (v1)
    - Documentation snapshot date (e.g., "As of 2024-01-15")
    - Link to archived API docs if available
    - Known limitations or deprecations

- [ ] **Widget type coverage audit**
  - Compare our widgets against Datadog's official widget types
  - Document which widgets are supported vs. not supported
  - Create tracking issue for unsupported widgets
  - Reference: https://docs.datadoghq.com/dashboards/widgets/

- [ ] **API schema validation**
  - Add JSON schema for dashboard JSON
  - Validate generated dashboards against Datadog's expected schema
  - Add schema validation tests

### Documentation Improvements
- [ ] **API reference documentation**
  - Auto-generate Python API docs (Sphinx/MkDocs)
  - Document all public functions with examples
  - Add type annotations throughout

- [ ] **Jsonnet library reference**
  - Create searchable reference for all widgets, presets, layouts
  - Add cross-references between related functions
  - Include visual examples/screenshots where possible

- [ ] **Migration guides**
  - Create guide for users migrating from manual JSON
  - Create guide for users coming from Terraform
  - Add upgrade guide template for future versions

- [ ] **Tutorial series**
  - Getting started (5 min quickstart)
  - Building a service dashboard (15 min)
  - Advanced patterns (custom components, external vars)
  - CI/CD integration guide

## Testing

### Unit Tests
- [ ] **Python unit tests (target: 90%+ coverage)**
  - `client/dashboard.py`: API client methods
  - `utils/jsonnet.py`: Compilation logic
  - `cli/main.py`: CLI commands (with mocks)
  - Error handling paths
  - Edge cases (empty dashboards, malformed JSON, etc.)

- [ ] **Jsonnet library tests**
  - Test widget builders produce valid JSON
  - Test layout calculations (positioning, sizing)
  - Test preset configurations
  - Regression tests for known issues

### Integration Tests
- [ ] **Datadog API integration tests**
  - Create/update/delete dashboard (requires test account)
  - List dashboards
  - Fetch dashboard by ID
  - Handle rate limiting
  - Handle authentication errors
  - Use VCR.py or similar for recording/replaying API calls

- [ ] **Jsonnet compilation tests**
  - Compile all example dashboards
  - Test external variables
  - Test import paths
  - Test error messages for invalid Jsonnet

### End-to-End Tests
- [ ] **CLI integration tests**
  - Test full workflow: create → push → fetch → update → delete
  - Test --dry-run mode
  - Test error handling for missing credentials
  - Test output formatting (JSON, tables, etc.)

### Property-Based Tests
- [ ] **Fuzz testing**
  - Generate random dashboard configurations
  - Ensure no crashes on valid inputs
  - Test boundary conditions (very large dashboards, etc.)

## Code Quality

### Type Safety
- [ ] **Complete type annotations**
  - Add types to all function signatures
  - Add return type annotations
  - Run mypy in strict mode: `mypy --strict src/dogonnet`

- [ ] **Pydantic models**
  - Create Pydantic models for Dashboard, Widget, Layout
  - Validate API responses
  - Provide better error messages

### Error Handling
- [ ] **Custom exception hierarchy**
  - `DoggonetError` (base)
  - `CompilationError` (Jsonnet errors)
  - `APIError` (Datadog API errors)
  - `AuthenticationError` (credential issues)
  - `ValidationError` (schema validation)

- [ ] **Comprehensive error messages**
  - Include context (what was being done, what went wrong)
  - Suggest fixes where possible
  - Include links to docs for common errors

- [ ] **Graceful degradation**
  - Handle network failures with retries
  - Handle rate limiting (exponential backoff)
  - Timeout configuration

### Code Style & Linting
- [ ] **Linting configuration**
  - Enable all recommended ruff rules
  - Add pre-commit hooks
  - Configure pylint/flake8 if needed

- [ ] **Format all code**
  - Run ruff format on entire codebase
  - Configure line length, import sorting

- [ ] **Docstring coverage**
  - 100% coverage for public API
  - Use Google or NumPy style consistently
  - Include examples in docstrings

## Security

### Credential Handling
- [ ] **Secure credential storage**
  - Document best practices (environment vars, .env files)
  - Warn against committing credentials
  - Add .env to .gitignore
  - Consider keyring integration for credential storage

- [ ] **Audit dependencies**
  - Run `pip-audit` or `safety check`
  - Pin dependency versions
  - Regular dependency updates

- [ ] **Input validation**
  - Sanitize all user inputs
  - Validate dashboard IDs (format, characters)
  - Prevent path traversal in file operations

### Secrets Scanning
- [ ] **Pre-commit hooks**
  - Add gitleaks or detect-secrets
  - Scan for API keys in commits
  - Scan for hardcoded credentials

## Performance

### Optimization
- [ ] **Benchmark Jsonnet compilation**
  - Measure compilation time for large dashboards
  - Profile memory usage
  - Optimize hot paths

- [ ] **Caching**
  - Cache compiled Jsonnet (optional)
  - Cache API responses where appropriate
  - Consider memoization for expensive operations

- [ ] **Batch operations**
  - Support pushing multiple dashboards at once
  - Implement rate limiting awareness
  - Parallelize independent operations

## Reliability

### Retry Logic
- [ ] **Configurable retries**
  - Make retry count configurable
  - Exponential backoff
  - Jitter to prevent thundering herd

- [ ] **Idempotency**
  - Ensure push operations are idempotent
  - Handle concurrent updates gracefully
  - Conflict resolution strategy

### Logging
- [ ] **Structured logging**
  - Use Python logging module
  - Configurable log levels
  - JSON logging option for machine parsing
  - Redact credentials from logs

- [ ] **Verbose mode**
  - Add `-v/--verbose` flag
  - Show debug information
  - Show API requests/responses (sanitized)

## CI/CD

### GitHub Actions
- [ ] **Test workflow**
  - Run tests on push/PR
  - Test matrix: Python 3.10, 3.11, 3.12, 3.13
  - Test on Linux, macOS, Windows
  - Code coverage reporting (codecov.io)

- [ ] **Lint workflow**
  - Run ruff check
  - Run mypy
  - Check formatting
  - Fail on warnings

- [ ] **Release workflow**
  - Automated PyPI publishing on tag
  - Automated changelog generation
  - GitHub release creation
  - Docker image publishing (optional)

- [ ] **Dependency updates**
  - Dependabot configuration
  - Automated PR creation for updates
  - Pin transitive dependencies

### Pre-commit Hooks
- [ ] **Local development hooks**
  - ruff format
  - ruff check
  - mypy
  - pytest (fast tests only)
  - gitleaks/detect-secrets

## Distribution

### PyPI Publishing
- [ ] **Package metadata**
  - Accurate classifiers
  - Keywords for discoverability
  - Project URLs (homepage, docs, issues)
  - Long description from README

- [ ] **Version management**
  - Use semantic versioning (SemVer)
  - Automated version bumping
  - Changelog maintenance (Keep a Changelog format)
  - Git tags for releases

- [ ] **Build configuration**
  - Test wheel builds locally
  - Verify package contents (manifest check)
  - Source distribution (sdist) + wheel
  - Include all necessary files (libsonnet, docs)

### Alternative Distribution
- [ ] **Conda package** (optional)
  - conda-forge recipe
  - Multi-platform builds

- [ ] **Docker image** (optional)
  - Official Docker image
  - Include all dependencies
  - Examples in image

- [ ] **Homebrew formula** (future)
  - macOS installation via brew

## Examples & Demos

### Example Quality
- [ ] **Verify all examples work**
  - Test compilation of all examples
  - Update examples to use latest API
  - Add comments explaining each section

- [ ] **Expand example coverage**
  - Add example for every widget type
  - Add example for every preset
  - Complex multi-service dashboard
  - Custom component example
  - External variables example

- [ ] **Interactive demos**
  - Jupyter notebook tutorial
  - Web-based playground (stretch goal)
  - Video walkthrough

## Community & Governance

### Repository Setup
- [ ] **README badges**
  - PyPI version
  - Python version support
  - Test status
  - Code coverage
  - License
  - Downloads

- [ ] **Issue templates**
  - Bug report template
  - Feature request template
  - Question template

- [ ] **PR template**
  - Checklist for contributors
  - Link to CONTRIBUTING.md

- [ ] **Code of Conduct**
  - Add CODE_OF_CONDUCT.md
  - Contributor Covenant or similar

### Communication
- [ ] **Changelog**
  - CHANGELOG.md in Keep a Changelog format
  - Document breaking changes
  - Migration guides for major versions

- [ ] **Roadmap**
  - Public roadmap for features
  - Milestone planning
  - Community input on priorities

## Monitoring & Telemetry

### Usage Analytics (Optional)
- [ ] **Opt-in telemetry**
  - Anonymous usage statistics
  - Error reporting (Sentry integration?)
  - Performance metrics
  - Clear privacy policy

### Health Checks
- [ ] **Datadog API status**
  - Check API availability before operations
  - Handle API maintenance windows
  - Status page monitoring

## Compatibility

### Backwards Compatibility
- [ ] **Deprecation policy**
  - Document deprecation process
  - Minimum 2 minor versions before removal
  - Clear deprecation warnings

- [ ] **API stability guarantees**
  - Document what's considered public API
  - Semantic versioning commitment
  - Beta/experimental feature marking

### Forward Compatibility
- [ ] **New Datadog features**
  - Process for adding new widgets
  - Testing against Datadog beta features
  - Feature flags for experimental widgets

## Legal & Compliance

### Licensing
- [ ] **License review**
  - Verify MIT license is appropriate
  - Check all dependency licenses
  - Add NOTICE file if needed
  - Copyright headers in source files

- [ ] **Attribution**
  - Credit grafonnet-lib inspiration
  - List all contributors
  - Third-party acknowledgments

## Datadog-Specific Items

### Widget Coverage Audit
- [ ] **Core widgets** (verify against Datadog docs dated YYYY-MM-DD)
  - [x] Timeseries
  - [ ] Query Value
  - [ ] Heatmap
  - [ ] Toplist
  - [ ] Change
  - [ ] Event Stream
  - [ ] Event Timeline
  - [ ] Alert Graph
  - [ ] Alert Value
  - [ ] Check Status
  - [ ] Distribution
  - [ ] Funnel
  - [ ] Geomap
  - [ ] Hostmap
  - [ ] List
  - [ ] Log Stream
  - [ ] Monitor Summary
  - [ ] Note (text/markdown)
  - [ ] Scatter Plot
  - [ ] SLO
  - [ ] Service Map
  - [ ] Service Summary
  - [ ] Table
  - [ ] Trace Service
  - [ ] Treemap
  - [ ] Pie Chart
  - [ ] Sunburst

- [ ] **Layout types**
  - [ ] Ordered (free-form)
  - [ ] Grid (verify current implementation)
  - [ ] Split (new style)

- [ ] **Template variables**
  - [ ] Basic template variables
  - [ ] Saved views
  - [ ] Presets

### API Feature Parity
- [ ] **Dashboard features**
  - [ ] Restricted roles
  - [ ] Notification settings
  - [ ] Dashboard URLs
  - [ ] Public URLs
  - [ ] Reflow type
  - [ ] Dashboard lists

## Priority Levels

### P0 (Must have for 1.0)
- Documentation of Datadog API version
- Unit tests (80%+ coverage)
- Integration tests (basic)
- Type annotations
- Custom exceptions
- CI/CD (tests + linting)
- PyPI publishing
- Examples verification

### P1 (Should have for 1.0)
- Widget coverage audit
- API schema validation
- Error handling improvements
- Security audit
- Comprehensive docs
- Changelog

### P2 (Nice to have for 1.0)
- Advanced examples
- Performance optimization
- Telemetry (opt-in)
- Docker image

### P3 (Future versions)
- Terraform provider
- Web playground
- Conda package
- Video tutorials

## Next Actions

1. **Create `DATADOG_API_VERSION.md`** documenting the API version
2. **Set up testing infrastructure** (pytest, coverage)
3. **Add type annotations** to all code
4. **Set up CI/CD** (GitHub Actions)
5. **Widget coverage audit** against Datadog docs
6. **Write unit tests** for core modules
7. **Create release process** documentation

---

**Target: 1.0 Release**
- [ ] All P0 items complete
- [ ] 80%+ P1 items complete
- [ ] Production deployment successful
- [ ] Community feedback incorporated
