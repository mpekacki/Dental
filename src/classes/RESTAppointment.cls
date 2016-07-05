@RestResource(urlMapping='/Appointment')
global with sharing class RESTAppointment {
    
    @HttpPost
    global static Appointment__c registerAppointment(ID dentistID,
											DateTime dateTimeStart,
											String description, 
											String appointmentType, 
											String firstName, 
											String lastName,
											String phone,
											String email) {

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
    	//return 'Appointment successfully booked';
    	return appointment;
    }
}