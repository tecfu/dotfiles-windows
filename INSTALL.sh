#!/bin/bash

# Get the directory of the script
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installing dotfiles from $REPO_DIR..."

backup_and_link() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    
    echo "Linking $src to $dest"
    # Ensure source path is absolute
    ln -sf "$src" "$dest"
}

# .bashrc sources bashmarks.plugin.sh from the repo it lives in. It can't
# discover that path at runtime via BASH_SOURCE/readlink, because `ln -s`
# silently falls back to a plain file copy (instead of failing) on Windows
# accounts without symlink privilege (Developer Mode off / non-elevated) -
# a copy has no way to point back to the repo. So instead of symlinking
# .bashrc, render it and bake the repo path in directly, the same way
# render_alacritty_config() bakes absolute import paths into the alacritty
# configs below.
render_bashrc() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    echo "Rendering $src to $dest"
    sed "s#__DOTFILES_REPO_DIR__#$REPO_DIR#g" "$src" > "$dest"
}

# profile.ps1 dot-sources bashmarks.plugin.ps1 from the repo it lives in,
# and (like .bashrc) can't discover that path at runtime, since PowerShell's
# $PSScriptRoot reflects wherever $PROFILE itself is (e.g. under a
# OneDrive-redirected Documents folder), not this repo. So render it the
# same way render_bashrc() does, baking in the absolute repo path.
#
# PowerShell accepts forward slashes in paths just fine, so the baked-in
# path uses `cygpath -m` (forward slashes) rather than `cygpath -w`
# (backslashes) - this avoids having to escape backslashes for sed's
# replacement text.
render_ps_profile() {
    local src="$1"

    if ! command -v powershell.exe >/dev/null 2>&1; then
        echo "powershell.exe not found, skipping PowerShell profile install"
        return
    fi

    local ps_profile_win ps_profile
    ps_profile_win="$(powershell.exe -NoProfile -NonInteractive -Command '$PROFILE' | tr -d '\r')"
    ps_profile="$(cygpath -u "$ps_profile_win")"

    local dest_dir
    dest_dir="$(dirname "$ps_profile")"
    if [ ! -d "$dest_dir" ]; then
        echo "Creating directory $dest_dir"
        mkdir -p "$dest_dir"
    fi

    if [ -e "$ps_profile" ] || [ -L "$ps_profile" ]; then
        echo "Backing up existing $ps_profile to ${ps_profile}.bak"
        mv "$ps_profile" "${ps_profile}.bak"
    fi

    echo "Rendering $src to $ps_profile"
    sed "s#__DOTFILES_REPO_DIR__#$(cygpath -m "$REPO_DIR")#g" "$src" > "$ps_profile"
}

# profile.ps1 requires PSReadLine 2.2+ (for ViEditVisually - the 'v' vi-mode
# editor binding - and predictive IntelliSense). Windows PowerShell 5.1
# ships PSReadLine 2.0.0 built in, which lacks both, so install a newer
# version into the CurrentUser scope alongside it (profile.ps1 loads it
# explicitly via `Import-Module PSReadLine -MinimumVersion 2.2.0 -Force`).
ensure_ps_readline() {
    if ! command -v powershell.exe >/dev/null 2>&1; then
        echo "powershell.exe not found, skipping PSReadLine install"
        return
    fi

    echo "Ensuring PSReadLine >= 2.2.0 is installed for PowerShell"
    powershell.exe -NoProfile -NonInteractive -Command '
        $ErrorActionPreference = "Stop"
        $minVersion = [Version]"2.2.0"
        $installed = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        if ($installed -and $installed.Version -ge $minVersion) {
            Write-Output "PSReadLine $($installed.Version) already installed"
            return
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
        }
        Install-Module -Name PSReadLine -MinimumVersion $minVersion -Force -Scope CurrentUser -AllowClobber -SkipPublisherCheck
        $installed = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        Write-Output "Installed PSReadLine $($installed.Version)"
    ' | tr -d '\r'
}

# Alacritty's `general.import` resolves relative paths (e.g.
# ".alacritty.base.toml") relative to the directory the config file is
# *found* in - if the config is a symlink, that means the symlink's own
# directory, not the repo directory it points to. So instead of symlinking
# the per-platform alacritty files into $HOME, we copy them and rewrite their
# relative imports to absolute paths pointing back into the repo. This keeps
# the in-repo files simple (plain relative imports) for direct use by
# application-shortcuts.v2.ahk, while still working once copied elsewhere.
#
# The Alacritty binary that reads these imports differs by environment:
#   - WSL: the Linux `alacritty` binary, which understands POSIX paths
#     like /mnt/c/Users/... (what $REPO_DIR already looks like under WSL).
#   - Git Bash / native Windows: the Windows Alacritty.exe, which cannot
#     parse MSYS-style paths like /c/Users/...; it needs a Windows-native
#     path such as C:/Users/.... `cygpath -m` performs that conversion.
render_alacritty_config() {
    local src="$1"
    local dest="$2"
    local dest_dir import_repo_dir
    dest_dir="$(dirname "$dest")"

    if is_wsl; then
        import_repo_dir="$REPO_DIR"
    else
        import_repo_dir="$(cygpath -m "$REPO_DIR")"
    fi

    if [ ! -d "$dest_dir" ]; then
        echo "Creating directory $dest_dir"
        mkdir -p "$dest_dir"
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    echo "Rendering $src to $dest"
    if is_wsl; then
        sed "s#\"\.alacritty#\"$import_repo_dir/.alacritty#g" "$src" > "$dest"
    else
        # .alacritty.git-bash.toml hardcodes a placeholder bash.exe path
        # ("C:/Program Files/Git/bin/bash.exe") that only matches a default
        # Git-for-Windows install. Git Bash is commonly installed elsewhere
        # (e.g. AppData\Local\Programs\Git, a portable install, etc.), so
        # replace it with the bash.exe actually running this script.
        local bash_path
        bash_path="$(cygpath -m "$(command -v bash)")"
        sed -e "s#\"\.alacritty#\"$import_repo_dir/.alacritty#g" \
            -e "s#^program = \"C:/Program Files/Git/bin/bash.exe\"#program = \"$bash_path\"#" \
            "$src" > "$dest"
    fi
}

