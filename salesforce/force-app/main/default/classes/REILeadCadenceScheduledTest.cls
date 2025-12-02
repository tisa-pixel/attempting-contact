/**
 * Test class for REILeadCadenceScheduled
 */
@isTest
public class REILeadCadenceScheduledTest {

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
    }

    @isTest
    static void testCreateDay0EveningTask() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'towner' LIMIT 1];

        // Create lead that entered today
        Lead lead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Status = 'Attempting_Contact',
            Property_Address__c = '123 Main St',
            Property_City__c = 'Denver',
            Last_Submission_Date__c = Date.today(),
            OwnerId = testUser.Id
        );
        insert lead;

        Test.startTest();
        REILeadCadenceScheduled.createDailyTasks();
        Test.stopTest();

        // Should create Evening Text task
        List<Task> tasks = [SELECT Subject FROM Task WHERE WhoId = :lead.Id AND Subject = 'Evening Text'];
        System.assertEquals(1, tasks.size(), 'Should have Evening Text task');
    }

    @isTest
    static void testCreateDay1Tasks() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'towner' LIMIT 1];

        // Create lead that entered yesterday (Day 1)
        Lead lead = new Lead(
            FirstName = 'Jane',
            LastName = 'Smith',
            Company = 'Test Company',
            Status = 'Attempting_Contact',
            Property_Address__c = '456 Oak Ave',
            Property_City__c = 'Boulder',
            Last_Submission_Date__c = Date.today().addDays(-1),
            OwnerId = testUser.Id
        );
        insert lead;

        Test.startTest();
        REILeadCadenceScheduled.createDailyTasks();
        Test.stopTest();

        // Should create Day 1 tasks (3 tasks)
        List<Task> tasks = [SELECT Subject FROM Task WHERE WhoId = :lead.Id];
        System.assertEquals(3, tasks.size(), 'Should have 3 Day 1 tasks');
    }

    @isTest
    static void testSkipsLeadsBeyondDay14() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'towner' LIMIT 1];

        // Create lead that entered 15 days ago
        Lead lead = new Lead(
            FirstName = 'Old',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Attempting_Contact',
            Property_Address__c = '789 Pine St',
            Property_City__c = 'Arvada',
            Last_Submission_Date__c = Date.today().addDays(-15),
            OwnerId = testUser.Id
        );
        insert lead;

        Test.startTest();
        REILeadCadenceScheduled.createDailyTasks();
        Test.stopTest();

        // Should not create any tasks
        List<Task> tasks = [SELECT Id FROM Task WHERE WhoId = :lead.Id];
        System.assertEquals(0, tasks.size(), 'Should have no tasks for day 15+');
    }

    @isTest
    static void testSchedulableInterface() {
        Test.startTest();
        String jobId = System.schedule(
            'Test REI Cadence',
            '0 0 8 * * ?',
            new REILeadCadenceScheduled()
        );
        Test.stopTest();

        // Verify job was scheduled
        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, jobs.size(), 'Job should be scheduled');
    }
}
