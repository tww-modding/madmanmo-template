[CmdletBinding()]
param
(
	[string]$version
)

$ErrorActionPreference = "Stop";
$VerbosePreference = "Continue";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

$modFilePath = "$rootDirectoryPath\mod.json";
$mod = ConvertFrom-Json ([System.IO.File]::ReadAllText($modFilePath));

$file = "$rootDirectoryPath\build\$version\$($mod.name)-$version.pack";

& "$rootDirectoryPath\tools\pfm-4.1.2\PackFileManager.exe" $file
