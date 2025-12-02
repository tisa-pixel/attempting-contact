# Attempting Contact - Lead Follow-up Cadence

Salesforce Lead follow-up workflow using Chris Voss negotiation techniques.

## Overview

A 14-day, 17-touch cadence for Leads in "Attempting Contact" status who haven't been reached yet. Tasks are created **only on the day they're due** - never all at once.

## Business Rules

| Rule | Detail |
|------|--------|
| **Trigger** | Lead.Status = `Attempting_Contact` |
| **Timeline Anchor** | `Last_Submission_Date__c` |
| **Task Owner** | Always Lead Owner |
| **Exit Conditions** | Status changes to Warm, Nurture, Archive, or Converted |
| **On Exit** | Stop creating new tasks AND delete any incomplete tasks |
| **Phone Call Limit** | Max 1 call per 4-hour period |
| **Task Content** | Script + Coaching Notes in Task body |

## Merge Fields

| Placeholder | Salesforce Field |
|-------------|------------------|
| `[Name]` | `Lead.FirstName` |
| `[Address]` | `Lead.Property_Address__c` |
| `[Neighborhood]` | `Lead.Property_City__c` |
| `[Company]` | "REI Team" (hardcoded) |
| `[Lead Manager First Name]` | `Owner.FirstName` |
| `[Lead Manager Phone]` | `Owner.Phone` |
| `[Nearby Street]` | Dynamic (TBD - recent closed deal nearby) |

## Cadence Summary

| Day | Touches | Channels |
|-----|---------|----------|
| 0 | 5 | Text → Call → Email → Call+VM → Text |
| 1 | 3 | Call → Email → Text |
| 2 | 1 | Call |
| 4 | 1 | Email |
| 5 | 1 | Text |
| 6 | 1 | Call |
| 7 | 1 | Email |
| 9 | 1 | Text |
| 11 | 1 | Call+VM |
| 13 | 1 | Email |
| 14 | 1 | Status → Nurture |

**Total: 17 touches over 14 days**

## Files

- `cadence-data.csv` - Full cadence with scripts and coaching notes
- `REQUIREMENTS.md` - Detailed technical requirements
- `email-templates/` - Email template content for Salesforce
- `salesforce/` - Metadata for deployment

## Status

🚧 In Development

---
*Chris Voss techniques: Tactical empathy, labeling, mirroring, calibrated questions*
