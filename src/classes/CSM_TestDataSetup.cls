//@isTest
public class CSM_TestDataSetup {
/*
	static testMethod void csmLoadDataTest() {
       	Test.startTest();
       		CSM_TestDataSetup csmTestObj = new CSM_TestDataSetup();
       		csmTestObj.createDataUpToPlayBookPlay(2, 2, 2);
		    system.assert(csmTestObj.playBookPlayList != null);
       		csmTestObj.createDataForAccountPlan(1, 1);
		    system.assert(csmTestObj.successPlanPhaseList != null);
       		csmTestObj.createDataForFocusCategory(1, 1, 2);
		    system.assert(csmTestObj.focusCategoryList != null);
       	Test.stopTest();
    } 
*/

	public String prefixName{get{ return prefixName==null?'':prefixName;} set;}
	public List<CSM_Indicator_Group__c> indicatorGroupList{get; set;}
	public List<CSM_Indicator__c> indicatorList{get; set;}
	public List<CSM_Play__c> playList{get; set;}
	public List<CSM_Play_Criteria__c> playCriteriaList{get; set;}
	public List<CSM_Play_Task__c> playTaskList{get; set;}
	public List<CSM_Playbook__c> playBookList{get; set;}
	public List<CSM_PlaybookPlay__c> playBookPlayList{get; set;}
	public List<CSM_Account_Plan_Template__c> accPlanTemplateList{get; set;}
	public List<Account> accountList{get; set;}
	public List<CSM_Account_Plan__c> accountPlanList{get; set;}
	public List<CSM_Account_Plan_Playbook__c> successPlanPlayBookList{get;set;}
	public List<CSM_Account_Plan_Template_Indicator__c> accountPlanTemplateIndicatorList{get;set;}
	public List<CSM_Account_Plan_Phase__c> successPlanPhaseList{get;set;}
	public List<CSM_Focus_Category_View__c> focusCategoryViewlist{get;set;}
	public List<CSM_Focus_Category_View_Criteria__c> fcvCriteriaList{get;set;}
	public List<CSM_Focus_Category_View_Column__c> fcvColumnList{get;set;}
	public List<CSM_Focus_Category_Group__c> focusCategoryGrouplist{get;set;}
	public List<CSM_Focus_Category_Column__c> focusCategoryColumnlist{get;set;}
	public List<CSM_Focus_Category__c> focusCategoryList{get;set;}
	public string nameSpace;
	
	public CSM_TestDataSetup() { nameSpace = CSM_Util.getNamespace(); }
	
	public CSM_TestDataSetup(String prefixName) {
		this.prefixName = prefixName;
		nameSpace = CSM_Util.getNamespace();
	}
/*	
	static testMethod void csmDataSetup() {
       	Test.startTest();
       		CSM_TestDataSetup csmTestObj = new CSM_TestDataSetup();
       		csmTestObj.createDataUpToPlayBookPlay(1, 1, 1);
		    system.assert(csmTestObj.playBookPlayList != null);
       		csmTestObj.createDataForAccountPlan(1, 1);
		    system.assert(csmTestObj.successPlanPhaseList != null);
       		csmTestObj.createDataForFocusCategory(1, 1, 2);
		    system.assert(csmTestObj.focusCategoryList != null);
       	Test.stopTest();
    } 
	static testMethod void loadDataSetup() {
       	Test.startTest();
       		CSM_TestDataSetup csmTestObj = new CSM_TestDataSetup();
       		csmTestObj.createLoadDataUpToPlayBookPlay(1, 1, 1);
       		csmTestObj.createLoadDataForAccountPlan(1, 1);
       		csmTestObj.createLoadDataForFocusCategory(1, 1, 2);
		    system.assert(true);
       	Test.stopTest();
    } 
*/    
	
	public void createLoadDataUpToPlayBookPlay(Integer noOfPlays, Integer noOfTasksForEachPlay, Integer noOfPlayBooks) {
		createDataUpToPlayBookPlay(noOfPlays, noOfTasksForEachPlay, noOfPlayBooks);
	}
	public void createLoadDataForAccountPlan(Integer noOfAccountsTempmplates, Integer noOfPhaseForEachSuccessPlanTemplate) {
		createDataForAccountPlan(noOfAccountsTempmplates, noOfPhaseForEachSuccessPlanTemplate);
	}
	public void createLoadDataForFocusCategory(Integer noOfFocusCategoryView, Integer noOfFocusCategoryGroups, Integer noOfColumnsInEachFCGroups) {
		createDataForFocusCategory(noOfFocusCategoryView, noOfFocusCategoryGroups, noOfColumnsInEachFCGroups);
	}
	
