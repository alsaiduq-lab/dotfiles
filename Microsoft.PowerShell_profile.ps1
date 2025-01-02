Import-Module Terminal-Icons
Import-Module PSReadLine
Import-Module z
Import-Module posh-git
Import-Module gsudoModule

# Discord Rich Presence IPC Path Setup
#
# This hotfix ensures proper Discord RPC (Rich Presence Control) functionality
# for applications like Neovim that rely on Discord's IPC pipe.
# It checks for both standard Discord and Vesktop (alternative Discord client) IPC paths
# and sets the appropriate environment variable.
#
# Priority:
# 1. Use existing DISCORD_IPC_PATH if set
# 2. Check for Vesktop IPC pipe
# 3. Fall back to standard Discord IPC pipe

$ErrorActionPreference = 'SilentlyContinue'
if ($null -eq $env:DISCORD_IPC_PATH) {
    $discordPipe = "\\.\pipe\discord-ipc-0"
    $vestopPipe = Join-Path $env:APPDATA "vesktop\discord-ipc-0"
    
    $env:DISCORD_IPC_PATH = if (Test-Path $vestopPipe) {
        $vestopPipe
    } else {
        $discordPipe
    }
}
$ErrorActionPreference = 'Continue'


# Environment setup
$env:VIRTUAL_ENV_DISABLE_PROMPT = "1"
$env:MANPAGER = "less -R"

$env:POWERSHELL_UPDATECHECK = "Off"
$env:GIT_OPTIONAL_LOCKS = "0"

$LocalBin = Join-Path $HOME ".local\bin"
$CargoBin = Join-Path $HOME ".cargo\bin"

if (Test-Path $LocalBin) {
    $env:PATH = "$LocalBin;$env:PATH"
}
if (Test-Path $CargoBin) {
    $env:PATH = "$CargoBin;$env:PATH"
}


Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -Colors @{
    Command            = [ConsoleColor]::Cyan
    Number             = [ConsoleColor]::Yellow
    Member             = [ConsoleColor]::Magenta
    Operator           = [ConsoleColor]::Magenta
    Type               = [ConsoleColor]::Blue
    Variable           = [ConsoleColor]::Green
    Parameter          = [ConsoleColor]::White
    ContinuationPrompt = [ConsoleColor]::Gray
    Default            = [ConsoleColor]::White
}

# History management and search configuration
#
# Enhanced PowerShell history management with:
# - Smart history search using up/down arrows
# - Ctrl+R for reverse history search
# - F8 for history search with current text
# - Extended history size and persistence
# - History save path customization

# Set history file location
$historyFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.powershell_history'
Set-PSReadLineOption -HistorySavePath $historyFilePath

# Configure history behavior
Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# Smart history navigation
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key F8 -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Shift+F8 -Function HistorySearchForward

# Additional history search bindings
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
Set-PSReadLineKeyHandler -Key Ctrl+s -Function ForwardSearchHistory
Set-PSReadLineKeyHandler -Key Ctrl+Alt+UpArrow -Function PreviousHistory
Set-PSReadLineKeyHandler -Key Ctrl+Alt+DownArrow -Function NextHistory


# Custom utility functions for PowerShell
#
# A collection of enhanced utility functions to simplify common operations
# and provide additional functionality for daily tasks.
#
#





function backup {
    <#
    .SYNOPSIS
        Creates a backup copy of a file with .bak extension
    .DESCRIPTION
        Makes a copy of the specified file and appends .bak to the filename
    .PARAMETER filename
        The path to the file to backup
    .EXAMPLE
        backup "config.json"
        # Creates config.json.bak
    #>
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$filename
    )
    
    if (Test-Path $filename) {
        try {
            Copy-Item $filename "$filename.bak" -ErrorAction Stop
            Write-Host "✓ Created backup: $filename.bak" -ForegroundColor Green
        } catch {
            Write-Host "× Failed to create backup: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "× File not found: $filename" -ForegroundColor Red
    }
}

