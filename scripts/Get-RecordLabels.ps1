<#
.SYNOPSIS
    Retrieves all record labels from Microsoft Purview Records Management
    and exports the configuration to CSV and JSON.

.DESCRIPTION
    Connects to Security & Compliance PowerShell and retrieves all retention
    labels that are configured as record labels (IsRecordLabel = True) or
    regulatory records. Exports results with full configuration details
    including retention period, disposition action, and record type.

.PARAMETER OutputPath
    Directory path for output files. Defaults to .\reports\

.PARAMETER Format
    Output format: CSV, JSON, or Both. Defaults to Both.

.PARAMETER IncludeStandardLabels
    If specified, includes standard retention labels (non-record) in output.

.EXAMPLE
    .\Get-RecordLabels.ps1
    .\Get-RecordLabels.ps1 -OutputPath "C:\Reports" -Format CSV
    .\Get-RecordLabels.ps1 -IncludeStandardLabels

.NOTES
    Author:      Lokesh M
    Repository:  Microsoft-Purview-Records-Management
    Requires:    ExchangeOnlineManagement module
    Role:        Records Management or Compliance Administrator
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]$OutputPath = ".\reports",

    [Parameter()]
    [ValidateSet('CSV', 'JSON', 'Both')]
    [string]$Format = 'Both',

    [Parameter()]
    [switch]$IncludeStandardLabels
)

#region Functions

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $colour = switch ($Level) {
        'INFO'    { 'Cyan' }
        'SUCCESS' { 'Green' }
        'WARNING' { 'Yellow' }
        'ERROR'   { 'Red' }
        default   { 'White' }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colour
}

function Connect-PurviewCompliance {
    try {
        Write-Log "Connecting to Security and Compliance PowerShell..."
        Connect-IPPSSession -ErrorAction Stop
        Write-Log "Connected successfully." -Level 'SUCCESS'
    }
    catch {
        Write-Log "Connection failed: $($_.Exception.Message)" -Level 'ERROR'
        throw
    }
}

#endregion

#region Main

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Log "Created output directory: $OutputPath"
}

Connect-PurviewCompliance

Write-Log "Retrieving compliance tags (retention labels)..."

try {
    $allLabels = Get-ComplianceTag -ErrorAction Stop
    Write-Log "Retrieved $($allLabels.Count) total labels." -Level 'SUCCESS'
}
catch {
    Write-Log "Failed to retrieve labels: $($_.Exception.Message)" -Level 'ERROR'
    throw
}

# Filter to record labels unless IncludeStandardLabels is specified
if ($IncludeStandardLabels) {
    $targetLabels = $allLabels
    Write-Log "Including all labels (standard + record)."
}
else {
    $targetLabels = $allLabels | Where-Object { $_.IsRecordLabel -eq $true -or $_.IsRegulatoryLabel -eq $true }
    Write-Log "Filtered to $($targetLabels.Count) record/regulatory labels."
}

if ($targetLabels.Count -eq 0) {
    Write-Log "No record labels found. Verify that record labels exist in the tenant." -Level 'WARNING'
    exit
}

# Build output objects
$labelReport = foreach ($label in $targetLabels) {
    [PSCustomObject]@{
        LabelName              = $label.Name
        DisplayName            = $label.DisplayName
        IsRecordLabel          = $label.IsRecordLabel
        IsRegulatoryLabel      = $label.IsRegulatoryLabel
        RetentionDuration      = $label.RetentionDuration
        RetentionDurationUnit  = $label.RetentionDurationDisplayHint
        RetentionAction        = $label.RetentionAction
        RetentionType          = $label.RetentionType
        DispositionComment     = $label.DispositionComment
        Disabled               = $label.Disabled
        PublishedToPolicyCount = ($allLabels | Where-Object { $_.Name -eq $label.Name }).PSObject.Properties['PolicyCount']?.Value
        CreatedBy              = $label.CreatedBy
        WhenCreated            = $label.WhenCreated
        WhenChanged            = $label.WhenChanged
        Comment                = $label.Comment
    }
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

# Export CSV
if ($Format -in 'CSV', 'Both') {
    $csvPath = Join-Path $OutputPath "record-labels-$timestamp.csv"
    $labelReport | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    Write-Log "CSV exported: $csvPath" -Level 'SUCCESS'
}

# Export JSON
if ($Format -in 'JSON', 'Both') {
    $jsonPath = Join-Path $OutputPath "record-labels-$timestamp.json"
    $labelReport | ConvertTo-Json -Depth 5 | Out-File -FilePath $jsonPath -Encoding UTF8
    Write-Log "JSON exported: $jsonPath" -Level 'SUCCESS'
}

# Summary
Write-Log ""
Write-Log "=== Record Label Summary ===" -Level 'INFO'
Write-Log "Total labels retrieved:    $($targetLabels.Count)"
Write-Log "Record labels:             $(($targetLabels | Where-Object { $_.IsRecordLabel -eq $true -and $_.IsRegulatoryLabel -ne $true }).Count)"
Write-Log "Regulatory record labels:  $(($targetLabels | Where-Object { $_.IsRegulatoryLabel -eq $true }).Count)"
Write-Log "Output path:               $OutputPath"

#endregion
