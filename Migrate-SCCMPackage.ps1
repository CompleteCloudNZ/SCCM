<#
This script reads in the packages from SCCM using the sitecode variable and then replaces part of the installed location string.
This is required when performing migrations from one server to another or possibly cross domain 
#>
Import-module "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" 

$OriginalSource = "\\sourcesccm"
$DestinationSource = "\\targetsccm"
$SiteCode = "ABC:"

Set-Location $SiteCode

$PackageArray = Get-CMPackage
#$PackageArray = Get-CMPackage |ft Name,PackageID,PkgSourcePath -AutoSize

foreach($Package in $PackageArray)
{
    $ChangePath = $Package.PkgSourcePath.Replace($OriginalSource, $DestinationSource) 
    Set-CMPackage -Name $Package.Name -Path $ChangePath 
    Write-Host $Package.Name ” has been changed to ” $ChangePath 
}

