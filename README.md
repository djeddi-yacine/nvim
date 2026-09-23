# Neovim configuration

A small, modular Neovim configuration built mostly from Neovim's own APIs.

## Start it

```sh
nvim
```

Use Neovim 0.12 or newer. Neovim 0.13 adds native multicursors; core editing, pickers, LSP, and this config's other features use the supported Neovim APIs. Clone this repository into the directory returned by `:echo stdpath('config')`. Run `:ConfigPluginsInstall` once to install the optional UI plugins. Startup never checks for updates; `:ConfigPluginsStatus` shows what is installed, and `:ConfigPluginsUpdate` checks for updates only when you invoke it.

The theme is Catppuccin Mocha. Editor and floating-window backgrounds are transparent, and popups use sharp square borders. The Catppuccin configuration lives in `lua/config/theme.lua`; set `theme = false` in `lua/plugins/settings.lua` to use the built-in fallback.

The status bar is the final terminal row, touching the terminal border. Neovim's command line is collapsed until needed; partially typed commands appear in the status bar. The status bar separates its fields with `|` and colors them with the active theme. It shows mode, Git branch and change counts, file and modified state, diagnostics, attached LSP names, filetype, encoding, indentation (`S2` means two spaces; `T4` means a four-column tab setting), and a compact `line:column` position. It omits the file's line-ending label (`unix`, `dos`, etc.). `+` is staged files, `~` is unstaged files, `?` is untracked files, and arrows show commits ahead or behind upstream. It hides less essential details in narrow windows. Git status comes from one asynchronous, cached command after launch in a repo and on save or focus; it never runs on every status bar redraw or blocks startup. Run `:ConfigGitRefresh` if you need an immediate update. Its implementation is in `lua/config/git_status.lua`; remove its `setup()` call in `init.lua` to disable it.

## Think of it like VS Code

| VS Code | Here |
| --- | --- |
| Explorer | `<Space>e` (mini.files) |
| Quick Open | `<Space>ff` (fuzzy mini.pick) |
| Search in Files | `<Space>fg` (live ripgrep search) |
| Open editors | `<Space>fb` or `[b` / `]b` |
| Extensions | `lua/plugins/` and `:ConfigPluginsInstall` |
| Language extensions | `lua/languages/` and `:ConfigLangEnable` |
| Problems | `<Space>lq` or `<Space>ld` |
| Go to definition | `gd` after LSP attaches |
| Format document | `<Space>lf` |
| Surround selection/text | `sa`, `sd`, `sr` from mini.surround |
| Multicursor | Native `Q`, `1Q`, visual `Q`, `Ctrl-L` |

`<Space>` is the leader key: release Space, then press the following letters. The `mini.clue` key hint appears immediately after Space; press `Esc` to dismiss it. The file explorer and pickers also close with `Esc`.

## Find and move between files

Start in a project directory with `cd /path/to/project && nvim`, or open a project file directly. File and text searches use the current Git repository root when there is one. Outside Git, they use the current directory or the open file's directory.

| Goal | Keys |
| --- | --- |
| Find a file by fuzzy name or path | `<Space>ff`, type a few characters, then Enter |
| Search text inside project files | `<Space>fg`, type a pattern, then Enter on a match |
| See open files | `<Space>fb` |
| Previous or next open buffer | `[b` or `]b` |
| Switch back to the previous file | `Ctrl-6` (standard `Ctrl-^`) |
| Close the current file buffer | `<Space>bd` or `:bdelete` |

In a picker, `Ctrl-N` / `Ctrl-P` or arrow keys move through results, `Tab` toggles a preview, and `Shift-Tab` shows picker help. Enter opens a result in the current window; `Ctrl-S`, `Ctrl-V`, and `Ctrl-T` open it in a horizontal split, vertical split, or new tab. `Esc` closes the picker. File search includes dotfiles, respects `.gitignore`, and skips the `.git` directory. Text search uses ripgrep's normal ignore rules.

