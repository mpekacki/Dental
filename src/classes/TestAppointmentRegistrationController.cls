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
        System.assertEquals(Constants.APPOINTMENT_STATUS_AWAITING, insertedRecord.Status__c);
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

    @isTest
    static void testDeleteTemporaryAppointment() {
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

        List<ID> ids = new List<ID>();
        ids.add(app.ID);

        DeleteTemporaryAppointment.deleteTemporaryAppointment(ids);
    }
}