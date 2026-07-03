# Troubleshooting — Microsoft Purview Records Management

## Common Issues and Resolutions

### Record Label Not Visible in File Plan

**Symptom:** After creating a record label, it does not appear in `Records Management → File Plan`.

**Cause:** Label has not been published via a label policy, or synchronisation is still in progress.

**Resolution:**
1. Confirm the label is published: `Data Lifecycle Management → Label Policies`
2. Allow up to 24 hours for synchronisation
3. Verify the label policy includes the record label and is assigned to users

---

### "Mark items as a regulatory record" Option Not Visible

**Symptom:** The Regulatory Record option does not appear in label configuration.

**Cause:** Regulatory Record UI must be explicitly enabled via PowerShell before it appears in the portal.

**Resolution:**
```powershell
Connect-IPPSSession -UserPrincipalName admin@patchthecloud.onmicrosoft.com
Set-RegulatoryComplianceUI -Enabled $true
```

Refresh the compliance portal after running this command.

---

### Users Can Still Delete Content After Record Label Is Applied

**Symptom:** A SharePoint document with a record label can still be deleted by users.

**Cause 1:** The label is a standard retention label, not a record label (Is Record = No in File Plan).

**Resolution:** Verify the label has "Mark items as a record" enabled in its configuration.

**Cause 2:** The label was applied to the wrong content, or the policy has not synchronised.

**Resolution:** Allow 24 hours for label policy to sync. Verify the label is applied to the specific item.

**Cause 3:** The user has site owner or higher permissions which may bypass label controls in some configurations.

**Resolution:** Test deletion with a standard user account (not SharePoint site owner or higher).

---

### Disposition Tab Not Visible in Records Management

**Symptom:** The Disposition tab does not appear in `Records Management`.

**Cause:** User is not assigned the Disposition Management role.

**Resolution:**
```
compliance.microsoft.com → Permissions → Compliance roles → Disposition Management → Edit → Add members
```

The user must also have at least Compliance Reader access to view Records Management.

---

### File Plan Export Returns Empty CSV

**Symptom:** Exporting the File Plan produces a CSV with headers but no data rows.

**Cause:** No labels are published or the tenant has no retention labels configured.

**Resolution:**
1. Verify labels exist in `Data Lifecycle Management → Retention Labels`
2. Verify at least one label is published via a label policy
3. Wait 24 hours post-publish before exporting

---

### Event-Based Retention Not Starting

**Symptom:** After creating an event, the retention period does not start for labelled content.

**Cause 1:** Asset ID mismatch — the Asset ID in the event does not match the Asset ID property on the content.

**Resolution:** Verify the Asset ID value set on the SharePoint item (via file properties) exactly matches the Asset ID specified when creating the event.

**Cause 2:** Event type mismatch — the label uses a different event type than the event that was created.

**Resolution:** Confirm the event type in the label's retention settings matches the event type selected when creating the event.

---

### Record Label Not Appearing in Office Apps

**Symptom:** Users cannot see the record label in the Sensitivity/Label selector in Word, Outlook, etc.

**Cause:** Record labels (retention labels) do not appear in the Office app sensitivity bar. They are applied via:
- Manual application in SharePoint/OneDrive document properties
- Auto-apply policies
- Default label on a SharePoint library

**Resolution:** Record labels are not applied from Office apps the same way as sensitivity labels. Train users to apply them via SharePoint file properties or configure auto-apply policies.

---

### Compliance Portal Shows "Access Denied" for Records Management

**Symptom:** Navigating to Records Management shows an access denied error.

**Cause:** User is not assigned the Records Management role.

**Resolution:**
```
compliance.microsoft.com → Permissions → Compliance roles → Records Management → Add members
```

---

## Related Documentation

- [01 — Overview](01-overview.md)
- [02 — Record Labels](02-record-labels.md)
- [06 — Regulatory Records](06-regulatory-records.md)
- [07 — Validation](07-validation.md)
