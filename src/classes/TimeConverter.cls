public class TimeConverter {
	
	public static final Timezone TZ = Timezone.getTimeZone(Constants.CLINIC_TIMEZONE);
	    
    public static Integer t24ToMinutes(Integer t24){
    	return t24 / 100 * 60 + math.mod(t24, 100);
    }
    
    public static Integer t24ToMinutes(Decimal t24) {
    	return t24ToMinutes(math.round(t24));
    }
    
    public static Integer minutesToT24(Integer minutes) {
    	Integer hourPart = minutes / 60;
    	Integer minPart = math.mod(minutes, 60);
    	return hourPart * 100 + minPart;
    }
    
    public static DateTime extractTimeFrom(AvailableTime__c a) {
    	return addT24ToDate(a.TimeFrom__c, a.Date__c, true);
    }
    
    public static DateTime extractTimeTo(AvailableTime__c a) {
    	return addT24ToDate(a.TimeTo__c, a.Date__c, true);
    }
    
    private static DateTime addT24ToDate(Decimal t24, Date d, Boolean adjustForTZ) {
    	Integer minutes = t24ToMinutes(t24);
    	DateTime dt = ((DateTime)d).addMinutes(minutes);
    	return DateTime.newInstance(dt.getTime() - (adjustForTZ ? TZ.getOffset(dt) : 0));
    }
}