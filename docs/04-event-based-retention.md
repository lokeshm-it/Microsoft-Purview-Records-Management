# Event-Based Retention

## Overview

Event-based retention is a Microsoft Purview Records Management capability that triggers the start of a retention period based on a specific business event rather than the date content was created or last modified. This makes it suitable for record categories where the retention obligation begins at a point in time unrelated to when the document was first created.

---

## Common Event-Based Retention Use Cases

| Record Category | Triggering Event | Retention Period |
|---|---|---|
| Employment contracts | Employee departure date | 7 years post-departure |
| Client contracts | Contract expiry date | 10 years post-expiry |
| Project records | Project closure date | 5 years post-closure |
| Product records | Product discontinuation date | Duration of product life + 10 years |
| Legal case files | Case closure date | 10 years post-closure |
| Insurance policies | Policy expiry date | 7 years post-expiry |

---

## How Event-Based Retention Works

```
Content Created → Retention Label Applied → Event Occurs → Retention Period Starts → Retention Period Expires → Disposition
```

Without event-based retention, the retention period begins when the content is created or modified. With event-based retention:

1. The retention label is applied to content at any point
2. The retention period does not start until the specified event occurs
3. When the event is registered in Microsoft Purview, the retention period begins for all content with that label and the matching asset ID
4. At the end of the retention period, disposition action (delete or disposition review) is triggered

---

## Configuring Event-Based Retention

### Step 1 — Create an Event Type

```
Records Management → Events → Event types → Add event type
```

Configure:
- **Event type name:** `Employee Departure`
- **Description:** Triggers HR record retention for departing employees

Microsoft Purview includes built-in event types:
- Employee activity
- Product lifetime
- Contract duration

### Step 2 — Create a Retention Label with Event-Based Trigger

```
Data Lifecycle Management → Retention Labels → Create a label
```

On the **Define retention settings** page:
- **Retain items for:** 7 years
- **Start the retention period based on:** An event

Select the event type: `Employee Departure`

Enable: **Mark items as a record** (if record declaration is required)

### Step 3 — Publish the Label

Publish the event-based retention label to the appropriate workloads or user groups.

### Step 4 — Apply the Label to Content

Apply the label to HR records (e.g., employee files in SharePoint, OneDrive). Also set an **Asset ID** — a value that links the content to a specific employee record. The Asset ID is set in the file's SharePoint properties column.

### Step 5 — Create the Event

When an employee departs:

```
Records Management → Events → Create
```

Configure:
- **Event type:** Employee Departure
- **Event name:** Employee Departure — [Employee Name]
- **Event date:** Departure date
- **Asset IDs:** Employee ID value (e.g., `EMP-10042`)

Microsoft Purview then starts the retention period for all content with the Employee Departure event label and the matching Asset ID.

---

## Asset ID Matching

Asset IDs are used to link events to specific content. Without an Asset ID, an event starts the retention period for ALL content with that label tenant-wide — which is rarely the intended behaviour.

| Without Asset ID | With Asset ID |
|---|---|
| Event starts retention for all matching labelled content | Event starts retention only for content with matching Asset ID |
| Use for events that affect all records of a type | Use for events tied to specific individuals, contracts, or projects |

---

## Licensing and Limitations

- Event-based retention requires **Microsoft 365 E5** or the Compliance add-on
- Asset IDs must be set before the event is created — retroactive assignment is not supported
- Events can be created via the compliance portal or via REST API (Graph)
- Event creation via Microsoft Graph supports automated integration with HR, CRM, or project management systems

---

## MS-102 Exam Guidance

**Scenario:** An organisation must retain employee files for 7 years from the date the employee leaves the company, not from when the files were created.

**Correct answer:** Event-based retention with "Employee activity" event type.

**Key distinction:** Event-based retention starts from an event date. All other retention options start from content creation, modification, or label application date.

---

## Related Documentation

- [02 — Record Labels](02-record-labels.md)
- [05 — Disposition Review](05-disposition-review.md)
- [07 — Validation](07-validation.md)
