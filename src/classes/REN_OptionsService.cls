/**
 * Created Date		: May 3, 2018
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - This class will picklist values
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi										May 3, 2018			1.1		This class will return picklist values for the field
 *
 */
 public with sharing class REN_OptionsService extends REN_JSONAPIBusinessLayer {
	
	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	return null;
    }
    	
	/***This method will retuen JSON for picklist field**/	
 	public override String getResponse(Set<String> paramSet) {
 		REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
	    payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
	    String inputParam = (new List<String>(paramSet))[0];
	    try{
	    	String[] inputParamsArray = inputParam.contains(':') ? inputParam.split(':') : null ;
		    String objectName = inputParamsArray != null ? inputParamsArray[0] : (new List<String>(paramSet))[0];
		    String fieldName = inputParamsArray != null ? inputParamsArray[1] : '';
		    Map<String, String> pickListValueMap = CHL_Util.getPickListValueMap(objectName, fieldName);
		    REN_JSONAPIPayLoad.mainData payLoad;
		    for(String pickListValue: pickListValueMap.values()) {
			    payLoad = new REN_JSONAPIPayLoad.mainData();
				payLoad.type = fieldName;
			    payLoad.Id = pickListValue;
				payLoad.attributes = new Map<String,String>();
		        payLoad.attributes.put('value', pickListValueMap.get(pickListValue));
				payLoadParent.data.add(payLoad);
		    }
		    payLoadParent.action = 'GET';
		    payLoadParent.links = new Map<String, String>();
		    payLoadParent.links.put('Self','/options/'+objectName+'/'+fieldName);  
		    payLoadParent.status = 'SUCCESS';
	    }catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>(); 
            payloadParent.status='ERROR';
            Id oppId = null;
            REN_LowTouchUtil.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString(), oppId);
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured', e.getMessage()));
            payLoadParent.errors = errorList;
            
        }
        return JSON.serialize(payLoadParent);	    
	 }   
}