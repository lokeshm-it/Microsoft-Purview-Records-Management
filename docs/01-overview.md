# Records Management in Microsoft Purview — Overview

## What Is Records Management?

Microsoft Purview Records Management is a compliance solution that enables organisations to manage the complete lifecycle of business records across Microsoft 365. It extends the capabilities of retention labels and data lifecycle management by introducing formal record declaration, enhanced content protection, structured disposition workflows, and centralised governance visibility.

Records Management is positioned as the highest tier of content governance within Microsoft Purview — above standard retention policies and retention labels — and is designed for content that carries legal, regulatory, or business-critical significance.

---

## Why Records Management Is Required

Organisations operating in regulated industries or subject to legal obligations must demonstrate that:

- Records are retained for the required statutory or regulatory period
- Records cannot be modified or deleted during the retention period
- Disposal of records is authorised and documented
- An audit trail exists for all record lifecycle events

Without Records Management controls, content managed through standard retention labels remains editable and may be deleted by users within the retention period, creating compliance exposure.

---

## Business Context

This implementation addresses the following business scenarios:

| Record Category | Regulatory Obligation | Retention Requirement |
|---|---|---|
| Financial statements | SEC Rule 17a-4, SOX | 7 years minimum |
| HR records | Employment law | Duration of employment + 7 years |
| Legal contracts | Contract law | Duration + 10 years |
| Audit reports | ISO 27001, SOC 2 | 5 years |
| Compliance policies | GDPR Article 5 | 3 years post-update |
| Board meeting minutes | Corporate governance | 10 years |

---

## Records Management vs Data Lifecycle Management

| Capability | Data Lifecycle Management | Records Management |
|---|---|---|
| Retention policies (workload-wide) | ✅ | ❌ |
| Retention labels (item-level) | ✅ | ✅ (via record labels) |
| Prevent user modification | ❌ | ✅ |
| Prevent admin label removal | ❌ | ✅ (Regulatory only) |
| Disposition review workflow | ❌ | ✅ |
| File Plan visibility | ❌ | ✅ |
| Chain of custody audit trail | Partial | Full |
| Event-based retention triggers | ✅ | ✅ |

---

## Key Components

### Record Labels
Retention labels configured with "Mark items as a record". Once content is labelled, users cannot edit or delete it. Only compliance administrators can modify record label configurations.

### Regulatory Records
The highest level of immutability. Once declared as a Regulatory Record, no administrator — including Global Administrators — can remove the label. This setting is appropriate for content subject to SEC Rule 17a-4 or equivalent mandates.

### File Plan
A centralised management view within Records Management that displays all retention and record labels, their retention durations, disposition actions, and record type designations. The File Plan supports export to CSV for reporting and audit purposes.

### Disposition Review
A workflow capability that routes content to designated reviewers when the retention period expires. Reviewers must approve or reject deletion before content is permanently removed. An audit log is maintained for all disposition decisions.

### Event-Based Retention
Retention periods triggered by a specific business event rather than content creation or modification date. Common use cases include contract expiry, employee departure, or project closure.

---

## Licensing Requirements

| Capability | License Required |
|---|---|
| Record Labels (basic) | Microsoft 365 E3 |
| Regulatory Records | Microsoft 365 E5 / Compliance add-on |
| Disposition Review | Microsoft 365 E5 / Compliance add-on |
| File Plan | Microsoft 365 E5 / Compliance add-on |
| Event-Based Retention | Microsoft 365 E5 / Compliance add-on |
| Audit log (Records Management events) | Microsoft 365 E5 |

---

## Admin Roles Required

| Role | Purpose |
|---|---|
| Records Management | Full access to Records Management portal |
| Compliance Administrator | Access to compliance portal and label configuration |
| Compliance Data Administrator | Read and manage compliance data |
| Disposition Management | Approve or reject disposition reviews |

---

## Navigation

Access Records Management via:

```
compliance.microsoft.com → Solutions → Records Management
```

Or direct URL: `https://compliance.microsoft.com/recordsmanagement`

---

## Related Documentation

- [02 — Record Labels](02-record-labels.md)
- [03 — File Plan](03-file-plan.md)
- [04 — Event-Based Retention](04-event-based-retention.md)
- [05 — Disposition Review](05-disposition-review.md)
- [06 — Regulatory Records](06-regulatory-records.md)
- [07 — Validation](07-validation.md)
