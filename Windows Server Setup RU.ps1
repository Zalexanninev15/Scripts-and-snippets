# Самое необходимое
# https://softcomputers.org/blog/nastroika-windows-server-2022/
# https://softcomputers.org/blog/nastroika-windows-server-2019/
# Инструкция по активации удаленных рабочих столов RDP: https://softcomputers.org/blog/licenzirovanye-ydalennyh-rabochih-stolov/
# Создаём структуру OU в Active Directory с помощью PowerShell: https://winitpro.ru/index.php/2021/11/15/sozdat-strukturu-ou-v-active-directory-powershell/
# https://winitpro.ru/index.php/category/windows-server-2019/
# https://winitpro.ru/index.php/2021/03/09/bazovye-komandy-nastrojki-windows-server-core/
# Настройка зон A и AAAA: https://ispserver.ru/help/nastroyka-sobstvennogo-servera-imen-windows-server

# http://www.itsamples.com/downloads/network-activity-indicator-64.zip

# Настройка удалённого доступа:
# https://docs.vultr.com/how-to-set-up-a-vpn-on-windows-server-2019-using-remote-access

# nslookup -type=AAAA 192.168.0.1

# В DHCP резервирование:
# 002, 004, 042
# Параметры сервера:
# 004
# на клиентской машине: net time /set /y

# Localhost: localhost, 192.168.0.?, 127.0.0.1, ::1 (ipv6), 0.0.0.0

# Групповые политики через реестр: https://gpsearch.azurewebsites.net

# https://habr.com/ru/articles/560652/
# https://winitpro.ru/index.php/2017/11/21/ustanovka-i-aktivaciya-rds-license-na-windows-server-2016/
# Среди ролей находим Файловые службы и службы хранилища , раскрываем ее и проверяем, что установлены галочки напротив следующих компонентов:
# Службы хранения;
# Файловый сервер;
# Set-SmbServerConfiguration -Smb2CreditsMin 128 
# Set-SmbServerConfiguration -Smb2CreditsMax 2048
# Set-SmbServerConfiguration -AsynchronousCredits 64    
# Set-SmbServerConfiguration -CachedOpenLimit 5    
# Set-SmbServerConfiguration -DurableHandleV2TimeoutInSeconds 30    
# Set-SmbServerConfiguration -AutoDisconnectTimeout 0    
# Set-SmbServerConfiguration -DurableHandleV2TimeoutInSeconds 30
# Set-SmbServerConfiguration -CachedOpenLimit 5
# (gwmi win32_terminalservicesetting -N "root\cimv2\terminalservices").enabledfss
# если 1, то:
# Set-Itemproperty -Path Registry::"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Quota System\" -name EnableCpuQuota -Value 0
# Set-Itemproperty -Path Registry::"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TSFairShare\Disk\" -name EnableFairShare -Value 0
# fsutil 8dot3name set 1
# Restart-Computer
# sc config srv start= demand
# вместо этого юзаем: sc config mrxsmb20 start= demand
# Restart-Computer

# Общий доступ:
# $folderPath = "C:\SharedFolder"
# Только пользователю:
# $user = "Domain\User"
# New-SmbShare -Name "SharedFolder" -Path $folderPath -FullAccess $user
# Для всех:
# New-SmbShare -Name "SharedFolder" -Path $folderPath -FullAccess Everyone


# # # Конфигурация компьютера -> Политики -> Административные шаблоны -> Система -> Вход в систему

# # # 2. Блокировка доступа к реестру для непривилегированных пользователей

# # # Конфигурация компьютера -> Политики -> Административные шаблоны -> Компоненты Windows -> Политики автозапуска
# # # 3. Блокировка автозапуска USB

# # # Рабочий стол в админ. шаб. в конф. польз.
# # # 4. Скрыть Управление в Корзине

# # # Рабочий стол в админ. шаб. в конф. польз.
# # # 5. Скрыть команду Управление из контекстного меню проводника

# # # Рабочий стол в админ. шаб. в конф. польз.
# # # 6. Отключение пунктов Управление и Свойства в контекстном меню проводника

