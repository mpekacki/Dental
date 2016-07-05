public class DayPreview {
	public List<RangePreview> ranges {get;set;}
	public Date d {get;set;}
	public boolean custom {get;set;}
	public String dayName {get;set;}
	
	public DayPreview (String dayName, Date d) {
		this.ranges = new List<RangePreview>();
		this.d = d;
		this.dayName = dayName;
	}
}