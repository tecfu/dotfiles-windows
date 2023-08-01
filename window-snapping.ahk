; Snap window to top left quarter of screen (CTRL+ALT+U)
^!u::
  WinGet, activeWindow, ID, A
  SysGet, monitorWidth, 0
  SysGet, monitorHeight, 1
  WinMove, ahk_id %activeWindow%, , 0, 0, %monitorWidth//2, %monitorHeight//2
return

; Snap window to bottom left quarter of screen (CTRL+ALT+N)
^!n::
  WinGet, activeWindow, ID, A
  SysGet, monitorWidth, 0
  SysGet, monitorHeight, 1
  WinMove, ahk_id %activeWindow%, , 0, %monitorHeight//2, %monitorWidth//2, %monitorHeight//2
return

; Snap window to left half of screen (CTRL+ALT+J)
^!j::
  WinGet, activeWindow, ID, A
  SysGet, monitorWidth, 0
  WinMove, ahk_id %activeWindow%, , 0, 0, %monitorWidth//2, A_ScreenHeight
return

; Snap window to top right quarter of screen (CTRL+ALT+O)
^!o::
  WinGet, activeWindow, ID, A
  SysGet, monitorWidth, 0
  SysGet, monitorHeight, 1
  WinMove, ahk_id %activeWindow%, , %monitorWidth//2, 0, %monitorWidth//2, %monitorHeight//2
return

; Snap window to bottom right quarter of screen (CTRL+ALT+.)
^!.::
  WinGet, activeWindow, ID, A
  SysGet, monitorWidth, 0
  SysGet, monitorHeight, 1
  WinMove, ahk_id %activeWindow%, , %monitorWidth//2, %monitorHeight//2, %monitorWidth//2, %monitorHeight//2
return

; Snap window to right half of screen (CTRL+ALT+L)
^!l::
  WinGet, activeWindow, ID, A
  SysGet, monitorWidth, 0
  WinMove, ahk_id %activeWindow%, , %monitorWidth//2, 0, %monitorWidth//2, A_ScreenHeight
return
