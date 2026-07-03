<#
.SYNOPSIS
    Exports the Microsoft Purview Records Management File Plan to CSV and JSON.

.DESCRIPTION
    Retrieves all retention and record labels and exports a structured File Plan
    report suitable for records governance audits, regulatory submissions, and
    ISO 15489 records schedule documentation. Includes all File Plan descriptor
    fields where populated.

.PARAMETER OutputPath
    Directory for output files. Defaults to .\reports\

.PARAMETER RecordsOnly
    If specified, exports only labels configured as record or regulatory records.

.PARAMETER IncludeFilePlanDescriptors
    If specified, includes extended File Plan descriptor columns (Authority, Citation, etc.)

.EXAMPLE
    .\Export-FilePlan.ps1
    .\Export-FilePlan.ps1 -RecordsOnly -OutputPath "C:\AuditReports"
    .\Export-FilePlan.ps1 -IncludeFilePlanDescriptors

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
    [switch]$RecordsOnly,

    [Parameter()]
    [switch]$IncludeFilePlanDescriptors
)

#region Functions

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $col = switch ($Level) {
        'SUCCESS' { 'Green' } 'WARNING' { 'Yellow' } 'ERROR' { 'Red' } default { 'Cyan' }
    }
    Write-Host "[$ts] [$Level] $Message" -ForegroundColor $col
}

#endregion

#region Main

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Log "Connecting to Security and Compliance PowerShell..."
try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Log "Connected." -Level 'SUCCESS'
}
catch {
    Write-Log "Connection failed: $($_.Exception.Message)" -Level 'ERROR'
    throw
}

Write-Log "Retrieving labels for File Plan export..."
$allLabels = Get-ComplianceTag -ErrorAction Stop

if ($RecordsOnly) {
    $labels = $allLabels | Where-Object { $_.IsRecordLabel -eq $true -or $_.IsRegulatoryLabel -eq $true }
    Write-Log "Filtered to $($labels.Count) record/regulatory labels."
}
else {
    $labels = $allLabels
    Write-Log "Exporting all $($labels.Count) labels."
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

$filePlan = foreach ($label in $labels) {
    $entry = [ordered]@{
        # Core identification
        LabelName             = $label.Name
        DisplayName           = $label.DisplayName
        LabelStatus           = if ($label.Disabled) { 'Inactive' } else { 'Active' }

        # Record designation
        IsRecord              = $label.IsRecordLabel
        IsRegulatoryRecord    = $label.IsRegulatoryLabel

        # Retention configuration
        RetentionPeriod       = $label.RetentionDuration
        RetentionUnit         = $label.RetentionDurationDisplayHint
        RetentionBasedOn      = $label.RetentionType
        RetentionAction       = $label.RetentionAction

        # Disposition
        DispositionType       = if ($label.ReviewerEmail) { 'Disposition Review' } else { 'Automatic' }
        ReviewerEmail         = $label.ReviewerEmail

        # Publication
        Published             = -not [string]::IsNullOrEmpty($label.ExchangeLocation)

        # Audit
        CreatedBy             = $label.CreatedBy
        WhenCreated           = $label.WhenCreated?.ToString('yyyy-MM-dd HH:mm:ss')
        WhenChanged           = $label.WhenChanged?.ToString('yyyy-MM-dd HH:mm:ss')
        Comment               = $label.Comment
    }

    # Optional File Plan descriptors
    if ($IncludeFilePlanDescriptors) {
        $entry['FilePlanFunction']      = $label.FilePlanProperty?.ReferenceId
        $entry['FilePlanCategory']      = $label.FilePlanProperty?.SubCategory
        $entry['AuthorityType']         = $label.FilePlanProperty?.AuthorityType
        $entry['AuthorityCitation']     = $label.FilePlanProperty?.Citation
        $entry['CitationProvision']     = $label.FilePlanProperty?.CitationURL
        $entry['ReferenceID']           = $label.FilePlanProperty?.ReferenceId
    }

    [PSCustomObject]$entry
}

# Export CSV
$csvPath = Join-Path $OutputPath "file-plan-export-$timestamp.csv"
$filePlan | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Log "File Plan CSV exported: $csvPath" -Level 'SUCCESS'

# Export JSON
$jsonPath = Join-Path $OutputPath "file-plan-export-$timestamp.json"
$filePlan | ConvertTo-Json -Depth 5 | Out-File -FilePath $jsonPath -Encoding UTF8
Write-Log "File Plan JSON exported: $jsonPath" -Level 'SUCCESS'

# Summary
Write-Log ""
Write-Log "=== File Plan Export Summary ===" -Level 'INFO'
Write-Log "Total labels exported:         $($labels.Count)"
Write-Log "Record labels:                 $(($labels | Where-Object { $_.IsRecordLabel }).Count)"
Write-Log "Regulatory record labels:      $(($labels | Where-Object { $_.IsRegulatoryLabel }).Count)"
Write-Log "Labels with disposition review:$(($labels | Where-Object { $_.ReviewerEmail }).Count)"
Write-Log "Output directory:              $OutputPath"

#endregion
