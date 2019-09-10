<#PSScriptInfo

.VERSION 2.3

.GUID 0fc48522-2362-4cc0-b46d-e1d88d87b4e2

.AUTHOR jbritt@microsoft.com

.COMPANYNAME Microsoft

.COPYRIGHT Microsoft

.TAGS 

.LICENSEURI 

.PROJECTURI 
   https://aka.ms/ManageARMBlueprints/Video

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
   May 23, 2019 - version 2.3
   * Added BlueprintTarget to the parameters to allow for supporting subscription for Blueprint Location on
     import and export. Thank you https://github.com/mrptsai (Paul Towler) for your inputs to add this option! 
   * Added new API version https://github.com/JimGBritt/AzureBlueprint/commit/c3304315745676912e7a958e40fa91b5da0d005e (thank you https://github.com/drmiru Michael Rueefli!)
   * Added enhanced error output https://github.com/JimGBritt/AzureBlueprint/commit/94658c99a7b8207937492bb5a71285a094b6c11e#diff-e7e495ba10b61589a1c555132692367f (thank you https://github.com/Oechiih Jan Oehen!)
   * Updated -ModuleMode to be Az by default (time to move on :)).
   * Added option to bypass subscription requirement and provide TenantID (https://github.com/JimGBritt/AzureBlueprint/issues/2)
     Thank you https://github.com/GPugnet (Guillaume Pugnet) your your feedback on bypassing the SubId requirement
#>


<#  
.SYNOPSIS  
  Import, Export, or Report for an Azure Blueprint and related artifacts into or out of an Azure AD Management Group.
  
.DESCRIPTION  
  To learn how to use this script, please watch this video: https://aka.ms/ManageARMBlueprints/Video 

  This script takes a SubscriptionID, ManagementGroupID, BlueprintName, Mode switch, and an optional 
  NewBluePrintName as a parameter.  This script is meant to provide the ability to export an Azure
  ARM Blueprint for backup or import into an other Management Group.  You can also report on what artifacts are configured
  for a specific blueprint using the report mode.

  Use of "-Force" provides the ability to launch this script without prompting, if all required parameters are provided.

  NOTE: This version currently only supports exporting a latest full published version or current draft of a blueprint and
  related artifacts.

  ADDITIONAL NOTE: This script currently also does not export custom policies.

.PARAMETER ModuleMode
    The module (AzureRM or Az) used to authenticate to Azure to be leveraged with the script execution

.PARAMETER SubscriptionId
    The subscriptionID of the Azure Subscription that is within the Azure AD tenant with your Blueprint or where
    you will be targeting for import of your Blueprint

.PARAMETER ManagementGroupID
    Use this to reference a Management Group to export a named Blueprint and artifacts

.PARAMETER NewBluePrintName
    Use this to update the Blueprint name on a selected Blueprint to a new name on import / export.

.PARAMETER BlueprintName
    Use this to bypass searching for a Blueprint during the script on export

.PARAMETER Mode
    Indicates mode of operation (Import/Export/Report) for a Blueprint

.PARAMETER ExportDir
    This is the base folder for exporting the Azure Blueprint data.  Example "Exports" or .\Exports or "c:\exports"

.PARAMETER ImportDir
    This is the base folder for importing a Blueprint and artifacts into an Azure AD Management Group. The folder would
    look something like ".\Exports\MG-Root\MyBlueprint" or "c:\exports\MG-Root\MyBlueprint"
 
 .PARAMETER Force
    Use Force to run silently [providing all parameters needed for silent mode]
    see get-help <scriptfile> -examples

 .PARAMETER ReportDir
    Use ReportDir in conjunction with report to export report results to a report directory

 .PARAMETER TenantId
    Use the -TenantId parameter with a proper guid formatted ID to bypass the subscriptionID requirement
    Note: Cannot use in conjunction with -SubscriptionID

 .PARAMETER BlueprintMode
    Use the -BlueprintMode parameter to specify you want to import/export/report from either a subscriptionID or ManagementGroupID
    Note: ManagementGroup is the default mode

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -ModuleMode Az -Mode import -ImportDir .\BPExports\MG-root\MyBlueprint 
  Uses Az Module to authenticate to Azure and Imports a blueprint from the relative path.  
  Will prompt for Azure Subscription to set context on AD Tenant.
  See: https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.0.0 to migrate to Az Module

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -ModuleMode AzureRM -Mode import -ImportDir .\BPExports\MG-root\MyBlueprint 
  Uses AzureRM Module to authenticate to Azure and Imports a blueprint from the relative path.
  Will prompt for Azure Subscription to set context on AD Tenant.
  Note: Az is currently the default

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -Mode import -ImportDir .\BPExports\MG-root\MyBlueprint -TenantId "<guid>"
  Imports a blueprint from the relative path.  Will prompt for Management Group to import into

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -Mode import -ImportDir .\BPExports\MG-root\MyBlueprint -BlueprintMode Subscription
  Imports a blueprint from the relative path.  Will prompt for Azure Subscription to import blueprint into

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -Mode export -exportDir .\BPExports\ -BlueprintMode Subscription
  Exports a blueprint to the relative path.  Will prompt for Azure Subscription to export blueprint from

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -Mode import -ImportDir .\BPExports\MG-root\MyBlueprint 
  Imports a blueprint from the relative path.  Will prompt for Azure Subscription to set context on AD Tenant

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -mode export -ManagementGroupID "<ManagementGroup where Blueprint is located>" -BlueprintName "<MyBlueprint>" -ExportDir "<Target Folder Name>"
  Take in parameters and exports a named blueprint and related artifacts to a sub directory named after the MG

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -mode export -ManagementGroupID "<ManagementGroup where Blueprint is located>" -BlueprintName "<MyBlueprint>" -ExportDir "Blueprints"
  Take in parameters and exports a named blueprint and related artifacts to a sub directory named after the new MG name
  This example allows you to export the named Managment Group in the blueprint and artifacts to a new one allowing you
  to import into another Azure AD tenant with a different naming / management group structure.

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -mode import -ImportDir ".\exports\MG-Root\MyBlueprint" -ManagementGroupID "<Target ManagementGroup for Blueprint>" -NewBlueprintName "<New Blueprint Name>"
  This will import a blueprint and artifacts from a source directory and targets a management group and new blueprint name on import

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -Mode Import -ImportDir ".\exports\MG-Root\MyBlueprint" -SubscriptionId "e69041bc-8e27-4272-9089-60ac8f508937" -force
  This will import a blueprint and artifacts from a source directory without prompting.

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -mode report -ManagementGroupID "<ManagementGroup where Blueprint is located>" -BlueprintName "<MyBlueprint>" -ReportDir "<Target Folder Name>" -SubscriptionID "<a SubscriptionID within the tenant you want to report from>"
  Take in parameters and exports a named blueprint and related artifacts to a sub directory named after the MG

.NOTES
   AUTHOR: Jim Britt Senior Program Manager - Azure CAT 
   LAST EDIT: May 23, 2019 - version 2.3
   * Added BlueprintTarget to the parameters to allow for supporting subscription for Blueprint Location on
     import and export. Thank you https://github.com/mrptsai (Paul Towler) for your inputs to add this option! 
   * Added new API version https://github.com/JimGBritt/AzureBlueprint/commit/c3304315745676912e7a958e40fa91b5da0d005e (thank you https://github.com/drmiru Michael Rueefli!)
   * Added enhanced error output https://github.com/JimGBritt/AzureBlueprint/commit/94658c99a7b8207937492bb5a71285a094b6c11e#diff-e7e495ba10b61589a1c555132692367f (thank you https://github.com/Oechiih Jan Oehen!)
   * Updated -ModuleMode to be Az by default (time to move on :)).
   * Added option to bypass subscription requirement and provide TenantID (https://github.com/JimGBritt/AzureBlueprint/issues/2)
     Thank you https://github.com/GPugnet (Guillaume Pugnet) your your feedback on bypassing the SubId requirement
   
   January 04, 2019 - version 2.2
   * Added ModuleMode to the parameters to allow for supporting AzureRM and Az module sets
     Thank you Florent APPOINTAIRE (@florent_app) for the feedback and additional inputs for supporting Az modules  
   * Added validation that all blueprint and artifact names are less than or equal to the maximum of 48 characters
     Thank you for your great inputs on these updates Guillaume Pugnet (@PugnetGuillaume)!
     https://github.com/JimGBritt/AzureBlueprint/issues/1   
   
   November 30, 2018 - version 2.1
   * Updated REST Token code
   * Added exit 1 to terminating errors
   * Thank you for your great inputs on these updates Guillaume Pugnet (@PugnetGuillaume)!
   
   November 20, 2018 - version 2.0
   * Added function for standard error
   * Added function for building REST PUT payload
   * Updated error to indicate clear-AzureRMContext (to replace Logout-AzureRMAccount) to resolve 401
     Thanks https://twitter.com/JFE_CH (Jonas Feller) for the recommendation at this site: 
     https://www.jfe.cloud/export-import-azure-blueprints/ 
   * Removed "ID" and "Name" fields from the export
   * Building "Name" and "ID" for imports dynamically based on folder and file name for blueprint and artifacts
   * Added proper order handling for import of blueprint first, then all artifacts
   * Added APIVersion variable 
   * Thanks Alexander Frankel[MSFT] for your thoughts and feedback here across this release!
      
   November 13, 2018 ver 1.42
   * Added try/catch logic on json conversion to catch improper json files
   * Fixed an example in my get-help output
   * Thank you Jorge Cotillo (MSFT) AzureCAT for your inputs on improved logic for json validation!
   
   October 31, 2018 ver 1.41
   * Added more debug information to help in troubleshooting issues
   * Removed NewManagementGroupID and required ManagementGroupID as a parameter for import/report/export
   * Thank you Javier Soriano (MSFT) for the feedback and recommendations for a cleaner import experience!
   * Thank you Tao Yang (MVP) for your input around additional debug options
   * And special thanks to Aleksandar Nikolic (MVP) for your initial review and great feedback!

   October 24, 2018
   * Renamed ManagementGroup parameter to ManagementGroupID to make it clearer
   * Added ReportDir parameter to target a report directory
   * No longer navigating to script directory during execution
   * Updated Parameters / Sets in general - clean up

.LINK
    This script posted to and discussed at the following locations:
    https://aka.ms/ManageARMBlueprints/
    https://aka.ms/ManageARMBlueprints/Video
    https://github.com/JimGBritt/AzureBlueprint/
#>

<# 
REST API Documentation here: https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-rest-api

Blueprints are available via the following rest endpoint within your Azure AD tenant.
https://management.azure.com/providers/Microsoft.Management/managementGroups/<MG-NAME>/providers/Microsoft.Blueprint/blueprints/<BLUEPRINT-NAME>?api-version=2017-11-11-preview

And to get the artifacts the following REST API endpoint is available:
https://management.azure.com/providers/Microsoft.Management/managementGroups/<MG-NAME>/providers/Microsoft.Blueprint/blueprints/<BLUEPRINT-NAME>/artifacts?api-version=2017-11-11-preview
#>
[cmdletbinding(
        DefaultParameterSetName='Default'
    )]

param
(
    # Mode (Export/Import/Report)
    [Parameter(ParameterSetName='Default',Mandatory = $True)]
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Report')]
    [ValidateSet("Export","Import","Report")]
    [String]$Mode,
    
    # Module Mode (Az or AzureRM)
    [Parameter(Mandatory = $False)]
    [ValidateSet("Az","AzureRM")]
    [String]$ModuleMode="Az",

    # The Management Group ID (***not the friendly name***)
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Report')]
    [string]$ManagementGroupID,

    # Use ReportDir to export a report of the selected Blueprint and related artifacts
    # Used with the report mode
    [Parameter(ParameterSetName='Report')]
    [string]$ReportDir,

    # The Blueprint Name
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Report')]
    [string]$BlueprintName,

    # Provide SubscriptionID to bypass subscription listing
    [Parameter(ParameterSetName='force')]
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='Report')]
    [guid]$SubscriptionId,

    # New Blueprint Name
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Import')]
    [string]$NewBlueprintName,        

    <#
    # Draft or Published **** future use ****
    [Parameter(Mandatory=$False,ParameterSetName='Export')]
    [ValidateSet("Draft","Published")] 
    [string]$State,        

    # Published Blueprint Version **** future use ****
    [Parameter(Mandatory=$False,ParameterSetName='Export')]
    [string]$Version,        
    #>

    # Base folder for export
    [Parameter(ParameterSetName='Export')]
    [string]$ExportDir,

    # Base folder for import
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='force')]
    [string]$ImportDir,

    # Blueprint Mode (Subscription or ManagementGroup)
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='Report')]
    [ValidateSet("ManagementGroup","Subscription")]
    [string]$BlueprintMode="ManagementGroup",

    # Use Force to run in silent mode (requires certain parameters to be provided)
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='force')]
    [switch]$Force,

    # TenantId to bypass subscription requirement
    [guid]$TenantId,

    [Parameter()]
    [ValidateSet('AzureChinaCloud', 'AzureCloud', 'AzureGermanCloud', 'AzureUSGovernment')]
    [String]$Environment = 'AzureCloud'

)

