public with sharing class AccountRemoter {
        
    @RemoteAction
    public static List<Dentist__c> getDentists() {
    	return [SELECT ID, Name, Speciality__c FROM Dentist__c];
    }
    
    @RemoteAction
    public static List<Date> getAvailableDatesForDentist(ID dentistID) {
    	List<Date> result = new List<Date>();
    	
    	Set<Date> uniqueDates = new Set<Date>();
    	for (DateTime dt : new DentistHelper(dentistID).getPossibleAppointmentStartTimes()) {
    		uniqueDates.add(dt.date());
    	}
    	
    	result.addAll(uniqueDates);
    	result.sort();
    	
    	return result;
    }
    
    @RemoteAction
    public static List<String> getAvailableTimesForDentistAndDate(ID dentistID, Date d) {
    	List<String> result = new List<String>();
    	
    	for (DateTime dt : new DentistHelper(dentistID).getPossibleAppointmentStartTimes()) {
    		if (dt.date() == d) {
    			result.add(TimeConverter.formatTime(dt));
    		}
    	}
    	
    	return result;
    }

    @RemoteAction
    public static void releaseLock(String sessionId) {
        List<Appointment__c> l = 
            [SELECT Dentist__c, Date_and_time_start__c 
            FROM Appointment__c
            WHERE SessionId__c = :sessionId
            AND Status__c = :Constants.APPOINTMENT_STATUS_TEMPORARY];

        delete l;
    }
    
    @RemoteAction
    public static String reserveTimeSlot(String sessionId, ID dentistID, Date appointmentDate, String appointmentTime) {
    	if (sessionId != null && sessionId != 'null') {
    		// delete previous lock
    		List<Appointment__c> toDelete = [SELECT ID FROM Appointment__c WHERE SessionId__c = :sessionId AND Status__c = :Constants.APPOINTMENT_STATUS_TEMPORARY];
    		if (toDelete.size() > 0) {
    			delete toDelete;
    		}
    	} else {
    		sessionId = String.valueOf(Crypto.getRandomLong());
    	}

        if (appointmentTime.length() != 5 || !Pattern.matches('\\d{2}:\\d{2}', appointmentTime)) {
            throw new CustomValidationException('Invalid format for appointmentTime');
        }

        DateTime dateTimeStart = TimeConverter.addTimeToDate(appointmentTime, appointmentDate);
    	
    	Appointment__c appointment = createTemporaryAppointment(dentistID, dateTimeStart, sessionId);
    	
    	insert appointment;    	
    	
    	return sessionId;
    }
    
    @RemoteAction
    public static Appointment__c registerAppointment(
        String sessionId, 
		ID dentistID,
		Date appointmentDate,
        String appointmentTime,
		String description, 
		String appointmentType, 
		String firstName, 
		String lastName,
		String phone,
		String email) {

        if ((email == null || email == '') && (phone == null || phone == '')) {
            throw new CustomValidationException('Email or phone are required');
        }

        if (appointmentTime.length() != 5 || !Pattern.matches('\\d{2}:\\d{2}', appointmentTime)) {
            throw new CustomValidationException('Invalid format for appointmentTime');
        }

        DateTime dateTimeStart = TimeConverter.addTimeToDate(appointmentTime, appointmentDate);
    													
    	Appointment__c appointment;							
    	
        List<Appointment__c> lApp = [SELECT ID, Date_and_time_start__c, Date_and_time_end__c, Dentist__c, Description__c, RecordTypeId, Dentist__r.Name
	    	FROM Appointment__c 
	    	WHERE Status__c = :Constants.APPOINTMENT_STATUS_TEMPORARY AND SessionId__c = :sessionId];
    	if (lApp.size() > 0) {
            appointment = lApp[0];
        } else {
            appointment = createTemporaryAppointment(dentistID, dateTimeStart, sessionId);
            insert appointment;
            appointment = [SELECT ID, Date_and_time_start__c, Date_and_time_end__c, Dentist__c, Description__c, RecordTypeId, Dentist__r.Name
                FROM Appointment__c 
                WHERE ID = :appointment.ID 
                LIMIT 1];
        }

    	appointment.Customer_phone__c = phone;
    	appointment.Description__c = description;
        Schema.RecordTypeInfo rtInfo = Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get(appointmentType);
        if (rtInfo == null) {
            throw new CustomValidationException('Invalid appointment type');
        }
    	appointment.RecordTypeId = rtInfo.getRecordTypeId();
    	appointment.Status__c = Constants.APPOINTMENT_STATUS_AWAITING;
    	
        List<Contact> cList;
        if(email != null && email != '') {
            cList = [SELECT ID, FirstName, LastName FROM Contact WHERE Email = :email];
        } else if (phone != null && phone != '') {
            cList = [SELECT ID, FirstName, LastName FROM Contact WHERE Phone = :phone];
        }

        if (cList.size() > 0) {
            appointment.Contact__c = cList[0].ID;
        } else {
            Contact contact = new Contact();
            contact.FirstName = firstName;
            contact.LastName = lastName;
            contact.Phone = phone;
            contact.Email = email;

            insert contact;
            appointment.Contact__c = contact.Id;
        }   		
    	
    	appointment.OwnerID = [SELECT OwnerID FROM Dentist__c WHERE ID = :appointment.Dentist__c].OwnerID;
    	    	
    	update appointment;
    	
    	submitForApproval(appointment.Id);
    	
    	return appointment;
    }

    public static List<DentistWithHours> getDentistsWithHours(Integer year, Integer month) {
        Date dateFrom = Date.newInstance(year, month, 1);
        Date dateTo = dateFrom.addMonths(1).addDays(-1);

        List<DentistWithHours> result = new List<DentistWithHours>();

        for (Dentist__c dentist : [SELECT ID, Name, Speciality__c FROM Dentist__c]) {
            DentistHelper helper = new DentistHelper(dentist.ID);
            DentistWithHours dwh = helper.getDentistWithHours(dateFrom, dateTo);
            result.add(dwh);
        }

        return result;
    }
    
    private static Appointment__c createTemporaryAppointment(ID dentistId, DateTime dateTimeStart, String sessionId) {
    	Appointment__c appointment = new Appointment__c();
    	appointment.Dentist__c = dentistID;
    	appointment.Date_and_time_start__c = dateTimeStart;
    	appointment.Date_and_time_end__c = dateTimeStart.addMinutes(Constants.APPOINTMENT_TIME_IN_MINUTES);
    	appointment.Status__c = Constants.APPOINTMENT_STATUS_TEMPORARY;
    	appointment.SessionId__c = sessionId;
    	return appointment;
    }
    
    private static void submitForApproval(ID objectId) {
    	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    	req.setObjectId(objectId);
    	Approval.process(req);
    }
}