public class HoursPreview {

	public String week {get;set;}
	public List<DayPreview> days {get;set;}
	
	private Map<String, DayPreview> namesToDays;
	
	public HoursPreview(Date weekStart) {
		this.days = new List<DayPreview>();
		this.namesToDays = new Map<String, DayPreview>();
		List<Schema.PicklistEntry> daysPicklist = AvailableTime__c.Day_of_week__c.getDescribe().getPicklistValues();
		
		for (Integer i = 0; i < daysPicklist.size(); i++) {
			Schema.PicklistEntry e = daysPicklist[i];
			String dayName = e.getValue();
			DayPreview p = new DayPreview(dayName, weekStart.addDays(i));
			days.add(p);
			namesToDays.put(dayName, p);
		}
	}
		    
    public void writeRanges(String currentDay, Decimal timeFrom, Decimal timeTo, boolean isCustom){
    	RangePreview range = new RangePreview();
    	range.timeFrom = timeFrom;
    	range.timeTo = timeTo;
    	
		this.namesToDays.get(currentDay).ranges.add(range);
		this.namesToDays.get(currentDay).custom = isCustom;
    }
}