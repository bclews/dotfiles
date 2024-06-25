
# Default target
all: stow

# Stow all configuration files
stow:
	@for config in $(shell find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \;); do \
		stow $$config; \
	done
	@echo "All configurations stowed."

# Unstow all configuration files
unstow:
	@for config in $(shell find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \;); do \
		stow -D $$config; \
	done
	@echo "All configurations unstowed."

# Show usage
help:
	@echo "Usage:"
	@echo "  make         - Stow all configurations"
	@echo "  make stow    - Stow all configurations"
	@echo "  make unstow  - Unstow all configurations"
	@echo "  make help    - Show this help message"

.PHONY: all stow unstow help

