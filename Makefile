
# Default target
all: stow

# --- OS-aware package selection ---
# `wildcard */` skips dotdirs (.git, .claude), so only @notes needs explicit
# filtering. Per-OS skip lists exclude packages that have no meaning on the
# target OS (e.g. Hammerspoon on Linux). To skip a package on a specific
# machine regardless of OS, export SKIP_LOCAL="pkg1 pkg2" in the environment.
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
  SKIP_OS :=
else ifeq ($(UNAME_S),Linux)
  SKIP_OS := hammerspoon
else
  SKIP_OS :=
endif

ALL_DIRS := $(patsubst %/,%,$(wildcard */))
PACKAGES := $(filter-out @notes $(SKIP_OS) $(SKIP_LOCAL),$(ALL_DIRS))

# Stow all configuration files
stow:
	@for config in $(PACKAGES); do \
		stow $$config; \
	done
	@echo "Stowed on $(UNAME_S): $(PACKAGES)"

# Unstow all configuration files
unstow:
	@for config in $(PACKAGES); do \
		stow -D $$config; \
	done
	@echo "Unstowed on $(UNAME_S): $(PACKAGES)"

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

# Show resolved package list (useful for debugging OS detection)
list:
	@echo "OS:       $(UNAME_S)"
	@echo "Skipped:  $(SKIP_OS) $(SKIP_LOCAL)"
	@echo "Packages: $(PACKAGES)"

# Show usage
help:
	@echo "Usage:"
	@echo "  make             - Stow all configurations for this OS"
	@echo "  make stow        - Stow all configurations for this OS"
	@echo "  make unstow      - Unstow all configurations for this OS"
	@echo "  make list        - Show which packages would be stowed"
	@echo "  make completions - Regenerate cached zsh completions"
	@echo "  make help        - Show this help message"
	@echo ""
	@echo "Env vars:"
	@echo "  SKIP_LOCAL=\"pkg1 pkg2\"  Skip packages on this machine regardless of OS"

.PHONY: all stow unstow completions list help
