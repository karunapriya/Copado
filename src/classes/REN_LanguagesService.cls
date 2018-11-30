/**
 * Created Date     : June, 04 2018
 * Developed By     : Vishal, Comity Designs, Inc.
 *
 * Function         : @description - Handling Languages
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Vishal                   User Story              June, 04 2018    1.0         Handling Languages supported for a user   
 *
 */
 public with sharing class REN_LanguagesService extends REN_JSONAPIBusinessLayer {
	
	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	return null;
    }
    
    /***This method will return JSON for all LT Languages**/
    /***Example - {"data": [{"type": "language","id": "en-US","attributes": {"english": "English","native": "English"}},
    						{"type": "language","id": "fr-FR","attributes": {"english": "English","native": "Français"}},
    						{"type": "language","id": "cn-ZN","attributes": {"english": "Chinese","native": "日本語"}}
    						],"links":{"self":"/languages"},"action": "GET"}
	/***This method will retuen JSON for picklist field**/	
 	public override String getResponse(Set<String> paramSet) {
 		REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
	    payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>(); 
	    try{
	    	
	    	List<REN_LT_Active_Languages__c> activeLanguagesList =  REN_LT_Active_Languages__c.getall().values();
	    	if (!activeLanguagesList.isEmpty() && activeLanguagesList != null){
	    		REN_JSONAPIPayLoad.mainData payLoad;
	    		for(REN_LT_Active_Languages__c lang : activeLanguagesList) {
	    			payLoad = new REN_JSONAPIPayLoad.mainData();
					payLoad.type = 'language';
				    payLoad.Id = lang.REN_LT_Language_Code__c;
				    payLoad.attributes = new Map<String,String>();
				    payLoad.attributes.put('english', lang.name);
				    payLoad.attributes.put('native', lang.REN_LT_Language_Native_Value__c);
					payLoadParent.data.add(payLoad);
	    		}
	    		payLoadParent.action = 'GET';
			    payLoadParent.links = new Map<String, String>();
			    payLoadParent.links.put('Self','/languages');  
			    payLoadParent.status = 'SUCCESS';
	    	} else {
		    	payLoadParent.status = 'ERROR';
	            errorList.add(new REN_LowTouchUtil().createErrorList('ERROR', system.Label.CHL_LBL_STAGE_ONLOAD, 'ERROR', system.Label.CHL_LBL_STAGE_ONLOAD));
	            REN_LowTouchUtil.updateErrorLog(system.label.CHL_LBL_STAGE_ONLOAD, 'Languages Not added in custom Setting.', null); //ToDo: Add custom label. Currently unable to add due to major version.
	            payLoadParent.errors = errorList;
		    }
	    }catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            payloadParent.status='ERROR';
            Id oppId = null;
            REN_LowTouchUtil.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString(), null);
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, 'Exception occured', e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString()));
            payLoadParent.errors = errorList;
            
        }
        return JSON.serialize(payLoadParent);	    
	 }       
}