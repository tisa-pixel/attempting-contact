# Daily Dose - Build Post: Attempting Contact Cadence
**For conversionisourgame.com**
**Created:** December 11, 2025

---

## 1. BUILD TITLE
How I Built a 17-Touch Lead Follow-Up System in Salesforce That Never Forgets to Call Back (Built in 36 Minutes)

---

## 2. THE PROBLEM
REI teams lose deals because follow-up is inconsistent and generic. Reps forget to call back, send "just checking in" messages that get ignored, or give up after 2-3 attempts. Industry data shows it takes 8-12 touches to reach a motivated seller, but most reps stop at 3.

The manual approach is broken:
- Reps decide when to follow up (inconsistent timing)
- They use whatever script they remember (no coaching)
- New hires sound desperate, veterans sound bored
- Leads fall through cracks when reps get busy
- No one tracks what's actually working

You need a system that follows up automatically, uses proven psychology-based scripts, and trains your reps while they work - without adding headcount or paying for expensive sales engagement tools.

---

## 3. THE SOLUTION
Built an automated 17-touch, 14-day follow-up cadence in Salesforce that creates tasks automatically when a Lead enters "Attempting Contact" status.

When a lead submits a form, the cadence kicks off instantly:
- **Day 0:** 5 touches (text → call → email → call+VM → text)
- **Days 1-14:** 12 more strategic touches across phone, text, and email

Each task includes:
- **The exact script to use** (psychology-based, not generic)
- **Coaching notes** explaining WHY the technique works
- **Merge fields** for personalization ([Name], [Address], etc.)

Tasks appear only on the day they're due (not all at once). If lead status changes, all incomplete tasks auto-delete. Reps can't procrastinate or forget - it's on their task list.

**Built in 36 minutes** using Claude Code. Would cost $2,250-$12,500 to build traditionally.

---

## 4. WATCH ME BUILD IT
[YouTube embed code - TBD]

Watch the full walkthrough on YouTube where I break down the architecture, task scheduling logic, and merge field replacement.

---

## 5. WHAT YOU'LL LEARN
- How to build multi-day automated cadences in Salesforce
- Writing high-conversion scripts using psychological persuasion techniques
- Scheduled jobs for recurring task creation
- Record-Triggered Flows with scheduled paths
- Merge field replacement in task descriptions
- Business hours logic (8 AM - 7 PM, no weekends)
- Task cleanup when lead status changes
- Owner reassignment triggers
- Re-entry logic (restart vs. pick up where they left off)
- Custom fields for cadence tracking

---

## 6. BUILD DETAILS

### 6.1 Time Investment
| Who | Time Required |
|-----|---------------|
| **Salesforce Admin (internal)** | 50 hours over 1.5-2 weeks ($2,250-$3,250) |
| **Salesforce Developer (contractor)** | 50 hours ($5,000-$7,500) |
| **Salesforce Consultancy** | 50 hours ($8,750-$12,500) |
| **If You Build It (with this guide)** | 36 minutes |

### 6.2 Cost Breakdown
| Approach | Cost |
|----------|------|
| **Salesforce Admin Rate** | $45-65/hour |
| **Estimated Admin Cost** | $2,250-$3,250 |
| **Developer Rate** | $100-150/hour |
| **Estimated Dev Cost** | $5,000-$7,500 |
| **Consultancy Rate** | $175-250/hour |
| **Estimated Consultancy Cost** | $8,750-$12,500 |
| **DIY Cost (Your Time)** | 36 minutes + $0 (uses existing Salesforce) |

**Savings:** $2,250-$12,500

---

## 7. TECH STACK
🔧 **Tools Used:**
- **Salesforce** (CRM platform)
- **Apex** (5 classes + 4 test classes)
- **Record-Triggered Flows** (Entry + Exit)
- **Scheduled Jobs** (Daily 8 AM task creation)
- **Custom Fields** (Cadence tracking)
- **Merge Fields** (Personalization)

