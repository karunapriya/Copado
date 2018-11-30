public with sharing class CSM_FocusCategoryViewCriteriaDataAccess {

	public static List<CSM_Focus_Category_View_Criteria__c> populateFCVCriteriaInformation(String fcViewId)
	{
		List<CSM_Focus_Category_View_Criteria__c> criteriaList = new List<CSM_Focus_Category_View_Criteria__c>();
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_CRIT_DATE,
        	CSM_Constants.OBJ_PLAY_CRIT_NAME,CSM_Constants.OBJ_PLAY_CRIT_TYPE, CSM_Constants.OBJ_PLAY_CRIT_DISPLAY_NAME,
        	CSM_Constants.OBJ_PLAY_CRIT_OPERATOR, CSM_Constants.OBJ_PLAY_CRIT_VALUE, CSM_Constants.OBJ_FCV,
        	CSM_Constants.OBJ_FCVC_IS_SPECIFIC_DATE, CSM_Constants.OBJ_FCVC_DATE_LITERAL_NUMBER, CSM_Constants.OBJ_FCVC_DATE_LITERAL_STRING,
        	CSM_Constants.OBJ_PLAY_CRIT_DATETIME};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV_CRITERIA, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList);
                
        if (noAccessFieldList.isEmpty())
        {
        	criteriaList = [SELECT id, RLM_Date_Value__c, RLM_LineNo__c, RLM_Values__c, RLM_Field_Name__c, RLM_Is_Specific_Date__c, RLM_Date_Literal_String__c,
        					RLM_Field_Type__c, CSM_Focus_Category_View__c,	RLM_Operator__c, RLM_Field_Display_Name__c, RLM_Date_Literal_Number__c,
        					RLM_DateTime_Value__c
							from CSM_Focus_Category_View_Criteria__c
							where CSM_Focus_Category_View__c = :fcViewId
							order by RLM_LineNo__c
							limit 100];
        }
        else 
        { 
        	 String[] arguments = new String[] {CSM_Constants.OBJ_FCV_CRITERIA + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return 	criteriaList;
	}
	
	/*public static List<CSM_Focus_Category_View_Criteria__c> populateFCVCriteriaInformation(List<String> fcViewIdList)
	{
		List<CSM_Focus_Category_View_Criteria__c> criteriaList = new List<CSM_Focus_Category_View_Criteria__c>();
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_CRIT_DATE,
        	CSM_Constants.OBJ_PLAY_CRIT_NAME,CSM_Constants.OBJ_PLAY_CRIT_TYPE, CSM_Constants.OBJ_PLAY_CRIT_DISPLAY_NAME,
        	CSM_Constants.OBJ_PLAY_CRIT_OPERATOR, CSM_Constants.OBJ_PLAY_CRIT_VALUE, CSM_Constants.OBJ_FCV, CSM_Constants.OBJ_FCVC_IS_SPECIFIC_DATE,
        	CSM_Constants.OBJ_FCVC_DATE_LITERAL_NUMBER, CSM_Constants.OBJ_FCVC_DATE_LITERAL_STRING};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV_CRITERIA, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList);
                
        if (noAccessFieldList.isEmpty())
        {
        	criteriaList = [SELECT id, Name, RLM_Date_Value__c, RLM_Values__c, RLM_Field_Name__c, RLM_Is_Specific_Date__c, RLM_Date_Literal_Number__c,
        					RLM_Field_Type__c, CSM_Focus_Category_View__c,	RLM_Operator__c, RLM_Field_Display_Name__c, RLM_Date_Literal_String__c
							from CSM_Focus_Category_View_Criteria__c
							where CSM_Focus_Category_View__c in :fcViewIdList
							order by CSM_Focus_Category_View__c
							limit 1000];
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_FCV_CRITERIA + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return 	criteriaList;
	}*/
	
	
	public static List<CSM_Focus_Category_View_Criteria__c> saveFCVCriteria(List<CSM_Focus_Category_View_Criteria__c> fcViewCriteriaList)
	{
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_CRIT_DATE,
        	CSM_Constants.OBJ_PLAY_CRIT_NAME,CSM_Constants.OBJ_PLAY_CRIT_TYPE, CSM_Constants.OBJ_PLAY_CRIT_DISPLAY_NAME,
        	CSM_Constants.OBJ_PLAY_CRIT_OPERATOR, CSM_Constants.OBJ_PLAY_CRIT_VALUE, CSM_Constants.OBJ_FCV,
        	CSM_Constants.OBJ_PLAY_CRIT_DATETIME};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV_CRITERIA, 
                CSM_Constants.DML_OPERATION_UPSERT, criteriaFieldList);
                
        if (noAccessFieldList.isEmpty())
        {
        	upsert fcViewCriteriaList;
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_FCV_CRITERIA + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));
        }	
        return 	fcViewCriteriaList;
	}
	
	public static boolean deleteFCVCriteria(List<CSM_Focus_Category_View_Criteria__c> fcViewCriteriaList)
	{
        boolean isSuccess = false;
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV_CRITERIA, 
                CSM_Constants.DML_OPERATION_Delete, null);
        // No need to check if field list is empty.  An exception will be thrown if user cannot delete        
  
    	delete fcViewCriteriaList;
    	isSuccess = true;
       
        return 	isSuccess;
	}
	
	
	 /* 
	 *@description Create the Clone of FCCriteria .
	 *@Params : It accepts Id of FC view Id as fcViewID and cloned FC View of as fcViewIDNew. 
	 */
	public static void cloneFCCriteriaByFCId(String fcViewID,String fcViewIDNew ){
        List < CSM_Focus_Category_View_Criteria__c > fcViewCriteriaList = populateFCVCriteriaInformation(fcViewID);
        
        List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_CRIT_DATE,
        	CSM_Constants.OBJ_PLAY_CRIT_NAME,CSM_Constants.OBJ_PLAY_CRIT_TYPE, CSM_Constants.OBJ_PLAY_CRIT_DISPLAY_NAME,
        	CSM_Constants.OBJ_PLAY_CRIT_OPERATOR, CSM_Constants.OBJ_PLAY_CRIT_VALUE, CSM_Constants.OBJ_FCV,
        	CSM_Constants.OBJ_PLAY_CRIT_DATETIME};
        
	    CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FCV_CRITERIA, criteriaFieldList, CSM_Constants.DML_OPERATION_INSERT);
		if(fcViewCriteriaList != null){
			List < CSM_Focus_Category_View_Criteria__c > fcViewCriteriaCloneList = new List < CSM_Focus_Category_View_Criteria__c > ();
			for (CSM_Focus_Category_View_Criteria__c fcvCriteriaObj: fcViewCriteriaList) {
				CSM_Focus_Category_View_Criteria__c fcvCriteria = new CSM_Focus_Category_View_Criteria__c();
				fcvCriteria = fcvCriteriaObj.clone(false, false, false, false);
				fcvCriteria.CSM_Focus_Category_View__c = fcViewIDNew;
				fcViewCriteriaCloneList.add(fcvCriteria);
			}
			insert fcViewCriteriaCloneList;
		}
     }
     
     /*
     *@description Create the Clone on FCRestrictVisiblity .
	 *@Params : It accepts Id of FC view Id as fcViewID and cloned FC View of as fcViewIDNew.
     */
     public static void cloneRestrictVisibilityByFCId(String fcViewID,String fcViewIDNew){
     	List<CSM_Focus_Category_View__Share> fcViewShareList = new List<CSM_Focus_Category_View__Share>();
     	fcViewShareList = [SELECT AccessLevel,ParentId,UserOrGroupId,RowCause FROM CSM_Focus_Category_View__Share where ParentId=:fcViewID AND RowCause!= 'Rule'AND RowCause!= 'Owner'];
     	if(fcViewShareList != null){ 
     		List<CSM_Focus_Category_View__Share> fcRestrictVisiblityCloneList = new List<CSM_Focus_Category_View__Share>();
     		for(CSM_Focus_Category_View__Share fcShareObj:fcViewShareList){
				CSM_Focus_Category_View__Share fcViewShare = new CSM_Focus_Category_View__Share();
				fcViewShare = fcShareObj.clone(false, false, false, false);
				fcViewShare.ParentId = fcViewIDNew;
				fcRestrictVisiblityCloneList.add(fcViewShare);
     		}
     		insert fcRestrictVisiblityCloneList;
     	}
     }
     
}