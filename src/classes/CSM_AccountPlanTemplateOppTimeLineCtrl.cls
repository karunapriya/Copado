public with sharing class CSM_AccountPlanTemplateOppTimeLineCtrl {
	
   public List<SelectOption> allDateFields{get;set;}
   public List<SelectOption> addedFields{get;set;}
   public String selectedField {get; set;}
   public String deletedField {get; set;}
   public List<SelectOption> existingFields{get;set;}
  
    /**
	* @description constructor 
	*/
	public CSM_AccountPlanTemplateOppTimeLineCtrl() { 
		
	}
	
	private void populateFields(){
		
		this.addedFields = new List<SelectOption>();
   		this.allDateFields = new List<SelectOption>();
   		try
		{
	   		Set<String> existingFieldSet = getExistingValues();
		    List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList('Opportunity');
			for( Schema.SObjectField tmpfield :fieldList) { 
				if (String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_DATE) { 
					if(existingFieldSet != null && existingFieldSet.contains(tmpField.getDescribe().getName())){
						this.addedFields.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
					}else {
					   	this.allDateFields.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
				    }
			   		CSM_Util.sortSelectOptionByLabel(this.allDateFields);
					CSM_Util.sortSelectOptionByLabel(this.addedFields);
				}
			}
		}catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
			
	}
       
    public CSM_Account_Plan_Template__c theAccountPlanTemplate 
	{ 
		get; 
		set {
			if (value != null && this.allDateFields == null)
			{
				theAccountPlanTemplate = value;
				populateFields();
			}
		}
	}
	
   private Set<String> getExistingValues(){
   		Set<String> existingFieldSet;
    	String existingValues = theAccountPlanTemplate.CSM_Opp_Dates_TimeLines__c;
    	if(String.isNotBlank(existingValues)){
	    	List<String> existingFieldList = existingValues.split(';');
	    	if(existingFieldList != null){
		    	existingFieldSet = new Set<String>(existingFieldList);
	    	}
    	}
    	return existingFieldSet;
    } 
       
    public CSM_AccountPlanTemplateController CSM_AccountPlanTemplateController
	{ 
		get; 
    	set 
    	{
			if (value != null) 
			{
				CSM_AccountPlanTemplateController = value;		
				CSM_AccountPlanTemplateController.setaccountPlanTemplateOppTimeLine(this);
			}
		}
	}
           
    
    
     public PageReference addField(){
     	SelectOption foundOption;
       try{
        if (!String.isBlank(selectedField)){
        	for(Integer i=0; i<this.allDateFields.size(); i++){
        		SelectOption selectedOption = allDateFields.get(i);
        		if(this.selectedField.equals(selectedOption.getValue())){
        			foundOption = this.allDateFields.remove(i);
        			break;
        		}
        	}
        	this.addedFields.add(foundOption);
		 	
        }
        }catch (exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
        return null;
    }
     
     public PageReference removeField(){
     	SelectOption foundOption;
       try{
	       if (!String.isBlank(deletedField)){
			 	for(Integer i=0; i<this.addedFields.size(); i++){
	        		SelectOption selectedOption = this.addedFields.get(i);
	        		if(this.deletedField.equals(selectedOption.getValue())){
	        			foundOption = this.addedFields.remove(i);
	        			break;
	        		}
	        	}
	        	this.allDateFields.add(foundOption);
	        	CSM_Util.sortSelectOptionByLabel(this.allDateFields);
	       }
       }catch (exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
       
        return null;
    }
    
    public String getSemiColonSeparatedFields(){
    	String semiColonSeparatedFields = '';
    	try
		{
	    	if(!this.addedFields.isEmpty()){
		    	for(SelectOption option : this.addedFields){
		    		semiColonSeparatedFields = semiColonSeparatedFields + option.getValue() + ';';
		    	}
		    	semiColonSeparatedFields = semiColonSeparatedFields.substring(0, semiColonSeparatedFields.length()-1);
	    	}
	    }catch (exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	    return semiColonSeparatedFields;
    }
     
}