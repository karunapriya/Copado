public with sharing class CSM_IndicatorGroupDataAccess
{
	public static List<CSM_Indicator_Group__c> getAllIndicatorGroups() 
	{
		List<CSM_Indicator_Group__c> indicatorGroupList = new List<CSM_Indicator_Group__c>();

		List<String> indicatorGroupFieldList = new List<String>{CSM_Constants.OBJ_IG_ID, CSM_Constants.OBJ_IG_DISPLAY_NAME};
        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_IG,
        	    CSM_Constants.DML_OPERATION_READ, indicatorGroupFieldList);	      
        	         
        if (noAccessList.isEmpty())
        {
        	indicatorGroupList = [SELECT Id,
        	                             CSM_Display_Name__c
        	                        FROM CSM_Indicator_Group__c
        	                       WHERE Id != null LIMIT 10];
        }
        else
        {     
        	
    		 String[] arguments = new String[] {CSM_Constants.OBJ_IG_ID + ':'+String.valueOf(noAccessList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
    		     
        } 
   
        return indicatorGroupList;
	}
	
	public static void insertIndicatorGroup(List<CSM_Indicator_Group__c> indicatorGroupList)
	{		
	    List<String> indicatorGroupFieldList = new List<String>{CSM_Constants.OBJ_IG_DISPLAY_NAME};
	
	    List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_IG,
	        CSM_Constants.DML_OPERATION_INSERT, indicatorGroupFieldList);
	    if (noAccessList.isEmpty())
	    {
	        insert indicatorGroupList;   		
	    }
	    else 
	    {
	        String[] arguments = new String[] {CSM_Constants.OBJ_IG + ':'+String.valueOf(noAccessList)};			   
	        throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE, 
	        arguments));
	    }

	}
}