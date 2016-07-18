global class DayAvailability {
    
    webservice Date day;
    webservice List<HourRange> availableHours = new List<HourRange>();

    global class HourRange {
    	webservice String timeFrom;
    	webservice String timeTo;
    }
}