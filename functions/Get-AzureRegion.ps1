<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-AzureRegion
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $resourceGroupLocation
    )

    Begin
    {
    }
    Process
    {
        if($resourceGroupLocation -like '*asia'){$azureRegion = 'Asia'}
        elseif($resourceGroupLocation -like 'canada*'){$azureRegion = 'Canada'}
        elseif($resourceGroupLocation -like 'australia*'){$azureRegion = 'Australia'}
        elseif($resourceGroupLocation -like 'brazil*'){$azureRegion = 'Brazil'}
        elseif($resourceGroupLocation -like 'japan*'){$azureRegion = 'Japan'}
        elseif($resourceGroupLocation -like '*us'){$azureRegion = 'US'}
        elseif($resourceGroupLocation -like '*europe'){$azureRegion = 'Europe'}
        elseif($resourceGroupLocation -like 'china*'){$azureRegion = 'China'}
        elseif($resourceGroupLocation -like '*india'){$azureRegion = 'India'}
        elseif($resourceGroupLocation -like 'canada*'){$azureRegion = 'Canada'}
    }
    End
    {
        $OutputObject = [PSCustomObject]@{
                        Region = $azureRegion
                        }
        Write-Output -InputObject $OutputObject
    }
}
