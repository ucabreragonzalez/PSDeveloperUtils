Function Get-RandomTempDirectory
{
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param
	(
	)

	If ($PSCmdlet.ShouldProcess("-WhatIf target", "-WhatIf action"))
	{
		$parent = [System.IO.Path]::GetTempPath()
		$name = [System.Guid]::NewGuid()
		
		return (Join-Path $parent $name)
	}
<#
.SYNOPSIS
Returns random directory name located in system temp location

.DESCRIPTION
Returns random directory name located in system temp location

.EXAMPLE
Get-RandomTempDirectory

#>
}
