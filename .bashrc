# $EDITOR/$VISUAL: used by ble.sh's vi-mode "edit-and-execute-command"
# widget (see the `v` rebinding below) to open the current command line in
# an external editor - the WSL/bash counterpart to profile.ps1's PSReadLine
# "v" handler. Use WSL-native vim rather than the Windows nvim.exe (aliased
# below as `nvim`): nvim.exe lives under the Windows user's home, not
# WSL's $HOME, so it 404s here; vim is installed natively in the WSL distro.
export EDITOR="vim"
export VISUAL="$EDITOR"

# WSL auto-appends the full Windows PATH via interop, including several
# /mnt/c/... directories. Those live on the 9p network filesystem and are
# extremely slow to stat/list (~600ms+ vs ~2ms for native ext4 dirs), and
# ble.sh's command-name completion scans every PATH directory on virtually
# every keystroke - so with Windows dirs in PATH, typing anything that
# triggers completion (e.g. `cd ./something<TAB>`, or even just ble.sh's
# background auto-complete idle pass) could stall for hundreds of ms per
# keystroke. Strip /mnt/* entries from PATH here (WSL only; harmless
# elsewhere since the pattern won't match) before ble.sh loads. This means
# Windows .exe files (e.g. notepad.exe) can no longer be run by bare name -
# use their full /mnt/c/... path, or an alias (see the nvim/alacritty
# aliases below), if needed.
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

# ble.sh: gives Bash inline "ghost text" suggestions from history plus
# syntax highlighting, while preserving vi keybindings - the bash/WSL
# counterpart to the PSReadLine predictive IntelliSense + vi-mode setup in
# profile.ps1. Installed by INSTALL.sh's ensure_ble_sh() (WSL only, since
# it needs `make`; Git Bash on native Windows skips it and this just no-ops
# there). Per ble.sh's own setup instructions, it must be sourced as close
# to the top of .bashrc as possible (with attach deferred via
# --attach=none) so it can see the rest of .bashrc's customization (vi
# mode is picked up automatically from .inputrc's `set editing-mode vi`).
if [ -r "$HOME/.local/share/blesh/ble.sh" ]; then
    source "$HOME/.local/share/blesh/ble.sh" --attach=none

    # ble.sh only computes/shows the history-based ghost-text suggestion via
    # a background "idle" pass, so pressing TAB right after typing (with no
    # pause) usually finds no suggestion active yet - TAB then falls through
    # to ble.sh's normal menu-complete (candidates cycling below the line,
    # accepted with Enter). This widget forces that computation to happen
    # synchronously on the very first TAB press: if a suggestion is (or
    # becomes) available, TAB accepts it immediately; otherwise it falls
    # back to the existing menu-complete/Enter-to-submit behavior
    # unchanged. Mirrors the PSReadLine Tab handler in profile.ps1.
    function ble/widget/tab-accept-suggestion-or-complete {
        [[ $_ble_edit_mark_active == auto_complete ]] || ble/complete/auto-complete.impl sync
        if [[ $_ble_edit_mark_active == auto_complete ]]; then
            ble/widget/auto_complete/insert-on-end
        else
            ble/widget/vi_imap/complete "$@"
        fi
    }
    ble-bind -m vi_imap -f 'TAB' 'tab-accept-suggestion-or-complete'
    # The actual Tab keypress is decoded as 'C-i' (they're the same 0x09
    # byte) - ble.sh's default keymap binds both names separately to
    # 'vi_imap/complete', and rebinding only 'TAB' left the real keystroke
    # still hitting the original 'C-i' binding. Rebind both.
    ble-bind -m vi_imap -f 'C-i' 'tab-accept-suggestion-or-complete'

    # Also cover the case where the suggestion was already showing (e.g.
    # idle already ran) before TAB is pressed - in that state ble.sh has
    # switched the active keymap to `auto_complete`, which by default has
    # no TAB binding of its own (falls through to
    # `auto_complete/cancel-default`, silently discarding the suggestion).
    ble-bind -m auto_complete -f 'TAB' 'auto_complete/@end insert'

    # ESC should fully dismiss the completion UI (ghost text or the
    # below-line candidate menu) rather than accept it. Neither keymap
    # binds ESC/C-[ by default: `auto_complete` falls through to
    # `auto_complete/cancel-default` (discards the suggestion, but leaves
    # a stray menu clear undone), and `menu_complete` falls through to
    # `menu_complete/exit-default`, which *accepts* the currently
    # selected candidate. `ble/widget/menu_complete/cancel` alone
    # deselects but never calls `ble/complete/menu/clear`, so the
    # candidate box stayed visible below the line after ESC. Wrap both
    # cancel widgets so ESC always removes the whole completion UI
    # (ghost text + candidate box), leaving the cursor at the end of the
    # word as typed.
    function ble/widget/tab-complete/esc-clear {
        ble/complete/menu/clear
        ble/widget/auto_complete/cancel
    }
    function ble/widget/tab-complete/esc-clear-menu {
        ble/widget/menu_complete/cancel
        ble/complete/menu/clear
    }
    ble-bind -m menu_complete -f 'ESC'  'tab-complete/esc-clear-menu'
    ble-bind -m menu_complete -f 'C-[' 'tab-complete/esc-clear-menu'
    ble-bind -m auto_complete -f 'ESC'  'tab-complete/esc-clear'
    ble-bind -m auto_complete -f 'C-[' 'tab-complete/esc-clear'

    # By default ble.sh's vi-command keymap implements real vim behavior,
    # where "v" enters character-wise VISUAL (selection) mode - unlike
    # plain bash/readline vi mode, where "v" runs edit-and-execute-command
    # (opens $VISUAL/$EDITOR on the command line, then runs it on save).
    # Rebind "v" to that widget so it matches the "v" behavior configured
    # for PSReadLine's vi-mode in profile.ps1 instead of showing "VISUAL".
    ble-bind -m vi_nmap -f 'v' 'vi-command/edit-and-execute-command'
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

# Attach ble.sh last, after all other .bashrc customization above, per its
# own setup instructions.
[[ ${BLE_VERSION-} ]] && ble-attach
