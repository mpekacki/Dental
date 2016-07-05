@RestResource(urlMapping='/DentistsWithHours/*/*')
global with sharing class RESTDentists {
    
    @HttpGet
    global static List<DentistWithHours> getDentistsAndHours() {
    	RestRequest request = RestContext.request;
    	Integer lastSlashIndex = request.requestURI.lastIndexOf('/');
    	Integer firstSlashIndex = request.requestURI.substring(0, lastSlashIndex).lastIndexOf('/');
    	Integer year = Integer.valueOf(request.requestURI.substring(firstSlashIndex + 1, lastSlashIndex));
    	Integer month = Integer.valueOf(request.requestURI.substring(lastSlashIndex + 1));
    	Date dateFrom = Date.newInstance(year, month, 1);
    	Date dateTo = dateFrom.addMonths(1).addDays(-1);

    	List<DentistWithHours> result = new List<DentistWithHours>();

    	for (Dentist__c dentist : [SELECT ID, Name, Speciality__c FROM Dentist__c]) {
    		DentistWithHours dwh = new DentistWithHours();
    		dwh.dentist = dentist;

    		DentistHelper helper = new DentistHelper(dentist.ID);
    		List<AvailableTime__c> availableHours = helper.getAvailableHours(dateFrom, dateTo);
    		dwh.availableHours = availableHours;

    		result.add(dwh);
    	}

    	return result;
    }
}