<#
    .SYNOPSIS
    Gets the IP ranges associated with Azure regions in CIDR format.
    .DESCRIPTION
    The Get-MicrosoftAzureDatacenterIPRange cmdlet gets a list of subnets in CIDR format (eg 192.168.1.0/24). A specific region can be specified, otherwise this cmdlet will return all subnets from all regions.
        
    The cmdlet gets the information from the Microsoft Azure Datacenter IP Ranges file, this is updated weekly, and is available for download from: https://www.microsoft.com/en-us/download/details.aspx?id=41653.
            
    If a path to the above file is not specified, then this CMDLet will download the file and store it in memory. Note, it will only do this once per execution.
            
    If no region is specified, then all subnets for all regions will be returned.
    .EXAMPLE
    C:\PS> Get-MicrosoftAzureDatacenterIPRange -AzureRegion 'North Central US'
    Returns all of the subnets in the North Central US DC, will download the Microsoft Azure Datacenter IP Ranges file into memory
    .EXAMPLE
    C:\PS> Get-MicrosoftAzureDatacenterIPRange -Path C:\Temp\AzureRanges.xml -AzureRegion 'North Central US'
    Returns all of the subnets in the North Central US DC based on the specified file
    .EXAMPLE
    C:\PS> Get-MicrosoftAzureDatacenterIPRange
    Returns all of the subnets used by Azure, will download the Microsoft Azure Datacenter IP Ranges file into memory
    .INPUTS
    Can take Azure region names from the pipeline.
    .OUTPUTS
    Outputs objects containing each subnet and their region.
#>
function Assert-SecureResourceGroupPolicyLocation
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Azure Automation Account
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        $resourceGroupRegion
    )

    Begin
    {
        $secureResourceGroups  = Find-AzureRmResourceGroup -Tag @{ Name='policy-location'; Value='enabled' }
        $subscription = Get-AzureRmContext
        $subscriptionId = $subscription.Subscription.SubscriptionId
    }
    Process
    {
        foreach($resourceGroup in $secureResourceGroups){
            $resourceGroupName = $resourceGroup.name
            $resourceGroupRegion = ((Get-AzureRegion -resourceGroupLocation $resourceGroup.location).Region).ToLower()
            $policyName = 'resource-group-location' + '-' + $resourceGroupRegion
            $azureLocations = Get-AzureRmLocation | Where-Object {$_.Location -like "*$resourceGroupRegion*"}
            if((Get-AzureRmPolicyDefinition | Where-Object {$_.Name -eq $policyName}) -eq $null){
                $azureRegions = '"' + ($azureLocations.Location -join '" , "') + '"'
                $policyDefinition = @"
{  
    "if" : {
        "not" : {
            "field" : "location",
            "in" : [$azureRegions]
        }
    },
    "then" : {
        "effect" : "deny"
    }
}
"@
                $policy = New-AzureRmPolicyDefinition `
                    -Name $policyName `
                    -Description "Policy to allow resource creation only in $resourceGroupRegion" `
                    -Policy $policyDefinition          
            }
        }
    }
    End
    {
    }
}