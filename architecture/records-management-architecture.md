# Records Management Architecture

## Diagram 1 — Enterprise Records Management Architecture

```mermaid
flowchart TB
    subgraph Content["Microsoft 365 Content Sources"]
        EXO[Exchange Online\nEmails & Mailboxes]
        SPO[SharePoint Online\nDocuments & Sites]
        ODB[OneDrive for Business\nPersonal Files]
        TMS[Microsoft Teams\nChannel Files]
    end

    subgraph Purview["Microsoft Purview Records Management"]
        RL[Record Labels\nMark as Record\nMark as Regulatory Record]
        FP[File Plan\nCentralised Visibility\nRetention Schedule]
        DR[Disposition Review\nReviewer Approval\nDestruction Certificate]
        EBR[Event-Based Retention\nContract Expiry\nEmployee Departure]
    end

    subgraph Governance["Records Governance Controls"]
        IMM[Immutability\nContent Cannot Be Modified\nContent Cannot Be Deleted]
        AUD[Audit Trail\nRecord Lifecycle Events\nChain of Custody]
        DISP[Disposition\nReview Approved\nPermanent Deletion]
    end

    subgraph Compliance["Regulatory Frameworks"]
        SEC[SEC Rule 17a-4\nFINRA 4511]
        ISO[ISO 15489\nRecords Management Standard]
        GDPR[GDPR Article 5\nData Minimisation]
        SOX[SOX\nFinancial Records]
    end

    Content --> RL
    RL --> FP
    RL --> IMM
    FP --> DR
    EBR --> DR
    DR --> DISP
    IMM --> AUD
    AUD --> Compliance
```

---

## Diagram 2 — Record Label Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ContentCreated : Document created in M365

    ContentCreated --> LabelPublished : Admin publishes record label via Label Policy

    LabelPublished --> LabelAvailable : Policy sync complete (up to 24h)

    LabelAvailable --> LabelApplied : User applies label\nOR auto-apply policy triggers

    LabelApplied --> RecordUnlocked : "Unlock by default" enabled\nUser can still edit

    LabelApplied --> RecordLocked : "Unlock by default" disabled\nEdit immediately blocked

    RecordUnlocked --> RecordLocked : User locks the record\nEdit now blocked permanently

    RecordLocked --> RetentionActive : Retention period counting down\nContent immutable

    RetentionActive --> PendingDisposition : Retention period expires

    PendingDisposition --> DispositionReview : Disposition review configured\nReviewer notified

    PendingDisposition --> PermanentDeletion : No disposition review\nAutomatic deletion

    DispositionReview --> PermanentDeletion : Reviewer approves deletion\nAudit record created

    DispositionReview --> RetentionExtended : Reviewer applies new label\nRetention period extended

    PermanentDeletion --> [*] : Record destroyed\nDestruction certificate in Audit log
```

---

## Diagram 3 — Disposition Review Workflow

```mermaid
flowchart LR
    A[Retention Period\nExpires] --> B{Disposition\nReview\nConfigured?}

    B -- No --> C[Automatic\nDeletion]
    B -- Yes --> D[Item Enters\nPending Disposition\nQueue]

    D --> E[Reviewer Notified\nvia Email]

    E --> F{Reviewer\nDecision}

    F -- Approve --> G[Item Permanently\nDeleted]
    F -- Relabel --> H[New Retention\nLabel Applied\nRetention Restarted]
    F -- Add Stage --> I[Escalate to\nNext Reviewer]

    G --> J[Audit Record\nCreated\nDestruction Certificate]
    H --> K[Item Returns\nto Active\nRetention]
    I --> F

    style G fill:#d4edda,color:#155724
    style C fill:#fff3cd,color:#856404
    style J fill:#cce5ff,color:#004085
```

---

## Diagram 4 — File Plan Architecture

```mermaid
flowchart TB
    subgraph FilePlan["File Plan — Records Management → File Plan"]
        direction TB
        FPView["Centralised Label View\n──────────────────\nLabel Name\nIs Record / Regulatory\nRetention Period\nRetention Action\nDisposition Type\nPublished Status"]
    end

    subgraph RecordCategories["Record Categories in this Implementation"]
        FR["MS102-Finance-Record\n7 Years | Retain & Delete\nIs Record: Yes\nScope: Finance Dept"]
    end

    subgraph Descriptors["ISO 15489 File Plan Descriptors"]
        FN[Function\nFinance]
        CAT[Category\nFinancial Statements]
        AUTH[Authority\nSEC Rule 17a-4]
        CIT[Citation\n17 CFR 240.17a-4]
    end

    subgraph Export["File Plan Export"]
        CSV[CSV Export\nQuarterly Audit]
        IMPORT[Bulk Import\nLegacy Migration]
    end

    RecordCategories --> FilePlan
    Descriptors --> FilePlan
    FilePlan --> Export
```

---

## Technology Stack

| Layer | Component | Purpose |
|---|---|---|
| Compliance Portal | compliance.microsoft.com | Administration and configuration |
| Records Management | Microsoft Purview Records Management | Record declaration, File Plan, Disposition |
| Data Lifecycle | Microsoft Purview DLM | Retention labels, label policies |
| Workloads | Exchange Online, SharePoint Online, OneDrive, Teams | Content locations |
| Automation | Security & Compliance PowerShell | Reporting and audit |
| Audit | Microsoft Purview Audit | Record lifecycle event logging |
| Identity | Microsoft Entra ID | Role-based access control |

---

## Records Management Portal Navigation

```
compliance.microsoft.com
└── Solutions
    ├── Data Lifecycle Management
    │   ├── Retention Labels          ← Create and configure record labels
    │   └── Label Policies            ← Publish labels to workloads
    └── Records Management
        ├── Overview
        ├── File Plan                 ← Centralised label visibility
        ├── Events                    ← Create event-based retention triggers
        └── Disposition               ← Review and approve pending dispositions
```
