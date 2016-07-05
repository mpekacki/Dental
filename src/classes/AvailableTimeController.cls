public with sharing class AvailableTimeController {
	
	public String dentistName {get; private set;}
    
    @TestVisible
    private ID userID;
    @TestVisible
    private ID dentistID;
    private DentistHelper helper;
        
    public AvailableTime__c availableTime {get; private set;}
    
    public String selectedType{get;set{
    	selectedType = value;
    	availableTime.Day_of_week__c = null;
    	availableTime.Date__c = null;
    	unavailableForTheDay = false;
    }}
    public ID selectedID {get;set;}
    
    public String previewWeeksForward {get; set;}
    
    public Date monthViewDate {get;set;}
    
    public Boolean unavailableForTheDay {get; set;}
            
    public AvailableTimeController(){
        this.userID = UserInfo.getUserId();        
        Dentist__c dentist = [SELECT ID, Name FROM Dentist__c WHERE OwnerID = :this.userID LIMIT 1];
        this.dentistID = dentist.ID;
        this.dentistName = dentist.Name;
        this.helper = new DentistHelper(dentistID);
        this.previewWeeksForward = '0';
        initNewRecord();
        this.selectedType = 'Day';
        this.monthViewDate = Date.today().toStartOfMonth();
    }
    
    private void initNewRecord(){    
        this.availableTime = new AvailableTime__c(Dentist__c = dentistID, TimeTo__c = Constants.APPOINTMENT_TIME_IN_MINUTES);
    }
    
    public void save() {   	
    	if (unavailableForTheDay && selectedType == 'Date'){
    		availableTime.TimeFrom__c = null;
    		availableTime.TimeTo__c = null;
    	}
     
        try {
            upsert(availableTime);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record created successfully'));
            initNewRecord();
        } catch (System.DmlException e) {
            ApexPages.addMessages(e);
        }  
    }
    
    public PageReference deleteRecord() {
        AvailableTime__c toBeDeleted = [SELECT ID FROM AvailableTime__c WHERE ID = :selectedID];
        delete toBeDeleted;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Record deleted successfully'));
        this.selectedID = null;
        return null;
    }
    
    public void incrementMonthView() {
    	monthViewDate = monthViewDate.addMonths(1);
    }
    
    public void decrementMonthView() {
    	monthViewDate = monthViewDate.addMonths(-1);
    }
    
    public List<SelectOption> getTypes(){
        List<SelectOption> types = new List<SelectOption>();
        types.add(new SelectOption('Day', 'Day'));
        types.add(new SelectOption('Date', 'Date'));
        return types;
    }
    
    public List<SelectOption> getHours(){
        List<SelectOption> hours = new List<SelectOption>();
        
        for (Integer i = 0; i <= 1440; i += Constants.APPOINTMENT_TIME_IN_MINUTES) {
            hours.add(new SelectOption(String.valueOf(i), TimeConverter.formatMinutes(i)));
        }

        return hours;
    }
    
	public List<AvailableTime__c> getDefaultHours(){        
        return helper.getDefaultHours();
    }
    
    public List<AvailableTime__c> getCustomHours(){        
        return helper.getCustomHours();
    }
    
    public List<HoursPreview> getHoursPreview() {
    	return helper.getHoursPreviewByMonthYear(monthViewDate.month(), monthViewDate.year());
    }
    
    
}