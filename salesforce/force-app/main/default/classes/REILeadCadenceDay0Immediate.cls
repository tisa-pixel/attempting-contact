/**
 * REILeadCadenceDay0Immediate
 * Creates the 3 immediate Day 0 tasks when Lead enters "Attempting_Contact" status
 * - First Contact Text (immediate)
 * - First Call - No VM (immediate)
 * - Personal Email (immediate)
 *
 * Called from Flow via @InvocableMethod
 */
public class REILeadCadenceDay0Immediate {

    public class Request {
        @InvocableVariable(label='Lead ID' required=true)
        public Id leadId;
    }

    public class Result {
        @InvocableVariable(label='Tasks Created')
        public Integer tasksCreated;

        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(label='Create Day 0 Immediate Tasks' description='Creates the 3 immediate tasks for Day 0 of Attempting Contact cadence')
    public static List<Result> createDay0ImmediateTasks(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result res = new Result();
            res.tasksCreated = 0;
            res.success = true;

            try {
                // Get lead and owner info
                Lead lead = REILeadCadenceHelper.getLeadWithFields(req.leadId);
                User owner = REILeadCadenceHelper.getUserWithFields(lead.OwnerId);

                // Set Last_Submission_Date__c to today if not set or if re-entry after 5 days
                Date lastSubmission = lead.Last_Submission_Date__c;
                Boolean needsUpdate = false;

                if (lastSubmission == null || !REILeadCadenceHelper.isWithinReentryWindow(lastSubmission)) {
                    lastSubmission = Date.today();
                    lead.Last_Submission_Date__c = lastSubmission;
                    needsUpdate = true;
                }

                // Get immediate tasks (first 3 tasks of Day 0)
                List<REILeadCadenceHelper.TaskDefinition> day0Tasks = REILeadCadenceHelper.getTasksForDay(0);
                List<Task> tasksToCreate = new List<Task>();

                // Current time for immediate tasks
                DateTime now = DateTime.now();
                DateTime adjustedNow = REILeadCadenceHelper.adjustToBusinessHours(now);

                // Create immediate tasks (first 3: Text, Call, Email)
                for (Integer i = 0; i < 3 && i < day0Tasks.size(); i++) {
                    REILeadCadenceHelper.TaskDefinition taskDef = day0Tasks[i];

                    // Check for duplicates
                    if (!REILeadCadenceHelper.taskExists(lead.Id, taskDef.taskName, adjustedNow.date())) {
                        Task t = REILeadCadenceHelper.createTask(lead, owner, taskDef, adjustedNow);
                        tasksToCreate.add(t);
                    }
                }

                // Insert tasks
                if (!tasksToCreate.isEmpty()) {
                    insert tasksToCreate;
                    res.tasksCreated = tasksToCreate.size();
                }

                // Update lead if Last_Submission_Date__c changed
                if (needsUpdate) {
                    update lead;
                }

            } catch (Exception e) {
                res.success = false;
                res.errorMessage = e.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}
