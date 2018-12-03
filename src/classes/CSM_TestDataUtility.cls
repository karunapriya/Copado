/**
	Test class support class
**/
public class CSM_TestDataUtility {
	public static Boolean associateRenewalOppty = false;
	
    public static List<CSM_Account_Plan_Template__c> createAccountPlanTemplateData(Integer recordCount) {
    	
    	List<CSM_Account_Plan_Template__c> tmpList = new List<CSM_Account_Plan_Template__c>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for(Integer i=1; i <= recordCount; i++)
    	{
    		CSM_Account_Plan_Template__c newTemplate = new CSM_Account_Plan_Template__c();
    		newTemplate.CSM_Template_Name__c = 'AccountPlanTemplate ' + i;
    		newTemplate.CSM_isActive__c = true;
    		newTemplate.CSM_Opp_Date__c='CloseDate';
    		newTemplate.CSM_Opp_Dates_TimeLines__c='LastActivityDate;CreatedDate';
    		tmpList.add(newTemplate);
    	}
    	insert tmpList;
    	return tmpList;
        // TO DO: implement unit test
    }
    
    public static CSM_TriggerEnablement__c enableAllTriggers(){
    	CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
		cTriggerEnablement.CSM_AccountPlanTrigger__c = true;
		cTriggerEnablement.CSM_AccountTrigger__c = true;
		cTriggerEnablement.REN_AssetTrigger__c = true;
		cTriggerEnablement.CSM_CaseTrigger__c = true;
		cTriggerEnablement.CSM_OpportunityTrigger__c = true;
		cTriggerEnablement.CSM_PlayResultTrigger__c = true;
		cTriggerEnablement.CSM_TaskTrigger__c = true;
		cTriggerEnablement.REN_RenewalRelationshipTrigger__c  = true;
		cTriggerEnablement.CSM_ScoutCustomerTrigger__c  = true;		
		cTriggerEnablement.CHL_PartnerOpportunityTrigger__c = true;
		cTriggerEnablement.CSM_PlaybookPlayTrigger__c = true;
		cTriggerEnablement.CHL_UserTrigger__c = true;
		cTriggerEnablement.CSM_AccountPlan_PlaybookTrigger__c = true;
		cTriggerEnablement.CSM_SuccessPlanPlayTrigger__c = true;		
		upsert cTriggerEnablement;
		
		return cTriggerEnablement;
    }
    
    public static List<CSM_Account_Plan_Phase__c> createAccountPlanPhaseData(Integer recordCount, String templateId)
    {
    	List<CSM_Account_Plan_Phase__c> tmpList = new List<CSM_Account_Plan_Phase__c>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for(Integer i=1; i <= recordCount; i++)
    	{
    		CSM_Account_Plan_Phase__c newTemplate = new CSM_Account_Plan_Phase__c();
    		newTemplate.CSM_Phase_Name__c = 'Phase ' + i;
    		newTemplate.CSM_Order__c = i;
    		newTemplate.CSM_Length__c = 10;
    		newTemplate.CSM_Account_Plan_Template__c = templateId;
    		tmpList.add(newTemplate);
    	}
    	insert tmpList;
    	return tmpList;
    }
    
    public static List<CSM_Account_Plan_Playbook__c> createAccountPlanPlaybookData(String accountPlanId, String templateId, List<String> playbookIdList)
    {
    	//CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;
    	
    	List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
    	for(String s : playbookIdList)
    	{
    		CSM_Account_Plan_Playbook__c newAccountPlanPlaybook = new CSM_Account_Plan_Playbook__c();
    		newAccountPlanPlaybook.CSM_Playbook__c = s;
    		newAccountPlanPlaybook.CSM_IsActive__c = true;
    		if(!String.isEmpty(templateId))
    		{
    			newAccountPlanPlaybook.CSM_Account_Plan_Template__c = templateId;
    		}
    		if(!String.isEmpty(accountPlanId))
    		{
    			newAccountPlanPlaybook.CSM_Account_Plan__c = accountPlanId;
    		}
    		tmpList.add(newAccountPlanPlaybook);
    	}
    	insert tmpList;
    	return tmpList;
    }
    public static List<CSM_SuccessPlan_Play__c> createAccountPlanPlayData(List<String> playList, String playbookPlayId, String successPlanPlaybook)
    {
    	List<CSM_SuccessPlan_Play__c> tmpList = new List<CSM_SuccessPlan_Play__c>();
    	CSM_SuccessPlan_Play__c succPlanPlay;
    	for(String play : playList) {
    		succPlanPlay = new CSM_SuccessPlan_Play__c();
    		succPlanPlay.CSM_Play__c = (Id)play;
			succPlanPlay.CSM_Playbook_Play__c = (Id)playbookPlayId;
			succPlanPlay.CSM_SuccessPlan_Playbook__c = (Id)successPlanPlaybook;
			tmpList.add(succPlanPlay);
    	}
    	insert tmpList;
    	return tmpList;
    }
    public static List<CSM_Playbook__c> createPlaybooks(Integer recordCount)
    {
    	List<CSM_Playbook__c> tmpList = new List<CSM_Playbook__c>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for(Integer i=1; i <= recordCount; i++)
    	{
    		CSM_Playbook__c newPlaybook = new CSM_Playbook__c();
    		newPlaybook.CSM_isActive__c = true;
    		newPlaybook.CSM_Automated__c = false;
    		newPlaybook.CSM_display_name__c = 'New Playbook ' + i;
    		newPlaybook.CSM_Short_Description__c = 'This is ' + newPlaybook.CSM_display_name__c + ' short description';
    		tmpList.add(newPlaybook);
    	}
    	insert tmpList;
    	return tmpList;
    	
    }
    