# # # Рабочий стол в админ. шаб. в конф. польз.
# # # 7. Скрыть Компьютер

# # # Рабочий стол в админ. шаб. в конф. польз.
# # # 8. Скрыть корзину

$Global:SystemConfig = @{
    AdminName = "Администратор"
    AdminPassword = "1"
    DomainName = ""
    DomainNetBIOSName = ""
    DomainPassword = ""
    NetworkConfig = @{
        IPAddress = "192.168.0.1"
        SubnetMask = "255.255.255.0"
        Gateway = "192.168.0.1"
        PrimaryDNS = "192.168.0.1"
        AlternativeDNS = ""
    }
    DHCPScope = @{
        StartRange = ""
        EndRange = ""
    }
    GroupPolicies = @{
        gp1 = $false
        gp2 = $false
        gp3 = $false
        gp4 = $false
        gp5 = $false
        gp6 = $false
        gp7 = $false
        gp8 = $false
    }
}

# Меню
function Show-MainMenu {
    Clear-Host
    try { 
        $Global:SystemConfig.DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
    }
    catch {
        $Global:SystemConfig.DomainName = "не задан"
    }
    # Другой способ: $Global:SystemConfig.DomainName = (Get-ADDomainController -Discover).Domain
    Write-Host "Домен: $($Global:SystemConfig.DomainName)"
    Write-Host "======= Настройка системы =======" -ForegroundColor Cyan
    Write-Host "U. Отключение проверки сложности паролей"
    Write-Host "0. Установка компонентов, Админка, переименование компьютера [restart]"
	Write-Host "S. Sconfig"
   # Write-Host "1. Настройка сетевого адптера"
    Write-Host "1. Настройка Active Directory (Домен)"
    Write-Host "H. Настройка DHCP"
    Write-Host "2. Создание пользователей (папка Users)"
    Write-Host "3. Создать подразделения (OU)"
    Write-Host "4. Создать компьютеры"
	Write-Host "N. Internet Explorer (IIS)"
    # Write-Host "5. Групповые политики (не доделано)"
    Write-Host "5. Чтобы показать в Сети (Службы)"
    Write-Host "6. Установить остальные компоненты"
    Write-Host "T. Резервирование Windows 10 (DHCP) и Сервер времени (NTP) [?]"
    Write-Host "7. Перезагрузка системы"
    Write-Host "8. Только смена времени"
    Write-Host "Q. Выход"
}

function Disable-Password-Check {
# secpol.msc
Clear-Host
Write-Host "===== Отключение проверки сложности паролей =====" -ForegroundColor Green
    $securityPolicy = [System.IO.Path]::Combine($env:windir, "security\policy.cfg")
$policyContent = @"
[Version]
signature="`$CHICAGO`$"
Revision=1
[System Access]
PasswordComplexity = 0
MinimumPasswordLength = 1
"@
    $policyContent | Out-File -FilePath $securityPolicy -Encoding ASCII
    secedit /configure /db secedit.sdb /cfg $securityPolicy /quiet
    Write-Host "Политики сложности паролей отключены" -ForegroundColor Yellow
    Pause
}

function Show-in-Network {
    Clear-Host
    Write-Host "===== Показать в Сети (Службы) =====" -ForegroundColor Green
    $services = @(
    "Dnscache",          # DNS-клиент
    "SSDPSRV",           # SSDP
    "upnphost",          # Узел PNP
    "FDResPub"           # Публикация ресурсов обнаружения функций
)

    foreach ($service in $services) {
        try{
            Set-Service -Name $service -StartupType Automatic
            Start-Service -Name $service
            Write-Host $service
        }
        catch { Write-Host "Служба $($service) уже готова!" }
    }

    Write-Host "Службы настроены!" -ForegroundColor Green

    Pause
}

