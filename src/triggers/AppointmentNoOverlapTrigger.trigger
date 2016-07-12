trigger AppointmentNoOverlapTrigger on Appointment__c (before insert, before update) {
    for (Appointment__c a : Trigger.New) {      	  	    	
  	  	a.Hour_start_TZ_adjusted__c = DateTime.newInstance(a.Date_and_time_start__c.getTime() + TimeConverter.TZ.getOffset(a.Date_and_time_start__c)).hour() * 100;
  	  	a.DOW_TZ_adjusted__c = a.Date_and_time_start__c.format('EEEE');
  	  	
    	if([
	    	SELECT ID 
	    	FROM Appointment__c 
	    	WHERE 
	    		ID <> :a.ID
	    		AND
	    		Dentist__c = :a.Dentist__c
	    		AND
	    		Date_and_time_start__c < :a.Date_and_time_end__c AND Date_and_time_end__c > :a.Date_and_time_start__c
	    		AND 
	    		Status__c IN (:Constants.APPOINTMENT_STATUS_CONFIRMED, :Constants.APPOINTMENT_STATUS_AWAITING, :Constants.APPOINTMENT_STATUS_TEMPORARY)
    	].size() > 0) {
    		a.addError('There is another appointment that overlaps with this one.');
    	}
    	
    	Decimal timeFrom = a.Date_and_time_start__c.hour() * 60 + a.Date_and_time_start__c.minute();
    	Decimal timeTo = a.Date_and_time_end__c.hour() * 60 + a.Date_and_time_end__c.minute();
    	String dayOfWeek = a.Date_and_time_start__c.format('EEEE');
    	
    	if([
	    	SELECT ID 
	    	FROM AvailableTime__c 
	    	WHERE 
	    		Dentist__c = :a.Dentist__c
	    		AND
	    		TimeFrom__c <= :timeFrom AND TimeTo__c >= :timeTo
	    		AND
	    		(Date__c = :a.Date_and_time_start__c.date() OR Day_of_week__c = :dayOfWeek)
    	].size() == 0) {
    		a.addError('Appointment time is outside dentist\'s availability hours.');
    	}
    }
    
    
}