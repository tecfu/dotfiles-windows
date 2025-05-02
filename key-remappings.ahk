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
; Map Win+M to open/activate Outlook
;-----------------------------------------
#m::
    outlookPath := "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE" ; --- VERIFY THIS PATH! ---
    If WinExist("ahk_exe OUTLOOK.EXE") && WinActive("ahk_exe OUTLOOK.EXE") {
        Return
    } Else If WinExist("ahk_exe OUTLOOK.EXE") {
        WinActivate, ahk_exe OUTLOOK.EXE
    } Else If FileExist(outlookPath) {
        Run, %outlookPath%
    } Else {
        MsgBox, Outlook executable not found at:`n%outlookPath%`nPlease verify the path in the AutoHotkey script.
    }
Return


;-----------------------------------------
; Map Win+V to open/activate Visual Studio Code
;-----------------------------------------
#v::
    vsCodePath := "C:\Users\" . A_UserName . "\AppData\Local\Programs\Microsoft VS Code\Code.exe" ; --- VERIFY USER PATH! ---
    vsCodePathSystem := "C:\Program Files\Microsoft VS Code\Code.exe" ; --- VERIFY SYSTEM PATH! ---

    If WinExist("ahk_exe Code.exe") && WinActive("ahk_exe Code.exe") {
        Return
    } Else If WinExist("ahk_exe Code.exe") {
        WinActivate, ahk_exe Code.exe
    } Else If FileExist(vsCodePath) {
        Run, %vsCodePath%
    } Else If FileExist(vsCodePathSystem) {
        Run, %vsCodePathSystem%
    } Else {
         MsgBox, Visual Studio Code executable not found at common locations:`n%vsCodePath%`nOR`n%vsCodePathSystem%`nPlease verify the path in the AutoHotkey script.
    }
Return


;-----------------------------------------
; Map Win+C to open/activate Google Chrome
;-----------------------------------------
#c::
    chromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe" ; --- VERIFY 64-BIT PATH! ---
    chromePathX86 := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" ; --- VERIFY 32-BIT PATH! ---

    If WinExist("ahk_exe chrome.exe") {
        WinActivate, ahk_exe chrome.exe
    } Else If FileExist(chromePath) {
        Run, %chromePath%
    } Else If FileExist(chromePathX86) {
         Run, %chromePathX86%
    } Else {
        MsgBox, Google Chrome executable not found at common locations:`n%chromePath%`nOR`n%chromePathX86%`nPlease verify the path in the AutoHotkey script.
    }
Return


;-----------------------------------------
; Map Win+D to open/activate DBeaver
;-----------------------------------------
#d::
    dbeaverPath := "C:\Program Files\DBeaver\dbeaver.exe" ; --- !! STRONGLY VERIFY THIS PATH !! ---

    If WinExist("ahk_exe dbeaver.exe") && WinActive("ahk_exe dbeaver.exe") {
        Return
    } Else If WinExist("ahk_exe dbeaver.exe") {
        WinActivate, ahk_exe dbeaver.exe
    } Else If FileExist(dbeaverPath) {
        Run, %dbeaverPath%
    } Else {
        MsgBox, DBeaver executable not found at:`n%dbeaverPath%`nPlease verify the path in the AutoHotkey script. DBeaver paths often vary.
    }
Return


;-----------------------------------------
; Map Ctrl+Q to close the ACTIVE window
;-----------------------------------------
; ^ represents the Ctrl key
; q represents the 'q' key
; This will attempt to close the currently focused window, regardless of the application.
; It overrides the default Ctrl+Q behavior in applications that use it.

^q::
    WinClose, A ; 'A' refers to the active window
Return