function Install-Others {
    Clear-Host
    Write-Host "===== Установка остальных компонентов =====" -ForegroundColor Green
    Install-WindowsFeature -Name Web-IP-Security,Web-ODBC-Logging,Web-Scripting-Tools,Web-Mgmt-Compat,Web-Metabase,Web-Lgcy-Mgmt-Console,AD-Certificate,ADCS-Cert-Authority,Remote-Desktop-Services,RDS-Licensing,RemoteAccess,DirectAccess-VPN,CMAK,SMTP-Server,Windows-Internal-Database,RSAT-Feature-Tools,RSAT-SMTP,RSAT-RDS-Tools,RDS-Licensing-UI,RSAT-ADCS,RDS-Licensing,RSAT-ADCS-Mgmt,RSAT-RemoteAccess,RSAT-RemoteAccess-Mgmt,RSAT-RemoteAccess-PowerShell -IncludeManagementTools
    Write-Host "Остальные компоненты установлены!" -ForegroundColor Green
    Pause
}

function Sconfig {
	Start-Process sconfig
	}

function Create-Admin {
    Clear-Host
    Write-Host "===== Создание администратора =====" -ForegroundColor Green
    cmd /c "chcp 65001 && net user Администратор /active:yes && net user Администратор mek-@29ty7"
    $securityPolicy = [System.IO.Path]::Combine($env:windir, "security\policy.cfg")
$policyContent = @"
[Version]
signature="`$CHICAGO`$"
Revision=1
[System Access]
PasswordComplexity = 0
MinimumPasswordLength = 1
"@
    $policyContent | Out-File -FilePath $securityPolicy -Encoding ASCII
    secedit /configure /db secedit.sdb /cfg $securityPolicy /quiet

	cmd /c "chcp 65001 && net accounts /minpwlen:1 && net user Администратор /active:yes && net user Администратор 1 && start lusrmgr.msc"
	
    #New-LocalUser `
        # -Name $username `
        # -Password $password `
        # -FullName $username `
        # -Description "Главная учетная запись администратора" `
        # -PasswordNeverExpires:$true | Out-Null
    
    Write-Host "Политики сложности паролей отключены" -ForegroundColor Yellow
    Write-Host "Создан администратор: Администратор" -ForegroundColor Green
    Write-Host "Пароль: 1" -ForegroundColor Green
    Pause
    shutdown /l
}

function Prepare-System {
    Clear-Host
    Write-Host "===== Предварительная настройка =====" -ForegroundColor Green
    Write-Host "Установка компонентов..." -ForegroundColor Yellow
    Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP, Web-Server, Web-Ftp-Server -IncludeManagementTools
    Write-Host "Компоненты установлены: AD, DNS, DHCP, IIS, FTP" -ForegroundColor Green
    $WshShell = New-Object -ComObject WScript.Shell
    $Desktop = [System.Environment]::GetFolderPath('Desktop')
    $Shortcut = $WshShell.CreateShortcut("$Desktop\Админка.lnk")
    $Shortcut.TargetPath = "$env:windir\system32\control.exe"
    $Shortcut.Arguments = "/name Microsoft.AdministrativeTools"
    $Shortcut.IconLocation = "$env:windir\system32\imageres.dll,1"
    $Shortcut.Save()
    Write-Host "Ярлык админки создан!" -ForegroundColor Green
    $pcname = Read-Host "Введите имя компьютера (Сервер)"
    Rename-Computer -NewName $pcname –Restart -Force
    Pause
}

