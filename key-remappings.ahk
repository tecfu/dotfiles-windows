#NoEnv  ; Recommended for performance and compatibility.
#Warn   ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

;-----------------------------------------
; CapsLock <-> Escape Swap
;-----------------------------------------
$Capslock::Esc
$Esc::
    if GetKeyState("CapsLock", "T")
        SetCapsLockState, Off
    else
        SetCapsLockState, On
Return


;-----------------------------------------
; Map Ctrl+Q to close the ACTIVE window
;-----------------------------------------
^q::
    WinClose, A ; 'A' refers to the active window
Return


;-----------------------------------------
; Map Ctrl+Shift+4 to Win+Shift+S
; (Often used to trigger Windows Snipping Tool with an alternative shortcut)
;-----------------------------------------
$^+4:: ; Use $ to prevent self-triggering if Send involves the hotkey's own modifiers
    Send, #+s
Return
