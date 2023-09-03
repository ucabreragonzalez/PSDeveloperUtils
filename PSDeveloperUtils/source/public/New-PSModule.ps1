Function New-PSModule
{
	[CmdletBinding(SupportsShouldProcess=$true)]
	Param
	(
		# The name of the module to be created
		[Parameter(Position=0, Mandatory=$true)]
		[String]
		$Name,
		# A description of what the functions within the Module do.
		[Parameter(Position=1, Mandatory=$true)]
		[String]
		$Description,
		# Optional. A path to create the new module structures in. If omitted, creates in the current directory.
		[ValidateScript({
			if( -Not ($_ | Test-Path) ){
				throw [System.IO.DirectoryNotFoundException] "$Path $($Path) not found."
			}
			return $true
		})]
		[Parameter(Position=2, Mandatory=$false)]
		[System.IO.DirectoryInfo]
		$Path
	)


	If ($Path) { Push-Location $Path }
	
	If ($PSCmdlet.ShouldProcess("Creating new project $($Name) in $(Get-Location)"))
	{
		#Create module folder
		New-Item $Name -ItemType Directory | Out-Null

		Push-Location $Name
		
		#Create build file
		New-BuildFile | Out-Null

		#Create standard directories
		New-Item "source" -ItemType Directory | Out-Null
		New-Item "tests\.gitkeep" -ItemType File -Force | Out-Null
		
		Push-Location .\source

		New-Item "classes\.gitkeep" -ItemType File -Force | Out-Null
		New-Item "private\.gitkeep" -ItemType File -Force | Out-Null
		New-Item "public\.gitkeep" -ItemType File -Force | Out-Null

		#Create module
		$psm1File = New-PSM1File $Name
		
		#Create module manifest
		$psd1File = "$($Name).psd1"
		
		$manifestParams = @{
			Path = $psd1File
			RootModule = $psm1File
			Description = $Description
		}
		
		New-ModuleManifest @manifestParams

		Pop-Location

		$module = @{ "Name" = $psm1File; "ModulePath" = (Get-Location); "Manifest" = $psd1File }
		
		Pop-Location
	}

	If ($Path) { Pop-Location }

	return $module
<#
.SYNOPSIS
Creates the standard structures for a new PS module

.DESCRIPTION
Creates the standard structures for a new PS module
Creates source directories, test directories and a build script

.EXAMPLE
PS> New-PSModule MyNewModule -Description "Test Description"

.EXAMPLE
PS> New-PSModule -Name MyNewModule -Path "./Path/To/Module" -Description "Test Description"

#>
}
