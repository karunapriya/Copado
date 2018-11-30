/** 
 * @date        06.08.2015
 * @description Used to fetch data from CSM_TriggerEnablement custom settings.
 */

public with sharing class CSM_TriggerEnablementDataAccess {
	
	private CSM_TriggerEnablementDataAccess() {}
	private static CSM_TriggerEnablementDataAccess singletonInstance;
	private CSM_TriggerEnablement__c triggerConfig;
	public static final String AccountPlanPlaybookTrigger = 'CSM_AccountPlan_PlaybookTrigger__c';
	public static final String AccountPlanTrigger = 'CSM_AccountPlanTrigger__c';
	public static final String AccountTrigger = 'CSM_AccountTrigger__c';
	public static final String AssetTrigger = 'REN_AssetTrigger__c';
	public static final String AttachmentTrigger = 'REN_AttachmentTrigger__c';
	public static final String BatchFilterTrigger = 'CSM_BatchFilterTrigger__c';
	public static final String CaseTrigger = 'CSM_CaseTrigger__c';
	public static final String OpportunityLineItemsTrigger = 'REN_OpportunityLineItemsTrigger__c';
	public static final String OpportunityTrigger = 'CSM_OpportunityTrigger__c';
	public static final String PartnerOpportunityTrigger = 'CHL_PartnerOpportunityTrigger__c';
	public static final String PartnerRenewableLineItemTrigger = 'CHL_PartnerRenewableLineItemTrigger__c';
	public static final String PlaybookPlayTrigger = 'CSM_PlaybookPlayTrigger__c';
	public static final String PlaybookTrigger = 'CSM_PlaybookTrigger__c';
	public static final String PlayResultTrigger = 'CSM_PlayResultTrigger__c';
	public static final String PortalGroupTrigger = 'CHL_PortalGroupTrigger__c';
	public static final String QuoteLineItemTrigger = 'CHL_QuoteLineItemTrigger__c';
	public static final String QuoteTrigger = 'CHL_QuoteTrigger__c';
	public static final String ServiceContractTrigger = 'REN_ServiceContractTrigger__c';
	public static final String RenewalRelationshipTrigger = 'REN_RenewalRelationshipTrigger__c';
	public static final String ScoutCustomerTrigger = 'CSM_ScoutCustomerTrigger__c';
	public static final String SuccessPlanPlayTrigger = 'CSM_SuccessPlanPlayTrigger__c';
	public static final String TaskTrigger = 'CSM_TaskTrigger__c';
	public static final String UserTrigger = 'CHL_UserTrigger__c';
	public static final String LeadTrigger = 'CSM_LeadTrigger__c';
	public static final String ContractLineItemTrigger = 'CSM_ContractLineItemTrigger__c';
	
	public static CSM_TriggerEnablementDataAccess getInstance(){
		if(singletonInstance == null){
			singletonInstance = new CSM_TriggerEnablementDataAccess();
		}
		return singletonInstance;
	}
	
	public Boolean byPassDataloadValidation {
		get {
			if(this.byPassDataloadValidation == null){
				this.triggerConfig = this.triggerConfig == null 
									? getTriggerEnablementSettings() 
									: this.triggerConfig;
				this.byPassDataloadValidation = triggerConfig.CLM_Bypass_Data_Load_Validation__c == null 
												? false 
												: triggerConfig.CLM_Bypass_Data_Load_Validation__c;					
			}
			return this.byPassDataloadValidation;
		}
		private set;
	}
	
	public Boolean isTriggerEnabled(String triggerName) {
		this.triggerConfig = this.triggerConfig == null 
							? getTriggerEnablementSettings() 
							: this.triggerConfig;
		Boolean isEnabled = (Boolean)triggerConfig.get(triggerName);
        isEnabled = isEnabled == null? true : isEnabled;
        return isEnabled;
	}
    
    private CSM_TriggerEnablement__c getTriggerEnablementSettings() {
    	// Retrieve default enable application values from custom settings
    	CSM_TriggerEnablement__c triggerEnablementSettings;
        CSM_TriggerEnablement__c triggerEnablementUser = CSM_TriggerEnablement__c.getInstance(UserInfo.getUserId());
        if (triggerEnablementUser != null) { 
            triggerEnablementSettings =  triggerEnablementUser;
        } 
        
        return triggerEnablementSettings;
    }
}