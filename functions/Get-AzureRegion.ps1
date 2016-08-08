<#

.SYNOPSIS
    Returns the geo-political region of an Azure datacenter.

.DESCRIPTION
    The Get-AzureRegion cmdlet returns the geo-political region of an Azure datacenter.

.EXAMPLE
    C:\PS> Get-AzureRegion -location 'australiasoutheast'

.EXAMPLE
    C:\PS> Get-AzureRegion -displayName 'Australia Southeast'

.EXAMPLE
    C:\PS> $resourceGroup = Get-AzureRmResourceGroup -Name 'myGroup' | Get-AzureRegion -location $resourceGroup.location

.INPUTS
    Can take Azure datacenter locations from the pipeline, in both short form (e.g. 'australiasoutheast') and DisplayName format (e.g. 'Australia Southeast').

.OUTPUTS
    Main geo-political region of the specified datacenter (e.g. 'Australia').

#>
function Get-AzureRegion
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Azure Automation Account
        [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        $location,
        # Azure Automation Account
        [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        $displayName
    )

    Begin
    {
    }
    Process
    {
        if($location -like '*asia' -or $displayName -like '*Asia'){$azureRegion = 'Asia'}
        elseif($location -like 'canada*' -or $displayName -like 'Canada*'){$azureRegion = 'Canada'}
        elseif($location -like 'australia*' -or $displayName -like 'Australia*'){$azureRegion = 'Australia'}
        elseif($location -like 'brazil*' -or $displayName -like 'Brazil*'){$azureRegion = 'Brazil'}
        elseif($location -like 'japan*' -or $displayName -like 'Japan*'){$azureRegion = 'Japan'}
        elseif($location -like '*us' -or $displayName -like '*US'){$azureRegion = 'US'}
        elseif($location -like '*europe' -or $displayName -like '*Europe'){$azureRegion = 'Europe'}
        elseif($location -like 'china*' -or $displayName -like 'China*'){$azureRegion = 'China'}
        elseif($location -like '*india' -or $displayName -like '*India'){$azureRegion = 'India'}
    }
    End
    {
        $OutputObject = [PSCustomObject]@{
                        Region = $azureRegion
                        }
        Write-Output -InputObject $OutputObject
    }
}
