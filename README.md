# Configuration Files for Windows

## Installation

To install the configuration files (`.bashrc`, `.inputrc`, `alacritty.toml`), the PowerShell profile (bashmarks + vi-mode PSReadLine config), and `oh-my-bash`:

1. Open Git Bash in this repository's directory.
2. Run the installation script:
   ```bash
   ./INSTALL.sh
   ```
   This script will:
   - Backup your existing configuration files (appending `.bak`).
   - Create symlinks to the files in this repository.
   - Install [oh-my-bash](https://github.com/ohmybash/oh-my-bash) if it is not already installed.
   - Render `profile.ps1` to your real PowerShell `$PROFILE` path (baking in
     this repo's absolute path so it can dot-source `bashmarks.plugin.ps1`).
   - On native Windows (not WSL), repoint the Start Menu "Git Bash" shortcut
     at Alacritty, so opening "Git Bash" launches bash inside Alacritty
     instead of the default mintty window (see Alacritty Configuration below).

## Bashmarks

`bm`/`s`/`g`/`p`/`d` (save/goto/print/delete directory bookmarks) work the
same way in both Git Bash and PowerShell, and share the same bookmark file
(`~/.sdirs`), so a bookmark saved in one shell is immediately available in
the other. The bash version is `bashmarks.plugin.sh` (sourced from
`.bashrc`); the PowerShell port is `bashmarks.plugin.ps1` (dot-sourced from
`profile.ps1`).

## Predictions / Tab Completion

Both shells are configured with inline "ghost text" suggestions (based on
command history) plus vi-mode-aware Tab completion, so the experience is
consistent whether you're in PowerShell or WSL/Git Bash.

### PowerShell

- Configured in `profile.ps1` via **PSReadLine** (requires PSReadLine 2.2+;
  installed/upgraded automatically by `INSTALL.sh`'s `ensure_ps_readline`,
  since Windows PowerShell 5.1 only ships 2.0.0 built in).
- `Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView`
  enables the gray inline suggestion as you type.
- `Tab` (vi Insert mode) is bound to a custom handler: it accepts the
  inline suggestion if one is showing, otherwise falls back to normal vi
  tab-completion (paths, commands, parameters).
- `v` (vi Command mode) is bound to `ViEditVisually`, which opens the
  current command line in nvim (`$env:VISUAL`/`$env:EDITOR`) for editing,
  mirroring bash vi-mode's `v` key.

### WSL / Git Bash

- Configured in `.bashrc` via **[ble.sh](https://github.com/akinomyoga/ble.sh)**
  (Bash Line Editor), which replaces GNU Readline with inline ghost-text
  suggestions from history, syntax highlighting, and vi-mode support.
- Installed to `~/.local/share/blesh` by `INSTALL.sh`'s `ensure_ble_sh`
  (WSL only - it needs `make`/`gawk`, which Git Bash on native Windows
  doesn't provide; `.bashrc`'s `[ -r ... ]` file check makes it a no-op
  there instead of an error).
- Vi mode is picked up automatically from `.inputrc`'s
  `set editing-mode vi` - no separate ble.sh vi-mode config is needed.
- `Tab` (vi Insert mode) already triggers completion via ble.sh's own
  default `vi_imap` binding (`ble-bind -f 'TAB' 'vi_imap/complete'`).
- Per ble.sh's own setup instructions, it's sourced near the top of
  `.bashrc` (`--attach=none`) and attached (`ble-attach`) at the very end,
  after all other `.bashrc` customization.

## Alacritty Configuration

Install Alacritty at `~/Applications/Alacritty.exe` (this path is not on
PATH by default, but `.bashrc` aliases `alacritty` to it, and the AutoHotkey
scripts and INSTALL.sh-rendered configs also expect it there).

Two Alacritty config files are included:

- `alacritty.toml` — defaults to Git Bash as the shell.
- `alacritty.ps.toml` — uses PowerShell 7 (pwsh.exe). Copy to `alacritty.toml` if you prefer PowerShell as your Alacritty shell.

### Making "Git Bash" open in Alacritty

By default, the Windows "Git Bash" shortcut launches `git-bash.exe`, which
opens its own mintty window and never touches Alacritty. `INSTALL.sh`
repoints that shortcut's target at `~/Applications/Alacritty.exe
--config-file ~/.alacritty.toml`, so opening "Git Bash" from the Start Menu
or search now opens an Alacritty window running bash instead. The original
shortcut is backed up to `Git Bash.lnk.bak` in the same folder. The
`alacritty` alias in `.bashrc` uses the same `--config-file` flag, so running
`alacritty` from an existing shell behaves the same way.

**Architecture:** Alacritty is the terminal emulator itself (its own native,
GPU-rendered window) - Windows Terminal is not involved at all. Per
`terminal.shell` in `.alacritty.git-bash.toml`, Alacritty spawns `bash.exe`
(Git Bash) directly as a child process, communicating through a hidden
Windows ConPTY (a `conhost.exe --headless` helper process you won't see a
window for). Confirmed via process tree - `bash.exe`'s parent process ID is
Alacritty's:

```
Alacritty.exe                        <- the terminal emulator/window
 +- conhost.exe --headless ...       <- Windows' ConPTY backend (invisible plumbing)
 +- bash.exe --login -i              <- Git Bash shell, direct child of Alacritty
```

This is unrelated to the `Win+N` Neovim hotkey in the AutoHotkey scripts,
which intentionally opens Neovim inside Windows Terminal (`wt`) instead -
that hotkey's `WindowsTerminal.exe`/`OpenConsole.exe` process tree is
completely separate from Alacritty's.

### Ctrl+Alt+T hotkey opens in $HOME, not the repo folder

`application-shortcuts.v2.ahk` runs `SetWorkingDir A_ScriptDir` at startup,
setting the AutoHotkey script's own working directory to wherever the
`.ahk` file lives - normally this repo's folder. Without an explicit
working directory, a process launched via `Run()` inherits that cwd, so the
`Ctrl+Alt+T` Alacritty hotkey used to open its shell inside
`dotfiles-windows` instead of `$HOME`. The hotkey now passes
`--working-directory` (Alacritty's own flag for this) pointing at
`%USERPROFILE%`, so it starts in `$HOME` like the other Alacritty entry
points (the Start Menu shortcut and the `alacritty` bash alias).

## AutoHotkey

- Install AutoHotkey by downloading the [zip file from Github](https://github.com/AutoHotkey/AutoHotkey/releases), store version will likely blocked on corporate devices

- Run Script at Startup

```
Press Win + R
-> Type shell:startup
-> Right-click inside the Startup folder
-> New
-> Shortcut
-> Browse to your .ahk file -> Next -> Finish)
```
