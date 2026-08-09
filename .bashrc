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
