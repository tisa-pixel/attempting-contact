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

✅ **Live in Production** - Deployed December 2, 2025

---

## Why This Matters for REI Teams

### The Problem
REI teams lose deals because follow-up is inconsistent. Reps forget to call back, send generic messages, or give up after 2-3 attempts. Industry data shows it takes 8-12 touches to reach a motivated seller, but most reps stop at 3.

### The Solution
This automated cadence ensures:

1. **More Deals Closed** - Consistent 17-touch follow-up means you're there when sellers are ready, not just when reps remember to call.

2. **Rep Consistency Without Babysitting** - Every rep follows the same proven playbook. New hires perform like veterans.

3. **No Leads Fall Through Cracks** - Tasks appear automatically. Reps can't "forget" to follow up.

4. **Scripts That Actually Work** - Chris Voss techniques (labeling, tactical empathy, calibrated questions) instead of "Hey, just following up..."

5. **Training Built Into the Workflow** - Coaching Notes explain WHY each technique works. Reps learn while doing.

6. **Scalable Without Adding Headcount** - One rep can work 50+ leads simultaneously because the system handles scheduling.

---

## Build Cost Analysis

### What This Would Cost to Build Traditionally

| Approach | Hourly Rate | Hours | Total Cost |
|----------|-------------|-------|------------|
| Salesforce Admin (internal) | $45-65/hr | 50 hrs | $2,250 - $3,250 |
| Salesforce Developer (contractor) | $100-150/hr | 50 hrs | $5,000 - $7,500 |
| Salesforce Consultancy | $175-250/hr | 50 hrs | $8,750 - $12,500 |

**Standard timeline: 1.5-2 weeks**

### What We Built
- 5 Apex classes + 4 test classes (~800 lines of code)
- 2 Record-Triggered Flows with scheduled paths
- 1 Apex Trigger for owner reassignment
- 3 custom Task fields
- 5 email templates
- Full documentation

**Actual build time: 36 minutes**

---

## Technical Components

| Component | Purpose |
|-----------|---------|
| `REILeadCadenceHelper.cls` | Core logic, 17 task definitions, merge field replacement, business hours |
| `REILeadCadenceDay0Immediate.cls` | Creates first 3 tasks instantly via Flow |
| `REILeadCadenceDay0FourHour.cls` | Creates +4 hour task via scheduled path |
| `REILeadCadenceScheduled.cls` | Daily 8 AM job for Days 1-14 tasks |
| `REILeadCadenceCleanup.cls` | Deletes incomplete tasks on exit |
| `REILeadOwnerChangeTrigger` | Reassigns tasks when Lead owner changes |
| `REI_Lead_Cadence_Entry` | Flow triggers on status = Attempting_Contact |
| `REI_Lead_Cadence_Exit` | Flow triggers on exit from Attempting_Contact |

### Custom Task Fields
- `Cadence_Name__c` - Identifies which cadence created the task
- `Cadence_Day__c` - Which day in the cadence (0-14)
- `Coaching_Notes__c` - Explains why the technique works

---

*Chris Voss techniques: Tactical empathy, labeling, mirroring, calibrated questions*
