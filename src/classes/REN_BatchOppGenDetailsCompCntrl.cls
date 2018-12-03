public with sharing class REN_BatchOppGenDetailsCompCntrl {
	
	public REN_Renew_Configuration__c renewConfig {get; set;}
	public REN_Renew_Configuration__c renewConfigRR {get; set;}
	public String queryFilter{get; set;}
	public Boolean isFilterWidget {get; set;}
	public String renConfigId {
		get; 
		set {
			if(value != null)
			{
				renConfigId = value;
				getRenewConfig();
				getFilterCriteria();
				
			}
		}
	}
	public String objType {
		get; 
		set {
			if(value != null)
			{
				objType = value;
				updatefilterval();
			}
		}
	}
	
	public	REN_BatchOppGenDetailsCompCntrl(){
		isFilterWidget =  false;
	}
	
	public REN_Renew_Configuration__c getRenewConfig(){
		if(String.isBlank(renConfigId) || renConfigId.trim() == '-'){
			renewConfig = null;
		}else{
			renewConfig = REN_RenewConfigurationDataAccess.getRenewConfigByIdy(renConfigId);
			this.renewConfigRR = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(renewConfig.REN_Record_Key__c+'_πRR');
			renewConfigRR = (renewConfigRR == null )? new REN_Renew_Configuration__c() : renewConfigRR;
		}
		return renewConfig;
	}
	
	public String getFilterCriteria(){
		String retCriteria = null;
		if(objType == 'filterWidget'){
			List<REN_Line_Criteria__c> renewCriList = REN_LineCriteriaDataAccess.getLineCriteriaListByConfig(renConfigId, null);
			REN_LogicBuilderValidationHelper helper = new REN_LogicBuilderValidationHelper();
			if(renewCriList != null && renewConfig != null){
				retCriteria = helper.buildWhereCriteriaString(renewCriList, renewConfig, true);
			}
			if(String.isNotBlank(renewConfigRR.REN_Record_Key__c) && String.isNotBlank(renewConfigRR.REN_Filter_Criteria__c)){
				renewCriList = REN_LineCriteriaDataAccess.getLineCriteriaListByConfig(renewConfigRR.id, null);
				if(renewCriList != null && renewConfigRR != null){
					String retCriteriaRR = helper.buildWhereCriteriaString(renewCriList, renewConfigRR, true);
					retCriteriaRR = ' Id IN (Select Asset From ' + Schema.SObjectType.REN_Renews_To__c.label + ' Where (' + retCriteriaRR + '))';
					if(String.isBlank(retCriteria)){
						retCriteria = retCriteriaRR;
					}else{
						retCriteria = retCriteria + ' AND ' +  retCriteriaRR;
					}
				}
			}
		}
		queryFilter = retCriteria;
		return retCriteria;
	}
	
	public List<String> getGroupCriteria(){
		List<String> retCriteriatemp = new List<String>();
		if(objType == 'groupWidget'){
			String retCriteria = '';
			List<REN_Line_Criteria__c> renewCriList = REN_LineCriteriaDataAccess.getLineCriteriaListByConfig(renConfigId, null);
			REN_LogicBuilderValidationHelper helper = new REN_LogicBuilderValidationHelper();
			System.debug(renewConfig + '\n\n0~~~~:objType: ' + objType);
	
			if(renewCriList != null && renewConfig != null){
				if(renewConfig.REN_Configuration_Type__c == REN_Constants.OBJ_RC_CTYPE_GROUPING){
					for(REN_Line_Criteria__c criteria : renewCriList){
						retCriteriatemp.add(criteria.RLM_Field_Display_Name__c);
					}
				}
			}
		}
		System.debug('\n\n2~~~~:objType: ' + objType);
		return retCriteriatemp;
	}
	
	public String getViewName(){
		String recKey = null;		
		if(renewConfig != null && renewConfig.REN_View_Name__c != null){
			recKey = renewConfig.REN_View_Name__c;
		}
		return recKey;
	}
	
	public String getDescription(){
		String descp = null;
		if(renewConfig != null && renewConfig.REN_Description__c != null){
			descp = renewConfig.REN_Description__c;
		}		
		return descp;
	}
	
	public String getRecordsReturned(){
		String recRet = null;
		String criteria;
		if(renewConfig != null && renewConfig.REN_Filter_Criteria__c != null){
			criteria = ' where (' + renewConfig.REN_Filter_Criteria__c + ') '; 
			if(String.isNotBlank(renewConfigRR.REN_Filter_Criteria__c)){
				criteria += ' AND Id IN (Select REN_Asset__c From REN_Renews_To__c  Where (' + renewConfigRR.REN_Filter_Criteria__c + '))';
			}else{
				criteria += ' AND Id Not IN (Select REN_Asset__c From REN_Renews_To__c)';
			}
		}
		try{
			Integer recCount = REN_AssetDataAccess.getAssetsCounts(criteria, 40001);
			if(recCount > 40000){
				recRet = 'Records Returned > 40,000';
			}
			else{
				recRet = 'Records Returned: ' + recCount;
			}
		}
		catch(Exception e){
			recRet = 'Records Returned: 0';
		}
		return recRet;		
	}
	
	public void updatefilterval(){
		if(objType == 'filterWidget'){
			isFilterWidget = true;
		}
	}
	

}