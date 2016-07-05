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
public class TestAppointmentRegistrationController {
	
	@isTest
    public static void testBookingAnAppointment() {
        AppointmentRegistrationController ctr = new AppointmentRegistrationController();
        Appointment__c app = ctr.appointment;
        
        Dentist__c dentist = ctr.dentists[0];
        app.Dentist__c = dentist.ID;
        
        List<Date> dates = ctr.getAvailableDatesForDentist(dentist.ID);
        Date d = dates[0];
        List<DateTime> times = ctr.getAvailableTimesForDentistAndDate(dentist.ID, d);
        DateTime dt = times[0];
        
        app.Date_and_time_start__c = dt;
        
        ctr.saveTemporary();
        
        dt = times[1]; // select other date
        app.Date_and_time_start__c = dt;
        
        ctr.saveTemporary();
        
        ctr.contact.FirstName = 'Jesse';
        ctr.contact.LastName = 'Pinkman';
        ctr.contact.Email = 'marcel.pekacki+bitch@gmail.com';
        ctr.contact.Phone = '123456789';

        app.Description__c = 'boly zomp';
        app.RecordTypeId = ctr.getAppointmentTypes()[0].getValue();
        
        ctr.savePermanent();
        
        Appointment__c insertedRecord = [SELECT ID, Status__c, Contact__c, Contact__r.Email, Dentist__r.Name FROM Appointment__c WHERE ID = :app.ID LIMIT 1];
        System.assertEquals('Awaiting confirmation', insertedRecord.Status__c);
        System.assertEquals('marcel.pekacki+bitch@gmail.com', insertedRecord.Contact__r.Email);
        System.assertEquals(Dentist.Name, insertedRecord.Dentist__r.Name);
    }
    
    @isTest
    static void testGetDentistsSO() {
    	AppointmentRegistrationController ctr = new AppointmentRegistrationController();
    	
    	List<SelectOption> dentistsSO = ctr.getDentistsSO();
    	
    	System.assertEquals(ctr.dentists.size(), dentistsSO.size());
    }
    
    @isTest
    static void testGetDatesSO() {
    	AppointmentRegistrationController ctr = new AppointmentRegistrationController();
    	
    	List<SelectOption> datesSO = ctr.getDatesSO();
    }
    
    @isTest
    static void testGetTimesSO() {
    	AppointmentRegistrationController ctr = new AppointmentRegistrationController();
    	
    	List<SelectOption> timesSO = ctr.getTimesSO();
    }
}