function Time-Cfg {
    Clear-Host
    Write-Host "===== Резервирование DHCP / Сервер времени =====" -ForegroundColor Green
    $macPC = Read-Host "Введите MAC-адрес Windows 10 / 192.168.0.2"
    Add-DhcpServerv4Reservation -ScopeId 192.168.0.0 -IPAddress 192.168.0.2 -ClientId $macPC
    Read-Host "Резервирование завершено, нажмите Enter и настройте сервер времени, либо Ctrl+C"
    $timeSettingsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Config" -Name "AnnounceFlags" -Value 5 
    Set-ItemProperty -Path $timeSettingsPath -Name "NtpServer" -Value "0.pool.ntp.org,0x1 1.pool.ntp.org,0x1 2.pool.ntp.org,0x1"
    Set-ItemProperty -Path $timeSettingsPath -Name "TimeServer" -Value "192.168.0.1"
    Set-ItemProperty -Path $timeSettingsPath -Name "Type" -Value "NTP"
    Set-ItemProperty -Path $timeSettingsPath -Name "MaxPosPhaseCorrect" -Value 3600 -Type DWord
    Write-Host "Ожидайте завершения..."
    Restart-Service w32Time
    cmd /c "chcp 65001 && w32tm /resync /force"
    Write-Host "Настройте другое время!"
    Start-Process timedate.cpl
    pause
    cmd /c "chcp 65001 && w32tm /resync /force"
    cmd /c "chcp 65001 && net time /set /y"
    Write-Host "На Windows 10 введите: net time /set /y"
    Write-Host "Сервер времени настроен!" -ForegroundColor Green
    pause
}

function Change-Time {
    Clear-Host
    Write-Host "===== Смена времени =====" -ForegroundColor Green
    Start-Process timedate.cpl
    pause
    #& w32tm /resync /force
    cmd /c "chcp 65001 && net time /set /y"
    Write-Host "На Windows 10 введите: net time /set /y"
    pause
}

# Функции настройки
function Configure-Network {
    Clear-Host
    Write-Host "===== Настройка сети =====" -ForegroundColor Green
	$InterfaceIndex = (Get-NetIPConfiguration | Where-Object { $_.InterfaceAlias -eq "Ethernet0" }).InterfaceIndex
	New-NetIPaddress -InterfaceIndex $InterfaceIndex -IPAddress $Global:SystemConfig.NetworkConfig.IPAddress -PrefixLength 24 -DefaultGateway $Global:SystemConfig.NetworkConfig.Gateway
	Set-DNSClientServerAddress –InterfaceIndex $InterfaceIndex -ServerAddresses $Global:SystemConfig.NetworkConfig.PrimaryDNS
    # $adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
    
    # foreach ($adapter in $adapters) {
        # Удаление существующих IP
        # Get-NetIPAddress -InterfaceAlias $adapter.Name | Remove-NetIPAddress -Confirm:$false
        
        # Установка нового статического IP
        # New-NetIPAddress `
            # -InterfaceAlias $adapter.Name `
            # -IPAddress $Global:SystemConfig.NetworkConfig.IPAddress `
            # -PrefixLength 24 `
            # -DefaultGateway $Global:SystemConfig.NetworkConfig.Gateway | Out-Null
        
        # Настройка DNS
        # Set-DnsClientServerAddress `
            # -InterfaceAlias $adapter.Name `
            # -ServerAddresses $Global:SystemConfig.NetworkConfig.PrimaryDNS,$Global:SystemConfig.NetworkConfig.AlternativeDNS | Out-Null
        
        # Write-Host "Настроен сетевой интерфейс: $($adapter.Name)" -ForegroundColor Cyan
    # }
    

    # Var 2
	# $CloneName = "Eth0"
	
	# # Получение текущего единственного интернет-адаптера
	# $CurrentAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
	# if (-not $CurrentAdapter) {
		# Write-Host "Активный адаптер не найден!" -ForegroundColor Red
		# exit 1
	# }
	
	# # Проверить, существует ли уже клон
	# $CloneAdapter = Get-NetAdapter -Name $CloneName -ErrorAction SilentlyContinue
	# if ($CloneAdapter) {
		# # Если клон существует, сделать текущий адаптер основным
		# Write-Host "Клон $CloneName уже существует. Удаляю старый клон..." -ForegroundColor Yellow
		# Set-NetIPInterface -InterfaceAlias $CurrentAdapter.Name -InterfaceMetric 10
		# Remove-NetIPAddress -InterfaceAlias $CloneName -Confirm:$false -ErrorAction SilentlyContinue
		# Remove-NetAdapter -Name $CloneName -Confirm:$false
	# }
	
	# # Создание нового клона
	# Write-Host "Создаю новый адаптер $CloneName..." -ForegroundColor Green
	# New-NetIPAddress -InterfaceAlias $CurrentAdapter.Name -IPAddress $Global:SystemConfig.NetworkConfig.IPAddress -PrefixLength 24 -DefaultGateway $Global:SystemConfig.NetworkConfig.Gateway
	# Rename-NetAdapter -Name $CurrentAdapter.Name -NewName $CloneName
	
	# # Настройка IP, шлюза и DNS
	# Write-Host "Настраиваю параметры IP и DNS..." -ForegroundColor Green
	# Set-NetIPAddress -InterfaceAlias $CloneName -IPAddress $Global:SystemConfig.NetworkConfig.IPAddress -PrefixLength (32 - [math]::Log([double]([convert]::ToInt32($Global:SystemConfig.NetworkConfig.SubnetMask.Split(".")[0], 10) + 256), 2))
	# Set-DnsClientServerAddress -InterfaceAlias $CloneName -ServerAddresses $Global:SystemConfig.NetworkConfig.PrimaryDNS, $Global:SystemConfig.NetworkConfig.AlternativeDNS
	
	# # Сделать новый адаптер основным
	# Write-Host "Делаю $CloneName основным адаптером..." -ForegroundColor Green
	# Set-NetIPInterface -InterfaceAlias $CloneName -InterfaceMetric 1
		
    # Write-Host "Настройки сети сохранены (Eth0)" -ForegroundColor Green
    msg * "IPv4: 192.168.0.1 - везде | маска 255.255.255.0"
    Start-Process ncpa.cpl
    Pause
}