---

## 8. STEP-BY-STEP BREAKDOWN

### 1. **Create Custom Fields on Task Object**

Start by adding three custom fields to the Task object in Salesforce. These fields let the system identify which cadence created each task, track which day in the sequence it belongs to, and store coaching notes for the rep.

The cadence name field acts as a tag so cleanup automation knows which tasks to delete when a lead exits the status. The day number helps with reporting and debugging. The coaching notes field is where the psychology-based training lives - reps see it every time they open a task.

---

### 2. **Build the Core Helper Class**

Create a central class that stores all 17 touch definitions in one data structure. Each touch includes the day number, timing, communication type, subject line, script content, and coaching notes explaining why the technique works.

This approach keeps everything organized in one place. When you want to update a script or add a new touch, you only change one file. The helper class also handles merge field replacement - swapping placeholders like [Name] and [Address] with actual lead data - and includes business hours logic to respect your team's operating window.

---

### 3. **Build Day 0 Immediate Tasks Class**

Create a class that fires instantly when a lead enters the cadence. It creates the first three touches (text, call, email) right away so reps have work in their queue within seconds of a form submission.

This invocable class gets called from a Flow trigger. It queries the lead record for personalization data, loops through the first three touch definitions, and inserts the tasks with fully populated scripts and coaching notes.

---

### 4. **Build Day 0 +4 Hour Task Class**

Create another class that handles the fourth touch - a call with voicemail - scheduled for 4 hours after entry. This class respects business hours: if it's after 7 PM, the task gets pushed to the next business day at 8 AM instead.

The business hours logic prevents tasks from being created outside operating windows. Nobody wants a "call this lead now" task at 11 PM. The class checks the current time and either creates the task immediately or defers to the daily scheduled job.

---

### 5. **Build Daily Scheduled Job**

Create a schedulable class that runs every morning at 8 AM. It finds all leads currently in "Attempting Contact" status, calculates how many days since they entered the cadence, and creates any tasks due for that day.

The job checks whether each task already exists before creating it - no duplicates. It uses the lead's entry date to determine which touches are due today, then bulk-inserts all new tasks in a single operation for efficiency.

---

### 6. **Schedule the Daily Job**

Register the scheduled job to run at 8 AM every day using Salesforce's cron syntax. This takes one line executed in the Developer Console. Once scheduled, it runs indefinitely until you explicitly unschedule it.

The cron expression specifies the exact time: minute, hour, day of month, month, day of week. Set it and forget it - your cadence tasks will appear every morning like clockwork.

---

### 7. **Build Cleanup Class for Exit**

Create an invocable class that deletes all open cadence tasks when a lead exits the "Attempting Contact" status. This prevents orphan tasks from cluttering rep queues after the lead converts, disqualifies, or moves to a different stage.

The cleanup query finds all tasks associated with the lead that are still open and tagged with the cadence name, then bulk-deletes them. This happens automatically through a Flow trigger - no manual cleanup needed.

---

### 8. **Build Entry Flow**

Create a Record-Triggered Flow on the Lead object that fires when status changes to "Attempting Contact." The immediate path calls the Day 0 Immediate class to create the first three tasks. A scheduled path at +4 hours calls the Day 0 +4 Hour class.

Flows are the trigger mechanism that connects lead status changes to your Apex classes. The immediate path ensures instant response. The scheduled path handles delayed touches while still being event-driven rather than polling-based.

---

### 9. **Build Exit Flow**

Create another Record-Triggered Flow that fires when a lead's status changes FROM "Attempting Contact" to any other value. This flow calls the Cleanup class to delete all incomplete cadence tasks.

The exit trigger uses the PRIORVALUE function to detect when the previous status was "Attempting Contact." This ensures cleanup only happens when leaving the cadence, not on other status changes.

---

### 10. **Build Owner Reassignment Trigger**

Create a trigger that fires when a lead's owner changes. It finds all open cadence tasks for that lead and updates their owner to match the new lead owner.

