public with sharing class CHL_PortalContentDataAccess {
	
	public static List<CHL_Portal_Content__c> portalContentsList {
		get{
			if(portalContentsList == null){
				portalContentsList = getPortalContents();
			}
			return portalContentsList;
		}
	}
	
	
	public static List<CHL_Portal_Content__c> getPortalContents()	{
		List<String> portalContentsFields = new List<String>{'CHL_Category__c',
		                                                   'CHL_Description__c',
		                                                   'CHL_Language__c',
		                                                   'CHL_Type__c',
		                                                   'CHL_Weblink_URL__c',
		                                                   'Id',
		                                                   'Name'
		                                                   };
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PORTAL_CONTENT, portalContentsFields, CSM_Constants.DML_OPERATION_READ); 
        String userLanguage = CHL_Util.getLanguageForUserLanguageCode(UserInfo.getLanguage());
        system.debug('userLanguage : '+'::'+userLanguage);
        return [SELECT Id,Name,CHL_Category__c,CHL_Description__c,CHL_Language__c,CHL_Type__c,CHL_Weblink_URL__c  from CHL_Portal_Content__c where CHL_Language__c =:userLanguage OR CHL_Language__c = null  limit 10000];
	}
    
}