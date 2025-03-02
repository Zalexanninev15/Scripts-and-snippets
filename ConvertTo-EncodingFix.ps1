function ConvertTo-EncodingFix ([string]$From, [string]$To){
    Begin{
        $encFrom = [System.Text.Encoding]::GetEncoding($from)
        $encTo = [System.Text.Encoding]::GetEncoding($to)
    }
    Process{
        $bytes = $encTo.GetBytes($_)
        $bytes = [System.Text.Encoding]::Convert($encFrom, $encTo, $bytes)
        $encTo.GetString($bytes)
    }
}

# Как использовать: Invoke-Command -ScriptBlock { dism /? } -ComputerName testcomp | ConvertTo-EncodingFix -From cp866 -To windows-1251
