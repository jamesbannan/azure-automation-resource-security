<#

.SYNOPSIS
    Creates security groups in Azure Active Directory for selected Resource Groups and assigns Azure RBAC roles.

.DESCRIPTION
    The Assert-SecureResourceGroupRbac cmdlet checks for the existence of a Security Group in Azure Active Directory for each RBAC role.

    For example, a Resource Group called 'myGroup' will have three groups created: 'myGroup-Owners', 'myGroup-Contributors', 'myGroup-Reader', and the relevant RBAC role will be assigned to each group.

    The policy is only created if the Resource Group has a tag called 'secure-rbac' with a value of 'enabled'.

.EXAMPLE
    C:\PS> $resourceGroups = Find-AzureRmResourceGroup -Tag @{ Name='secure-rbac'; Value='enabled' } | Assert-SecureResourceGroupRbac -resourceGroups $resourceGroups
    Finds all Resource Groups in the current subscription with the resource tag 'secure-rbac':'enabled', creates Security Groups in Azure Active Directory and assigns the relevant RBAC role.

.INPUTS
    Can take Azure Resource Group properties from Find-AzureRmResourceGroup from the pipeline.

.OUTPUTS
    None.

#>

function Assert-SecureResourceGroupRbac
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Azure Automation Account
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        $resourceGroups,

        # Azure Active Directory Account
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        $subscriptionId
    )

    Begin
    {
        $roleTypes = @('Owner','Contributor','Reader')

    }
    Process
    {
        foreach($resourceGroup in $resourceGroups){
            $resourceGroupName = $resourceGroup.name
            foreach($role in $roleTypes){
                $adGroupName = $resourceGroupName + '-' + $role
                $adGroup = Get-MsolGroup -SearchString $adGroupName
                if($adGroup -eq $null){
                    $description = 'Automatically created by Azure Automation at '+ (((Get-Date).ToUniversalTime()).ToString('yyMMdd-HHmm'))
                    $adGroup = New-MsolGroup -DisplayName $adGroupName -Description $description -Verbose
                    while((Get-MsolGroup -SearchString $adGroupName) -eq $null){
                        Write-Host 'Checking for successful deployment of Azure AD group.'
                        }
                    }
                    else{
                        Write-Host 'Azure Active Directory group' $adGroupName 'exists.'
                    }
                $roleAssignment = Get-AzureRmRoleAssignment -ObjectId $adGroup.ObjectId.Guid -ErrorAction SilentlyContinue
                if($roleAssignment -eq $null){
                    while($roleAssignment -eq $null){
                        $roleAssignment = New-AzureRmRoleAssignment -ObjectId $adGroup.ObjectId.Guid -RoleDefinitionName $role -Scope "/subscriptions/$subscriptionId/resourcegroups/$resourceGroupName" -Verbose -ErrorAction SilentlyContinue
                        }
                    $roleAssignment
                    }
                    else{
                        Write-Host 'ARM Role Assignment exists for group' $adGroupName 'on Resource Group' $resourceGroupName 'in subscription' $subscription.Subscription.SubscriptionName
                    }
            }
        }
    }
    End
    {
    }
}