function copy {
    <#
    .SYNOPSIS
        Enhanced copy function with directory support
    .DESCRIPTION
        Copies files or directories, with recursive support for directories
    .PARAMETER from
        Source path
    .PARAMETER to
        Destination path
    .EXAMPLE
        copy "src" "dest"
        # Copies src directory to dest
    #>
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$from,
        
        [Parameter(Position=1)]
        [string]$to
    )
    
    try {
        if ((Test-Path $from -PathType Container) -and $to) {
            Copy-Item -Path $from -Destination $to -Recurse -ErrorAction Stop
            Write-Host "✓ Copied directory: $from -> $to" -ForegroundColor Green
        } else {
            Copy-Item $args -ErrorAction Stop
            Write-Host "✓ Copied file(s) successfully" -ForegroundColor Green
        }
    } catch {
        Write-Host "× Copy failed: $_" -ForegroundColor Red
    }
}


function Find-File {
    <#
    .SYNOPSIS
        Recursively searches for files matching a pattern
    .DESCRIPTION
        Searches current directory and subdirectories for files matching the specified pattern
    .PARAMETER name
        Full or partial filename to search for
    .EXAMPLE
        Find-File "config"
        # Finds all files containing "config" in the name
    #>
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$name
    )
    
    try {
        $results = Get-ChildItem -Recurse -Filter "*$name*" | Select-Object FullName
        if ($results) {
            Write-Host "`nFound $($results.Count) matches:" -ForegroundColor Cyan
            $results | ForEach-Object {
                Write-Host "  $($_.FullName)"
            }
        } else {
            Write-Host "No files found matching: $name" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "× Search failed: $_" -ForegroundColor Red
    }
}


function Get-PublicIP {
    <#
    .SYNOPSIS
        Retrieves the current public IP address
    .DESCRIPTION
        Uses ipify.org API to fetch the current public IP address of the system
    .EXAMPLE
        Get-PublicIP
        # Returns current public IP address
    #>
    try {
        $response = Invoke-WebRequest -Uri "https://api.ipify.org?format=text" -TimeoutSec 5
        $ip = $response.Content.Trim()
        Write-Host "Public IP: $ip" -ForegroundColor Cyan
        return $ip
    } catch {
        Write-Host "× Failed to retrieve IP address: $_" -ForegroundColor Red
        return $null
    }
}







#alias'
# Unix-style aliases with enhanced functionality
#
# These aliases provide Unix/Linux-like commands in PowerShell
# with additional features and Windows-appropriate implementations.

# Network and Web
Set-Alias -Name curl -Value Invoke-WebRequestWrapper -Force -Option AllScope -Description "Enhanced web request client with curl-like syntax"

# File System Operations
Set-Alias -Name ls -Value dir -Option AllScope -Force -Description "List directory contents"
Set-Alias -Name grep -Value Select-String -Description "Search for patterns in text"
Set-Alias -Name which -Value Get-Command -Description "Locate commands and show their paths"
Set-Alias -Name touch -Value New-Item -Description "Create new files or update timestamps"
Set-Alias -Name less -Value 'Get-Content -Wait' -Description "View file contents with scrolling"
Set-Alias -Name tree -Value Show-TreeWithParams -Description "Display directory structure in tree format"
Set-Alias -Name find -Value Find-File -Description "Recursively search for files in current directory and subdirectories"
Set-Alias -Name pubip -Value Get-PublicIP -Description "Get the current public IP address of this system"

# Process Management
Set-Alias -Name pkill -Value Stop-Process -Description "Kill processes by name or ID"
Set-Alias -Name sudo -Value gsudo -Description "Execute commands with elevated privileges"
Set-Alias -Name reboot -Value Restart-Computer -Description "Reboots the pc"

