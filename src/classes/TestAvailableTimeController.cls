@isTest
private class TestAvailableTimeController {

	@isTest
    static void testCreateRecordDay() {
    	Dentist__c dentist = TestTools.createDentist(UserInfo.getUserID());
        AvailableTimeController ctr = new AvailableTimeController();
        ctr.availableTime.TimeFrom__c = 600;
        ctr.availableTime.TimeTo__c = 960;
        ctr.availableTime.Day_of_week__c = 'Monday';
        
        ctr.save();
        
        AvailableTime__c inserted = [SELECT ID, TimeFrom__c, TimeTo__c, Day_of_week__c, Date__c FROM AvailableTime__c WHERE Dentist__c = :dentist.ID LIMIT 1];
        System.assertEquals(600, inserted.TimeFrom__c);
        System.assertEquals(960, inserted.TimeTo__c);
        System.assertEquals('Monday', inserted.Day_of_week__c);
        System.assertEquals(null, inserted.Date__c);
    }
    
	@isTest
    static void testCreateRecordDate() {
    	Dentist__c dentist = TestTools.createDentist(UserInfo.getUserID());
        AvailableTimeController ctr = new AvailableTimeController();
        ctr.availableTime.TimeFrom__c = 600;
        ctr.availableTime.TimeTo__c = 960;
        ctr.availableTime.Date__c = Date.today();
        
        ctr.save();
        
        AvailableTime__c inserted = [SELECT ID, TimeFrom__c, TimeTo__c, Day_of_week__c, Date__c FROM AvailableTime__c WHERE Dentist__c = :dentist.ID LIMIT 1];
        System.assertEquals(600, inserted.TimeFrom__c);
        System.assertEquals(960, inserted.TimeTo__c);
        System.assertEquals(Date.today(), inserted.Date__c);
        System.assertEquals(null, inserted.Day_of_week__c);
    }
    
    @isTest
    static void testDeleteRecord() {
    	Dentist__c dentist = TestTools.createDentist(UserInfo.getUserID());
    	AvailableTimeController ctr = new AvailableTimeController();
        ctr.availableTime.TimeFrom__c = 600;
        ctr.availableTime.TimeTo__c = 960;
        ctr.availableTime.Date__c = Date.today();
        
        ctr.save();
        
        ctr.selectedID = [SELECT ID FROM AvailableTime__c WHERE Dentist__c = :dentist.ID LIMIT 1].Id;
        ctr.deleteRecord();
    }
    
    @isTest
    static void testGetLists() {
    	Dentist__c dentist = TestTools.createDentist(UserInfo.getUserID());
    	AvailableTimeController ctr = new AvailableTimeController();
    	List<SelectOption> dentists = ctr.getHours();
    	List<SelectOption> types = ctr.getTypes();
    	List<AvailableTime__c> defaultHours = ctr.getDefaultHours();
    	List<AvailableTime__c> customHours = ctr.getCustomHours();
    }
}