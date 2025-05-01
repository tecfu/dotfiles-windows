; AutoHotkey Script for Window Tiling and Maximize
; Fix: Adds WinRestore before WinMove to handle previously maximized windows.

; Snap window to the top left quarter of the screen
^!u::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  WinMove, A, , 0, 0, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the bottom left quarter of the screen
^!n::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  WinMove, A, , 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the left half of the screen
^!j::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  WinMove, A, , 0, 0, A_ScreenWidth//2, A_ScreenHeight
return

; Snap window to the top right quarter of the screen
^!o::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  WinMove, A, , A_ScreenWidth//2, 0, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the bottom right quarter of the screen
^!.::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  WinMove, A, , A_ScreenWidth//2, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the right half of the screen
^!l::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  WinMove, A, , A_ScreenWidth//2, 0, A_ScreenWidth//2, A_ScreenHeight
return

; Maximize the currently focused window with CTRL+ALT+M
^!m::
  WinMaximize, A
return

; === Explanation ===
; ^ = Ctrl key modifier
; ! = Alt key modifier
; # = Win key modifier (not used here, but useful to know)
; A = Active Window identifier
; WinRestore, A = Restores the active window if it's maximized or minimized
; WinMove, WinTitle, WinText, X, Y, Width, Height = Moves/Resizes a window
; WinMaximize, WinTitle = Maximizes a window
; A_ScreenWidth / A_ScreenHeight = Built-in variables for screen dimensions
; // = Integer division (ensures whole pixel values)
; Return = Ends a multi-line hotkey definition
