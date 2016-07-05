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
private class TestFilterCriterion {

	@isTest
    static void testCriterionOnAppointments() {
    	Appointment__c app1 = new Appointment__c(Status__c = 'Confirmed');
    	Appointment__c app2 = new Appointment__c(Status__c = 'Rejected');
    	
    	List<Appointment__c> apps = new List<Appointment__c>();
    	apps.add(app1);
    	apps.add(app2);
    	
    	FilterCriterion f = new FilterCriterion(apps, 'Status__c', 'Status__c', 'Status');
    	
    	List<Appointment__c> filtered = f.filter(apps);
    	System.assertEquals(2, filtered.size());
    	
    	f.selectedValue = 'Rejected';
    	filtered = f.filter(apps);
    	System.assertEquals(1, filtered.size());
    	
    	f.selectedValue = 'Awaiting confirmation';
    	filtered = f.filter(apps);
    	System.assertEquals(0, filtered.size());
    }
}