trigger AbsenceOnlyTrigger on AvailableTime__c (before insert, before update) {
	
    // verifies that a record defining absence for a given date is the only record for that date
    for (AvailableTime__c a : Trigger.new) {
        if ((a.TimeFrom__c == null && a.TimeTo__c == null && a.Date__c != null && [
        	SELECT ID 
        	FROM AvailableTime__c 
        	WHERE 
        		ID != :a.ID
                AND
                Dentist__c = :a.Dentist__c
                AND
                Date__c = :a.Date__c
        ].size() > 0)
        ||
        (a.Date__c != null && [
        	SELECT ID 
        	FROM AvailableTime__c 
        	WHERE 
        		ID != :a.ID
                AND
                Dentist__c = :a.Dentist__c
                AND
                Date__c = :a.Date__c
                AND
                TimeFrom__c = null
                AND 
                TimeTo__c = null
        ].size() > 0)){
        	a.addError('A record which defines absence must be the only custom record for its day.');        	
        }
    }
}