This keeps tasks visible to the right rep. Without this trigger, reassigned leads would have orphan tasks sitting in the previous owner's queue. The trigger bulk-updates all affected tasks in a single DML operation.

---

### 11. **Write Test Classes**

Salesforce requires 75% code coverage for production deployments. Create test classes for each of your Apex classes that verify the happy path works correctly.

Test classes create test leads, update their status to trigger the cadence, and assert that the expected tasks were created. They also test edge cases like business hours boundaries and cleanup behavior.

---

## 9. GITHUB REPO
📂 **Get the Code:**
[View on GitHub: github.com/tisa-pixel/attempting-contact](https://github.com/tisa-pixel/attempting-contact)

**What's included in the repo:**
- 5 Apex classes
- 4 Test classes
- Full cadence data (CSV with all 17 touches)
- Salesforce metadata for deployment
- Flow configurations
- Email template content
- Complete documentation

---

## 10. DOWNLOAD THE TEMPLATE
⬇️ **Download Resources:**
- [Clone the repo](https://github.com/tisa-pixel/attempting-contact) - Full Salesforce metadata
- [Cadence Scripts (CSV)](https://github.com/tisa-pixel/attempting-contact/blob/main/cadence-data.csv) - All 17 scripts + coaching notes
- [Technical Requirements](https://github.com/tisa-pixel/attempting-contact/blob/main/REQUIREMENTS.md) - Complete spec

**Deployment Checklist:**
1. Clone repo
2. Create custom fields (Cadence_Name__c, Cadence_Day__c, Coaching_Notes__c)
3. Deploy Apex classes
4. Run test classes (ensure 75%+ coverage)
5. Create Entry Flow (record-triggered)
6. Create Exit Flow (record-triggered)
7. Deploy Owner Change trigger
8. Schedule daily job (8 AM)
9. Test with a lead
10. Monitor tasks created

---

## 11. QUESTIONS? DROP THEM BELOW
💬 **Have questions or want to share your results?**
- Comment on the [YouTube video](#) (TBD)
- DM me on Instagram: [@donottakeifallergictorevenue](https://www.instagram.com/donottakeifallergictorevenue/)
- Open an issue on [GitHub](https://github.com/tisa-pixel/attempting-contact/issues)

---

## 12. RELATED BUILDS
| Build 1 | Build 2 | Build 3 |
|---------|---------|---------|
| **Sarah - AI Lead Qualifier** | **Am I Spam? - Phone Reputation Checker** | **Check Yo Rep - Find Your Elected Officials** |
| AI voice agent that calls leads, qualifies, and warm transfers | Check if your DIDs are flagged before campaigns | Civic engagement tool for finding representatives |
| [View Build](https://github.com/tisa-pixel/rei-lead-qualifier) | [View Build](https://github.com/tisa-pixel/am-i-spam) | [View Build](https://github.com/tisa-pixel/check-yo-rep) |

---

## Additional Metadata (for SEO / Backend)

**Published:** December 11, 2025
**Author:** Tisa Daniels
**Category:** Salesforce Automation / Sales Enablement / Real Estate Tech
**Tags:** #Salesforce #LeadNurture #Cadence #SalesAutomation #RealEstateInvesting
**Estimated Read Time:** 8 minutes
**Video Duration:** TBD

---

## Design Notes for Wix Implementation

### Layout Style:
- **Dark background** (charcoal #1B1C1D)
- **High contrast text** (white headings, light gray body)
- **Accent colors:** Blue (#2563eb), Green (#16a34a for "completed"), Orange (#f59e0b for "in progress")
- **Clean, modern, mobile-first**

### Call-to-Action Buttons:
- **Primary CTA** (Clone on GitHub): Purple (#7c3aed)
- **Secondary CTA** (Watch on YouTube): Blue (#2563eb)

---

**Template Version:** 1.0
**Created:** December 11, 2025
**Build Time:** 36 minutes with Claude Code
