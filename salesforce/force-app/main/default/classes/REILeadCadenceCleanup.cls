/**
 * REILeadCadenceCleanup
 * Deletes incomplete cadence tasks when Lead exits "Attempting_Contact" status
 *
 * Called from Flow via @InvocableMethod when Lead.Status changes FROM Attempting_Contact
 */
public class REILeadCadenceCleanup {

    public class Request {
        @InvocableVariable(label='Lead ID' required=true)
        public Id leadId;
    }

    public class Result {
        @InvocableVariable(label='Tasks Deleted')
        public Integer tasksDeleted;

        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(label='Delete Incomplete Cadence Tasks' description='Deletes all open Attempting Contact tasks for a Lead')
    public static List<Result> deleteIncompleteTasks(List<Request> requests) {
        List<Result> results = new List<Result>();

        // Collect all lead IDs
        Set<Id> leadIds = new Set<Id>();
        for (Request req : requests) {
            leadIds.add(req.leadId);
        }

        // Query all incomplete cadence tasks for these leads
        List<Task> tasksToDelete = [
            SELECT Id, WhoId
            FROM Task
            WHERE WhoId IN :leadIds
            AND Cadence_Name__c = :REILeadCadenceHelper.CADENCE_NAME
            AND IsClosed = false
        ];

        // Group tasks by lead
        Map<Id, List<Task>> tasksByLead = new Map<Id, List<Task>>();
        for (Task t : tasksToDelete) {
            if (!tasksByLead.containsKey(t.WhoId)) {
                tasksByLead.put(t.WhoId, new List<Task>());
            }
            tasksByLead.get(t.WhoId).add(t);
        }

        // Delete tasks and build results
        if (!tasksToDelete.isEmpty()) {
            delete tasksToDelete;
        }

        for (Request req : requests) {
            Result res = new Result();
            res.success = true;

            List<Task> leadTasks = tasksByLead.get(req.leadId);
            res.tasksDeleted = leadTasks != null ? leadTasks.size() : 0;

            results.add(res);
        }

        return results;
    }
}