`<Space>e` opens the file explorer at the current file. Use `j`/`k` to move, `l` to enter a directory or open a file while keeping the explorer open, `h` to go to the parent directory, Enter to open a file and close the explorer, and `Esc` to close it. `g?` shows its built-in help; `Esc` closes that help too. To create, rename, or delete files, edit their names or lines in the explorer and press `=` to review and confirm the changes. The explorer shows directories; the fuzzy picker is usually faster when you know part of a filename. In Neovim, a buffer is an open file; `:q` closes a window, while `:bdelete` removes its buffer from the open-file list.

If a buffer has unsaved edits, closing it with `<Space>bd` / `:bdelete` or exiting with `<Space>q` / `:q` asks whether to save, discard, or cancel. Switching between files keeps unsaved buffers open. The confirmation applies to standard Neovim commands too; `:q!` still explicitly discards changes.

## Standard Neovim keys

These work without a plugin or a custom mapping:

| Do this | Keys |
| --- | --- |
| Enter insert mode; return to normal | `i`; `Esc` |
| Move by character or word | `h j k l`; `w` next word, `b` previous word |
| Start/end of line or file | `0`, `$`; `gg`, `G` |
| Search and repeat | `/text` then Enter; `n` next, `N` previous; `*` searches the word under the cursor |
| Select text | `v` for characters, `V` for lines, `Ctrl-V` for a block |
| Delete, copy, paste | `dd` delete line, `yy` copy line, `p` paste |
| Change a word; repeat edit | `ciw`; `.` repeats the last change |
| Undo and redo | `u`; `Ctrl-R` |
| Save, quit, edit another file | `:w`, `:q`, `:e path`; `:wq` does both |
| Move between windows | `Ctrl-W` then `h`, `j`, `k`, or `l` |
| Open help | `:help topic` |

The config also provides these shortcuts. Use the standard commands above whenever you prefer:

| Keys | Action |
| --- | --- |
| `<Space>w`, `<Space>q`, `<Space>bd` | Save, quit, delete current buffer |
| `<Space>t` | Open a disposable terminal split |
| `[b`, `]b` | Previous, next buffer |
| `<Space>e` | File explorer (`h` parent, `l` open, `Esc` close, `g?` help) |
| `<Space>ff`, `<Space>fg`, `<Space>fb`, `<Space>fh` | Find files, search text, buffers, help |
| `<Space>ld`, `<Space>lq`, `[d`, `]d` | Line diagnostics, all diagnostics, previous/next diagnostic |
| `<Space>lf` | Format through the attached LSP |
| `sa`, `sd`, `sr` | Add, delete, replace surrounding text through mini.surround |
| `Esc Esc` in a terminal buffer | Return to normal mode |

Inside a picker, type to filter, Enter to open, and Escape to close. Once an LSP is attached, `K`, `grn`, and `gra` offer hover, rename, and code actions; `<C-Space>` requests completion, `<C-n>` / `<C-p>` select an item, and `<C-y>` accepts it. `gd` goes to the LSP definition while attached. Run `:verbose nmap` to inspect normal-mode mappings and `:help key-notation` to read the notation.

## Terminal inside Neovim

From Normal mode, `<Space>t` opens a disposable terminal in a 12-row bottom split. `:terminal` opens one in the current window when you want the full view; `:vsplit | terminal` opens one beside your file. Type shell commands normally while in Terminal mode. Press `Esc Esc` to return to Normal mode (the native sequence is `Ctrl-\\` then `Ctrl-N`). From there, `Ctrl-W h/j/k/l` moves between windows, and `i` returns to the terminal's input. Type `exit` at the shell prompt to stop the shell. `<Space>q` or `<Space>bd` closes the terminal immediately; terminal buffers are disposable and do not ask about saving. `:q` closes only the current window. To run one shell command without a terminal buffer, use `:!command`.

