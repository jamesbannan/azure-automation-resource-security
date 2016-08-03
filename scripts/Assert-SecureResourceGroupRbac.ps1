<#PSScriptInfo

.VERSION 0.1

.GUID 789edb15-d900-4197-9f93-a1afd5a4e8e9

.AUTHOR James Bannan

.COMPANYNAME 

.COPYRIGHT 

.TAGS Azure Automation,RBAC,Azure Resource Manager,Azure Active Directory

.LICENSEURI https://github.com/jamesbannan/azure-automation-resource-security/blob/master/LICENSE

.PROJECTURI https://github.com/jamesbannan/azure-automation-resource-security

.ICONURI 

.EXTERNALMODULEDEPENDENCIES MsOnline,AzureRM.Resources

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

<# 

.DESCRIPTION 
 This script creates Owner, Contributor and Reader groups for each Azure Resource Group with a secure-rbac:enabled tag, and creates an RBAC role assignment for each group. 

#> 

Param(
    [CmdletBinding()]
    # Azure Automation Account
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    $AutomationAccount,
    # Azure Active Directory Account
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true)]
    $AzureADAccount
    )

function Assert-SecureResourceGroupRbac
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
    )

    Begin
    {
    }
    Process
    {
        foreach($resourceGroup in $secureResourceGroups){
            $resourceGroupName = $resourceGroup.name
            foreach($role in $roleTypes){
                $adGroupName = $resourceGroupName + '-' + $role
                $adGroup = Get-MsolGroup -SearchString $adGroupName
                if($adGroup -eq $null){
                    $description = 'Automatically created by Azure Automation at '+ (((Get-Date).ToUniversalTime()).ToString('yyMMdd-HHmm'))
                    $adGroup = New-MsolGroup -DisplayName $adGroupName -Description  -Verbose
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

### Authenticate to ARM and Azure AD ###

$credARM = Get-AutomationPSCredential -Name $AutomationAccount
$credAAD = Get-AutomationPSCredential -Name $AzureADAccount
Import-Module MsOnline
Add-AzureRmAccount -Credential $credARM -Verbose
Connect-MsolService -Credential $credAAD -Verbose

### Retrieve Resource Groups based on tag values

$secureResourceGroups  = Find-AzureRmResourceGroup -Tag @{ Name='secure-rbac'; Value='enabled' }
$roleTypes = @('Owner','Contributor','Reader')
$subscription = Get-AzureRmContext
$subscriptionId = $subscription.Subscription.SubscriptionId

Assert-SecureResourceGroupRbac