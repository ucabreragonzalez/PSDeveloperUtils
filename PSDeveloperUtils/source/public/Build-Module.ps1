Function Build-Module
{
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param
	(
		# Path to the root of the module code
		[ValidateScript({
			if ( -Not ($_ | Test-Path) ) {
				throw [System.IO.DirectoryNotFoundException] "Path $RootPath not found."
			}
			return $true
		})]
		[Parameter(Position = 0, Mandatory = $true)]
		[System.IO.DirectoryInfo]
		$RootPath,
		# Optional. If set, the built module will try publish to specified repository name
		# For now it supports only local repository on a folder
		[Parameter(Mandatory = $false)]
		[string]
		$Repository,
		# Optional switch. If set, Pester tests will not be executed
		[Parameter(Mandatory = $false)]
		[switch]
		$SkipTests
	)

	$moduleName = (Get-Item $RootPath).Name
	If (!$moduleName) {
		throw 'Could not identify the module name'
	}

	If ($PSCmdlet.ShouldProcess($moduleName, "Building module"))
	{
		try {
			# Copy source of module to a temp folder
			$tempModulePath = Copy-ModuleSource -RootPath $RootPath

			if (-not $SkipTests) {
				Remove-Module -Name $moduleName -ErrorAction SilentlyContinue
				Import-Module Pester
				# Import temp version
				Import-Module $tempModulePath -Force

				Push-Location $RootPath
				$pesterResults = Invoke-Pester -PassThru
				Pop-Location
			}
			
			if ([string]::IsNullOrEmpty($Repository)){
				# if no need to publish, then we are done.
				return
			}

			if ($pesterResults.Result -eq "Failed") {
				Write-Host "Test Failed: Module was not published." -ForegroundColor DarkRed
				return
			}

			# will try to find out max version in repository and increase if needed.
			$repoModule = Find-Module $moduleName -Repository $Repository -ErrorAction SilentlyContinue
			if ($repoModule) {
				$oldVersion = [Version]::new($repoModule.Version)
				$newVersion = [Version]::new($oldVersion.Major, $oldVersion.Minor, $oldVersion.Build, ($oldVersion.Revision + 1))
			} else {
				$newVersion = [Version]::new(0, 0, 1, 1)
			}

			$Params = @{
				Path = (Join-Path $tempModulePath "$moduleName.psd1")
				ModuleVersion = $newVersion
			}
			
			Update-ModuleManifest @Params

			# Now will try to publish
			Publish-Module -Path $tempModulePath -Repository $Repository
			Write-Host "$moduleName Module version $($newVersion.ToString()) published to $Repository." -ForegroundColor Cyan
		}
		catch {
			throw $_
		}
	}
<#
.SYNOPSIS
Build module in a temp directory, run its test cases and publish it to an existing repository

.DESCRIPTION
Build module in a temp directory, run its test cases and publish it to an existing repository
If the PublishToRepositoryName parameter is set, the module will not be copied to the PS modules directory, but will be imported in place.
If the SkipTests switch is set, the Pester tests are not executed.

.EXAMPLE

#>
}
