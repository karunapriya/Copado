public with sharing class REN_OppRenewalAdminUpdateCompCntrl extends REN_BaseMainController{
	public Boolean hasServiceContract {get; private set;}
    public REN_Renew_Configuration__c renconfigobj{get;set;}
    
    public List<REN_LogicBuilderInputWrapper> lbInputWrapperList{get;set;}
    public List<REN_UpdateRuleWrapper> updateRuleWrapperList {get; set;}
    private Map<string,REN_Renew_Configuration__c> mapOfConfigKeyNConfigObj;
	
    public REN_OppRenewalAdminUpdateCompCntrl() {
    	super();
    	this.hasServiceContract = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);
        this.lbInputWrapperList = new List<REN_LogicBuilderInputWrapper>();
        init();
    }
    
    private void init(){
    	try{
    		Set<String> mappingKeySet = new Set<String>{REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,
    											REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT,
    											REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT,
    											REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT};
	    	mapOfConfigKeyNConfigObj = new Map<string, REN_Renew_Configuration__c>();
	    	List<REN_Renew_Configuration__c> renewConfigurationList =  REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(mappingKeySet);
    	    if(renewConfigurationList != null && !renewConfigurationList.isEmpty())	{
	    	    for(REN_Renew_Configuration__c renconfig:renewConfigurationList) {
	    	    	mapOfConfigKeyNConfigObj.put(renconfig.REN_Record_Key__c, renconfig);
	    	    }
    	    }
    	    retrieveDataFromRenewConfig();
    	    REN_LogicBuilderInputWrapper assetLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT), 
    	    									REN_Constants.OBJ_LC, 'Asset', REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT, false, this, system.Label.REN_LBL_ASSET_FIELDS
												, 'refreshLB3', 'onChangeDate3');
    	    this.lbInputWrapperList.add(assetLogicBuilderInputWrapper);
    	    REN_LogicBuilderInputWrapper cliLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT), 
    	    									REN_Constants.OBJ_LC, 'ContractLineItem', REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT, false, 
    	    									this, system.Label.REN_LBL_SCLI_FIELDS, 'refreshLB4', 'onChangeDate4');
    	    this.lbInputWrapperList.add(cliLogicBuilderInputWrapper);
	        
			cliLogicBuilderInputWrapper.isCurrencyOptionDisabled = true;
			assetLogicBuilderInputWrapper.dependentLogicBuilder = cliLogicBuilderInputWrapper;	        
	        
	        String checkValues= '';
	        updateRuleWrapperList = new List<REN_UpdateRuleWrapper>();
	        this.renconfigobj = mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
            if(this.renconfigobj != null && String.isNotBlank(this.renconfigobj.REN_Update_On__c)){
            	checkValues= this.renconfigobj.REN_Update_On__c;
            }
	        Set<String> savedRuleKeySet = new Set<String>(checkValues.split(';'));
	        
	        updateRuleWrapperList.add(new REN_UpdateRuleWrapper(Label.REN_OPP_UPDATE_CHANGE_ASSET, 
	        								REN_Constants.FLD_VAL_UPDATE_ON_ASSET_EX, 
	        								savedRuleKeySet.contains(REN_Constants.FLD_VAL_UPDATE_ON_ASSET_EX)));
	        if (this.hasServiceContract){
		        updateRuleWrapperList.add(new REN_UpdateRuleWrapper(Label.REN_OPP_CHANGE_SC_LI,
		        			'Contract Lines - Existing', 
		        			savedRuleKeySet.contains('Contract Lines - Existing')));
		        updateRuleWrapperList.add(new REN_UpdateRuleWrapper(Label.REN_OPP_NEW_SC_LINEITEM,
		        			'Contract Lines - New',
		        			savedRuleKeySet.contains('Contract Lines - New')));
	        }
    	}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
    }
    
    public void retrieveDataFromRenewConfig()
    {
		if(!mapOfConfigKeyNConfigObj.containskey(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY)) {
	    	this.renconfigobj = new REN_Renew_Configuration__c(REN_Record_Key__c = REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);	   
	    	mapOfConfigKeyNConfigObj.put(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,this.renconfigobj); 	    	
	    }
	    if(!mapOfConfigKeyNConfigObj.containskey(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT)) {
	    	this.renconfigobj = new REN_Renew_Configuration__c(REN_Record_Key__c = REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT);	  
	    	mapOfConfigKeyNConfigObj.put(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT,this.renconfigobj); 	     	    	
	    }
	    if(!mapOfConfigKeyNConfigObj.containskey(REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT)) {
	    	this.renconfigobj = new REN_Renew_Configuration__c(REN_Record_Key__c = REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT);	  
	    	mapOfConfigKeyNConfigObj.put(REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT,this.renconfigobj); 	     	    	
	    }
    }
    
    public PageReference save() {
    	try {
    		List<REN_Renew_Configuration__c> saveOpptyToRenewOppty = new List<REN_Renew_Configuration__c>();
    		this.renconfigobj = mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
    		this.renconfigobj.REN_Update_On__c= getUpdateRulesStr();
    		saveOpptyToRenewOppty.add(this.renconfigobj);
    		saveOpptyToRenewOppty = REN_RenewConfigurationDataAccess.saveRenewConfiguration(saveOpptyToRenewOppty);
    		saveConfigAndCriterias();
    		if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){ 
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 
										String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[]{'Renewal Opportunity '})));
    		}
    	}catch(system.DmlException dmlEx){
			if(!dmlEx.getDmlType(0).equals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, dmlEx.getMessage()));
			}
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
        return null;
    }

    public PageReference cancel() {
    	PageReference pageRef = Page.REN_OpportunityRenewalAdmin;
        return pageRef;
    }
    
    private void saveConfigAndCriterias(){
		Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
		for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
			if(baseChildController instanceof REN_LogicBuilderCmpCtrl){
				((REN_LogicBuilderCmpCtrl)baseChildController).performSave();
			}
		}
	}
	
    private String getUpdateRulesStr(){
    	String s ='';
    	for(REN_UpdateRuleWrapper wrapper: updateRuleWrapperList){
    		if(wrapper.isKeyRequiredToSaveInObject){
    			if(String.isEmpty(s)){
    				s = wrapper.checkboxKey;
    			}else{
    				s += ';' + wrapper.checkboxKey;
    			}
    		}
    	}
    	return s;
    }
    
	public with sharing class REN_UpdateRuleWrapper {
		public String checkBosxLabel{get;set;}
		public String checkboxKey{get;set;}
		public boolean isKeySavedInObject{get;set;}
		public boolean isKeyRequiredToSaveInObject{get;set;}
		public REN_UpdateRuleWrapper(String checkBosxLabel, String checkboxKey, boolean isKeySavedInObject) {
			this.checkBosxLabel = checkBosxLabel;
			this.checkboxKey = checkboxKey;
			this.isKeySavedInObject = isKeySavedInObject;
			this.isKeyRequiredToSaveInObject = isKeySavedInObject;
		}
	}
}