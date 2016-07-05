public with sharing class TestTools {
    public static Dentist__c createDentist(ID userID) {
    	Dentist__c dentist = new Dentist__c(Name='Dr Test', First_Name__c = 'Tester', Last_Name__c = 'Test');
    	insert dentist;
    	dentist.OwnerID = userID;
    	update dentist;
    	return dentist;
    }
}