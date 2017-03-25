$ErrorActionPreference = "Stop";
$VerbosePreference = "Continue";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

& "$here\update.ps1";

$modFilePath = "$rootDirectoryPath\mod.json";
$mod = ConvertFrom-Json ([System.IO.File]::ReadAllText($modFilePath));

$version = "$($mod.version.breaking).$($mod.version.patch).$($mod.version.build)"
$name = $mod.name;

Write-Verbose "Building [$name] version [$version]"

$buildFolder = "$rootDirectoryPath\build\$version";
$packFilePath = "$buildFolder\$name-$version.pack";
$imageFilePath = "$buildFolder\$name-$version.png";

if (-not (Test-Path $buildFolder))
{
	$result = New-Item -ItemType Directory -Path $buildFolder;
}
$pack = Copy-Item -Path "$rootDirectoryPath\build\template.pack" -Destination $packFilePath -Force
$image = Copy-Item -Path"$rootDirectoryPath\src\images\mod.png" -Destination $imageFilePath -Force

& "$rootDirectoryPath\tools\pfm-4.1.2\PackFileManager.exe" $packFilePath

$answer = Read-Host -Prompt "Finalise build? This will commit everything to source control and tag with the version (y/n)";
if ($answer -eq "y")
{
	& git add -A;
	& git commit -m "Changes for automated build [$version]";
	& git tag $version;
}