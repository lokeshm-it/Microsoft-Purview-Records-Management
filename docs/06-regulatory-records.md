# Regulatory Records

## What Is a Regulatory Record?

A Regulatory Record is the highest level of content immutability available in Microsoft Purview Records Management. It extends the standard Record Label by adding constraints that apply even to Global Administrators:

- The Regulatory Record label **cannot be removed** by any user, including Global Administrators
- The content **cannot be deleted** by any user or administrator during the retention period
- Even Microsoft support cannot remove a Regulatory Record designation
- The label persists for the full retention period with no override capability

This level of protection is designed for content subject to strict regulatory mandates such as SEC Rule 17a-4(f), FINRA, CFTC, or equivalent requirements that mandate write-once, read-many (WORM) storage.

---

## Regulatory Record vs Record Label

| Property | Record Label | Regulatory Record |
|---|---|---|
| Prevents user editing | ✅ (when locked) | ✅ (always) |
| Prevents user deletion | ✅ | ✅ |
| Admin can remove label | ✅ | ❌ |
| Global Admin can remove | ✅ | ❌ |
| Microsoft support can remove | ✅ | ❌ |
| Appropriate for SEC 17a-4 | ❌ | ✅ |
| Reversible | Yes | No |

> **Critical:** Because Regulatory Records cannot be removed by anyone, this setting must be thoroughly tested and validated before enabling in production. Misapplication of Regulatory Record labels creates irreversible constraints on content for the full retention period.

---

## Enabling the Regulatory Record Setting

### Pre-Requisite: Enable via PowerShell

The Regulatory Record option is not enabled by default in the Microsoft Purview portal. It must be enabled by a tenant administrator using Security & Compliance PowerShell:

```powershell
Connect-IPPSSession -UserPrincipalName admin@patchthecloud.onmicrosoft.com

Set-RegulatoryComplianceUI -Enabled $true
```

After running this command, refresh the compliance portal. The **Mark items as a regulatory record** option becomes available in label configuration.

> **Warning:** This command cannot be reversed. Once enabled, the Regulatory Record option remains permanently available in the portal.

### Configuring a Regulatory Record Label

```
Data Lifecycle Management → Retention Labels → Create a label
```

On the **Define record management settings** page, select:
> **Mark items as a regulatory record**

Note that selecting this option automatically removes the "Unlock this record by default" option — Regulatory Records are always locked immediately upon application.

---

## Use Cases for Regulatory Records

| Industry | Record Type | Regulatory Requirement |
|---|---|---|
| Financial services | Trading records, order books | SEC Rule 17a-4(f), FINRA 4511 |
| Healthcare | Clinical trial data | FDA 21 CFR Part 11 |
| Government | Official government records | NARA regulations |
| Legal | Court-ordered preservation | Legal hold orders |
| Energy | Environmental compliance records | EPA requirements |

---

## Lab Environment Note

In the Patchthecloud.onmicrosoft.com lab tenant, Regulatory Records were evaluated but not deployed to production content. The lab validated:

- The `Set-RegulatoryComplianceUI -Enabled $true` command successfully enables the option
- The "Mark items as a regulatory record" option appears in the label wizard after enabling
- A test label was created and verified in the File Plan with Regulatory Record = Yes

Full deployment to production content was not completed in the lab to avoid creating irreversible constraints on test content.

---

## Security Controls

### Immutability Guarantee

Regulatory Records provide an immutability guarantee that satisfies WORM (Write Once, Read Many) requirements:
- Content cannot be overwritten
- Content cannot be deleted before retention period expires
- Label cannot be removed or replaced
- Retention period cannot be shortened

### Chain of Custody

All access and modification attempts against Regulatory Records are captured in the Microsoft Purview Audit log, providing a complete chain of custody record for forensic and regulatory review purposes.

---

## MS-102 Exam Guidance

**Scenario:** A financial organisation must comply with SEC Rule 17a-4 by ensuring broker-dealer communications cannot be deleted or modified by any user, including administrators.

**Correct answer:** Regulatory Record label.

**Key distinction:** Only Regulatory Records provide the WORM-level immutability required by SEC Rule 17a-4. Standard Record Labels can be removed by administrators and do not satisfy this requirement.

---

## Related Documentation

- [02 — Record Labels](02-record-labels.md)
- [05 — Disposition Review](05-disposition-review.md)
- [07 — Validation](07-validation.md)
