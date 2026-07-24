#NoEnv
#SingleInstance Force
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%

;===========================================================
; Helper Functions
;===========================================================

LaunchOrActivate(exeName, paths) {
    ; Activate existing window if one exists.
    if WinExist("ahk_exe " . exeName) {
        WinActivate
        return
    }

    ; Accept either a single path or an array of paths.
    if !IsObject(paths)
        paths := [paths]

    for _, path in paths {
        if FileExist(path) {
            Run, %path%
            return
        }
    }

    MsgBox, 16, Application Not Found, % exeName . "`n`nExecutable not found.`n`nSearched:`n`n" . StrJoin(paths, "`n")
}

StrJoin(arr, delim := "`n") {
    out := ""
    for i, item in arr {
        if (i > 1)
            out .= delim
        out .= item
    }
    return out
}

;===========================================================
; Win+O -> Outlook
;===========================================================
#o::
    LaunchOrActivate("OUTLOOK.EXE", [
        "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE",
        "C:\Program Files\Microsoft Office\root\Office17\OUTLOOK.EXE"
    ])
Return

;===========================================================
; Win+V -> Visual Studio Code
;===========================================================
#v::
    EnvGet, LocalAppData, LOCALAPPDATA

    LaunchOrActivate("Code.exe", [
        LocalAppData . "\Programs\Microsoft VS Code\Code.exe",
        "C:\Program Files\Microsoft VS Code\Code.exe"
    ])
Return

;===========================================================
; Win+C -> Google Chrome
;===========================================================
#c::
    EnvGet, LocalAppData, LOCALAPPDATA

    LaunchOrActivate("chrome.exe", [
        LocalAppData . "\Google\Chrome\Application\chrome.exe",
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    ])
Return

;===========================================================
; Win+D -> DBeaver
;===========================================================
#d::
    LaunchOrActivate("dbeaver-ce.exe", [
        "C:\Program Files\DBeaver\dbeaver-ce.exe",
        "C:\Program Files\DBeaver\dbeaver.exe"
    ])
Return

;===========================================================
; Win+N -> Neovim
;
; Opens Neovim in Windows Terminal using:
; %USERPROFILE%\.vim\init.vim
;===========================================================
#n::
    EnvGet, UserProfile, USERPROFILE

    nvim := UserProfile . "\Applications\nvim-win64\nvim-win64\bin\nvim.exe"
    init := UserProfile . "\.vim\init.vim"

    if !FileExist(nvim) {
        MsgBox, 16, Neovim, Neovim executable not found.`n`n%nvim%
        Return
    }

    if !FileExist(init) {
        MsgBox, 16, Neovim, init.vim not found.`n`n%init%
        Return
    }

    cmd := """" . nvim . """ -u """ . init . """"

    if WinExist("ahk_exe WindowsTerminal.exe")
        Run, % "wt -w 0 nt --title Neovim " . cmd
    else
        Run, % "wt nt --title Neovim " . cmd
Return

;===========================================================
; Ctrl+Alt+T -> Alacritty (WSL/Linux)
;
; Uses:
;   ~/.alacritty.toml
;===========================================================
^!t::
    Run, wsl.exe alacritty -c ~/.alacritty.toml
Return

;===========================================================
; Ctrl+Alt+Shift+T -> Alacritty (Windows)
;
; Uses:
;   %USERPROFILE%\.config\alacritty\alacritty.ps.toml
;===========================================================
^!+t::
    EnvGet, UserProfile, USERPROFILE

    alacritty := UserProfile . "\Applications\Alacritty.exe"
    config := UserProfile . "\.config\alacritty\alacritty.ps.toml"

    if !FileExist(alacritty) {
        MsgBox, 16, Alacritty, Alacritty executable not found.`n`n%alacritty%
        Return
    }

    if !FileExist(config) {
        MsgBox, 16, Alacritty, Configuration file not found.`n`n%config%
        Return
    }

    cmd := """" . alacritty . """ -c """ . config . """ --working-directory """ . UserProfile . """"

    Run, %cmd%, %UserProfile%
Return
