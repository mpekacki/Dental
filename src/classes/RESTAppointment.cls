@RestResource(urlMapping='/Appointment')
global with sharing class RESTAppointment {
    
    @HttpPost
    global static Appointment__c registerAppointment(ID dentistID,
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