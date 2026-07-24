# ==========================================
# PSReadLine Vi Mode Configuration
# ==========================================

# 1. Enable Vi Mode
Set-PSReadLineOption -EditMode Vi

# 2. Configure the Mode Indicator to use a Script
# This is required to use ViModeChangeHandler
Set-PSReadLineOption -ViModeIndicator Script

# 3. Define the Handler Function
function OnViModeChange {
    param($Mode)
    
    # Using [char]27 for compatibility across PS 5.1 and PS 7
    if ($Mode -eq 'Command') {
        [Console]::Write("$([char]27)[2 q") # Block cursor
    } else {
        [Console]::Write("$([char]27)[6 q") # Bar cursor
    }
}

# 4. Attach the Handler
Set-PSReadLineOption -ViModeChangeHandler $Function:OnViModeChange

# 5. Key Mappings (Vi-Command Mode)

# To unbind Spacebar correctly, use an empty ScriptBlock
Set-PSReadLineKeyHandler -Chord 'Spacebar' -ViMode Command -ScriptBlock { }

# Multi-chord mappings (Spacebar as leader)
Set-PSReadLineKeyHandler -Chord 'Spacebar,a' -ViMode Command -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord 'Spacebar,;' -ViMode Command -Function EndOfLine

# 6. Key Mappings (Vi-Insert Mode)
Set-PSReadLineKeyHandler -Chord 'UpArrow' -ViMode Insert -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord 'DownArrow' -ViMode Insert -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord 'Ctrl+h' -ViMode Insert -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -ViMode Insert -Function ShellForwardWord
