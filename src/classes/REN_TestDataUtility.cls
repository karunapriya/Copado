@isTest
public class REN_TestDataUtility {

	public static Product2 createProduct(Integer index){
		Product2 prod = new Product2();
		prod.Name = 'Test Product' + index;
		prod.IsActive = true;
		prod.ProductCode = 'IN7080' + index;
		return prod;
	}
	
	public static Asset createAsset(Id accountId, Id productId){
		Asset asset = new Asset();
		asset.AccountId = accountId;
		asset.Product2Id = productId;
		asset.Name = 'Test Asset';
		asset.Price = 20.00;
		asset.Quantity = 2;
		return asset;
	}
	
	public static PricebookEntry createPBEntry(Id productId){
		PricebookEntry pbe = new PricebookEntry();
		pbe.Product2Id = productId;
		pbe.Pricebook2Id = Test.getStandardPricebookId();
		pbe.UnitPrice = 99;
		pbe.IsActive = true;
		return pbe;
	}
	
	public static REN_Line_Criteria__c createLineCriteria(String recName,String criteria,String objApiName, String fldName, String fldType,String value,
															Date dateVal,String operator,Boolean specDate, String datLitString,Integer datNumber,ID rConfigID, Datetime dateTimeVal){
		REN_Line_Criteria__c lineCriteriaObj = new REN_Line_Criteria__c();
		lineCriteriaObj.Name = recName;
		lineCriteriaObj.RLM_Criteria__c = criteria;
		lineCriteriaObj.RLM_Object_API_Name__c = objApiName;
		lineCriteriaObj.RLM_Field_Name__c = fldName;
		lineCriteriaObj.RLM_Field_Type__c = fldType;
		lineCriteriaObj.RLM_Values__c = value;
		lineCriteriaObj.RLM_Date_Value__c = dateVal;
		lineCriteriaObj.RLM_Operator__c = operator;
		lineCriteriaObj.RLM_Is_Specific_Date__c = specDate;
		lineCriteriaObj.RLM_Date_Literal_String__c = datLitString;
		lineCriteriaObj.RLM_Date_Literal_Number__c = datNumber;
		lineCriteriaObj.RLM_DateTime_Value__c = dateTimeVal;
		lineCriteriaObj.REN_Renew_Configuration__c = rConfigID;
		
		return lineCriteriaObj;
	}
	/*
	public static REN_Renew_Configuration__c createRenewConfiguration(String triggerType, String name){
		REN_Renew_Configuration__c renewConfig = new REN_Renew_Configuration__c(Name = name, 
											REN_Is_Active__c = true
											);
		return renewConfig;
	}
	*/
	public static REN_Field_Mappings__c createFieldMapping(String mappingName, String dataType, 
													String toName, String fromName, String toObject, 
													String fromObject, Boolean isRequired, 
													String defaultValue) {
		REN_Field_Mappings__c fm = new REN_Field_Mappings__c();
		fm.name = mappingName;
		//fm.REN_Renew_Configuration__c = rcRenewalId;
		fm.REN_Field_Data_Type__c = dataType;
		fm.REN_To_Field_API_Name__c = toName;
		fm.REN_From_Field_API_Name__c = fromName;
		fm.REN_To_Object_API_Name__c = toObject;
		fm.REN_From_Object_Api_Name__c = fromObject;
		fm.REN_Is_Required__c = isRequired;
		fm.REN_Default_Value__c = defaultValue;
		return fm;
	}
	public static List<REN_Renew_Configuration__c> createRenewConfigurationDatalist(){
		List<REN_Renew_Configuration__c> renconfiglst = new List<REN_Renew_Configuration__c>();
		Map<String, REN_Renew_Configuration__c> renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
		List<REN_Renew_Configuration__c> renewConfigurationList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(null);
    	system.assert(true);
    	if(renewConfigurationList != null){
        	for(REN_Renew_Configuration__c rConfig: renewConfigurationList){
        		renewConfigurationMap.put(rConfig.REN_Record_Key__c, rConfig);
        	}
    	}		
    	
    	renconfiglst.add(createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,'StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c=false', renewConfigurationMap));
		renconfiglst.add(createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET,'StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c=false', renewConfigurationMap));
		renconfiglst.add(createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT,'StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c=false', renewConfigurationMap));
		renconfiglst.add(createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT,'',renewConfigurationMap));
		renconfiglst.add(createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT,'', renewConfigurationMap));
		renconfiglst.add(createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT,'', renewConfigurationMap));
		renconfiglst.add(createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET,'', renewConfigurationMap));
		renconfiglst.add(createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM,'', renewConfigurationMap));
		//insert renconfiglst;
		return renconfiglst;
	}
	
	public static REN_Renew_Configuration__c createRenewConfigurationbyRecordKey(String recordKey, String filterCondition, Map<String, REN_Renew_Configuration__c> renewConfigurationMap){
		string renUpdateOn = '';
		if(recordKey == REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY)	{
	    		renupdateon = 'Asset - Existing;Contract Lines - Existing;Contract Lines - New';
    	}
    	REN_Renew_Configuration__c renewConfig = renewConfigurationMap.get(recordKey);
    	if(renewConfig == null){
    		renewConfig = new REN_Renew_Configuration__c();
    	}
		//renewConfig.Name = recordKey;
		renewConfig.REN_Record_Key__c = recordKey; 
		renewConfig.REN_Is_Active__c = true;
		renewConfig.REN_Update_On__c = renUpdateOn;
		renewConfig.REN_Filter_Criteria__c = filterCondition;
		return renewConfig;
	}
}