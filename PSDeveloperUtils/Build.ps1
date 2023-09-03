[CmdletBinding()]
Param(
	[Parameter(Mandatory = $false)]
	[string]
	$Repository,
	[Parameter(Mandatory = $false)]
	[switch]
	$SkipTests
)
Import-Module PSDeveloperUtils

Build-Module -RootPath $PSScriptRoot -Repository:$Repository -SkipTests:$SkipTests