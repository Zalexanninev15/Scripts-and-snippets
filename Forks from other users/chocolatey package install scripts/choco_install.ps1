# allow running: Set-ExecutionPolicy Bypass -Scope Process -Force

# src: https://gist.github.com/apfelchips/792f7708d0adff7785004e9855794bc0
# goal: install all basic tools / pin software with working autoupdate mechanism / specialized stuff is commented out

# misc: Windows Store .appx downloader https://store.rg-adguard.net/

# Check Permissions
if ( -Not( (New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) ){
    Write-Error -Message "Script needs Administrator permissions"
    exit 1
}

if (-Not (Get-Command "choco" -errorAction SilentlyContinue)) {
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

choco feature enable -n=allowGlobalConfirmation

## https://chocolatey.org/packages

choco install chocolateygui

## need >=1803
choco install powertoys
choco pin add -n=powertoys

## Browsers
choco install firefox
choco pin add -n=firefox
choco install brave
choco pin add -n=brave
# choco install chromium

#choco install rambox # AIO Chat Client / PWA Container
#choco pin add -n=rambox

choco install 7zip
choco install libreoffice-fresh
choco install everything --params "'/run-on-system-startup'" # fast filename seacrch
choco install agentransack # file content search

## Crypto Tools
choco install keepassxc
# choco install yubikey-manager
# choco install yubikey-piv-manager # Yubikey Smartcard features
# choco install yubico-authenticator # Read OTP Tokens
# choco install openssl.light
# choco install gpg4win # GPG GUI Tools
# choco install gnupg
# choco install xca # Key/Cert Management GUI
# choco install keystore-explorer.portable # JAVA Cert Management GUI

## PDF Tools
# choco install foxitreader --ia '/MERGETASKS="!desktopicon,!setdefaultreader,!displayinbrowser" /COMPONENTS=*pdfviewer,*ffse,*installprint,*ffaddin,*ffspellcheck,!connectedpdf"'
choco install sumatrapdf --params "'/NoDesktop /WithPreview'"
## choco install okular # (outdated use Microsoft Store version: https://www.microsoft.com/store/productId/9N41MSQ1WNM8)
# Adobe Acrobat DC Reader (64bit) https://get.adobe.com/reader/otherversions/

choco install pdf24 --params "'/Basic'"

## Media Tools
# choco install mpv
choco install vlc
# choco install audacity
# choco install mp3tag
# choco install mediainfo
# choco install exiftool

choco install lossless-cut
choco install audacity
choco install audacity-ffmpeg

# choco install meGui # ffmpeg, etc. GUI
# choco install handbrake # video encoder GUI

# choco install irfanview
# choco install irfanviewplugins
# choco install irfanview-shellextension

# choco install sharex # screenshot utility
# choco install carnac # display shortcuts for screencasts
choco install paint.net
# choco install dispcalgui # Color Calibration
# choco install gimp
# choco install krita
# choco install rawtherapee # FLOSS Lightroom
# choco install XnConvert # Bulk image converter
# choco install XnViewMP # fast image viewer / manager
# choco install ghostscript # needed for PDF preview

choco install inkscape # SVG editor
#choco install drawio
#choco install yed # Diagramm Creator

## Networking Utilities
choco install advanced-ip-scanner
# choco install angryip # !!! autoinstalls oracle jre
#choco install snmpb # SNMP GUI Browser

# choco install acrylic-dns-proxy
# choco pin -n=acrylic-dns-proxy # updates require manual uninstall

# choco install zerotier-one # mesh VPN
# choco install ngrok # Tunnel Service

## Remote Management Software
#choco install teamviewer
choco install anydesk
#choco install mRemoteNG
#choco install royalts
#choco install vnc-viewer # RealVNC viewer
# choco install rcdman # (discontinued https://www.zdnet.com/article/microsoft-discontinues-rdcman-app-following-security-bug/)

## SQL / SCP
# choco install sql-server-management-studio
# choco install heidisql
# choco install dbbeaver
# choco install sqlitebrowser
choco install winscp

## Editors / IDEs / Fonts
choco install notepadplusplus
choco install notepadreplacer --params "'/NOTEPAD:C:\Program Files\Notepad++\notepad++.exe'"

#choco install sublimetext4
#choco pin add -n=sublimetext4
#choco install vscode
#choco pin add -n=vscode # use internal updater
# choco install vim --ia='/NoDesktopShortcuts /NoContextmenu'
# choco install linqpad # .NET Scratchpad
choco install winmerge
# choco install beyondcompare
# choco install zeal

#choco install sourcecodepro # coding font
#choco install meslolg.dz # apple's menlo like font

## Sysinternals / Monitoring / File Analysis
# complete Sysinterals install is too noisy use WSSC instead
choco install procexp
choco install autoruns
choco install pstools
# choco install dbgview
# choco install sysmon # advanced logging / auditing service https://github.com/SwiftOnSecurity/sysmon-config#use

# choco install glogg # logviewer

# choco install cpu-z
# choco install hwmonitor
# choco install gpu-z
# choco install pci-z

# choco install lessmsi # msi inspector
# choco install universal-extractor2 # depricated use https://github.com/Bioruebe/UniExtract2/releases
# choco install hxd # basic hex editor
# choco install free-hex-editor-neo # advanced hex editor
# choco install sandboxie # sandbox environment

## Cleanup
choco install bleachbit
choco install treesizefree
#choco install dupeguru # duplicate finder gui
#choco install revo-uninstaller

## Runtimes / Languages
# choco install doxygen
# choco install pyenv-win # python version manager - breaks wsl when in PATH --> bash\r

# choco install openjdk # current version from java.net
# choco install openjdk8 # from AdoptOpenJDK
# choco install autohotkey
# choco install golang
# choco install php

# choco install nodejs-lts
# choco install yarn
# choco install adb # Standalone Android Debug Bridge

## Windows / .net / c# Development
# choco install dotnetcore-sdk
# choco install powershell-core --ia='ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=0'
# choco install nuget.commandlines
# choco install nugetpackageexplorer

## CLI Tools
# choco install ConEmu
# choco install far # cli file editor / explorer

choco install git.install --params "'/GitOnlyOnPath /NoShellIntegration /NoShellHereIntegration /NoGuiHereIntegration /NoAutoCrlf'"
# choco install lazygit
choco install bind-toolsonly # dig, nslookup, etc.

# choco install Sudo # VBscript Shim
choco install gsudo # .net app

# choco install ln
choco install less
choco install mdcat # cli markdown viewer
# choco install jdupes
# choco install ag # the_silver_searcher sourcecode search (faster ack)
# choco install fzf
# choco install jq
choco install curl
choco install tree # use with tree.exe != builtin tree.com
# choco install rsync # cwrsync https://itefix.net/content/how-can-i-secure-connections-between-windows-rsync-clients-and-cwrsync-servers
# choco install lftp # make sure to delete ssh.exe/sh.exe/bash.exe shims https://nwgat.ninja/lftp-for-windows/
# choco install tcping
choco install wget
# choco install aria2
# choco install ffmpeg
# choco install youtube-dl
choco install exiftool

#### WSL
# choco install lxrunoffline

## Explorer Shell Extensions
choco install ecm # Easy Context Menu
# choco install defaultprogramseditor

# choco install tortoisegit
# choco install sourcetree
# choco install gitextensions # lightweigth git GUI

choco install lockhunter
choco install linkshellextension
choco install hashcheck
# choco install puretext # automatically remove text formating
# choco install teracopy

choco install caffeine # keep screen on

## FS / Imaging Tools
choco install veeam-agent # Automated Image Backup Tool
# choco install partitionwizard
# choco install imgburn

# choco install win32diskimager
# choco install disk2vhd
# choco install osfmount

# choco install etcher
# choco install rufus

# choco install recuva
# choco install testdisk-photorec

## VM / Containers
# choco install virtualbox /ExtensionPack
# choco install vagrant

# choco install docker-cli
# choco install docker-machine
# choco install kubernetes-cli
# choco install minikube # Run Kubernetes locally

##SSH Server
## (depricated use windows features instead) choco install openssh --params='"/SSHServerFeature"'
# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
Add-WindowsCapability -Online -Name OpenSSH.Client
# Add-WindowsCapability -Online -Name OpenSSH.Server

## Windows FLOSS LDAP client
## choco install pgina

## FileSync
#choco install synctrayzor
#choco pin add -n=synctrayzor

choco install nextcloud-client
choco pin add -n=nextcloud-client

#choco install chocolatey-misc-helpers.extension
##auto upgrade https://chocolatey.org/packages/choco-upgrade-all-at
#choco install choco-upgrade-all-at --params "'/DAILY:yes /TIME:03:00 /ABORTTIME:07:00'"