	public void createDataUpToPlayBookPlay(Integer noOfPlays, Integer noOfTasksForEachPlay, Integer noOfPlayBooks) {
		createIndicatorGroup();
		createIndicators(indicatorGroupList);
		createPlay(noOfPlays);
		createPlayCriteria(playList);
		createPlayTask(playList, noOfTasksForEachPlay);
		createPlaybook(noOfPlayBooks);
		createPlaybookPlay(playBookList,playList,noOfPlays);
		
		/*System.debug(LoggingLevel.WARN,'\n\n~@~ Created CSM Data: ' 
		  + '\n indicatorGroupList: ' + indicatorGroupList.size() + ':- ' + indicatorGroupList
		  + '\n indicatorList: ' + indicatorList.size() + ':- ' + indicatorList
		  + '\n playList: ' + playList.size() + ':- ' + playList
		  + '\n playCriteriaList: ' + playCriteriaList.size() + ':- ' + playCriteriaList
		  + '\n playTaskList: ' + playTaskList.size() + ':- ' + playTaskList
		  + '\n playBookList: ' + playBookList.size() + ':- ' + playBookList
		  + '\n playBookPlayList: ' + playBookPlayList.size() + ':- ' + playBookPlayList
		);*/        
		
    }
	public void createDataForAccountPlan(Integer noOfAccountsTempmplates, Integer noOfPhaseForEachSuccessPlanTemplate) {
		
		createAccount(noOfAccountsTempmplates);
		createAccountPlanTemplate(noOfAccountsTempmplates);
		createSuccessPlanPhase(noOfPhaseForEachSuccessPlanTemplate,accPlanTemplateList);
		createSuccessPlanPlaybook(accPlanTemplateList,playBookList,2);
		createSuccessPlanIndicator(accPlanTemplateList,indicatorList);
		createAccountPlan(accountList, accPlanTemplateList);

		System.debug(LoggingLevel.WARN,'\n\n~@~ Created CSM Data: ' 
		  + '\n accountList: ' + accountList.size() + ':- ' + accountList
		  + '\n accPlanTemplateList: ' + accPlanTemplateList.size() + ':- ' + accPlanTemplateList
		  + '\n successPlanPhaseList: ' + successPlanPhaseList.size() + ':- ' + successPlanPhaseList
		  + '\n successPlanPlayBookList: ' + successPlanPlayBookList.size() + ':- ' + successPlanPlayBookList
		  + '\n accountPlanTemplateIndicatorList: ' + accountPlanTemplateIndicatorList.size() + ':- ' + accountPlanTemplateIndicatorList
		  + '\n accountPlanList: ' + accountPlanList.size() + ':- ' + accountPlanList
		);        
    }
	public void createDataForFocusCategory(Integer noOfFocusCategoryView, Integer noOfFocusCategoryGroups, Integer noOfColumnsInEachFCGroups) {
		
		focusCategoryViewlist = createFocusCategoryView(noOfFocusCategoryView);
		createFocusCategoryCriteria(focusCategoryViewlist);
		createFCVColumn(focusCategoryViewlist);
		createFocusCategoryGroup(noOfFocusCategoryGroups);
		createFocusCatColumn(noOfColumnsInEachFCGroups, focusCategoryGrouplist);
		createFocusCategories(noOfFocusCategoryGroups,focusCategoryColumnlist,focusCategoryViewlist);//???
		
		System.debug(LoggingLevel.WARN,'\n\n~@~ Created Data: ' 
		  + '\n focusCategoryViewlist: ' + focusCategoryViewlist.size() + ':- ' + focusCategoryViewlist
		  + '\n fcvCriteriaList: ' + fcvCriteriaList.size() + ':- ' + fcvCriteriaList
		  + '\n fcvColumnList: ' + fcvColumnList.size() + ':- ' + fcvColumnList
		  + '\n focusCategoryGrouplist: ' + focusCategoryGrouplist.size() + ':- ' + focusCategoryGrouplist
		  + '\n focusCategoryColumnlist: ' + focusCategoryColumnlist.size() + ':- ' + focusCategoryColumnlist
		  + '\n focusCategoryList: ' + focusCategoryList.size() + ':- ' + focusCategoryList
		);        
		
    }
	//*********** Indicator Group ***********
	public List<CSM_Indicator_Group__c> createIndicatorGroup()	{
		indicatorGroupList = new List<CSM_Indicator_Group__c>();
		string queryString = 'select Id from ' +nameSpace+ 'CSM_Indicator_Group__c limit 1';		
		indicatorGroupList = Database.query(queryString);
		if(indicatorGroupList.isEmpty())	{
			//indicatorGroupList = new List<CSM_Indicator_Group__c>();
			indicatorGroupList.add(new CSM_Indicator_Group__c(CSM_Display_Name__c = 'Load Test Indicator Group'));
			insert indicatorGroupList;
		}
		return indicatorGroupList;

	}
	//*********** Indicators *************//???
	public List<CSM_Indicator__c> createIndicators(List<CSM_Indicator_Group__c> indicatorGroupListParam)	{
		indicatorList = new List<CSM_Indicator__c>();	
		indicatorList = [select Id,CSM_Object_Field_Name__c  from CSM_Indicator__c limit 10];	
		if(indicatorList.isEmpty())	{	
			for(integer i=1;i<=3;i++)	{
				if(i==1)	{				
					CSM_Indicator__c newIndicator1ForAccount  = createIndicatorsForEachObject(indicatorGroupListParam[0].Id, 'Industry','Industry','Industry','PICKLIST','Account','Industry',TRUE);
					CSM_Indicator__c newIndicator1ForOpportunity  = createIndicatorsForEachObject(indicatorGroupListParam[0].Id, 'Lead Source','Lead Source','LeadSource','PICKLIST','Opportunity','Lead Source',TRUE);
					indicatorList.add(newIndicator1ForAccount);
					indicatorList.add(newIndicator1ForOpportunity);
				}
				else if(i==2){
					CSM_Indicator__c newIndicator2ForAccount  = createIndicatorsForEachObject(indicatorGroupListParam[0].Id, 'Annual Revenue','Annual Revenue','AnnualRevenue','CURRENCY','Account','Annual Revenue',TRUE);
					CSM_Indicator__c newIndicator2ForOpportunity  = createIndicatorsForEachObject(indicatorGroupListParam[0].Id, 'Amount','Amount','Amount','CURRENCY','Opportunity','Amount',TRUE);
					indicatorList.add(newIndicator2ForAccount);
					indicatorList.add(newIndicator2ForOpportunity);
				}						
				else{
					CSM_Indicator__c newIndicator3ForAccount  = createIndicatorsForEachObject(indicatorGroupListParam[0].Id, 'Health Status','Health Status',nameSpace+'CSM_Health_Status__c','PICKLIST','Account','Health Status',TRUE);
					CSM_Indicator__c newIndicator3ForOpportunity  = createIndicatorsForEachObject(indicatorGroupListParam[0].Id, 'Stage','Stage','StageName','PICKLIST','Opportunity','Stage',TRUE);
					indicatorList.add(newIndicator3ForAccount);
					indicatorList.add(newIndicator3ForOpportunity);
	
				}
			}
			insert indicatorList;
		}
		return indicatorList;

	}
	
