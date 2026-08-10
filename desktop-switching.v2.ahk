#SingleInstance Force
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
SetKeyDelay 30, 30 ; Add a small delay, might help with reliability

; === Virtual Desktop Switching (Keep your original mapping) ===
; Use Ctrl + Alt + Right Arrow to switch to the next virtual desktop
^!Right:: {
    Send "^#{Right}"  ; Send Ctrl+Win+Right
}

; Use Ctrl + Alt + Left Arrow to switch to the previous virtual desktop
^!Left:: {
    Send "^#{Left}"   ; Send Ctrl+Win+Left
}

; Use Ctrl + Shift + Left Arrow to move the active window to the previous virtual desktop
^+Left:: { ; Ctrl + Shift + Left
    title := WinGetTitle("A")
    WinSetExStyle("^0x80", title)
    Send "{LWin down}{Ctrl down}{Left}{Ctrl up}{LWin up}"
    Sleep 50
    WinSetExStyle("^0x80", title)
    WinActivate title
}

; Use Ctrl + Shift + Right Arrow to move the active window to the next virtual desktop
^+Right:: { ; Ctrl + Shift + Right
    title := WinGetTitle("A")
    WinSetExStyle("^0x80", title)
    Send "{LWin down}{Ctrl down}{Right}{Ctrl up}{LWin up}"
    Sleep 50
    WinSetExStyle("^0x80", title)
    WinActivate title
}
