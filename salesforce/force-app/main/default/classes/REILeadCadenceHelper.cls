/**
 * REILeadCadenceHelper
 * Shared utilities for the Attempting Contact lead cadence
 * - Business hours logic (8 AM - 7 PM)
 * - Weekend handling (push to Monday)
 * - Merge field replacement
 * - Task creation helpers
 * - Cadence data (scripts + coaching notes)
 */
public class REILeadCadenceHelper {

    public static final String CADENCE_NAME = 'Attempting Contact';
    public static final Integer BUSINESS_START_HOUR = 8;  // 8 AM
    public static final Integer BUSINESS_END_HOUR = 19;   // 7 PM

    /**
     * Task definition class - holds all info needed to create a task
     */
    public class TaskDefinition {
        public Integer cadenceDay;
        public Integer hour;
        public Integer minute;
        public String taskName;
        public String taskType;
        public String script;
        public String coachingNotes;

        public TaskDefinition(Integer day, Integer hr, Integer min, String name, String type, String script, String coaching) {
            this.cadenceDay = day;
            this.hour = hr;
            this.minute = min;
            this.taskName = name;
            this.taskType = type;
            this.script = script;
            this.coachingNotes = coaching;
        }
    }

    /**
     * Get all task definitions for the cadence
     */
    public static Map<Integer, List<TaskDefinition>> getAllTaskDefinitions() {
        Map<Integer, List<TaskDefinition>> tasksByDay = new Map<Integer, List<TaskDefinition>>();

        // Day 0 tasks
        tasksByDay.put(0, new List<TaskDefinition>{
            new TaskDefinition(0, 0, 0, 'First Contact - Text', 'Text',
                'Hi [Name], [Lead Manager First Name] here. Saw you reached out about [Address]. Is now a bad time?',
                'ASKING "Is now a bad time?" gets better responses than "Do you have time?" People feel safer saying "no" than committing to "yes." Gives them control of the conversation.'),
            new TaskDefinition(0, 0, 2, 'First Call - No VM', 'Call',
                'Hi [Name], this is [Lead Manager First Name]. I just texted you - did you get it?\n\n[If yes] Great. I saw you reached out about [Address]. It seems like you might be exploring your options?\n\n[Listen for response]\n\nWhat\'s got you thinking about selling [Address]?',
                'START WITH "It seems like..." to show you understand their situation (makes them feel heard). Then ask "What\'s got you thinking about selling?" instead of yes/no questions - forces them to open up and tell you what\'s really going on.'),
            new TaskDefinition(0, 0, 10, 'Personal Email from Lead Manager', 'Email',
                'SUBJECT: [Name] - [Address]\n\nHi [Name],\n\nI\'m [Lead Manager First Name]. Just tried calling you about [Address].\n\nIt sounds like you might be weighing your options on what to do with the property.\n\nI work with homeowners in [Neighborhood] who are in similar situations - some need to sell quickly, some just want to know what it\'s worth, some are testing the waters.\n\nWhat makes the most sense for you right now?\n\nNo pressure either way.\n\n[Lead Manager First Name]\n[Lead Manager Phone]',
                'ACKNOWLEDGE different scenarios they might be in (shows empathy). Ask "What makes sense for you?" instead of pitching - makes them articulate their needs. End with "No pressure" to create safety.'),
            new TaskDefinition(0, 4, 0, 'Second Call + Leave VM', 'Call',
                'CALL: Hi [Name], [Lead Manager First Name] again. I tried you earlier. Is this still a bad time?\n\n[If they answer] It seems like you\'ve been tough to reach - I\'m guessing you\'re pretty busy?\n\nVOICEMAIL: Hi [Name], [Lead Manager First Name] with REI Team. Look, I know you\'re probably getting bombarded with calls about [Address]. I get it - that must be overwhelming.\n\nHere\'s what I\'m NOT going to do: I\'m not going to bug you every day or pressure you into something that doesn\'t make sense for you.\n\nWhat I CAN do: Give you a straight answer on what we can offer and let you decide if it makes sense.\n\nIf now\'s not the right time, no problem. My number is [Lead Manager Phone].\n\nTalk soon.',
                'CALL OUT their concerns BEFORE they say them ("I know you\'re getting bombarded..."). This disarms objections and shows you get it. Removes pressure by acknowledging what they\'re thinking.'),
            new TaskDefinition(0, 18, 0, 'Evening Text', 'Text',
                'Hi [Name], [Lead Manager First Name]. Haven\'t connected yet. Is the timing just not right?',
                'ASKING "Is the timing just not right?" makes it easy for them to respond without feeling pressured. They can say "yeah, bad timing" and keep the door open.')
        });

        // Day 1 tasks
        tasksByDay.put(1, new List<TaskDefinition>{
            new TaskDefinition(1, 10, 0, 'Third Call', 'Call',
                'Hi [Name], [Lead Manager First Name]. Still trying to connect with you about [Address]. Are you avoiding me?\n\n[If they laugh/respond] It seems like maybe the timing just hasn\'t been right?\n\n[If no answer] I\'ll try again later - no pressure.',
                'USE HUMOR to break tension ("Are you avoiding me?" makes them laugh). Keep it light. NO VOICEMAIL - research shows 3+ voicemails decrease response rates. Only leaving 2 total VMs (Day 0 and Day 11).'),
            new TaskDefinition(1, 14, 0, 'Value Proposition Email', 'Email',
                'SUBJECT: What makes us different (probably not what you think)\n\nHi [Name],\n\nYou\'ve probably heard from a bunch of "we buy houses" companies by now.\n\nI\'m guessing some of them sounded too good to be true?\n\nHere\'s the truth: We\'re not going to offer you retail value. Nobody who buys cash can.\n\nWhat we CAN offer:\n→ A real number in 24 hours (not "maybe" or "we\'ll see")\n→ Close on YOUR timeline (7 days or 60 days - you pick)\n→ Zero repairs, zero fees, zero BS\n\nThe question is: Does that make sense for what you need right now?\n\nIf it doesn\'t, I totally get it. Listing with an agent might be the better move.\n\nBut if speed and simplicity matter more than squeezing every last dollar, let\'s talk.\n\nWhat sounds more important to you - max price or fast/easy?\n\n[Lead Manager First Name]',
                'ADDRESS "too good to be true" concern upfront. BE HONEST: "We won\'t offer retail" builds massive trust. Then force them to think about what matters more - max price or speed/simplicity?'),
            new TaskDefinition(1, 17, 0, 'Evening Check Text', 'Text',
                'Hi [Name], [Lead Manager First Name]. Wrong number?',
                'HUMOR breaks the pattern of ignored texts. "Wrong number?" makes them respond "No, right number but..." and suddenly they\'re talking to you.')
        });

        // Day 2
        tasksByDay.put(2, new List<TaskDefinition>{
            new TaskDefinition(2, 11, 0, 'Fourth Call', 'Call',
                'Hi [Name], [Lead Manager First Name] with REI Team. I feel like I might be bothering you at this point?\n\n[Listen]\n\nIt seems like you might still be thinking it over?\n\n[If no answer, don\'t leave VM - just note the attempt]',
                'LABEL how they might be feeling ("I feel like I might be bothering you") - shows self-awareness and empathy. NO VOICEMAIL on this call - save VMs for Day 0 and Day 11 only.')
        });

        // Day 4
        tasksByDay.put(4, new List<TaskDefinition>{
            new TaskDefinition(4, 10, 0, 'Address the Elephant Email', 'Email',
                'SUBJECT: You\'re probably thinking...\n\nHi [Name],\n\nYou\'re probably thinking one of these:\n\n1. "This sounds like a lowball"\n2. "I need to talk to my family first"\n3. "I\'m not sure I\'m ready to sell"\n4. "I want to see what a realtor says"\n\nAll totally valid.\n\nHere\'s what I\'ve learned working with homeowners in [Neighborhood]:\n\nThe people who sell to us are usually in one of these situations:\n→ They inherited a property they don\'t want\n→ They\'re tired of being a landlord\n→ The house needs work they can\'t afford or don\'t want to deal with\n→ They need to sell fast (divorce, relocation, financial pressure)\n\nDoes any of that sound familiar?\n\nIf not - if you have time and the house is in great shape - you\'ll probably get more money listing it traditionally.\n\nBut if you\'re in one of those situations above, we might be able to help.\n\nWhat\'s really going on with [Address]?\n\n[Lead Manager First Name]',
                'LIST every objection they\'re probably thinking ("You\'re probably thinking..."). Then describe common situations they might relate to. End with "What\'s really going on?" to get them to open up.')
        });

        // Day 5
        tasksByDay.put(5, new List<TaskDefinition>{
            new TaskDefinition(5, 14, 0, 'Direct Question Text', 'Text',
                'Hi [Name], [Lead Manager First Name]. Straight question - are we even in the ballpark of what you need?',
                'DIRECT question forces them to evaluate if you\'re a fit. "Are we even in the ballpark?" is honest and makes them think - not pushy.')
        });

        // Day 6
        tasksByDay.put(6, new List<TaskDefinition>{
            new TaskDefinition(6, 15, 0, 'Fifth Call', 'Call',
                'Hi [Name], [Lead Manager First Name]. I\'m going to try you one more time, then I\'ll leave you alone. Fair?\n\n[If answer] It seems like [Address] might not be urgent for you right now?\n\n[If no answer, don\'t leave VM]',
                'ACKNOWLEDGE you\'ve been calling but keep it light. "Fair?" gets them to engage. NO VOICEMAIL - limiting to 2 total VMs (Day 0 and Day 11 only) per research.')
        });

        // Day 7
        tasksByDay.put(7, new List<TaskDefinition>{
            new TaskDefinition(7, 10, 0, 'The Real Cost Email', 'Email',
                'SUBJECT: What selling traditionally ACTUALLY costs\n\nHi [Name],\n\nLet\'s talk about the elephant in the room.\n\nYou\'re probably thinking: "If I list with a realtor, I\'ll get more money."\n\nAnd you might be right.\n\nBut here\'s what that actually looks like:\n\nSay [Address] is worth $300k:\n→ 6% realtor commission: -$18,000\n→ Closing costs (2-3%): -$7,500\n→ Repairs from inspection: -$5,000 to $20,000\n→ Staging/photos: -$2,000\n→ Time on market: 60-90 days\n→ Mortgage/taxes/insurance while it sits: -$3,000+\n\nNet after all that: ~$265,000\nTime invested: 3-4 months\n\nWith us:\n→ Offer: $260,000\n→ Your costs: $0\n→ Time to close: 10 days\n\nSo the question isn\'t "who pays more."\n\nThe question is: What\'s worth more to you - an extra $5,000 or 3 months of your life?\n\nThat\'s not a trick question. For some people, the answer is "give me the $5k."\n\nFor others, it\'s "I just want this handled."\n\nWhich one sounds like you?\n\n[Lead Manager First Name]',
                'ADDRESS the "list for more money" objection head-on with REAL MATH. Concrete numbers build credibility. Then ask "Which one sounds like you?" to force self-reflection on priorities.')
        });

        // Day 9
        tasksByDay.put(9, new List<TaskDefinition>{
            new TaskDefinition(9, 11, 0, 'Permission to Help Text', 'Text',
                'Hi [Name], [Lead Manager First Name]. What would have to be true for us to help with [Address]?',
                'POWERFUL QUESTION: "What would have to be true for us to help?" Makes them articulate their exact criteria. Once they tell you, you know exactly what they need.')
        });

        // Day 11
        tasksByDay.put(11, new List<TaskDefinition>{
            new TaskDefinition(11, 14, 0, 'Sixth Call + Leave VM', 'Call',
                'CALL: Hi [Name], [Lead Manager First Name]. Last call, I promise. It seems like this just isn\'t the right fit?\n\nVOICEMAIL: Hey [Name], [Lead Manager First Name] here.\n\nThis is my last call. I don\'t want to be a pest.\n\nI just closed on a house on [Nearby Street] last week. The homeowner was in a similar spot - inherited property, needed repairs, didn\'t want to deal with it.\n\nWe closed in 8 days. No inspections, no appraisals, no drama.\n\nThey told me afterward: "I should\'ve called you two months ago. I wasted so much time stressing about this."\n\nI don\'t know if that\'s you. Maybe [Address] is different.\n\nBut if you\'re avoiding this because it feels overwhelming, I get it.\n\nWhat if it could be easier than you think?\n\nText me if you want to talk. If not, I won\'t bug you again.\n\n[Lead Manager Phone]',
                'SHARE a real recent example (social proof). Then say "I don\'t know if that\'s you" (low pressure). End with "What if it could be easier than you think?" to reframe their perspective. Final call.')
        });

        // Day 13
        tasksByDay.put(13, new List<TaskDefinition>{
            new TaskDefinition(13, 10, 0, 'Permission to Close Email', 'Email',
                'SUBJECT: Can I close your file?\n\nHi [Name],\n\nI\'ve been trying to reach you for two weeks.\n\nThat tells me something:\n\nEither:\na) You\'re not interested\nb) You already handled [Address]\nc) The timing just isn\'t right\nd) I\'m saying something wrong and turning you off\n\nIf it\'s A or B - congrats, glad it worked out. I\'ll close your file.\n\nIf it\'s C - if you think you might want to sell in 3-6 months but not now - just reply "later" and I\'ll check back with you then.\n\nIf it\'s D - if I\'ve been too pushy or said something that rubbed you the wrong way - I apologize. That wasn\'t my intention.\n\nBut here\'s what I don\'t want to happen:\n\nSix months from now, your situation with [Address] gets worse. Maybe the property taxes hit, or the HOA comes after you, or a pipe bursts, or a tenant trashes the place.\n\nAnd you think: "Damn, I should\'ve called that guy back."\n\nI\'ve seen it happen.\n\nSo here\'s my ask:\n\nEven if now isn\'t the right time, save my number.\n\nBecause if things change - if you suddenly NEED to sell fast - I\'m still here.\n\nI had a homeowner ignore me for 6 months. Then her tenant destroyed the place. She called me back in a panic.\n\nWe gave her an offer in 24 hours and closed in 5 days.\n\nShe told me: "Thank God you didn\'t give up on me."\n\nI\'m not giving up on you either.\n\nBut I AM going to stop calling.\n\nThe ball\'s in your court.\n\n[Lead Manager First Name]\n[Lead Manager Phone]\n\nP.S. - If you respond "not interested," I\'ll respect that and you\'ll never hear from me again. No hard feelings.',
                'LIST every possible reason for no response. PAINT a picture of future regret ("6 months from now...") - people fear loss more than they value gain. Share real story of someone who waited too long. End with "Ball\'s in your court" - final control moment.')
        });

        // Day 14
        tasksByDay.put(14, new List<TaskDefinition>{
            new TaskDefinition(14, 17, 0, 'Move to Nurture', 'Task',
                'Change Status to "Nurture". Add to monthly email sequence.\n\nNote: Used full Chris Voss cadence. If they respond in future, they\'re highly qualified - they\'ve been thinking about it.',
                'END ACTIVE CADENCE: They\'ve experienced empathy, honesty, and options. If they come back later, they\'re highly qualified - they\'ve been thinking about it. Move to monthly nurture emails.')
        });

        return tasksByDay;
    }

