# Rust Dedicated Server Automation

This repository contains a PowerShell script to automate downloading, updating, and launching a Rust Dedicated Server using SteamCMD.

## Features

- Automatically downloads and updates SteamCMD if not present.
- Installs or updates the Rust Dedicated Server (AppID: 258550).
- Configures server identity, ports, RCON, world generation, and performance settings.
- Launches the server with custom parameters.

## Usage

1. **Clone or Download** this repository to your server.
2. **Edit `Start.ps1`** to customize server settings (IP, ports, server name, etc.) as needed.
3. **Run the script** in PowerShell:

   ```powershell
   ./Start.ps1
   ```

   - The script will:
     - Download and extract SteamCMD if missing.
     - Install or update Rust Dedicated Server.
     - Create necessary configuration files.
     - Start the server with your specified settings.

## Configuration

- Server settings can be changed at the top of `Start.ps1`.
- The script creates and uses a `server.cfg` file in `server/Tranquility/cfg/`.
- Update frequency is controlled by the `last_update.txt` file (updates if older than 1 day).

## Requirements

- Windows Server or Windows 10/11
- PowerShell 5.1 or later
- Internet connection for downloading SteamCMD and server updates

## Files

- [`Start.ps1`](Start.ps1): Main automation script.
- `update_script.txt`, `last_update.txt`: Used internally by the script.
- `steamcmd/`: Directory where SteamCMD is installed.
- `RustDedicated.exe`: Rust server executable (downloaded by the script).

## Notes

- Make sure required ports are open in your firewall.
- For advanced server configuration, edit `server.cfg` or pass additional arguments in the script.