# Function used to build numbers in selection tables for menus
function Add-IndexNumberToArray (
    [Parameter(Mandatory=$True)]
    [array]$array
    )
{
    for($i=0; $i -lt $array.Count; $i++) 
    { 
        Add-Member -InputObject $array[$i] -Name "#" -Value ($i+1) -MemberType NoteProperty 
    }
    $array
}

function StandardError
{
    param ($Exception)
    write-host "An error occurred - please check rights or parameters for proper configuration and try again"
    write-host "If you received " -NoNewline 
    write-host "The access token is invalid " -NoNewline -ForegroundColor Red
    write-host "or an error " -NoNewline
    write-host "(401)" -NoNewline -ForegroundColor Red 
    write-host ", then please type"
    write-host "Clear-AzureRmContext " -ForegroundColor Yellow
    write-host "from within your PowerShell prompt and try running the script again"
    write-host "Error 401 could indicate cached authentication tokens have expired"
    write-host "Error 403 could indicate target Management Group does not exist"
    write-host "Error 404 could indicate source blueprint not found"
    write-host "======================================================================="
    write-host "Specific Error is: " -NoNewline
    write-host "$Exception" -ForegroundColor Yellow

}
function build-PutContent
{
    param
    (
        $URI,
        $BodyContent    
    )
    $PutContent = @{
        URI = $URI
        Headers = @{
            Authorization = "Bearer $($token.AccessToken)"
            'Content-Type' = 'application/json'
        }
        Method = 'Put'
        UseBasicParsing = $true
        Body = $BodyContent
    }
    return $PutContent
}

