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

$version = "$($mod.version.breaking).$($mod.version.patch).$($mod.version.build)"
$name = $mod.name;

$modFile = "$name-$version.pack";
$modFilePath = "$rootDirectoryPath\build\$version\$modFile";
$destinationPath = "C:\Program Files (x86)\Steam\SteamApps\common\Total War WARHAMMER\data\$modFile";

Write-Verbose "Copying Mod [$modFile] from [$modFilePath] to [$destinationPath]";
$result = Copy-Item -Path $modFilePath -Destination $destinationPath -Force