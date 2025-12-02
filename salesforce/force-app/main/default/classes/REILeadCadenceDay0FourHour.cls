/**
 * REILeadCadenceDay0FourHour
 * Creates the +4 hour task for Day 0
 * - Second Call + Leave VM
 *
 * Called from Flow Scheduled Path (4 hours after entry)
 */
public class REILeadCadenceDay0FourHour {

    public class Request {
        @InvocableVariable(label='Lead ID' required=true)
        public Id leadId;
    }

    public class Result {
        @InvocableVariable(label='Task Created')
        public Boolean taskCreated;

        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(label='Create Day 0 Four Hour Task' description='Creates the +4 hour task (Second Call + VM) for Day 0')
    public static List<Result> createDay0FourHourTask(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result res = new Result();
            res.taskCreated = false;
            res.success = true;

            try {
                // Get lead and owner info
                Lead lead = REILeadCadenceHelper.getLeadWithFields(req.leadId);

                // Only proceed if lead is still in Attempting_Contact status
                if (lead.Status != 'Attempting_Contact') {
                    res.success = true;
                    res.taskCreated = false;
                    results.add(res);
                    continue;
                }

                User owner = REILeadCadenceHelper.getUserWithFields(lead.OwnerId);

                // Get the +4 hour task (4th task in Day 0 list, index 3)
                List<REILeadCadenceHelper.TaskDefinition> day0Tasks = REILeadCadenceHelper.getTasksForDay(0);

                if (day0Tasks.size() > 3) {
                    REILeadCadenceHelper.TaskDefinition taskDef = day0Tasks[3]; // Second Call + VM

                    // Calculate due time (now, adjusted for business hours)
                    DateTime now = DateTime.now();
                    DateTime dueDateTime = REILeadCadenceHelper.adjustToBusinessHours(now);

                    // Check for duplicates
                    if (!REILeadCadenceHelper.taskExists(lead.Id, taskDef.taskName, dueDateTime.date())) {
                        Task t = REILeadCadenceHelper.createTask(lead, owner, taskDef, dueDateTime);
                        insert t;
                        res.taskCreated = true;
                    }
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