function Configure-ActiveDirectory {
    Clear-Host
    Write-Host "===== Настройка Active Directory (Домен) =====" -ForegroundColor Green
    Write-Host "Создание нового домена"
    $Global:SystemConfig.DomainName = Read-Host "Введите полное имя домена (например, mashina.com)"
	$Global:SystemConfig.DomainPassword = Read-Host "Введите пароль имя домена (например, Pass123)"
    # $Global:SystemConfig.DomainNetBIOSName = Read-Host "Введите NetBIOS имя домена (например, MASHINA)"
    $Global:SystemConfig.DomainNetBIOSName = $Global:SystemConfig.DomainName.Split('.')[0].ToUpper()
	Install-ADDSForest -DomainName $Global:SystemConfig.DomainName -DomainNetbiosName $Global:SystemConfig.DomainNetBIOSName -SafeModeAdministratorPassword (ConvertTo-SecureString $Global:SystemConfig.DomainPassword -AsPlainText -Force) -Force
    Write-Host "Настройки Active Directory сохранены!" -ForegroundColor Green
	Add-Computer -DomainName $Global:SystemConfig.DomainName -Restart
    Pause
}

function Configure-DHCP {
    Clear-Host

    Write-Host "===== Настройка DHCP =====" -ForegroundColor Green
    Write-Host "Добавить ещё - дипазон + 1"
    Write-Host "Добавить только - дипазон"
    $Global:SystemConfig.DHCPScope.StartRange = Read-Host "Начальный IP диапазона (например, 192.168.0.1)"
    $Global:SystemConfig.DHCPScope.EndRange = Read-Host "Конечный IP диапазона (например, 192.168.0.40)"

    #Add-DhcpServerSecurityGroup
    #$domainUserUpper = $Global:SystemConfig.DomainName.Split('.')[0].ToUpper()
    #Set-DhcpServerDnsCredential -Credential $domainUserUpper\Администратор
    #Set-DhcpServerv4OptionValue -DnsDomain [System.Net.Dns]::GetHostByName($env:computerName).HostName -DnsServer 192.168.0.1 -Router 192.168.0.1
    #Add-DhcpServerv4Scope -Name LAB -StartRange $Global:SystemConfig.DHCPScope.StartRange -EndRange $Global:SystemConfig.DHCPScope.EndRange -SubnetMask 255.255.255.0 -ComputerName $env:COMPUTERNAME -LeaseDuration 8.00:00:00 -State Active
    #Add-DhcpServerv4ExclusionRange -ScopeID 192.168.0.0 -StartRange 192.168.0.1 -EndRange 192.168.0.1
    #Restart-Service DHCPServer

    Write-Output "Обнаружение сетевых настроек..."
    $server = $env:ComputerName
    $domain = $env:UserDnsDomain
    $domainName = $env:UserDomain
    $serverDomain = $server + "." + $domain
    $ipv4 = (Get-NetIPAddress -AddressFamily IPv4 | select *)
    $ipA = $ipv4[0].IPAddress
    $ipNet = $ipv4.IPAddress[0].Split(".")
    $ipNet = $ipNet[0] + "." + $ipNet[1] + "." + $ipNet[2] + ".0"
    $ipRouter = ((Get-NetIPConfiguration -InterfaceIndex ($ipv4[0].ifIndex) ).IPv4DefaultGateWay).NextHop
    $dhcp = Get-WindowsFeature | where { $_.Name -match "DHCP" }
    Write-Output "Установка DHCP компонентов..."
    Add-WindowsFeature $dhcp -IncludeManagementTools
    $dhcpStart = $Global:SystemConfig.DHCPScope.StartRange
    $dhcpEnd = $Global:SystemConfig.DHCPScope.EndRange
    $scopeName = "$domainName DHCP"
    Write-Output "Настройка DHCP..."
    Add-DhcpServerInDC -DnsName $serverDomain -IPAddress $ipA
    Add-DhcpServerv4Scope -Name $scopeName -StartRange $dhcpStart -EndRange $dhcpEnd -SubnetMask "255.255.255.0"
    $scopeID = (Get-DHCPServerv4Scope).ScopeID
    $dhcpEclStart = "192.168.0.1"
    $dhcpEclEnd = "192.168.0.1"
    Add-DhcpServerv4ExclusionRange -ScopeId $scopeID -StartRange $dhcpEclStart -EndRange $dhcpEclEnd
    Set-DHCPServerv4OptionValue -ComputerName $serverDomain -dnsServer $ipA -dnsDomain $domain -Router $ipRouter
    Set-DhcpServerv4DnsSetting -ComputerName $serverDomain -DynamicUpdates Always -DeleteDnsRROnLeaseExpiry $true
    $username = $env:USERNAME
    $username = "$domainName\$userName"
    $pwd = Read-Host -AsSecureString -Prompt "Введите пароль для $username"
    $cred = New-Object System.Management.Automation.PSCredential($username,$pwd)
    Set-DHCPServerDNSCredential $cred
    Set-DHCPServerSetting -ConflictDetectionAttempts 2
    Restart-Service DHCPServer
    Write-Host "DHCP настроен!" -ForegroundColor Green
    Pause
}

