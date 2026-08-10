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
; Shift+Ctrl+Alt+T -> Alacritty (Windows PowerShell)
;
; Uses config: %USERPROFILE%\dotfiles-windows\.alacritty.ps.toml
;===========================================================

^!+t:: {
userProfile := EnvGet("USERPROFILE")
alacrittyExe := userProfile . "\Applications\Alacritty.exe"
configPath := userProfile . "\dotfiles-windows\.alacritty.ps.toml"
; Without --working-directory, Alacritty inherits this script's own
; working directory (SetWorkingDir A_ScriptDir, i.e. the dotfiles-windows
; repo folder) instead of opening in $HOME.
RUN('"' . alacrittyExe . '" --config-file "' . configPath . '" --working-directory "' . userProfile . '"', userProfile)
}

;===========================================================
; Ctrl+Alt+T -> Alacritty (Git Bash)
;
; Uses config: %USERPROFILE%\.alacritty.toml (rendered by INSTALL.sh from
; .alacritty.git-bash.toml - see note below)
;===========================================================
; ==================== Alacritty Hotkey ====================
; Ctrl+Alt+T → Open / Focus Alacritty (Git Bash)

^!t:: {
userProfile := EnvGet("USERPROFILE")
alacrittyExe := userProfile . "\Applications\Alacritty.exe"
; Must use the *rendered* config at ~/.alacritty.toml, not the raw repo
; file .alacritty.git-bash.toml directly: INSTALL.sh's
; render_alacritty_config() rewrites that file's placeholder
; "C:/Program Files/Git/bin/bash.exe" `program` path to the actual
; bash.exe location on this machine (e.g. under AppData\Local\Programs\Git
; if Git wasn't installed to the Program Files default). Pointing at the
; raw repo file meant Alacritty tried to launch a bash.exe that doesn't
; exist there, failed immediately, and the window closed right away.
configPath := userProfile . "\.alacritty.toml"
; Without --working-directory, Alacritty inherits this script's own
; working directory (SetWorkingDir A_ScriptDir, i.e. the dotfiles-windows
; repo folder) instead of opening in $HOME.
RUN('"' . alacrittyExe . '" --config-file "' . configPath . '" --working-directory "' . userProfile . '"', userProfile)
}

;===========================================================
; Ctrl+Alt+W -> Alacritty (WSL/Linux)
;
; Uses config: ~/dotfiles-windows/.alacritty.wsl.toml
;===========================================================

^!w:: {
    ; A_UserName is a built-in variable for the current Windows user
    Run("wsl.exe LIBGL_ALWAYS_SOFTWARE=1 alacritty --config-file /mnt/c/Users/" . A_UserName . "/dotfiles-windows/.alacritty.wsl.toml")
}
