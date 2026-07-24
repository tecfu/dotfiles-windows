# ==========================================
# PSReadLine Vi Mode Configuration (.inputrc mappings)
# ==========================================

# 1. Enable Vi Mode and show mode status in prompt
Set-PSReadLineOption -EditMode Vi

# 2. Dynamic Cursor Shape changing based on mode (Insert vs Command)
function OnViModeChange {
    if ($args[0] -eq 'Command') {
        Write-Host -NoNewline "`e[2 q" # Block cursor for Command mode
    } else {
        Write-Host -NoNewline "`e[6 q" # Steady Bar cursor for Insert mode
    }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange

# 3. Mappings for Vi-Command Mode
# Unbind Spacebar
Set-PSReadLineKeyHandler -Chord 'Spacebar' -ViMode Command -Function DigitArgument
# Jump to beginning of line (mapped from: 'Space a')
Set-PSReadLineKeyHandler -Chord 'Space,a' -ViMode Command -Function BeginningOfLine
# Jump to end of line (mapped from: 'Space ;')
Set-PSReadLineKeyHandler -Chord 'Space,;' -ViMode Command -Function EndOfLine

# 4. Mappings for Vi-Insert Mode
# History navigation via Up/Down arrow keys
Set-PSReadLineKeyHandler -Chord 'UpArrow' -ViMode Insert -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord 'DownArrow' -ViMode Insert -Function HistorySearchForward

# Jump left or right by one word via Ctrl+H and Ctrl+L
Set-PSReadLineKeyHandler -Chord 'Ctrl+h' -ViMode Insert -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -ViMode Insert -Function ShellForwardWord
