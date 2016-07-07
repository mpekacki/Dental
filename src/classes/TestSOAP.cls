@isTest(SeeAllData=true)
private class TestSOAP {

	@isTest
    static List<DentistWithHours> testGetDentistsWithHours() {
    	Integer year = 2016;
    	Integer month = 7;

        List<DentistWithHours> dwhs = AppointmentRegistrationSOAPWebService.getDentistsAndHours(year, month);
        Integer noOfDentists = [SELECT ID FROM Dentist__c].size();
        
        System.assertEquals(noOfDentists, dwhs.size());

        return dwhs;
    }

    @isTest
    static void testPostAppointment() {
    	List<DentistWithHours> dwhs = testGetDentistsWithHours();

        ID dentistId = dwhs[0].dentist.ID;

        Date appointmentDate = dwhs[0].availableDays[0].day;
        String appointmentTime = dwhs[0].availableDays[0].availableHours[0].timeFrom;
        String description = 'Aua';
        String typeName = 'Treatment';
        String firstName = 'Dexter';
        String lastName = 'Morgan';
        String phone = '444444';
        String email = 'marcel.pekacki+dexter@gmail.com';

    	Appointment__c app = AppointmentRegistrationSOAPWebService.registerAppointment(dentistId,
												appointmentDate,
												appointmentTime,
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

        DateTime timeStart = TimeConverter.addTimeToDate(appointmentTime, appointmentDate);
         
        System.assertEquals(dentistId, insertedRecord.Dentist__c);
        System.assertEquals(timeStart, insertedRecord.Date_and_time_start__c);
        System.assertEquals(timeStart.addMinutes(Constants.APPOINTMENT_TIME_IN_MINUTES), insertedRecord.Date_and_time_end__c);
        System.assertEquals(description, insertedRecord.Description__c);
        System.assertEquals(typeName, insertedRecord.RecordType.Name);
        System.assertEquals(firstName, insertedRecord.Contact__r.FirstName);
        System.assertEquals(lastName, insertedRecord.Contact__r.LastName);
        System.assertEquals(phone, insertedRecord.Contact__r.Phone);
        System.assertEquals(email, insertedRecord.Contact__r.Email);
    }

    @isTest
    static void testRegisterOnTakenSlot() {
    	List<DentistWithHours> dwhs = testGetDentistsWithHours();

        ID dentistId = dwhs[0].dentist.ID;
        Date appointmentDate = dwhs[0].availableDays[0].day;
        String appointmentTime = dwhs[0].availableDays[0].availableHours[0].timeFrom;

        DateTime timeStart = TimeConverter.addTimeToDate(appointmentTime, appointmentDate);

        AccountRemoter.reserveTimeSlot(null, dentistId, timeStart);
        
        String description = 'Aua';
        String typeName = 'Treatment';
        String firstName = 'Dexter';
        String lastName = 'Morgan';
        String phone = '444444';
        String email = 'marcel.pekacki+dexter@gmail.com';

        try{
        	AppointmentRegistrationSOAPWebService.registerAppointment(dentistId,
												appointmentDate,
												appointmentTime,
												description,
												typeName,
												firstName,
												lastName,
												phone,
												email); // should throw an exception
        	System.assert(false); // should not reach here
    	} catch (DmlException e) {
    		System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
    	}
    }
}