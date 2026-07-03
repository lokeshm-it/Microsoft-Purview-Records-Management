# Disposition Review

## What Is Disposition Review?

Disposition review is a Microsoft Purview Records Management workflow that requires one or more designated reviewers to approve or reject the deletion of content when its retention period expires. Without an approved disposition review, content is not permanently deleted — it remains preserved in a pending disposition state.

This capability provides a human-controlled checkpoint in the record disposal process, satisfying regulatory requirements that mandate documented authorisation before record destruction.

---

## Why Disposition Review Matters

Many regulatory frameworks require that:
- Record destruction is authorised by a designated records officer
- A destruction certificate or audit log is maintained
- Reviewers have the opportunity to extend retention if circumstances change
- Destruction decisions are documented and attributable to a named individual

Disposition review directly addresses these requirements within Microsoft 365, without requiring external records management systems.

---

## Configuring Disposition Review

### Step 1 — Assign Disposition Management Role

```
compliance.microsoft.com → Permissions → Compliance roles
```

Assign users to the **Disposition Management** role group. This role is required to:
- Appear as a disposition reviewer
- Approve or reject disposition decisions
- Access the Disposition tab in Records Management

### Step 2 — Enable Disposition Review on a Label

When creating or editing a retention label:

```
Data Lifecycle Management → Retention Labels → Create/Edit label
```

On the **Choose what happens after the retention period** page:
- Select: **Trigger a disposition review**
- Add reviewers: Enter UPNs of designated records officers

Multiple review stages can be configured for multi-level approval processes.

### Step 3 — Monitor Pending Dispositions

```
Records Management → Disposition → Pending dispositions
```

When items reach the end of their retention period, they appear in the Pending dispositions view. Reviewers receive email notifications and can:
- **Approve for deletion:** Item is permanently deleted; audit record created
- **Relabel:** Apply a different retention label to extend retention
- **Add another stage:** Route to additional reviewer
- **Export:** Download list of pending items for offline review

---

## Multi-Stage Disposition Review

For high-value records, multi-stage review ensures that deletion requires approval from multiple stakeholders:

| Stage | Reviewer Role | Action |
|---|---|---|
| Stage 1 | Department Records Officer | Initial review and approval |
| Stage 2 | Compliance Officer | Secondary approval |
| Stage 3 | Legal Counsel | Final approval for legal records |

---

## Audit Trail

All disposition decisions are recorded in Microsoft Purview Audit:

| Event | Audit Activity |
|---|---|
| Item entered pending disposition | DispositionReviewPending |
| Disposition approved | DispositionReviewApproved |
| Disposition rejected | DispositionReviewRejected |
| Item relabelled during review | DispositionReviewRelabelled |
| Reviewer added | DispositionReviewerAdded |

The audit trail provides a defensible destruction certificate that demonstrates regulatory compliance.

---

## Disposition Review Notifications

Reviewers receive email notifications when:
- Items are pending disposition review
- A review stage is approaching its deadline
- Another reviewer has taken action on an item

Notifications are sent to the email address associated with the reviewer's Microsoft 365 account.

---

## Licensing Requirement

Disposition review requires **Microsoft 365 E5** or the Microsoft Purview Compliance add-on. This capability is not available in E3 tenants.

---

## MS-102 Exam Guidance

**Scenario:** An organisation requires a compliance officer to approve deletion of all financial records before they are permanently removed at the end of the retention period.

**Correct answer:** Enable **Trigger a disposition review** on the retention label and assign the compliance officer as a reviewer.

**Key distinction:** Without disposition review, content is automatically deleted at retention period end. With disposition review, content is held pending human approval.

---

## Related Documentation

- [02 — Record Labels](02-record-labels.md)
- [06 — Regulatory Records](06-regulatory-records.md)
- [07 — Validation](07-validation.md)
