$ErrorActionPreference = "Stop";
$VerbosePreference = "Continue";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

$modFilePath = "$rootDirectoryPath\mod.json";
$mod = ConvertFrom-Json ([System.IO.File]::ReadAllText($modFilePath));

$version = "$($mod.version.breaking).$($mod.version.patch).$($mod.version.build)"
$name = $mod.name;

Write-Verbose "Building [$name] version [$version]"

$buildFolder = "$rootDirectoryPath\build\$version";
$file = "$buildFolder\$name-$version.pack";

if (-not (Test-Path $buildFolder))
{
	$result = New-Item -ItemType Directory -Path $buildFolder;
}
$pack = Copy-Item -Path "$rootDirectoryPath\build\template.pack" -Destination $file -Force

& "$rootDirectoryPath\tools\pfm-4.1.2\PackFileManager.exe" $file