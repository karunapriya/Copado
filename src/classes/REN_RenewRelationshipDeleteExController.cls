/**
 * Created Date     : July 13, 2017
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 *
 * Function         : @description - This class is used to check if Quote is in sync with the opportunity. 
 									 If it is in sync, an alert is shown for confirming delete on RLI.
 * Support Email    : 
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Rucha                    US2496              July 13, 2017            1.1                 @description
 *
**/

public with sharing class REN_RenewRelationshipDeleteExController {
	public Boolean isRecordDeleted {get;set;}
	public Boolean isQuoteEnabled {get;set;}
	public Boolean isSyncedQuotePresent {get;set;}
    public List<REN_Renews_To__c> rliList;
    private String returnUrl;
    private REN_Renews_To__c rliObj;
    public ID oppId{get;set;}
    
    public REN_RenewRelationshipDeleteExController(ApexPages.StandardController stdController){
    	rliObj = (REN_Renews_To__c)stdController.getRecord();
        isSyncedQuotePresent = false;
        isRecordDeleted = false;
        isQuoteEnabled = CSM_AccessController.hasField('opportunity',  'SyncedQuoteId');
        returnUrl = ApexPages.currentPage().getParameters().get('retURL');
        Set<String> rliCrudFldSet = new Set<String>{'id','REN_Renews_To__c'};
        Set<String> rliFldSet = new Set<String>{'id','REN_Renews_To__c'};
        if(isQuoteEnabled) {
        	rliFldSet.add('REN_Renews_To__r.SyncedQuoteId');
        }
        
        /* Getting list of RLIs. */
        rliList = REN_RenewRelationshipDataAccess.getRenewalRelationshipByIds(rliFldSet, new Set<String>{rliObj.id},rliCrudFldSet);        
        if(rliList != null && !rliList.isEmpty()){
        	oppId =  rliList[0].REN_Renews_To__c;
            if(isQuoteEnabled && rliList[0].REN_Renews_To__r.get('SyncedQuoteId') != null){           	
                isSyncedQuotePresent = true;
            }
        }
    }
    
    /* This method is used to remove synced quote on the Opportunity and delete selected RLI. */
    
    public PageReference removeSyncedQuote(){
    	PageReference retPage;
    	Savepoint sp = Database.setSavepoint();
        try{
	        List<Opportunity> toBeUpdatedOppsList = new List<Opportunity>() ;
	        List<String> oppFieldSet = new List<String>{'id'};
	        if(isQuoteEnabled) {
        		oppFieldSet.add('SyncedQuoteId');
        	}	        
	        Opportunity syncedOpp = new Opportunity(Id = oppId);
	        syncedOpp.put('SyncedQuoteId', null);
	        toBeUpdatedOppsList.add(syncedOpp);
	        
	        //disbale all the triggers
	        CSM_TriggerManager.disableAllTriggers();
	        	
	        REN_OpportunityDataAccess.updateOpportunitySObject(toBeUpdatedOppsList,oppFieldSet);	        
	        retPage = deleteRLI();
	        if(retPage == null){
	        	Database.rollback(sp);
	        }
        }catch(Exception e){
        	ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,REN_Util.getGenericErrorMessage(e,''));
            ApexPages.addMessage(msg);
            retPage = null;
        }
        return retPage;       
    }
        
    /* This method is used to delete selected RLI if Quote is not synced to Opportunity. */
    
    public PageReference deleteRLI(){
        PageReference retPage;
        try{
            if(rliList != null && !rliList.isEmpty()){ 
            		//disbale all the triggers
	        		CSM_TriggerManager.disableAllTriggers();  
	        		           
                REN_RenewRelationshipDataAccess.deleteRenewalRelationship(rliList);                
                if(oppId != null){
        			REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(new Set<ID>{oppId});
        		}
        		retPage = new PageReference('/' + oppId);
        		isRecordDeleted = true;
            }
            
        }catch(Exception e){
        	ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,REN_Util.getGenericErrorMessage(e,''));
            ApexPages.addMessage(msg);
            retPage = null;
        } 
        return retPage;
       
    }
    
    /* This method is used to redirect user on selected RLI or Opportunity page. */

    public PageReference cancelAndReturnToOppt(){
        PageReference retPage;
        if(isRecordDeleted || (returnUrl != null && !returnUrl.contains('/home/'))){
        	retPage = (new PageReference('/' + oppId));
        }else{
        	retPage = new PageReference('/' + rliObj.id); 
        }          
        return retPage;
     }
}