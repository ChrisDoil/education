# setup-sdr-windows.ps1 — Windows side of the SDR toolchain: forward the
# RTL-SDR dongle into WSL2 with usbipd-win. Nothing else is needed on Windows;
# SDR++ and the rtl tools run inside WSL (see setup-sdr-wsl.sh).
#
# Run in an ADMINISTRATOR PowerShell:
#   Set-ExecutionPolicy -Scope Process Bypass -Force   # if scripts are blocked
#   .\setup-sdr-windows.ps1
#
# Safe to re-run. Binding is one-time per machine; attaching must be repeated
# every time the dongle is replugged or WSL restarts — the script ends by
# offering --auto-attach for that.

$ErrorActionPreference = 'Stop'
$hwid = '0bda:2838'   # Realtek RTL2838 — the RTL-SDR Blog V3

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Run this from an Administrator PowerShell (bind needs it).' }

Write-Host '==> usbipd-win'
if (Get-Command usbipd -ErrorAction SilentlyContinue) {
    Write-Host "    already installed: $(usbipd --version)"
} else {
    winget install --exact --id dorssel.usbipd-win --accept-source-agreements --accept-package-agreements
    # winget adds it to PATH for new shells; pick it up in this one
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not (Get-Command usbipd -ErrorAction SilentlyContinue)) {
        throw 'usbipd installed but not on PATH yet — open a new admin PowerShell and re-run.'
    }
}

Write-Host '==> looking for the dongle'
$list = usbipd list
$row  = $list | Where-Object { $_ -match $hwid }
if (-not $row) {
    Write-Host "    no $hwid device connected. Plug the RTL-SDR in and re-run." -ForegroundColor Yellow
    Write-Host '    (current devices:)'; $list | Write-Host
    exit 1
}
Write-Host "    $row"

Write-Host '==> bind (one-time: marks the device shareable; hardware-id so it follows the dongle, not the port)'
if ($row -match 'Shared|Attached') {
    Write-Host '    already bound'
} else {
    usbipd bind --hardware-id $hwid
}

Write-Host '==> make sure WSL is running, then attach'
wsl -e true 2>$null
usbipd attach --wsl --hardware-id $hwid
Write-Host '    attached. In WSL:  lsusb && rtl_test -t'

Write-Host ''
Write-Host 'Every replug / WSL restart needs the attach again:'
Write-Host "    usbipd attach --wsl --hardware-id $hwid"
Write-Host 'or, to have it re-attach automatically while this window stays open:'
Write-Host "    usbipd attach --wsl --hardware-id $hwid --auto-attach"
