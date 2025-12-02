/**
 * Test class for REILeadCadenceHelper
 */
@isTest
public class REILeadCadenceHelperTest {

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
    static void testIsWeekend() {
        // Saturday
        Date saturday = Date.newInstance(2024, 1, 6);
        System.assertEquals(true, REILeadCadenceHelper.isWeekend(saturday), 'Saturday should be weekend');

        // Sunday
        Date sunday = Date.newInstance(2024, 1, 7);
        System.assertEquals(true, REILeadCadenceHelper.isWeekend(sunday), 'Sunday should be weekend');

        // Monday
        Date monday = Date.newInstance(2024, 1, 8);
        System.assertEquals(false, REILeadCadenceHelper.isWeekend(monday), 'Monday should not be weekend');
    }

    @isTest
    static void testGetNextBusinessDay() {
        // Saturday should return Monday
        Date saturday = Date.newInstance(2024, 1, 6);
        Date result = REILeadCadenceHelper.getNextBusinessDay(saturday);
        System.assertEquals(Date.newInstance(2024, 1, 8), result, 'Saturday should return Monday');

        // Monday should return Monday
        Date monday = Date.newInstance(2024, 1, 8);
        result = REILeadCadenceHelper.getNextBusinessDay(monday);
        System.assertEquals(monday, result, 'Monday should return Monday');
    }

    @isTest
    static void testIsWithinBusinessHours() {
        // 9 AM - should be within
        DateTime nineAM = DateTime.newInstance(2024, 1, 8, 9, 0, 0);
        System.assertEquals(true, REILeadCadenceHelper.isWithinBusinessHours(nineAM), '9 AM should be within business hours');

        // 7 PM - should be outside (7 PM = 19:00 which is the end)
        DateTime sevenPM = DateTime.newInstance(2024, 1, 8, 19, 0, 0);
        System.assertEquals(false, REILeadCadenceHelper.isWithinBusinessHours(sevenPM), '7 PM should be outside business hours');

        // 7 AM - should be outside
        DateTime sevenAM = DateTime.newInstance(2024, 1, 8, 7, 0, 0);
        System.assertEquals(false, REILeadCadenceHelper.isWithinBusinessHours(sevenAM), '7 AM should be outside business hours');
    }

    @isTest
    static void testAdjustToBusinessHours() {
        // After hours on weekday - should push to next day 8 AM
        DateTime eightPM = DateTime.newInstance(2024, 1, 8, 20, 0, 0); // Monday 8 PM
        DateTime result = REILeadCadenceHelper.adjustToBusinessHours(eightPM);
        System.assertEquals(8, result.hour(), 'Should be 8 AM');
        System.assertEquals(Date.newInstance(2024, 1, 9), result.date(), 'Should be next day');

        // Weekend - should push to Monday 8 AM
        DateTime saturdayNoon = DateTime.newInstance(2024, 1, 6, 12, 0, 0);
        result = REILeadCadenceHelper.adjustToBusinessHours(saturdayNoon);
        System.assertEquals(8, result.hour(), 'Should be 8 AM');
        System.assertEquals(Date.newInstance(2024, 1, 8), result.date(), 'Should be Monday');
    }

    @isTest
    static void testGetTasksForDay() {
        List<REILeadCadenceHelper.TaskDefinition> day0Tasks = REILeadCadenceHelper.getTasksForDay(0);
        System.assertEquals(5, day0Tasks.size(), 'Day 0 should have 5 tasks');

        List<REILeadCadenceHelper.TaskDefinition> day1Tasks = REILeadCadenceHelper.getTasksForDay(1);
        System.assertEquals(3, day1Tasks.size(), 'Day 1 should have 3 tasks');

        List<REILeadCadenceHelper.TaskDefinition> day99Tasks = REILeadCadenceHelper.getTasksForDay(99);
        System.assertEquals(0, day99Tasks.size(), 'Day 99 should have no tasks');
    }

    @isTest
    static void testReplaceMergeFields() {
        Lead lead = [SELECT Id, FirstName, Property_Address__c, Property_City__c, OwnerId FROM Lead LIMIT 1];
        User owner = [SELECT Id, FirstName, Phone FROM User WHERE Id = :lead.OwnerId];

        String script = 'Hi [Name], this is [Lead Manager First Name] from [Company] about [Address] in [Neighborhood]. Call me at [Lead Manager Phone].';
        String result = REILeadCadenceHelper.replaceMergeFields(script, lead, owner);

        System.assert(result.contains('John'), 'Should contain lead first name');
        System.assert(result.contains('Test'), 'Should contain owner first name');
        System.assert(result.contains('REI Team'), 'Should contain company name');
        System.assert(result.contains('123 Main St'), 'Should contain address');
        System.assert(result.contains('Denver'), 'Should contain city');
    }

    @isTest
    static void testTaskExists() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        // Should not exist initially
        Boolean exists = REILeadCadenceHelper.taskExists(lead.Id, 'Test Task', Date.today());
        System.assertEquals(false, exists, 'Task should not exist');

        // Create task
        Task t = new Task(
            Subject = 'Test Task',
            WhoId = lead.Id,
            ActivityDate = Date.today(),
            Cadence_Name__c = REILeadCadenceHelper.CADENCE_NAME
        );
        insert t;

        // Should exist now
        exists = REILeadCadenceHelper.taskExists(lead.Id, 'Test Task', Date.today());
        System.assertEquals(true, exists, 'Task should exist');
    }

    @isTest
    static void testCalculateCadenceDay() {
        // Today should be day 0
        Integer day = REILeadCadenceHelper.calculateCadenceDay(Date.today());
        System.assertEquals(0, day, 'Today should be day 0');

        // Yesterday should be day 1
        day = REILeadCadenceHelper.calculateCadenceDay(Date.today().addDays(-1));
        System.assertEquals(1, day, 'Yesterday should be day 1');
    }

    @isTest
    static void testIsWithinReentryWindow() {
        // Today - within window
        System.assertEquals(true, REILeadCadenceHelper.isWithinReentryWindow(Date.today()), 'Today should be within window');

        // 5 days ago - within window
        System.assertEquals(true, REILeadCadenceHelper.isWithinReentryWindow(Date.today().addDays(-5)), '5 days ago should be within window');

        // 6 days ago - outside window
        System.assertEquals(false, REILeadCadenceHelper.isWithinReentryWindow(Date.today().addDays(-6)), '6 days ago should be outside window');
    }
}