    /**
     * Get task definitions for a specific day
     */
    public static List<TaskDefinition> getTasksForDay(Integer day) {
        Map<Integer, List<TaskDefinition>> allTasks = getAllTaskDefinitions();
        return allTasks.containsKey(day) ? allTasks.get(day) : new List<TaskDefinition>();
    }

    /**
     * Replace merge fields in script text
     */
    public static String replaceMergeFields(String script, Lead lead, User owner) {
        if (String.isBlank(script)) return script;

        String result = script;
        result = result.replace('[Name]', lead.FirstName != null ? lead.FirstName : '');
        result = result.replace('[Address]', lead.Property_Address__c != null ? lead.Property_Address__c : '');
        result = result.replace('[Neighborhood]', lead.Property_City__c != null ? lead.Property_City__c : '');
        result = result.replace('[Company]', 'REI Team');
        result = result.replace('[Lead Manager First Name]', owner.FirstName != null ? owner.FirstName : '');
        result = result.replace('[Lead Manager Phone]', owner.Phone != null ? owner.Phone : '');

        // [Nearby Street] - TODO: implement dynamic lookup for recent closed deals
        result = result.replace('[Nearby Street]', 'a nearby street');

        return result;
    }

    /**
     * Check if a datetime is within business hours (8 AM - 7 PM)
     */
    public static Boolean isWithinBusinessHours(DateTime dt) {
        Integer hour = dt.hour();
        return hour >= BUSINESS_START_HOUR && hour < BUSINESS_END_HOUR;
    }

