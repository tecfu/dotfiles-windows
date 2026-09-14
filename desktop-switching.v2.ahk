#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
SetKeyDelay 30, 30 ; Add a small delay, might help with reliability

; Switch virtual desktops without moving the focused window.
^!Left::Send "^#{Left}"
^!Right::Send "^#{Right}"

; Move the focused window and follow it to the adjacent virtual desktop.
^+Left::MoveActiveWindowToDesktop(3)
^+Right::MoveActiveWindowToDesktop(4)

MoveActiveWindowToDesktop(direction) {
    Critical
    hwnd := WinGetID("A")

    ; Windows 11 24H2/25H2 shell interfaces: move the application view, not its styles.
    shell := ComObject("{C2F03A33-21F5-47FA-B4BB-156362A2F239}",
        "{6D5140C1-7436-11CE-8034-00AA006009FA}")
    desktops := ComObjQuery(shell, "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}",
        "{53F5CA0B-158F-4124-900C-057158060B27}")
    views := ComObjQuery(shell, "{1841C6D7-4F9D-42C0-AF41-8747538F10E5}",
        "{1841C6D7-4F9D-42C0-AF41-8747538F10E5}")

    current := target := view := 0
    try {
        ComCall(6, desktops, "Ptr*", &current) ; GetCurrentDesktop
        result := ComCall(8, desktops, "Ptr", current, "Int", direction, "Ptr*", &target, "UInt")
        if result = 0x80028CA1 ; No adjacent desktop at this edge (TYPE_E_OUTOFBOUNDS).
            return
        if result != 0
            throw OSError(result, , "GetAdjacentDesktop")
        ComCall(6, views, "Ptr", hwnd, "Ptr*", &view) ; GetViewForHwnd
        ComCall(4, desktops, "Ptr", view, "Ptr", target) ; MoveViewToDesktop
        ComCall(9, desktops, "Ptr", target) ; SwitchDesktop
        WinActivate hwnd
        if !WinWaitActive(hwnd, , 2)
            throw Error("The window moved, but could not be focused.")
    } finally {
        for pointer in [view, target, current] {
            if pointer
                ObjRelease(pointer)
        }
    }
}
