; AutoHotkey Script for Window Tiling and Maximize
; Fix: Adds WinRestore before WinMove to handle previously maximized windows.
; Fix: Uses MonitorWorkArea to account for the taskbar height/position.

#NoEnv  ; Recommended for performance and compatibility with future v2 scripts.
#Warn   ; Recommended for catching common errors.
SendMode Input  ; Recommended for speed and reliability.

; Snap window to the top left quarter of the screen
^!u::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  SysGet, MonitorWorkArea, MonitorWorkArea ; Get usable screen dimensions (excluding taskbar)
  WorkWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
  WorkHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
  WinMove, A, , MonitorWorkAreaLeft, MonitorWorkAreaTop, WorkWidth // 2, WorkHeight // 2
return

; Snap window to the bottom left quarter of the screen
^!n::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  SysGet, MonitorWorkArea, MonitorWorkArea
  WorkWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
  WorkHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
  WinMove, A, , MonitorWorkAreaLeft, MonitorWorkAreaTop + WorkHeight // 2, WorkWidth // 2, WorkHeight // 2
return

; Snap window to the left half of the screen
^!j::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  SysGet, MonitorWorkArea, MonitorWorkArea
  WorkWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
  WorkHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
  WinMove, A, , MonitorWorkAreaLeft, MonitorWorkAreaTop, WorkWidth // 2, WorkHeight
return

; Snap window to the top right quarter of the screen
^!o::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  SysGet, MonitorWorkArea, MonitorWorkArea
  WorkWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
  WorkHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
  WinMove, A, , MonitorWorkAreaLeft + WorkWidth // 2, MonitorWorkAreaTop, WorkWidth // 2, WorkHeight // 2
return

; Snap window to the bottom right quarter of the screen
^!.::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  SysGet, MonitorWorkArea, MonitorWorkArea
  WorkWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
  WorkHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
  WinMove, A, , MonitorWorkAreaLeft + WorkWidth // 2, MonitorWorkAreaTop + WorkHeight // 2, WorkWidth // 2, WorkHeight // 2
return

; Snap window to the right half of the screen
^!l::
  WinRestore, A  ; Restore window if maximized/minimized before moving
  SysGet, MonitorWorkArea, MonitorWorkArea
  WorkWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
  WorkHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
  WinMove, A, , MonitorWorkAreaLeft + WorkWidth // 2, MonitorWorkAreaTop, WorkWidth // 2, WorkHeight
return

; Maximize the currently focused window with CTRL+ALT+M
^!m::
  ; Maximize respects the work area by default, so no change needed here
  WinMaximize, A
return

; === Explanation ===
; ^ = Ctrl key modifier
; ! = Alt key modifier
; # = Win key modifier
; A = Active Window identifier
; WinRestore, A = Restores the active window if it's maximized or minimized
; SysGet, MonitorWorkArea, MonitorWorkArea = Gets usable screen rect into MonitorWorkAreaLeft/Top/Right/Bottom
; WorkWidth/WorkHeight = Calculated usable width/height
; WinMove, WinTitle, WinText, X, Y, Width, Height = Moves/Resizes a window
; WinMaximize, WinTitle = Maximizes a window (respects work area)
; // = Integer division
; Return = Ends a multi-line hotkey definition
