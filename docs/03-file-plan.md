# File Plan

## What Is the File Plan?

The File Plan is a centralised management view within Microsoft Purview Records Management that provides visibility into all retention labels and record labels configured across the organisation. It is the primary interface for records administrators to audit, manage, and export the organisation's records retention schedule.

The File Plan aggregates:
- All retention labels from Data Lifecycle Management
- All record labels configured with record declaration settings
- Retention periods, actions, and disposition settings
- Record type designations (Standard, Record, Regulatory Record)
- Label status and publication state

---

## Navigating the File Plan

```
compliance.microsoft.com → Solutions → Records Management → File Plan
```

![File Plan — centralised view of record labels and retention settings](../images/03-file-plan/01-file-plan-overview.png)
*Appendix A.2 — File Plan — Records Management → File Plan — MS102-Finance-Record label visible with Is Record = Yes*

---

## File Plan Columns

| Column | Description |
|---|---|
| **Label name** | Display name of the retention or record label |
| **Label status** | Active / Inactive |
| **Retention period** | Duration in days, months, or years |
| **Retention action** | Retain only / Delete only / Retain and delete |
| **Is record** | Yes / No — indicates record declaration |
| **Regulatory record** | Yes / No — indicates regulatory designation |
| **Disposition type** | None / Disposition review |
| **Based on** | When created / When modified / Event |
| **Published** | Yes / No — whether published via label policy |

---

## Lab File Plan — MS102-Finance-Record

After publishing the MS102-Finance-Record label, the File Plan confirms the following configuration:

| Field | Value |
|---|---|
| Label name | MS102-Finance-Record |
| Label status | Active |
| Retention period | 7 Years |
| Retention action | Retain and delete |
| Is record | Yes |
| Regulatory record | No |
| Disposition type | None (Disposition review not yet configured) |
| Based on | When items were created |
| Published | Yes |

---

## File Plan Import and Export

### Exporting the File Plan

The File Plan can be exported to a CSV file for audit documentation, regulatory submissions, or records schedule reporting.

```
Records Management → File Plan → Export
```

The exported CSV contains all fields visible in the File Plan view and is suitable for submission to records governance auditors.

### Importing Labels via File Plan

For organisations migrating from legacy records management systems, labels can be imported in bulk using the File Plan import feature:

```
Records Management → File Plan → Import
```

The import template includes columns for:
- Label name and description
- Retention period and action
- Record type designation
- File plan descriptors (function, category, authority, citation)

---

## File Plan Descriptors

The File Plan supports additional metadata descriptors that align with the ISO 15489 records management standard:

| Descriptor | Purpose |
|---|---|
| **Function** | Business function the record supports (e.g., Finance, Legal) |
| **Category** | Specific record category (e.g., Accounts Payable, Contracts) |
| **Authority type** | Regulatory authority requiring the retention (e.g., SEC, GDPR) |
| **Authority citation** | Specific regulation or rule citation |
| **Provision** | Provision number within the cited regulation |
| **Reference ID** | Internal records schedule reference |

These descriptors are optional in the lab environment but should be populated in production for ISO 15489 compliance.

---

## File Plan and eDiscovery Integration

The File Plan provides visibility into which items are declared as records. During eDiscovery investigations:

- Items with record labels are preserved independently of eDiscovery holds
- Record status is visible in Content Search results
- Disposition review status is auditable through the Audit log

---

## Best Practices

1. **Review the File Plan after every label change** — Confirm new or modified labels appear with the correct record designation before publishing.
2. **Export quarterly** — Maintain quarterly File Plan exports as audit evidence.
3. **Use File Plan descriptors** — Populate Authority and Citation fields to align with regulatory frameworks.
4. **Separate record from non-record labels** — Filter the File Plan by "Is record = Yes" to review only declared records.

---

## Related Documentation

- [02 — Record Labels](02-record-labels.md)
- [05 — Disposition Review](05-disposition-review.md)
- [07 — Validation](07-validation.md)
