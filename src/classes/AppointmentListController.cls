public with sharing class AppointmentListController {
    
    public List<AppointmentViewRow> appointments {get; private set;}
    private List<AppointmentViewRow> appointmentsUnfiltered;
    
    public ID selectedID {get; set;}
    
    public List<FilterCriterion> filterCriteria {get; private set;}
    
    public String profileName {get; private set;}
    
    public AppointmentListController() {    	
    	this.profileName = [SELECT Name FROM Profile WHERE ID = :UserInfo.getProfileId()].Name;

    	List<Appointment__c> rawAppointments = [SELECT ID, Name, Date_and_time_start__c, Date_and_time_end__c, Contact__c, Status__c, RecordTypeId, Contact__r.Name, RecordType.Name, Dentist__r.Name, Dentist__r.Speciality__c FROM Appointment__c WHERE Status__c != 'Temporary'];
    	
    	this.filterCriteria = new List<FilterCriterion>();
    	
    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'Status__c', 'Status__c', 'Status'));
    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'Contact__c', 'Contact__r.Name', 'Customer'));
    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'RecordTypeId', 'RecordType.Name', 'Type'));
    	
    	if (profileName == 'Clinic owner') {
	    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'Dentist__c', 'Dentist__r.Name', 'Dentist'));
	    	this.filterCriteria.add(new FilterCriterion(rawAppointments, 'Dentist__r.Speciality__c', 'Dentist__r.Speciality__c', 'Dentist speciality'));
    	}
    	
    	appointmentsUnfiltered = new List<AppointmentViewRow>();
    	
    	for (Appointment__c a : rawAppointments) {
    		appointmentsUnfiltered.add(new AppointmentViewRow(a));
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
		
		public AppointmentViewRow(Appointment__c appointment) {
			this.appointment = appointment;
			this.workItemID = getWorkItemID(appointment.ID);
		}
		
		private ID getWorkItemID(ID objectID){
			try {
	    		ID processInstanceId = [SELECT ID FROM ProcessInstance WHERE TargetObjectID = :objectID].ID;
				ID workItemID = [SELECT ID FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :processInstanceId AND ActorId = :UserInfo.getUserId()].ID;
				return workItemID;
	    	} catch (Exception e) {
	    		return null;
	    	}
	    }
	}
}