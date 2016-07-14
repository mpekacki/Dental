public with sharing class AppointmentListController {
    
    public List<AppointmentViewRow> appointments {get; private set;}
    private List<AppointmentViewRow> appointmentsUnfiltered;
    
    public ID selectedID {get; set;}
    
    public List<FilterCriterion> filterCriteria {get; private set;}
    
    public String profileName {get; private set;}
    
    public AppointmentListController() {    	
    	this.profileName = [SELECT Name FROM Profile WHERE ID = :UserInfo.getProfileId()].Name;

    	Map<ID,Appointment__c> mApp = new Map<ID,Appointment__c>([SELECT ID, Name, Date_and_time_start__c, Date_and_time_end__c, Contact__c, Status__c, RecordTypeId, Contact__r.Name, RecordType.Name, Dentist__r.Name, Dentist__r.Speciality__c FROM Appointment__c WHERE Status__c != :Constants.APPOINTMENT_STATUS_TEMPORARY]);
    	List<Appointment__c> rawAppointments = mApp.values();
    	
    	this.filterCriteria = new List<FilterCriterion>();
    	
    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'Status__c', 'Status__c', 'Status'));
    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'Contact__c', 'Contact__r.Name', 'Customer'));
    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'RecordTypeId', 'RecordType.Name', 'Type'));
    	
    	if (Constants.PROFILE_NAME_OWNER.equals(profileName)) {
	    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'Dentist__c', 'Dentist__r.Name', 'Dentist'));
	    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'Dentist__r.Speciality__c', 'Dentist__r.Speciality__c', 'Dentist speciality'));
    	}
    	
    	appointmentsUnfiltered = new List<AppointmentViewRow>();

    	List<ProcessInstanceWorkitem> piwis = [SELECT ID, ProcessInstance.TargetObjectID FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectID IN :mApp.keySet() AND ActorId = :UserInfo.getUserId()];
    	
    	for (Appointment__c a : rawAppointments) {

    		appointmentsUnfiltered.add(new AppointmentViewRow(a, getWorkItemId(piwis, a.ID)));
    	}
    	
    	appointments = appointmentsUnfiltered;
    }
	
	public PageReference filter() {
		appointments = appointmentsUnfiltered;
		for (FilterCriterion f : filterCriteria) {
			appointments = filter(f, appointments);
		}
		
		return null;
	}

	private ID getWorkItemId(List<ProcessInstanceWorkitem> piwis, ID appointmentID) {
		for (ProcessInstanceWorkitem piwi : piwis) {
    		if (piwi.ProcessInstance.TargetObjectID == appointmentID) {
    			return piwi.ID;
    		}
    	}
    	return null;
	}
	
	private List<AppointmentViewRow> filter(FilterCriterion f, List<AppointmentViewRow> l) {
		List<AppointmentViewRow> filtered = new List<AppointmentViewRow>();
		
		for (AppointmentViewRow o : l){
			if (f.recordMatches(o.appointment)) {
				filtered.add(o);
			}
		}
		
		return filtered;
	}
	   
	public class AppointmentViewRow {
		public Appointment__c appointment {get; private set;}
		public ID workItemID {get; private set;}
		
		public AppointmentViewRow(Appointment__c appointment, ID workItemID) {
			this.appointment = appointment;
			this.workItemID = workItemID;
		}
	}
}