# File Content Viewing
# Use 'bat' if available, fallback to Get-Content
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    Set-Alias -Name cat -Value bat -Option AllScope -Force -Description "Display file contents with syntax highlighting (using bat)"
} else {
    Set-Alias -Name cat -Value Get-Content -Option AllScope -Force -Description "Display file contents"
}

# Directory navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function ..... { Set-Location ../../../.. }
function ...... { Set-Location ../../../../.. }




# Main tree function
function Show-Tree {
    param (
        [string]$Path = ".",
        [int]$IndentLevel = 0,
        [switch]$NoFiles,
        [switch]$DirectoriesOnly,
        [System.Collections.ArrayList]$ParentLastStatus = $null
    )

$fileTypes = @{
    # Text and Documents
    '.txt'  = '📄'; '.doc'  = '📄'; '.docx' = '📄'; '.odt' = '📄'
    '.pdf'  = '📕'; '.md'   = '📖'; '.json' = '🔧'
    '.xml'  = '📰'; '.csv'  = '📊'; '.xlsx' = '📊'; '.xls' = '📊'
    '.rtf'  = '📄'; '.tex'  = '📜'; '.epub' = '📚'
    '.mobi' = '📚'; '.azw3' = '📚'; '.azw'  = '📚'
    '.ppt'  = '📊'; '.pptx' = '📊'; '.key'  = '📊'
    '.pages'= '📄'; '.gdoc' = '📄'; '.gdraw'= '🎨'
    
    # Source Code
    '.ps1'  = '💠'; '.psm1' = '💠'; '.psd1' = '💠'
    '.py'   = '🐍'; '.pyc'  = '🐍'; '.pyw'  = '🐍'
    '.js'   = '🟨'; '.jsx'  = '🟨'; '.ts'   = '🔷'
    '.tsx'  = '🔷'; '.vue'  = '🟢'; '.svelte' = '🔥'
    '.html' = '🌐'; '.css'  = '🎨'; '.scss' = '🎨'
    '.less' = '🎨'; '.sass' = '🎨'
    '.cpp'  = '🔵'; '.c'    = '🔵'; '.h'    = '🔵'
    '.hpp'  = '🔵'; '.hxx'  = '🔵'; '.cc'   = '🔵'
    '.java' = '☕'; '.class'= '☕'; '.jar'  = '☕'
    '.kt'   = '🟦'; '.scala'= '🔵'; '.groovy' = '🟣'
    '.rs'   = '🦀'; '.go'   = '🔹'; '.nim'  = '👑'
    '.lua'  = '🌙'; '.r'    = '📊'; '.m'    = '🔢'
    '.f90'  = '🔢'; '.f95'  = '🔢'; '.f03'  = '🔢'
    '.asm'  = '⚙️'; '.s'    = '⚙️'; '.ko'   = '🐧'
    '.swift'= '🦅'; '.dart' = '🎯'; '.vb'   = '🅱️'
    '.fs'   = '🔷'; '.jl'   = '🔹'; '.sh'   = '🐚'
    '.zsh'  = '🌰'; '.bash' = '🐚'; '.pl'   = '🐪'
    '.php'  = '🐘'; '.sql'  = '🗃️'; '.rb'   = '💎'
    '.rkt'  = '🍇'; '.clj'  = '🍏'; '.erl'  = '📡'
    
    # Media
    '.jpg'  = '🖼️'; '.jpeg' = '🖼️'; '.png'  = '🖼️'
    '.gif'  = '🎬'; '.mp4'  = '🎥'; '.mov'  = '🎥'
    '.avi'  = '🎥'; '.mkv'  = '🎥'; '.wmv'  = '🎥'
    '.mp3'  = '🎵'; '.wav'  = '🎵'; '.ogg'  = '🎵'
    '.flac' = '🎵'; '.m4a'  = '🎵'; '.aac'  = '🎵'
    '.webp' = '🖼️'; '.svg'  = '🎨'; '.ico'  = '🎨'
    '.webm' = '🎥'; '.heic' = '📷'; '.raw'  = '📸'
    '.psd'  = '🎨'; '.ai'   = '🎨'; '.xcf'  = '🎨'
    '.tiff' = '🖼️'; '.bmp'  = '🖼️'; '.cr2'  = '📸'
    '.mpeg' = '🎥'; '.m2ts' = '🎥'; '.3gp'  = '🎥'
    
    # Archives
    '.zip'  = '📦'; '.rar'  = '📦'; '.7z'   = '📦'
    '.tar'  = '📦'; '.gz'   = '📦'; '.bz2'  = '📦'
    '.xz'   = '📦'; '.iso'  = '💿'; '.img'  = '💿'
    '.tgz'  = '📦'; '.tbz2' = '📦'; '.lz4'  = '📦'
    '.cab'  = '📦'; '.dmg'  = '💿'; '.s7z'  = '📦'
    '.arj'  = '📦'; '.deb'  = '📦'; '.rpm'  = '📦'
    
    # Executables and Scripts
    '.exe'  = '⚡'; '.bat'  = '⚡'; '.cmd'  = '⚡'
    '.msi'  = '📥'; '.app'  = '📱'; '.apk'  = '📱'
    '.vbs'  = '⚡'; '.lnk'  = '🔗'
    '.cgi'  = '⚙️'; '.bin'  = '💾'; '.run'  = '⚡'
    
    # Configuration
    '.ini'  = '⚙️'; '.cfg'  = '⚙️'; '.yml'  = '📝'
    '.yaml' = '📝'; '.conf' = '⚙️'; '.env'  = '🔒'
    '.toml' = '⚙️'; '.config' = '⚙️'; '.prefs' = '⚙️'
    
    # Git and Version Control
    '.gitignore' = '🚫'; '.gitattributes' = '📋'
    '.gitmodules' = '🔗'; '.diff' = '📝'; '.patch' = '🔨'
    
    # Web Development
    '.wasm' = '⚡'; '.elm'  = '🌳'; '.coffee' = '☕'
    '.asp'  = '🌐'; '.aspx' = '🌐'; '.cshtml' = '🌐'
    
    # Database
    '.sqlite'= '🗃️'; '.mdb'  = '🗃️'; '.accdb'= '🗃️'
    '.pgsql' = '🐘'; '.mongodb' = '🍃'; '.redis' = '🔴'
    '.cql'   = '🗄️'; '.ora'  = '🗄️'
    
    # Container and Cloud
    '.dockerfile' = '🐳'; '.docker' = '🐳'
    '.tf'   = '☁️'; '.tfstate' = '☁️'
    '.k8s'  = '☸️'; '.aws'  = '☁️'; '.azure' = '☁️'
    
    # Other
    '.log'  = '📋'; '.bak'  = '🔄'; '.tmp'  = '⏳'
    '.dll'  = '🔧'; '.sys'  = '💻'
    '.dat'  = '📊'; '.o'    = '⚙️'
    '.lock' = '🔒'; '.pid'  = '🔢'; '.sock' = '🔌'
    '.torrent' = '📡'; '.backup' = '🔄'
    '.DS_Store' = '📁'; '.Thumbs.db' = '🖼️'
}
    
    # Initialize counters at root level
    if ($IndentLevel -eq 0) {
        $script:dirCount = 0
        $script:fileCount = 0
        $ParentLastStatus = New-Object System.Collections.ArrayList
    }

    # Get directory contents
    $allItems = Get-ChildItem -Path $Path
    $directories = @($allItems | Where-Object { $_.PSIsContainer } | Sort-Object Name)
    $files = @($allItems | Where-Object { !$_.PSIsContainer } | Sort-Object Name)

    # Process directories
    for ($i = 0; $i -lt $directories.Count; $i++) {
        $item = $directories[$i]
        $isLast = ($i -eq $directories.Count - 1) -and ($files.Count -eq 0)

        # Build the prefix for the current line
        $prefix = if ($IndentLevel -eq 0) {
            ""
        } else {
            $linePrefix = ""
            for ($j = 0; $j -lt $IndentLevel - 1; $j++) {
                $linePrefix += $(if ($ParentLastStatus[$j]) { "    " } else { "│   " })
            }
            $linePrefix += $(if ($isLast) { "└── " } else { "├── " })
            $linePrefix
        }

        # Output the directory line
        Write-Host $prefix -NoNewline
        Write-Host "📁" -NoNewline
        Write-Host " $($item.Name)" -ForegroundColor Blue

        $script:dirCount++

        # Process subdirectories
        if ($ParentLastStatus -eq $null) {
            $ParentLastStatus = New-Object System.Collections.ArrayList
        }
        $ParentLastStatus.Add($isLast) > $null
        Show-Tree -Path $item.FullName -IndentLevel ($IndentLevel + 1) -NoFiles:$NoFiles -DirectoriesOnly:$DirectoriesOnly -ParentLastStatus $ParentLastStatus
        $ParentLastStatus.RemoveAt($ParentLastStatus.Count - 1)
    }

    # Process files if needed
    if (-not $DirectoriesOnly -and -not $NoFiles) {
        for ($i = 0; $i -lt $files.Count; $i++) {
            $item = $files[$i]
            $isLast = ($i -eq $files.Count - 1)
            $extension = $item.Extension.ToLower()
            $icon = $fileTypes[$extension]
            if (-not $icon) { $icon = '📄' }  # Default icon for unknown file types

            # Build the prefix for files
            $prefix = if ($IndentLevel -eq 0) {
                ""
            } else {
                $linePrefix = ""
                for ($j = 0; $j -lt $IndentLevel - 1; $j++) {
                    $linePrefix += $(if ($ParentLastStatus[$j]) { "    " } else { "│   " })
                }
                $linePrefix += $(if ($isLast) { "└── " } else { "├── " })
                $linePrefix
            }

            # Output the file line
            Write-Host "$prefix$icon $($item.Name)" -ForegroundColor White
            $script:fileCount++
        }
    }

    # Show summary at root level
    if ($IndentLevel -eq 0) {
        Write-Host "`n$script:dirCount directories" -NoNewline
        if (-not $DirectoriesOnly -and -not $NoFiles) {
            Write-Host ", $script:fileCount files" -NoNewline
        }
        Write-Host ""
    }
}

