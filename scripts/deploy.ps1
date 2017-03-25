[CmdletBinding()]
param
(
	[string]$version
)

$ErrorActionPreference = "Stop";
$VerbosePreference = "Continue";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

$modFilePath = "$rootDirectoryPath\build\$version\packed";
$destinationPath = "C:\Program Files (x86)\Steam\SteamApps\common\Total War WARHAMMER\data\$modFile";

Write-Verbose "Deploying From [$modFilePath] to [$destinationPath]";
$result = Copy-Item -Path $modFilePath -Destination $destinationPath -Force