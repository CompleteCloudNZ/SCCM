Import-module "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" 

$siteCode = "SMS:"
Set-Location $siteCode

$boundaries = Import-Csv C:\Scripts\subnets-groups.csv

<# the csv looks like:

Network,Location,Description,Group
10.204.32.0/23,Auckland,Head Office,Auckland
10.204.34.0/23,Auckland,Pop-up Store,Auckland
10.204.40.0/26,Tauranga,Regional Distribution,BOP

#>

$boundaryarray = @()

foreach($boundary in $boundaries)
{

    $IPAddress = ($boundary.Network -split ("/"))[0]

    $Object = New-Object PSObject -Property @{            
        IPAddress       = $IPAddress               
        Location      = $boundary.Location
        Description      = $boundary.Location+" "+$boundary.Network
        Network =   $boundary.Network
        BoundaryGroup = $boundary.Group
    }               
    $boundaryarray += $Object
}

$groups = $boundaries |Select-Object Group -Unique

foreach($boundarygroup in $groups.Group)
{
    New-CMBoundaryGroup -Name $boundarygroup
}


foreach($cmboundary in $boundaryarray)
{
    New-CMBoundary -Type IPSubnet -Value $cmboundary.Network -Name $cmboundary.Description 
    Add-CMBoundaryToGroup -BoundaryGroupID  (Get-CMBoundaryGroup -Name $cmboundary.BoundaryGroup).GroupID -BoundaryName $cmboundary.Description 
}

