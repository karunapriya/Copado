public with sharing class CSM_IndicatorDataAccess
{
	/** 
	 * @description finds a list of indicators by the given group id
	 * @param indicator group id
	 * @return list of Indicator objects
	 */
	public static List<CSM_Indicator__c> findIndicatorsByGroup (Id indicatorGroupId) {
		List<CSM_Indicator__c> listOfIndicators = new List<CSM_Indicator__c>();

		List<String> indicatorFieldList = new List<String>{CSM_Constants.OBJ_I_DISPLAY_NAME,
        	CSM_Constants.OBJ_I_INDICATOR_GROUP,CSM_Constants.OBJ_I_FIELD_NAME, 
        	CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_I_IS_ACTIVE, CSM_Constants.OBJ_I_FIELD_LABEL};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_I,
            CSM_Constants.DML_OPERATION_READ, indicatorFieldList);   
        
        if (noAccessList.isEmpty())
        {
        
            listOfIndicators = [SELECT Id,
                                      CSM_Indicator_Display_Name__c,
           	                          CSM_Indicator_Group__c,
   	                                  CSM_Object_Field_Name__c,
   	                                  CSM_Object_Name__c,
   	                                  CSM_isActive__c,
   	                                  CSM_Object_Field_Type__c,
   	                                  CSM_Object_Field_Label__c
   	                             FROM CSM_Indicator__c
   	                            WHERE CSM_Indicator_Group__c = :indicatorGroupId LIMIT 500];
		    return listOfIndicators;
        }
        else
        {	
        	 String[] arguments = new String[] {CSM_Constants.OBJ_I + ':'+String.valueOf(noAccessList)};
        	 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));       	 
        }

        return listOfIndicators;
	}
	
	/** 
	 * @description upserts a list of indicators
	 * @param list of indicator objects
	 * @return void
	 */
	public static void upsertListIndicator(List<CSM_Indicator__c> listIndicator)
	{

	    List<String> indicatorFieldList = new List<String>{CSM_Constants.OBJ_I_DISPLAY_NAME,
        	CSM_Constants.OBJ_I_INDICATOR_GROUP,CSM_Constants.OBJ_I_FIELD_NAME, 
        	CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_I_IS_ACTIVE,
        	CSM_Constants.OBJ_I_FIELD_TYPE, CSM_Constants.OBJ_I_NAME,
        	CSM_Constants.OBJ_I_FIELD_LABEL};
	        
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_I, indicatorFieldList, CSM_Constants.DML_OPERATION_UPSERT);
    	
			if (!listIndicator.isEmpty())
			{
			    upsert listIndicator;
			}
	}
	
	/** 
	 * @description retrieves indicators for the given indicator id
	 * @param indicator id
	 * @return list of indicator objects
	 */
	public static List<CSM_Indicator__c> getIndicatorById(String indicatorId)
	{
		List<CSM_Indicator__c> listOfIndicators = new List<CSM_Indicator__c>();

		List<String> indicatorFieldList = new List<String>{CSM_Constants.OBJ_I_ID, CSM_Constants.OBJ_I_NAME, 
        	CSM_Constants.OBJ_I_FIELD_NAME, CSM_Constants.OBJ_I_FIELD_TYPE, 
        	CSM_Constants.OBJ_I_OBJECT_NAME};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_I,
            CSM_Constants.DML_OPERATION_READ, indicatorFieldList);   
        
        if (noAccessList.isEmpty())
        {
        
            listOfIndicators = [SELECT Id,
									  Name,
   	                                  CSM_Object_Field_Name__c,
   	                                  CSM_Object_Field_Type__c,
   	                                  CSM_Object_Name__c
   	                             FROM CSM_Indicator__c
   	                            WHERE Id = :indicatorId limit 1];
		    return listOfIndicators;
        }
        else
        {	
        	 String[] arguments = new String[] {CSM_Constants.OBJ_I + ':'+String.valueOf(noAccessList)};
        	 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));       	 
        }

        return listOfIndicators;
	}
	
	
	/** 
	 * @description retrieves a list of opportunities for the given account
	 * @param account id
	 * @param set of opportunity indicator fields
	 * @return list of opportunity SObjects
	 */
	 //Commented the method as it is not used anywhere. Search did not find any reference for it.
	/* public static List<SObject> dynamicOpportunityQuery(String accountId, Set<String> objectFields)
    {
    	List<SObject> tmpList = new List<SObject>();
    	List<String> acctFieldList = new List<String>();
    	Id localAcctId = accountId;
		String namespace = CSM_Util.getNamespace();
    	String queryString = 'SELECT Id';
    	
    	for (String accountFieldNames: objectFields)
    	{
    		if (accountFieldNames != null && nameSpace!=null && nameSpace.length()>0){
                accountFieldNames = accountFieldNames.replaceAll(nameSpace, '');
            } 
    		queryString += ', ' + accountFieldNames;
    		acctFieldList.add(accountFieldNames);
    	}	
	    if(UserInfo.isMultiCurrencyOrganization() && CSM_Util.returnIfCurrencyISOCodeExists(CSM_Constants.OBJ_OPPORTUNITY))	{
    		queryString += ', ' + CSM_Constants.CURRENCY_ISO_CD;
    		acctFieldList.add(CSM_Constants.CURRENCY_ISO_CD);
	    }
	    
    	queryString += ' from Opportunity where AccountId = :localAcctId order by LastModifiedDate desc LIMIT 1'; 
    	
    	List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_TYPE_OPPORTUNITY, 
                CSM_Constants.DML_OPERATION_READ, acctFieldList);
    	if (noAccessFieldList.isEmpty())
        {    
            tmpList = Database.query(queryString);
            return tmpList;
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_TYPE_OPPORTUNITY + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

        return tmpList;
    }*/
    
    /** 
	 * @description retrieves a list of accounts for the given account
	 * @param account id
	 * @param set of indicator account fields
	 * @return list of accounot SObjects
	 */
    public static List<SObject> dynamicQueryForCustomObject(String accountId, String idName, String objectName, Set<String> objectFields)
    {
    	List<SObject> tmpList = new List<SObject>();
    	List<String> fieldList = new List<String>();
    	String namespace = CSM_Util.getNamespace();
    	String queryString = 'SELECT Id';
	
    	for (String fieldName: objectFields)
    	{
    		if (fieldName != null && nameSpace!=null && nameSpace.length()>0){
                fieldName = fieldName.replaceAll(nameSpace, '');
            } 
    		queryString += ', ' + fieldName;
    		fieldList.add(fieldName);
    	}	

	    if(UserInfo.isMultiCurrencyOrganization() && CSM_Util.returnIfCurrencyISOCodeExists(objectName) && !queryString.contains(CSM_Constants.CURRENCY_ISO_CD))	{
    		queryString += ', ' + CSM_Constants.CURRENCY_ISO_CD;
    		fieldList.add(CSM_Constants.CURRENCY_ISO_CD);
	    }
	   
    	queryString += ' from '+objectName+' where '+idName+' = :accountId LIMIT 1'; 
    	System.debug('queryString - '+queryString);
    	List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(objectName, 
                CSM_Constants.DML_OPERATION_READ, fieldList);
        if (noAccessFieldList.isEmpty())
        {    
            tmpList = Database.query(queryString);
            return tmpList;
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_TYPE_ACCOUNT + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

        return tmpList;
    }
        
    /** 
	 * @description retrieves a list of accounts for the given account
	 * @param account id
	 * @param set of indicator account fields
	 * @return list of accounot SObjects
	 */
	 //Deprecated
    /*public static List<SObject> dynamicQuery(String accountId, Set<String> objectFields)
    {
    	return null;
    }*/
    
     /** 
	 * @description retrieves a list of scout accounot custom field objects for the given account
	 * @param account id
	 * @param set of indicator scout fields
	 * @return list of accounot SObjects
	 */
	//Deprecated
   /* public static List<SObject> dynamicScoutQuery(String accountId, Set<String> objectFields)
    {
    	return null;
    }*/
    
    /*Delete Indicator List*/
    public static void deleteIndicator(List<CSM_Indicator__c> indicatorList) 
	{
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_I, null, CSM_Constants.DML_OPERATION_DELETE);
    	
			delete indicatorList;
    	
	}
}