/**
 * Created Date     : Feb, 18 2018
 * Developed By     : Vishal, Comity Designs, Inc.
 *
 * Function         : @description - Low Touch factory that routes 
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Vishal                   User Story              Feb 18, 2018    1.0         Low Touch oAuth access token based on refresh token   
 *
 */
public with sharing class REN_LowTouchRouter {
 
    private String objectName {get; set;}
    private String objectId {get; set;}
    
    public REN_LowTouchRouter() {
        
    }
    
    private void getObjectNameId(REN_LowTouchPayLoad payLoad) {
        System.debug('Payload -'+payLoad);
        if (payLoad !=null && payLoad.Links != null && !payLoad.Links.isEmpty()) {
            List<String> objValue = getParam(payLoad.links);
            if (!objValue.isEmpty()){
                String[] objValueArray = objValue[0].split('=');
                if (!objValueArray.isEmpty()){
                    this.objectName = objValueArray[0];
                    this.objectId = objValueArray[1];
                    if (objValue.size()==2){
                        String[] objRelArray = objValue[1].split('=');
                        this.objectName = objRelArray[0];
                        if(this.objectName == 'labels'){
                        	this.objectId = objRelArray[1];	
                        } 
                        if(this.objectName.equalsIgnoreCase('paymentmethods') && objRelArray.size() == 2 &&  objRelArray[1].equalsIgnoreCase('docusign')){
                        	this.objectName = 'DocuSign';
                        } else if(this.objectName.equalsIgnoreCase('paymentmethods') && objRelArray.size() == 2 &&  objRelArray[1].equalsIgnoreCase('cc')){
                        	this.objectName = 'Payments';
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
            REN_LowTouchPayLoad payLoad = (REN_LowTouchPayLoad) JSON.deserialize(req, REN_LowTouchPayLoad.class);
    
            REN_LowTouchRouter router = new REN_LowTouchRouter();
            getObjectNameId(payLoad);
	        if (this.objectName != null && this.objectId != null){
                System.debug('this.objectName - '+this.objectName);
                String className = 'REN_LowTouch' + this.objectName+ 'Service';
                Type typeObj = type.forName(className);
                Object handler = typeObj.newInstance();
                if (handler instanceof REN_LowTouchBusinessLayer) {
                    if (payLoad.action != null){
                        System.debug('payLoad.action = '+payLoad.action);
                        if (payLoad.action == 'GET'){
                            jsonString = ((REN_LowTouchBusinessLayer) handler).getResponse(new Set<String>{this.objectId});
                        } else {
                            jsonString = ((REN_LowTouchBusinessLayer) handler).postResponse(new Set<String>{this.objectId}, payLoad);
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
                            System.debug('objValue - '+objValue);
                        }
                    }
                }
            }
        }
        
        return objValue;
    }
}