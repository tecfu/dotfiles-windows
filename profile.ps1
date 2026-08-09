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

# ==========================================
# PSReadLine Vi Mode Configuration
# ==========================================

# 1. Enable Vi Mode
Set-PSReadLineOption -EditMode Vi

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

# ==========================================
# 6. Key Mappings (Vi-Insert Mode)
# ==========================================

# History navigation
Set-PSReadLineKeyHandler -Chord 'UpArrow' -ViMode Insert -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord 'DownArrow' -ViMode Insert -Function HistorySearchForward

# Word navigation
Set-PSReadLineKeyHandler -Chord 'Ctrl+h' -ViMode Insert -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -ViMode Insert -Function ShellForwardWord

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
