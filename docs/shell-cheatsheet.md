# Shell cheatsheet

Everyday usage patterns for tools wired up in this dotfiles repo.

## Man pages (via `bat`)

Configured through `MANPAGER` in `zsh/.zshrc`. Workflow is unchanged — just use `man`:

```
man git-rebase
man ls
man zshbuiltins
```

Output is syntax-highlighted: code examples get language highlighting, section headers are styled, and the pager is `less` (via bat) with its search/navigation (`/`, `n`, `N`, `g`, `G`, `q`).

## fzf

Environment variables in `zsh/.zshrc` point fzf at `fd` for listing (respects `.gitignore`, hides `.git`), and wire `bat`/`eza` previews for files/directories.

### Keybindings (interactive)

| Binding             | What it does                                                                 |
|---------------------|------------------------------------------------------------------------------|
| `Ctrl-T`            | Fuzzy-pick a **file**, insert its path at the cursor. Preview: bat.          |
| `Alt-C` (or `Esc c`)| Fuzzy-pick a **directory** and `cd` into it. Preview: eza tree.              |
| `Ctrl-R`            | Fuzzy-search shell **history**. Preview: full command text.                  |

Examples:

```
nvim <Ctrl-T>           # nvim <fuzzy-picked file>
cat <Ctrl-T>            # cat <fuzzy-picked file>
mv <Ctrl-T> <Ctrl-T>    # two pickers, two paths
<Alt-C>                 # jump into any subdirectory
<Ctrl-R>                # reverse-search history
```

### Completion trigger (`**<Tab>`)

Type `**` followed by `<Tab>` to invoke fzf for the current argument of any command:

```
vim **<Tab>             # fuzzy-pick a file as vim's argument
ssh **<Tab>             # fuzzy-pick a known SSH host
git checkout **<Tab>    # fuzzy-pick a branch
kill **<Tab>            # fuzzy-pick a running process
```

### Inside the fzf picker

- Type to filter (fuzzy matching)
- `Ctrl-J` / `Ctrl-K` or arrow keys to move
- `Enter` to select, `Esc` to cancel
- `Tab` / `Shift-Tab` for multi-select (where the binding supports it)
- `Shift-↑` / `Shift-↓` to scroll the preview pane

### macOS + Ghostty caveat

`Alt-C` requires the terminal to send `Option` as `Esc`. Ghostty does this by default for left-Option; if `Alt-C` types `ç` instead of opening the directory picker, check the `macos-option-as-alt` setting. Fall back: press `Esc` then `c`.