function User-Management {
    Clear-Host
    Import-Module ActiveDirectory
    Write-Host "===== Создание пользователей =====" -ForegroundColor Green
    $domainParts = $Global:SystemConfig.DomainName.Split('.')
    $SecurePassword = ConvertTo-SecureString "Pass123!@#" -AsPlainText -Force
    # разные пароли у каждого:
    # Add-Type -AssemblyName System.Web
    # $SecurePassword = ConvertTo-SecureString [System.Web.Security.Membership]::GeneratePassword(5,1) -AsPlainText -Force
    # Можно посмотреть что разные: $SecurePassword | ConvertFrom-SecureString
    # Test CN: Get-ADObject -Filter {Name -eq "Users"} -Properties DistinguishedName
    # OU
    $usersNum = [int](Read-Host "Введите количество пользователей")
    for ($i = 1; $i -le $usersNum; $i++) {
        $userName = "user$($i)"
        $ouPath = "OU=Users,DC=$($domainParts[0]),DC=$($domainParts[1])"

        New-ADUser -Name $userName `
                   -GivenName $userName `
                   -Surname $userName `
                   -SamAccountName "username_$($userName)" `
                   -UserPrincipalName "username_$($userName)@$($Global:SystemConfig.DomainName)" `
                   -AccountPassword $SecurePassword `
                   -Enabled $true `
                   -Path "CN=Users,DC=$($domainParts[0]),DC=$($domainParts[1])" `
                   -PassThru | Enable-ADAccount
        Write-Host $userName
    }
    Write-Host "Создано $($usersNum) пользователя! Пароли: Pass123!@#" -ForegroundColor Green
    Start-Process dsa.msc
    Pause
}

