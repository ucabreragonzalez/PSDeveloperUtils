Push-Location $PSScriptRoot

#Dot source the functions into the current session
Get-ChildItem -Filter *.ps1 -Path public,private -Recurse | ForEach-Object { . $_.FullName }

#Export the functions in the Export folder
Get-ChildItem -Filter *.ps1 -Path public -Recurse | ForEach-Object { Export-ModuleMember $_.BaseName }

Pop-Location