# $EDITOR/$VISUAL: used by bash vi-mode's "edit-and-execute-command" widget
# (the "v" key in vi Command mode, per .inputrc's `set editing-mode vi`) to
# open the current command line in an external editor - the WSL/bash
# counterpart to profile.ps1's PSReadLine "v" handler. Use WSL-native vim
# rather than the Windows nvim.exe (aliased below as `nvim`): nvim.exe
# lives under the Windows user's home, not WSL's $HOME, so it 404s here;
# vim is installed natively in the WSL distro.
export EDITOR="vim"
export VISUAL="$EDITOR"

# WSL auto-appends the full Windows PATH via interop, including several
# /mnt/c/... directories. Those live on the 9p network filesystem and are
# extremely slow to stat/list (~600ms+ vs ~2ms for native ext4 dirs), which
# can stall bash's own command-name Tab completion for hundreds of ms per
# keystroke. Strip /mnt/* entries from PATH here (WSL only; harmless
# elsewhere since the pattern won't match). This means Windows .exe files
# (e.g. notepad.exe) can no longer be run by bare name - use their full
# /mnt/c/... path, or an alias (see the nvim/alacritty aliases below), if
# needed.
if [[ -n ${WSL_DISTRO_NAME-} ]]; then
    _clean_path=
    IFS=: read -ra _path_parts <<< "$PATH"
    for _p in "${_path_parts[@]}"; do
        [[ $_p == /mnt/* ]] && continue
        _clean_path+="${_clean_path:+:}$_p"
    done
    PATH=$_clean_path
    unset _clean_path _path_parts _p
    hash -r
fi

# Repo directory, baked in by INSTALL.sh at install time (see render_bashrc).
# This can't be resolved dynamically via BASH_SOURCE/readlink at runtime
# because `ln -s` silently falls back to a plain file copy (instead of
# failing) on Windows accounts without symlink privilege (Developer Mode
# off / non-elevated) - a copy has no way to point back to the repo.
_dotfiles_dir="__DOTFILES_REPO_DIR__"
source "$_dotfiles_dir/bashmarks.plugin.sh"
unset _dotfiles_dir

alias nvim="~/Applications/nvim-win64/bin/nvim.exe"

# Alacritty.exe is installed at ~/Applications/Alacritty.exe (see README.md)
# rather than a location on PATH, so alias it directly. --config-file must
# be explicit: without it, Alacritty falls back to its default config
# search path (e.g. %APPDATA%\alacritty\alacritty.toml) instead of the one
# INSTALL.sh renders to ~/.alacritty.toml, which can pick up a stale/unrelated config.
alias alacritty="~/Applications/Alacritty.exe --config-file ~/.alacritty.toml"