## Native multicursors

No multicursor plugin is installed. These are Neovim 0.13's built-in keys:

1. Put the cursor on a word and press `*` to search for it. Press `1Q` to place cursors at all matches. Type `ciw` and the replacement text, then `Esc`; each match changes together.
2. For chosen positions, press `Q` to place a cursor, move elsewhere, and press `Q` again. `Ctrl-LeftMouse` toggles one at the click position.
3. Select several lines with `V`, move down, then press `Q` to place one cursor on each selected line. Type `I` or another normal edit.

`Ctrl-L` clears all extra cursors (and search highlighting); `gQ` restores the last set. `]C` and `[C` jump between cursors. `q=` toggles whether movement happens at every cursor. `:help multicursor` has the full native guide. Normal editing keys remain the same while the extra cursors are active.

## Language switches

All five language servers are **off by default** in [`lua/languages/settings.lua`](lua/languages/settings.lua). Syntax coloring and normal editing still work when a server is off.

For the current session:

```vim
:ConfigLangEnable go
:ConfigLangDisable go
:ConfigLangEnable c
:ConfigLangEnable dart
:ConfigLangEnable buf
:ConfigLangEnable lua
:ConfigLanguages
```

For every future launch, change the corresponding `false` to `true` in `lua/languages/settings.lua`, then restart Neovim. Each server's command and root rules live in its own file under `lua/languages/`.

| Switch | Executable used | Files |
| --- | --- | --- |
| `go` | `gopls` | Go files and Go module files |
| `c` | `clangd` | C, C++, Objective-C |
| `dart` | `dart language-server --protocol=lsp` | Dart |
| `buf` | `buf lsp serve` | `.proto` and Buf configuration files |
| `lua` | `lua-language-server` | Lua files, including this Neovim config |

This config does not install or update language servers. Install the executable for each language and make sure it is on `PATH` before enabling that language. Buf uses its CLI language server, so it provides navigation, completion, formatting, and lint diagnostics through one process. Formatting is manual with `<Space>lf`; saving a file does not launch a formatter.

## Development workflow

An LSP server is a separate program that understands a project. Once you enable a language and open a matching file, Neovim starts that server and shows its name in the status line. It provides navigation, completion, code actions, formatting, and live diagnostics according to the server's capabilities. A diagnostic is an error, warning, or hint shown in the sign column and status line; it does not necessarily replace a full project build or lint command.

For example, open a Go project with `nvim main.go`, run `:ConfigLangEnable go`, then check `:checkhealth vim.lsp` if `gopls` does not attach. The server needs a matching filetype and a project root marker such as `go.mod`. `:ConfigLanguages` shows which language switches and executables are available. Enable only the languages you use; switches entered as commands last for the current Neovim session.

| Task | Keys or command | VS Code equivalent |
| --- | --- | --- |
| Show documentation for symbol under cursor | `K` | Hover |
| Jump to definition; jump back | `gd`; `Ctrl-O` | Go to Definition; Go Back |
| Find references / implementations | `grr` / `gri` | Find All References / Go to Implementations |
| Rename symbol across project | `grn` | Rename Symbol |
| Code actions and quick fixes | `gra` | Quick Fix |
| List symbols in current file | `gO` | Go to Symbol in Editor |
| Request completion | `Ctrl-Space` in Insert mode | Trigger Suggest |
| Accept a completion | `Ctrl-Y` in the completion menu | Accept Suggestion |
| Show problem at cursor | `<Space>ld` | View Problem |
| Jump to previous / next problem | `[d` / `]d` | Previous / Next Problem |
| Put all current diagnostics in quickfix | `<Space>lq` | Problems panel |
| Format the current buffer | `<Space>lf` | Format Document |
| Save the buffer | `<Space>w` or `:write` | Save |

