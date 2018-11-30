public with sharing class REN_MergeOppFieldWrapper implements Comparable {
	public String label{get;set;}
	public String name{get;set;}
	public Boolean nillable{get;set;}
	public String typeVal{get;set;}
	public String relationshipName{get;set;}
	public Boolean IsEqual{get;set;}	
	public String fieldKey{get;set;}
	
	public REN_MergeOppFieldWrapper(String label, String name, String fieldKey){
		this.label = label;
		this.name = name;
		this.fieldKey = fieldKey;
	}
	
	public REN_MergeOppFieldWrapper(String label, String name, Boolean nillableVal, String typeValue, String relName, String fieldKey){
		this.label = label;
		this.name = name;
		this.nillable = nillableVal;
		this.typeVal = typeValue;
		this.relationshipName = relName;
		this.IsEqual = false;
		this.fieldKey = fieldKey;
	}
		
	public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        REN_MergeOppFieldWrapper compareToField = (REN_MergeOppFieldWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        return this.label.compareTo(compareToField.label);      
    }
}