Function New-PesterTestFile
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
		# The name of the function to create Pester tests for
		[Parameter(Position=0, Mandatory=$true)]
		[String]
		$Name,
		# Optional. The name of the module. If omitted, the function will try to work it out
		[Parameter(Position=1, Mandatory=$false)]
		[String]
		$ModuleName,
		# Optional. A path to create the new function in. If omitted, creates in the current directory.
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

    If ($PSCmdlet.ShouldProcess("$Name", "Creating test file"))
    {
		If ($Path) { Push-Location $Path }
		
		# Try to find the tests directory
		# Try to figure out the module name, if it's not set
		ForEach ($parentDir In @(".\", "..\", "..\..\")) {
			If (Test-Path -Path "$($parentDir)tests") {
				If (!$ModuleName) {$ModuleName = (Get-Item $parentDir).Name }
				
				Push-Location "$($parentDir)tests"
				$testDirSet = $true
				break
			}
		}

		$fileContent = "Describe ""$Name"" -Tag 'Unit' {
	InModuleScope $ModuleName {
		It ""Dummy test will fail - replace me"" {
			`$false | Should -BeTrue
		}
	}
}"

		$fileContent | Out-File "$Name.Tests.ps1"

		# Tidy up paths
		If ($testDirSet) { Pop-Location }
		If ($Path) { Pop-Location }
    }
<#
.SYNOPSIS
Create a new standard Pester test file

.DESCRIPTION
Create a new standard Pester test file
Will look for a folder called "tests" and create the test there

.EXAMPLE
PS> New-PesterTestFile myPSFunction

.EXAMPLE
PS> New-PesterTestFile -Name myPSFunction -ModuleName myPSModule -Path "./path/to/tests/or/module/dir"

.LINK
https://github.com/pester/Pester/

#>
}
