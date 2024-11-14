.PHONY: venv

# Default target
all: venv

# Setup development environment and debugging
venv:
	@if command -v uv >/dev/null 2>&1; then \
		uv sync --all-extras; \
	else \
		pip install -e ".[dev]"; \
	fi; \
	echo "Virtual environment created and activated"
