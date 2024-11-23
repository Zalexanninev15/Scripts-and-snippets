$s=@'
function Send-SocketCommand{[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$h,[Parameter(Mandatory=$true)][string]$c,[Parameter(Mandatory=$false)][string]$d,[Parameter(Mandatory=$false)][string]$s);try{$p=9028;$t=New-Object Net.Sockets.Socket([Net.Sockets.AddressFamily]::InterNetwork,[Net.Sockets.SocketType]::Stream,[Net.Sockets.ProtocolType]::Tcp);$t.Connect($h,$p);$r=@{Command=$c;Data=$d;Second=$s}|ConvertTo-Json;$b=[Text.Encoding]::UTF8.GetBytes($r);$t.Send($b)|Out-Null;$f=New-Object byte[] 1048576;$v=$t.Receive($f);$e=[Text.Encoding]::UTF8.GetString($f,0,$v);Write-Output $e}catch{Write-Error "Error: $_"}finally{if($t){$t.Close()}}}Set-Alias sc Send-SocketCommand
'@
iex $s
