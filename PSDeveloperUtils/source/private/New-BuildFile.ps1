Function New-BuildFile
{
	[CmdletBinding(SupportsShouldProcess=$true)]
	Param()
	
	$buildFile = "Build.ps1"

	#Create module
	$contents = '[CmdletBinding()]
Param(
	[Parameter(Mandatory = $false)]
	[string]
	$Repository,
	[Parameter(Mandatory = $false)]
	[switch]
	$SkipTests
)
Import-Module PSDeveloperUtils

Build-Module -RootPath $PSScriptRoot -Repository:$Repository -SkipTests:$SkipTests'

	If ($PSCmdlet.ShouldProcess($buildFile, "Create"))
	{
		$contents | Out-File $buildFile
		
		return $buildFile
	}
<#
.SYNOPSIS
Creates a standard build file

.DESCRIPTION
Creates a standard build file

.EXAMPLE
PS> New-BuildFile

#>
}
