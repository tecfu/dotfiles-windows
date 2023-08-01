; Snap window to the top left quarter of the screen
^!u::
  WinMove, A, , 0, 0, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the bottom left quarter of the screen
^!n::
  WinMove, A, , 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the left half of the screen
^!j::
  WinMove, A, , 0, 0, A_ScreenWidth//2, A_ScreenHeight
return

; Snap window to the top right quarter of the screen
^!o::
  WinMove, A, , A_ScreenWidth//2, 0, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the bottom right quarter of the screen
^!.::
  WinMove, A, , A_ScreenWidth//2, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the right half of the screen
^!l::
  WinMove, A, , A_ScreenWidth//2, 0, A_ScreenWidth//2, A_ScreenHeight
return

; Maximize the currently focused window with CTRL+ALT+M
^!m::
  WinMaximize, A
return