# Wrapper function for easier command-line use
function Show-TreeWithParams {
    param(
        [Parameter(Position = 0)]
        [string]$Path = ".",
        [switch]$NoFiles,
        [switch]$DirectoriesOnly
    )
    Show-Tree -Path $Path -NoFiles:$NoFiles -DirectoriesOnly:$DirectoriesOnly
}










# Initialize Starship with correct Windows paths
$configDir = Join-Path $HOME "AppData\Local\.config"
$configFile = Join-Path $configDir "starship.toml"
$ENV:STARSHIP_CONFIG = $configFile.Replace('\', '/')

try {
    $null = Get-Command starship -ErrorAction Stop
    Invoke-Expression (& starship init powershell)
} catch {
    Write-Warning "Starship is not installed or there was an error: $_"
}


# Set default encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

# API Keys and Environment Variables Management
#
# This module provides secure storage and management of API keys and sensitive credentials.
# Keys are stored in encrypted form in the user's AppData directory and can optionally
# be loaded into environment variables.
#
# Functions:
# - Add-Key: Securely stores an API key or credential
# - Get-Key: Retrieves a stored key
# - Remove-Key: Deletes a stored key
# - Show-Keys: Lists all stored keys
# - Load-Keys: Loads all stored keys into environment variables
#
# Usage:
# addkey -Name "API_KEY" -Value "secret" -AddToEnv     # Store and load to env
# key "API_KEY"                                        # Retrieve a key
# keys                                                 # List all keys
# rmkey "API_KEY" -RemoveFromEnv                       # Delete key and remove from env
# loadkeys                                             # Load all keys to environment

function Add-Key {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Value,
        [switch]$AddToEnv
    )
    
    $apiKeysDir = Join-Path $HOME "AppData\Local\ApiKeys"
    if (!(Test-Path $apiKeysDir)) {
        New-Item -Path $apiKeysDir -ItemType Directory -Force | Out-Null
    }
    $keyPath = Join-Path $apiKeysDir "$Name.key"
    
    $Value | ConvertTo-SecureString -AsPlainText -Force | 
        ConvertFrom-SecureString | 
        Set-Content $keyPath

    if ($AddToEnv) {
        [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process)
    }
}