    public static List<CSM_Account_Plan_Template_Indicator__c> createAcctPlanIndicators(String accountPlanTemplateId, List<CSM_Indicator__c> indList)
    {
    	List<CSM_Account_Plan_Template_Indicator__c> tmpList = new List<CSM_Account_Plan_Template_Indicator__c>();
    	
    	
    	for(CSM_Indicator__c i : indList)
    	{
    		CSM_Account_Plan_Template_Indicator__c newIndicator = new CSM_Account_Plan_Template_Indicator__c();
    		newIndicator.CSM_Account_Plan_Template__c = accountPlanTemplateId;
    		newIndicator.CSM_isACtive__c = true;
    		newIndicator.CSM_Indicator__c = i.id;
    		
    		newIndicator.CSM_Order__c = 1;
    		
    		if(i.CSM_Object_Field_Type__c == CSM_Constants.TYPE_DATE)
    		{
    			newIndicator.CSM_Criteria_1_Type__c = 'Success'; 
    			newIndicator.CSM_Criteria_1_From_Date__c = System.Today();
    			newIndicator.CSM_Criteria_1_To_Date__c = System.Today();
    			
    			newIndicator.CSM_Criteria_2_Type__c = 'Meet'; 
    			newIndicator.CSM_Criteria_2_From_Date__c = System.Today().addDays(1);
    			newIndicator.CSM_Criteria_2_To_Date__c = System.Today().addDays(4);
    			
    			newIndicator.CSM_Criteria_3_Type__c = 'Fail'; 
    			newIndicator.CSM_Criteria_3_From_Date__c = System.Today().addDays(5);
    			newIndicator.CSM_Criteria_3_To_Date__c = System.Today().addDays(9);
    		}
    		else if (i.CSM_Object_Field_Type__c == CSM_Constants.TYPE_STRING)
    		{
    		    newIndicator.CSM_Criteria_1_Type__c = 'Success';
    		    newIndicator.CSM_Criteria_1_From_Value__c = 'New Opp 1';
    		    
    		    newIndicator.CSM_Criteria_2_Type__c = 'Meet'; 
    			newIndicator.CSM_Criteria_2_From_Value__c = 'New Opp 2';    
    			
    			newIndicator.CSM_Criteria_3_Type__c = 'Fail'; 
    			newIndicator.CSM_Criteria_3_From_Value__c = 'New Opp 3';		    
    		}
    		else if (i.CSM_Object_Field_Type__c == CSM_Constants.TYPE_INTEGER 
    		        || i.CSM_Object_Field_Type__c == CSM_Constants.TYPE_DOUBLE)
    		{
    			newIndicator.CSM_Criteria_1_Type__c = 'Success';
    			newIndicator.CSM_Criteria_1_From_Value__c = '1';
    			newIndicator.CSM_Criteria_1_To_Value__c = '1000';
    			
    			newIndicator.CSM_Criteria_2_Type__c = 'Meet';
    			newIndicator.CSM_Criteria_2_From_Value__c = '1001';
    			newIndicator.CSM_Criteria_2_To_Value__c = '2000';
    			
    			newIndicator.CSM_Criteria_3_Type__c = 'Fail';
    			newIndicator.CSM_Criteria_3_From_Value__c = '2001';
    			newIndicator.CSM_Criteria_3_To_Value__c = '3000';
    		}    		
    		else if (i.CSM_Object_Field_Type__c == CSM_Constants.TYPE_PICKLIST)
    		{
    			newIndicator.CSM_Criteria_1_Type__c = 'Success';
    			newIndicator.CSM_Criteria_1_From_Value__c = 'Private';  
    			newIndicator.CSM_Criteria_2_Type__c = 'Meet';
    			newIndicator.CSM_Criteria_2_From_Value__c = 'Public';  
    			newIndicator.CSM_Criteria_3_Type__c = 'Fail';
    			newIndicator.CSM_Criteria_3_From_Value__c = 'Default'; 			
    		}
    		else if (i.CSM_Object_Field_Type__c == CSM_Constants.TYPE_CURRENCY)
    		{
    			newIndicator.CSM_Criteria_1_Type__c = 'Success';
    			newIndicator.CSM_Criteria_1_From_Value__c = '1';
    			newIndicator.CSM_Criteria_1_To_Value__c = '1000';
    			
    			newIndicator.CSM_Criteria_2_Type__c = 'Meet';
    			newIndicator.CSM_Criteria_2_From_Value__c = '1001';
    			newIndicator.CSM_Criteria_2_To_Value__c = '2000';
    			
    			newIndicator.CSM_Criteria_3_Type__c = 'Fail';
    			newIndicator.CSM_Criteria_3_From_Value__c = '2001';
    			newIndicator.CSM_Criteria_3_To_Value__c = '3000';
    		}    		
    		else
    		{
    			newIndicator.CSM_Criteria_1_Type__c = 'Success';
    			newIndicator.CSM_Criteria_1_From_Value__c = '1';
    			newIndicator.CSM_Criteria_1_To_Value__c = '100';
    			
    			newIndicator.CSM_Criteria_2_Type__c = 'Meet';
    			newIndicator.CSM_Criteria_2_From_Value__c = '101';
    			newIndicator.CSM_Criteria_2_To_Value__c = '1000';
    			
    			
    			newIndicator.CSM_Criteria_3_Type__c = 'Fail';
    			newIndicator.CSM_Criteria_3_From_Value__c = '1001';
    			newIndicator.CSM_Criteria_3_To_Value__c = '2000';
    		}
    		tmpList.add(newIndicator);
    	}
    	insert tmpList;
    	return tmpList;
    }
    
