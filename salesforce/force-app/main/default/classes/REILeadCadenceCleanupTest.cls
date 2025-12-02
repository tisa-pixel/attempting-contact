/**
 * Test class for REILeadCadenceCleanup and Owner Change Trigger
 */
@isTest
public class REILeadCadenceCleanupTest {

    @TestSetup
    static void setupTestData() {
        // Create test users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'Owner1',
            Email = 'testowner1@test.com',
            Username = 'testowner1' + DateTime.now().getTime() + '@test.com',
            Alias = 'towner1',
            TimeZoneSidKey = 'America/Denver',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            Phone = '303-555-1234'
        );
        insert testUser1;

        User testUser2 = new User(
            FirstName = 'Test',
            LastName = 'Owner2',
            Email = 'testowner2@test.com',
            Username = 'testowner2' + DateTime.now().getTime() + '@test.com',
            Alias = 'towner2',
            TimeZoneSidKey = 'America/Denver',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            Phone = '303-555-5678'
        );
        insert testUser2;
    }

    @isTest
    static void testCleanupDeletesIncompleteTasks() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'towner1' LIMIT 1];

        // Create lead
        Lead lead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Status = 'Attempting_Contact',
            Property_Address__c = '123 Main St',
            Property_City__c = 'Denver',
            OwnerId = testUser.Id
        );
        insert lead;

        // Create cadence tasks
        List<Task> tasks = new List<Task>();
        tasks.add(new Task(
            Subject = 'First Contact - Text',
            WhoId = lead.Id,
            OwnerId = testUser.Id,
            Cadence_Name__c = 'Attempting Contact',
            Status = 'Not Started'
        ));
        tasks.add(new Task(
            Subject = 'First Call - No VM',
            WhoId = lead.Id,
            OwnerId = testUser.Id,
            Cadence_Name__c = 'Attempting Contact',
            Status = 'Completed' // This one is completed
        ));
        tasks.add(new Task(
            Subject = 'Personal Email',
            WhoId = lead.Id,
            OwnerId = testUser.Id,
            Cadence_Name__c = 'Attempting Contact',
            Status = 'Not Started'
        ));
        insert tasks;

        REILeadCadenceCleanup.Request req = new REILeadCadenceCleanup.Request();
        req.leadId = lead.Id;

        Test.startTest();
        List<REILeadCadenceCleanup.Result> results = REILeadCadenceCleanup.deleteIncompleteTasks(
            new List<REILeadCadenceCleanup.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(true, results[0].success, 'Should be successful');
        System.assertEquals(2, results[0].tasksDeleted, 'Should delete 2 incomplete tasks');

        // Verify only completed task remains
        List<Task> remainingTasks = [SELECT Subject FROM Task WHERE WhoId = :lead.Id];
        System.assertEquals(1, remainingTasks.size(), 'Should have 1 remaining task');
        System.assertEquals('First Call - No VM', remainingTasks[0].Subject, 'Completed task should remain');
    }

    @isTest
    static void testOwnerChangeTriggerReassignsTasks() {
        User testUser1 = [SELECT Id FROM User WHERE Alias = 'towner1' LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE Alias = 'towner2' LIMIT 1];

        // Create lead with first owner
        Lead lead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Status = 'Attempting_Contact',
            Property_Address__c = '123 Main St',
            Property_City__c = 'Denver',
            OwnerId = testUser1.Id
        );
        insert lead;

        // Create cadence tasks owned by first user
        List<Task> tasks = new List<Task>();
        tasks.add(new Task(
            Subject = 'First Contact - Text',
            WhoId = lead.Id,
            OwnerId = testUser1.Id,
            Cadence_Name__c = 'Attempting Contact',
            Status = 'Not Started'
        ));
        tasks.add(new Task(
            Subject = 'First Call - No VM',
            WhoId = lead.Id,
            OwnerId = testUser1.Id,
            Cadence_Name__c = 'Attempting Contact',
            Status = 'Not Started'
        ));
        insert tasks;

        Test.startTest();
        // Change lead owner
        lead.OwnerId = testUser2.Id;
        update lead;
        Test.stopTest();

        // Verify tasks were reassigned
        List<Task> updatedTasks = [SELECT OwnerId FROM Task WHERE WhoId = :lead.Id];
        for (Task t : updatedTasks) {
            System.assertEquals(testUser2.Id, t.OwnerId, 'Task should be reassigned to new owner');
        }
    }
}
