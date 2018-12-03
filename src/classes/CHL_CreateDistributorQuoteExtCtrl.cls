/**
 * Created Date     : Oct 27, 2016
 * Developed By     : Tanvi, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Tanvi                    User Story              Oct 27, 2016            1.1                 @description
 *
 */
public with sharing class CHL_CreateDistributorQuoteExtCtrl {
    
    public boolean isError{get;set;}
    public string quoteId;
    private String quoteExtnNameSpace;
	public string errMsg{get;set;}
	private List<sObject> quoteList;
    
    public CHL_CreateDistributorQuoteExtCtrl(ApexPages.StandardController sc) {
        quoteId = sc.getId();
        isError = false;
		boolean is2TierEnable = false;	
        List<ApexTrigger> tr =[select NamespacePrefix from ApexTrigger where Name like:'%CHL_QuoteLineItemTrigger%'];
        if (tr!=null && !tr.isEmpty()){
            quoteExtnNameSpace = (String.isNotBlank(tr[0].nameSpacePrefix) ?  tr[0].nameSpacePrefix + '__' :  '');
        }
		List<CHL_Opportunity_Status_Log__c> opptyStatusLogList = [select Id,CHL_Enable_2_Tier_Pricing__c from CHL_Opportunity_Status_Log__c limit 1 ];
		if(opptyStatusLogList != null && !opptyStatusLogList.isEmpty()) {
			is2TierEnable = opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
		}
		if(is2TierEnable == false) {
			isError = true;
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, '2-Tier Pricing is not enabled in the Organization.')); 
			errMsg = Label.CHL_ERR_TWO_TIER_PRICING;
		} else {                
			String quoteCustomFields = quoteExtnNameSpace+'CHL_Reseller_Quote__c,'+quoteExtnNameSpace+'CHL_Partner_Opportunity__c,'+quoteExtnNameSpace + 'CHL_Partner_Account_1__c,'+quoteExtnNameSpace + 'CHL_Partner_Account_2__c,'+quoteExtnNameSpace + 'CHL_Partner_Account_1_Type__c,'+quoteExtnNameSpace + 'CHL_Partner_Account_2_Type__c,'+quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c';
			String quoteQuery = 'select Id, name,OpportunityId,ShippingHandling,Tax,Pricebook2Id,'+quoteCustomFields+' from Quote where Id =:quoteId limit 1';
			quoteList = database.query(quoteQuery);                       
			system.debug('quoteId : '+quoteId);
			String poId = quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Opportunity__c' ) != null ? (String)quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') : '';
			if(String.isBlank(poId) || poId == null) {
				isError = true;
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Partner 1 and 2 must be populated before creating a Distributor Quote.')); 
				errMsg = Label.CHL_ERR_PARTNER_ACC_DISTRIBUTOR_QUOTE;
			} else {
				String partnerAcc1 = quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Account_1__c') != null ? (String)quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Account_1__c') : '';
				String partnerAcc2 = quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Account_2__c') != null ? (String)quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Account_2__c') : '';
				String partnerAcc1Type = quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Account_1_Type__c') != null ? (String)quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Account_1_Type__c') : '';
				String partnerAcc2Type = quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Account_2_Type__c') != null ? (String)quoteList[0].get(quoteExtnNameSpace + 'CHL_Partner_Account_2_Type__c') : '';
				if((String.isNotBlank(partnerAcc1Type) && String.isBlank(partnerAcc1)) || (String.isNotBlank(partnerAcc2Type) && String.isBlank(partnerAcc2))) {                    
					isError = true;
					errMsg = Label.CHL_ERR_PARTNER_ACC_DISTRIBUTOR_QUOTE;
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Partner 1 and 2 must be populated before creating a Distributor Quote.'));
				} else if((String.isBlank(partnerAcc1Type) && String.isNotBlank(partnerAcc1)) || (String.isBlank(partnerAcc2Type) && String.isNotBlank(partnerAcc2))) { 
					isError = true;
					errMsg = Label.CHL_ERR_PARTNER_ACC_DISTRIBUTOR_QUOTE;
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Partner 1 and 2 must be populated before creating a Distributor Quote.'));
				} else if(partnerAcc1Type !='Distributor' && partnerAcc2Type != 'Distributor') { 
					isError = true;
					errMsg = Label.CHL_ERR_NO_DISTRIBUTOR_QUOTE;
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Add a distributor partner to the quote before creating a Distributor Quote.'));
				} else if((Boolean)quoteList[0].get(quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c') == true) { 
					isError = true;
					errMsg =  Label.CHL_ERR_DISTRIBUTOR_QUOTE;
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'A Distributor Quote cannot be created from another  Distributor Quote.'));
				} else {
					quoteQuery = 'select Id from Quote where CHL_Reseller_Quote__c =:quoteId AND CHL_Partner_Opportunity__c =:poId limit 1';
					List<sObject> distribQuoteList = database.query(quoteQuery);    
						
					if(distribQuoteList != null && !distribQuoteList.isEmpty()) {
						isError = true;
						errMsg =  Label.CHL_ERR_DUPLICATE_DISTRIBUTOR_QUOTE;
						//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'A Distributor Quote already exists for this quote.'));
					}
				}
			}
		}
    }
    
    public PageReference CreateQuote(){
        	
        Set<Id> quoteIds = new Set<Id>();
        Savepoint sp;
        isError = false;
        PageReference detailPage = null;
        sp = Database.setSavepoint(); 
        try {
            CSM_TriggerManager.disableAllTriggers();
			quoteIds.add((Id)quoteList[0].get('Id'));
			isError = false;
			BasePackageParam params = new BasePackageParam();
			params.sObjIds = quoteIds;
			params.className = 'CHL_QuoteExtension';
			params.methodName = 'createDistributorQuotesAndQlis';
			SS_BasePackageAccess.getInstance().paramJson = JSON.serialize(params);
			SS_BasePackageAccess.getInstance().invoke();
			List<Quote> distributorQuote = [Select Id From Quote Where CHL_Reseller_Quote__c IN:quoteIds Order By CreatedDate DESC LIMIT 1];
			if(distributorQuote != null && !distributorQuote.isEmpty()){
				detailPage = new PageReference('/'+distributorQuote[0].Id);
			}
                    
        }
        catch(Exception ex){
            Database.rollback(sp);
            isError = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);
            //return null;
         }
         //PageReference pageRef = ApexPages.currentPage();
        //pageRef.setRedirect(true);
        return detailPage;
    }
	
	public pageReference returnToQuote() {
		return new PageReference('/'+quoteId);
	}
    
    public Static Set<String> getAssignedCustomPermissions() {
        Set<String> assignedCustomPermissions = new Set<String>();
        BasePackageParam params = new BasePackageParam();
        params.className = 'SS_LicenseCheck';
        params.methodName = 'retrieveAssignedCustomPermissions';
        SS_BasePackageAccess.getInstance().paramJson = JSON.serialize(params);
        String value = SS_BasePackageAccess.getInstance().invoke();
        if(String.isNotBlank(value)){
            assignedCustomPermissions = (Set<String>)JSON.deserialize(value, Set<String>.class);
        }
        return assignedCustomPermissions ;
    
    }
    
    public class BasePackageParam {
        public Set<Id> sObjIds;
        public String className;
        public String methodName;
    }
}