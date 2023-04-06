Function New-PSFunction
{
	[CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='default')]
	Param
	(
		# The name of the function to be created
		[Parameter(Position=0, Mandatory=$true)]
		[String]
		$Name,
		# The synopsis of the function's purpose. Will be added to the help comment
		[Parameter(Position=1, Mandatory=$true)]
		[String]
		$Synopsis,
		# Optional. A path to create the new function in. If omitted, creates in the current directory.
		[ValidateScript({
			if( -Not ($_ | Test-Path) ){
				throw [System.IO.DirectoryNotFoundException] "$Path $($Path) not found."
			}
			return $true
		})]
		[Parameter(Position=2, Mandatory=$false)]
		[System.IO.DirectoryInfo]
		$Path,
		# Optional. If set, the function will attempt to create the file in a "public" or a "source\public" directory in either the current/path directory.
		[Parameter(Mandatory=$false, ParameterSetName='Public')]
		[switch]
		$Public,
		# Optional. If set, the function will attempt to create the file in a "private" or a "source\private" directory in either the current/path directory.
		[Parameter(Mandatory=$false, ParameterSetName='Private')]
		[switch]
		$Private,
		# Optional. If set, no Pester test file will be created.
		[Parameter(Mandatory=$false)]
		[switch]
		$SkipTests
	)
	
	Begin {
		If ($Path) { Push-Location $Path }

		# Handle Public / Private swtiches
		New-Variable -Name 'subDir'

		If ($Public) { $subDir = "public" }
		ElseIf ($Private) { $subDir = "private" }

		If ($subDir) {
			If (Test-Path -Path $subDir) {
				Push-Location $subDir
				$subDirSet = $true
			}
			ElseIf (Test-Path -Path "source\$subDir") {
				Push-Location "source\$subDir"
				$subDirSet = $true
			}
		}


		$functionText = "Function $Name
{
	[CmdletBinding(SupportsShouldProcess = `$true)]
	Param
	(
		# Inline parameter help comment
		[Parameter(Position = 0, Mandatory = `$true)]
		[String]
		`$Param1
	)

	If (`$PSCmdlet.ShouldProcess(`"-WhatIf target`", `"-WhatIf action`"))
	{

	}
<#
.SYNOPSIS
$Synopsis

.DESCRIPTION

.PARAMETER Name

.INPUTS

.OUTPUTS

.EXAMPLE

.LINK

#>
}"

		$functionFile = Join-Path (Get-Location) "$Name.ps1"
	}
	Process {
		If ($PSCmdlet.ShouldProcess("Creating new function $Name in $(Get-Location)")) {
			$functionText | Out-File $functionFile
			
			# Create Pester tests, unless flag is set
			If (!$SkipTests) { New-PesterTestFile -Name $Name }
		}
	}
	End {
		# Tidy up paths
		If ($subDirSet) { Pop-Location }
		If ($Path) { Pop-Location }

		return [System.IO.FileInfo]$functionFile
	}
	
<#
.SYNOPSIS
Creates a standard template for a new PS function

.DESCRIPTION
Creates a standard template for a new PS function.
Supports an optional path parameter, as well as the ability to create within public or private directories within that directory

.EXAMPLE
PS> New-PSFunction My-Function "A function to do stuff"

.EXAMPLE
PS> New-PSFunction -Name My-PublicFunction -Synopsis "A function to do stuff" -Path ".\MyModule" -Public

.EXAMPLE
PS> New-PSFunction -Name My-PrivateFunction -Synopsis "A function to do stuff" -Path ".\MyModule" -Private

#>
}