# MAIN SCRIPT
Write-Host "Using " -NoNewline 
write-host "$ModuleMode " -NoNewline -ForegroundColor Yellow
write-host "module mode"

# Limitations to the script
write-host "Please note this script is using a preview API for Azure Blueprint and is subject to change." -ForegroundColor Green
write-host "This script currently only supports Draft Blueprints or most recently published and related artifacts." -ForegroundColor DarkYellow
write-host "This script currently does not support custom policies - only built-ins are supported." -ForegroundColor DarkYellow

$RmUrl = if ($ModuleMode -eq 'Az')
{
    (Get-AzEnvironment -Name $Environment).ResourceManagerUrl
}
else
{
    (Get-AzureRmEnvironment -Name $Environment).ResourceManagerUrl
}

# Determine where the script is running - build export dir
if ($MyInvocation.MyCommand.Path -ne $null)
{
    $CurrentDir = Split-Path $MyInvocation.MyCommand.Path
}
else
{
    # Sometimes $myinvocation is null, it depends on the PS console host
    $CurrentDir = "."
}
$APIVersion = "?api-version=2018-11-01-preview"
#cd $CurrentDir

# Determine what we are doing - export/import/report
if($Mode -eq "Export" -and !$ExportDir)
{
    Write-Host "Please " -NoNewline
    write-host "provide a directory " -NoNewline -ForegroundColor Yellow
    Write-Host "to EXPORT using the `$ExportDir parameter for your blueprint and artifacts"
    exit 1
}

