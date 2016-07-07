@RestResource(urlMapping='/DentistsWithHours/*/*')
global with sharing class RESTDentists {
    
    @HttpGet
    global static List<DentistWithHours> getDentistsAndHours() {
    	RestRequest request = RestContext.request;
    	Integer lastSlashIndex = request.requestURI.lastIndexOf('/');
    	Integer firstSlashIndex = request.requestURI.substring(0, lastSlashIndex).lastIndexOf('/');
    	Integer year = Integer.valueOf(request.requestURI.substring(firstSlashIndex + 1, lastSlashIndex));
    	Integer month = Integer.valueOf(request.requestURI.substring(lastSlashIndex + 1));

    	return AccountRemoter.getDentistsWithHours(year, month);
    }
}