    public static List<CSM_Indicator__c> createIndicators(String IndicatorGroup, Integer recordCount)
    {
    	List<CSM_Indicator__c> tmpList = new List<CSM_Indicator__c>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for(Integer i=1; i<=recordCount; i++)
    	{
    		CSM_Indicator__c newInd = new CSM_Indicator__c();
    		newInd.CSM_isActive__c = true;
    		newInd.CSM_Indicator_Group__c = IndicatorGroup;
    		newInd.CSM_Indicator_Display_Name__c = 'Indicator ' + i;
    		newInd.name = 'Indicator ' + i;
    		if(i==1)
    		{
    			newInd.CSM_Object_Name__c =  CSM_Constants.OBJ_TYPE_ACCOUNT;
    			newInd.CSM_Object_Field_Type__c = CSM_Constants.TYPE_DATE;
    			newInd.CSM_Object_Field_Name__c = 'CSM_Last_Health_Status__c';
    		}
    		else if(i==2)
    		{
    			newInd.CSM_Object_Name__c =  CSM_Constants.OBJ_TYPE_ACCOUNT;
    			newInd.CSM_Object_Field_Type__c = CSM_Constants.TYPE_INTEGER;
    			newInd.CSM_Object_Field_Name__c = 'NumberOfEmployees';
    		}
    		else if(i==3)
    		{
    			newInd.CSM_Object_Name__c = CSM_Constants.OBJ_TYPE_OPPORTUNITY;
    			newInd.CSM_Object_Field_Type__c = CSM_Constants.TYPE_STRING;
    			newInd.CSM_Object_Field_Name__c = 'Name';
    		}
    		else if(i==4)
    		{
    			newInd.CSM_Object_Name__c = CSM_Constants.OBJ_TYPE_ACCOUNT;
    			newInd.CSM_Object_Field_Type__c = CSM_Constants.TYPE_PICKLIST;
    			newInd.CSM_Object_Field_Name__c = 'Ownership';
    		}
    		else if(i== 5)
    		{
    			newInd.CSM_Object_Name__c = CSM_Constants.OBJ_TYPE_OPPORTUNITY;
    			newInd.CSM_Object_Field_Type__c = CSM_Constants.TYPE_DOUBLE;
    			newInd.CSM_Object_Field_Name__c = 'TotalOpportunityQuantity';
    			
    		} 
			else if (i == 6)	
    		{
    			newInd.CSM_Object_Name__c = CSM_Constants.OBJ_TYPE_ACCOUNT;
    			newInd.CSM_Object_Field_Type__c = CSM_Constants.TYPE_CURRENCY;
    			newInd.CSM_Object_Field_Name__c = CSM_Constants.OBJ_A_ANNUAL_REVENUE;
    		}    		
    		else if (i == 7)	
    		{
    			newInd.CSM_Object_Name__c = CSM_Constants.OBJ_TASK;
    			newInd.CSM_Object_Field_Type__c = CSM_Constants.TYPE_DOUBLE;
    			newInd.CSM_Object_Field_Name__c = 'CallDurationInSeconds';
    		}
    		else if (i == 8)	
    		{
    			newInd.CSM_Object_Name__c = CSM_Constants.OBJ_SA_SACF;
    			newInd.CSM_Object_Field_Type__c = CSM_Constants.TYPE_DOUBLE;
    			newInd.CSM_Object_Field_Name__c = 'BUCUDEMANDD747__c';
    		}
    		tmpList.add(newInd);
    	}
    	insert tmpList;
    	return tmpList;
    }
    public static List<CSM_Indicator_Group__c> createIndicatorGroups()
    {
    	List<CSM_Indicator_Group__c> tmpList = new List<CSM_Indicator_Group__c>();
    	tmpList.add(new CSM_Indicator_Group__c(csm_display_name__c='Health'));
    	insert tmpList;
    	return tmpList;
    }
   
