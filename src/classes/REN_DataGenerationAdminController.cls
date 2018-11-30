public with sharing class REN_DataGenerationAdminController extends REN_BaseMainController{

	public Boolean hasRenewAccess {get; private set;}
	public Boolean hasServiceContract {get; private set;}
	public String retUrl{get;set;}
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
    public Map<string,REN_Renew_Configuration__c> mapofConfigKeyNConfigObj{get;set;}    
    public String oppToAsset {get; set;}
    public String oppToSC {get; set;}
    public String CorpCurrencyCode{get;set;}
    public List<REN_LogicBuilderInputWrapper> lbInputWrapperList{get;set;}
    private REN_Renew_Configuration__c renconfigobj;
	
	public REN_DataGenerationAdminController(){
		super();
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        PageReference pageRef = Page.REN_DataGenerationAdmin;
        retURL = pageRef.getURL();
	    helpParam = CSM_Constants.HELP_INSTALL_BASE_DATA_RULE;
	    this.hasServiceContract = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);
        this.oppToAsset = REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET;
        this.oppToSC=REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT;
        this.lbInputWrapperList = new List<REN_LogicBuilderInputWrapper>();
        CorpCurrencyCode=CSM_Util.getCorpCurrency();
		
		this.renconfigobj = new REN_Renew_Configuration__c();
		Set<String> opportunityGenerationSet=new Set<String>{REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET,REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET,REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT,REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM};
	    	mapofConfigKeyNConfigObj = new Map<string, REN_Renew_Configuration__c>();
	    	List<REN_Renew_Configuration__c> renewConfigurationList =  REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(opportunityGenerationSet);
    	    if(renewConfigurationList != null && !renewConfigurationList.isEmpty())	{
	    	    for(REN_Renew_Configuration__c renconfig:renewConfigurationList)	{
	    	    	mapofConfigKeyNConfigObj.put(renconfig.REN_Record_Key__c,renconfig);
	    	    }
    	    }
    	    retrieveDataFromRenewConfig();
    	    
    	    REN_LogicBuilderInputWrapper oppLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET), 
									REN_Constants.OBJ_LC, 'Opportunity', REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET, false, this, ''
									, 'refreshLB1', 'onChangeDate1');
    	    this.lbInputWrapperList.add(oppLogicBuilderInputWrapper);
    	    
    	    REN_LogicBuilderInputWrapper oliLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET), 
    									REN_Constants.OBJ_LC, 'Product2', REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET, false, this, 
    									system.Label.REN_LBL_PRODUCTS, 'refreshLB2', 'onChangeDate2');
    	    
    	    this.lbInputWrapperList.add(oliLogicBuilderInputWrapper);
    									
    		REN_LogicBuilderInputWrapper cliLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM), 
    									REN_Constants.OBJ_LC, 'Product2', REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM, false, 
    									this, system.Label.REN_LBL_PRODUCTS, 'refreshLB3', 'onChangeDate3');							
    	    this.lbInputWrapperList.add(cliLogicBuilderInputWrapper);
    	    
			oliLogicBuilderInputWrapper.isCurrencyOptionDisabled = true;
			oppLogicBuilderInputWrapper.dependentLogicBuilder = oliLogicBuilderInputWrapper;
			cliLogicBuilderInputWrapper.isCurrencyOptionDisabled = true;
			oliLogicBuilderInputWrapper.dependentLogicBuilder = cliLogicBuilderInputWrapper;
    	    
	}
	
	public void retrieveDataFromRenewConfig()
    {
		if(!mapOfConfigKeyNConfigObj.containskey(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET)) {
	    	this.renconfigobj = new REN_Renew_Configuration__c(REN_Record_Key__c = REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);	   
	    	mapOfConfigKeyNConfigObj.put(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET,this.renconfigobj); 	    	
	    }
	    if(!mapOfConfigKeyNConfigObj.containskey(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT)) {
	    	this.renconfigobj = new REN_Renew_Configuration__c(REN_Record_Key__c = REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT);	  
	    	mapOfConfigKeyNConfigObj.put(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT,this.renconfigobj); 	     	    	
	    }
	    if(!mapOfConfigKeyNConfigObj.containskey(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET)) {
	    	this.renconfigobj = new REN_Renew_Configuration__c(REN_Record_Key__c = REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET);	  
	    	mapOfConfigKeyNConfigObj.put(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET,this.renconfigobj); 	     	    	
	    }
	    if(!mapOfConfigKeyNConfigObj.containskey(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM)) {
	    	this.renconfigobj = new REN_Renew_Configuration__c(REN_Record_Key__c = REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM);	  
	    	mapOfConfigKeyNConfigObj.put(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM,this.renconfigobj); 	     	    	
	    }
    }
	
	public PageReference saveDataGeneration(){
		try {
			saveFieldMappings();
			if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){ 
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 
										String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[]{'Install Base Data Rules '})));
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
	
	public PageReference cancel(){
		PageReference pageRef = Page.CSM_Admin;
	    pageRef.getParameters().put('tabCategory', 'Renewal');
	    pageRef.setRedirect(true);
	    return pageRef;
	}

	public PageReference manageMappings(){
		PageReference pageRef = Page.ren_renewalmappings;
	    pageRef.getParameters().put('tabCategory', 'Renewal');
	    pageRef.setRedirect(true);
	    return pageRef;
	}
	
	private void saveFieldMappings(){
		Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
		for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
			if(baseChildController instanceof REN_LogicBuilderCmpCtrl){
				// DE715 fix
				REN_LogicBuilderCmpCtrl logicBuilder = (REN_LogicBuilderCmpCtrl)baseChildController;
				if(logicBuilder.logicBuilderInput.logicBuilderExtName.equalsIgnoreCase(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET)){
					REN_Renew_Configuration__c renConfig = mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
					if(renConfig.REN_Is_Active__c){
						logicBuilder.performSave();
					}
				}else if(logicBuilder.logicBuilderInput.logicBuilderExtName.equalsIgnoreCase(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM)){
					REN_Renew_Configuration__c renConfig = mapOfConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT);
					if(renConfig.REN_Is_Active__c){
						logicBuilder.performSave();
					}
				}else{
					logicBuilder.performSave();
				}
				// DE715 fix end.
			}
		}
		copyCriteriaInOppToSC();
	}
	
	private void copyCriteriaInOppToSC() {
		REN_Renew_Configuration__c assetRenConfigurationObj = mapofConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
		REN_Renew_Configuration__c renSCObjToUpdate = mapofConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT);
		renSCObjToUpdate.RLM_Filter_Logic__c = assetRenConfigurationObj.RLM_Filter_Logic__c;
		renSCObjToUpdate.REN_Filter_Criteria__c = assetRenConfigurationObj.REN_Filter_Criteria__c;
		renSCObjToUpdate.RLM_Currency_Code__c = assetRenConfigurationObj.RLM_Currency_Code__c;
		//Fix for DE492 start
		REN_Renew_Configuration__c productToAssetRenConfigurationObj = mapofConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET);
		REN_Renew_Configuration__c prodToCliConfig = mapofConfigKeyNConfigObj.get(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM);
		productToAssetRenConfigurationObj.REN_Is_Active__c = assetRenConfigurationObj.REN_Is_Active__c;
		prodToCliConfig.REN_Is_Active__c = renSCObjToUpdate.REN_Is_Active__c;
		REN_RenewConfigurationDataAccess.saveRenewConfiguration(new List<REN_Renew_Configuration__c>{renSCObjToUpdate, productToAssetRenConfigurationObj, prodToCliConfig});
		//End 
		List<REN_Line_Criteria__c> lineCriteriaSCList = REN_LineCriteriaDataAccess.getLineCriteriaListByConfig(renSCObjToUpdate.id,
																										REN_Constants.OBJ_OPPORTUNITY);
		REN_LineCriteriaDataAccess.deleteLineCriteria(lineCriteriaSCList);
		List<REN_Line_Criteria__c >lineCriteriaAssetList = new List<REN_Line_Criteria__c>();
		List<REN_Line_Criteria__c> lineCriteriaList = REN_LineCriteriaDataAccess.getLineCriteriaListByConfig(assetRenConfigurationObj.id,
																											REN_Constants.OBJ_OPPORTUNITY);
		for(REN_Line_Criteria__c lineCL : lineCriteriaList)
   		{
   			REN_Line_Criteria__c lc = new REN_Line_Criteria__c();
   			lc = lineCL.clone(false, true);
   			lc.REN_Renew_Configuration__c = renSCObjToUpdate.id;
   			lineCriteriaAssetList.add(lc);
   		}				
   		REN_LineCriteriaDataAccess.upsertLineCriterias(lineCriteriaAssetList);
	}
}