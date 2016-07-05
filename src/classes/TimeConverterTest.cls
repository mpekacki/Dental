@isTest
public class TimeConverterTest {
	@isTest
	static void TestT24ToMinutes() {
		Integer T24 = 1337;
		
		Integer minutes = TimeConverter.t24ToMinutes(T24);
		
		System.assert(minutes == 817);
	}
	
	@isTest
	static void TestMinutesTo24() {
		Integer minutes = 817;
		
		Integer t24 = TimeConverter.minutesToT24(minutes);
		
		System.assert(t24 == 1337);
	}
	
	@isTest
	static void TestT24ToMinutesDecimal() {
		Decimal t24 = 2137.0;
		
		Integer minutes = TimeConverter.t24toMinutes(t24);
		
		System.assertEquals(minutes, 1297);
	}
	
	@isTest
	static void TestExtractTimeFrom() {
		AvailableTime__c a = new AvailableTime__c();
		a.TimeFrom__c = 1000;
		a.Date__c = Date.today();
		
		DateTime timeFrom = TimeConverter.extractTimeFrom(a);
		
		System.assertEquals(timeFrom.hour(), 10);
	}
	
	@isTest
	static void TestExtractTimeTo() {
		AvailableTime__c a = new AvailableTime__c();
		a.TimeTo__c = 1200;
		a.Date__c = Date.today();
		
		DateTime timeFrom = TimeConverter.extractTimeTo(a);
		
		System.assertEquals(timeFrom.hour(), 12);
	}
}