	public CSM_Indicator__c createIndicatorsForEachObject(Id indicatorGroupId, String fieldDisplayName, string fieldLabel, String fieldName, String fieldType, String Objname, String indicatorName, boolean isActive) {
		CSM_Indicator__c newIndicator = new CSM_Indicator__c();
		newIndicator.CSM_Indicator_Group__c = indicatorGroupId;
		newIndicator.CSM_Indicator_Display_Name__c = fieldDisplayName;
		newIndicator.CSM_Object_Field_Label__c = fieldLabel;
		newIndicator.CSM_Object_Field_Name__c = fieldName;
		newIndicator.CSM_Object_Field_Type__c = fieldType;
		newIndicator.CSM_Object_Name__c = Objname;
		newIndicator.Name = indicatorName;
		newIndicator.CSM_isActive__c = isActive;
		return newIndicator;		

	}
	//*********** Play *******************
	// ObjName : Account,Opportunity,Case,CSM_Account_Plan__c;
	
	public  List<CSM_Play__c> createPlay(Integer recordCountPerObject){
    	playList = new List<CSM_Play__c>();
    	if(recordCountPerObject == null){
    		recordCountPerObject = 1;
    	}
    	string caseStatus = 'High';
    	String accountCriteria = 'select id,name,NumberOfEmployees, AnnualRevenue from Account where NumberOfEmployees > 50 and AnnualRevenue > 1000.0';
		String opportunityCriteria = 'Select id, accountId, Amount from Opportunity where Amount > 5000 and Probability < 80.0';
		String caseCriteria = 'Select id, name, Priority from Case where Priority = ' + caseStatus;
		String accountPlanCriteria = 'select id, CSM_AccountId__c,CSM_Phase_Start_Date__c from ' + nameSpace + 'CSM_Account_Plan__c where CSM_Phase_Start_Date__c = LAST_90_DAYS';    	
    	
    	for (Integer i=1; i<=recordCountPerObject; i++){
    		CSM_Play__c playForAccount = createPlayForObject('Account',accountCriteria,i);
			CSM_Play__c playForOpportunity = createPlayForObject('Opportunity',opportunityCriteria,i);
			CSM_Play__c playForCase = createPlayForObject('Case',caseCriteria,i);
			CSM_Play__c playForAccountPlan = createPlayForObject('CSM_Account_Plan__c',accountPlanCriteria,i);
			playList.add(playForAccount);
    		playList.add(playForOpportunity);
			playList.add(playForCase);
    		playList.add(playForAccountPlan);
    	}
    	insert playList;
    	return playList;
    }
	
	public CSM_Play__c createPlayForObject(string ObjName, string queryCriteria, integer loopCounter)	{
		CSM_Play__c newPlay = new CSM_Play__c();
		newPlay.CSM_isActive__c = true;
		newPlay.CSM_Display_Name__c = prefixName + ObjName + ' Play ' + loopCounter;
		newPlay.CSM_Object_Name__c = ObjName;
		newPlay.CSM_SHORT_DESCRIPTION__C = ObjName + ' Play ' + loopCounter;
		newPlay.CSM_Query_Criteria__c = queryCriteria;
		return newPlay;

	}

	//*********************Play Criteria**********************

	public List<CSM_Play_Criteria__c> createPlayCriteria(List<CSM_Play__c> playListParam){
		playCriteriaList = new List<CSM_Play_Criteria__c>();		
		for(CSM_Play__c playObj : playListParam){	
			CSM_Play_Criteria__c newPlayCriteria;
			if(playObj.CSM_Object_Name__c == 'Account')	{				
				for(integer i=1;i<=2;i++)	{
					if(i==1)	{				
						newPlayCriteria  = createPlayCriteriaForPlayObject(playObj.Id, 'Employees','NumberOfEmployees','INTEGER','>','50','',TRUE);
						playCriteriaList.add(newPlayCriteria);
					}
					else {
						newPlayCriteria  = createPlayCriteriaForPlayObject(playObj.Id, 'Annual Revenue','AnnualRevenue','CURRENCY','>','1000','',TRUE);
						playCriteriaList.add(newPlayCriteria);
					}						
				}
			}
			else if(playObj.CSM_Object_Name__c == 'Opportunity')	{				
				for(integer i=1;i<=2;i++)	{
					if(i==1)	{				
						newPlayCriteria  = createPlayCriteriaForPlayObject(playObj.Id, 'Amount','Amount','CURRENCY','>','5000','',TRUE);
						playCriteriaList.add(newPlayCriteria);
					}
					else {
						newPlayCriteria  = createPlayCriteriaForPlayObject(playObj.Id, 'Probability (%)','PERCENT','CURRENCY','<','80','',TRUE);
						playCriteriaList.add(newPlayCriteria);
					}	
				}
			}
			else if(playObj.CSM_Object_Name__c == 'Case')	{
				newPlayCriteria  = createPlayCriteriaForPlayObject(playObj.Id, 'Priority','Priority','PICKLIST','=','High','',TRUE);
				playCriteriaList.add(newPlayCriteria);
			}
			else if(playObj.CSM_Object_Name__c == nameSpace+'CSM_Account_Plan__c')	{
				newPlayCriteria  = createPlayCriteriaForPlayObject(playObj.Id, 'Phase Start Date',nameSpace+'CSM_Phase_Start_Date__c','DATE','=','','LAST_90_DAYS',FALSE);
				playCriteriaList.add(newPlayCriteria);
			}
		}
		 insert playCriteriaList;
		 return playCriteriaList;
	}   
	