    public static List<CSM_Account_Plan__c> createAccountPlan(List<Account> accountList, String accountPlanTemplateId)
    {
    	//CSM_Constants.ACCOUNT_PLAN_TRIGGER = false;
		List<CSM_Account_Plan__c> accountPlanList = new List<CSM_Account_Plan__c>();
    	
    	for (Account a : accountList)
    	{
    		CSM_Account_Plan__c accountPlan = new CSM_Account_Plan__c();
    		accountPlan.CSM_Account_Plan_Template__c = accountPlanTemplateId;
    		accountPlan.CSM_Phase_Start_Date__c = System.today();
    		accountPlan.CSM_AccountId__c = a.id;
    		accountPlan.CSM_isActive__c = true;
    		accountPLanList.add(accountPlan);
    	}
    	insert accountPlanList;
    	return accountPlanList; 
    }
    
    public static List<Account> createAccount(Integer recordCount)
    {
    	List<String> FieldList = new List<String>{REN_Constants.FLD_NAME};
    	CSM_Util.checkCRUD_FLS('Account', FieldList, CSM_Constants.DML_OPERATION_INSERT);
    	
    	CSM_Constants.ACCOUNT_TRIGGER = false;
    	List<Account> tmpList = new List<Account>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for (integer i=1; i<=recordCount; i++)
    	{
    		Account newAccount = new Account();
    		newAccount.Name = 'Account ' + i;
    		tmpList.add(newAccount);
    	}
    	insert tmpList;
    	return tmpList;
    }
    public static List<Opportunity> createOpportunity(Integer recordCount, String accountId)
    {
    	List<String> opportunityFieldList = new List<String>{REN_CONSTANTS.OBJ_OPP_ACCOUNT, 
		                                                    REN_Constants.FLD_NAME,
		                                                    REN_Constants.OBJ_RC_OPPORTUNITY_STAGE,
		                                                    REN_Constants.OBJ_OPP_CLOSE_DATE,
		                                                    REN_CONSTANTS.OBJ_OPP_CONSOLIDATED
		                                                    };
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opportunityFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        
    	CSM_Constants.OPPORTUNITY_TRIGGER = false;
    	List<Opportunity> tmpList = new List<Opportunity>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for(integer i=1; i<=recordCount; i++)
    	{
    		Opportunity newOpportunity = new Opportunity();
    		newOpportunity.accountId = accountId;
    		newOpportunity.Name = 'New Opp ' + i;
    		newOpportunity.CloseDate = System.Today();
    		newOpportunity.StageName = 'Qualification';
    		newOpportunity.REN_Is_Consolidated__c = false;
    		tmpList.add(newOpportunity);
    	}
    	insert tmpList;
    	return tmpList;
    }
    
