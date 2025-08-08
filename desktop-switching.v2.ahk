#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; SendMode Input ; Let's use SendEvent or SendPlay if Input fails with complex sequences
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 30, 30 ; Add a small delay, might help with reliability

; === Virtual Desktop Switching (Keep your original mapping) ===
; Use Ctrl + Alt + Right Arrow to switch to the next virtual desktop
^!Right::
  Send, ^#{Right}  ; Send Ctrl+Win+Right
Return

; Use Ctrl + Alt + Left Arrow to switch to the previous virtual desktop
^!Left::
  Send, ^#{Left}   ; Send Ctrl+Win+Left
Return

; Use Ctrl + Shift + Left Arrow to move the active window to the previous virtual desktop
^+Left:: ; Ctrl + Shift + Left
  WinGetTitle, Title, A
  WinSet, ExStyle, ^0x80, %Title%
  Send {LWin down}{Ctrl down}{Left}{Ctrl up}{LWin up}
  sleep, 50
  WinSet, ExStyle, ^0x80, %Title%
  WinActivate, %Title%
Return

; Use Ctrl + Shift + Right Arrow to move the active window to the next virtual desktop
^+Right:: ; Ctrl + Shift + Right
  WinGetTitle, Title, A
  WinSet, ExStyle, ^0x80, %Title%
  Send {LWin down}{Ctrl down}{Right}{Ctrl up}{LWin up}
  sleep, 50
  WinSet, ExStyle, ^0x80, %Title%
  WinActivate, %Title%
Return