	public CSM_Play_Criteria__c createPlayCriteriaForPlayObject(Id PlayId, String fieldDisplayName, string fieldName, String fieldType, string operator, String fieldValue, String DateString, boolean isSpecificdate){
		CSM_Play_Criteria__c newPlayCriteriaParam = new CSM_Play_Criteria__c();
		newPlayCriteriaParam.CSM_Play__c = PlayId;
		newPlayCriteriaParam.RLM_Field_Display_Name__c = fieldDisplayName;
		newPlayCriteriaParam.RLM_Field_Name__c = fieldName;
		newPlayCriteriaParam.RLM_Field_Type__c = fieldType;
		newPlayCriteriaParam.RLM_Operator__c = operator;
		newPlayCriteriaParam.RLM_Values__c = fieldValue;
		newPlayCriteriaParam.RLM_Date_Literal_String__c = DateString;
		newPlayCriteriaParam.RLM_Is_Specific_Date__c = isSpecificdate;
		return newPlayCriteriaParam;
	}
	//*********************Play Task**********************

	public List<CSM_Play_Task__c> createPlayTask(List<CSM_Play__c> playList, Integer noOfTaskEachPlay){
		playTaskList = new List<CSM_Play_Task__c>();
    	for(CSM_Play__c playObj : playList ){
    		for(integer i = 0; i < noOfTaskEachPlay; i++){
    			CSM_Play_Task__c newTask = new CSM_Play_Task__c();
				newTask.CSM_Assign_To__c = 'Account Owner';
				newTask.Name = prefixName + playObj.CSM_Object_Name__c +'_Task' + i;
				newTask.CSM_Days_Until_Due__c = 30;
				newTask.CSM_IsActive__c = true;
				newTask.CSM_Play__c = playObj.id;
				newTask.CSM_Description__c = 'Desc. for  Task ' + i;
    			 playTaskList.add(newTask);
    		}
		}
	 insert playTaskList;
	 return playTaskList;
	}    

	//***************** PlayBook *******************************

	 public List<CSM_Playbook__c> createPlaybook(Integer recordCount){
	    	playBookList = new List<CSM_Playbook__c>();
	    	if(recordCount == null){
	    		recordCount = 1;
	    	}
	
	    	for(Integer i=1; i<=recordCount; i++){
	    		CSM_Playbook__c newPlaybook = new CSM_Playbook__c();
	    		newPlaybook.CSM_Display_Name__c = prefixName + ' Playbook ' + i;
	    		newPlaybook.CSM_IsActive__c = true;
	    		newPlaybook.CSM_Long_Description__c = 'Long description for Playbook ' + i;
	    		newPlaybook.CSM_Short_Description__c = 'Short description for Playbook ' + i;
	    		newPlaybook.CSM_External_Id__c = '100' + i;
	    		playBookList.add(newPlaybook);
	    	}
	    	insert playBookList;
	    	return playBookList;
	  }

 	//********************PlayBookPlay*******************

	public  List<CSM_PlaybookPlay__c> createPlaybookPlay(List<CSM_Playbook__c> playBook, List<CSM_Play__c> playListParam, Integer noOfPlaysForEachPlayBook){
		playbookPlayList = new list<CSM_PlaybookPlay__c>();
		integer playCount = noOfPlaysForEachPlayBook;
		for(CSM_Playbook__c playBookObj : playBook ){
			for(integer i=0; i<noOfPlaysForEachPlayBook; i++){
				if(playCount < playListParam.size()){
					playbookPlayList.add(new CSM_PlaybookPlay__c(CSM_Playbook__c = playBookObj.Id, CSM_Play__c = playListParam[playCount - i].Id));
				}
				else {
					playbookPlayList.add(new CSM_PlaybookPlay__c(CSM_Playbook__c = playBookObj.Id, CSM_Play__c = playListParam[i].Id));
				}
			}
			playCount += noOfPlaysForEachPlayBook;
		}
    	insert playbookPlayList;
    	return playbookPlayList;
	 }

	/*public  List<CSM_PlaybookPlay__c> createPlaybookPlay(List<CSM_Playbook__c> playBookListParam, List<CSM_Play__c> playListParam){
		playbookPlayList = new list<CSM_PlaybookPlay__c>();
		for(CSM_Playbook__c playBookObj : playBookListParam ){
			for(CSM_Play__c playObj : playListParam ){
				playbookPlayList.add(new CSM_PlaybookPlay__c(CSM_Playbook__c = playBookObj.Id, CSM_Play__c = playObj.Id));
			}
		}
    	insert playbookPlayList;
    	return playbookPlayList;
	 }*/

	//********************** SP Template ****************
	
	public List<CSM_Account_Plan_Template__c> createAccountPlanTemplate(Integer recordCount){
    	
    	accPlanTemplateList = new List<CSM_Account_Plan_Template__c>();
    	for(Integer i=1; i <= recordCount; i++){
    		CSM_Account_Plan_Template__c newTemplate = new CSM_Account_Plan_Template__c();
    		newTemplate.CSM_Template_Name__c = prefixName + 'AccountPlanTemplate ' + i;
    		newTemplate.CSM_isActive__c = true;
    		accPlanTemplateList.add(newTemplate);
    	}
    	insert accPlanTemplateList;
    	return accPlanTemplateList;
       
    }
	//********************** Success Plan Phase ********************************
	
	public List<CSM_Account_Plan_Phase__c> createSuccessPlanPhase(Integer noOfPhaseForEachSuccessPlanTemplate, List<CSM_Account_Plan_Template__c> successPlanTemplateListParam){
        successPlanPhaseList = new List<CSM_Account_Plan_Phase__c>();
        for(CSM_Account_Plan_Template__c a: successPlanTemplateListParam){
            for(integer i=1; i<=noOfPhaseForEachSuccessPlanTemplate; i++){
                CSM_Account_Plan_Phase__c newSuccessPlanPhase = new CSM_Account_Plan_Phase__c();
                newSuccessPlanPhase.CSM_ACCOUNT_PLAN_TEMPLATE__C = a.id;
                newSuccessPlanPhase.CSM_PHASE_NAME__C = 'Phase ' + i;
                newSuccessPlanPhase.CSM_ORDER__C = i;
                newSuccessPlanPhase.CSM_LENGTH__C = i * 30;
                successPlanPhaseList.add(newSuccessPlanPhase);
            }
        }
        insert successPlanPhaseList;
        return successPlanPhaseList;
    }
	
	//********************* Success Plan Template Playbook **********************
	
