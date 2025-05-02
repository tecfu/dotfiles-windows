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
    EnvGet, userProfileDir_VSCode, USERPROFILE ; Explicitly get USERPROFILE env var
    vsCodePath := userProfileDir_VSCode . "\AppData\Local\Programs\Microsoft VS Code\Code.exe" ; --- VERIFY USER PATH! ---
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
; Map Win+N to open/activate Neovim
;-----------------------------------------
#n:: ; Changed hotkey from ^n to #n (Win+N)
    EnvGet, userProfileDir_Nvim, USERPROFILE ; Explicitly get USERPROFILE env var into a variable
    ; --- !! STRONGLY VERIFY THIS PATH !! ---
    ; Construct path using the retrieved environment variable
    neovimPath := userProfileDir_Nvim . "\Applications\nvim-win64\nvim-win64\bin\nvim.exe"
    neovimExe := "nvim.exe" ; Or maybe "nvim-qt.exe" if using a GUI version?

    If WinExist("ahk_exe " . neovimExe) && WinActive("ahk_exe " . neovimExe) {
        Return ; Already active
    } Else If WinExist("ahk_exe " . neovimExe) {
        WinActivate, ahk_exe %neovimExe%
    } Else If FileExist(neovimPath) {
        ; Run inside Windows Terminal (wt.exe) - Recommended for terminal nvim
        ; Using %neovimPath% which now contains the full path derived from userProfileDir_Nvim
        Run, wt.exe new-tab --title Neovim "%neovimPath%" ; Added quotes around path variable for safety

        ; Option 2: Run inside Git Bash's Mintty (Adapt path to mintty.exe if needed)
        ; Run, "C:\Program Files\Git\usr\bin\mintty.exe" -e "%neovimPath%"

        ; Option 3: If using Alacritty (Adapt path to alacritty.exe)
        ; Run, "C:\Path\To\Alacritty\alacritty.exe" -e "%neovimPath%"
    }
    Else {
        MsgBox, Neovim executable not found at:`n%neovimPath%`n(Based on USERPROFILE: %userProfileDir_Nvim%)`nPlease verify the path and executable name (`neovimExe` variable) in the AutoHotkey script.
    }
Return


;-----------------------------------------
; Map Ctrl+Q to close the ACTIVE window
;-----------------------------------------
^q::
    WinClose, A ; 'A' refers to the active window
Return
