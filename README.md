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