if($Mode -eq "Import" -AND !$ImportDir)
{
    Write-Host "Please " -NoNewline
    write-host "provide a directory " -NoNewline -ForegroundColor Yellow
    write-host "to IMPORT using the `$ImportDir parameter for your blueprint and artifacts" 
    exit 1
}
If($Mode -eq "Report" -AND $ReportDir)
{
    IF(!$(Test-Path -Path "$ReportDir"))
    {
        write-host "Directory " -NoNewline
        Write-Host "$ReportDir " -ForegroundColor Yellow -NoNewline
        Write-Host "does not exist - please create and retry the operation"
        exit 1        
    }
}

# Login to Azure - if already logged in, use existing credentials.
Write-Host "Authenticating to Azure..." -ForegroundColor Cyan
try
{
    If($ModuleMode -eq "AzureRM"){$AzureLogin = Get-AzureRMSubscription}
    If($ModuleMode -eq "Az"){$AzureLogin = Get-AzSubscription}
}
catch
{
    If($ModuleMode -eq "AzureRM")
    {
        $null = Login-AzureRmAccount -Environment $Environment
        $AzureLogin = Get-AzureRmSubscription
    }
    If($ModuleMode -eq "Az")
    {
        $null = Login-AzAccount -Environment $Environment
        $AzureLogin = Get-AzSubscription
    }
}

