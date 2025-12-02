/**
 * REILeadCadenceScheduled
 * Daily scheduled job (runs at 8 AM) that creates:
 * - Evening Text for Day 0 leads
 * - All tasks for Days 1-14
 *
 * Respects business hours and weekends.
 * Handles re-entry logic (pick up where left off if within 5 days).
 *
 * Schedule with: System.schedule('REI Lead Cadence Daily', '0 0 8 * * ?', new REILeadCadenceScheduled());
 */
public class REILeadCadenceScheduled implements Schedulable {

    public void execute(SchedulableContext sc) {
        createDailyTasks();
    }

    /**
     * Main method to create all daily tasks
     * Can also be called directly for testing
     */
    public static void createDailyTasks() {
        // Skip weekends - tasks will be created on Monday
        if (REILeadCadenceHelper.isWeekend(Date.today())) {
            return;
        }

        // Get all leads in Attempting_Contact status with Last_Submission_Date__c set
        List<Lead> leads = [
            SELECT Id, FirstName, LastName, OwnerId, Status,
                   Property_Address__c, Property_City__c, Last_Submission_Date__c
            FROM Lead
            WHERE Status = 'Attempting_Contact'
            AND Last_Submission_Date__c != null
        ];

        if (leads.isEmpty()) {
            return;
        }

        // Collect all owner IDs
        Set<Id> ownerIds = new Set<Id>();
        for (Lead l : leads) {
            ownerIds.add(l.OwnerId);
        }

        // Get all owners in one query
        Map<Id, User> ownersMap = new Map<Id, User>([
            SELECT Id, FirstName, LastName, Phone
            FROM User
            WHERE Id IN :ownerIds
        ]);

        List<Task> tasksToCreate = new List<Task>();
        Map<Integer, List<REILeadCadenceHelper.TaskDefinition>> allTaskDefs = REILeadCadenceHelper.getAllTaskDefinitions();

        for (Lead lead : leads) {
            User owner = ownersMap.get(lead.OwnerId);
            if (owner == null) continue;

            Integer cadenceDay = REILeadCadenceHelper.calculateCadenceDay(lead.Last_Submission_Date__c);

            // Handle weekend leads - if they entered on Sat/Sun, today (Monday) is effectively Day 0 evening + Day 1
            // Adjust cadence day for weekend entries
            Date lastSubmission = lead.Last_Submission_Date__c;
            if (REILeadCadenceHelper.isWeekend(lastSubmission)) {
                // They entered on weekend, adjust so Monday is treated correctly
                // Saturday entry: Monday = Day 2 but we should create Day 0 evening + Day 1 + Day 2
                // Sunday entry: Monday = Day 1 but we should create Day 0 evening + Day 1
                // For simplicity, create all missed tasks up to current day
                createMissedTasksForWeekendEntry(lead, owner, lastSubmission, tasksToCreate, allTaskDefs);
                continue;
            }

            // Day 0 - create Evening Text (task index 4)
            if (cadenceDay == 0) {
                List<REILeadCadenceHelper.TaskDefinition> day0Tasks = allTaskDefs.get(0);
                if (day0Tasks != null && day0Tasks.size() > 4) {
                    REILeadCadenceHelper.TaskDefinition eveningTask = day0Tasks[4]; // Evening Text
                    DateTime dueDateTime = REILeadCadenceHelper.calculateDueDateTime(
                        lastSubmission, 0, eveningTask.hour, eveningTask.minute
                    );

                    if (!REILeadCadenceHelper.taskExists(lead.Id, eveningTask.taskName, dueDateTime.date())) {
                        Task t = REILeadCadenceHelper.createTask(lead, owner, eveningTask, dueDateTime);
                        tasksToCreate.add(t);
                    }
                }
            }

            // Days 1-14 - create tasks for today's cadence day
            if (cadenceDay >= 1 && cadenceDay <= 14) {
                List<REILeadCadenceHelper.TaskDefinition> todayTasks = allTaskDefs.get(cadenceDay);
                if (todayTasks != null) {
                    for (REILeadCadenceHelper.TaskDefinition taskDef : todayTasks) {
                        DateTime dueDateTime = REILeadCadenceHelper.calculateDueDateTime(
                            lastSubmission, taskDef.cadenceDay, taskDef.hour, taskDef.minute
                        );

                        if (!REILeadCadenceHelper.taskExists(lead.Id, taskDef.taskName, dueDateTime.date())) {
                            Task t = REILeadCadenceHelper.createTask(lead, owner, taskDef, dueDateTime);
                            tasksToCreate.add(t);
                        }
                    }
                }
            }
        }

        // Insert all tasks
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }

    /**
     * Handle leads that entered on weekend - create all missed tasks on Monday
     */
    private static void createMissedTasksForWeekendEntry(
        Lead lead,
        User owner,
        Date lastSubmission,
        List<Task> tasksToCreate,
        Map<Integer, List<REILeadCadenceHelper.TaskDefinition>> allTaskDefs
    ) {
        Integer actualDays = lastSubmission.daysBetween(Date.today());

        // Create Day 0 Evening Text (always missed if weekend entry)
        List<REILeadCadenceHelper.TaskDefinition> day0Tasks = allTaskDefs.get(0);
        if (day0Tasks != null && day0Tasks.size() > 4) {
            REILeadCadenceHelper.TaskDefinition eveningTask = day0Tasks[4];
            DateTime dueDateTime = DateTime.newInstance(Date.today(), Time.newInstance(eveningTask.hour, eveningTask.minute, 0, 0));

            if (!REILeadCadenceHelper.taskExists(lead.Id, eveningTask.taskName, dueDateTime.date())) {
                Task t = REILeadCadenceHelper.createTask(lead, owner, eveningTask, dueDateTime);
                tasksToCreate.add(t);
            }
        }

        // Create tasks for each missed day (1 to actualDays, up to day 14)
        for (Integer day = 1; day <= actualDays && day <= 14; day++) {
            List<REILeadCadenceHelper.TaskDefinition> dayTasks = allTaskDefs.get(day);
            if (dayTasks != null) {
                for (REILeadCadenceHelper.TaskDefinition taskDef : dayTasks) {
                    // All missed tasks get created for today with their scheduled times
                    DateTime dueDateTime = DateTime.newInstance(Date.today(), Time.newInstance(taskDef.hour, taskDef.minute, 0, 0));
                    dueDateTime = REILeadCadenceHelper.adjustToBusinessHours(dueDateTime);

                    if (!REILeadCadenceHelper.taskExists(lead.Id, taskDef.taskName, dueDateTime.date())) {
                        Task t = REILeadCadenceHelper.createTask(lead, owner, taskDef, dueDateTime);
                        tasksToCreate.add(t);
                    }
                }
            }
        }
    }
}
