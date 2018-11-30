/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		08.13.2014
 * @description	CSM_AcctPlanTempalteIndicatorDataAccess  class for the Success Plan template indicator data access functionality 
 */

public with sharing class CSM_AcctPlanTemplateIndicatorDataAccess {
	
	/** 
	 * @description gets the indicators based on specified Success Plan template id
	 * @return List<CSM_Account_Plan_Template_Indicator__c>
	 */
	public static List<CSM_Account_Plan_Template_Indicator__c> accountPlanTemplateIndicators(String accountPlanTemplateId)
	{
		List<CSM_Account_Plan_Template_Indicator__c> tmpList = new List<CSM_Account_Plan_Template_Indicator__c>();	
		//validate that the the Success Plan template indicators and indicator objects are readable
		List<String> acctTemplateIndicatorList = new List<String>{CSM_Constants.OBJ_APT_IND_ACCTPLANTEPMPLATE,
			CSM_Constants.OBJ_APT_IND_ID, CSM_Constants.OBJ_APT_IND_NAME,
        	CSM_Constants.OBJ_APT_IND_ISACTIVE,CSM_Constants.OBJ_APT_IND_CRIT_1_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_1_TO, CSM_Constants.OBJ_APT_IND_CRIT_1_TYPE,CSM_Constants.OBJ_APT_IND_CRIT_2_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_2_TO, CSM_Constants.OBJ_APT_IND_CRIT_2_TYPE,CSM_Constants.OBJ_APT_IND_CRIT_3_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_3_TO, CSM_Constants.OBJ_APT_IND_CRIT_3_TYPE, 
        	CSM_Constants.OBJ_APT_IND_CRIT_1_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_1_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_CRIT_2_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_2_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_CRIT_3_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_3_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_INDICATOR, CSM_Constants.OBJ_APT_IND_ORDER};
	    List<String> noAccessList1 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_APT_IND,
    	    CSM_Constants.DML_OPERATION_READ, acctTemplateIndicatorList);
		List<String> indicatorFieldList = new List<String>{CSM_Constants.OBJ_I_DISPLAY_NAME,
        	CSM_Constants.OBJ_I_INDICATOR_GROUP,CSM_Constants.OBJ_I_FIELD_NAME, 
        	CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_I_IS_ACTIVE};
	    List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_I,
    	    CSM_Constants.DML_OPERATION_READ, indicatorFieldList);
		//If readable, query the object
		if(noAccessList1.isEmpty() && noAccessList2.isEmpty())
		{
			tmpList = [select id, 
							  name, 
							  CSM_Account_Plan_Template__c, 
							  CSM_IsACtive__c,  
							  CSM_Criteria_1_From_Value__c,
							  CSM_Criteria_1_To_Value__c,
							  CSM_Criteria_1_Type__c,
							  CSM_Criteria_2_From_Value__c,
							  CSM_Criteria_2_To_Value__c,
							  CSM_Criteria_2_Type__c,
							  CSM_Criteria_3_From_Value__c,
							  CSM_Criteria_3_To_Value__c,
							  CSM_Criteria_3_Type__c,
							  CSM_Indicator__c,
							  CSM_Indicator__r.CSM_Indicator_Display_Name__c,
							  CSM_Indicator__r.CSM_Object_Field_Name__c,
							  CSM_Indicator__r.CSM_Object_Name__c, 
							  CSM_Indicator__r.CSM_Object_Field_Type__c, 
							  CSM_Criteria_1_From_Date__c,
							  CSM_Criteria_1_To_Date__c,
							  CSM_Criteria_2_From_Date__c,
							  CSM_Criteria_2_To_Date__c,
							  CSM_Criteria_3_From_Date__c,
							  CSM_Criteria_3_To_Date__c, 
							  CSM_Order__c
						 from CSM_Account_Plan_Template_Indicator__c
						where CSM_Account_Plan_Template__c = :accountPlanTemplateId 
					 order by CSM_Order__c limit 100];
				  
		}
		//If not readable, display error message
		else
		{
			String[] arguments1 = new String[] {CSM_CONSTANTS.OBJ_APT_IND + ':'+String.valueOf(noAccessList1)};
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
	    	    System.Label.CSM_MSG_OBJECT_NOT_READABLE + ' ' + arguments1));
	    	String[] arguments2 = new String[] {CSM_CONSTANTS.OBJ_I + ':'+String.valueOf(noAccessList2)};
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
	    	    System.Label.CSM_MSG_OBJECT_NOT_READABLE + ' ' + arguments2));
		}
		
		return tmpList;
		
	}
	/** 
	 * @description update the Success Plan template indicators
	 * @return boolean
	 */
	public static boolean updateAccountPlanTemplateIndicators(List<CSM_Account_Plan_Template_Indicator__c> templateIndicatorList){
		boolean isSuccess = false;	
		List<String> acctTemplateIndicatorList = new List<String>{
        	CSM_Constants.OBJ_APT_IND_ISACTIVE,CSM_Constants.OBJ_APT_IND_CRIT_1_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_1_TO, CSM_Constants.OBJ_APT_IND_CRIT_1_TYPE,CSM_Constants.OBJ_APT_IND_CRIT_2_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_2_TO, CSM_Constants.OBJ_APT_IND_CRIT_2_TYPE,CSM_Constants.OBJ_APT_IND_CRIT_3_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_3_TO, CSM_Constants.OBJ_APT_IND_CRIT_3_TYPE,
        	CSM_Constants.OBJ_APT_IND_CRIT_1_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_1_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_CRIT_2_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_2_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_CRIT_3_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_3_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_INDICATOR, CSM_Constants.OBJ_APT_IND_ORDER};
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APT_IND, acctTemplateIndicatorList, CSM_Constants.DML_OPERATION_UPSERT); 
		upsert templateIndicatorList;
	    isSuccess = true;
    	return isSuccess;
	}
	
	public static void cloneAccountPlanTemplateIndicator(Map<Id, Id> currentToCloneTemplateIdMap){
		List<String> acctTemplateIndicatorList = new List<String>{CSM_Constants.OBJ_APT_IND_ISACTIVE, CSM_Constants.OBJ_APT_IND_CRIT_1_FROM_DATE,
			CSM_Constants.OBJ_APT_IND_CRIT_1_FROM, CSM_Constants.OBJ_APT_IND_CRIT_1_TO_DATE, CSM_Constants.OBJ_APT_IND_CRIT_1_TO, 
			CSM_Constants.OBJ_APT_IND_CRIT_1_TYPE, CSM_Constants.OBJ_APT_IND_CRIT_2_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_2_TO, CSM_Constants.OBJ_APT_IND_CRIT_2_TYPE,
			CSM_Constants.OBJ_APT_IND_CRIT_2_FROM_DATE, CSM_Constants.OBJ_APT_IND_CRIT_2_TO_DATE,
			CSM_Constants.OBJ_APT_IND_CRIT_3_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_3_TO, CSM_Constants.OBJ_APT_IND_CRIT_3_TYPE,
         	CSM_Constants.OBJ_APT_IND_CRIT_3_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_3_TO_DATE,
            CSM_Constants.OBJ_APT_IND_INDICATOR, CSM_Constants.OBJ_APT_IND_ORDER, CSM_Constants.OBJ_APT_IND_ACCTPLANTEPMPLATE};
            
    	List<String> noAccessList1 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_APT_IND,
    	    CSM_Constants.DML_OPERATION_READ, acctTemplateIndicatorList);
    	    
    	if (noAccessList1.isEmpty())
    	{
			List<CSM_Account_Plan_Template_Indicator__c> cloneIndicatorList = new List<CSM_Account_Plan_Template_Indicator__c>();
			List<CSM_Account_Plan_Template_Indicator__c> apTempIndicatorList = [Select CSM_IsActive__c, CSM_Criteria_1_From_Date__c, CSM_Criteria_1_From_Value__c, 
																CSM_Criteria_1_To_Date__c, CSM_Criteria_1_To_Value__c, CSM_Criteria_1_Type__c,
																CSM_Criteria_2_From_Date__c, CSM_Criteria_2_From_Value__c, CSM_Criteria_2_To_Date__c,
																CSM_Criteria_2_To_Value__c, CSM_Criteria_2_Type__c, CSM_Criteria_3_From_Date__c,
																CSM_Criteria_3_From_Value__c, CSM_Criteria_3_To_Date__c, CSM_Criteria_3_To_Value__c,
																CSM_Criteria_3_Type__c, CSM_Indicator__c, CSM_Order__c, CSM_Account_Plan_Template__c 
																From CSM_Account_Plan_Template_Indicator__c 
																Where CSM_Account_Plan_Template__c IN:currentToCloneTemplateIdMap.keySet() LIMIT 1000];
			if(!apTempIndicatorList.isEmpty()){
				for(CSM_Account_Plan_Template_Indicator__c apTempIndicator : apTempIndicatorList){
					CSM_Account_Plan_Template_Indicator__c cloneIndicator = apTempIndicator.clone(false, true);
					cloneIndicator.CSM_Account_Plan_Template__c = currentToCloneTemplateIdMap.get(apTempIndicator.CSM_Account_Plan_Template__c);
					cloneIndicatorList.add(cloneIndicator);
				}
				updateAccountPlanTemplateIndicators(cloneIndicatorList);
			}
    	}
    	else
    	{
    		String[] arguments1 = new String[] {CSM_CONSTANTS.OBJ_APT_IND + ':'+String.valueOf(noAccessList1)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
		        System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments1)); 
    	}
	}
	
	/*Get Association of all Indicators with Success Plan Template*/
	public static List<CSM_Account_Plan_Template_Indicator__c> getSuccessPlanTempIndicatorAll(String indicatorId)
	{	
		List<CSM_Account_Plan_Template_Indicator__c> tmpList = new List<CSM_Account_Plan_Template_Indicator__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_IND_ID, CSM_Constants.OBJ_APT_IND_ISACTIVE, CSM_Constants.OBJ_APT_IND_NAME,CSM_Constants.OBJ_APT_IND_ORDER,CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE, CSM_Constants.OBJ_APT_IND_INDICATOR};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APT_IND,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		if(noAccessList.isEmpty()){
			tmpList = [SELECT Id, 
							  CSM_IsACtive__c, 
							  Name,
							  CSM_Order__c,
							  CSM_Indicator__c,
							  CSM_Account_Plan_Template__c,
							  CSM_Account_Plan_Template__r.CSM_Template_Name__c,
							  CSM_Account_Plan_Template__r.CSM_IsActive__c
						FROM 
						 	CSM_Account_Plan_Template_Indicator__c
						WHERE 
							CSM_Indicator__c = :indicatorId 
						LIMIT 10000];
		}
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APP + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
    	    return tmpList;
    	}
		return tmpList;
	}
	/** 
	 * @description delete the indicators based on specified Success Plan template id
	 * @return boolean SUCCESS or FAIL
	 */
	public static boolean removeAcctPlanTmplIndicatorById(String indicatorId)
	{
		List<CSM_Account_Plan_Template_Indicator__c> tmpList = new List<CSM_Account_Plan_Template_Indicator__c>();	
		//validate that the the Success Plan template indicators and indicator objects are readable
		List<String> acctTemplateIndicatorList = new List<String>{CSM_Constants.OBJ_APT_IND_ACCTPLANTEPMPLATE,
			CSM_Constants.OBJ_APT_IND_ID, CSM_Constants.OBJ_APT_IND_NAME,
        	CSM_Constants.OBJ_APT_IND_ISACTIVE,CSM_Constants.OBJ_APT_IND_CRIT_1_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_1_TO, CSM_Constants.OBJ_APT_IND_CRIT_1_TYPE,CSM_Constants.OBJ_APT_IND_CRIT_2_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_2_TO, CSM_Constants.OBJ_APT_IND_CRIT_2_TYPE,CSM_Constants.OBJ_APT_IND_CRIT_3_FROM, 
        	CSM_Constants.OBJ_APT_IND_CRIT_3_TO, CSM_Constants.OBJ_APT_IND_CRIT_3_TYPE, 
        	CSM_Constants.OBJ_APT_IND_CRIT_1_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_1_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_CRIT_2_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_2_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_CRIT_3_FROM_DATE,CSM_Constants.OBJ_APT_IND_CRIT_3_TO_DATE,
        	CSM_Constants.OBJ_APT_IND_INDICATOR, CSM_Constants.OBJ_APT_IND_ORDER};
	    List<String> noAccessList1 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_APT_IND,
    	    CSM_Constants.DML_OPERATION_READ, acctTemplateIndicatorList);
		List<String> indicatorFieldList = new List<String>{CSM_Constants.OBJ_I_DISPLAY_NAME,
        	CSM_Constants.OBJ_I_INDICATOR_GROUP,CSM_Constants.OBJ_I_FIELD_NAME, 
        	CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_I_IS_ACTIVE};
	    List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_I,
    	    CSM_Constants.DML_OPERATION_READ, indicatorFieldList);
		//If readable, query the object
		if(Schema.sObjectType.CSM_Account_Plan_Template_Indicator__c.isDeletable()){
			if(noAccessList1.isEmpty() && noAccessList2.isEmpty())
			{
				tmpList = [select id, 
								  name, 
								  CSM_Account_Plan_Template__c, 
								  CSM_Indicator__c
						 	from CSM_Account_Plan_Template_Indicator__c
							where Id = :indicatorId 
					 		limit 1];
					 	
				if (tmpList != null && tmpList.size() > 0) {
					//delete the TemplateIndicatorList
					List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_APT_IND, CSM_Constants.DML_OPERATION_DELETE, null);
					delete tmpList;
					return true;
				}
			}  
		
			//If not readable, display error message
			else
			{
				String[] arguments1 = new String[] {CSM_CONSTANTS.OBJ_APT_IND + ':'+String.valueOf(noAccessList1)};
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
	    	    System.Label.CSM_MSG_OBJECT_NOT_READABLE + ' ' + arguments1));
	    		String[] arguments2 = new String[] {CSM_CONSTANTS.OBJ_I + ':'+String.valueOf(noAccessList2)};
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
	    	    System.Label.CSM_MSG_OBJECT_NOT_READABLE + ' ' + arguments2));
	    	    
	    		return false;
			}
		}
		return false;
	}
	public static boolean deleteAcctPlanTmplIndicatorList(List<CSM_Account_Plan_Template_Indicator__c> successplantempindicatorList)
	{	
	    	List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_APT_IND, CSM_Constants.DML_OPERATION_DELETE, null);
			if(noAccessList.isEmpty())
			{
				delete successplantempindicatorList;
				return true;
			}
			else
			{
				String[] arguments1 = new String[] {CSM_CONSTANTS.OBJ_APT_IND + ':'+String.valueOf(noAccessList)};
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, System.Label.CSM_MSG_OBJECT_NOT_READABLE + ' ' + arguments1)); 
		    	return false;
			}
		
		return false;
	}	
}