	public List<CSM_Account_Plan_Playbook__c> createSuccessPlanPlaybook(List<CSM_Account_Plan_Template__c> successPlanTemplateListParam, List<CSM_Playbook__c> playBookListParam,Integer recordCountForEachSuccessPlanTemplate){
        successPlanPlayBookList = new List<CSM_Account_Plan_Playbook__c>();
        integer playBookCount = 1;
        for(CSM_Account_Plan_Template__c pb: successPlanTemplateListParam){			
            for(integer i=0; i<recordCountForEachSuccessPlanTemplate; i++){   
            	if(playBookCount < playBookListParam.size())	{    
					successPlanPlayBookList.add(new CSM_Account_Plan_Playbook__c(CSM_Account_Plan_Template__c = pb.Id, CSM_IsActive__c = true, CSM_Playbook__c = playBookListParam[playBookCount - i].Id));				
				}
        	}
        	playBookCount += recordCountForEachSuccessPlanTemplate;
        }
        insert successPlanPlayBookList;
        return successPlanPlayBookList;        
    }
	//********************* Success Plan Template Indicators **********************
	
	public List<CSM_Account_Plan_Template_Indicator__c> createSuccessPlanIndicator(List<CSM_Account_Plan_Template__c> successPlanTemplateListParam, List<CSM_Indicator__c> indicatorsListParam){
        accountPlanTemplateIndicatorList = new List<CSM_Account_Plan_Template_Indicator__c>();
        for(CSM_Account_Plan_Template__c st: successPlanTemplateListParam){
            for(CSM_Indicator__c ind: indicatorsListParam){
				if(ind.CSM_Object_Field_Name__c == 'Industry')	{
					CSM_Account_Plan_Template_Indicator__c indicatorCriteriaForIndustry  = createAccountPlanTemplateIndicatorObj(ind.Id,st.Id, 'Success','Technology', 'Technology','Fail','Chemicals','Chemicals','','','',1,TRUE);

					accountPlanTemplateIndicatorList.add(indicatorCriteriaForIndustry);
				}
				else if(ind.CSM_Object_Field_Name__c == nameSpace+'CSM_Health_Status__c')	{
					CSM_Account_Plan_Template_Indicator__c indicatorCriteriaForHealthStatus  = createAccountPlanTemplateIndicatorObj(ind.Id,st.Id, 'Success','Healthy', 'Healthy','Fail','Adoption','Adoption','','','',2,TRUE);
					accountPlanTemplateIndicatorList.add(indicatorCriteriaForHealthStatus);
				}
				else if(ind.CSM_Object_Field_Name__c == 'Amount')	{
					CSM_Account_Plan_Template_Indicator__c indicatorCriteriaForAmount  = createAccountPlanTemplateIndicatorObj(ind.Id,st.Id, 'Success','10000', '','Fail','','1000','Meet','1001','9999',3,TRUE);
					accountPlanTemplateIndicatorList.add(indicatorCriteriaForAmount);
				}
				else if(ind.CSM_Object_Field_Name__c == 'LeadSource')	{
					CSM_Account_Plan_Template_Indicator__c indicatorCriteriaForLeadSource  = createAccountPlanTemplateIndicatorObj(ind.Id,st.Id, 'Success','Web', 'Web','Fail','Other','Other','','','',4,TRUE);
					accountPlanTemplateIndicatorList.add(indicatorCriteriaForLeadSource);
				}
			}
        }
        insert accountPlanTemplateIndicatorList;
        return accountPlanTemplateIndicatorList;
    }
	
	private CSM_Account_Plan_Template_Indicator__c createAccountPlanTemplateIndicatorObj(Id indicatorId, Id successPlanTemplateId, String type1, String fromValue1, string toValue1,String type2, String fromValue2, string toValue2,String type3, String fromValue3, string toValue3,Integer order, boolean isActive){
		CSM_Account_Plan_Template_Indicator__c newSPTIndicator =  new CSM_Account_Plan_Template_Indicator__c();
		newSPTIndicator.CSM_Indicator__c = indicatorId;
		newSPTIndicator.CSM_Criteria_1_Type__c = type1;
		newSPTIndicator.CSM_Criteria_1_From_Value__c = fromValue1;
		newSPTIndicator.CSM_Criteria_1_To_Value__c = toValue1;
		newSPTIndicator.CSM_Criteria_2_Type__c = type2;
		newSPTIndicator.CSM_Criteria_2_From_Value__c = fromValue2;
		newSPTIndicator.CSM_Criteria_2_To_Value__c = toValue2;
		newSPTIndicator.CSM_Criteria_3_Type__c = type3;
		newSPTIndicator.CSM_Criteria_3_From_Value__c = fromValue3;
		newSPTIndicator.CSM_Criteria_3_To_Value__c = toValue3;
		newSPTIndicator.CSM_Order__c = order;
		newSPTIndicator.CSM_Account_Plan_Template__c = successPlanTemplateId;
		newSPTIndicator.CSM_IsActive__c = isActive;
		return newSPTIndicator;

	}
	
	//********************** SP ****************
	
	public List<CSM_Account_Plan__c> createAccountPlan(List<Account> accountList, List<CSM_Account_Plan_Template__c> accountPlanTemplate){
		accountPlanList = new List<CSM_Account_Plan__c>();
    		for (integer i=0;i<accountList.size();i++){
				if(accountPlanTemplate != null || !accountPlanTemplate.isEmpty()){
					CSM_Account_Plan__c accountPlan = new CSM_Account_Plan__c();
					accountPlan.CSM_Account_Plan_Template__c = accountPlanTemplate[i].id;
					accountPlan.CSM_Phase_Start_Date__c = System.today() - 1;
					accountPlan.CSM_AccountId__c = accountList[i].id;
					accountPlan.CSM_isActive__c = true;
					accountPlanList.add(accountPlan);
				}
			}  
	 insert accountPlanList;
	 return accountPlanList; 
	}

	//******************* Accounts *************
	
