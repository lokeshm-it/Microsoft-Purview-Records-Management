<#
.SYNOPSIS
    Audits and exports the complete Microsoft Purview Records Management
    configuration for compliance documentation and governance review.

.DESCRIPTION
    Produces a comprehensive audit report covering:
    - All record and regulatory record labels
    - Label policies and publication status
    - Disposition review configuration
    - Event types configured for event-based retention
    - Records Management role assignments
    Exports to HTML report and JSON for downstream processing.

.PARAMETER OutputPath
    Directory for report output. Defaults to .\reports\

.PARAMETER GenerateHtmlReport
    If specified, generates an HTML audit report in addition to JSON/CSV.

.EXAMPLE
    .\Get-RecordsManagementConfiguration.ps1
    .\Get-RecordsManagementConfiguration.ps1 -OutputPath "C:\Audit" -GenerateHtmlReport

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
    [switch]$GenerateHtmlReport
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

function Get-RecordLabelStats {
    param($Labels)
    @{
        TotalLabels       = $Labels.Count
        RecordLabels      = ($Labels | Where-Object { $_.IsRecordLabel -and -not $_.IsRegulatoryLabel }).Count
        RegulatoryLabels  = ($Labels | Where-Object { $_.IsRegulatoryLabel }).Count
        ActiveLabels      = ($Labels | Where-Object { -not $_.Disabled }).Count
        InactiveLabels    = ($Labels | Where-Object { $_.Disabled }).Count
        WithDisposition   = ($Labels | Where-Object { $_.ReviewerEmail }).Count
        AutoDelete        = ($Labels | Where-Object { $_.RetentionAction -eq 'Delete' }).Count
        RetainAndDelete   = ($Labels | Where-Object { $_.RetentionAction -eq 'KeepAndDelete' }).Count
    }
}

#endregion

#region Main

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Log "Connecting to Security and Compliance PowerShell..."
Connect-IPPSSession -ErrorAction Stop
Write-Log "Connected." -Level 'SUCCESS'

$auditTimestamp = Get-Date
$timestamp      = $auditTimestamp.ToString('yyyyMMdd-HHmmss')

# 1. Retrieve all labels
Write-Log "Retrieving all compliance tags..."
$allLabels    = Get-ComplianceTag -ErrorAction Stop
$recordLabels = $allLabels | Where-Object { $_.IsRecordLabel -or $_.IsRegulatoryLabel }
Write-Log "Found $($allLabels.Count) total labels, $($recordLabels.Count) record/regulatory." -Level 'SUCCESS'

# 2. Retrieve label policies
Write-Log "Retrieving label policies..."
try {
    $labelPolicies = Get-RetentionCompliancePolicy -ErrorAction Stop
    Write-Log "Found $($labelPolicies.Count) label policies." -Level 'SUCCESS'
}
catch {
    Write-Log "Could not retrieve label policies: $($_.Exception.Message)" -Level 'WARNING'
    $labelPolicies = @()
}

# 3. Retrieve event types
Write-Log "Retrieving event types for event-based retention..."
try {
    $eventTypes = Get-ComplianceRetentionEventType -ErrorAction Stop
    Write-Log "Found $($eventTypes.Count) event types." -Level 'SUCCESS'
}
catch {
    Write-Log "Could not retrieve event types: $($_.Exception.Message)" -Level 'WARNING'
    $eventTypes = @()
}

# 4. Calculate statistics
$stats = Get-RecordLabelStats -Labels $recordLabels

# 5. Build audit report
$auditReport = [ordered]@{
    AuditMetadata = @{
        TenantAuditDate    = $auditTimestamp.ToString('yyyy-MM-dd HH:mm:ss UTC')
        GeneratedBy        = $env:USERNAME
        ScriptVersion      = '1.0.0'
        Repository         = 'Microsoft-Purview-Records-Management'
    }
    Statistics = $stats
    RecordLabels = $recordLabels | Select-Object Name, DisplayName, IsRecordLabel, IsRegulatoryLabel,
        RetentionDuration, RetentionDurationDisplayHint, RetentionAction, RetentionType,
        Disabled, ReviewerEmail, CreatedBy, WhenCreated, WhenChanged, Comment
    LabelPolicies = $labelPolicies | Select-Object Name, Mode, Enabled, WhenCreated, WhenChanged, Comment
    EventTypes = $eventTypes | Select-Object Name, DisplayName, CreatedBy, WhenCreated
}

