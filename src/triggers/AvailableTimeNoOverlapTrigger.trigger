trigger AvailableTimeNoOverlapTrigger on AvailableTime__c (before insert, before update) {
    
    for (AvailableTime__c a : Trigger.New) {
        
            // check if another record for the same day does not overlap with the new record 
            if ([
                SELECT ID 
                FROM AvailableTime__c 
                WHERE 
                	ID != :a.ID
                	AND
                	Dentist__c = :a.Dentist__c
                	AND
                	((Day_of_week__c != null AND Day_of_week__c = :a.Day_of_week__c) OR (Date__c != null AND Date__c = :a.Date__c))
                	AND
                	(
                        TimeFrom__c <= :a.TimeTo__c AND TimeTo__c >= :a.TimeFrom__c 
                    )
            ].size() > 0) {
                a.addError(Constants.AVAILABLE_TIME_MESSAGE_OVERLAP);
            }
    }
}