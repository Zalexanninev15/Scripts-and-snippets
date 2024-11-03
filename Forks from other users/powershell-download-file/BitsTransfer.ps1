$url = Read-Host -Prompt 'input link'
$output = Read-Host -Prompt 'input destination(with file-name)'
$start_time = Get-Date

Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $output

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"