function Create-OrganizationalUnits {
    Clear-Host
    Import-Module ActiveDirectory
    Write-Host "===== Создание подразделений =====" -ForegroundColor Green
    $domainParts = $Global:SystemConfig.DomainName.Split('.')
    $orgsNum = [int](Read-Host "Введите количество подразделений")
    #do {
    #    $ouName = Read-Host "Введите имя подразделения (или 'done' для завершения)"
    #    if ($ouName -ne 'done') {
    #        $Global:SystemConfig.OrganizationalUnits += $ouName
    #    }
    #} while ($ouName -ne 'done')
    for ($i = 1; $i -le $orgsNum; $i++) {
        $unitName = "Подразделение $($i)"
        New-ADOrganizationalUnit -Name $unitName -Path "DC=$($domainParts[0]),DC=$($domainParts[1])"

        # Убрать флаг защиты от удаления
        Get-ADobject -Identity "OU=$($unitName),DC=$($domainParts[0]),DC=$($domainParts[1])" | Set-ADObject -ProtectedFromAccidentalDeletion $false –verbose

        Write-Host $unitName
    }
    Write-Host "Подразделения созданы!" -ForegroundColor Green
    Start-Process dsa.msc
    Pause
}

function Create-PC {
    Clear-Host
    Import-Module ActiveDirectory
    Write-Host "===== Создание компьютеров =====" -ForegroundColor Green
    $domainParts = $Global:SystemConfig.DomainName.Split('.')
    $pcsNum = [int](Read-Host "Введите количество компьютеров")
    #do {
    #    $ouName = Read-Host "Введите имя подразделения (или 'done' для завершения)"
    #    if ($ouName -ne 'done') {
    #        $Global:SystemConfig.OrganizationalUnits += $ouName
    #    }
    #} while ($ouName -ne 'done')
    for ($i = 1; $i -le $pcsNum; $i++) {
        $computerName = "PC$($i)"
        New-ADComputer -Name $computerName -Path "CN=Computers,DC=$($domainParts[0]),DC=$($domainParts[1])" -Enabled $true

        # Доп. настройки
        #New-ADComputer `
        #-Name "Workstation01" `
        #-SamAccountName "Workstation01" `
        #-Path "OU=Workstations,DC=example,DC=com" `
        #-Description "Workstation for finance department" `
        #-DNSHostName "workstation01.example.com" `
        #-Enabled $true

        Write-Host $computerName
    }
    Write-Host "Компьютеры созданы!" -ForegroundColor Green
    Start-Process dsa.msc
    Pause
}

function Open-IE {
    Clear-Host
    try
    {
	    $ie = New-Object -ComObject InternetExplorer.Application -Strict
	    $ie.Navigate("http://localhost")
	    $ie.Visible = 1
    }
    catch 
    {
        Start-Process iexplorer.exe
    }

}

