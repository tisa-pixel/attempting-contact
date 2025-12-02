# Technical Requirements

## Business Rules (Confirmed)

| Rule | Decision |
|------|----------|
| **Trigger** | Lead.Status = `Attempting_Contact` |
| **Timeline Anchor** | `Last_Submission_Date__c` |
| **Task Owner** | Always Lead Owner |
| **Business Hours** | 8 AM - 7 PM only |
| **Weekends** | Nothing fires until Monday |
| **After-hours tasks** | Push to next business day 8 AM |
| **Exit Conditions** | Status changes FROM Attempting_Contact |
| **On Exit** | Delete all incomplete cadence tasks |
| **Lead Owner Changes** | Reassign all open cadence tasks to new owner |
| **Re-entry within 5 days** | Pick up where they left off |
| **Re-entry after 5 days** | Restart cadence from Day 0 |
| **Total Touchpoints** | 17 over 14 days |

## Merge Fields

| Placeholder | Salesforce Field |
|-------------|------------------|
| `[Name]` | `Lead.FirstName` |
| `[Address]` | `Lead.Property_Address__c` |
| `[Neighborhood]` | `Lead.Property_City__c` |
| `[Company]` | "REI Team" (hardcoded) |
| `[Lead Manager First Name]` | `Owner.FirstName` |
| `[Lead Manager Phone]` | `Owner.Phone` |
| `[Nearby Street]` | Dynamic lookup (recent closed deal nearby) |

---

## Salesforce Configuration Needed

### 1. Custom Fields

**Task.Cadence_Name__c** (Text 50)
- Purpose: Identify cadence tasks for cleanup/reporting
- Value: "Attempting Contact"

**Task.Cadence_Day__c** (Number) - Optional
- Purpose: Track which day in cadence (for reporting)

### 2. Task Type Picklist Values

Add to `Task.Type` standard field:
- `Call`
- `Text`
- `Email`