	public List<Account> createAccount(Integer recordCount) {
    	accountList = new List<Account>();
    	for (integer i=1; i<=recordCount; i++){
    		Account newAccount = new Account();
    		newAccount.Name = prefixName + '_Account ' + i;
    		accountList.add(newAccount);
    	}
    	insert accountList;
    	return accountList;    
    }  
	//*********************Focus Category View **********************
	
	public List<CSM_Focus_Category_View__c> createFocusCategoryView(Integer recordCountPerObject){
    	focusCategoryViewlist = new List<CSM_Focus_Category_View__c>();
    	if(recordCountPerObject == null){
    		recordCountPerObject = 1;
    	}
    	string taskStatus = 'Not Started';
    	String accountCriteria = 'WHERE NumberOfEmployees > 100';
		string accountSOQL = 'select id, name , Type, AnnualRevenue, Sic, NumberOfEmployees from Account WHERE NumberOfEmployees > 100';
		String opportunityCriteria = 'WHERE Probability <= 80.0';
		string opportunitySOQL = 'select id, name , Probability, CloseDate, TotalOpportunityQuantity, Amount from Opportunity WHERE Probability <= 80.0';
		String taskCriteria = 'and Status = '+ taskStatus;
		String taskSOQL = 'SELECT Id, CSM_Risk_Reason__c, Description, WhoId, CSM_Account__c, ActivityDate, Subject, WhatId, What.Name, CSM_Play__c, CSM_Completed_Date__c, CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_Account_Plan__c, OwnerId, Owner.Name, Status, CSM_Task_State__c, CSM_Play_Task__c, CSM_Play__r.CSM_Display_Name__c FROM Task  where CSM_Play__c != null and Status = '+taskStatus;    	
    	
    	for (Integer i=1; i<=recordCountPerObject; i++){
    		CSM_Focus_Category_View__c fCVForAccount = createFCVForObject('Account',accountCriteria,accountSOQL,'Type, AnnualRevenue, Sic, NumberOfEmployees',i);
			CSM_Focus_Category_View__c fCVForOpportunity = createFCVForObject('Opportunity',opportunityCriteria,opportunitySOQL,'Probability, CloseDate, TotalOpportunityQuantity, Amount',i);
			CSM_Focus_Category_View__c fCVForTask = createFCVForObject('Task',taskCriteria,taskSOQL,'',i);
			focusCategoryViewlist.add(fCVForAccount);
    		focusCategoryViewlist.add(fCVForOpportunity);
			focusCategoryViewlist.add(fCVForTask);
    	}
    	insert focusCategoryViewlist;
    	return focusCategoryViewlist;
    }
	public CSM_Focus_Category_View__c createFCVForObject(string ObjName, string queryCriteria, string objSOQL, String Columns, integer loopCounter)	{
		CSM_Focus_Category_View__c newFCV = new CSM_Focus_Category_View__c();
		newFCV.CSM_Display_Name__c = ObjName + ' FCV ' + loopCounter;
		newFCV.CSM_Object_Name__c = ObjName;
		newFCV.CSM_Columns__c = Columns;
		newFCV.CSM_Criteria__c = queryCriteria;
		newFCV.CSM_SOQL__c = objSOQL;
		return newFCV;
	}
	//*********************Focus Category View Criteria**********************
	public  List<CSM_Focus_Category_View_Criteria__c> createFocusCategoryCriteria(List<CSM_Focus_Category_View__c> focusCatViewListParam){
		fcvCriteriaList = new List<CSM_Focus_Category_View_Criteria__c>();		
		for(CSM_Focus_Category_View__c fcvObj : focusCatViewListParam){	
			CSM_Focus_Category_View_Criteria__c newFCVCriteria;
			if(fcvObj.CSM_Object_Name__c == 'Account')	{		
				newFCVCriteria  = createFCVCriteriaForEachObject(fcvObj.Id, 'Employees','NumberOfEmployees','INTEGER','>','100','',TRUE);
				fcvCriteriaList.add(newFCVCriteria);
			}
			else if(fcvObj.CSM_Object_Name__c == 'Opportunity')	{
				newFCVCriteria  = createFCVCriteriaForEachObject(fcvObj.Id, 'Probability (%)','Probability','PERCENT','<=','80','',TRUE);
				fcvCriteriaList.add(newFCVCriteria);
			}
			else if(fcvObj.CSM_Object_Name__c == 'Task')	{
				newFCVCriteria  = createFCVCriteriaForEachObject(fcvObj.Id, 'Status','Status','PICKLIST','=','Not Started','',TRUE);
				fcvCriteriaList.add(newFCVCriteria);
			}
		}
		 insert fcvCriteriaList;
		 return fcvCriteriaList;
	}   
	
	private CSM_Focus_Category_View_Criteria__c createFCVCriteriaForEachObject(Id fCVId, String fieldDisplayName, string fieldName, String fieldType, string operator, String fieldValue, String DateString, boolean isSpecificdate){
		CSM_Focus_Category_View_Criteria__c newFCVCriteriaParam = new CSM_Focus_Category_View_Criteria__c();
		newFCVCriteriaParam.CSM_Focus_Category_View__c = fCVId;
		newFCVCriteriaParam.RLM_Field_Display_Name__c = fieldDisplayName;
		newFCVCriteriaParam.RLM_Field_Name__c = fieldName;
		newFCVCriteriaParam.RLM_Field_Type__c = fieldType;
		newFCVCriteriaParam.RLM_Operator__c = operator;
		newFCVCriteriaParam.RLM_Values__c = fieldValue;
		newFCVCriteriaParam.RLM_Date_Literal_String__c = DateString;
		newFCVCriteriaParam.RLM_Is_Specific_Date__c = isSpecificdate;
		return newFCVCriteriaParam;
	}
	
	//*********************Focus Category View Column**********************