# function Configure-GroupPolicies {
    # Clear-Host
    # Write-Host "===== Настройка групповых политик =====" -ForegroundColor Green
    
	# Write-Host "1. Отключение анимации при первом входе пользователей в систему"
    # write-host "2. Блокировка доступа к реестру для непривилегированных пользователей"
    # write-host "3. Блокировка автозапуска USB"
    # write-host "4. Скрыть Управление в Корзине"
    # write-host "5. Скрыть команду Управление из контекстного меню проводника (ярлык Этот компьютер на рабочем столе)"
    # write-host "6. Отключение пунктов Управление (то же что и 5 пункте) и Свойства (когда открываешь этот компьютер будет такой пункт для перехода в свойства системы) в контекстном меню проводника"
    # write-host "7. Скрыть Компьютер на рабочем столе"
    # write-host "8. Скрыть корзину на рабочем столе"

    # $choice = Read-Host "Выберите политики (через запятую)"
    
    # $Global:SystemConfig.GroupPolicies.gp1 = $choice -contains "1"
    # $Global:SystemConfig.GroupPolicies.gp2 = $choice -contains "2"
    # $Global:SystemConfig.GroupPolicies.gp3 = $choice -contains "3"
    # $Global:SystemConfig.GroupPolicies.gp4 = $choice -contains "4"
    # $Global:SystemConfig.GroupPolicies.gp5 = $choice -contains "5"
    # $Global:SystemConfig.GroupPolicies.gp6 = $choice -contains "6"
    # $Global:SystemConfig.GroupPolicies.gp7 = $choice -contains "7"
    # $Global:SystemConfig.GroupPolicies.gp8 = $choice -contains "8"
   
    # Import-Module GroupPolicy
    # $gpoName = "Ограничения"
    # $gpo = New-GPO -Name $gpoName -Domain $Global:SystemConfig.DomainName

    # # Отключение анимации при первом входе
    # Set-GPRegistryValue -Name $gpoName -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableFirstLogonAnimation" -Type DWord -Value 0

    # # 2. Блокировка доступа к реестру
    # Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "DisableRegistryTools" -Type DWord -Value 1

    # # 3. Блокировка автозапуска USB
    # Set-GPRegistryValue -Name $gpoName -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoAutorun" -Type DWord -Value 1
    # Set-GPRegistryValue -Name $gpoName -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoDriveTypeAutoRun" -Type DWord -Value 255

    # # 4. Скрыть Управление в Корзине
    # Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoPropertiesRecycleBin" -Type Dword -Value 0

    # # 5-6. Отключение Управление и Свойства в контекстном меню
    # #Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "DisableAdminPage" -Type DWord -Value 1
    # #Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoPropertiesMyComputer" -Type DWord -Value 1

    # # 7. Скрыть Компьютер на рабочем столе
     # Set-GPORegistrySetting -Name $gpoName -Ke "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -ValueName "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type Dword -Value 1

    # # 8. Скрыть корзину на рабочем столе
    # Set-GPORegistrySetting -Name $gpoName -Ke "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -ValueName "{645FF040-5081-101B-9F08-00AA002F954E}" -Type Dword -Value 1
   
    # $ou = "OU=Clients,DC=$($Global:SystemConfig.DomainName.Split('.')[0]),DC=$($Global:SystemConfig.DomainName.Split('.')[1])"
    # New-GPLink -Name $gpoName -Target $ou
    # gpupdate /force
    # Write-Host "Групповая политика настроена только для клиентских компьютеров" -ForegroundColor Green
    # Pause
# }

# Главный цикл меню
function Start-Menu {
    do {
        Show-MainMenu
        $choice = Read-Host "Выберите действие"
        
        switch ($choice.ToString().ToLower()) {
            "U" { Disable-Password-Check }
            "T" { Time-Cfg }
            "0" { Prepare-System }
			"S" { Sconfig }
            #"1" { Configure-Network }
            "1" { Configure-ActiveDirectory }
            "H" { Configure-DHCP }
            #"D" { Configure-DNS }
            "2" { User-Management }
            "3" { Create-OrganizationalUnits }
            "4" { Create-PC }
			"N" { Open-IE }
            # "5" { Configure-GroupPolicies }
            "5" { Show-in-Network }
            "6" { Install-Others }
            "7" { Restart-Computer -Force }
            "8" { Change-Time }
            "Q" { return }
        }
    } while ($true)
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
	$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
	if ($currentUserName.Contains('\')) {
			$displayName = $currentUserName.Split('\')[-1]
	}
	else {
			$displayName = $currentUserName
	}
	$isAdminUser = $displayName -match '^(Admin|Админ)'
	if ($isAdminUser) {
		Start-Menu
	}
	else {
			Create-Admin
	}
} else {
    Write-Output "PowerShell не запущен с правами администратора."
}
