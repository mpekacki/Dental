@RestResource(urlMapping='/DentistsWithHours')
global with sharing class RESTDentists {
    
    @HttpGet
    global static List<DentistWithHours> getDentistsAndHours() {
    	RestRequest request = RestContext.request;

    	Integer year;
    	Integer month;
    	if (request.params.size() == 0) {
    		year = Date.today().year();
    		month = Date.today().month();
    	} else {
    		year = Integer.valueOf(request.params.get('year'));
    		month = Integer.valueOf(request.params.get('month'));
    	}	

    	return AccountRemoter.getDentistsWithHours(year, month);
    }
}