public with sharing class CSM_AcctPlanTemplateIndicatorWrapper {
	public CSM_Account_Plan_Template_Indicator__c indicator {get; set;}
	public String indicatorDisplay {get; set;}
	public String indicatorType {get; set;}
	public boolean isDateIndicator {get; set;}
	
	/** 
 	 * @description Wrapper class constructor
 	 * @return PageReference
 	 */
	public CSM_AcctPlanTemplateIndicatorWrapper(CSM_Account_Plan_Template_Indicator__c theIndicator)
	{
		this.indicator = theIndicator;
		indicatorDisplay = indicator.CSM_Indicator__r.CSM_Object_Name__c + ' ' + indicator.CSM_Indicator__r.CSM_Object_Field_Name__c;
		indicatorType = indicator.CSM_Indicator__r.CSM_Object_Field_Type__c;
		if(this.indicator.CSM_Indicator__r.CSM_Object_Field_Type__c == CSM_Constants.TYPE_DATE)
		{
			isDateIndicator = true;
			
		}
		else
		{
			isDateIndicator = false;
		}
	}
	
}