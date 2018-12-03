public with sharing class TriggerEnablement {
	private TriggerEnablement() {}
	private static TriggerEnablement singletonInstance;
	private CSM_TriggerEnablement__c triggerConfig;
	public static final String AccountTrigger = 'Account_Trigger__c';
	public static final String OperationsTargetTrigger = 'OperationsTarget_Trigger__c';	
	public static final String PeerReviewTrigger = 'PeerReview_Trigger__c';	
	public static final String ProactiveRuleLineItemTrigger = 'ProactiveRule_LineItem_Trigger__c';
	public static final String ProactiveRuleTrigger = 'ProactiveRule_Trigger__c';
	public static final String SalesTargetTrigger = 'SalesTarget_Trigger__c';
	public static final String UserTrigger = 'User_Trigger__c';
							
	public static TriggerEnablement getInstance(){
		if(singletonInstance == null){
			singletonInstance = new TriggerEnablement();
		}
		return singletonInstance;
	}
	
	public Boolean byPassDataloadValidation {
		get {
			if(this.byPassDataloadValidation == null){
				this.triggerConfig = this.triggerConfig == null 
									? getTriggerEnablementSettings() 
									: this.triggerConfig;
				this.byPassDataloadValidation = (Boolean)triggerConfig.get('CLM_Bypass_Data_Load_Validation__c');
				this.byPassDataloadValidation = this.byPassDataloadValidation == null? false : this.byPassDataloadValidation;
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