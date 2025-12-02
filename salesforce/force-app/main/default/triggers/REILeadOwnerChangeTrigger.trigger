/**
 * REILeadOwnerChangeTrigger
 * When Lead Owner changes, reassign all open cadence tasks to the new owner
 */
trigger REILeadOwnerChangeTrigger on Lead (after update) {

    // Collect leads where owner changed
    Map<Id, Id> leadToNewOwner = new Map<Id, Id>();

    for (Lead newLead : Trigger.new) {
        Lead oldLead = Trigger.oldMap.get(newLead.Id);

        if (oldLead.OwnerId != newLead.OwnerId) {
            leadToNewOwner.put(newLead.Id, newLead.OwnerId);
        }
    }

    if (leadToNewOwner.isEmpty()) {
        return;
    }

    // Get all open cadence tasks for these leads
    List<Task> tasksToUpdate = [
        SELECT Id, WhoId, OwnerId
        FROM Task
        WHERE WhoId IN :leadToNewOwner.keySet()
        AND Cadence_Name__c = 'Attempting Contact'
        AND IsClosed = false
    ];

    // Reassign to new owner
    for (Task t : tasksToUpdate) {
        Id newOwnerId = leadToNewOwner.get(t.WhoId);
        if (newOwnerId != null) {
            t.OwnerId = newOwnerId;
        }
    }

    if (!tasksToUpdate.isEmpty()) {
        update tasksToUpdate;
    }
}
