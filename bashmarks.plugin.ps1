# PowerShell port of bashmarks.plugin.sh.
#
# Shares the same bookmark storage file ($HOME/.sdirs, in the bash
# `export DIR_name="path"` format) so bookmarks saved from Git Bash / WSL
# are immediately available here, and vice versa. Paths are stored with a
# literal "$HOME" prefix (instead of an expanded absolute path) exactly like
# the bash version, so bookmarks remain portable across shells/machines
# sharing the same $HOME.
#
# USAGE:
# bm -a bookmarkname - saves the curr dir as bookmarkname
# bm -g bookmarkname - jumps to that bookmark (or: g bookmarkname)
# bm -p bookmarkname - prints the bookmark (or: p bookmarkname)
# bm -d bookmarkname - deletes the bookmark (or: d bookmarkname)
# bm -l             - list all bookmarks (or: bm ls)

$Script:BashmarksFile = Join-Path $HOME ".sdirs"

if (-not (Test-Path $Script:BashmarksFile)) {
    New-Item -ItemType File -Path $Script:BashmarksFile -Force | Out-Null
}

function Test-BashmarkName {
    param([string]$Name)
    if ([string]::IsNullOrEmpty($Name)) {
        Write-Host "bookmark name required"
        return $false
    }
    if ($Name -notmatch '^[A-Za-z0-9_]+$') {
        Write-Host "bookmark name is not valid"
        return $false
    }
    return $true
}

# Reads $HOME/.sdirs into an ordered name -> absolute-path table, expanding
# the literal "$HOME" prefix bash writes into this machine's actual $HOME.
function Get-BashmarkTable {
    $table = [ordered]@{}
    if (Test-Path $Script:BashmarksFile) {
        Get-Content $Script:BashmarksFile | ForEach-Object {
            if ($_ -match '^export DIR_([A-Za-z0-9_]+)="(.*)"$') {
                $name = $Matches[1]
                $path = $Matches[2].Replace('$HOME', $HOME) -replace '/', '\'
                $table[$name] = $path
            }
        }
    }
    return $table
}

function Remove-BashmarkLine {
    param([string]$Name)
    if (Test-Path $Script:BashmarksFile) {
        $lines = @(Get-Content $Script:BashmarksFile | Where-Object { $_ -notmatch "^export DIR_$Name=" })
        Set-Content -Path $Script:BashmarksFile -Value $lines
    }
}

function Save-Bashmark {
    param([Parameter(Position = 0)][string]$Name)
    if (-not (Test-BashmarkName $Name)) { return }
    Remove-BashmarkLine -Name $Name
    $curDir = (Get-Location).Path
    $homeTrimmed = $HOME.TrimEnd('\')
    if ($curDir.StartsWith($homeTrimmed, [System.StringComparison]::OrdinalIgnoreCase)) {
        $curDir = '$HOME' + $curDir.Substring($homeTrimmed.Length)
    }
    $curDir = $curDir -replace '\\', '/'
    Add-Content -Path $Script:BashmarksFile -Value "export DIR_$Name=`"$curDir`""
}

function Remove-Bashmark {
    param([Parameter(Position = 0)][string]$Name)
    if (-not (Test-BashmarkName $Name)) { return }
    Remove-BashmarkLine -Name $Name
}

function Invoke-Bashmark {
    param([Parameter(Position = 0)][string]$Name)
    $table = Get-BashmarkTable
    if (-not $table.Contains($Name)) {
        Write-Host "WARNING: '$Name' bashmark does not exist" -ForegroundColor DarkYellow
        return
    }
    $target = $table[$Name]
    if (Test-Path $target) {
        Set-Location $target
    } else {
        Write-Host "WARNING: '$target' does not exist" -ForegroundColor DarkYellow
    }
}

function Show-Bashmark {
    param([Parameter(Position = 0)][string]$Name)
    $table = Get-BashmarkTable
    if ($table.Contains($Name)) {
        $table[$Name]
    } else {
        Write-Host "WARNING: '$Name' bashmark does not exist" -ForegroundColor DarkYellow
    }
}

function Get-BashmarkNames {
    (Get-BashmarkTable).Keys | Sort-Object
}

function Show-BashmarkList {
    $table = Get-BashmarkTable
    foreach ($name in ($table.Keys | Sort-Object)) {
        Write-Host ("{0,-20} {1}" -f "DIR_$name", $table[$name]) -ForegroundColor DarkYellow
    }
}

function Show-BashmarkUsage {
    Write-Host 'USAGE:'
    Write-Host "bm -h                   - Prints this usage info"
    Write-Host 'bm -a <bookmark_name>   - Saves the current directory as "bookmark_name"'
    Write-Host 'bm [-g] <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
    Write-Host 'bm -p <bookmark_name>   - Prints the directory associated with "bookmark_name"'
    Write-Host 'bm -d <bookmark_name>   - Deletes the bookmark'
    Write-Host 'bm -l                   - Lists all available bookmarks'
}

function bm {
    # Deliberately no param() block: PowerShell's parameter binder treats a
    # bare "-l"/"-a"/etc. token as a parameter-name lookup (not a positional
    # value) even when quoted, so options like `bm -l` would otherwise fail
    # to bind. Reading $args directly sidesteps that.
    $Option = $args[0]
    $Name = $args[1]
    switch ($Option) {
        '-a' { Save-Bashmark -Name $Name }
        '-d' { Remove-Bashmark -Name $Name }
        '-g' { Invoke-Bashmark -Name $Name }
        '-p' { Show-Bashmark -Name $Name }
        '-l' { Show-BashmarkList }
        '-h' { Show-BashmarkUsage }
        'ls' { Show-BashmarkList }
        default {
            if ([string]::IsNullOrEmpty($Option)) {
                Show-BashmarkUsage
            } elseif ($Option.StartsWith('-')) {
                Write-Host "Unknown option '$Option'"
                Show-BashmarkUsage
            } else {
                # non-option supplied as first arg. assume goto [ bm BOOKMARK_NAME ]
                Invoke-Bashmark -Name $Option
            }
        }
    }
}

# Aliases mirroring the bash plugin: s (save), g (goto), p (print), d (delete)
Set-Alias -Name s -Value Save-Bashmark -Force
Set-Alias -Name g -Value Invoke-Bashmark -Force
Set-Alias -Name p -Value Show-Bashmark -Force
Set-Alias -Name d -Value Remove-Bashmark -Force

# Tab completion for bookmark names on g/p/d (bm intentionally excluded: it
# has no param() block - see bm's definition above - so ArgumentCompleter,
# which binds by parameter name, has nothing to attach to for bm's 2nd arg;
# use the g/s/p/d aliases for tab completion instead).
$Script:BashmarkCompleter = {
    param($wordToComplete, $commandAst, $cursorPosition)
    Get-BashmarkNames | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
Register-ArgumentCompleter -CommandName g -ParameterName Name -ScriptBlock $Script:BashmarkCompleter
Register-ArgumentCompleter -CommandName p -ParameterName Name -ScriptBlock $Script:BashmarkCompleter
Register-ArgumentCompleter -CommandName d -ParameterName Name -ScriptBlock $Script:BashmarkCompleter