# Authenticate to Azure if not already authenticated 
# Ensure this is the subscription where your Management Groups are that house Blueprints for import/export operations
If($AzureLogin -and !($SubscriptionID) -and !($TenantId))
{
    If($ModuleMode -eq "AzureRM"){[array]$SubscriptionArray = Add-IndexNumberToArray (Get-AzureRmSubscription)}
    If($ModuleMode -eq "Az"){[array]$SubscriptionArray = Add-IndexNumberToArray (Get-AzSubscription)}
    [int]$SelectedSub = 0

    # use the current subscription if there is only one subscription available
    if ($SubscriptionArray.Count -eq 1) 
    {
        $SelectedSub = 1
    }
    # Get SubscriptionID if one isn't provided
    while($SelectedSub -gt $SubscriptionArray.Count -or $SelectedSub -lt 1)
    {
        Write-host "Please select a subscription from the list below for the " -NoNewline
        write-host $Mode -ForegroundColor Yellow -NoNewline
        write-host " Operation"
        $SubscriptionArray | select "#", Name, ID | ft
        try
        {
            $SelectedSub = Read-Host "Please enter a selection from 1 to $($SubscriptionArray.count) for the $Mode Operation"
        }
        catch
        {
            Write-Warning -Message 'Invalid option, please try again.'
        }
    }
    if($($SubscriptionArray[$SelectedSub - 1].Name))
    {
        $SubscriptionName = $($SubscriptionArray[$SelectedSub - 1].Name)
    }
    elseif($($SubscriptionArray[$SelectedSub - 1].SubscriptionName))
    {
        $SubscriptionName = $($SubscriptionArray[$SelectedSub - 1].SubscriptionName)
    }
    write-verbose "You Selected Azure Subscription: $SubscriptionName"
    
    if($($SubscriptionArray[$SelectedSub - 1].SubscriptionID))
    {
        [guid]$SubscriptionID = $($SubscriptionArray[$SelectedSub - 1].SubscriptionID)
    }
    if($($SubscriptionArray[$SelectedSub - 1].ID))
    {
        [guid]$SubscriptionID = $($SubscriptionArray[$SelectedSub - 1].ID)
    }
}
if($SubscriptionId -and !($TenantId))
{
    Write-Host "Selecting Azure Subscription: $($SubscriptionID.Guid) ..." -ForegroundColor Cyan
    If($ModuleMode -eq "AzureRM"){$Null = Select-AzureRmSubscription -SubscriptionId $SubscriptionID.Guid}
    If($ModuleMode -eq "Az"){$Null = Select-AzSubscription -SubscriptionId $SubscriptionID.Guid}
}
If(!($ManagementGroupID) -and $BlueprintMode -eq "ManagementGroup")
{
    If($ModuleMode -eq "AzureRM"){[array]$MgtGroupArray = Add-IndexNumberToArray (Get-AzureRmManagementGroup)}
    If($ModuleMode -eq "Az"){[array]$MgtGroupArray = Add-IndexNumberToArray (Get-AzManagementGroup)}
    if(!$MgtGroupArray)
    {
        Write-host "Please make sure you have Management Groups that are accessible"
        exit 1
    }
    [int]$SelectedMG = 0

    # use the current Managment Group if there is only one MG available
    if ($MgtGroupArray.Count -eq 1) 
    {
        $SelectedMG = 1
    }
    # Get Management Group if one isn't provided
    while($SelectedMG -gt $MgtGroupArray.Count -or $SelectedMG -lt 1)
    {
        Write-host "Please select a Management Group from the list below"
        $MgtGroupArray | select "#", Name, DisplayName, Id | ft
        try
        {
            write-host "If you don't see your ManagementGroupID try using the parameter -ManagementGroupID" -ForegroundColor Cyan
            $SelectedMG = Read-Host "Please enter a selection from 1 to $($MgtGroupArray.count)"
        }
        catch
        {
            Write-Warning -Message 'Invalid option, please try again.'
        }
    }
    if($($MgtGroupArray[$SelectedMG - 1].Name))
    {
        $ManagementGroupID = $($MgtGroupArray[$SelectedMG - 1].Name)
    }
    
    write-verbose "You Selected Management Group: $ManagementGroupID"
    Write-Host "Selecting Management Group: $ManagementGroupID ..." -ForegroundColor Cyan
}

# Set context for REST Auth Token
If($ModuleMode -eq "AzureRM"){$currentContext = Get-AzureRmContext}
If($ModuleMode -eq "Az"){$currentContext = Get-AzContext}

# Get token from current context to auth
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
if($TenantId)
{
    $token = $profileClient.AcquireAccessToken($currentContext.Tenant.TenantId)
}
else 
{
    $token = $profileClient.AcquireAccessToken($currentContext.Subscription.TenantId)
}

