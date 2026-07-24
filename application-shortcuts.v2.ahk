#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

;===========================================================
; Global Settings
;===========================================================
SendMode "Input"
SetWorkingDir A_ScriptDir

;===========================================================
; Helper Functions
;===========================================================

LaunchOrActivate(exeName, paths) {
    if WinExist("ahk_exe " exeName) {
        WinActivate
        return
    }

    if !IsObject(paths)
        paths := [paths]

    for path in paths {
        if FileExist(path) {
            Run(path)
            return
        }
    }

    MsgBox(
        exeName "`n`nExecutable not found.`n`nSearched:`n`n" StrJoin(paths, "`n"),
        "Application Not Found",
        "Iconx"
    )
}

StrJoin(arr, delim := "`n") {
    result := ""
    for i, item in arr
        result .= (i > 1 ? delim : "") item
    return result
}

;===========================================================
; Win+O -> Outlook
;===========================================================
#o::{
    LaunchOrActivate("OUTLOOK.EXE", [
        "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE",
        "C:\Program Files\Microsoft Office\root\Office17\OUTLOOK.EXE"
    ])
}

;===========================================================
; Win+V -> Visual Studio Code
;===========================================================
#v::{
    LaunchOrActivate("Code.exe", [
        EnvGet("LOCALAPPDATA") "\Programs\Microsoft VS Code\Code.exe",
        "C:\Program Files\Microsoft VS Code\Code.exe"
    ])
}

;===========================================================
; Win+C -> Google Chrome
;===========================================================
#c::{
    LaunchOrActivate("chrome.exe", [
        EnvGet("LOCALAPPDATA") "\Google\Chrome\Application\chrome.exe",
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    ])
}

;===========================================================
; Win+D -> DBeaver
;===========================================================
#d::{
    LaunchOrActivate("dbeaver-ce.exe", [
        "C:\Program Files\DBeaver\dbeaver-ce.exe",
        "C:\Program Files\DBeaver\dbeaver.exe"
    ])
}

;===========================================================
; Win+N -> Neovim
;===========================================================
#n::{
    profile := EnvGet("USERPROFILE")
    nvim := profile "\Applications\nvim-win64\nvim-win64\bin\nvim.exe"
    init := profile "\.vim\init.vim"

    if !FileExist(nvim) {
        MsgBox("Neovim executable not found:`n`n" nvim, "Neovim", "Iconx")
        return
    }

    if !FileExist(init) {
        MsgBox("Neovim init.vim not found:`n`n" init, "Neovim", "Iconx")
        return
    }

    cmd := '"' nvim '" -u "' init '"'

    if WinExist("ahk_exe WindowsTerminal.exe")
        Run('wt -w 0 nt --title Neovim ' cmd)
    else
        Run('wt nt --title Neovim ' cmd)
}

;===========================================================
; Shift+Ctrl+Alt+T -> Alacritty (WSL/Linux)
;
; Uses config: ~/dotfiles-windows/.alacritty.toml
;===========================================================

^!+t::{
    ; A_UserName is a built-in variable for the current Windows user
    Run("wsl.exe LIBGL_ALWAYS_SOFTWARE=1 alacritty --config-file /mnt/c/Users/" . A_UserName . "/dotfiles-windows/.alacritty.wsl.toml")
}

;===========================================================
; Ctrl+Alt+T -> Alacritty (Windows)
;
; Uses config: %USERPROFILE%\dotfiles-windows\.alacritty.ps.toml
;===========================================================
; ==================== Alacritty Hotkey ====================
; Ctrl+Alt+T → Open / Focus Alacritty

^!t:: {
    userProfile := EnvGet("USERPROFILE")
    alacrittyPath := userProfile "\Applications\Alacritty.exe"
    
    if WinExist("ahk_exe Alacritty.exe") {
        WinActivate("ahk_exe Alacritty.exe")
    } else {
        Run alacrittyPath
    }
}
