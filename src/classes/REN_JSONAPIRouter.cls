/**
 * Created Date		: Apr 19, 2018
 * Developed By		: Tanvi, Comity Designs, Inc.
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
 * Tanvi					User Story				Apr 19, 2018			1.1					@description
 *
 */
 public with sharing class REN_JSONAPIRouter {
    private String objectName {get; set;}
    private String objectId {get; set;}
    
    public REN_JSONAPIRouter() {
        
    }
    
    private void getObjectNameId(REN_JSONAPIPayLoad payLoad) {
        if (payLoad !=null && payLoad.Links != null && !payLoad.Links.isEmpty()) {
            List<String> objValue = getParam(payLoad.links);
            System.debug('objValue -'+objValue);        
        	if (!objValue.isEmpty()){
                String[] objValueArray = objValue[0].split('=');
                if (!objValueArray.isEmpty()){
                    this.objectName = objValueArray[0];
                    this.objectId = objValueArray[1];
                    if (objValue.size()==2){
                        String[] objRelArray = objValue[1].split('=');
                        system.debug('objRelArray :: '+objRelArray + 'objValueArray[1] :: '+objValueArray[1]+'objRelArray[1] :: '+objRelArray[1]);    
                        system.debug('objValueArray[0] : '+objValueArray[0]+'objectName : '+objectName);                    
                        this.objectId = objRelArray[0].equalsIgnoreCase('labels') || objectName.equalsIgnoreCase('options') ? objValueArray[1] + ':' + objRelArray[1] : objValueArray[1]; 
                        this.objectName = objValueArray[0].equalsIgnoreCase('labels') || objValueArray[0].equalsIgnoreCase('options') ? objValueArray[0] : objRelArray[0];
                        this.objectName = objectName.equalsIgnoreCase('paymentmethods') && objRelArray.size() == 2 &&  objRelArray[1].equalsIgnoreCase('ds') ? 'DocuSign' : this.objectName; 
                        this.objectName = objectName.equalsIgnoreCase('paymentmethods') && objRelArray.size() == 2 &&  objRelArray[1].equalsIgnoreCase('cc') ? 'Payments' : this.objectName;
                      
                    } else {
                    	if(objectName.equalsIgnoreCase('importquotes') && objectId.equalsIgnoreCase('labels')) {
                    		this.objectName = 'labels';
                    		this.objectId = 'importquotes:'+UserInfo.getLanguage();
                    	} 
                    }
                        
                    System.debug ('objectName - '+objectName + ' objectId - '+objectId);
                }
            } 
        } 
	}
    
    public String getPostRequest(String req) {
        String jsonString = null;
        if (req!=null){
            REN_JSONAPIPayLoad payLoad = (REN_JSONAPIPayLoad) JSON.deserialize(req, REN_JSONAPIPayLoad.class);
    
            REN_JSONAPIRouter router = new REN_JSONAPIRouter();
            getObjectNameId(payLoad);
	        if (this.objectName != null && this.objectId != null){
                System.debug('this.objectName - '+this.objectName+'\n this.objectId :: '+this.objectId);
                String className = 'REN_' + this.objectName+ 'Service';
                Type typeObj = type.forName(className);
                Object handler = typeObj.newInstance();
                if (handler instanceof REN_JSONAPIBusinessLayer) {
                    if (payLoad.action != null){
                        System.debug('payLoad.action = '+payLoad.action);
                        if (payLoad.action == 'GET'){
                            jsonString = ((REN_JSONAPIBusinessLayer) handler).getResponse(new Set<String>{this.objectId});
                        } else {
                            jsonString = ((REN_JSONAPIBusinessLayer) handler).postResponse(new Set<String>{this.objectId}, payLoad);
                        }
                    }
                }
            }
        }	
		return jsonString;
	}
    
    private List<String> getParam(Map<String, String> links){
        List<String> objValue = new List<String>();
        if (links != null && links.containsKey('self')) {
            String self = links.get('self');
            if (self != null){
                String[] linksArray = self.split('/');
                if (linksArray!=null){
                    for (integer i=0; i<=linksArray.size()-1;i++){
                        if (linksArray[i] != null && linksArray[i] != '' && linksArray[i] != 'relationships'){
                            if (i<linksArray.size()-1){
                                objValue.add(linksArray[i]+'='+linksArray[i+1]);
                                i++;
                            } else {
                                objValue.add(linksArray[i]+'='+linksArray[i]);
                            }
                        }
                    }
                }
            }
        }
        
        return objValue;
    }
}