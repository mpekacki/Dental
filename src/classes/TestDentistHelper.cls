/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class TestDentistHelper {

	@isTest
    static void testCarveOutAppointmentsFromTimeBlock() {
        AvailableTime__c a = new AvailableTime__c();
        a.TimeFrom__c = 1000;
        a.TimeTo__c = 1600;
        a.Date__c = Date.newInstance(2016, 1, 1);
        
        List<Appointment__c> apps = new List<Appointment__c>();
        
        Appointment__c app1 = new Appointment__c();
      	app1.Date_and_time_start__c = TimeConverter.extractTimeFrom(a).addMinutes(30);
      	app1.Date_and_time_end__c = app1.Date_and_time_start__c.addMinutes(30);
      	
      	apps.add(app1);
      	
      	Appointment__c app2 = new Appointment__c();
      	app2.Date_and_time_start__c = TimeConverter.extractTimeFrom(a).addMinutes(180);
      	app2.Date_and_time_end__c = app2.Date_and_time_start__c.addMinutes(30);
      	
      	apps.add(app2);
      	      	      	
      	List<Dentist__c> dentists = [SELECT ID FROM Dentist__c];
      	System.assertNotEquals(dentists.size(), 0);
    	for (Dentist__c d : dentists) {
    		DentistHelper helper = new DentistHelper(d.Id);
    		      	
	      	List<AvailableTime__c> fragmented = helper.carveOutAppointmentsFromTimeBlock(a, apps);
			System.assertEquals(3, fragmented.size());
    	}
    }
    
    @isTest
    static void testGetPossibleAppointmentStartTimes() {
    	List<Dentist__c> dentists = [SELECT ID FROM Dentist__c];
    	System.assertNotEquals(dentists.size(), 0);
    	for (Dentist__c d : dentists) {
    		DentistHelper helper = new DentistHelper(d.Id);
    		List<DateTime> possibleTimes = helper.getPossibleAppointmentStartTimes();
    	}
    }
    
    @isTest
    static void testGetPreview() {
    	List<Dentist__c> dentists = [SELECT ID FROM Dentist__c];
    	System.assertNotEquals(dentists.size(), 0);
    	for (Dentist__c dt : dentists) {
    		DentistHelper helper = new DentistHelper(dt.Id);
    		for (Date d = Date.today(); d < Date.today().addMonths(3); d = d.addMonths(1)){
    			List<HoursPreview> prev = helper.getHoursPreviewByMonthYear(d.month(), d.year());
    			Integer daysInMonth = Date.daysInMonth(d.year(), d.month());
    			Integer daysInPreview = 0;
    			for (HoursPreview h : prev) {
    				for(DayPreview dp : h.days) {
    					if (dp.d.month() == d.month()) {
    						daysInPreview++;
    					}
    				}
    			}
    			System.assertEquals(daysInMonth, daysInPreview);
    		}
    	}
    }
}