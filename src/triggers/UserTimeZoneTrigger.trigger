trigger UserTimeZoneTrigger on User (before insert, before update) {
    for (User u : Trigger.New){
    	if (u.TimeZoneSidKey != Constants.CLINIC_TIMEZONE) {
    		u.addError('User time zone must be identical to the organization time zone.');
    	}
    }
}