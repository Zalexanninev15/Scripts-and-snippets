function Send-SocketCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerIp,
        
        [Parameter(Mandatory=$true)]
        [string]$Command,
        
        [Parameter(Mandatory=$false)]
        [string]$Data,
        
        [Parameter(Mandatory=$false)]
        [string]$Second
    )

    $port = 9028
    
    try {
        $socket = New-Object System.Net.Sockets.Socket(
            [System.Net.Sockets.AddressFamily]::InterNetwork,
            [System.Net.Sockets.SocketType]::Stream,
            [System.Net.Sockets.ProtocolType]::Tcp
        )

        $socket.Connect($ServerIp, $port)

        $requestData = @{
            Command = $Command
            Data = $Data
            Second = $Second
        } | ConvertTo-Json

        $requestBytes = [System.Text.Encoding]::UTF8.GetBytes($requestData)
        $socket.Send($requestBytes) | Out-Null

        $buffer = New-Object byte[] 1048576
        $received = $socket.Receive($buffer)
        
        $response = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $received)
        Write-Output $response
    }
    catch {
        Write-Error "Ошибка подключения: $_"
    }
    finally {
        if ($socket) {
            $socket.Close()
        }
    }
}

# Пример использования
# Send-SocketCommand -ServerIp "192.168.1.100" -Command "echo" -Data "Привет" -Second "Мир"
