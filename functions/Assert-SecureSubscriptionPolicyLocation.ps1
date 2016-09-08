<#

.SYNOPSIS
    Applies an ARM policy on a Resource Group to prevent deployment of resources in other geo-political regions.

.DESCRIPTION
    The Assert-SecureResourceGroupPolicyLocation cmdlet checks for the existence of an ARM policy which prevents deployment of resources outside the geopolitical region in which the Resource Group is located.

    For example, if the Resource Group is in Australia Southeast, a policy will be created which only allows resources within the Resource Group to be deployed to Australia Southeast and Australia East.

    The policy is only created if the Resource Group has a tag called 'policy-location' with a value of 'enabled'.

.EXAMPLE
    C:\PS> $resourceGroups = Find-AzureRmResourceGroup -Tag @{ Name='policy-location'; Value='enabled' } | Get-MicrosoftAzureDatacenterIPRange -resourceGroups $resourceGroups
    Finds all Resource Groups in the current subscription with the resource tag 'policy-location':'enabled', and assigns an ARM policy to prevent deployment of resources outside the Resource Group's geo-political region.

.INPUTS
    Can take Azure Resource Group properties from Find-AzureRmResourceGroup from the pipeline.

.OUTPUTS
    None.

#>

function Assert-SecureSubscriptionPolicyLocation
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Resource Group Name
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        $subscriptionName,

        # Resource Group Location
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        $azureRegion
    )

    Begin
    {
    }
    Process
    {
        $azureRegion = $azureRegion.toLower()
        $policyName = 'subscription-location' + '-' + $azureRegion
        $azureLocations = Get-AzureRmLocation | Where-Object {$_.Location -like "$azureRegion*" -or $_.Location -like "*$azureRegion"}
        if((Get-AzureRmPolicyDefinition | Where-Object {$_.Name -eq $policyName}) -eq $null){
            $azureRegions = ' "' + ($azureLocations.Location -join '" , "') + '" '
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
                -Description "Policy to allow resource creation only in $azureRegion" `
                -Policy $policyDefinition          
            $policyAssignmentName = $subscriptionName + '-' + $policyName
            $subscription = Get-AzureRmSubscription -SubscriptionName $subscriptionName
            $policyAssignment = Get-AzureRmPolicyAssignment | Where-Object {$_.Name -eq $policyAssignmentName}
            if($policyAssignment -eq $null){
                $subscriptionScope = '/subscriptions/' + $subscription.SubscriptionId
                $policyAssignment = New-AzureRmPolicyAssignment -Name $policyAssignmentName -PolicyDefinition $policy -Scope $subscriptionScope
            }
                
        }

    }
    End
    {
    }
}