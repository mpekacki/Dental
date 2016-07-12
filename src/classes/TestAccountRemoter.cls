@isTest(SeeAllData=true)
private class TestAccountRemoter {

	@isTest
    static void testRegisterAppointment() {
        List<Dentist__c> dentists = AccountRemoter.getDentists();
        List<Date> dates = AccountRemoter.getAvailableDatesForDentist(dentists[0].ID);
        
        Date appDate = dates[0];
        
        List<String> times = AccountRemoter.getAvailableTimesForDentistAndDate(dentists[0].ID, appDate);
        
        ID dentistId = dentists[0].ID;
        String appTime = times[0];
        
        String sessionId = AccountRemoter.reserveTimeSlot(null, dentistId, appDate, appTime);
        
        String description = 'Aua';
        String typeName = 'Treatment';
        String firstName = 'Dexter';
        String lastName = 'Morgan';
        String phone = '444444';
        String email = 'marcel.pekacki+dexter@gmail.com';
        
        Appointment__c app = AccountRemoter.registerAppointment(sessionId,
        														dentistId,
        														appDate,
                                                                appTime,
        														description,
        														typeName,
        														firstName,
        														lastName,
        														phone,
        														email);
        														
        System.assertNotEquals(null, app.ID);
        
        Appointment__c insertedRecord = [SELECT ID, Dentist__c, Date_and_time_start__c, Date_and_time_end__c, Description__c, RecordType.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Phone, Contact__r.Email
         FROM Appointment__c 
         WHERE ID = :app.ID LIMIT 1];

        DateTime dateTimeStart = TimeConverter.addTimeToDate(appTime, appDate);
         
        System.assertEquals(dentistId, insertedRecord.Dentist__c);
        System.assertEquals(dateTimeStart, insertedRecord.Date_and_time_start__c);
        System.assertEquals(dateTimeStart.addMinutes(Constants.APPOINTMENT_TIME_IN_MINUTES), insertedRecord.Date_and_time_end__c);
        System.assertEquals(description, insertedRecord.Description__c);
        System.assertEquals(typeName, insertedRecord.RecordType.Name);
        System.assertEquals(firstName, insertedRecord.Contact__r.FirstName);
        System.assertEquals(lastName, insertedRecord.Contact__r.LastName);
        System.assertEquals(phone, insertedRecord.Contact__r.Phone);
        System.assertEquals(email, insertedRecord.Contact__r.Email);
    }
}