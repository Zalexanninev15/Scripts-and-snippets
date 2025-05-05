$ErrorActionPreference = "Stop"

$rootFolder = Resolve-Path -Path "."
$oldName = "Sample.Foo"
$newName = "Sample.Bar"

# Rename files and folders
foreach ($item in Get-ChildItem -LiteralPath $rootFolder -Recurse | Sort-Object -Property FullName -Descending) {
    $itemNewName = $item.Name.Replace($oldName, $newName)
    if ($item.Name -ne $itemNewName) {
        Rename-Item -LiteralPath $item.FullName -NewName $itemNewName
    }
}

# Replace content in files
foreach ($item in Get-ChildItem -LiteralPath $rootFolder -Recurse -Include "*.cmd", "*.cs", "*.csproj", "*.json", "*.md", "*.proj", "*.props", "*.ps1", "*.sln", "*.slnx", "*.targets", "*.txt", "*.vb", "*.vbproj", "*.xaml", "*.xml", "*.xproj", "*.yml", "*.yaml") {
    $content = Get-Content -LiteralPath $item.FullName
    if ($content) {
        $newContent = $content.Replace($oldName, $newName)
        Set-Content -LiteralPath $item.FullName -Value $newContent
    }
}