function Load-Keys {
    $apiKeysDir = Join-Path $HOME "AppData\Local\ApiKeys"
    if (!(Test-Path $apiKeysDir)) {
        New-Item -Path $apiKeysDir -ItemType Directory -Force | Out-Null
        return
    }
    $keys = Get-ChildItem -Path $apiKeysDir -Filter "*.key"
    foreach ($key in $keys) {
        $name = $key.BaseName
        $value = Get-Key -Name $name
        if ($value) {
            [Environment]::SetEnvironmentVariable($name, $value, [EnvironmentVariableTarget]::Process)
        }
    }
}

function Get-Key {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    $apiKeysDir = Join-Path $HOME "AppData\Local\ApiKeys"
    $keyPath = Join-Path $apiKeysDir "$Name.key"
    
    if (Test-Path $keyPath) {
        $secureString = Get-Content $keyPath | ConvertTo-SecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    }
    return $null
}

function Remove-Key {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [switch]$RemoveFromEnv
    )
    
    $apiKeysDir = Join-Path $HOME "AppData\Local\ApiKeys"
    $keyPath = Join-Path $apiKeysDir "$Name.key"
    
    if (Test-Path $keyPath) {
        Remove-Item $keyPath
        if ($RemoveFromEnv) {
            [Environment]::SetEnvironmentVariable($Name, $null, [EnvironmentVariableTarget]::Process)
        }
    }
}

