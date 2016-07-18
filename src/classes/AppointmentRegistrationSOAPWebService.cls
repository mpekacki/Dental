global class AppointmentRegistrationSOAPWebService {
	
    webservice static List<DentistWithHours> getDentistsAndHours(Integer year, Integer month) {
    	List<DentistWithHours> result = AccountRemoter.getDentistsWithHours(year, month);
    	return result;
    }

    webservice static Appointment__c registerAppointment(ID dentistID,
											Date appointmentDate,
											String appointmentTime,
											String description, 
											String appointmentType, 
											String firstName, 
											String lastName,
											String phone,
											String email) {

    	Appointment__c appointment = AccountRemoter.registerAppointment(
											    		null,
											    		dentistID,
											    		appointmentDate,
											    		appointmentTime,
											    		description,
											    		appointmentType,
											    		firstName,
											    		lastName,
											    		phone,
											    		email
											    	);
    	return appointment;
    }
}