# Detect whether this script is running inside WSL (vs. Git Bash on native Windows)
is_wsl() {
    grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null
}

# Repoint the Start Menu "Git Bash" shortcut at Alacritty (native Windows /
# Git Bash only - there's no equivalent shortcut to touch from WSL) so that
# opening "Git Bash" from the Start Menu/search launches bash inside
# Alacritty instead of the default mintty-based git-bash.exe window.
update_git_bash_shortcut() {
    local shortcut="$HOME/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Git/Git Bash.lnk"
    local alacritty_exe="$HOME/Applications/Alacritty.exe"

    if [ ! -f "$shortcut" ]; then
        echo "Git Bash Start Menu shortcut not found at $shortcut, skipping"
        return
    fi

    if [ ! -f "$alacritty_exe" ]; then
        echo "Alacritty not found at $alacritty_exe, skipping Git Bash shortcut update"
        return
    fi

    echo "Backing up existing $shortcut to ${shortcut}.bak"
    cp -f "$shortcut" "${shortcut}.bak"

    local shortcut_win alacritty_win config_win ps_script
    shortcut_win="$(cygpath -w "$shortcut")"
    alacritty_win="$(cygpath -w "$alacritty_exe")"
    config_win="$(cygpath -w "$HOME/.alacritty.toml")"
    ps_script="$(mktemp --suffix=.ps1)"

    cat > "$ps_script" <<EOF
\$sh = New-Object -ComObject WScript.Shell
\$lnk = \$sh.CreateShortcut('$shortcut_win')
\$lnk.TargetPath = '$alacritty_win'
\$lnk.Arguments = '--config-file "$config_win"'
\$lnk.Save()
EOF

    echo "Repointing Git Bash Start Menu shortcut at Alacritty"
    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$(cygpath -w "$ps_script")"
    rm -f "$ps_script"
}

# 1. Install .bashrc
render_bashrc "$REPO_DIR/.bashrc" "$HOME/.bashrc"

# 2. Install .inputrc
backup_and_link "$REPO_DIR/.inputrc" "$HOME/.inputrc"

# 3. Install oh-my-bash
if [ ! -d "$HOME/.oh-my-bash" ]; then
    echo "Installing oh-my-bash..."
    git clone https://github.com/ohmybash/oh-my-bash.git "$HOME/.oh-my-bash"
else
    echo "oh-my-bash is already installed at $HOME/.oh-my-bash"
fi

# 4. Install alacritty configs
#    - .alacritty.base.toml / .alacritty.shell-bindings.toml are shared
#      settings imported by the platform-specific files below; they are not
#      installed directly.
#    - Run this script from Git Bash on native Windows to install the Git
#      Bash + PowerShell configs. Run it again from inside WSL (e.g.
#      `bash /mnt/c/Users/<you>/dotfiles-windows/INSTALL.sh`) to also install
#      the WSL config into the Linux side's $HOME.
if is_wsl; then
    echo "Detected WSL environment"
    # .alacritty.wsl.toml goes in $HOME/.alacritty.toml for `alacritty -c ~/.alacritty.toml`
    render_alacritty_config "$REPO_DIR/.alacritty.wsl.toml" "$HOME/.alacritty.toml"
else
    echo "Detected Git Bash / native Windows environment"
    # .alacritty.git-bash.toml goes in $HOME/.alacritty.toml for Git Bash
    render_alacritty_config "$REPO_DIR/.alacritty.git-bash.toml" "$HOME/.alacritty.toml"
    # .alacritty.ps.toml goes in ~/.config/alacritty/ for Windows PowerShell
    render_alacritty_config "$REPO_DIR/.alacritty.ps.toml" "$HOME/.config/alacritty/alacritty.ps.toml"
    # 5. Point the "Git Bash" Start Menu shortcut at Alacritty
    update_git_bash_shortcut
    # 6. Install the PowerShell profile (bashmarks + vi-mode PSReadLine config)
    ensure_ps_readline
    render_ps_profile "$REPO_DIR/profile.ps1"
fi

echo ""
echo "Configuration files installed successfully!"
echo ""
echo "For AutoHotkey scripts (*.ahk), please see README.md for startup instructions."