    /**
     * Check if a date is a weekend
     */
    public static Boolean isWeekend(Date d) {
        DateTime dt = DateTime.newInstance(d, Time.newInstance(12, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday';
    }

    /**
     * Get next business day (skips weekends)
     */
    public static Date getNextBusinessDay(Date d) {
        Date result = d;
        while (isWeekend(result)) {
            result = result.addDays(1);
        }
        return result;
    }

    /**
     * Adjust datetime to next business hours if outside 8 AM - 7 PM or on weekend
     */
    public static DateTime adjustToBusinessHours(DateTime dt) {
        Date adjustedDate = dt.date();
        Integer hour = dt.hour();

        // If weekend, push to Monday
        if (isWeekend(adjustedDate)) {
            adjustedDate = getNextBusinessDay(adjustedDate);
            return DateTime.newInstance(adjustedDate, Time.newInstance(BUSINESS_START_HOUR, 0, 0, 0));
        }

        // If before business hours, set to 8 AM same day
        if (hour < BUSINESS_START_HOUR) {
            return DateTime.newInstance(adjustedDate, Time.newInstance(BUSINESS_START_HOUR, 0, 0, 0));
        }

        // If after business hours, push to 8 AM next business day
        if (hour >= BUSINESS_END_HOUR) {
            adjustedDate = getNextBusinessDay(adjustedDate.addDays(1));
            return DateTime.newInstance(adjustedDate, Time.newInstance(BUSINESS_START_HOUR, 0, 0, 0));
        }

        return dt;
    }

    /**
     * Calculate the due datetime for a task based on cadence day and time
     */
    public static DateTime calculateDueDateTime(Date lastSubmissionDate, Integer cadenceDay, Integer hour, Integer minute) {
        Date dueDate = lastSubmissionDate.addDays(cadenceDay);
        DateTime dueDateTime = DateTime.newInstance(dueDate, Time.newInstance(hour, minute, 0, 0));
        return adjustToBusinessHours(dueDateTime);
    }

    /**
     * Check if a task already exists (duplicate prevention)
     */
    public static Boolean taskExists(Id leadId, String taskName, Date dueDate) {
        List<Task> existing = [
            SELECT Id FROM Task
            WHERE WhoId = :leadId
            AND Subject = :taskName
            AND Cadence_Name__c = :CADENCE_NAME
            AND ActivityDate = :dueDate
            LIMIT 1
        ];
        return !existing.isEmpty();
    }

    /**
     * Create a single task
     */
    public static Task createTask(Lead lead, User owner, TaskDefinition taskDef, DateTime dueDateTime) {
        Task t = new Task();
        t.Subject = taskDef.taskName;
        t.Type = taskDef.taskType;
        t.WhoId = lead.Id;
        t.OwnerId = lead.OwnerId;
        t.ActivityDate = dueDateTime.date();
        t.ReminderDateTime = dueDateTime;
        t.IsReminderSet = true;
        t.Priority = 'Normal';
        t.Status = 'Not Started';
        t.Description = replaceMergeFields(taskDef.script, lead, owner);
        t.Cadence_Name__c = CADENCE_NAME;
        t.Cadence_Day__c = taskDef.cadenceDay;
        t.Coaching_Notes__c = taskDef.coachingNotes;
        return t;
    }

    /**
     * Get Lead with all required fields for cadence
     */
    public static Lead getLeadWithFields(Id leadId) {
        return [
            SELECT Id, FirstName, LastName, OwnerId, Status,
                   Property_Address__c, Property_City__c, Last_Submission_Date__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];
    }

    /**
     * Get User with required fields
     */
    public static User getUserWithFields(Id userId) {
        return [
            SELECT Id, FirstName, LastName, Phone
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];
    }

    /**
     * Calculate which cadence day a lead is on based on Last_Submission_Date__c
     */
    public static Integer calculateCadenceDay(Date lastSubmissionDate) {
        return lastSubmissionDate.daysBetween(Date.today());
    }

    /**
     * Check if lead is still within the 5-day re-entry window
     */
    public static Boolean isWithinReentryWindow(Date lastSubmissionDate) {
        Integer daysSince = lastSubmissionDate.daysBetween(Date.today());
        return daysSince <= 5;
    }
}
