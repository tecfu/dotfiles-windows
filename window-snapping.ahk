; Snap window to the top left quarter of the screen
^!u::
  WinGet, activeWindow, ID, A
  WinGet, winState, MinMax, ahk_id %activeWindow%
  if (winState = -1) {
    ; Window is maximized, so restore it to its previous state
    WinRestore, ahk_id %activeWindow%
  }
  WinMove, ahk_id %activeWindow%, , 0, 0, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the bottom left quarter of the screen
^!n::
  WinGet, activeWindow, ID, A
  WinGet, winState, MinMax, ahk_id %activeWindow%
  if (winState = -1) {
    ; Window is maximized, so restore it to its previous state
    WinRestore, ahk_id %activeWindow%
  }
  WinMove, ahk_id %activeWindow%, , 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the left half of the screen
^!j::
  WinGet, activeWindow, ID, A
  WinGet, winState, MinMax, ahk_id %activeWindow%
  if (winState = -1) {
    ; Window is maximized, so restore it to its previous state
    WinRestore, ahk_id %activeWindow%
  }
  WinMove, ahk_id %activeWindow%, , 0, 0, A_ScreenWidth//2, A_ScreenHeight
return

; Snap window to the top right quarter of the screen
^!o::
  WinGet, activeWindow, ID, A
  WinGet, winState, MinMax, ahk_id %activeWindow%
  if (winState = -1) {
    ; Window is maximized, so restore it to its previous state
    WinRestore, ahk_id %activeWindow%
  }
  WinMove, ahk_id %activeWindow%, , A_ScreenWidth//2, 0, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the bottom right quarter of the screen
^!.::
  WinGet, activeWindow, ID, A
  WinGet, winState, MinMax, ahk_id %activeWindow%
  if (winState = -1) {
    ; Window is maximized, so restore it to its previous state
    WinRestore, ahk_id %activeWindow%
  }
  WinMove, ahk_id %activeWindow%, , A_ScreenWidth//2, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight//2
return

; Snap window to the right half of the screen
^!l::
  WinGet, activeWindow, ID, A
  WinGet, winState, MinMax, ahk_id %activeWindow%
  if (winState = -1) {
    ; Window is maximized, so restore it to its previous state
    WinRestore, ahk_id %activeWindow%
  }
  WinMove, ahk_id %activeWindow%, , A_ScreenWidth//2, 0, A_ScreenWidth//2, A_ScreenHeight
return

; Maximize or restore the currently focused window with CTRL+ALT+M
^!m::
  WinGet, activeWindow, ID, A
  WinGet, winState, MinMax, ahk_id %activeWindow%
  if (winState = -1) {
    ; Window is maximized, so restore it to its previous state
    WinRestore, ahk_id %activeWindow%
  } else {
    ; Window is not maximized, so maximize it
    WinMaximize, ahk_id %activeWindow%
  }
return
