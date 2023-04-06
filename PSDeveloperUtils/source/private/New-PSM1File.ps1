Function New-PSM1File
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
		[Parameter(Position=0,Mandatory=$true)]
		[string]
		$Name
	)
	
	$psm1File = "$($Name).psm1"

	#Create module
	$psm1 = 'Push-Location $PSScriptRoot

#Dot source the functions into the current session
Get-ChildItem -Filter *.ps1 -Path public,private -Recurse | ForEach-Object { . $_.FullName }

#Export the functions in the Export folder
Get-ChildItem -Filter *.ps1 -Path public -Recurse | ForEach-Object { Export-ModuleMember $_.BaseName }

Pop-Location'

	If ($PSCmdlet.ShouldProcess($psm1File, "Create"))
	{
		$psm1 | Out-File $psm1File
		
		return $psm1File
    }
<#
.SYNOPSIS
Creates a standard PSM1 file

.DESCRIPTION
Creates a standard PSM1 file

.EXAMPLE
PS> New-PSM1File MyModule

#>
}
