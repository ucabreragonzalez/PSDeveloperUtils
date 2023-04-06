Function New-BuildFile
{
	[CmdletBinding(SupportsShouldProcess=$true)]
	Param()
	
	$buildFile = "Build.ps1"

	#Create module
	$contents = '[CmdletBinding()]
Param(
	[Parameter(Mandatory = $false)]
	[switch]
	$Deploy,
	[Parameter(Mandatory = $false)]
	[switch]
	$SkipTests
)
## Do some magic!!...
## Well for now you need to write something in here'

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
