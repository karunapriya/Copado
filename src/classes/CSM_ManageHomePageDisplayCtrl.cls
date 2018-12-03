/**
 * Created Date		: Sep 14, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Implementation of US2669 (Design a way to specify the order of Focus categories displayed on the home page)
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2757				    Sep 14, 2017	1.1					Specifiy order for Focus Category to be displayed on Home page
 *
 */
public with sharing class CSM_ManageHomePageDisplayCtrl {

    public String vt {get; private set;}
    public String helpParam {get; set;}
    
    public CSM_ManageHomePageDisplayCtrl() {
        vt = ApexPages.currentPage().getParameters().get('vt');
        helpParam = CSM_Constants.HELP_ORGANIZE_FOCUS_CATEGORIES;
    }
    
	@RemoteAction
    public static object getUsersForManager(String dummyId){
        List<SObject> searchList = CSM_UserDataAccess.getUserListForFocusCategories();
		List<CSM_FocusCategoryUserWrapper> userWrapper = new List<CSM_FocusCategoryUserWrapper>();
        for(SObject str : searchList) {
        	CSM_FocusCategoryUserWrapper wrp = new CSM_FocusCategoryUserWrapper();
        	wrp.id = (String)str.get('Id');
        	wrp.name = (String)str.get('name');
        	userWrapper.add(wrp);
        }
        return userWrapper;
    }
    
    @RemoteAction
    public static object getFocusCategories(String passedUserId){       
    	CSM_UserForResponseWrapper userIdWrp = (CSM_UserForResponseWrapper)JSON.deserialize(passedUserId,CSM_UserForResponseWrapper.class);
    	system.debug('\nuserIdWrp~~'+userIdWrp);
        CSM_FocusCategoryResponseWrapper wrpObj = new CSM_FocusCategoryResponseWrapper();
        Set<Id> fcvIdSet = CSM_FocusCategoryViewDataAccess.getFocusCategoryIds(new Set<Id>{userIdWrp.id != null?userIdWrp.id:UserInfo.getUserId()});        
        List<CSM_Focus_Category_View__c> searchList = CSM_FocusCategoryViewDataAccess.getFocusCategoryList(fcvIdSet);        
        List<CSM_Focus_Category_Display_Order__c> fcDisplayOrderList = CSM_FocusCategoryDisplayOrderDataAccess.getFCDisplayOrderByUserId(new Set<Id>{userIdWrp.id != null?userIdWrp.id:UserInfo.getUserId()}); 
        wrpObj = CSM_ManageHomePageDisplayCtrlHelper.getFocusCategoryOrderWrapper(searchList, fcDisplayOrderList);
        return JSON.serialize(wrpObj);
    }
    
    @RemoteAction
    public static object saveFocusCategories(String saveString){        
        CSM_FocusCategoryOrderWrapper wrpObj = (CSM_FocusCategoryOrderWrapper)JSON.deserialize(saveString,CSM_FocusCategoryOrderWrapper.class);
        system.debug('\nwrpObj~~'+wrpObj);
        List<CSM_Focus_Category_Display_Order__c> fcViewOrderingList = CSM_ManageHomePageDisplayCtrlHelper.getFocusCategoryOrderList(wrpObj, UserInfo.getUserId());
        List<Database.SaveResult> fcSaveResult = null;
        if(fcViewOrderingList != null && !fcViewOrderingList.isEmpty()) {
        	fcSaveResult = CSM_FocusCategoryDisplayOrderDataAccess.insertFCDisplayOrder(fcViewOrderingList);	
        }
        Boolean isSuccess = true;
        if(fcSaveResult != null && !fcSaveResult.isEmpty()) {
	        for(Database.SaveResult sr : fcSaveResult) {
	        	isSuccess = sr.isSuccess()? true:false;
	        }
        }
        CSM_ResponseWrapper respWrp = new CSM_ResponseWrapper();
        respWrp.success = isSuccess;
        respWrp.message = respWrp.success? '':'something went wrong';
        return JSON.serialize(respWrp);
    }
    
    public class CSM_UserForResponseWrapper {
    	String id {get; set;}
    	String name {get;set;}
    }
}