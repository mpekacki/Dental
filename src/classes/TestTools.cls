public with sharing class TestTools {

    public static Dentist__c createDentist() {
    	Dentist__c dentist = new Dentist__c(Name='Dr Test', First_Name__c = 'Tester', Last_Name__c = 'Test', OwnerID = UserInfo.getUserId());
    	insert dentist;
    	return dentist;
    }

}