#NoEnv  ; Recommended for performance and compatibility.
#Warn   ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

;-----------------------------------------
; CapsLock <-> Escape Swap
;-----------------------------------------
; $ prefix prevents the hotkey triggering itself during Send/SetCapsLockState

; Make the physical Caps Lock key act like the Escape key.
$Capslock::Esc

; Make the physical Escape key toggle the actual Caps Lock state (On/Off).
$Esc::
    if GetKeyState("CapsLock", "T")
        SetCapsLockState, Off
    else
        SetCapsLockState, On
Return


;-----------------------------------------
; Map Win+M to open Outlook
;-----------------------------------------
#m::
    ; --- VERIFY THIS PATH! ---
    outlookPath := "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"

    If WinExist("ahk_exe OUTLOOK.EXE") && WinActive("ahk_exe OUTLOOK.EXE")
    {
        Return ; Already active, do nothing (or WinMinimize, A)
    }
    Else If WinExist("ahk_exe OUTLOOK.EXE")
    {
        WinActivate, ahk_exe OUTLOOK.EXE
    }
    Else If FileExist(outlookPath)
    {
        Run, %outlookPath%
    }
    Else
    {
        MsgBox, Outlook executable not found at:`n%outlookPath%`nPlease verify the path in the AutoHotkey script.
    }
Return


;-----------------------------------------
; Map Win+V to open Visual Studio Code
;-----------------------------------------
#v::
    ; --- VERIFY THIS PATH! ---
    ; Common locations:
    ; User Install: C:\Users\%UserName%\AppData\Local\Programs\Microsoft VS Code\Code.exe
    ; System Install: C:\Program Files\Microsoft VS Code\Code.exe
    vsCodePath := "C:\Users\" . A_UserName . "\AppData\Local\Programs\Microsoft VS Code\Code.exe" ; Using built-in variable

    If WinExist("ahk_exe Code.exe") && WinActive("ahk_exe Code.exe")
    {
        Return ; Already active
    }
    Else If WinExist("ahk_exe Code.exe")
    {
        WinActivate, ahk_exe Code.exe
    }
    Else If FileExist(vsCodePath)
    {
        Run, %vsCodePath%
    }
    Else ; Try checking the system install path as a fallback
    {
        vsCodePathSystem := "C:\Program Files\Microsoft VS Code\Code.exe"
        If FileExist(vsCodePathSystem)
        {
            Run, %vsCodePathSystem%
        }
        Else
        {
             MsgBox, Visual Studio Code executable not found at common locations:`n%vsCodePath%`nOR`n%vsCodePathSystem%`nPlease verify the path in the AutoHotkey script.
        }
    }
Return


;-----------------------------------------
; Map Win+C to open Google Chrome
;-----------------------------------------
#c::
    ; --- VERIFY THIS PATH! ---
    chromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe"
    ; Also check: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

    ; Note: Chrome often has multiple processes. Activating might bring up the last active window.
    If WinExist("ahk_exe chrome.exe")
    {
        WinActivate, ahk_exe chrome.exe
    }
    Else If FileExist(chromePath)
    {
        Run, %chromePath%
    }
    Else ; Check x86 path
    {
        chromePathX86 := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        If FileExist(chromePathX86)
        {
             Run, %chromePathX86%
        }
        Else
        {
            MsgBox, Google Chrome executable not found at common locations:`n%chromePath%`nOR`n%chromePathX86%`nPlease verify the path in the AutoHotkey script.
        }
    }
Return


;-----------------------------------------
; Map Win+D to open DBeaver
;-----------------------------------------
#d::
    ; --- !! STRONGLY VERIFY THIS PATH !! ---
    ; DBeaver installation paths vary greatly! Check your installation.
    ; Common Installer Path: C:\Program Files\DBeaver\dbeaver.exe
    ; Possible User Path: C:\Users\%UserName%\AppData\Local\DBeaver\dbeaver.exe
    ; Could be different if installed via Scoop, Chocolatey, or portable zip.
    dbeaverPath := "C:\Program Files\DBeaver\dbeaver.exe"

    If WinExist("ahk_exe dbeaver.exe") && WinActive("ahk_exe dbeaver.exe")
    {
        Return ; Already active
    }
    Else If WinExist("ahk_exe dbeaver.exe")
    {
        WinActivate, ahk_exe dbeaver.exe
    }
    Else If FileExist(dbeaverPath)
    {
        Run, %dbeaverPath%
    }
    Else
    {
        MsgBox, DBeaver executable not found at:`n%dbeaverPath%`nPlease verify the path in the AutoHotkey script. DBeaver paths often vary.
    }
Return

