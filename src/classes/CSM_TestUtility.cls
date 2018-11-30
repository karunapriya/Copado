public with sharing class CSM_TestUtility {
	public static CSM_Focus_Category_Group__c focusCategoryGroup;
	public static CSM_Focus_Category_Column__c focusCategoryColumn;
	public static CSM_Focus_Category__c focusCategory;
	public static CSM_Focus_Category_View__c focusCategoryView;
	public static CSM_Focus_Category_View__c focusCategoryViewTask;
	public static CSM_Focus_Category_View_Column__c focusCategoryViewColumn;
	public static CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria;

	public static CSM_Focus_Category_Group__c focusCategoryGroupTiles;
	public static CSM_Focus_Category_Column__c focusCategoryColumnTiles;
	public static CSM_Focus_Category__c focusCategoryTiles;


    public static CSM_Focus_Category_Column__c focusCategoryColumn2;   
    public static CSM_Focus_Category_Group__c focusCategoryGroup2;
    public static CSM_Focus_Category_View__c focusCategoryView2;
    public static CSM_Focus_Category_View__c focusCategoryView3;
    public static CSM_Focus_Category_View__c focusCategoryViewTask2;
	public static CSM_Focus_Category_View_Column__c focusCategoryViewColumn2;
	public static CSM_Focus_Category_View_Criteria__c focusCategoryViewCriteria2;

	public static Account acct;
	public static CSM_Account_Plan__c acctPlan;
	public static CSM_Playbook__c playBook;
	public static CSM_Play__c play;
	public static CSM_Play_Task__c playTask;
	public static Task tsk;
	public static CSM_PlaybookPlay__c playbookPlay;
	public static CSM_Play_Criteria__c playCriteria;
	
	public static CSM_Account_Plan_Playbook__c acctPlanPB;
	public static CSM_SuccessPlan_Play__c spPlay; 
		
	public static void addLicense() {
		SS_License__c license =SS_License__c.getOrgDefaults();
		if (license == null) {
			license = new SS_License__c();
			license.SetupOwnerId = UserInfo.getUserId();
			license.CSM__c = true;
			upsert license;
		}
		else 
		{
			if(license.CSM__c == false)
			{
				license.CSM__c = true;
				upsert license;
			}
		}
		
	}
	
	public static void addRenewLicense() {
		SS_License__c license =SS_License__c.getOrgDefaults();
		if (license == null) {
			license = new SS_License__c();
			license.SetupOwnerId = UserInfo.getUserId();
			license.Renew__c = true;
			upsert license;
		}
		else 
		{
			if(license.Renew__c == false)
			{
				license.Renew__c = true;
				upsert license;
			}
		}
		
	}
	
	public static void addCSMAdmin() {
		CSM_Admin__c csmAdmin = CSM_AdminDataAccess.getCSMAdminInstance();
		
		csmAdmin.CSM_Focus_Category_Objects__c = 'Account, Opportunity, Task';
		csmAdmin.CSM_Email__c = 'vishal@comitydesigns.com';
		csmAdmin.CSM_FailCriteriaColor__c = '#FF0000';
		csmAdmin.CSM_Focus_Category_Objects__c = 'Account;Opportunity;Task';
		csmAdmin.CSM_IndicatorObjects__c = 'Account;Opportunity;Contact';
		csmAdmin.CSM_MeetCriteriaColor__c = '#8BC333';
		csmAdmin.CSM_Phase_Colors__c = '#54A2CF;#8BC333;#FF8B33;#6F0A96;#BF006D;#00978C;#9E223F;#006BA9;#FBE703';
		csmAdmin.CSM_Play_Objects__c = 'Account;Opportunity;CSM_Account_Plan__c';
		csmAdmin.CSM_Risk_Reason__c = 'Adoption Issue;CSAT Issues;Onboarding Issue;Payment Issue;Renewal Staging;Support Issue;Training Issue';
		csmAdmin.CSM_Risk_Reason_Dismiss__c = 'Adoption Issue;Support Issue;Training Issue';
		csmAdmin.CSM_Risk_Reason_Cont__c = 'Adoption Issue Related;CSAT Issues Related';
		csmAdmin.CSM_Risk_Reason_Dismiss_Cont__c = 'Support Related';
		csmAdmin.CSM_SCOUT_Installed__c = false;
		csmAdmin.CSM_SuccessCriteriaColor__c = '#8BC333';
		csmAdmin.CSM_SCOUT_Installed__c = true;
		csmAdmin.CSM_Focus_Category_Column_Limit__c = 4;
		csmAdmin.CSM_Focus_Category_Tiles_Limit__c = 1;
		csmAdmin.CSM_Focus_Categories_Rec_To_Display__c = 10;
		csmAdmin.CSM_Default_Plan_Tab__c = 0;
		csmAdmin.CSM_Health_Status_Colors__c = '#51721e;#6e9b28;#8bc333;a2d356;#b8dd7f;#cfe8a7;#e5f3cf;#f4faea;#354a13';
		upsert csmAdmin;	
	}
		
	public static void insertAccount() {
		acct = new Account();
		acct.Name = 'Test Account Vish - ZZZ';
		acct.BillingState = 'GA';
		insert acct;
	}
		
	public static void insertAccountPlan(String acctId) {
		acctPlan = new CSM_Account_Plan__c();
		acctPlan.CSM_AccountId__c = acctId;
		insert acctPlan;
	}
		
	public static void insertPlayBook() {
		playBook = new CSM_Playbook__c();
		playBook.CSM_IsActive__c = true;
		playBook.CSM_Display_Name__c = 'Playbook A';
		playBook.CSM_Automated__c = false;
		playBook.CSM_Playbook_Type__c = 'Manual';
		insert playBook;
	}
	
	public static CSM_Play__c insertPlayWithoutInsert() {
		CSM_Play__c newPlay = new CSM_Play__c();
		newPlay.CSM_IsActive__c = true;
		newPlay.CSM_Automated__c = false;
		newPlay.CSM_Display_Name__c = 'Play A';
		newPlay.CSM_Object_Name__c = 'Account';
		return newPlay;
	}

	public static void insertPlay() {
		play = insertPlayWithoutInsert();
		insert play;
	}
	
	
	public static void insertPlaybookPlay(String playBookId, String playId){
		playbookPlay = new CSM_PlaybookPlay__c();
		playbookPlay.CSM_Playbook__c = playBookId;
		playbookPlay.CSM_Play__c = playId;
		insert playBookPlay;
	}
			
	public static void insertPlayTask(String playId){
		playTask = new CSM_Play_Task__c();
		playTask.CSM_IsActive__c = true;
		playTask.CSM_Assign_To__c = 'Account Owner';
		playTask.CSM_Days_Until_Due__c = 30;
		playTask.CSM_Play__c = playId;
		playTask.CSM_Description__c = 'Test A';
		insert playTask;
	}	
	
	public static void insertTask(String acctId, String acctPlanId, String playId) {
		tsk = new Task();
		tsk.WhatId = acctId;
		tsk.Subject = 'Call';
		tsk.ActivityDate = Date.today();
		tsk.CSM_Account__c = acctId;
		if(playId == null || playId == '') {
			tsk.CSM_SuccessPlan_Play__c = acctPlanId;
		} else {
			tsk.CSM_Play__c = playId;
			tsk.CSM_Account_Plan__c = acctPlanId;
		}
		tsk.Status = 'Not Started';
		tsk.csm_successplan_play__c = spPlay.Id;		
		insert tsk;
	}
		
	public static CSM_Focus_Category_View__c insertFCV(String displayName, String columns, String criteria, String soql, String objName,String currencyHeader) {
		CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
		fcv.CSM_Display_Name__c = displayName;
		fcv.CSM_Columns__c = columns;
		fcv.CSM_Criteria__c = criteria;
		fcv.CSM_SOQL__c = soql;
		fcv.CSM_Object_Name__c = objName;
		fcv.CSM_Currency_Header__c = currencyHeader;
		fcv.CSM_Filter_By_Owner_Value__c = 'My Account';
		insert fcv;
		return fcv;
	}	
	
	public static void insertFCVColumn(String viewId) {
		focusCategoryViewColumn = new CSM_Focus_Category_View_Column__c();
		focusCategoryViewColumn.CSM_Display_Name__c = 'Billing City';
		focusCategoryViewColumn.CSM_Object_Field_Name__c = 'BillingCity';
		focusCategoryViewColumn.CSM_Object_Field_Type__c = 'String';
		focusCategoryViewColumn.CSM_Object_Name__c = 'Account';
		focusCategoryViewColumn.CSM_Focus_Category_View__c = viewId;
		insert focusCategoryViewColumn;
	}
	
	
	public static void insertFCVCriteria(String viewId) {
		focusCategoryViewCriteria = new CSM_Focus_Category_View_Criteria__c();
		focusCategoryViewCriteria.RLM_Field_Name__c = 'BillingCity';
		focusCategoryViewCriteria.RLM_Field_Display_Name__c = 'Billing City';
		focusCategoryViewCriteria.RLM_Field_Type__c = 'String';
		focusCategoryViewCriteria.RLM_Operator__c = '=';
		focusCategoryViewCriteria.RLM_Values__c = 'GA';
		focusCategoryViewCriteria.CSM_Focus_Category_View__c = viewId;
		insert focusCategoryViewCriteria;
	}
	
	public static CSM_Focus_Category_View_Criteria__c createFCVCriteria(String fldName, String fldDisplayName, String fldType, String operator, String value, String viewId) {
		focusCategoryViewCriteria = new CSM_Focus_Category_View_Criteria__c();
		focusCategoryViewCriteria.RLM_Field_Name__c = fldName;
		focusCategoryViewCriteria.RLM_Field_Display_Name__c = fldDisplayName;
		focusCategoryViewCriteria.RLM_Field_Type__c = fldType;
		focusCategoryViewCriteria.RLM_Operator__c = operator;
		focusCategoryViewCriteria.RLM_Values__c = value;
		focusCategoryViewCriteria.CSM_Focus_Category_View__c = viewId;
		return focusCategoryViewCriteria;
	}
	public static void insertPlayCriteria(String playId) {
		playCriteria = new CSM_Play_Criteria__c();
		playCriteria.RLM_Field_Name__c = 'BillingCity';
		playCriteria.RLM_Field_Display_Name__c = 'Billing City';
		playCriteria.RLM_Field_Type__c = 'String';
		playCriteria.RLM_Operator__c = '=';
		playCriteria.RLM_Values__c = 'GA';
		playCriteria.CSM_Play__c = playId;
		insert playCriteria;
	}
	public static void insertFCVCriteriaIn(String viewId) {
		focusCategoryViewCriteria = new CSM_Focus_Category_View_Criteria__c();
		focusCategoryViewCriteria.RLM_Field_Name__c = 'BillingState';
		focusCategoryViewCriteria.RLM_Field_Display_Name__c = 'Billing State/Province';
		focusCategoryViewCriteria.RLM_Field_Type__c = 'STRING';
		focusCategoryViewCriteria.RLM_Operator__c = 'IN';
		focusCategoryViewCriteria.RLM_Values__c = 'GA,CA,FL';
		focusCategoryViewCriteria.CSM_Focus_Category_View__c = viewId;
		insert focusCategoryViewCriteria;
	}
		
	public static CSM_Focus_Category_Group__c insertFCG(String groupType, Integer orderNo, String displayName) {
		CSM_Focus_Category_Group__c fcg = new CSM_Focus_Category_Group__c();
		fcg.CSM_Display_Name__c = displayName;
		fcg.CSM_Group_Type__c = groupType;
		fcg.CSM_Order__c = orderNo;
		fcg.CSM_IsActive__c = true;
		insert fcg;
		System.assertNotEquals(null, fcg.Id);
		return fcg;
	}	
	
	public static CSM_Focus_Category_Column__c insertFCColumn(String fcGroupId, Integer orderNo, String displayName) {
		CSM_Focus_Category_Column__c fcc = new CSM_Focus_Category_Column__c();
		fcc.CSM_Focus_Category_Group__c = fcGroupId;
		fcc.CSM_Display_Name__c = displayName;
		fcc.CSM_Column_Order__c = orderNo;
		fcc.CSM_IsActive__c = true;
		insert fcc;
		System.assertNotEquals(null, fcc.Id);
		return fcc;
	}
	
	public static void insertFC(String columnId, Integer orderNo, String fcViewId) {
		focusCategory = new CSM_Focus_Category__c();
		focusCategory.CSM_Focus_Category_Column__c = columnId; 
		focusCategory.CSM_Focus_Category_View__c = fcViewId; 
		focusCategory.CSM_View_Order__c = orderNo;
		focusCategory.CSM_IsActive__c = true;
		insert focusCategory;
	}
	
	public static void insertSPPB(String acctPlanId,String playBookId){
		acctPlanPB = new CSM_Account_Plan_Playbook__c();
		acctPlanPB.CSM_Account_Plan__c = acctPlanId;
		acctPlanPB.CSM_Playbook__c = playBookId;
		insert acctPlanPB;
	}
	
	public static void insertSPPL(String playId,String sppbid){
		spPlay = new CSM_SuccessPlan_Play__c();
		spPlay.CSM_Play__c = playId;
		spPlay.CSM_SuccessPlan_Playbook__c = sppbid;
		insert spPlay;
	}
	
	public static void setup()
	{
		CSM_Constants.PLAY_RESULT_TRIGGER = false;
		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;
		CSM_Constants.ACCOUNT_TRIGGER = false;
		CSM_Constants.OPPORTUNITY_TRIGGER = false;
		CSM_Constants.PLAY_CRITERIA_TRIGGER = false;
		
		addLicense();
		
		addCSMAdmin();

		insertAccount();
		
		insertAccountPlan(acct.Id);
		
		insertPlayBook();
		
		insertPlay();
		
		insertPlaybookPlay(playBook.Id, play.Id);
		
		insertPlayTask(play.Id);
		
		insertSPPB(acctPlan.Id, playBook.Id);
		
		insertSPPL(play.Id, acctPlanPB.Id);
		
		insertTask(acct.Id, acctPlan.Id, play.Id);
		
		insertTask(acct.Id, spPlay.Id,null);
		
		focusCategoryGroup = insertFCG(CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_MAIN, 1, 'Test Focus Category Group Display Name 1');
		
		focusCategoryView = insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'', 
				'SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue');
		
		insertFCVColumn(focusCategoryView.Id);

		focusCategoryViewTask = insertFCV('View Task Test', '', ' WHERE CSM_Play__c!=null', CSM_Constants.TASK_SOQL + ' WHERE CSM_Play__c!=null', 'Task',null);
		
		focusCategoryColumn = insertFCColumn(focusCategoryGroup.Id, 1, 'Test Focus Category Column Display 1');
		insertFC(focusCategoryColumn.Id, 1, focusCategoryView.Id);
		
		insertFCColumn(focusCategoryGroup.Id, 2, 'Test Focus Category Column Display 2');
		insertFC(focusCategoryColumn.Id, 2, focusCategoryViewTask.Id);
		
		insertFC(focusCategoryColumn.Id,  1, focusCategoryView.Id);

		insertFCVCriteria(focusCategoryView.Id);
		
		///
		focusCategoryGroup2 = insertFCG(CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_MAIN, 1, 'Test Focus Category Group Display Name 2');
		
		focusCategoryView2 = insertFCV('View Account Test2', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState IN\'GA,CA,FL,IL\'', 
				'SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState IN\'GA,CA,FL,IL\'', 'Account',null);
		
		insertFCVColumn(focusCategoryView2.Id);

		focusCategoryView3 = insertFCV('View Opportunity Test1', 'REN_Account_ID__c, Amount, CloseDate, REN_Default_Renewal_Opportunity_Name__c', 'WHERE CloseDate < TODAY', 
				'select id, name , REN_Account_ID__c, Amount, CloseDate, REN_Default_Renewal_Opportunity_Name__c from Opportunity WHERE CloseDate < TODAY', 'Opportunity',null);
		
		insertFCVColumn(focusCategoryView3.Id);

		focusCategoryViewTask2 = insertFCV('View Task Test', '', ' WHERE CSM_Play__c!=null', CSM_Constants.TASK_SOQL + ' WHERE CSM_Play__c!=null', 'Task',null);
		focusCategoryColumn2 = insertFCColumn(focusCategoryGroup2.Id, 1, 'Test Focus Category Column Display 2');
		insertFC(focusCategoryColumn2.Id, 1, focusCategoryView2.Id);
		
		insertFCColumn(focusCategoryGroup2.Id, 2, 'Test Focus Category Column Display 2');
		insertFC(focusCategoryColumn2.Id, 2, focusCategoryViewTask2.Id);
		
		insertFC(focusCategoryColumn2.Id,  1, focusCategoryView2.Id);

		insertFCVCriteriaIn(focusCategoryView2.Id);
		
		///		
		insertFC(focusCategoryColumn.Id, 3, focusCategoryView.Id);
		
		insertFC(focusCategoryColumn.Id, 4, focusCategoryView.Id);
		
		focusCategoryGroupTiles = insertFCG(CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_TILES, 1, 'Test Focus Category Group Display Name 1');
		
		focusCategoryColumnTiles = insertFCColumn(focusCategoryGroupTiles.Id, 1, 'Test Focus Category Column Display 1');
		
		insertFC(focusCategoryColumnTiles.Id, 1, focusCategoryView.Id);
		
		insertFC(focusCategoryColumnTiles.Id, 2, focusCategoryView.Id);
		
	}
	
	public static void addCSMHelpLinks() {
		CSM_HelpLinks__c csmhelp = CSM_AdminDataAccess.getCSMHelpLinksInstance();
		 
		csmhelp.CSM_Admin_Focus_Category_Groups__c = 'focus-category-groups';
		csmhelp.CSM_ADmin_Focus_Category_Views__c = 'admin-focus-categories';
		csmHelp.CSM_Admin_Indicator_Groups__c = 'indicator-groups';
		csmHelp.CSM_Admin_Playbooks__c = 'playbooks';
		csmHelp.CSM_Admin_Plays__c = 'provide-play-details';
		csmHelp.CSM_Admin_Success_Plan_Templates__c = 'success-plan-templates';
		csmHelp.CSM_Base_Url__c = 'http://csm.helpdocsonline.com/';
		csmHelp.CSM_Overview__c = 'overview-tab';
		csmHelp.CSM_Success_Plan_Details__c = 'customer-success-plan-page';
		csmHelp.CSM_Success_Plan_Home__c = 'success-plans-tab';
		upsert csmhelp;
	}
	public static CSM_Focus_Category_View__c insertFCVTestUtility(String displayName, String columns, String criteria, String soql, 
																String objName,String currencyHeader, String relationshipDetail, Boolean isSavedSearch, 
																String filterby, String sortOrder, String filterLogic) {
		CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
		fcv.CSM_Display_Name__c = displayName;
		fcv.CSM_Columns__c = columns;
		fcv.CSM_Criteria__c = criteria;
		fcv.CSM_SOQL__c = soql;
		fcv.CSM_Object_Name__c = objName;
		fcv.CSM_Currency_Header__c = currencyHeader;
		fcv.RLM_Related_Object_Name__c = relationshipDetail;
        fcv.RLM_Is_Saved_Search__c = isSavedSearch;
        fcv.CSM_Filter_By_Owner_Value__c = filterby;
        fcv.CSM_Sort_Order__c = sortOrder;
        fcv.RLM_Filter_Logic__c = filterLogic;
		return fcv;
	}
	
	public static REN_Custom_Search_Config__c insertCustomSearchConfig(String name, String parentObject, String fieldSetApiName, String relationshipDetail, 
																		String massUpdateFieldSet, String filterableFieldSet, String flowName) {
		REN_Custom_Search_Config__c csConfig = new REN_Custom_Search_Config__c();
		csConfig.Name = name;
		csConfig.REN_Parent_Object__c = parentObject;
		csConfig.REN_Field_Set_API_Name__c = fieldSetApiName;
		csConfig.REN_Related_Object__c = relationshipDetail;
		csConfig.REN_Mass_Update_FieldSet_Name__c = massUpdateFieldSet;
		csConfig.REN_Filterable_Field_Set_Name__c = filterableFieldSet;
		csConfig.REN_Flow_Name__c = flowName;
		return csConfig;
	}
}