    public static List<SObject> createServiceContract(Integer recordCount, String accountId)
    {
    	//CSM_Constants.SERVICECONTRACT_TRIGGER = false;
    	List<SObject> tmpList = new List<SObject>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
	   if (CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT))
	   { 	
	    	for(integer i=1; i<=recordCount; i++)
	    	{
	    			SObject newServiceContract = CSM_AccessController.newSObject(REN_Constants.OBJ_SERVICE_CONTRACT);//new ServiceContract();
		    		newServiceContract.put(REN_Constants.OBJ_SC_ACCOUNT,accountId);
					newServiceContract.put(REN_Constants.OBJ_SC_PRICEBOOK2_ID, Test.getStandardPricebookId());	    		
		    		newServiceContract.put(REN_Constants.OBJ_SC_NAME,'New SContract ' + i);
		    		newServiceContract.put(REN_Constants.OBJ_SC_START_DATE,Date.valueOf((DateTime.now() - 1).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'')));
		    		newServiceContract.put(REN_Constants.OBJ_SC_END_DATE, Date.valueOf((DateTime.now() + 2).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'')));
		    		if (associateRenewalOppty==true) {
			    		List<Opportunity> opptyList = createOpportunity(1, accountId); 
			    		if (opptyList!=null && !opptyList.isEmpty()) {
			    			if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID)){
			    				newServiceContract.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID, opptyList[0].Id);
			    			}
		    			}  
		    		}
		    		  		
		    		//newServiceContract.REN_Is_Consolidated__c = false;
		    		if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED)){
		    			newServiceContract.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED, false);
		    		}
					tmpList.add(newServiceContract);
	    	}
	   } 	
    	if (CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
    		insert tmpList;
    	}
    	return tmpList;
    }
    
    
    public static List<CSM_Playbook__c> createPlaybookTestData(Integer recordCount)
    {
    	List<CSM_Playbook__c> tmpList = new List<CSM_Playbook__c>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for(Integer i=1; i<=recordCount; i++)
    	{
    		CSM_Playbook__c newPlaybook = new CSM_Playbook__c();
    		newPlaybook.CSM_Display_Name__c = 'Playbook ' + i;
    		newPlaybook.CSM_IsActive__c = true;
    		newPlaybook.CSM_Long_Description__c = 'Long description for Playbook ' + i;
    		newPlaybook.CSM_Short_Description__c = 'Short description for Playbook ' + i;
    		newPlaybook.CSM_External_Id__c = '100' + i;
    		tmpList.add(newPlaybook);
    	}
    	insert tmpList;
    	return tmpList;
    }
    
    public static List<CSM_Play__c> createPlayTestData(Integer recordCount)
    {
    	List<CSM_Play__c> tmpList = new List<CSM_Play__c>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for (Integer i=1; i<=recordCount; i++)
    	{
    		CSM_Play__c newPlay = new CSM_Play__c();
    		newPlay.CSM_isActive__c = true;
    		newPlay.CSM_Display_Name__c = 'Play ' + i;
    		newPlay.CSM_Object_Name__c = 'Account';
    		newPlay.CSM_External_Id__c = 'ExternalId' + 1;
    		newPlay.CSM_Query_Criteria__c = 'Select id, name, numberofemployees from Account where numberOfemployees >= 100';
    		tmpList.add(newPlay);
    	}
    	insert tmpList;
    	return tmpList;
    }
     
    public static CSM_PlaybookPlay__c createPlaybookPlayTestData(String playBookId, String playId){
		CSM_PlaybookPlay__c newPlaybookPlay = new CSM_PlaybookPlay__c();
		newPlaybookPlay.CSM_Playbook__c = playBookId;
		newPlaybookPlay.CSM_Play__c = playId;
    	
    	insert newPlaybookPlay;
    	return newPlaybookPlay;
	}
    
    public static List<CSM_Play__c> createPlayOpportunityTestData(String playbookId, Integer recordCount)
    {
    	List<CSM_Play__c> tmpList = new List<CSM_Play__c>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for (Integer i=1; i<=recordCount; i++)
    	{
    		CSM_Play__c newPlay = new CSM_Play__c();
    		newPlay.CSM_isActive__c = true;
    		newPlay.CSM_Display_Name__c = 'Play ' + i;
    		newPlay.CSM_Object_Name__c = 'Opportunity';
    		newPlay.CSM_Query_Criteria__c = 'Select id, name, stagename, accountId from Opportunity where stageName = \'Prospecting\' ';
    		tmpList.add(newPlay);
    	}
    	insert tmpList;
    	return tmpList;
    }
    public static List<CSM_Play_Criteria__c> createOpportunityPlayCriteriaDataDate(String playId)
    {
    	CSM_Constants.PLAY_CRITERIA_TRIGGER = false;
    	List<CSM_Play_Criteria__c> tmpList = new List<CSM_Play_Criteria__c>();
		CSM_Play_Criteria__c newCriteria = new CSM_Play_Criteria__c();
		newCriteria.RLM_Field_Display_Name__c = 'StageNAme';
		newCriteria.RLM_Field_Name__c = 'StageName';
		newCriteria.RLM_Field_Type__c = CSM_Constants.TYPE_PICKLIST;
		newCriteria.CSM_Play__c = playid;
		newCriteria.RLM_Operator__c = '>=';
		newCriteria.RLM_Values__c = 'Prospecting';
		tmpList.add(newCriteria);
		insert tmpList;
		return tmpList;
    }
    
    public static List<CSM_Play_Criteria__c> createPlayCriteriaDataDate(String playId)
    {
    	CSM_Constants.PLAY_CRITERIA_TRIGGER = false;
    	List<CSM_Play_Criteria__c> tmpList = new List<CSM_Play_Criteria__c>();
		CSM_Play_Criteria__c newCriteria = new CSM_Play_Criteria__c();
		newCriteria.RLM_Field_Display_Name__c = 'Last Health Status';
		newCriteria.RLM_Field_Name__c = 'CSM_Last_Health_Status__c';
		newCriteria.RLM_Field_Type__c = CSM_Constants.TYPE_DATE;
		newCriteria.CSM_Play__c = playid;
		newCriteria.RLM_Operator__c = '>=';
		newCriteria.RLM_Date_Value__c = System.Today();
		tmpList.add(newCriteria);
		insert tmpList;
		return tmpList;
    }
    public static List<CSM_Play_Criteria__c> createPlayCriteriaData(String playId)
    {
    	List<CSM_Play_Criteria__c> tmpList = new List<CSM_Play_Criteria__c>();
		CSM_Play_Criteria__c newCriteria = new CSM_Play_Criteria__c();
		newCriteria.RLM_Field_Display_Name__c = 'SLA Expiration Date';
		newCriteria.RLM_Field_Name__c = 'NumberOfEmployees';
		newCriteria.RLM_Field_Type__c = CSM_Constants.TYPE_INTEGER;
		newCriteria.CSM_Play__c = playid;
		newCriteria.RLM_Operator__c = '>=';
		newCriteria.RLM_Values__c = '100'; 
		tmpList.add(newCriteria);
		insert tmpList;
		return tmpList;
    }
    
    public static List<CSM_Play_Criteria__c> createPlayCriteriaOpptyData(String playId)
    {
    	List<CSM_Play_Criteria__c> tmpList = new List<CSM_Play_Criteria__c>();
		CSM_Play_Criteria__c newCriteria = new CSM_Play_Criteria__c();
		newCriteria.RLM_Field_Display_Name__c = 'Stage Name';
		newCriteria.RLM_Field_Name__c = 'StageName';
		newCriteria.RLM_Field_Type__c = CSM_Constants.TYPE_STRING;
		newCriteria.CSM_Play__c = playid;
		newCriteria.RLM_Operator__c = '=';
		newCriteria.RLM_Values__c = 'Prospecting'; 
		tmpList.add(newCriteria);
		insert tmpList;
		return tmpList;
    }
    
    public static List<CSM_Play_Task__c> createPlayTaskData(String playId)
    {
    	List<CSM_Play_Task__c> tmpList = new List<CSM_Play_Task__c>();
    	CSM_Play_Task__c newTask1 = new CSM_Play_Task__c();
    	newTask1.CSM_Assign_To__c = CSM_Constants.ASSIGN_ACCOUNT_OWNER;
    	newTask1.Name = 'Task 1';
    	newTask1.CSM_Days_Until_Due__c = 30;
    	newTask1.CSM_IsActive__c = true;
    	newTask1.CSM_Play__c = playId;
    	newTask1.CSM_Description__c = 'The description';
    	tmpList.add(newTask1);
    	CSM_Play_Task__c newTask2 = new CSM_Play_Task__c();
    	newTask2.CSM_Assign_To__c = CSM_Constants.ASSIGN_CSM_CONTACT;
    	newTask2.Name = 'Task 2';
    	newTask2.CSM_Days_Until_Due__c = 30;
    	newTask2.CSM_IsActive__c = true;
    	newTask2.CSM_Play__c = playId;
    	newTask2.CSM_Description__c = 'The description';
    	tmpList.add(newTask2);
    	CSM_Play_Task__c newTask3 = new CSM_Play_Task__c();
    	newTask3.CSM_Assign_To__c = CSM_Constants.ASSIGN_CSM_MANAGER;
    	newTask3.Name = 'Task 3';
    	newTask3.CSM_Days_Until_Due__c = 30;
    	newTask3.CSM_IsActive__c = true;
    	newTask3.CSM_Play__c = playId;
    	newTask3.CSM_Description__c = 'The description';
    	tmpList.add(newTask3);
    	CSM_Play_Task__c newTask4 = new CSM_Play_Task__c();
    	newTask4.CSM_Assign_To__c = CSM_Constants.ASSIGN_CUSTOMER_SUCCESS_MANAGER;
    	newTask4.Name = 'Task 4';
    	newTask4.CSM_Days_Until_Due__c = 30;
    	newTask4.CSM_IsActive__c = true;
    	newTask4.CSM_Play__c = playId;
    	newTask4.CSM_Description__c = 'The description';
    	tmpList.add(newTask4);
    	CSM_Play_Task__c newTask5 = new CSM_Play_Task__c();
    	newTask5.CSM_Assign_To__c = CSM_Constants.ASSIGN_EXEC_SPONSOR;
    	newTask5.Name = 'Task 5';
    	newTask5.CSM_Days_Until_Due__c = 30;
    	newTask5.CSM_IsActive__c = true;
    	newTask5.CSM_Play__c = playId;
    	newTask5.CSM_Description__c = 'The description5';
    	tmpList.add(newTask5);
    	CSM_Play_Task__c newTask6 = new CSM_Play_Task__c();
    	newTask6.CSM_Assign_To__c = CSM_Constants.ASSIGN_RENEWAL_MANAGER;
    	newTask6.Name = 'Task 6';
    	newTask6.CSM_Days_Until_Due__c = 30;
    	newTask6.CSM_IsActive__c = true;
    	newTask6.CSM_Play__c = playId;
    	newTask6.CSM_Description__c = 'The description6';
    	tmpList.add(newTask6);
    	CSM_Play_Task__c newTask7 = new CSM_Play_Task__c();
    	newTask7.CSM_Assign_To__c = CSM_Constants.ASSIGN_RENEWAL_CONTACT;
    	newTask7.Name = 'Task 7';
    	newTask7.CSM_Days_Until_Due__c = 30;
    	newTask7.CSM_IsActive__c = true;
    	newTask7.CSM_Play__c = playId;
    	newTask7.CSM_Description__c = 'The description7';
    	tmpList.add(newTask7);
    	CSM_Play_Task__c newTask8 = new CSM_Play_Task__c();
    	newTask8.CSM_Assign_To__c = CSM_Constants.ASSIGN_SUPPORT_CONTACT;
    	newTask8.Name = 'Task 8';
    	newTask8.CSM_Days_Until_Due__c = 30;
    	newTask8.CSM_IsActive__c = true;
    	newTask8.CSM_Play__c = playId;
    	newTask8.CSM_Description__c = 'The description 8';
    	tmpList.add(newTask8);
    	insert tmpList;
    	return tmpList;
    }     
    
    public static List<Contact> createContacts(String accountId, Integer recordCount)
    { 
    	List<Contact> tmpList = new List<Contact>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for (Integer i=1; i<=recordCount; i++ )
    	{
    		Contact newContact = new Contact();
    		newContact.FirstName = 'Test';
    		newContact.LastName = 'Contact ' + i;
    		newContact.CSM_Related__c = true;
    		newContact.AccountId = accountId;
    		tmpList.add(newContact);
    	}
    	insert tmpList;
    	return tmpList;
    }
    
    /**
     * Retrieves the user with 'System Administrator' profile.
     *
     * @return the User object with 'System Administrator' profile.
     */
    public static User GetTestRunAsUser() {
        
       Profile p = [Select p.Name, p.Id From Profile p where p.Name =: CSM_Constants.SYSTEM_ADMIN_NAME];
       User u = [select id, name from User where ProfileId = : p.id and IsActive = true][0]; 
       return u;
    }
    
    public static User CreateUser(Id profileId){
        User u = new User(
            FirstName = 'Test'
            , LastName = 'User'
            , Username = 'csm-renew-test@email.com'
            , Email = 'test@email.com'
            , IsActive = true
            , Alias = 'tuser'
            , TimeZoneSidKey = 'GMT'
            , LocaleSidKey = 'en_US'
            , EmailEncodingKey = 'ISO-8859-1'
            , LanguageLocaleKey = 'en_US'
            , ProfileId = profileId);
            return u;
    }
    
    public static User createTestUser(String profileName){ 
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName]; 
        return CreateUser(p.Id);
    }
    
    public static List<CSM_Chart_Management__c> createChartList() {
    	List<CSM_Chart_Management__c> newChartList = new List<CSM_Chart_Management__c>();
    	/*CSM_Chart_Management__c newChart1 = new CSM_Chart_Management__c();
		newChart1.CSM_Admin_List_Display__c = true; 
		newChart1.CSM_Color_Range__c = '#51721e;#6e9b28;#8bc333;a2d356;#b8dd7f;#cfe8a7;#e5f3cf;#f4faea;#354a13'; 
		newChart1.CSM_Color_Sort_Range__c ='Healthy;Low Adoption;Pending Churn;Undetermined'; 
		newChart1.CSM_Display_Color_Fields__c = false; 
		newChart1.CSM_Display_Color_Range__c = true;
		newChart1.CSM_Display_Range__c = false;
		newChart1.CSM_Field_1_Label__c = 'Health Status Field';
		newChart1.CSM_Field_1_Type__c = 'PICKLIST;STRING';
		newChart1.CSM_Field_1_Value__c = 'CSM_Health_Status__c';
		newChart1.CSM_Field_1_Display__c = true;
		newChart1.CSM_Module_Type__c = 'CSM';
		newChart1.CSM_Object_Label__c = 'Health Status Object'; 
		newChart1.CSM_Object_Name__c = 'Account';
		newChart1.CSM_Object_Type__c = 'Account;ScoutAnalytics__Account_Custom_Field__c'; 
		newChart1.CSM_Soql_Query__c = 'select id, CSM_Health_Status__c from Account';
		newChart1.Name = 'Health Status';
		newChart1.CSM_Display_Name__c = 'Account Health Status';
		newChartList.add(newChart1); */
		CSM_Chart_Management__c newChart6 = new CSM_Chart_Management__c();
		newChart6.CSM_Admin_List_Display__c = true;
		newChart6.CSM_Color_1_Label__c = 'High Usage Color'; 
		newChart6.CSM_Color_1_Value__c = '#51721e'; 
		newChart6.CSM_Color_2_Label__c = 'Normal Usage Color'; 
    	newChart6.CSM_Color_2_Value__c = '#6e9b28'; 
    	newChart6.CSM_Color_3_Label__c = 'Low Usage Color'; 
    	newChart6.CSM_Color_3_Value__c = '#8bc333'; 
    	newChart6.CSM_Color_Range__c = ''; 
    	newChart6.CSM_Color_Sort_Range__c = ''; 
    	newChart6.CSM_Display_Color_Fields__c = true; 
    	newChart6.CSM_Display_Color_Range__c = false;
    	newChart6.CSM_Display_Range__c = true;
    	newChart6.CSM_Field_1_Label__c = 'Opportunity Sum Field';
		newChart6.CSM_Field_1_Type__c = 'INTEGER;DOUBLE;CURRENCY';
		//newChart6.CSM_Field_1_Value__c = 'CSM_Opportunity_Amount__c';
		newChart6.CSM_Field_1_Display__c = true;
		newChart6.CSM_Field_2_Label__c = 'Usage Field';
		newChart6.CSM_Field_2_Type__c = 'INTEGER;DOUBLE;'; 
		newChart6.CSM_Field_2_Value__c = 'CSM_Usage__c';
		newChart6.CSM_Field_2_Display__c = true; 
		newChart6.CSM_Field_3_Label__c = 'ARR Field'; 
		newChart6.CSM_Field_3_Type__c = 'INTEGER;DOUBLE;CURRENCY'; 
		newChart6.CSM_Field_3_Value__c = 'CSM_ARR__c';
		newChart6.CSM_Field_3_Display__c = true; 
		newChart6.CSM_Module_Type__c = 'CSM';
		newChart6.CSM_Object_Label__c = 'Opportunity Value Object'; 
		newChart6.CSM_Object_Name__c = 'Account';
		newChart6.CSM_Object_Type__c = 'Account;ScoutAnalytics__Account_Custom_Field__c'; 
		newChart6.CSM_Range_1_Label__c = 'High Usage';
		newChart6.CSM_Range_2_Label__c = 'Normal Usage'; 
		newChart6.CSM_Range_3_Label__c  = 'Low Usage';
		newChart6.CSM_Range_4_Label__c = 'High ARR';
		newChart6.CSM_Range_5_Label__c  = 'Normal ARR';
		newChart6.CSM_Range_6_Label__c = 'Low ARR';
		newChart6.CSM_Soql_Query__c = 'select id, CSM_ARR__c, CSM_Usage__c from Account';
		newChart6.Name = 'Portfolio Summary - Opportunity and Usage';
		newChart6.CSM_Display_Name__c = 'Opportunity Value and Usage Portfolio Summary';
		newChartList.add(newChart6); 
		insert newChartList;
		return newChartList; 
    }
    
    public static Case createCase(Id accountId){
    	Case caseObj = new Case();
    	caseObj.AccountId = accountId;
    	caseObj.Status = 'New';
    	caseObj.Origin = 'Phone';
    	caseObj.Subject = 'Test Case';
    	
    	return caseObj;
    }
    public static List<CSM_Batch_Success_Plan_Default__c> createSuccPlanDefRecord(integer recordCount){
    	List<CSM_Batch_Success_Plan_Default__c> tmpList = new List<CSM_Batch_Success_Plan_Default__c>();
    	if(recordCount == null)
    	{
    		recordCount = 1;
    	}
    	for(Integer i=1; i <= recordCount; i++)
    	{
    		CSM_Batch_Success_Plan_Default__c newRecord = new CSM_Batch_Success_Plan_Default__c();
    		newRecord.CSM_Phase_Start_Date__c = Date.today();
    		newRecord.CSM_Account_Manager__c = UserInfo.getUserId();
    		newRecord.CSM_Contact__c = UserInfo.getUserId();
    		newRecord.CSM_Manager__c = UserInfo.getUserId();
    		newRecord.CSM_Customer_Success_Manager__c = UserInfo.getUserId();
    		newRecord.CSM_Exec_Sponsor__c = UserInfo.getUserId();
    		newRecord.CSM_Renewal_Contact__c = UserInfo.getUserId();
    		newRecord.CSM_Support_Contact__c = UserInfo.getUserId();
    		newRecord.CSM_Renewal_Manager__c = UserInfo.getUserId();
    		tmpList.add(newRecord);
    	}
    	insert tmpList;
    	return tmpList;
    }
}