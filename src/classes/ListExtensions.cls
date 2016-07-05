public with sharing class ListExtensions {

    public static List<AvailableTime__c> findByDate(List<AvailableTime__c> l, Date d){
    	List<AvailableTime__c> result = new List<AvailableTime__c>();
    	for (AvailableTime__c rec : l) {
    		if (rec.Date__c == d) {
    			result.add(rec);
    		}
    	}
    	return result;
    }
    
    public static List<AvailableTime__c> findByDayOfWeek(List<AvailableTime__c> l, String dayName){
    	List<AvailableTime__c> result = new List<AvailableTime__c>();
    	for (AvailableTime__c rec : l) {
    		if (rec.Day_of_week__c == dayName) {
    			result.add(rec);
    		}
    	}
    	return result;
    }
    
    public static List<Appointment__c> findByTimeFromAndTo(List<Appointment__c> l, DateTime timeFrom, DateTime timeTo) {
    	List<Appointment__c> result = new List<Appointment__c>();
    	for (Appointment__c a : l) {
    		if (a.Date_and_time_start__c < timeTo && timeFrom < a.Date_and_time_end__c) {
    			result.add(a);
    		}
    	}
    	return result;
    }
}