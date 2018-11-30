public with sharing class CHL_SyncingOptionController {
	
	public string syncingVaule{get;set;}
	public String channelNoAccessMsg {get; private set;}
	public string partnerOptyId{get;set;}
	public List<CHL_Partner_Opportunity__c> partnerOptyList;
	public string OptyId{get;set;}
	
	public Boolean hasChannelAccess {
        get;
        private set;
    }
    
 	public List<SelectOption> getsyncingOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(CHL_Constants.SYNCING_OPTION_TO_MO,Label.CHL_SYNCING_TO_MASTER_OPTY)); 
        options.add(new SelectOption(CHL_Constants.SYNCING_OPTION_FROM_MO,Label.CHL_SYNCING_FROM_MASTER_OPTY)); 
        options.add(new SelectOption(' ',Label.CHL_STOP_SYNCING)); 
        return options; 
    }
 	
 	public CHL_SyncingOptionController() { 		
        channelNoAccessMsg = SS_Constants.SS_NO_LICENSE_MSG;  
        hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;
        partnerOptyId = ApexPages.currentPage().getParameters().get('oppId'); 		        
 		Set<ID> poOptyIds = new set<ID>();
	    poOptyIds.add(partnerOptyId);
        partnerOptyList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataById(poOptyIds);
        if(partnerOptyList != null && !partnerOptyList.isEmpty()) {
        	this.syncingVaule = partnerOptyList[0].CHL_Syncing__c;
        	OptyId = partnerOptyList[0].CHL_Opportunity__c;
        }
 	}
 	
 	public PageReference Save() {
 		try {
	 		List<sObject> listToUpdate = new List<sObject>();
	 		if(partnerOptyList != null && !partnerOptyList.isEmpty()) {
	 			partnerOptyList[0].CHL_Syncing__c = this.syncingVaule; 
	 			listToUpdate.add(partnerOptyList[0]);
	 			CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(listToUpdate);
	 		}
	 		
 		}
    	catch(Exception ex){
    		system.debug('IN D ERROR : ');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			
		}
 		return null;
 	}
 	
 	public PageReference Cancel() {
 		return null;//new PageReference('/' + OptyId);
	}

}