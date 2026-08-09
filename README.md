# Configuration Files for Windows

## Installation

To install the configuration files (`.bashrc`, `.inputrc`, `alacritty.toml`) and `oh-my-bash`:

1. Open Git Bash in this repository's directory.
2. Run the installation script:
   ```bash
   ./INSTALL.sh
   ```
   This script will:
   - Backup your existing configuration files (appending `.bak`).
   - Create symlinks to the files in this repository.
   - Install [oh-my-bash](https://github.com/ohmybash/oh-my-bash) if it is not already installed.
   - On native Windows (not WSL), repoint the Start Menu "Git Bash" shortcut
     at Alacritty, so opening "Git Bash" launches bash inside Alacritty
     instead of the default mintty window (see Alacritty Configuration below).

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