### 3. Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    ENTRY TRIGGER                            │
│  Lead.Status changes TO "Attempting_Contact"                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ REILeadCadenceDay0Immediate (Apex)                  │   │
│  │ - First Contact Text (immediate)                    │   │
│  │ - First Call (immediate, treat +2min as immediate)  │   │
│  │ - Personal Email (immediate, treat +10min as immed) │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Flow Scheduled Path: +4 hours                       │   │
│  │ → REILeadCadenceDay0FourHour (Apex)                 │   │
│  │   - Second Call + VM                                │   │
│  │   - Respects business hours (push if after 7 PM)    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Daily Scheduled Job: 8 AM                           │   │
│  │ → REILeadCadenceScheduled (Apex)                    │   │
│  │   - Evening Text for Day 0 leads                    │   │
│  │   - All tasks for Days 1-14                         │   │
│  │   - Skips weekends (runs Monday for Sat/Sun leads)  │   │
│  │   - Checks re-entry logic (5-day window)            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    EXIT TRIGGER                             │
│  Lead.Status changes FROM "Attempting_Contact"              │
├─────────────────────────────────────────────────────────────┤
│  → Delete Tasks WHERE:                                      │
│      WhoId = Lead.Id                                        │
│      IsClosed = false                                       │
│      Cadence_Name__c = "Attempting Contact"                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 OWNER CHANGE TRIGGER                        │
│  Lead.OwnerId changes                                       │
├─────────────────────────────────────────────────────────────┤
│  → Update Tasks SET OwnerId = new Lead.OwnerId WHERE:       │
│      WhoId = Lead.Id                                        │
│      IsClosed = false                                       │
│      Cadence_Name__c = "Attempting Contact"                 │
└─────────────────────────────────────────────────────────────┘
```

### 4. Apex Classes

| Class | Purpose | Trigger |
|-------|---------|---------|
| `REILeadCadenceDay0Immediate` | Creates 3 immediate tasks | Flow @InvocableMethod |
| `REILeadCadenceDay0FourHour` | Creates +4 hour task | Flow Scheduled Path |
| `REILeadCadenceScheduled` | Creates Day 0 evening + Days 1-14 | Scheduled Job (8 AM daily) |
| `REILeadCadenceHelper` | Shared utilities (business hours, weekends, merge fields) | Called by other classes |
| `REILeadCadenceCleanup` | Deletes incomplete tasks on exit | Flow @InvocableMethod |
| `REILeadCadenceReassign` | Reassigns tasks on owner change | Trigger |

### 5. Day 0 Timing Logic

When status changes to Attempting_Contact at time T:

| Task | Due DateTime | Business Hours Handling |
|------|--------------|-------------------------|
| First Contact - Text | T (immediate) | If after 7 PM → next biz day 8 AM |
| First Call - No VM | T (immediate) | If after 7 PM → next biz day 8 AM |
| Personal Email | T (immediate) | If after 7 PM → next biz day 8 AM |
| Second Call + VM | T + 4 hours | If lands after 7 PM → next biz day 8 AM |
| Evening Text | Same day 6:00 PM | Created by daily job; if weekend → Monday |

### 6. Days 1-14 Timing

All created by daily scheduled job at 8 AM. Weekend leads get Monday tasks.

| Day | Time | Task | Type |
|-----|------|------|------|
| 1 | 10:00 AM | Third Call | Call |
| 1 | 2:00 PM | Value Proposition Email | Email |
| 1 | 5:00 PM | Evening Check Text | Text |
| 2 | 11:00 AM | Fourth Call | Call |
| 4 | 10:00 AM | Address the Elephant Email | Email |
| 5 | 2:00 PM | Direct Question Text | Text |
| 6 | 3:00 PM | Fifth Call | Call |
| 7 | 10:00 AM | The Real Cost Email | Email |
| 9 | 11:00 AM | Permission to Help Text | Text |
| 11 | 2:00 PM | Sixth Call + Leave VM | Call |
| 13 | 10:00 AM | Permission to Close Email | Email |
| 14 | EOD | Move to Nurture | Task |

### 7. Re-entry Logic

```
IF Lead.Status changes TO "Attempting_Contact":
    days_since_last = TODAY - Last_Submission_Date__c

    IF days_since_last <= 5:
        # Pick up where they left off
        # Calculate current cadence day and create remaining tasks
        current_day = days_since_last
        # Don't update Last_Submission_Date__c
    ELSE:
        # Restart from Day 0
        Last_Submission_Date__c = TODAY
        # Create Day 0 tasks
```

### 8. Email Templates Needed

Create in folder "Attempting Contact":

| # | Template Name | Day | Subject Line |
|---|--------------|-----|--------------|
| 1 | AC_Personal_Email | 0 | {!Lead.FirstName} - {!Lead.Property_Address__c} |
| 2 | AC_Value_Proposition | 1 | What makes us different (probably not what you think) |
| 3 | AC_Address_Elephant | 4 | You're probably thinking... |
| 4 | AC_Real_Cost | 7 | What selling traditionally ACTUALLY costs |
| 5 | AC_Permission_Close | 13 | Can I close your file? |

### 9. Duplicate Prevention

Each Apex class checks before creating:
```apex
List<Task> existing = [
    SELECT Id FROM Task
    WHERE WhoId = :leadId
    AND Subject = :taskName
    AND Cadence_Name__c = 'Attempting Contact'
    AND ActivityDate = :dueDate
];
if (existing.isEmpty()) {
    // Create task
}
```

---

## Dependencies

- Salesforce Edition: Enterprise+ (for Scheduled Paths in Flow)
- Lead Owner must have Phone populated for merge field
- Property_Address__c and Property_City__c should be populated on Leads
- Lead.Last_Submission_Date__c must exist

---

## Files in This Repo

```
attempting-contact/
├── README.md                 # Overview
├── REQUIREMENTS.md           # This file
├── cadence-data.csv          # Full cadence with scripts
├── email-templates/          # Email template content
│   ├── AC_Personal_Email.html
│   ├── AC_Value_Proposition.html
│   ├── AC_Address_Elephant.html
│   ├── AC_Real_Cost.html
│   └── AC_Permission_Close.html
└── salesforce/               # Metadata for deployment
    ├── classes/
    ├── flows/
    ├── objects/
    └── package.xml
```
