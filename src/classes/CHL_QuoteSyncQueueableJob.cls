public class CHL_QuoteSyncQueueableJob implements Queueable  {
	List<CHL_Partner_Opportunity__c> partnerOppList;
    Set<ID> oppIdSet;

	public CHL_QuoteSyncQueueableJob(List<CHL_Partner_Opportunity__c> partnerOppList){
		this.partnerOppList = partnerOppList;
	}

	public void execute(QueueableContext context) {
		try{
			Set<Id> poIdSet = new Set<Id>();
			oppIdSet = new Set<Id>(); 
			List<String> oppIdList = new List<String>();
    		for(CHL_Partner_Opportunity__c po :  partnerOppList){
    			oppIdList.add(po.CHL_Opportunity__c);
    			oppIdSet.add(po.CHL_Opportunity__c);
    			poIdSet.add(po.id);
    		}
    		if(oppIdList != null && !oppIdList.isEmpty()){
	    	 	Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>(REN_OpportunityDataAccess.getOpportunityAllDetailsById(oppIdList));
	    	 	List<SObject> quoteList = CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIdSet, true, true);
	    	 	if(quoteList != null && !quoteList.isEmpty()) {
		    	 	Map<Id,SObject> quoteMap = new Map<Id,SObject>();
		    	 	for(SObject quoteObj : quoteList ){	    	 		
		    	 		quoteMap.put((ID)quoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'),quoteObj);
		    	 	}
		    	 	
		    	 	List<SObject> oppListUpdate = new List<SObject>();
		    	 	for(CHL_Partner_Opportunity__c poObj : partnerOppList){
	    	 			SObject oppObj  = oppMap.get(poObj.CHL_Opportunity__c);	    	 			
						SObject quoteObj = quoteMap.get(poObj.id);
						if(CSM_AccessController.hasField(CSM_Constants.OBJ_OPPORTUNITY, CHL_Constants.OBJ_OPP_SYNCE_QUOTE_ID)) {
							oppObj.put(CHL_Constants.OBJ_OPP_SYNCE_QUOTE_ID ,(ID)quoteObj.get('Id'));
						}
						oppListUpdate.add(oppObj);
	    	 			
		    	 	}
		    	 	REN_OpportunityDataAccess.updateOpportunityforRenewals(oppListUpdate);
    			}
    		}
		}catch(Exception e){
			CHL_Util.sendEmailNotificationWithUrl(CHL_Constants.QUOTES_SYNC_EMAIL_SUBJECT,CHL_Constants.QUOTES_SYNC_EMAIL_TEXT1,CHL_Constants.QUOTES_SYNC_EMAIL_TEXT2 + '\n' +label.CHL_LBL_REASON_FOR_FAILURE + e  , CHL_Constants.QUOTES_SYNC_EMAIL_FROM, oppIdSet);
		}
	}

}