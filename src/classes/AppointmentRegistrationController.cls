public with sharing class AppointmentRegistrationController {
    
    public Appointment__c appointment {get; set;}
    public Contact contact {get; set;}
    public Date selectedDate {get;set;}
    
    public List<Dentist__c> dentists {get; private set;}
    private Map<ID, List<DateTime>> dentistAvailableTimes;
    
    public String sessionId {get; private set;}
    
    public AppointmentRegistrationController (){
    	
    	Cookie sessionCookie;
    	try {
    		sessionCookie = ApexPages.currentPage().getCookies().get('session_id');
    		sessionId = sessionCookie.getValue();
    	} catch (Exception e) {
    		sessionId = String.valueOf(Crypto.getRandomLong());
			setSessionCookie();
    	}
    	
    	try {
	    	appointment = [SELECT ID, Date_and_time_start__c, Date_and_time_end__c, Dentist__c, Description__c, RecordTypeId 
	    	FROM Appointment__c 
	    	WHERE Status__c = :Constants.APPOINTMENT_STATUS_TEMPORARY AND SessionId__c = :sessionId LIMIT 1];
    	} catch (QueryException e) {
	    	appointment = new Appointment__c();
    	}
    	
		contact = new Contact();
    	refreshTimes();
    }
    
    private void setSessionCookie() {
    	Cookie sessionCookie = new Cookie('session_id', sessionId, null, 300, false);
    	if (ApexPages.currentPage() != null) {
    		ApexPages.currentPage().setCookies(new Cookie[] {sessionCookie});
    	}
    }
    
    private void refreshTimes() {
    	dentists = [SELECT ID, Name, Speciality__c FROM Dentist__c];
    	dentistAvailableTimes = new Map<ID, List<DateTime>>();
    	
    	for (Dentist__c d : dentists) {
    		DentistHelper helper = new DentistHelper(d.ID);
    		List<DateTime> possibleTimes = helper.getPossibleAppointmentStartTimes();
    		dentistAvailableTimes.put(d.ID, possibleTimes);
    	}
    }
    
    public List<DateTime> getTimes() {
    	if (appointment.Dentist__c == null) {
    		return new List<DateTime>();
    	}
    	return dentistAvailableTimes.get(appointment.Dentist__c);
    }
    
    public List<Date> getAvailableDatesForDentist(ID dentistID) {
    	List<Date> result = new List<Date>();
    	
    	Set<Date> uniqueDates = new Set<Date>();
    	for (DateTime dt : dentistAvailableTimes.get(dentistID)) {
    		uniqueDates.add(dt.date());
    	}
    	
    	result.addAll(uniqueDates);
    	result.sort();
    	
    	return result;
    }
    
    public List<DateTime> getAvailableTimesForDentistAndDate(ID dentistID, Date d) {
    	List<DateTime> result = new List<DateTime>();
    	
    	for (DateTime dt : dentistAvailableTimes.get(dentistID)) {
    		if (dt.date() == d) {
    			result.add(dt);
    		}
    	}
    	
    	return result;
    }
    
    public List<SelectOption> getDentistsSO() {
    	List<SelectOption> result = new List<SelectOption>();
    	
    	for (Dentist__c d : dentists) {
    		result.add(new SelectOption(d.ID, d.Name + ', ' + d.Speciality__c));
    	}
    	
    	return result;
    }
    
    public List<SelectOption> getDatesSO() {
    	List<SelectOption> result = new List<SelectOption>();
    	
    	if (appointment.Dentist__c == null) {
    		return result;
    	}
    	
    	List<Date> dates = getAvailableDatesForDentist(appointment.Dentist__c);
    	for (Date d : dates) {
    		result.add(new SelectOption(d.format(), ((DateTime)d).format('yyyy-MM-dd EEEE')));
    	}
    	    	
    	return result;    	
    }
    
    public List<SelectOption> getTimesSO() {
    	List<SelectOption> result = new List<SelectOption>();
    	
    	if (appointment.Dentist__c == null) {
    		return result;
    	}
    	
    	List<DateTime> times = getAvailableTimesForDentistAndDate(appointment.Dentist__c, selectedDate);
    	for (DateTime d : times) {
    		result.add(new SelectOption(d.format(), d.format('HH:mm')));
    	}
    	    	
    	return result;
    }
    
    public List<SelectOption> getAppointmentTypes() {
    	List<SelectOption> result = new List<SelectOption>();
    	
    	Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Appointment__c.getRecordTypeInfosByName();
    	for (String typeName : rtMapByName.keySet()) {
    		if (typeName != 'Master'){
    			result.add(new SelectOption(rtMapByName.get(typeName).getRecordTypeId(), typeName));
    		}
    	}
    	
    	return result;
    }
    
    public PageReference saveTemporary() {
    	if (appointment.Dentist__c == null || appointment.Date_and_time_start__c == null) {
    		return null;
    	}
    	
    	appointment.SessionId__c = sessionId;
    	appointment.Date_and_time_end__c = appointment.Date_and_time_start__c.addMinutes(Constants.APPOINTMENT_TIME_IN_MINUTES);
    	appointment.Status__c = Constants.APPOINTMENT_STATUS_TEMPORARY;
    	
    	if (appointment.Id != null && !appointment.IsDeleted) {
    		delete appointment;
    		appointment.Id = null;
    	}
    	
    	insert appointment;
    	setSessionCookie();
    	
    	return null;
    }
    
    public PageReference savePermanent() {
    	appointment.Customer_phone__c = contact.Phone;
    	appointment.Status__c = Constants.APPOINTMENT_STATUS_AWAITING;
    	
    	try {
    		appointment.Contact__c = [SELECT ID, FirstName, LastName FROM Contact WHERE Email = :contact.Email LIMIT 1].Id;   		
    	} catch (Exception e) {
    		insert contact;
    		appointment.Contact__c = contact.Id;
    	}
    	    	    	
    	appointment.OwnerID = [SELECT OwnerID FROM Dentist__c WHERE ID = :appointment.Dentist__c].OwnerID;
    	    	
    	update appointment;
    	
    	submitForApproval();
    	
    	PageReference redirect = new PageReference('/apex/RegistrationSuccess');
    	redirect.setRedirect(true);
    	
    	return redirect;
    }
    
    private void submitForApproval() {
    	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    	req.setObjectId(appointment.Id);
    	Approval.process(req);
    }
}