# ==========================================
# Bashmarks
# ==========================================

# Repo directory, baked in by INSTALL.sh at install time (see
# render_ps_profile), the same way .bashrc bakes in its repo path - this
# profile is rendered to a copy under $PROFILE, not run in place, so it
# can't rely on $PSScriptRoot to find bashmarks.plugin.ps1.
$_dotfilesDir = "__DOTFILES_REPO_DIR__"
. "$_dotfilesDir/bashmarks.plugin.ps1"
Remove-Variable _dotfilesDir

# ==========================================
# Neovim Setup
# ==========================================

# Tell Neovim to source this specific config file during normal initialization
# (This avoids the '-u' flag bug which skips loading plugins and syntax)
$env:VIMINIT = 'source ~/.vim/init.vim'

# Alias 'nvim' directly to the executable
Set-Alias -Name nvim -Value "$HOME\Applications\nvim-win64\bin\nvim.exe"

# Alias 'vim' to the same neovim executable (no vim binary on Windows)
Set-Alias -Name vim -Value "$HOME\Applications\nvim-win64\bin\nvim.exe"

# Used by PSReadLine's ViEditVisually (the 'v' key in vi command mode) to
# know which editor to launch on the current command line.
$env:VISUAL = "$HOME\Applications\nvim-win64\bin\nvim.exe"
$env:EDITOR = $env:VISUAL

# ==========================================
# PSReadLine Vi Mode Configuration
# ==========================================

# ViEditVisually (needed for the 'v' key handler below) requires PSReadLine
# 2.2+; the version bundled with Windows PowerShell 5.1 is 2.0.0 and hangs
# the terminal when an interactive console app is launched from a key
# handler. Load the newer module explicitly (installed via
# `Install-Module PSReadLine -Scope CurrentUser`).
Import-Module PSReadLine -MinimumVersion 2.2.0 -Force -ErrorAction SilentlyContinue

# 1. Enable Vi Mode
Set-PSReadLineOption -EditMode Vi

# 1a. Predictive IntelliSense: inline "ghost text" suggestions from history.
# Wrapped in try/catch since hosts without VT support (e.g. redirected
# output, some remoting sessions) throw when enabling this.
try {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
} catch {}

# 2. Configure the Mode Indicator to use a Script
Set-PSReadLineOption -ViModeIndicator Script

# 3. Define the Cursor Shape Handler Function
function OnViModeChange {
    param($Mode)
    
    if ($Mode -eq 'Command') {
        [Console]::Write("$([char]27)[2 q") # Block cursor
    } else {
        [Console]::Write("$([char]27)[6 q") # Steady bar cursor
    }
}

# 4. Attach the Handler
Set-PSReadLineOption -ViModeChangeHandler $Function:OnViModeChange

# ==========================================
# 5. Key Mappings (Vi-Command Mode)
# ==========================================

# Unbind Spacebar so it can act as a clean leader key
Set-PSReadLineKeyHandler -Chord 'Spacebar' -ViMode Command -ScriptBlock { }

# --- Custom Motions ---
# Jump to beginning of line (Space + a)
Set-PSReadLineKeyHandler -Chord 'Spacebar,a' -ViMode Command -Function BeginningOfLine
# Jump to end of line (Space + ;)
Set-PSReadLineKeyHandler -Chord 'Spacebar,;' -ViMode Command -Function EndOfLine

# --- Composed Delete ('d') Operations ---
# We bind the 2-key chord 'd,Spacebar' and manually wait for the 3rd key
Set-PSReadLineKeyHandler -Chord 'd,Spacebar' -ViMode Command -ScriptBlock {
    # Read the 3rd keystroke silently
    $key = [System.Console]::ReadKey($true)
    
    if ($key.KeyChar -eq ';') {
        [Microsoft.PowerShell.PSConsoleReadLine]::KillLine()
    } elseif ($key.KeyChar -eq 'a') {
        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardKillLine()
    } else {
        # Beep if an invalid key was pressed
        [System.Console]::Beep()
    }
}

# --- Composed Change ('c') Operations ---
Set-PSReadLineKeyHandler -Chord 'c,Spacebar' -ViMode Command -ScriptBlock {
    $key = [System.Console]::ReadKey($true)
    
    if ($key.KeyChar -eq ';') {
        [Microsoft.PowerShell.PSConsoleReadLine]::KillLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::ViInsertMode()
    } elseif ($key.KeyChar -eq 'a') {
        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardKillLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::ViInsertMode()
    } else {
        [System.Console]::Beep()
    }
}

# --- Edit-and-execute-command (mirrors bash vi-mode 'v') ---
# Opens the current command line in $env:VISUAL/$env:EDITOR (nvim); on
# save+quit, the edited line replaces the buffer, matching bash's 'v' in
# vi command mode. Requires PSReadLine 2.2+ (see Import-Module above) -
# on 2.0.0 this hangs the terminal because it can't hand off the console
# to an interactive child process from within a key handler.
Set-PSReadLineKeyHandler -Chord 'v' -ViMode Command -Function ViEditVisually

# ==========================================
# 6. Key Mappings (Vi-Insert Mode)
# ==========================================

# History navigation
Set-PSReadLineKeyHandler -Chord 'UpArrow' -ViMode Insert -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord 'DownArrow' -ViMode Insert -Function HistorySearchForward

# Word navigation
Set-PSReadLineKeyHandler -Chord 'Ctrl+h' -ViMode Insert -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -ViMode Insert -Function ShellForwardWord

# Tab: accept the inline predictive suggestion (ghost text) if one is
# showing; otherwise fall back to normal vi tab-completion. We detect
# "nothing to accept" by checking whether the buffer actually changed.
Set-PSReadLineKeyHandler -Chord 'Tab' -ViMode Insert -ScriptBlock {
    param($key, $arg)

    $lineBefore = $null; $cursorBefore = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$lineBefore, [ref]$cursorBefore)

    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion($key, $arg)

    $lineAfter = $null; $cursorAfter = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$lineAfter, [ref]$cursorAfter)

    if ($lineAfter -eq $lineBefore -and $cursorAfter -eq $cursorBefore) {
        [Microsoft.PowerShell.PSConsoleReadLine]::ViTabCompleteNext($key, $arg)
    }
}

# ==========================================
# 7. Terminal Reset (Alt+K)
# ==========================================

# Alacritty used to send a raw Ctrl+L char for Alt+K, relying on PSReadLine's
# default Ctrl+L->ClearScreen binding - but Ctrl+l is rebound to
# ShellForwardWord in Vi Insert mode above, which silently broke that trick.
# Bind Alt+K directly instead, and do a real terminal reset (matching the
# bash Alt+K binding, which runs `echo -e "\033c"`) rather than just
# PSReadLine's ClearScreen, which only clears the screen/scrollback and
# doesn't reset terminal modes left in a bad state (e.g. after cat-ing
# binary data). "\033c" is the ANSI RIS (Reset to Initial State) sequence.
# Requires Alacritty to forward Alt+K as a normal Alt/meta keypress instead
# of intercepting it (see .alacritty.ps.toml).
$resetTerminal = {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Console]::Out.Write("$([char]27)c")
}
Set-PSReadLineKeyHandler -Chord 'Alt+k' -ViMode Insert -ScriptBlock $resetTerminal
Set-PSReadLineKeyHandler -Chord 'Alt+k' -ViMode Command -ScriptBlock $resetTerminal

# ==========================================
# Reload Path
# ==========================================
# Refresh $env:Path from the registry (Machine + User) without restarting
# the shell - useful after installing something that updates PATH.
function Reload-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
}
