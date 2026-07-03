# Microsoft Purview Records Management

> Enterprise implementation of Microsoft Purview Records Management — covering Record Labels, File Plan, Disposition Review, Regulatory Records, and Event-Based Retention across Microsoft 365 workloads.

![Status](https://img.shields.io/badge/Status-Live-brightgreen)
![Platform](https://img.shields.io/badge/Platform-Microsoft%20Purview-0078D4)
![Exam](https://img.shields.io/badge/Exam-MS--102-blue)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## Enterprise Overview

This repository documents a production-grade Microsoft Purview Records Management implementation deployed for a regulated organisation requiring formal lifecycle governance for financial, legal, and HR records. The implementation establishes record declaration controls, immutable record protection, structured disposition workflows, and centralized records visibility through the File Plan — all governed through the Microsoft Purview compliance portal.

Records Management in Microsoft Purview extends standard retention capabilities by adding record-level controls that prevent modification, enforce chain-of-custody requirements, and satisfy regulatory obligations under frameworks including ISO 15489, GDPR Article 5, and SEC Rule 17a-4.

---

## Business Problem

| Challenge | Business Impact |
|---|---|
| Financial records modified or deleted before retention period expires | Regulatory non-compliance; audit failure |
| No centralized visibility into retention labels across workloads | Inconsistent governance; eDiscovery gaps |
| Legal hold inadequate for declared records | Legal risk during litigation |
| Disposition of records without review or approval | Unauthorized destruction; compliance exposure |
| No distinction between retention-managed and record-managed content | Governance gaps for regulated content categories |

---

## Business Requirements

1. Declare financial records as immutable Records in Microsoft 365
2. Prevent modification or deletion of declared records during retention period
3. Provide a centralized File Plan view across all record categories
4. Implement Disposition Review workflows for regulated content
5. Support event-based retention for contract and legal document categories
6. Enable Regulatory Record designation for highest-sensitivity content
7. Automate record label reporting and configuration export via PowerShell

---

## Microsoft Solution

| Requirement | Microsoft Purview Component |
|---|---|
| Record declaration and immutability | Record Labels (Mark items as a record) |
| Highest-level protection | Regulatory Record Labels |
| Centralized records visibility | File Plan |
| Post-retention disposal workflow | Disposition Review |
| Contract/event-triggered retention | Event-Based Retention |
| Configuration reporting | PowerShell + Microsoft Graph |

---

## Environment

| Property | Value |
|---|---|
| Tenant | Patchthecloud.onmicrosoft.com |
| Admin Portal | compliance.microsoft.com |
| Workloads | Exchange Online, SharePoint Online, OneDrive, Teams |
| Licensing | Microsoft 365 E5 |
| Scope | Organisation-wide + Finance adaptive scope |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                  Microsoft Purview Records Management               │
│                     compliance.microsoft.com                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐   ┌──────────────┐   ┌─────────────────────────┐  │
│  │  File Plan  │   │ Record Labels│   │   Disposition Review    │  │
│  │  (Central   │   │ (Mark as     │   │   (Reviewer Approval    │  │
│  │   View)     │   │  Record)     │   │    Before Deletion)     │  │
│  └─────────────┘   └──────────────┘   └─────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              Microsoft 365 Workloads                         │   │
│  │   Exchange Online │ SharePoint Online │ OneDrive │ Teams    │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

See [architecture/records-management-architecture.md](architecture/records-management-architecture.md) for full Mermaid diagrams.

---

## Implementation Phases

### Phase 1 — Enable Records Management
Navigate to `compliance.microsoft.com → Solutions → Records Management`. Confirm Records Management is enabled for the tenant.

### Phase 2 — Create Record Labels
```
Data Lifecycle Management → Retention Labels → Create a label
```
- Label name: `MS102-Finance-Record`
- Retention period: 7 years
- Retention action: Retain and delete
- Record setting: **Mark items as a record**

![Record label mark-as-record setting](images/02-record-labels/01-mark-as-record-setting.png)
*Record declaration setting — converts retention label into a Record Label with enhanced governance controls*

### Phase 3 — Configure File Plan

Navigate to `Records Management → File Plan` to review all record labels, retention durations, and disposition settings in a centralised view.

![File Plan centralised view](images/03-file-plan/01-file-plan-overview.png)
*File Plan — centralised visibility into record labels, retention settings, and disposition actions*

### Phase 4 — Publish Label Policies

Navigate to `Data Lifecycle Management → Label Policies` to publish record labels to Exchange Online, SharePoint Online, and OneDrive.

![Published label policies](images/02-record-labels/02-label-policies-published.png)
*Label policies — MS102-Finance-Record published across Microsoft 365 workloads*

### Phase 5 — Configure Disposition Review
Assign disposition reviewers to record labels requiring human approval before content deletion. Navigate to `Records Management → Disposition`.

### Phase 6 — Validation
Verify record label configuration through the File Plan:
- Label Status = Active
- Is Record = Yes
- Retention Duration = 7 Years
- Disposition action configured

---

## Validation Results

| Test Case | Expected | Actual | Status |
|---|---|---|---|
| TC-REC-01 | MS102-Finance-Record appears in File Plan | Label visible with Is Record = Yes | ✅ Pass |
| TC-REC-02 | Record label published to all workloads | Policy visible in Label Policies | ✅ Pass |
| TC-REC-03 | Record prevents content modification | Edit blocked on declared record item | ✅ Pass |
| TC-REC-04 | File Plan shows all retention settings | Duration, action, record type all visible | ✅ Pass |
| TC-REC-05 | Disposition review configured | Reviewer assigned; approval workflow active | ✅ Pass |
| TC-REC-06 | Regulatory record prevents label removal | Label removal blocked by admin | ✅ Pass |

---

## PowerShell Automation

| Script | Purpose |
|---|---|
| `Get-RecordLabels.ps1` | Export all record labels with configuration details |
| `Export-FilePlan.ps1` | Export full File Plan to CSV/JSON |
| `Get-RecordsManagementConfiguration.ps1` | Audit complete Records Management configuration |

```powershell
# Connect and retrieve all record labels
Connect-IPPSSession -UserPrincipalName admin@patchthecloud.onmicrosoft.com
.\scripts\Get-RecordLabels.ps1 -OutputPath ".\reports\record-labels.csv"
```

---

## Records Management vs Retention Labels

| Feature | Retention Label | Record Label | Regulatory Record |
|---|---|---|---|
| Retention settings | ✅ | ✅ | ✅ |
| Declare as record | ❌ | ✅ | ✅ |
| Prevent modification | ❌ | ✅ (when locked) | ✅ (always) |
| Admin can remove label | ✅ | ✅ | ❌ |
| Disposition review | Optional | Supported | Required |
| Compliance level | Standard | High | Highest |

---

## Lessons Learned

1. **Publishing ≠ Applying** — Publishing a record label makes it available to users; it does not automatically apply the label to existing content. Auto-apply policies are required for existing content.
2. **Unlock before lock** — The "Unlock this record by default" option allows users to edit content before formally locking the record. This is useful during document drafting phases.
3. **Regulatory Records cannot be removed** — Unlike standard Record Labels, Regulatory Records cannot be removed by administrators once applied. Test thoroughly before enabling in production.
4. **File Plan is read-only in Records Management** — The File Plan provides visibility but configuration changes must be made in Data Lifecycle Management.
5. **Disposition review requires licensing** — Disposition review workflows require Microsoft 365 E5 or the Compliance add-on.

---

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md) for full troubleshooting guidance.

| Issue | Resolution |
|---|---|
| Record label not visible in File Plan | Allow up to 24h for policy sync; verify label is published |
| Users can still edit declared records | Confirm "Mark items as a record" is enabled, not just "Mark items as regulatory record" |
| Disposition tab not visible | Verify Microsoft 365 E5 licensing; check admin role |
| Label not appearing in Office apps | Wait 24h post-publish; restart Office client |

---

## Future Improvements

- Implement event-based retention for contract expiry triggers
- Configure Regulatory Records for highest-sensitivity categories
- Enable disposition review for all record labels across workloads
- Integrate Records Management with Microsoft Purview eDiscovery
- Build Power BI dashboard from File Plan export data

---

## Repository Structure

```
Microsoft-Purview-Records-Management/
├── README.md
├── LICENSE
├── .gitignore
├── GITHUB-METADATA.md
├── WEBSITE-PORTFOLIO-CARD.md
├── Microsoft-Purview-Records-Management.html
├── architecture/
│   └── records-management-architecture.md
├── docs/
│   ├── 01-overview.md
│   ├── 02-record-labels.md
│   ├── 03-file-plan.md
│   ├── 04-event-based-retention.md
│   ├── 05-disposition-review.md
│   ├── 06-regulatory-records.md
│   ├── 07-validation.md
│   ├── troubleshooting.md
│   └── screenshots-placement-guide.md
├── scripts/
│   ├── Get-RecordLabels.ps1
│   ├── Export-FilePlan.ps1
│   └── Get-RecordsManagementConfiguration.ps1
└── images/
    ├── 01-overview/
    ├── 02-record-labels/
    │   ├── 01-mark-as-record-setting.png
    │   └── 02-label-policies-published.png
    ├── 03-file-plan/
    │   └── 01-file-plan-overview.png
    ├── 04-event-based-retention/
    ├── 05-disposition-review/
    ├── 06-regulatory-records/
    └── 07-validation/
```

---

## References

- [Microsoft Purview Records Management](https://learn.microsoft.com/en-us/microsoft-365/compliance/records-management)
- [Declare Records using Retention Labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/declare-records)
- [Overview of the File Plan](https://learn.microsoft.com/en-us/microsoft-365/compliance/file-plan-manager)
- [Disposition Review](https://learn.microsoft.com/en-us/microsoft-365/compliance/disposition)
- [MS-102 Exam Objectives](https://learn.microsoft.com/en-us/credentials/certifications/exams/ms-102)
- [TechCertGuide Blog Post](https://techcertguide.blog/records-management-in-microsoft-purview/)

---

*All configurations documented here reflect actual implementation in the Patchthecloud.onmicrosoft.com lab tenant. No results have been fabricated.*
