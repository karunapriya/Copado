public with sharing class OLIDeleteExController {
    public Boolean isRecordDeleted {get;set;}
    public Boolean isQuoteEnabled {get;set;}
    public Boolean isSyncedQuotePresent {get;set;}
    public String isSyncedQuotePresentStr{get{ return '' + isSyncedQuotePresent;}}
    public List<OpportunityLineItem> oliList;
    private String returnUrl;
    private OpportunityLineItem oliObj;
    public ID oppId{get;set;}
    
    public OLIDeleteExController(ApexPages.StandardController stdController){
        oliObj = (OpportunityLineItem)stdController.getRecord();
        isSyncedQuotePresent = false;
        isRecordDeleted = false;
        returnUrl = ApexPages.currentPage().getParameters().get('retURL');
        Set<String> oliCrudFldSet = new Set<String>{'id','OpportunityId'};
        //Set<String> oliFldSet = new Set<String>{'id','OpportunityId', 'SyncedQuoteId'};
        Set<String> oliFldSet = new Set<String>{'id','OpportunityId','Opportunity.SyncedQuoteId'};
        
        /* Getting list of OLIs. */ 
        oliList = Util.getOpptyLineItemsById(new Set<Id>{oliObj.id}, oliFldSet, oliCrudFldSet) ;   
        if(oliList != null && !oliList.isEmpty()){
            oppId =  oliList[0].OpportunityId;
            if(oliList[0].Opportunity.get('SyncedQuoteId') != null){            
                isSyncedQuotePresent = true;
            }
        }
    }
    
    /* This method is used to remove synced quote on the Opportunity and delete selected OLI. */
    
    public PageReference removeSyncedQuote(){
        PageReference retPage;
        Savepoint sp = Database.setSavepoint();
        try{
            List<Opportunity> toBeUpdatedOppsList = new List<Opportunity>() ;
            List<String> oppFieldSet = new List<String>{'id', 'SyncedQuoteId'};
            
            Opportunity syncedOpp = new Opportunity(Id = oppId);
            syncedOpp.put('SyncedQuoteId', null);
            toBeUpdatedOppsList.add(syncedOpp); 
            Util.updateSObject('Opportunity', toBeUpdatedOppsList,oppFieldSet);         
            retPage = deleteOLI();
            if(retPage == null){
                Database.rollback(sp);
            }
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(msg);
            retPage = null;
        }
        return retPage;       
    }
        
    /* This method is used to delete selected OLI if Quote is not synced to Opportunity. */
    
    public PageReference deleteOLI(){
        PageReference retPage;
        try{
        	CSM_TriggerManager.disableAllTriggers();
            if(oliList != null && !oliList.isEmpty()){              
                List<String> fieldList = new List<String>{'OpportunityId', 'Name', 'Id'};
                Util.checkCRUD_FLS('OpportunityLineItem', fieldList, Constants.DML_OPERATION_DELETE);               
                delete oliList;             
                //Code to access base package methods
                BasePackageParam params = new BasePackageParam ();
	            params.sObjIds = new set<Id>{oppId};
	            params.className = 'REN_OpportunityLineItemRenewalHandler';
	            params.methodName = 'oliAfterTriggerEvent';
	            SS_BasePackageAccess.getInstance().paramJson = JSON.serialize(params);
	            SS_BasePackageAccess.getInstance().invoke(); 
                retPage = new PageReference('/' + oppId);
                isRecordDeleted = true;
            }
            
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
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
            retPage = new PageReference('/' + oliObj.id); 
        }          
        return retPage;
     }
     
     //Wrapper
     public class BasePackageParam {
        public Set<Id> sObjIds;
        public String className;
        public String methodName;
    }
}