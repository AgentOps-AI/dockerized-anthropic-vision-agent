.PHONY: venv



# Default target
all: venv

# Setup development environment and debugging
venv:
	@if [ ! -d ".venv" ]; then \
		if command -v uv >/dev/null 2>&1; then \
			uv venv && uv pip install -e ".[dev]"; \
		else \
			pip install -e ".[dev]"; \
		fi; \
		echo "Virtual environment created and activated"; \
	fi
