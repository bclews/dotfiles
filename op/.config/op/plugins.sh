export OP_PLUGIN_ALIASES_SOURCED=1
# alias gh="op plugin run -- gh"

# Function for GitHub CLI tool
gh() {
	op plugin run -- gh "$@"
}

# Add other command functions managed by 1Password's CLI as needed
# Example for another tool, replace 'tool' with actual command
#tool() {
#    op plugin run -- tool "$@"
#}

# Repeat the pattern above for all other commands managed by `op`
