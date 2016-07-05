@isTest
public class TimeConverterTest {

	@isTest
	static void TestExtractTimeFrom() {
		AvailableTime__c a = new AvailableTime__c();
		a.TimeFrom__c = 600;
		a.Date__c = Date.today();
		
		DateTime timeFrom = TimeConverter.extractTimeFrom(a);
		
		System.assertEquals(timeFrom.hour(), 10);
	}
	
	@isTest
	static void TestExtractTimeTo() {
		AvailableTime__c a = new AvailableTime__c();
		a.TimeTo__c = 720;
		a.Date__c = Date.today();
		
		DateTime timeFrom = TimeConverter.extractTimeTo(a);
		
		System.assertEquals(timeFrom.hour(), 12);
	}
}