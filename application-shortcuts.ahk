; AutoHotkey script to open a new Git Bash window with Ctrl+Alt+T

; Define the hotkey: ^ = Ctrl, ! = Alt, t = T key
^!t::
    ; Specify the full path to git-bash.exe
    ; IMPORTANT: Verify this path matches your actual Git installation directory!
    gitBashPath := "C:\Program Files\Git\git-bash.exe"

    ; Check if the file exists before trying to run it (optional but good practice)
    If FileExist(gitBashPath)
    {
        ; Run the Git Bash executable
        Run, %gitBashPath%
    }
    Else
    {
        ; Display an error message if the path is wrong
        MsgBox, Git Bash executable not found at:`n%gitBashPath%`nPlease check the path in the AutoHotkey script.
    }
Return

; === Explanation ===
; ^ = Ctrl key modifier
; ! = Alt key modifier
; t = T key
; :: = Hotkey definition separator
; := = Variable assignment (used for clarity, could put path directly in Run)
; If FileExist(path) = Checks if the specified file exists
; Run, Target = Command to launch an executable or file
; %variable% = Dereferences the variable to use its content
; MsgBox, Text = Displays a simple message box
; Return = Ends the hotkey definition

; Remap Caps Lock to Escape and Escape to Caps Lock

; Make the physical Caps Lock key send an Escape keystroke.
; This overrides its default toggling behavior.
CapsLock::Send {Esc}

; Make the physical Escape key toggle the actual Caps Lock state (On/Off).
; This overrides Escape's default behavior.
Esc::SetCapsLockState, Toggle

Return ; Good practice to end hotkey sections, though often implicit here
