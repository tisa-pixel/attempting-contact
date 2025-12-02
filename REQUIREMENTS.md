# Technical Requirements

## Salesforce Configuration Needed

### 1. Task Type Picklist Values
Add to `Task.Type` standard field:
- `Call`
- `Text`
- `Email`

### 2. Flow Architecture

**Trigger Flow: "Attempting Contact - Start Cadence"**
- Fires when: `Lead.Status` changes TO `Attempting_Contact`
- Action: Creates Day 0 tasks with exact time offsets
- Scheduled Paths: Days 1, 2, 4, 5, 6, 7, 9, 11, 13, 14

**Exit Flow: "Attempting Contact - Exit Cadence"**
- Fires when: `Lead.Status` changes FROM `Attempting_Contact` to any other value
- Action: Delete all open Tasks where:
  - `WhoId = Lead.Id`
  - `Status != 'Completed'`
  - Task was created by the cadence (need identifier)

### 3. Task Identification

To identify cadence-created tasks for cleanup, options:
- **Option A**: Custom field `Task.Cadence_Name__c` = "Attempting Contact"
- **Option B**: Task Subject prefix pattern
- **Option C**: Custom field `Task.Is_Cadence_Task__c` = true

**Recommendation**: Option A - allows for multiple cadences later

### 4. Day 0 Timing Logic

When status changes to Attempting_Contact at time T:
| Task | Due DateTime |
|------|--------------|
| First Contact - Text | T (immediate) |
| First Call - No VM | T + 2 minutes |
| Personal Email | T + 10 minutes |
| Second Call + VM | T + 4 hours |
| Evening Text | Same day 6:00 PM (Lead Owner timezone) |

**Edge case**: If status changes after 6 PM, Evening Text → next day 6 PM? Or skip?

### 5. Subsequent Days Timing

| Day | Time | Task |
|-----|------|------|
| 1 | 10:00 AM | Third Call |
| 1 | 2:00 PM | Value Proposition Email |
| 1 | 5:00 PM | Evening Check Text |
| 2 | 11:00 AM | Fourth Call |
| 4 | 10:00 AM | Address the Elephant Email |
| 5 | 2:00 PM | Direct Question Text |
| 6 | 3:00 PM | Fifth Call |
| 7 | 10:00 AM | The Real Cost Email |
| 9 | 11:00 AM | Permission to Help Text |
| 11 | 2:00 PM | Sixth Call + VM |
| 13 | 10:00 AM | Permission to Close Email |
| 14 | EOD | Move to Nurture (status change task) |

### 6. Email Templates Needed

Create in folder "Attempting Contact":
1. Personal Email from Lead Manager (Day 0)
2. Value Proposition (Day 1)
3. Address the Elephant (Day 4)
4. The Real Cost (Day 7)
5. Permission to Close File (Day 13)

### 7. Dynamic [Nearby Street] Field

Options:
- Query recent Opportunities/Closed Won near Lead's property
- Store in custom field `Lead.Recent_Nearby_Sale__c`
- Fallback: "a nearby street" placeholder

## Open Questions

1. ~~What triggers the cadence?~~ ✅ Status = Attempting_Contact
2. ~~What's the anchor date field?~~ ✅ Last_Submission_Date__c
3. ~~Exit conditions?~~ ✅ Any status change + delete incomplete tasks
4. **Edge case**: Status changes after 6 PM - skip evening text or next day?
5. **Edge case**: Weekends - do Day 1, Day 2 tasks still fire on Sat/Sun?
6. **[Nearby Street]** - implement dynamic lookup or use placeholder for now?

## Dependencies

- Salesforce Edition: Enterprise+ (for Scheduled Paths in Flow)
- Lead Owner must have Phone populated for merge field
- Property_Address__c and Property_City__c should be populated on Leads
