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
    public static List<DateTime> getAvailableTimesForDentistAndDate(ID dentistID, Date d) {
    	List<DateTime> result = new List<DateTime>();
    	
    	for (DateTime dt : new DentistHelper(dentistID).getPossibleAppointmentStartTimes()) {
    		if (dt.date() == d) {
    			result.add(dt);
    		}
    	}
    	
    	return result;
    }

    @RemoteAction
    public static Appointment__c getReservedSlot(String sessionId) {
        if (sessionId == null || sessionId == '') {
            return null;
        }

        List<Appointment__c> l = 
            [SELECT Dentist__c, Date_and_time_start__c 
            FROM Appointment__c
            WHERE SessionId__c = :sessionId];

        if (l.size() > 0) {
            return l[0];
        } else {
            return null;
        }
    }
    
    @RemoteAction
    public static String reserveTimeSlot(String sessionId, ID dentistID, DateTime dateTimeStart) {
    	if (sessionId != null) {
    		// delete previous lock
    		List<Appointment__c> toDelete = [SELECT ID FROM Appointment__c WHERE SessionId__c = :sessionId AND Status__c = 'Temporary'];
    		if (toDelete.size() > 0) {
    			delete toDelete;
    		}
    	} else {
    		sessionId = String.valueOf(Crypto.getRandomLong());
    	}
    	
    	Appointment__c appointment = createTemporaryAppointment(dentistID, dateTimeStart, sessionId);
    	
    	insert appointment;    	
    	
    	return sessionId;
    }
    
    @RemoteAction
    public static Appointment__c registerAppointment(String sessionId, 
    												ID dentistID,
    												DateTime dateTimeStart,
    												String description, 
    												String appointmentType, 
    												String firstName, 
    												String lastName,
    												String phone,
    												String email) {

        if ((email == null || email == '') && (phone == null || phone == '')) {
            throw new CustomValidationException('Email or phone are required');
        }
    													
    	Appointment__c appointment;							
    	
        List<Appointment__c> lApp = [SELECT ID, Date_and_time_start__c, Date_and_time_end__c, Dentist__c, Description__c, RecordTypeId 
	    	FROM Appointment__c 
	    	WHERE Status__c = 'Temporary' AND SessionId__c = :sessionId];
    	if (lApp.size() > 0) {
            appointment = lApp[0];
        } else {
            appointment = createTemporaryAppointment(dentistID, dateTimeStart, sessionId);
            insert appointment;
        }

    	appointment.Customer_phone__c = phone;
    	appointment.Description__c = description;
    	appointment.RecordTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get(appointmentType).getRecordTypeId();
    	appointment.Status__c = 'Awaiting confirmation';
    	
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
    
    private static Appointment__c createTemporaryAppointment(ID dentistId, DateTime dateTimeStart, String sessionId) {
    	Appointment__c appointment = new Appointment__c();
    	appointment.Dentist__c = dentistID;
    	appointment.Date_and_time_start__c = dateTimeStart;
    	appointment.Date_and_time_end__c = dateTimeStart.addMinutes(Constants.APPOINTMENT_TIME_IN_MINUTES);
    	appointment.Status__c = 'Temporary';
    	appointment.SessionId__c = sessionId;
    	return appointment;
    }
    
    private static void submitForApproval(ID objectId) {
    	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    	req.setObjectId(objectId);
    	Approval.process(req);
    }
}