@isTest
private class TestAppointmentNoOverlapTrigger {
	
	private static ID insertDentist() {
		Dentist__c d = new Dentist__c(Name='Testowy', First_Name__c = 'Test', Last_Name__c = 'Tester');
		insert d;
		return d.ID;
	}
	
	private static void insertAvailableTime(ID dentistID, Decimal timeFrom, Decimal timeTo, Date d) {

	}

	@isTest
    static void testNoOverlap() {
    	ID dentistID = insertDentist();
    	
    	AvailableTime__c a = new AvailableTime__c(Dentist__c = dentistID, TimeFrom__c = 1200, TimeTo__c = 1400, Date__c = Date.newInstance(2016, 5, 16));
		insert a;
		
    	DateTime dateStart = DateTime.newInstance(2016, 5, 16, 12, 0, 0);
    	DateTime dateEnd = dateStart.addMinutes(30);
        Appointment__c app1 = new Appointment__c(Dentist__c = dentistID, Date_and_time_start__c = dateStart, Date_and_time_end__c = dateEnd);
        Appointment__c app2 = new Appointment__c(Dentist__c = dentistID, Date_and_time_start__c = dateStart, Date_and_time_end__c = dateEnd);
        
        insert app1;
        try {
        	insert app2; // should throw exception
        	System.assert(false); // should not reach here
        } catch (DmlException e) {
        	System.assertEquals(1, e.getNumDml());
        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
    }
    
    @isTest
    static void testOutsideTime() {
    	ID dentistID = insertDentist();
    	
    	AvailableTime__c a = new AvailableTime__c(Dentist__c = dentistID, TimeFrom__c = 1200, TimeTo__c = 1400, Date__c = Date.newInstance(2016, 5, 16));
		insert a;
    	
    	DateTime dateStart = DateTime.newInstance(2016, 5, 16, 14, 0, 0);
    	DateTime dateEnd = dateStart.addMinutes(30);
        Appointment__c app1 = new Appointment__c(Dentist__c = dentistID, Date_and_time_start__c = dateStart, Date_and_time_end__c = dateEnd);
        
        try {
        	insert app1; // should throw exception
            System.assert(false); // should not reach here
        } catch (DmlException e) {
        	System.assertEquals(1, e.getNumDml());
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
    }
    
    @isTest
    static void testInsideTimeDate() {
    	ID dentistID = insertDentist();
    	
    	Date d1 = Date.newInstance(2016, 5, 16);
    	
    	AvailableTime__c a1 = new AvailableTime__c(Dentist__c = dentistID, TimeFrom__c = 1200, TimeTo__c = 1400, Date__c = d1);

		insert a1;
		
		DateTime dateStart1 = DateTime.newInstance(2016, 5, 16, 12, 0, 0);
    	DateTime dateEnd1 = dateStart1.addMinutes(30);
        Appointment__c app1 = new Appointment__c(Dentist__c = dentistID, Date_and_time_start__c = dateStart1, Date_and_time_end__c = dateEnd1);
        
        insert app1;

    	
    }
    
    @isTest
    static void testInsideTimeDay() {
    	ID dentistID = insertDentist();
    	
    	String dow2 = ((DateTime)Date.newInstance(2016, 5, 17)).format('EEEE');
    	
    	AvailableTime__c a2 = new AvailableTime__c(Dentist__c = dentistID, TimeFrom__c = 1500, TimeTo__c = 1600, Day_of_week__c = dow2);
    	
    	insert a2;
    	
    	DateTime dateStart2 = DateTime.newInstance(2016, 5, 17, 15, 0, 0);
    	DateTime dateEnd2 = dateStart2.addMinutes(30);
        Appointment__c app2 = new Appointment__c(Dentist__c = dentistID, Date_and_time_start__c = dateStart2, Date_and_time_end__c = dateEnd2);
        
        insert app2;
    }
}