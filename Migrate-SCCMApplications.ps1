<#

This script reads in the applications from SCCM using the sitecode variable and then replaces part of the installed location string.
This is required when performing migrations from one server to another or possibly cross domain 

#>

Import-module "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" 

$SiteCode = "ABC:"
Set-Location $SiteCode

$OriginalSource = "\\sourcesccm"
$DestinationSource = "\\targetsccm"

$ApplicationName = Get-CMApplication 
$ApplicationName = $ApplicationName.LocalizedDisplayName

foreach($application in $ApplicationName) 
{ 
    $DeploymentTypeName = Get-CMDeploymentType -ApplicationName $x 

    ForEach($DT in $DeploymentTypeName) 
    { 
        ## Change the directory path to the new location 
        $DTSDMPackageXLM = $DT.SDMPackageXML 
        $DTSDMPackageXLM = [XML]$DTSDMPackageXLM 
    
        ## Get Path for Apps with multiple DTs 
        $DTCleanPath = $DTSDMPackageXLM.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location[0] 
    
        ## Get Path for Apps with single DT 
        IF($DTCleanPath -eq “\”) 
        { 
            $DTCleanPath = $DTSDMPackageXLM.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location 
        } 
    
        $DirectoryPath = $DTCleanPath -replace [regex]::Escape($OriginalSource), “$DestinationSource”

        ## Modify DT path - ensure "$application" remains in quotes to combat space problems
        Set-CMDeploymentType –ApplicationName "$application” –DeploymentTypeName $DT.LocalizedDisplayName –MsiOrScriptInstaller –ContentLocation “$DirectoryPath” 

    } 
}
