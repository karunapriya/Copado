/**
 * Created Date		: Jul 30, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: This class is created for Quote Import redirect.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log 
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Comity					US3657			Jul 30, 2018			1.1					@description
 * 
 */
public with sharing class REN_QuoteImportRedirectController {
	private String OppId;
    private String caseId;
    private String partnerOppId;
    private String objId;
    private String ObjName;

    public REN_QuoteImportRedirectController(ApexPages.StandardSetController standardController) {
    	objId = ApexPages.currentPage().getParameters().get('Id');
	    objId = String.escapeSingleQuotes(objId);
	    ObjName = ((Id)objId).getSObjectType().getDescribe().getName();
	}
	
	public PageReference returnPage(){
    	List<SObject> SObjectList = new List<SObject>();
    	
    	if(ObjName == 'Case'){
            SObjectList  = getSObjectList(new set<String>{ObjName}, new set<Id>{objId}, new set<String>{'Opportunity__c'});
            OppId = (string)SObjectList[0].get('Opportunity__c');
        }else if(ObjName == 'CHL_Partner_Opportunity__c'){
            SObjectList  = getSObjectList(new set<String>{ObjName}, new set<Id>{objId}, new set<String>{'CHL_Opportunity__c'});
            OppId =(string) SObjectList[0].get('CHL_Opportunity__c');
        }else{
            OppId = objId;
        }
        
        PageReference pageRef = Page.REN_QuoteImportLanding;
        if(ObjName == 'Case'){
            pageRef.getParameters().put('oppId', OppId); 
            pageRef.getParameters().put('caseId', (Id)SObjectList[0].get('Id'));       
        }else{
            pageRef.getParameters().put('oppId', OppId);
        }
           
        return pageRef;
   }
   
   private List<SObject> getSObjectList(Set<String> objectNames,Set<Id> SObjectIds, Set<String> fldsToQuery){
   		List<String> sobjectFldList = new List<String>();
    	sobjectFldList.addAll((List<String>)JSON.deserialize(JSON.serialize(fldsToQuery), List<String>.class));
    	String soqlStr;
    	soqlStr = String.join(sobjectFldList, ',');
   		soqlStr = 'SELECT ' + soqlStr + ' FROM ' + new List<String>(objectNames)[0] +' WHERE Id IN:SObjectIds limit 10'; 
        return Database.query(soqlStr);
   }

    
}