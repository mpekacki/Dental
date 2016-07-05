public class TimeConverter {
	
	public static final Timezone TZ = Timezone.getTimeZone(Constants.CLINIC_TIMEZONE);

    public static String formatMinutes(Integer minutes) {
        return leftPad(String.valueOf(minutes / 60), 2, '0')  + ':' + leftPad(String.valueOf(Math.mod(minutes, 60)), 2, '0');
    }
    
    public static DateTime extractTimeFrom(AvailableTime__c a) {
    	return addMinutesToDate(Math.round(a.TimeFrom__c), a.Date__c, true);
    }
    
    public static DateTime extractTimeTo(AvailableTime__c a) {
    	return addMinutesToDate(Math.round(a.TimeTo__c), a.Date__c, true);
    }
    
    private static DateTime addMinutesToDate(Integer minutes, Date d, Boolean adjustForTZ) {
    	DateTime dt = ((DateTime)d).addMinutes(minutes);
    	return DateTime.newInstance(dt.getTime() - (adjustForTZ ? TZ.getOffset(dt) : 0));
    }

    private static String leftPad(String str, Integer places, String padString) {
        if (padString.length() != 1) {
            return null;
        }

        Integer l = str.length();
        for (Integer i = 0; i < places - l; i++) {
            str = padString + str;
        }
        return str;
    }
}