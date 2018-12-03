public with sharing class CHL_QuoteSyncProcessController{

    public list<Quote> selectedquoteId{get; set;}
    public String oppID{get; set;}
	public boolean isError{get;set;}
	public string errMsg{get;set;}
    
    public CHL_QuoteSyncProcessController(ApexPages.StandardSetController controller) {
        oppID = ApexPages.currentPage().getParameters().get('id');		
        isError = false;
        selectedquoteId=controller.getSelected() ;
        if(selectedquoteId.size()>=2){
            isError = true;  
			errMsg = Label.selected_more_than_one_quote_to_sync;
        }else if(selectedquoteId.size()<=0){
            isError = true;
			errMsg = Label.selected_none_to_sync;
        }else{
            list<Quote> Q= [Select IsSyncing from Quote where id=:selectedquoteId];
            if(Q[0].IsSyncing){
                isError = true;
				errMsg = Label.selected_quote_already_synced;
            }
        }
        //system.debug('yes in con'+selectedquoteId);
    }
    
    public PageReference Quotesyncprocess(){
        list<Opportunity> updatedOpptyList = new List<Opportunity>();
        //List<Opportunity> oldOpptyList = new List<Opportunity>();
		Set<Id> quoteIds = new Set<Id>();
        PageReference detailPage=null;
        Savepoint sp = Database.setSavepoint();
        isError = false;
        try{
            CSM_TriggerManager.disableAllTriggers();
			Id opptySyncedQuoteId = (Id)selectedquoteId[0].get('Id');
			quoteIds.add(opptySyncedQuoteId);
			CHL_CreateDistributorQuoteExtCtrl.BasePackageParam params = new CHL_CreateDistributorQuoteExtCtrl.BasePackageParam();
			params.sObjIds = quoteIds;
			params.className = 'CHL_QuoteExtension';
			params.methodName = 'syncQuoteFromOpportunity';
			SS_BasePackageAccess.getInstance().paramJson = JSON.serialize(params);
			SS_BasePackageAccess.getInstance().invoke();
			updatedOpptyList = [select id,SyncedQuoteid from Opportunity where id =:oppID AND SyncedQuoteid =:opptySyncedQuoteId limit 1];
			if(updatedOpptyList != null && !updatedOpptyList.isEmpty()){
				detailPage = new PageReference('/' + oppID);
			}
            if(!ApexPages.hasMessages()){   
                detailPage = new PageReference('/' + oppID);
            }else{
                Database.rollback(sp);
            }
        } catch(exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        return detailPage;
    }
}