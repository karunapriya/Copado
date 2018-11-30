public with sharing class REN_LT_EmailTemplateController {
	
	public String OpptId{get;set;}
        
    public Opportunity oppty {
    	get {
			List<Opportunity> OptyList = REN_OpportunityDataAccess.getOpportunitySyncQuote(new Set<String>{OpptId});
			return OptyList[0];    		
    	}
    	set;
    }
    public string orderNumber{
        get {
        	Opportunity opp = this.oppty;
	        if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c')){
	              orderNumber = opp != null  ? (String)opp.get(CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c') : '';
	        }
	         return orderNumber;
        }
        set;
	}
    	
}