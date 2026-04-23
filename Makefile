
# Default target
all: stow

# Stow all configuration files
stow:
	@for config in $(shell find . -mindepth 1 -maxdepth 1 -type d ! -name '.git' ! -name '@notes' -exec basename {} \;); do \
		stow $$config; \
	done
	@echo "All configurations stowed."

# Unstow all configuration files
unstow:
	@for config in $(shell find . -mindepth 1 -maxdepth 1 -type d ! -name '.git' ! -name '@notes' -exec basename {} \;); do \
		stow -D $$config; \
	done
	@echo "All configurations unstowed."

# Regenerate cached zsh completions for tools that ship `<tool> completion zsh`
COMPLETIONS_DIR := $(HOME)/.cache/zsh-completions
completions:
	@mkdir -p $(COMPLETIONS_DIR)
	@kubectl completion zsh  > $(COMPLETIONS_DIR)/_kubectl
	@helm completion zsh     > $(COMPLETIONS_DIR)/_helm
	@gh completion -s zsh    > $(COMPLETIONS_DIR)/_gh
	@docker completion zsh   > $(COMPLETIONS_DIR)/_docker
	@minikube completion zsh > $(COMPLETIONS_DIR)/_minikube
	@echo "Regenerated completions in $(COMPLETIONS_DIR)."

# Show usage
help:
	@echo "Usage:"
	@echo "  make             - Stow all configurations"
	@echo "  make stow        - Stow all configurations"
	@echo "  make unstow      - Unstow all configurations"
	@echo "  make completions - Regenerate cached zsh completions"
	@echo "  make help        - Show this help message"

.PHONY: all stow unstow completions help

