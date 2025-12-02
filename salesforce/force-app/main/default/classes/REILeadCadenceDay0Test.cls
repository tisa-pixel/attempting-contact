/**
 * Test class for Day 0 Apex classes
 */
@isTest
public class REILeadCadenceDay0Test {

    @TestSetup
    static void setupTestData() {
        // Create test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Owner',
            Email = 'testowner@test.com',
            Username = 'testowner' + DateTime.now().getTime() + '@test.com',
            Alias = 'towner',
            TimeZoneSidKey = 'America/Denver',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            Phone = '303-555-1234'
        );
        insert testUser;

        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Status = 'New',
            Property_Address__c = '123 Main St, Denver, CO',
            Property_City__c = 'Denver',
            OwnerId = testUser.Id
        );
        insert testLead;
    }

    @isTest
    static void testDay0ImmediateTasks() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        REILeadCadenceDay0Immediate.Request req = new REILeadCadenceDay0Immediate.Request();
        req.leadId = lead.Id;

        Test.startTest();
        List<REILeadCadenceDay0Immediate.Result> results = REILeadCadenceDay0Immediate.createDay0ImmediateTasks(
            new List<REILeadCadenceDay0Immediate.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should have 1 result');
        System.assertEquals(true, results[0].success, 'Should be successful');
        System.assertEquals(3, results[0].tasksCreated, 'Should create 3 immediate tasks');

        // Verify tasks created
        List<Task> tasks = [SELECT Subject, Type, Cadence_Name__c, Cadence_Day__c FROM Task WHERE WhoId = :lead.Id];
        System.assertEquals(3, tasks.size(), 'Should have 3 tasks');

        // Verify cadence fields
        for (Task t : tasks) {
            System.assertEquals('Attempting Contact', t.Cadence_Name__c, 'Should have cadence name');
            System.assertEquals(0, t.Cadence_Day__c, 'Should be day 0');
        }
    }

    @isTest
    static void testDay0ImmediateTasksDuplicatePrevention() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        REILeadCadenceDay0Immediate.Request req = new REILeadCadenceDay0Immediate.Request();
        req.leadId = lead.Id;

        Test.startTest();
        // First call
        REILeadCadenceDay0Immediate.createDay0ImmediateTasks(new List<REILeadCadenceDay0Immediate.Request>{ req });
        // Second call - should not create duplicates
        List<REILeadCadenceDay0Immediate.Result> results = REILeadCadenceDay0Immediate.createDay0ImmediateTasks(
            new List<REILeadCadenceDay0Immediate.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(0, results[0].tasksCreated, 'Should not create duplicate tasks');

        List<Task> tasks = [SELECT Id FROM Task WHERE WhoId = :lead.Id];
        System.assertEquals(3, tasks.size(), 'Should still have only 3 tasks');
    }

    @isTest
    static void testDay0FourHourTask() {
        Lead lead = [SELECT Id, Status FROM Lead LIMIT 1];
        lead.Status = 'Attempting_Contact';
        lead.Last_Submission_Date__c = Date.today();
        update lead;

        REILeadCadenceDay0FourHour.Request req = new REILeadCadenceDay0FourHour.Request();
        req.leadId = lead.Id;

        Test.startTest();
        List<REILeadCadenceDay0FourHour.Result> results = REILeadCadenceDay0FourHour.createDay0FourHourTask(
            new List<REILeadCadenceDay0FourHour.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(true, results[0].success, 'Should be successful');
        System.assertEquals(true, results[0].taskCreated, 'Should create task');

        List<Task> tasks = [SELECT Subject FROM Task WHERE WhoId = :lead.Id AND Subject = 'Second Call + Leave VM'];
        System.assertEquals(1, tasks.size(), 'Should have Second Call + VM task');
    }

    @isTest
    static void testDay0FourHourTaskSkipsIfNotAttempting() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        // Lead is still in 'New' status

        REILeadCadenceDay0FourHour.Request req = new REILeadCadenceDay0FourHour.Request();
        req.leadId = lead.Id;

        Test.startTest();
        List<REILeadCadenceDay0FourHour.Result> results = REILeadCadenceDay0FourHour.createDay0FourHourTask(
            new List<REILeadCadenceDay0FourHour.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(true, results[0].success, 'Should be successful');
        System.assertEquals(false, results[0].taskCreated, 'Should not create task');
    }
}
