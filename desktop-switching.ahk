; AutoHotkey script to remap virtual desktop switching in Windows 11/10
; Original: Ctrl+Win+Left/Right
; Desired:  Ctrl+Alt+Left/Right

; Use Ctrl + Alt + Right Arrow to switch to the next virtual desktop
^!Right::
  Send, ^#{Right}  ; Send Ctrl+Win+Right
Return

; Use Ctrl + Alt + Left Arrow to switch to the previous virtual desktop
^!Left::
  Send, ^#{Left}   ; Send Ctrl+Win+Left
Return
