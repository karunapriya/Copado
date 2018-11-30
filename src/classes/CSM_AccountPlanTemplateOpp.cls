public with sharing class CSM_AccountPlanTemplateOpp{

   public String selectedField {get; set;}
   public List<SelectOption> allDateFieldList{get; set;}
   
    /**
	* @description constructor 
	*/
		public CSM_AccountPlanTemplateOpp() {   
		    allDateFieldList =  new List<SelectOption>();
		    List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList('Opportunity');
				for( Schema.SObjectField tmpfield :fieldList) {         
					if (String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_DATE) {                            
					   	allDateFieldList.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
					 }
				}
   				/*if(selectedfield == null || String.isEmpty(selectedField)){
					selectedField = 'CloseDate';
				}*/
				
		 }
		  
		public CSM_Account_Plan_Template__c theAccountPlanTemplate 
		{ get; 
			set {
					if (value != null)
					{
                       theAccountPlanTemplate = value;
					   if(selectedField == null || String.IsEmpty(selectedField)){
					   		selectedField = theAccountPlanTemplate.CSM_Opp_Date__c;
					   }
					   if(selectedField == null || String.IsEmpty(selectedField)){
					   		selectedField = 'CloseDate';
					   }
					   
					}
				}
		}
	       
	    public CSM_AccountPlanTemplateController CSM_AccountPlanTemplateController
		{ 
			get; 
	    	set {
					if (value != null) 
					{
						CSM_AccountPlanTemplateController = value;		
						CSM_AccountPlanTemplateController.setaccountPlanTemplateOpp(this);
					}
				}
		}
	       
	 
  }