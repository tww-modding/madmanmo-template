$ErrorActionPreference = "Stop";
$VerbosePreference = "Continue";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

& "$rootDirectoryPath\src\assembly_kit\binaries\TWeak.AssemblyKit.exe" /standalone totalwardatabase