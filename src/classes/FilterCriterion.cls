public with sharing class FilterCriterion {
	
    public List<SelectOption> picklistValues {get; set;}
   	public String selectedValue {get; set;}
   	public String filterLabel {get; set;}
   	
   	private String valueField;
   	
   	public FilterCriterion(List<SObject> records, String valueField, String labelField, String filterLabel) {
   		this.filterLabel = filterLabel;
   		this.valueField = valueField;
   		
   		this.selectedValue = '<null>';
   		
   		this.picklistValues = new List<SelectOption>();
   		this.picklistValues.add(new SelectOption('<null>', '<All>'));
   		
   		Set<String> existingValues = new Set<String>();
   		
   		for (SObject o : records) {
   			Object fieldVal;
   			if (valueField.contains('.')) {
   				String[] parts = valueField.split('\\.');
   				fieldVal = o.getSObject(parts[0]).get(parts[1]);
   			} else {
   				fieldVal = o.get(valueField);
   			}
   			
   			String value = String.valueOf(fieldVal);
   			
   			Object labelVal;
   			if (labelField.contains('.')) {
   				String[] parts = labelField.split('\\.');
   				labelVal = o.getSObject(parts[0]).get(parts[1]);
   			} else {
   				labelVal = o.get(labelField);
   			}
   			
   			String label = String.valueOf(labelVal);
   			
   			if (!existingValues.contains(value)) {
   				this.picklistValues.add(new SelectOption(value, label));
   				existingValues.add(value);
   			}
   		}
   	}
   	
   	public List<SObject> filter(List<SObject> listToFilter) {
   		if (selectedValue == '<null>') {
   			return listToFilter;
   		}
   		
   		List<SObject> filtered = new List<SObject>();
   		
   		for (SObject o : listToFilter) {
   			if (recordMatches(o)) {
   				filtered.add(o);
   			}
   		}
   		
   		return filtered;
   	}
   	
   	public Boolean recordMatches(SObject o) {
   		if (selectedValue == '<null>') {
   			return true;
   		}
   		
   		Object fieldVal;
   		if (valueField.contains('.')) {
   			String[] parts = valueField.split('\\.');
   			fieldVal = o.getSObject(parts[0]).get(parts[1]);
   		} else {
   			fieldVal = o.get(valueField);
   		}
   		
   		return fieldVal == selectedValue;
   	}
}