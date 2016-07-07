global with sharing class AppointmentRegistrationSOAPWebService {
	
    webservice static List<DentistWithHours> getDentistsAndHours(Integer year, Integer month) {
    	return AccountRemoter.getDentistsWithHours(year, month);
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

    	if (appointmentTime.length() != 5 || !Pattern.matches('\\d{2}:\\d{2}', appointmentTime)) {
    		throw new CustomValidationException('Invalid format for appointmentTime');
    	}

    	DateTime dateTimeStart = TimeConverter.addTimeToDate(appointmentTime, appointmentDate);

    	Appointment__c appointment = AccountRemoter.registerAppointment(
											    		null,
											    		dentistID,
											    		dateTimeStart,
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