	public List<CSM_Focus_Category_View_Column__c> createFCVColumn(List<CSM_Focus_Category_View__c> focusCatViewListParam){
		fCVColumnList = new List<CSM_Focus_Category_View_Column__c>();		
		for(CSM_Focus_Category_View__c fcvObj : focusCatViewListParam){	
			if(fcvObj.CSM_Object_Name__c == 'Account')	{		
				CSM_Focus_Category_View_Column__c newFCVcol1  = createFCVColumnForEachObject(fcvObj.Id, 'Account Type','Type','PICKLIST','Account');
				CSM_Focus_Category_View_Column__c newFCVcol2  = createFCVColumnForEachObject(fcvObj.Id, 'Annual Revenue','AnnualRevenue','CURRENCY','Account');
				CSM_Focus_Category_View_Column__c newFCVcol3  = createFCVColumnForEachObject(fcvObj.Id, 'SIC Code','Sic','STRING','Account');
				CSM_Focus_Category_View_Column__c newFCVcol4  = createFCVColumnForEachObject(fcvObj.Id, 'Account Name','Name','STRING','Account');
				CSM_Focus_Category_View_Column__c newFCVcol5  = createFCVColumnForEachObject(fcvObj.Id, 'Employees','NumberOfEmployees','INTEGER','Account');
				fCVColumnList.add(newFCVcol1);
				fCVColumnList.add(newFCVcol2);
				fCVColumnList.add(newFCVcol3);
				fCVColumnList.add(newFCVcol4);
				fCVColumnList.add(newFCVcol5);
			}
			else if(fcvObj.CSM_Object_Name__c == 'Opportunity')	{
				CSM_Focus_Category_View_Column__c newFCVcol1  = createFCVColumnForEachObject(fcvObj.Id, 'Amount','Amount','CURRENCY','Opportunity');
				CSM_Focus_Category_View_Column__c newFCVcol2  = createFCVColumnForEachObject(fcvObj.Id, 'Name','Name','STRING','Opportunity');
				CSM_Focus_Category_View_Column__c newFCVcol3  = createFCVColumnForEachObject(fcvObj.Id, 'Probability (%)','Probability','PERCENT','Opportunity');
				CSM_Focus_Category_View_Column__c newFCVcol4  = createFCVColumnForEachObject(fcvObj.Id, 'Close Date','CloseDate','DATE','Opportunity');
				CSM_Focus_Category_View_Column__c newFCVcol5  = createFCVColumnForEachObject(fcvObj.Id, 'Quantity','TotalOpportunityQuantity','DOUBLE','Opportunity');
				fCVColumnList.add(newFCVcol1);
				fCVColumnList.add(newFCVcol2);
				fCVColumnList.add(newFCVcol3);
				fCVColumnList.add(newFCVcol4);
				fCVColumnList.add(newFCVcol5);
			}
			else if(fcvObj.CSM_Object_Name__c == 'Task')	{
				CSM_Focus_Category_View_Column__c newFCVcol1  = createFCVColumnForEachObject(fcvObj.Id, 'Status','Status','PICKLIST','Task');
				CSM_Focus_Category_View_Column__c newFCVcol2  = createFCVColumnForEachObject(fcvObj.Id, 'Success Plan Display Name',nameSpace+'CSM_Success_Plan_Display_Name__c','STRING','Task');
				CSM_Focus_Category_View_Column__c newFCVcol3  = createFCVColumnForEachObject(fcvObj.Id, 'Play Name',nameSpace+'CSM_Play_Name__c','STRING','Task');
				CSM_Focus_Category_View_Column__c newFCVcol4  = createFCVColumnForEachObject(fcvObj.Id, 'Play Task Count',nameSpace+'CSM_Play_Task_Count__c','DOUBLE','Task');
				CSM_Focus_Category_View_Column__c newFCVcol5  = createFCVColumnForEachObject(fcvObj.Id, 'Call Result','CallDisposition','STRING','Task');
				fCVColumnList.add(newFCVcol1);
				fCVColumnList.add(newFCVcol2);
				fCVColumnList.add(newFCVcol3);
				fCVColumnList.add(newFCVcol4);
				fCVColumnList.add(newFCVcol5);
			}
		}
		 insert fCVColumnList;
		 return fCVColumnList;
	}   
	
	public CSM_Focus_Category_View_Column__c createFCVColumnForEachObject(Id fCVId, String fieldDisplayName, string fieldName, String fieldType, string objName){
		CSM_Focus_Category_View_Column__c newFCVColumnParam = new CSM_Focus_Category_View_Column__c();
		newFCVColumnParam.CSM_Focus_Category_View__c = fCVId;
		newFCVColumnParam.CSM_Display_Name__c = fieldDisplayName;
		newFCVColumnParam.CSM_Object_Field_Name__c = fieldName;
		newFCVColumnParam.CSM_Object_Field_Type__c = fieldType;
		newFCVColumnParam.CSM_Object_Name__c = objName;
		return newFCVColumnParam;
	}
	
	//********************** Focus Category Group ****************
	
	public List<CSM_Focus_Category_Group__c> createFocusCategoryGroup(Integer recordCount){
    	focusCategoryGrouplist = new List<CSM_Focus_Category_Group__c>();
    	for(Integer i=1; i <= recordCount; i++){
    		CSM_Focus_Category_Group__c newFCG = new CSM_Focus_Category_Group__c();
    		newFCG.CSM_Display_Name__c = prefixName + ' FCG ' + i;
			newFCG.CSM_Group_Type__c = 'Main';
			newFCG.CSM_Order__c = i;
    		newFCG.CSM_isActive__c = true;
    		focusCategoryGrouplist.add(newFCG);
    	}
    	insert focusCategoryGrouplist;
    	return focusCategoryGrouplist;
       
    }
	//********************** Focus Category Column ********************************	
	public List<CSM_Focus_Category_Column__c> createFocusCatColumn(Integer recordCountForEachFCG, List<CSM_Focus_Category_Group__c> focusCatGroupListParam){
        focusCategoryColumnlist = new List<CSM_Focus_Category_Column__c>();
        for(CSM_Focus_Category_Group__c a: focusCatGroupListParam){
            for(integer i=1; i<=recordCountForEachFCG; i++){
                CSM_Focus_Category_Column__c newFCColumn = new CSM_Focus_Category_Column__c();
                newFCColumn.CSM_Focus_Category_Group__c = a.id;
                newFCColumn.CSM_Display_Name__c = 'Column ' + i;
                newFCColumn.CSM_Column_Order__c = i;
                focusCategoryColumnlist.add(newFCColumn);
            }
        }
        insert focusCategoryColumnlist;
        return focusCategoryColumnlist;
    }
	
