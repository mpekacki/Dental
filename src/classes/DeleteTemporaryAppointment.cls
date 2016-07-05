global class DeleteTemporaryAppointment {

	@InvocableMethod(label='Delete temporary appointment')
	public static void deleteTemporaryAppointment(List<ID> ids) {
		for (Appointment__c a : [SELECT ID, Status__c FROM Appointment__c WHERE ID IN :ids]) {
			if (a.Status__c == 'Temporary'){
				delete a;
			}
		}
	}
}