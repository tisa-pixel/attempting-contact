// Run this in Developer Console -> Execute Anonymous
// Creates the custom fields needed for the Attempting Contact cadence

// NOTE: Custom fields on Activity (Task/Event) cannot be created via Apex
// They must be created manually in Setup:
// 1. Setup -> Object Manager -> Activity -> Fields & Relationships -> New
// 2. Create these fields:

/*
Field 1: Cadence Name
- Field Label: Cadence Name
- Field Name: Cadence_Name
- Data Type: Text
- Length: 50
- Description: Identifies which cadence created this task

Field 2: Cadence Day
- Field Label: Cadence Day
- Field Name: Cadence_Day
- Data Type: Number
- Length: 2
- Decimal Places: 0
- Description: Which day in the cadence (0-14)

Field 3: Coaching Notes
- Field Label: Coaching Notes
- Field Name: Coaching_Notes
- Data Type: Long Text Area
- Length: 5000
- Visible Lines: 4
- Description: Coaching tips explaining why this technique works
*/

System.debug('Please create the Task custom fields manually in Setup:');
System.debug('Setup -> Object Manager -> Activity -> Fields & Relationships -> New');
System.debug('');
System.debug('1. Cadence_Name__c (Text 50)');
System.debug('2. Cadence_Day__c (Number 2,0)');
System.debug('3. Coaching_Notes__c (Long Text Area 5000)');