	//********************** Focus Category ********************************
	/*public List<CSM_Focus_Category__c> createFocusCategories(List<CSM_Focus_Category_Column__c> focusCatColumnListParam, List<CSM_Focus_Category_View__c> focusCatViewListParam){
        focusCategoryList = new List<CSM_Focus_Category__c>();		
        for(CSM_Focus_Category_View__c v: focusCatViewListParam){
        	Integer focusCategoryOrder = 1;
        	for(CSM_Focus_Category_Column__c c: focusCatColumnListParam){
                focusCategoryList.add(new CSM_Focus_Category__c(CSM_Focus_Category_Column__c = c.Id, CSM_View_Order__c = focusCategoryOrder++, CSM_IsActive__c = true, CSM_Focus_Category_View__c = v.Id));
			}
        }
        insert focusCategoryList;
        return focusCategoryList;
    }*/
    public List<CSM_Focus_Category__c> createFocusCategories(integer recordCountForColumn, List<CSM_Focus_Category_Column__c> focusCatColumnListParam, List<CSM_Focus_Category_View__c> focusCatViewListParam){
        focusCategoryList = new List<CSM_Focus_Category__c>();		
		integer columnVariable = 0;
		integer focusCategoryOrder = 1;
        for(CSM_Focus_Category_Column__c c: focusCatColumnListParam){
			if(columnVariable > 2)	{
				columnVariable = 0;
			}	
            for(integer i=(columnVariable*recordCountForColumn)+1; i<=((columnVariable+1)*recordCountForColumn); i++){       
				if(focusCategoryOrder > recordCountForColumn)	{
					focusCategoryOrder = 1;
				}
                focusCategoryList.add(new CSM_Focus_Category__c(CSM_Focus_Category_Column__c = c.Id, CSM_View_Order__c = focusCategoryOrder, CSM_IsActive__c = true, CSM_Focus_Category_View__c = focusCatViewListParam[i-1].Id));
				focusCategoryOrder += 1;
			}
			columnVariable += 1;
        }
        insert focusCategoryList;
        return focusCategoryList;
    }
	
	public List<CSM_Batch_Success_Plan_Default__c> createBatchSuccPlanDefault(Integer totalRecords){
   			List<CSM_Batch_Success_Plan_Default__c> batchSuccPlanDefaultList = new List<CSM_Batch_Success_Plan_Default__c>();
   			for (integer i=1; i<=totalRecords; i++){
   				CSM_Batch_Success_Plan_Default__c newBatchSuccplnDefault = new CSM_Batch_Success_Plan_Default__c();
   				newBatchSuccplnDefault.CSM_Account_Manager__c = UserInfo.getUserId();
   				newBatchSuccplnDefault.CSM_Contact__c = UserInfo.getUserId();
   				newBatchSuccplnDefault.CSM_Manager__c = UserInfo.getUserId();
   				newBatchSuccplnDefault.CSM_Customer_Success_Manager__c = UserInfo.getUserId();
   				newBatchSuccplnDefault.CSM_Exec_Sponsor__c = UserInfo.getUserId();
   				newBatchSuccplnDefault.CSM_Phase_Start_Date__c = System.today();
   				newBatchSuccplnDefault.CSM_Plan_Default_Name__c = 'Test';
   				newBatchSuccplnDefault.CSM_Renewal_Manager__c = UserInfo.getUserId();
   				newBatchSuccplnDefault.CSM_Renewal_Contact__c = UserInfo.getUserId();
   				newBatchSuccplnDefault.CSM_Support_Contact__c = UserInfo.getUserId();
   				batchSuccPlanDefaultList.add(newBatchSuccplnDefault);
   			}
   			insert batchSuccPlanDefaultList;
   			return batchSuccPlanDefaultList;
   } 
    public List<REN_Batch_Activity__c> createBatchActivity(Integer totalRecords){
    	List<REN_Batch_Activity__c> batchActivityList = new List<REN_Batch_Activity__c>();
    	for (integer i=1; i<=totalRecords; i++){
	    	REN_Batch_Activity__c newBatch = new REN_Batch_Activity__c();
	    	newBatch.REN_Grouping__c = null;
	    	newBatch.REN_Source_Record_Filter__c = null;
	    	newBatch.REN_Job_Start_Date__c = System.today();
	    	newBatch.REN_Pricebook__c = null;
	    	newBatch.REN_Closed_Date_Depends_On__c = 'CreatedDate';
	    	newBatch.REN_Batch_Type__c = 'CSM_PTA';
	    	newBatch.REN_Object__c = 'Account';
	    	//newBatch.Name = 'TestBatch' + i;
	    	batchActivityList.add(newBatch);
    	}
    	insert batchActivityList;
    	return batchActivityList;
    }
	
	public CSM_Batch_Filter__c createBatchFilter() {
    	CSM_Batch_Filter__c batchFilter = new CSM_Batch_Filter__c (
			Name = 'Batch filter by date',
			CSM_IsActive__c = true
		);
		
		Insert batchFilter;
		return batchFilter;
    }
    
    public CSM_Batch_Filter_Criteria__c createBatchFilterCriteria(String id) {
    	CSM_Batch_Filter_Criteria__c batchFilterCriteria = new CSM_Batch_Filter_Criteria__c (
			Name = 'Modified by date criteria',
			CSM_Batch_Filter__c = id
		);
		
		Insert batchFilterCriteria;
		return batchFilterCriteria;
    }
}