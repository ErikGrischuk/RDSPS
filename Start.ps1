# --- Download and update Rust Dedicated Server using SteamCMD ---
$steamCmdUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$steamDir = ".\steamcmd"
$steamCmdExe = Join-Path $steamDir "steamcmd.exe"
$steamCmdZip = Join-Path $steamDir "steamcmd.zip"
$updateScriptPath = ".\update_script.txt"
$lastUpdateFile = ".\last_update.txt"
$rustExe = ".\RustDedicated.exe"

function Ensure-SteamCmd {
    if (-not (Test-Path $steamDir)) {
        New-Item -ItemType Directory -Path $steamDir | Out-Null
    }
    if (-not (Test-Path $steamCmdExe)) {
        Invoke-WebRequest -Uri $steamCmdUrl -OutFile $steamCmdZip
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($steamCmdZip, $steamDir)
        Remove-Item $steamCmdZip
    }
}

function Run-SteamCmdUpdate($validate = $false) {
    $validateLine = if ($validate) { "app_update 258550 validate" } else { "app_update 258550" }
    $updateScriptContent = @"
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
login anonymous
force_install_dir ../
$validateLine
quit
"@
    Set-Content -Path $updateScriptPath -Value $updateScriptContent -Encoding ASCII
    Push-Location $steamDir
    Start-Process -Wait -NoNewWindow ".\steamcmd.exe" -ArgumentList "+runscript ../update_script.txt"
    Pop-Location
    Set-Content -Path $lastUpdateFile -Value (Get-Date)
}

Ensure-SteamCmd

$rustInstalled = Test-Path $rustExe
$needsUpdate = $true

if ($rustInstalled -and (Test-Path $lastUpdateFile)) {
    $lastUpdate = Get-Content $lastUpdateFile | Out-String | Get-Date
    if ($lastUpdate -gt (Get-Date).AddDays(-1)) {
        $needsUpdate = $false
    }
}

if (-not $rustInstalled) {
    Run-SteamCmdUpdate $true
} elseif ($needsUpdate) {
    Run-SteamCmdUpdate $false
}

# --- Start.ps1 ---
$serverdir = "Tranquility"
$cfgPath = ".\server\$serverdir\cfg\server.cfg"
if (-not (Test-Path $cfgPath)) {
    New-Item -ItemType File -Path $cfgPath -Force | Out-Null
}
# --- IP server ---
$ip = "192.168.137.1"

# --- Ports ---
$port = "28015"
$rconport = "28016"
$queryport = "28017"
$appport = "28083"

# --- RCON settings ---
$rconpassword = "MyStrongPassword123"
$rconweb = "True"

# --- Server settings ---
$servername = "[US] Tranquility:PvE"   
$serverdescription = "Welcome to Tranquility PvE Rust Server!"
$gamemode = "survival"
$tags = "monthly,pve,vanilla,na"
$serverurl = "https://example.png"
$headerimage = "https://example.png"
$logoimage = "https://example.png"

# --- World generation settings ---
$serverlevel = "Procedural Map"
$worldsize = "1000"
$seed = "123456"
$salt = "654321"

# --- Performance settings ---
$saveinterval = "600"
$tickrate = "128"
$fps = "256"
$gamelog = "server.log"
$maxplayers = "50"
$systemcpupriority = "high"

#--- TEST SETTINGS ---
#--- Clan system settings ---
$clanenabled = "True"

# --- Official server settings ---
$serverofficial = "True"

# --- Tutorial island settings ---
$tutorialenabled = "True"

# --- Arguments ---
$arguments = @(
# --- Process launch parameters ---
    "-batchmode",
    "-load",
    "-nographics",
    "-logfile", "$gamelog",
    "-LogLevel info",
    "-autoupdate",
# --- Server configuration ---
    "+server.identity $serverdir",
    "+server.readcfg"
# --- Connection parameters ---
    "+server.ip $ip",
    "+server.port $port",
    "+server.queryport $queryport",
# --- Rust+ App parameters ---
    "+app.listenip $ip",
    "+app.publicip $ip",
    "+app.port $appport",
# --- RCON parameters ---
    "+rcon.ip $ip",  
    "+rcon.port $rconport",
    "+rcon.web $rconweb",
    "+rcon.password `"$rconpassword`"",
# --- Server settings ---
    "+server.hostname `"$servername`"",
    "+server.description `"$serverdescription`"",
    "+server.gamemode $gamemode",
    "+server.tags $tags",
    "+server.url `"$serverurl`"",
    "+server.headerimage `"$headerimage`"",
    "+server.logoimage `"$logoimage`"",
# --- Test server settings ---
    "+clan.enabled $clanenabled",
    "+server.official $serverofficial",
    "+server.tutorialenabled $tutorialenabled",
# --- World generation settings ---
    "+server.level `"$serverlevel`"",
    "+server.worldsize $worldsize",
    "+server.seed $seed",
    "+server.salt $salt",
# --- Performance settings ---
    "+server.saveinterval $saveinterval",
    "+server.tickrate $tickrate",
    "+fps.limit $fps",
    "+server.maxplayers $maxplayers",
    "+system.cpu_priority $systemcpupriority"
)
# --- Run server ---
Start-Process ".\RustDedicated.exe" -ArgumentList $arguments
