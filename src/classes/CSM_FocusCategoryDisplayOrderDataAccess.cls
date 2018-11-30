/**
 * Created Date		: Sep 19, 2017
 * Developed By		: admin, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * admin					User Story				Sep 19, 2017			1.1					@description
 *
 */
public with sharing class CSM_FocusCategoryDisplayOrderDataAccess {
	public static List<CSM_Focus_Category_Display_Order__c> getFCDisplayOrderByUserId(Set<Id> userId, String fcType){  
		List<String> fieldList = new List<String>{'Id',
												  'CSM_Focus_Category_View_Id__c', 
												  'CSM_Order__c',
												  'CSM_Type__c',
												  'CSM_User_Id__c'};      
        CSM_Util.checkCRUD_FLS('CSM_Focus_Category_Display_Order__c', fieldList, CSM_Constants.DML_OPERATION_READ);
        return [select id, CSM_Focus_Category_View_Id__c, CSM_Order__c, CSM_Type__c, CSM_User_Id__c from CSM_Focus_Category_Display_Order__c where CSM_User_Id__c = :userId and CSM_Type__c = :fcType and CSM_Focus_Category_View_Id__c != null order by CSM_Order__c Asc];
    }
    
    public static List<CSM_Focus_Category_Display_Order__c> getFCDisplayOrderByUser(Set<Id> userId, String fcType){  
		List<String> fieldList = new List<String>{'Id',
												  'CSM_Focus_Category_View_Id__c', 
												  'CSM_Order__c',
												  'CSM_Type__c',
												  'CSM_User_Id__c'};      
        CSM_Util.checkCRUD_FLS('CSM_Focus_Category_Display_Order__c', fieldList, CSM_Constants.DML_OPERATION_READ);
        return [select id, CSM_Focus_Category_View_Id__c, CSM_Order__c, CSM_Type__c, CSM_User_Id__c from CSM_Focus_Category_Display_Order__c where CSM_User_Id__c = :userId and CSM_Type__c = :fcType order by CSM_Order__c Asc];
    }
    
    public static List<CSM_Focus_Category_Display_Order__c> getFCDisplayOrderByUserId(Set<Id> userId){  
		List<String> fieldList = new List<String>{'Id',
												  'CSM_Focus_Category_View_Id__c', 
												  'CSM_Order__c',
												  'CSM_Type__c',
												  'CSM_User_Id__c'};      
        CSM_Util.checkCRUD_FLS('CSM_Focus_Category_Display_Order__c', fieldList, CSM_Constants.DML_OPERATION_READ);
        return [select id, CSM_Focus_Category_View_Id__c, CSM_Order__c, CSM_Type__c, CSM_User_Id__c from CSM_Focus_Category_Display_Order__c where CSM_User_Id__c = :userId and CSM_Focus_Category_View_Id__c != null order by CSM_Order__c Asc];
    }
    
    public static void deleteFCDisplayOrder(List<CSM_Focus_Category_Display_Order__c> fcDisplayOrderList){  
		CSM_Util.checkCRUD_FLS('CSM_Focus_Category_Display_Order__c', null, CSM_Constants.DML_OPERATION_DELETE);
        delete fcDisplayOrderList;
    }
    
    public static List<Database.SaveResult> insertFCDisplayOrder(List<CSM_Focus_Category_Display_Order__c> fcDisplayOrderList){
    	List<Database.SaveResult> queryResultList = null;
		if(!fcDisplayOrderList.isEmpty()){
			List<String> fieldList = new List<String>{'CSM_Focus_Category_View_Id__c', 
													  'CSM_Order__c',
													  'CSM_Type__c',
													  'CSM_User_Id__c'};	 
			CSM_Util.checkCRUD_FLS('CSM_Focus_Category_Display_Order__c', fieldList, CSM_Constants.DML_OPERATION_INSERT);												
			queryResultList = Database.insert(fcDisplayOrderList , true);
		}
		return queryResultList;
    }
    
    public static List<Id> getFocusCategoryIdsByOrder(Set<Id> userIds,String fcType){
        List<Id> fcIdsByOrderList = new List<Id>();
        List<CSM_Focus_Category_Display_Order__c> fcOrderList = CSM_FocusCategoryDisplayOrderDataAccess.getFCDisplayOrderByUserId(userIds,fcType);
        if(fcOrderList != null && !fcOrderList.isEmpty()){
            for(CSM_Focus_Category_Display_Order__c fc:fcOrderList){
                fcIdsByOrderList.add(fc.CSM_Focus_Category_View_Id__c);
            }           
        }
        return fcIdsByOrderList;      
    }
	
	public static List<CSM_Focus_Category_Display_Order__c> getFCDisplayOrderByFCVId(Set<Id> fcvId){  
		List<String> fieldList = new List<String>{'Id',
												  'CSM_Focus_Category_View_Id__c', 
												  'CSM_Order__c',
												  'CSM_Type__c',
												  'CSM_User_Id__c'};      
        CSM_Util.checkCRUD_FLS('CSM_Focus_Category_Display_Order__c', fieldList, CSM_Constants.DML_OPERATION_READ);
        return [select id, CSM_Focus_Category_View_Id__c, CSM_Order__c, CSM_Type__c, CSM_User_Id__c from CSM_Focus_Category_Display_Order__c where CSM_Focus_Category_View_Id__c IN :fcvId];
    }
}