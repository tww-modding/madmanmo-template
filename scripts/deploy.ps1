[CmdletBinding()]
param
(
	[string]$version
)

$ErrorActionPreference = "Stop";
$VerbosePreference = "Continue";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

$sourcePath = "$rootDirectoryPath\build\$version\packed";
$destinationPath = "C:\Program Files (x86)\Steam\SteamApps\common\Total War WARHAMMER\data";

Write-Verbose "Deploying From [$modFilePath] to [$destinationPath]";
robocopy $sourcePath $destinationPath;