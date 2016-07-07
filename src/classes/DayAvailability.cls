global with sharing class DayAvailability {
    
    public Date day;
    public List<HourRange> availableHours = new List<HourRange>();

    global class HourRange {
    	public String timeFrom;
    	public String timeTo;
    }
}