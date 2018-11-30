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
 public with sharing class REN_IBExportService extends REN_JSONAPIBusinessLayer {
	
	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	return null;
    }
    
    /***This method will return JSON for all LT Languages**/
    /***Example - {"data": [{"type": "FieldName","id": "1234","attributes": {"Id": "1234","displayName": "Leena"}},
    						{"type": "FieldName","id": "1234","attributes": {"Id": "1234","displayName": "Leena"}},
    						{"type": "FieldName","id": "1234","attributes": {"Id": "1234","displayName": "Leena"}}
    						],"links":{"self":"/IBExport"},"action": "GET"}
	/***This method will retuen JSON for picklist field**/	
 	public override String getResponse(Set<String> paramSet) {
 		REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
	    payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
	    try{
	    	
	    	// We will get it from Opportunity Status log for now, JJ will provide more input if this is not the case
	    	List<REN_LT_Active_Languages__c> activeLanguagesList =  REN_LT_Active_Languages__c.getall().values();
	    	if (!activeLanguagesList.isEmpty() && activeLanguagesList != null){
	    		REN_JSONAPIPayLoad.mainData payLoad;
	    		
	    		
	    		payLoad = new REN_JSONAPIPayLoad.mainData();
				payLoad.type = 'fieldname';
			    payLoad.Id = '1234';
			    payLoad.attributes = new Map<String,String>();
			    payLoad.attributes.put('displayname', 'Leena');

			    payLoadParent.data.add(payLoad);
	    		payLoad = new REN_JSONAPIPayLoad.mainData();
				payLoad.type = 'fieldname';
			    payLoad.Id = '1234';
			    payLoad.attributes = new Map<String,String>();
			    payLoad.attributes.put('displayname', 'Leena Test 1');
			    payLoadParent.data.add(payLoad);
	    		/*for(REN_LT_Active_Languages__c lang : activeLanguagesList) {
	    			payLoad = new REN_JSONAPIPayLoad.mainData();
					payLoad.type = 'language';
				    payLoad.Id = lang.REN_LT_Language_Code__c;
				    payLoad.attributes = new Map<String,String>();
				    payLoad.attributes.put('english', lang.name);
				    payLoad.attributes.put('native', lang.REN_LT_Language_Native_Value__c);
					payLoadParent.data.add(payLoad);
	    		}*/
	    		payLoadParent.action = 'GET';
			    payLoadParent.links = new Map<String, String>();
			    payLoadParent.links.put('Self','/IBExport');  
			    payLoadParent.status = 'SUCCESS';
	    	}
	    }catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>(); 
            payloadParent.status='ERROR';
            Id oppId = null;
            REN_LowTouchUtil.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString(), null);
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, 'Exception occured', e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString()));
            payLoadParent.errors = errorList;
            
        }
        return JSON.serialize(payLoadParent);	    
	 }
	 
	 public with sharing class REN_LookupValues{
	 	public string Id {get; set;}
	 	public string displayName {get; set;}
	 }        
}