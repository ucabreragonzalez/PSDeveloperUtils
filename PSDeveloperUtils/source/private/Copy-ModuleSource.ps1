Function Copy-ModuleSource
{
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param
	(
		# Path to the root of the module code
		[ValidateScript({
			if ( -Not ($_ | Test-Path) ) {
				throw [System.IO.DirectoryNotFoundException] "Path $RootPath not found."
			}
			if ( -Not ((Join-Path $_ "source") | Test-Path) ) {
				throw [System.IO.DirectoryNotFoundException] "'source' folder in Path $RootPath not found."
			}
			return $true
		})]
		[Parameter(Position = 0, Mandatory = $true)]
		[System.IO.DirectoryInfo]
		$RootPath
	)

	If ($PSCmdlet.ShouldProcess($RootPath, "Copy"))
	{
		try {
			$moduleName = (Get-Item $RootPath).Name
			$randomDestinationPath = (Join-Path (Get-RandomTempDirectory) $moduleName)

			# Empty contents of existing folder if there, then create a new empty folder
			Remove-Item -Path $randomDestinationPath -Recurse -Force -ErrorAction SilentlyContinue
			New-Item $randomDestinationPath -ItemType Directory | Out-Null

			# The * after source copies just the contents of the folder and excludes the container folder itself
			Copy-Item -Path (Join-Path $RootPath "source" "*") -Destination $randomDestinationPath -Recurse

			return $randomDestinationPath
		}
		catch {
			throw $_
		}
	}
<#
.SYNOPSIS
Copies the contents of the source folder of a module to a random temp folder, and return directory path.

.DESCRIPTION
Copies the contents of the source folder of a module to a random temp folder, and return directory path.

.EXAMPLE
Copy-ModuleSource -RootPath "/home/user/repository/PSDeveloperUtils"

#>
}
