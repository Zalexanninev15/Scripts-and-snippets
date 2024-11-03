$url = Read-Host -Prompt 'input link'
$output = Read-Host -Prompt 'input destination(with file-name)'
$start_time = Get-Date

Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"