Neovim supplies `K`, `grr`, `gri`, `grn`, `gra`, and `gO` as standard LSP keys. This config adds `gd`, the `<Space>l` keys, and automatic completion when a capable server attaches. In the completion menu, `Ctrl-N` / `Ctrl-P` move through items. Code actions can depend on the cursor position or a visual selection.

Formatting acts on the **whole current buffer**, asynchronously, using an attached server that supports formatting. Review the result, then save with `<Space>w`; neither format-on-save nor auto-fix-on-save is enabled. If a server is off or does not offer formatting, `<Space>lf` has nothing to run. Check `:checkhealth vim.lsp` to see which server is attached and what it supports.

For project-wide checks, run the language's CLI in a terminal (`:terminal` opens one; `Esc Esc` returns to Normal mode):

| Project | Manual check | Manual formatter outside Neovim |
| --- | --- | --- |
| Go | `go vet ./...` or `go test ./...` | `gofmt -w file.go` |
| C/C++ | Run the project's compiler or build command; `clang-tidy` if configured | `clang-format -i file.c` |
| Dart | `dart analyze` and `dart test` | `dart format file.dart` |
| Buf / Protobuf | `buf lint`; `buf breaking --against <reference>` when checking compatibility | `buf format -w file.proto` |

These CLI checks run only when you ask for them. `buf lsp serve` also supplies live lint diagnostics for `.proto` files. Use `:copen` to inspect the quickfix list created by `<Space>lq`, Enter to jump to an item, and `:cclose` to close the list. `:lsp restart` restarts the attached server; `:checkhealth vim.lsp` is the first place to diagnose an absent server. See `:help lsp` and `:help diagnostic` for Neovim's complete built-in commands.

## Where to edit

| File | Responsibility |
| --- | --- |
| `init.lua` | Load order only |
| `lua/config/options.lua` | Editor options, including square popup borders |
| `lua/config/keymaps.lua` | Key bindings |
| `lua/config/autocmds.lua` | Editor events and completion on LSP attach |
| `lua/config/git_status.lua` | Asynchronous Git status for the status bar |
| `lua/config/project.lua` | Project root detection for search and Git status |
| `lua/config/theme.lua` | Catppuccin Mocha and transparency |
| `lua/plugins/init.lua` | Explicit plugin install and update commands |
| `lua/plugins/settings.lua` | Persistent editor module switches |
| `lua/plugins/mini.lua` | Picker, explorer, status line, pairs, icons, key hints, text objects, surrounding |
| `lua/plugins/statusline.lua` | Status bar layout and information |
| `lua/languages/settings.lua` | Persistent language switches |
| `lua/languages/{go,c,dart,buf,lua}.lua` | One language server per file |
| `lua/languages/init.lua` | Language command registration |

To add another plugin, put its source in `lua/plugins/init.lua`, install it explicitly, and give its setup its own module under `lua/plugins/`. To add a language, create a definition file and register its name in `lua/languages/init.lua` and `lua/languages/settings.lua`.

## Sources studied

- [Neovim core docs](https://neovim.io/doc/user/): startup, package management, LSP, diagnostics, and terminal.
- [Native multicursors](https://neovim.io/doc/user/repeat/#multicursor): built-in `Q`, `Ctrl-L`, and related motions in 0.13.
- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim): built-in `vim.pack` and LSP examples.
- [LazyVim starter](https://github.com/LazyVim/starter) and [LazyVim core](https://github.com/LazyVim/LazyVim): configuration structure, mappings, and LSP patterns.
- [NvChad starter](https://github.com/NvChad/starter) and [NvChad core](https://github.com/NvChad/NvChad): modular options, mappings, and plugin setup.
- [Buf editor integration](https://buf.build/docs/cli/editors-lsp/): `buf lsp serve` and Buf configuration filetypes.
- [Catppuccin for Neovim](https://github.com/catppuccin/nvim): Mocha, transparency, and Mini integration.

The references were studied as examples; this config does not load any distribution.
