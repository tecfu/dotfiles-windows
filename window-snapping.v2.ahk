; AutoHotkey v2 Script for Window Tiling and Maximize
#Warn  ; Enable warnings for potential issues

; Snap window to the top left quarter of the screen
^!u::
{
  WinRestore("A")  ; Restore window if maximized/minimized before moving
  MonitorWorkArea := GetMonitorWorkArea()
  WorkWidth := MonitorWorkArea.Right - MonitorWorkArea.Left
  WorkHeight := MonitorWorkArea.Bottom - MonitorWorkArea.Top
  WinMove(MonitorWorkArea.Left, MonitorWorkArea.Top, WorkWidth / 2, WorkHeight / 2, "A")
}

; Snap window to the bottom left quarter of the screen
^!n::
{
  WinRestore("A")  ; Restore window if maximized/minimized before moving
  MonitorWorkArea := GetMonitorWorkArea()
  WorkWidth := MonitorWorkArea.Right - MonitorWorkArea.Left
  WorkHeight := MonitorWorkArea.Bottom - MonitorWorkArea.Top
  WinMove(MonitorWorkArea.Left, MonitorWorkArea.Top + WorkHeight / 2, WorkWidth / 2, WorkHeight / 2, "A")
}

; Snap window to the left half of the screen
^!j::
{
  WinRestore("A")  ; Restore window if maximized/minimized before moving
  MonitorWorkArea := GetMonitorWorkArea()
  WorkWidth := MonitorWorkArea.Right - MonitorWorkArea.Left
  WorkHeight := MonitorWorkArea.Bottom - MonitorWorkArea.Top
  WinMove(MonitorWorkArea.Left, MonitorWorkArea.Top, WorkWidth / 2, WorkHeight, "A")
}

; Snap window to the top right quarter of the screen
^!o::
{
  WinRestore("A")  ; Restore window if maximized/minimized before moving
  MonitorWorkArea := GetMonitorWorkArea()
  WorkWidth := MonitorWorkArea.Right - MonitorWorkArea.Left
  WorkHeight := MonitorWorkArea.Bottom - MonitorWorkArea.Top
  WinMove(MonitorWorkArea.Left + WorkWidth / 2, MonitorWorkArea.Top, WorkWidth / 2, WorkHeight / 2, "A")
}

; Snap window to the bottom right quarter of the screen
^!.::
{
  WinRestore("A")  ; Restore window if maximized/minimized before moving
  MonitorWorkArea := GetMonitorWorkArea()
  WorkWidth := MonitorWorkArea.Right - MonitorWorkArea.Left
  WorkHeight := MonitorWorkArea.Bottom - MonitorWorkArea.Top
  WinMove(MonitorWorkArea.Left + WorkWidth / 2, MonitorWorkArea.Top + WorkHeight / 2, WorkWidth / 2, WorkHeight / 2, "A")
}

; Snap window to the right half of the screen
^!l::
{
  WinRestore("A")  ; Restore window if maximized/minimized before moving
  MonitorWorkArea := GetMonitorWorkArea()
  WorkWidth := MonitorWorkArea.Right - MonitorWorkArea.Left
  WorkHeight := MonitorWorkArea.Bottom - MonitorWorkArea.Top
  WinMove(MonitorWorkArea.Left + WorkWidth / 2, MonitorWorkArea.Top, WorkWidth / 2, WorkHeight, "A")
}

; Maximize the currently focused window with CTRL+ALT+M
^!m::
{
  WinMaximize("A")
}

; Helper function to get monitor work area
GetMonitorWorkArea()
{
  MonitorWorkArea := {}
  MonitorGet(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
  MonitorGetWorkArea(MonitorGetPrimary(), &WorkLeft, &WorkTop, &WorkRight, &WorkBottom)
  MonitorWorkArea.Left := WorkLeft
  MonitorWorkArea.Top := WorkTop
  MonitorWorkArea.Right := WorkRight  
  MonitorWorkArea.Bottom := WorkBottom
  Return MonitorWorkArea
}

; === Explanation ===
; ^ = Ctrl key modifier
; ! = Alt key modifier
; # = Win key modifier
; A = Active Window identifier
; WinRestore("A") = Restores the active window if it's maximized or minimized
; GetMonitorWorkArea() = Helper function that returns usable screen dimensions
; WorkWidth/WorkHeight = Calculated usable width/height
; WinMove(X, Y, Width, Height, WinTitle) = Moves/Resizes a window
; WinMaximize(WinTitle) = Maximizes a window (respects work area)
; / = Division (v2 uses real division, not integer division)
