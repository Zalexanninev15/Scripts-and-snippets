# Works on >= Windows 10 21H2 / Windows 11
# msixbundle: https://github.com/microsoft/winget-cli/releases/ Add-AppxPackage -Path Microsoft.DesktopAppInstaller_*.msixbundle
# MSStore link: https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1
# winget packages repo: https://github.com/microsoft/winget-pkgs/tree/master/manifests
# for autoupdates use msstore variants

# upgrade all: winget upgrade --all # also updates software not installed by winget can't pin or ignore yet
# options: https://docs.microsoft.com/en-us/windows/package-manager/winget/install#options

if (-Not (Get-Command "winget" -errorAction SilentlyContinue)) {
    Write-Error -Message "Please install winget"
    exit 1
}

# Check Permissions
if ( -Not( (New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) ){
    Write-Error -Message "Script needs Administrator permissions"
    exit 1
}
# WEB
# winget install --id Rambox.RamboxCE -e --silent
winget install --id AmineMouafik.Ferdi -e --silent
winget install --id 9NZVDKPMR9RD # Firefox
#winget install --id LibreWolf.LibreWolf -e --silent
#winget install --id eloston.ungoogled-chromium -e --silent

# Office
winget install LibreOffice.LibreOffice
winget install mb21.panwriter

# Encryption / Keys / Passwords
winget install --id KeePassXCTeam.KeePassXC -e --silent
winget install --id 9N9K02V7XR1B # xca Key Manager
winget install --id ShiningLight.OpenSSL-e --silent

# PDF
winget install --id SumatraPDF.SumatraPDF -e --silent
winget install --id XPDP273C0XHQH2 # Adobe Acrobat Reader DC
winget install --id 9N41MSQ1WNM8 # Okular PDF Reader
winget install --id geeksoftwareGmbH.PDF24Creator -e --silent

# Media Consumption
winget install --id Audacity.Audacity -e --silent
winget install --id XPDM1ZW6815MQM # VLC

# Media Creation
winget install --id 9N6X57ZGRW96 # Krita
winget install --id 9PD9BHGLFC7H # Inkscape

# Tools/Tweaks
winget install --id 9P7KNL5RWT25 # Sysintertnals Suite
winget install --id NirSoft.BlueScreenView -e --silent
winget install --id BleachBit.BleachBit -e --silent
winget install --id JAMSoftware.TreeSize.Free -e --silent

winget install --id Balena.Etcher -e --silent
winget install --id 9PC3H3V7Q9CH # Rufus
winget install --id PassmarkSoftware.OSFMount -e --silent

## Explorer Extensions
winget install --id CrystalRich.LockHunter -e --silent
winget install --id gurnec.HashCheckShellExtension -e --silent
winget install --id voidtools.Everything -e --silent

# FileSync
winget install --id Nextcloud.NextcloudDesktop -e --silent

# Remote
winget install --id AnyDeskSoftwareGmbH.AnyDesk -e --silent
winget install --id 9WZDNCRFJ3PS # Microsoft Remote Desktop
winget install --id WinSCP.WinSCP -e --silent

# CLI
winget install --id Microsoft.PowerShell -e --silent # Powershell Core 7
winget install --id 9n0dx20hk701 # WindowsTerminal
winget install --id GnuWin32.Wget -e --silent

# Networking
winget install --id Famatech.AdvancedIPScanner -e --silent
winget install --id qBittorrent.qBittorrent -e --silent

# DEV
winget install --id Git.Git -e --silent
winget install --id Atlassian.Sourcetree -e --silent
winget install --id SublimeHQ.SublimeText.4 -e --silent
winget install --id Microsoft.VisualStudioCode -e --silent
winget install --id ApacheFriends.Xampp -e --silent
winget install --id Notepad++.Notepad++ -e --silent

## SQL
winget install --id DBBrowserForSQLite.DBBrowserForSQLite -e --silent
winget install --id Microsoft.SQLServerManagementStudio -e --silent
winget install --id Microsoft.AzureDataStudio -e --silent
winget install --id 9NXPRT2T0ZJF # HeidiSQL
winget install --id 9NHTB9SQ51R1 # Antares SQL Gui

winget install --id OpenJS.NodeJS.LTS -e --silent
winget install --id AdoptOpenJDK.OpenJDK.8 -e --silent

# Hardware
winget install --id alcpu.CoreTemp -e --silent
winget install --id CPUID.CPU-Z -e --silent

## SSH Feature
# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
Add-WindowsCapability -Online -Name OpenSSH.Client
# Add-WindowsCapability -Online -Name OpenSSH.Server