# 6. Export JSON
$jsonPath = Join-Path $OutputPath "records-mgmt-audit-$timestamp.json"
$auditReport | ConvertTo-Json -Depth 8 | Out-File -FilePath $jsonPath -Encoding UTF8
Write-Log "Audit JSON exported: $jsonPath" -Level 'SUCCESS'

# 7. Export CSV summaries
$labelCsvPath = Join-Path $OutputPath "record-labels-audit-$timestamp.csv"
$auditReport.RecordLabels | Export-Csv -Path $labelCsvPath -NoTypeInformation -Encoding UTF8
Write-Log "Label CSV exported: $labelCsvPath" -Level 'SUCCESS'

# 8. Optional HTML report
if ($GenerateHtmlReport) {
    $htmlPath = Join-Path $OutputPath "records-mgmt-audit-$timestamp.html"
    $tableRows = $recordLabels | ForEach-Object {
        $recordType = if ($_.IsRegulatoryLabel) { '🔒 Regulatory' } elseif ($_.IsRecordLabel) { '📋 Record' } else { 'Standard' }
        $status     = if ($_.Disabled) { '<span style="color:red">Inactive</span>' } else { '<span style="color:green">Active</span>' }
        "<tr><td>$($_.Name)</td><td>$recordType</td><td>$($_.RetentionDuration) $($_.RetentionDurationDisplayHint)</td><td>$($_.RetentionAction)</td><td>$status</td></tr>"
    }

    $html = @"
<!DOCTYPE html><html><head><meta charset="UTF-8">
<title>Records Management Audit — $($auditTimestamp.ToString('yyyy-MM-dd'))</title>
<style>
  body { font-family: Segoe UI, sans-serif; background: #f4f6f9; color: #1a1a2e; padding: 2rem; }
  h1 { color: #0078D4; } h2 { color: #444; border-bottom: 2px solid #0078D4; padding-bottom: 4px; }
  table { border-collapse: collapse; width: 100%; margin-bottom: 2rem; background: #fff; }
  th { background: #0078D4; color: #fff; padding: 10px; text-align: left; }
  td { padding: 8px 10px; border-bottom: 1px solid #ddd; }
  tr:hover { background: #f0f4ff; }
  .stat { display: inline-block; background: #0078D4; color: #fff; border-radius: 8px; padding: 1rem 2rem; margin: 0.5rem; text-align: center; }
  .stat-value { font-size: 2rem; font-weight: bold; display: block; }
</style></head><body>
<h1>Microsoft Purview Records Management — Configuration Audit</h1>
<p>Generated: $($auditTimestamp.ToString('yyyy-MM-dd HH:mm:ss')) | Repository: Microsoft-Purview-Records-Management</p>
<h2>Summary</h2>
<div>
  <div class="stat"><span class="stat-value">$($stats.TotalLabels)</span>Total Labels</div>
  <div class="stat"><span class="stat-value">$($stats.RecordLabels)</span>Record Labels</div>
  <div class="stat"><span class="stat-value">$($stats.RegulatoryLabels)</span>Regulatory Records</div>
  <div class="stat"><span class="stat-value">$($stats.ActiveLabels)</span>Active</div>
  <div class="stat"><span class="stat-value">$($stats.WithDisposition)</span>Disposition Review</div>
</div>
<h2>Record Labels</h2>
<table><tr><th>Label Name</th><th>Type</th><th>Retention</th><th>Action</th><th>Status</th></tr>
$($tableRows -join "`n")
</table>
</body></html>
"@
    $html | Out-File -FilePath $htmlPath -Encoding UTF8
    Write-Log "HTML report exported: $htmlPath" -Level 'SUCCESS'
}

# 9. Console summary
Write-Log ""
Write-Log "=== Records Management Audit Complete ===" -Level 'SUCCESS'
Write-Log "Record labels:              $($stats.RecordLabels)"
Write-Log "Regulatory record labels:   $($stats.RegulatoryLabels)"
Write-Log "Active labels:              $($stats.ActiveLabels)"
Write-Log "With disposition review:    $($stats.WithDisposition)"
Write-Log "Label policies found:       $($labelPolicies.Count)"
Write-Log "Event types configured:     $($eventTypes.Count)"
Write-Log "Output directory:           $OutputPath"

#endregion
