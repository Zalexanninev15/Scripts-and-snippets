# I created a new script when doing coursework (it helps a lot when forming examples and calculating values in several types)
 
 function Evaluate-ExpressionInParentheses {
    param (
        [string]$expression
    )
    $regex = "\(([^()]+)\)"
    
    while ($expression -match $regex) {
        $subExpression = $matches[1]
        $result = [scriptblock]::Create(" $subExpression ") | Invoke-Expression
        $expression = $expression -replace "\($([regex]::Escape($subExpression))\)", $result
    }
    
    return $expression
}


$expression = Read-Host "Enter a mathematical expression with parentheses"
$finalExpression = Evaluate-ExpressionInParentheses -expression $expression

Write-Output "Processed view: $finalExpression+10"

$totalResult = [scriptblock]::Create(" $finalExpression+10 ") | Invoke-Expression
Write-Output "Total length: $totalResult (+ 10м)"

Read-Host "Press Enter to exit..."
