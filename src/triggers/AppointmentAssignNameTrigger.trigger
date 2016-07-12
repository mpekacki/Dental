trigger AppointmentAssignNameTrigger on Appointment__c (before update) {
	for (Appointment__c a : Trigger.New) {
		if (a.Status__c == Constants.APPOINTMENT_STATUS_AWAITING && Trigger.oldMap.get(a.Id).Status__c == Constants.APPOINTMENT_STATUS_TEMPORARY){
		    Dentist__c dentist = [SELECT ID, First_Name__c, Last_Name__c FROM Dentist__c WHERE ID = :a.Dentist__c];
			Contact contact = [SELECT ID, FirstName, LastName FROM Contact WHERE ID = :a.Contact__c];
			
			a.Name = 
				dentist.First_Name__c.substring(0,1) 
				+ dentist.Last_Name__c.substring(0,1) 
				+ '_' 
				+ contact.FirstName.substring(0,1) 
				+ contact.LastName.substring(0,1) 
				+ '_' 
				+ a.Date_and_time_start__c.format('yyyyMMdd_HHmm');
				
			a.SessionId__c = null;
		}
	}
}