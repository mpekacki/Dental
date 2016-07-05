@isTest
private class TestAvailableTime {

	@isTest
    static void testRangesDoNotOverlap() {
    	Dentist__c dentist = TestTools.createDentist(UserInfo.getUserID());
        AvailableTime__c a1 = new AvailableTime__c(TimeFrom__c = 1000, TimeTo__c = 1200, Day_of_week__c = 'Monday', Dentist__c = dentist.ID);
        AvailableTime__c a2 = new AvailableTime__c(TimeFrom__c = 800, TimeTo__c = 1400, Day_of_week__c = 'Monday', Dentist__c = dentist.ID);
        insert a1;
        try {
        	insert a2;
        } catch (DMLException e) {
        	return;
        }
        // should not reach here
        System.assert(false);
    }
    
    @isTest
    static void testAbsenceOnly() {
    	Dentist__c dentist = TestTools.createDentist(UserInfo.getUserID());
        AvailableTime__c a1 = new AvailableTime__c(TimeFrom__c = null, TimeTo__c = null, Date__c = Date.today(), Dentist__c = dentist.ID);
        AvailableTime__c a2 = new AvailableTime__c(TimeFrom__c = 800, TimeTo__c = 1400, Date__c = Date.today(), Dentist__c = dentist.ID);
        insert a1;
        try {
        	insert a2;
        } catch (DMLException e1) {
        	// reverse insertion order
        	delete a1;
        	insert a2; 
        	try {
        		insert a1;
        	} catch (DMLException e2) {
        		return;
        	}
        }
        // should not reach here
        System.assert(false);
    }
}