# If export or report mode is used 
If($Mode -eq "Export" -or $Mode -eq "Report")
{
    # REST Header for REST call to get Blueprints and Artifacts
    $GetBlueprint = @{
        Headers = @{
            Authorization = "Bearer $($token.AccessToken)"
            'Content-Type' = 'application/json'
        }
        Method = 'Get'
        UseBasicParsing = $true
    }
    # Let's go get all blueprints available within a selected management group
    If(!$BlueprintName)
    {
        # Get all Blueprints
        if ($BlueprintMode -eq "Subscription" -and !($TenantId))
        {
            $BlueprintsURI = "$($RmUrl)subscriptions/$($SubscriptionID)/providers/Microsoft.Blueprint/blueprints$($APIVersion)"    
        }
        else 
        {
            $BlueprintsURI = "$($RmUrl)providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints$($APIVersion)"    
        }
        
        Try
        {
            $BPs = Invoke-WebRequest -uri $BlueprintsURI @GetBlueprint
        }
        catch
        {
            StandardError -Exception $($_.Exception.Message)
            exit 1
        }
        $BPValues = $($BPs|convertfrom-json).value
        if(!$BPValues)
        {
            write-host "No Blueprints found in $ManagementGroupID"
            exit 1
        }
        [array]$BPsArray = Add-IndexNumberToArray $BPValues
        [int]$SelectedBP = 0

        # use the only BP if there is only one BP available
        if ($BPsArray.Count -eq 1) 
        {
            $SelectedBP = 1
        }
        # Get Blueprint if one isn't provided
        while($SelectedBP -gt $BPsArray.Count -or $SelectedBP -lt 1)
        {
            Write-host "Please select a Blueprint from the list below to export"
            if ($BlueprintMode -eq "Subscription" -and !($TenantId))
            {
                $BPsArray | Select-Object "#", @{Label = "Blueprint Name";Expression={$_.name}}, @{Label = "Subscription"; Expression = {$($BPsArray.ID).split("/")[2]}}, @{Label = "Blueprint Description";Expression={$_.properties.description}} | Format-Table
            }
            else
            {
                $BPsArray | Select-Object "#", @{Label = "Blueprint Name";Expression={$_.name}}, @{Label = "ManagementGroup"; Expression = {$($BPsArray.ID).split("/")[4]}}, @{Label = "Blueprint Description";Expression={$_.properties.description}} | Format-Table
            }
            try
            {
                $SelectedBP = Read-Host "Please enter a selection from 1 to $($BPsArray.count)"
            }
            catch
            {
                Write-Warning -Message 'Invalid option, please try again.'
            }
        }
        if($($BPsArray[$SelectedBP - 1].Name))
        {
            $BlueprintName = $($BPsArray[$SelectedBP - 1].Name)
        }
        write-verbose "You Selected Blueprint: $BlueprintName"
    }
    Write-Host "Selecting Blueprint: $BlueprintName ..." -ForegroundColor Cyan

    <#
    # FUTURE USE
    # Get all possible published versions of a selected Blueprint (if they exist) to choose from
    $BluePrintVersionsURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints/$BluePrintName/versions" + "?api-version=2017-11-11-preview"
    $BPVersions = Invoke-WebRequest -uri $BluePrintVersionsURI @GetBlueprint
    $BPVersions = $($BPVersions|convertfrom-json).content
    if($BPVersions)
    {
        [array]$BPVersionArray = Add-IndexNumberToArray ($BPVersions) 
        [int]$SelectedBPVer = 0

        # If there is only one Blueprint version available - select it
        if ($BPVersionArray.Count -eq 1) 
        {
            $SelectedBPVer = 1
        }
        # Get all blueprint versions
        while($SelectedBPVer -gt $BPVersionArray.Count -or $SelectedBPVer -lt 1)
        {
            Write-host "Please select a Blueprint Version from the list below to export"
            $BPVersionArray|select "#", @{Label = "Version";Expression={$_.name}}, @{Label = "Blueprint Name";Expression={$BlueprintName}}|ft
                
            try
            {
                $SelectedBPVer = Read-Host "Please enter a selection from 1 to $($BPVersionArray.count)"
            }
            catch
            {
                Write-Warning -Message 'Invalid option, please try again.'
            }
        }
        if($($BPVersionArray[$SelectedBPVer - 1].Name))
        {
            $Version = $($BPVersionArray[$SelectedBPVer - 1].Name)
        }
    
        write-verbose "You Selected Blueprint Version: $Version"
        Write-Host "Selecting Blueprint: $Version for Blueprint $BlueprintName..." -ForegroundColor Cyan
        $BluePrintURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints/$BlueprintName/versions/$Version" + "?api-version=2017-11-11-preview"
        $ArtifactsURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints/$BlueprintName/versions/$Version/artifacts" + "?api-version=2017-11-11-preview"
    }
    Else
    {
        Write-host "No published versions present to export - defaulting to draft"#>
    #Blueprints and Artifacts URIs
    if ($BlueprintMode -eq "Subscription" -and !($TenantId))
    {
        $BluePrintURI = "$($RmUrl)subscriptions/$($SubscriptionID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)$($APIVersion)"
        $ArtifactsURI = "$($RmUrl)subscriptions/$($SubscriptionID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)/artifacts$($APIVersion)"
    } else
    {
        $BluePrintURI = "$($RmUrl)providers/Microsoft.Management/managementGroups/$($ManagementGroupID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)$($APIVersion)"
        $ArtifactsURI = "$($RmUrl)providers/Microsoft.Management/managementGroups/$($ManagementGroupID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)/artifacts$($APIVersion)"
    }
    #}
    try
    {
        $BP = Invoke-WebRequest -uri $BluePrintURI @GetBlueprint
    }
    catch
    {
        StandardError -Exception $($_.Exception.Message)
        exit 1
    }
    $BlueprintContent = $BP.content | ConvertFrom-Json

    If($NewBluePrintName)
    {
        $TargetBPName = $NewBluePrintName
    }
    Else
    {
        $TargetBPName = $BlueprintName
    }
    if($Mode -eq "Export")
    {
        # Create export directory if one doesn't exist
        IF(!$(Test-Path -Path "$ExportDir\$TargetBPName"))
        {
            $NewFolder = New-Item -Type Directory "$ExportDir\$TargetBPName"
        }
        # Exporting main Blueprint
        write-host "Export Folder for export: $ExportDir\$TargetBPName" 
        Write-Host "Exporting Blueprint: " -ForegroundColor Cyan -NoNewline
        write-host "$BlueprintName " -ForegroundColor Yellow -NoNewline
        write-host "to target Blueprint Name $TargetBPName" -ForegroundColor White
        # Remove ID to generalize JSON
        $BlueprintContent = $BlueprintContent | Select-Object -Property * -ExcludeProperty id

        # Remove Name to generalize JSON
        $BlueprintContent = $BlueprintContent | Select-Object -Property * -ExcludeProperty name

        $BlueprintContent|ConvertTo-Json -Depth 50|Out-File "$ExportDir\$TargetBPName\$TargetBPName.json"
    }
    # Build details for Blueprint basic report
    if($Mode -eq "Report")
    {
        $Report =@()
        $MyObj = New-Object System.Object
        Add-Member -InputObject $MyObj -Name "Type" -Value ("AzureBlueprint") -MemberType NoteProperty 
        Add-Member -InputObject $MyObj -Name "Display Name" -Value ($BlueprintName) -MemberType NoteProperty
        Add-Member -InputObject $MyObj -Name "ID" -value ($BlueprintContent.name)-MemberType NoteProperty
        $Report = $Report + $Myobj
    }
    # Get All Artifacts
    try
    {
        try
        {
            $BPArtifacts = Invoke-WebRequest -Uri $ArtifactsURI @GetBlueprint
        }
        catch
        {
            StandardError -Exception $($_.Exception.Message)
            exit 1
        }
        $Artifacts = $BPArtifacts.Content | ConvertFrom-Json
        
        # Logic for exporting artifacts from a selected Blueprint        
        if($Mode -eq "Export")
        {
            Write-Host "Starting the export of Blueprint Artifacts" -ForegroundColor Cyan
            foreach($Artifact in $Artifacts.value)
            {

                # Exporting all artifacts by kind and name
                $Kind = $Artifact.kind
                $Name = $Artifact.Name

                # Remove ID to generalize json
                $Artifact = $Artifact | Select-Object -Property * -ExcludeProperty id
                # Removing name to generalize artifact
                $Artifact = $Artifact | Select-Object -Property * -ExcludeProperty name

                Write-Host "Exporting Artifact($Kind): " -NoNewline -ForegroundColor Cyan
                write-host "$Name.json" -ForegroundColor Yellow
                $Artifact|ConvertTo-Json -Depth 50|Out-File "$ExportDir\$TargetBPName\$Name.json"
            }
        }
        # Report logic for exporting a basic report of a Blueprint and Artifacts        
        if($Mode -eq "Report")
        {
            
            foreach($Artifact in $Artifacts.value)
            {
                # Display Details
                $MyObj = New-Object System.Object
                Add-Member -InputObject $MyObj -Name "Type" -Value ($Artifact.kind) -MemberType NoteProperty 
                Add-Member -InputObject $MyObj -Name "Display Name" -Value ($Artifact.Properties.DisplayName) -MemberType NoteProperty 
                Add-Member -InputObject $MyObj -Name "ID" -Value ($Artifact.Name) -MemberType NoteProperty 
                $Report = $Report + $Myobj
            }
            IF(!$ReportDir)
            {
                Write-Host "No Report Directory parameter " -NoNewline
                write-host "(`$ReportDir) " -NoNewline -ForegroundColor Yellow
                write-host " provided.  Writing to console!"
                $Report|ft
            }
            If($ReportDir)
            {
                $Time = $(Get-Date).ToString("yyyyMMddhhmm")
                Write-host "Writing Report to " -NoNewline
                write-host "$ReportDir\Report-$BlueprintName-$Time.csv"  -ForegroundColor Yellow
                $Report | Export-Csv "$ReportDir\Report-$BlueprintName-$Time.csv" -NoTypeInformation
            }
        } 
    }
    catch
    {}
    Write-host "Complete"
}
# Import logic for Azure Blueprints
If($Mode -eq "Import")
{
    # Array for JSONs processing
    $JSONArray =@()
    if($BlueprintMode -eq "Subscription" -and !($TenantId))
    {
        $TargetStr = "$SubscriptionId subscription"
    }
    else
    {
        $TargetStr = "$ManagementGroupID Management Group"        
    }
    
    # Validate customer wants to continue to import Blueprint and artifacts
    # If Force used, will update without prompting
    if ($Force -OR $PSCmdlet.ShouldContinue("This operation will attempt to import the Blueprint from $ImportDir into your $TargetStr. Continue?",$ImportDir) )
    {
        $filesToImport = Get-ChildItem $ImportDir\*.json -rec
        Write-Host "Starting the import of a Blueprint and Artifacts" -ForegroundColor Cyan
        Write-Host "Importing Blueprint from: " -ForegroundColor Cyan -NoNewline
        write-host "$ImportDir" -ForegroundColor Yellow 
        
        # Getting BlueprintName from base folder
        $BlueprintName = $filesToImport[0].directory.Name

        # Get each file
        foreach ($file in $filesToImport)
        {
            try
            {
                $FileContent = Get-Content -Path $File.pspath|ConvertFrom-Json -ErrorAction stop
            }
            catch
            {
                # Throw an error to screen and exit script on invalid json
                write-host "ERROR: " -NoNewline -ForegroundColor Red
                Write-Host "Check to ensure " -NoNewline
                write-host "$($File.Name) " -ForegroundColor Yellow -NoNewline
                write-host "is a valid JSON"
                exit 1
            }
            # Add ID to the PSObject to allow for importing to proper path
            If($FileContent.ID)
            {
                $FileContent.ID = $null
            }
            else
            {
                $FileContent | Add-Member -Name 'id' -Type NoteProperty -Value $Null
            }
            
            if($FileContent.type -eq "Microsoft.Blueprint/blueprints")
            {
                # Add Name to the PSObject to allow for importing to proper path
                If(!($FileContent.Name))
                {
                    $FileContent | Add-Member -Name 'Name' -Type NoteProperty -Value $File.Directory.Name
                }

                if($NewBluePrintName)
                {
                    # Only supported on draft (non versioned blueprint exports)
                    $FileContent.Name = $NewBluePrintName
                    $BlueprintName = $NewBluePrintName
                }
                #Ensure we update the Management Group / subscriptionId and BlueprintName for the target ID
                if ($BlueprintMode -eq "Subscription" -and !($TenantId))
                {
                    $FileContent.ID = "/subscriptions/$($SubscriptionID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)"
                }
                else
                {
                    $FileContent.ID = "/providers/Microsoft.Management/managementGroups/$($ManagementGroupID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)"    
                }
                
            }
            if($FileContent.type -eq "Microsoft.Blueprint/blueprints/artifacts") 
            {
                # Add Name to the PSObject to allow for importing to proper path
                If(!($FileContent.Name))
                {
                    $FileContent | Add-Member -Name 'Name' -Type NoteProperty -Value $File.BaseName
                }
                                
                if($NewBluePrintName)
                {
                    $BlueprintName = $NewBluePrintName
                }
                #Ensure we update the Management Group /subscriptionId and BlueprintName for the target ID
                if ($BlueprintMode -eq "Subscription" -and !($TenantId))
                {
                    $FileContent.ID = "/subscriptions/$($SubscriptionID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)/artifacts/$($FileContent.Name)"
                }
                else
                {
                    $FileContent.ID = "/providers/Microsoft.Management/managementGroups/$($ManagementGroupID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)/artifacts/$($FileContent.Name)"    
                }
                
            }
            $JSONArray = $JSONArray + $FileContent
        }

        # Let's publish the Blueprint First
        foreach($JSON in $JSONArray)
        {
            # Ensuring we are 48 or less chars - limit imposed for maximum naming for a blueprint or artifact
            If($JSON.Name.Length -gt 48)
            {
                Write-Host "Blueprint and artifact names must be 48 characters or less" -ForegroundColor Green
                Write-Host "Blueprint or artifact named $($JSON.Name) is " -ForegroundColor red -NoNewline
                write-host "$($JSON.Name.Length) " -ForegroundColor Yellow -NoNewline
                Write-host "chars long - please fix before import" -ForegroundColor Red
                exit 1
            }
            if($JSON.type -EQ "Microsoft.Blueprint/blueprints")
            {
                Write-Host "Importing main Blueprint first " -ForegroundColor White -NoNewline
                write-host "$($JSON.Name)" -ForegroundColor Yellow
                $ImportURI = "$($RmUrl.Trim('/'))$($JSON.ID)$($APIVersion)"
                $Body = $JSON|ConvertTo-Json -depth 50 -Compress -ErrorAction Stop

                # Put call 
                $Putconfig = build-PutContent -URI $ImportURI -BodyContent $Body
           
                try
                {
                    $PutEvent = Invoke-WebRequest @Putconfig
                }
                catch
                {
                    StandardError -Exception $($_.ErrorDetails.Message)
                    exit 1
                }
            }
        }
        foreach($JSON in $JSONArray)
        {
            if($JSON.type -EQ "Microsoft.Blueprint/blueprints/artifacts")
            {
                Write-Host "Importing $($JSON.Kind) artifact " -ForegroundColor White -NoNewline
                write-host "$($JSON.Name)" -ForegroundColor Yellow
                $ImportURI = "$($RmUrl.Trim('/'))$($JSON.ID)$($APIVersion)"
                $Body = $JSON|ConvertTo-Json -depth 50 -Compress -ErrorAction Stop

                # Put call 
                $Putconfig = build-PutContent -URI $ImportURI -BodyContent $Body
           
                try
                {
                    $PutEvent = Invoke-WebRequest @Putconfig
                }
                catch
                {
                    StandardError -Exception $($_.ErrorDetails.Message)
                    exit 1
                }
            }
        }
        write-host "Complete!"
    }
    else
    {
            Write-Host "You selected No - exiting"
            Write-Host "Complete" -ForegroundColor Cyan
            exit
    }
    
}
