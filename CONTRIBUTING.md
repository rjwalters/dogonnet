# Contributing to dogonnet

Thank you for your interest in contributing to dogonnet! This guide will help you get started.

## Development Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/dogonnet.git
cd dogonnet
```

2. Create a virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate
```

3. Install in development mode:
```bash
pip install -e ".[dev]"
```

## Making Changes

1. Create a new branch:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes

3. Run tests and linting:
```bash
# Run linting
ruff check .

# Format code
ruff format .

# Run type checking
mypy src/dogonnet

# Run tests (if available)
pytest
```

## Code Style

- Follow PEP 8 style guidelines
- Use type hints for all function signatures
- Keep line length to 120 characters
- Write docstrings for all public functions and classes

## Jsonnet Library Guidelines

When contributing to the Jsonnet library (`src/dogonnet/lib/`):

1. **Progressive Disclosure**: Support simple one-liner usage with optional complexity
2. **LLM-Friendly Documentation**: Use `@` tags for structured documentation
3. **Type Safety**: Document all enum values and valid options
4. **Backward Compatibility**: Don't break existing APIs

Example:
```jsonnet
// @widget: my_widget
// @purpose: What this widget does
// @simple: widgets.myWidget('Title', 'query')
// @options: { option1: 'value1', option2: 'value2' }

myWidget(title, query, options={}):: {
  // Implementation
}
```

## Submitting Changes

1. Commit your changes:
```bash
git commit -m "Add feature: description"
```

2. Push to your fork:
```bash
git push origin feature/your-feature-name
```

3. Create a Pull Request on GitHub

## Pull Request Guidelines

- Include tests for new features
- Update documentation as needed
- Add examples if introducing new functionality
- Keep PRs focused on a single feature or fix
- Write clear commit messages

## Questions?

Feel free to open an issue for any questions or concerns!