function Show-Keys {
    $apiKeysDir = Join-Path $HOME "AppData\Local\ApiKeys"
    if (!(Test-Path $apiKeysDir)) { return }
    
    $keys = Get-ChildItem -Path $apiKeysDir -Filter "*.key"
    if ($keys) {
        $keys | ForEach-Object {
            $name = $_.BaseName
            $inEnv = [Environment]::GetEnvironmentVariable($name) -ne $null
            $status = if ($inEnv) { "✓" } else { " " }
            Write-Host "  $status $name"
        }
    }
}

Set-Alias -Name key -Value Get-Key
Set-Alias -Name keys -Value Show-Keys
Set-Alias -Name addkey -Value Add-Key
Set-Alias -Name rmkey -Value Remove-Key
Set-Alias -Name loadkeys -Value Load-Keys

# Auto-load keys when profile loads
Load-Keys


# SSH Session Detection
#
# If $env:SSH_CONNECTION or $env:SSH_CLIENT is present, we assume this is an
# SSH session.
# ---------------------------------------------------------------------------

if (($env:SSH_CONNECTION -or $env:SSH_CLIENT) -and $null -eq $env:WT_SESSION) {
    Write-Host "`n[SSH DETECTED] Loading SSH-specific configurations..." -ForegroundColor Cyan

    $SSHConfigScript = Join-Path $HOME "ssh_profile.ps1"

    if (Test-Path $SSHConfigScript) {
        . $SSHConfigScript
        Write-Host "[SSH] SSH keys management functions loaded." -ForegroundColor Green
    } else {
        Write-Host "[SSH] WARNING: SSH keys management script not found at $SSHConfigScript." -ForegroundColor Yellow
    }
}
