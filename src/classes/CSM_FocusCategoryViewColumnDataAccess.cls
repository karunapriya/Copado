public with sharing class CSM_FocusCategoryViewColumnDataAccess {
	
	public static List<CSM_Focus_Category_View_Column__c> findFCVCByViewID (Id fcViewId) {
		List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
			CSM_Constants.OBJ_I_FIELD_NAME, CSM_Constants.OBJ_I_FIELD_TYPE, CSM_Constants.OBJ_FCV,
        	CSM_Constants.OBJ_I_OBJECT_NAME};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV_COLUMN,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        
        if (noAccessList.isEmpty())
        {
        
            List<CSM_Focus_Category_View_Column__c> listFCVC = [SELECT Id,
        	                                                  CSM_Display_Name__c,
					               	                          CSM_Focus_Category_View__c,
						   	                                  CSM_Object_Field_Name__c,
						   	                                  CSM_Object_Name__c,
						   	                                  CSM_Object_Field_Type__c
						   	                             FROM CSM_Focus_Category_View_Column__c
						   	                            WHERE CSM_Focus_Category_View__c = :fcViewId LIMIT 1000];
		    return listFCVC;
        }
        else
        {	
        	 String[] arguments = new String[] {CSM_Constants.OBJ_FCV_COLUMN + ':'+String.valueOf(noAccessList)};
        	 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));       	 
        }
        return null;
	}
	
	public static List<CSM_Focus_Category_View_Column__c> populateFCVColumnInformation (List<String> fcViewIds) {
		List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
			CSM_Constants.OBJ_I_FIELD_NAME, CSM_Constants.OBJ_I_FIELD_TYPE, CSM_Constants.OBJ_FCV,
        	CSM_Constants.OBJ_I_OBJECT_NAME};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV_COLUMN,
            CSM_Constants.DML_OPERATION_READ, fcvFieldList);   
        
        if (noAccessList.isEmpty())
        {
        
            List<CSM_Focus_Category_View_Column__c> listFCVC = [SELECT Id,
        	                                                  CSM_Display_Name__c,
					               	                          CSM_Focus_Category_View__c,
						   	                                  CSM_Object_Field_Name__c,
						   	                                  CSM_Object_Name__c,
						   	                                  CSM_Object_Field_Type__c
						   	                             FROM CSM_Focus_Category_View_Column__c
						   	                            WHERE CSM_Focus_Category_View__c IN :fcViewIds LIMIT 1000];
		    return listFCVC;
        }
        else
        {	
        	 String[] arguments = new String[] {CSM_Constants.OBJ_FCV_COLUMN + ':'+String.valueOf(noAccessList)};
        	 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));       	 
        }
        return null;
	}	
	
	public static void upsertFCVC(List<CSM_Focus_Category_View_Column__c> listFCVC)
	{
		List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
			CSM_Constants.OBJ_I_FIELD_NAME, CSM_Constants.OBJ_I_FIELD_TYPE, CSM_Constants.OBJ_FCV,
        	CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_I_NAME};
	    List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV_COLUMN,
    	    CSM_Constants.DML_OPERATION_UPSERT, fcvFieldList);
    	if (noAccessList.isEmpty())
    	{
			
			if (!listFCVC.isEmpty())
			{
			    upsert listFCVC;
			}
    	}
    	else
    	{
    		
    		String[] arguments = new String[] {CSM_Constants.OBJ_FCV_COLUMN + ':'+String.valueOf(noAccessList)};			   
	        throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, 
	        arguments));   		
    	}    	  
	}
	
	public static boolean deleteFCVColumn(List<CSM_Focus_Category_View_Column__c> fcViewColumnList)
	{
        boolean isSuccess = false;
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCV_COLUMN, 
                CSM_Constants.DML_OPERATION_Delete, null);
        //No need to check if list is empty.  If not allowed to delete exception will be thrown.         
      
    	delete fcViewColumnList;
    	isSuccess = true;
        
        return 	isSuccess;
	}
	
	 /* 
	 *@description Create the Clone of FCColumn.
	 *@Params : It accepts Id of FC view Id as fcViewID and cloned FC View of as fcViewIDNew. 
	 */
	public static void cloneFCColViewByFcId(String fcViewID,String fcViewIDNew ){

		List <CSM_Focus_Category_View_Column__c> fcvColList = findFCVCByViewID(fcViewID);
		
		List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_DISPLAY_NAME,
									CSM_Constants.OBJ_I_FIELD_NAME, CSM_Constants.OBJ_I_FIELD_TYPE, CSM_Constants.OBJ_FCV,
        							CSM_Constants.OBJ_I_OBJECT_NAME};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FCV_COLUMN, fcvFieldList, CSM_Constants.DML_OPERATION_INSERT);
	
		if(fcvColList != null){
			List < CSM_Focus_Category_View_Column__c > fcvColCloneList = new List < CSM_Focus_Category_View_Column__c > ();
			for (CSM_Focus_Category_View_Column__c fcvColObj: fcvColList) {
		 		CSM_Focus_Category_View_Column__c fcvCol = new CSM_Focus_Category_View_Column__c();
		 		fcvCol = fcvColObj.clone(false, false, false, false);
		 		fcvCol.CSM_Focus_Category_View__c = fcViewIDNew;
		 		fcvColCloneList.add(fcvCol);
			}
			insert fcvColCloneList;
		}
     }
}