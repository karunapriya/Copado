global class CSM_PostInstallationScript implements InstallHandler {
	
	private String namespace = getNameSpace();
	global void onInstall(InstallContext context) {
		
	
			 if (context.previousVersion() == null) {
				generateData(context);
			 }
			 else
			 {
			 	insertHelpLinks();
			 	//setPaymentConfig();
			 	insertCSMBatchJobConfig();
			 	if(context.previousVersion().compareTo(new Version(1,23))<=0){
			 		migrateData();
			 	}
			 	if(context.previousVersion().compareTo(new Version(1,18))<=0){
			 		insertTriggerEnablement();
			 	}
			 	
			 	if(context.previousVersion().compareTo(new Version(1,25))<=0 && context.previousVersion().compareTo(new Version(1,23))>0){
			 		setisSpecificDate();
			 	}
			 	implementIsClosedForFocusCategories();
			 	if(context.previousVersion().compareTo(new Version(2,0))<=0 && context.previousVersion().compareTo(new Version(1,31))>0){
			 		updateExistingFC(false);
			 	} else {
			 		updateExistingFC(true);
			 	}
			 	
			 	if(context.previousVersion().compareTo(new Version(2,1))<=0){
			 		insertSPPBTriggerEnablement();
					migrateSPPLData();			 		
			 	}
			 			 	
                if(context.previousVersion().compareTo(new Version(2,26,6))<=0){
                	updateEncryptionKey(); 
                	updateActiveFlagFC(); 
                	insertLowTouchAdmin();
                	//insertLowTouchURL();
                }
                
                if(context.previousVersion().compareTo(new Version(2,31,13))<=0){
                	copyLogicBuilderRLMValue();
                	insertLowTouchAdmin();
               		insertDocuSignReturnURL();
               		updateSOQLExistingFC();
               		
               }          
               if(context.previousVersion().compareTo(new Version(2,39,0))>=0){
               		insertCrossUpSellDefaultLimit();
               }
               setQliThresholdDefaultLimit();
			   populateRRFieldMapping();
               insertCustomSearchCustomSetting(context);
               createPOToPODefaultMapping();
               setNewOpptyAsRenewal();
               addActiveLanguagesForLT();
               deleteFieldMapping();
               populateCaseFieldMapping();
        }
		
	}
	/** This method will be used after 2.39.* if the Custom setting value is not defined for croo-up sell**/
	public void insertCrossUpSellDefaultLimit(){
		CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();
        if(cAdmin!=null && (cAdmin.CHL_Cross_sell_Up_sell_Record_Limit__c != null && cAdmin.CHL_Cross_sell_Up_sell_Record_Limit__c != 0 && cAdmin.CHL_Cross_sell_Up_sell_Record_Limit__c > 750)){
        	cAdmin.CHL_Cross_sell_Up_sell_Record_Limit__c =  750 ;
        	upsert cAdmin;
        }
		
	}
	private static void updateActiveFlagFC(){
        List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
        Set<Id> setFCIds = new Set<id>();
        for(CSM_Focus_Category_View__c fc : [Select Id, CSM_Is_Active__c From CSM_Focus_Category_View__c LIMIT 10000]){
            fc.CSM_Is_Active__c= true;
            fcViewList.add(fc);
            setFCIds.add(fc.Id);
        }
        upsert fcViewList;
        List<Group> lstOfAllInternalGroup = [Select id,DeveloperName from Group where DeveloperName =:'AllInternalUsers' limit 1];
        if(lstOfAllInternalGroup != null && !lstOfAllInternalGroup.isEmpty()){
            shareEditExistingFC(setFCIds, lstOfAllInternalGroup.get(0).Id);
        }
    }
    
    /*This method will provice access to all Existing focus category to all internal users
     *US2142
     */    
    public static void shareEditExistingFC(set<Id> recordIds, Id userOrGroupId){
        List<CSM_Focus_Category_View__share> listOfFC = new List<CSM_Focus_Category_View__share>();
        ignoreCannedFCRestrictVisibilty(recordIds); //DE2414
        for(Id fcId: recordIds){
            CSM_Focus_Category_View__share jobShr = new CSM_Focus_Category_View__share();
            // Set the ID of record being shared.
            jobShr.ParentId = fcId;
            // Set the ID of user or group being granted access.
            jobShr.UserOrGroupId = userOrGroupId;
            // Set the access level.
            
            jobShr.AccessLevel = 'Edit';
            listOfFC.add(jobShr);
        }
        insert listOfFC;
    }
    
    /* DE2414 - To remove canned FC from providing access to all internal users   */
	private static Set<Id> ignoreCannedFCRestrictVisibilty(Set<Id> recordIdSet){
		List<CSM_Focus_Category_View__c> cannedFcList = [select id from CSM_Focus_Category_View__c where name in ('Cases On Hold', 'My Quote Completed Opps', 'My Opportunities Expiring this Week', 'Opportunities Expiring this Week', 'Open Escalated Cases', 'Completed Quotes today', 'My Overdue cases', 'My Cases due today', 'My Escalated Cases', 'Upcoming Unassigned cases', 'Overdue Unassigned cases', 'Cases due today', 'Escalated Cases', 'My opps with an On Hold Case', 'All Quote Completed Opps', 'My Opps with Unsuccessful Quote/Booking', 'Opps with Unsuccessful Quotes & Bookings', 'My Opportunities 90 DIA', 'My Not contacted Opportunities', 'My Carryover opportunities', 'My Top Deals (Oppt amount > 10K)', 'My Opps likely to close this month', 'Opportunities 90 DIA', 'Not contacted Opportunities', 'Carryover opportunities', 'Top Deals (Oppt amount > 10K)', 'Opportunities likely to close this month', 'My Quote Cases', 'My Booking cases', 'My On hold cases', 'Unassigned cases', 'My All other cases', 'Quote Cases', 'Booking cases', 'On hold cases', 'All Other Cases')];
		if(cannedFcList != null){
			for(CSM_Focus_Category_View__c fcViewObj : cannedFcList){
				if(recordIdSet.contains(fcViewObj.id)){
					recordIdSet.remove(fcViewObj.id);
				}
			}
		}
		return recordIdSet;
	}
	
	 
	public void generateData(InstallContext context) {
		updateLicenses();
		insertGroups();
		insertCustomSettings();
		insertTriggerEnablement();
		generateSSValidationsCS();
		//setPaymentConfig();
		insertLowTouchAdmin();
		//insertCharts();
		activateStdPricebook();
		mapRenewalStatusValues();
		insertCSMBatchJobConfig();
		insertCustomSearchCustomSetting(context);
		populateRRFieldMapping();
		addActiveLanguagesForLT();
		populateCaseFieldMapping();
	}
	
	private void updateLicenses() {
			SS_License__c licenseInstance = SS_License__c.getOrgDefaults();
			licenseInstance.CSM__c = false;
			licenseInstance.Renew__c = true;
			licenseInstance.Channel__c = false;
			upsert licenseInstance;
			updateEncryptionKey();
	}
	
	private void updateEncryptionKey() {
		//below code is added as part of US1256 to populate encryption key
		SS_License__c licenseInstance = SS_License__c.getOrgDefaults();
		if(licenseInstance.REN_AES_Encryption_Key__c == null || String.isBlank(licenseInstance.REN_AES_Encryption_Key__c)) {
			Blob key = Crypto.generateAesKey(256);
			licenseInstance.REN_AES_Encryption_Key__c = EncodingUtil.base64Encode(key); 			
			upsert licenseInstance;
		}
	}
	
	private void generateSSValidationsCS() {
		SS_Validations__c ssValidations = SS_Validations__c.getOrgDefaults();
		if(ssValidations == null){
			ssValidations = new SS_Validations__c();
		}
		upsert ssValidations;
	}
	
	private void insertTriggerEnablement() {
		CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
		cTriggerEnablement.CSM_AccountPlanTrigger__c = true;
		cTriggerEnablement.CSM_AccountPlan_PlaybookTrigger__c = true;
		cTriggerEnablement.CSM_PlaybookPlayTrigger__c = true;
		cTriggerEnablement.CSM_AccountTrigger__c = true;
		cTriggerEnablement.REN_AssetTrigger__c = true;
		cTriggerEnablement.CSM_CaseTrigger__c = true;
		cTriggerEnablement.CSM_OpportunityTrigger__c = true;
		cTriggerEnablement.CSM_PlayResultTrigger__c = true;
		cTriggerEnablement.CSM_TaskTrigger__c = true;
		cTriggerEnablement.REN_RenewalRelationshipTrigger__c  = true;
		cTriggerEnablement.CSM_ScoutCustomerTrigger__c  = false;		
		cTriggerEnablement.CHL_PartnerOpportunityTrigger__c = true;
		cTriggerEnablement.CHL_UserTrigger__c = true;
		cTriggerEnablement.CSM_SuccessPlanPlayTrigger__c = true;		
		cTriggerEnablement.CSM_BatchFilterTrigger__c = true;			
		cTriggerEnablement.CSM_BatchFilterTrigger__c = true;	
		cTriggerEnablement.REN_AttachmentTrigger__c = true;
		//US2680 - Added triggers
		cTriggerEnablement.CSM_LeadTrigger__c = true;
		cTriggerEnablement.CHL_PartnerRenewableLineItemTrigger__c = true;
		cTriggerEnablement.REN_OpportunityLineItemsTrigger__c = true;
		cTriggerEnablement.CHL_PortalGroupTrigger__c = true;
		cTriggerEnablement.CSM_PlaybookTrigger__c = true;
		cTriggerEnablement.CLM_Bypass_Data_Load_Validation__c = false;
		cTriggerEnablement.REN_Bypass_Metrics_Field_Calculations__c = false;
		
		upsert cTriggerEnablement;
		
	}
	
	private void insertSPPBTriggerEnablement() {
		CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
		cTriggerEnablement.CSM_AccountPlan_PlaybookTrigger__c = true;
		cTriggerEnablement.CSM_PlaybookPlayTrigger__c = true;
		upsert cTriggerEnablement;
	}
	
	private void insertLowTouchAdmin() {
        List<REN_Low_Dollar_Client__c> lstOfLT = [Select Id,REN_Low_Touch_Admin_URL__c,REN_Request_Contact_Case_Type__c,Name from REN_Low_Dollar_Client__c limit 1];
        //string lowTouchURL = lstOfLT != null && !lstOfLT.isEmpty() ? lstOfLT[0].REN_Low_Touch_Admin_URL__c : '';   
        string recordType = lstOfLT != null && !lstOfLT.isEmpty() ? lstOfLT[0].REN_Request_Contact_Case_Type__c : ''; 
        string clientName = lstOfLT != null && !lstOfLT.isEmpty() ? lstOfLT[0].Name : '';   
        REN_Low_Dollar_Client__c cLowTouchAdminProd  = new REN_Low_Dollar_Client__c();
        //cLowTouchAdminProd.REN_Low_Touch_Admin_URL__c = lowTouchURL == null || String.isblank(lowTouchURL) ? 'https://lowtouchrenewals.herokuapp.com/':lowTouchURL;
        cLowTouchAdminProd.Name = clientName == null || String.isblank(clientName) ? 'Digital Renewals' : clientName;
        cLowTouchAdminProd.Id = lstOfLT != null && !lstOfLT.isEmpty()? lstOfLT.get(0).Id:null;
        cLowTouchAdminProd.REN_Docusign__c = true;
        cLowTouchAdminProd.REN_Live_Agent__c = true;
        cLowTouchAdminProd.REN_PO_Upload__c = true;
        cLowTouchAdminProd.REN_Asparato_Payment__c = true;
        cLowTouchAdminProd.REN_Request_Contact_Case_Type__c = recordType == null || String.isblank(recordType) ? 'Digital Renewals Case' : recordType;
        upsert cLowTouchAdminProd;
        
        //insertLowTouchURL();
    }
    
    /*private void insertLowTouchURL() {
    	//DE2358 
        CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();
       // if(cAdmin == null || cAdmin.id == null) { 
        	cAdmin.REN_Low_Touch_User_URL__c = cAdmin != null && String.isblank(cAdmin.REN_Low_Touch_User_URL__c) ? 'https://lowtouchrenewals.herokuapp.com/' : cAdmin.REN_Low_Touch_User_URL__c;
			
			upsert cAdmin;
        //}
    }*/
    
    private void insertDocuSignReturnURL() {
    	REN_DocuSign_Config__c docuSign = REN_DocuSign_Config__c.getOrgDefaults();
    	if(docuSign != null && docuSign.id != null){
    		docuSign.REN_RESTAPIUrl__c = docuSign != null && String.isblank(docuSign.REN_RESTAPIUrl__c) ? 'https://demo.docusign.net/restapi/v2/accounts/' : docuSign.REN_RESTAPIUrl__c;
    		//docuSign.REN_ReturnURL__c = 'https://lowtouchrenewals.herokuapp.com/home';
    		upsert docuSign;
    	}
    }
    
	/*private void setPaymentConfig() {
		REN_Payment_Config__c config  = REN_Payment_Config__c.getOrgDefaults();
		if(config == null || config.id == null){
			config = new REN_Payment_Config__c();
			insert config;
		}
	}*/
	
	private void insertCustomSettings() {
		CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();
		cAdmin.CSM_Email__c = UserInfo.getUserEmail();
		cAdmin.CSM_Risk_Reason__c  = 'C - Adoption Issue - ADI;C - CSAT Issues - CSI;C - Onboarding Issue - ONI;C - Payment Issue - PYI;C - Renewal Staging - RNS;C - Support Issue - SPI;C - Training Issue - TRI;C - Proactive Task - PRO';
		cAdmin.CSM_Default_Plan_Tab__c = 0;
		cAdmin.CSM_Risk_Reason_Dismiss__c = 'D - Already Completed - ACD;D - Alternative Task Performed - ATP;D - Bad Timing CSM Judgment - BTJ;D - Created In Error - CIE;D - Not Relevant - NTR';
		cAdmin.CSM_FailCriteriaColor__c	= '#FF0000';
		cAdmin.CSM_Focus_Categories_Rec_To_Display__c = 10;
		cAdmin.CSM_Focus_Category_Column_Limit__c = 3;
		cAdmin.CSM_Focus_Category_Objects__c = 'Account;Case;Opportunity;Task;CSM_Account_Plan__c';
		cAdmin.CSM_Focus_Category_Tiles_Limit__c = 8;
		cAdmin.CSM_Health_Status_Colors__c = '#8BC333;#FF8B33;#9E223F;#404040';
		cAdmin.CSM_Health_Status_Options__c = 'Healthy;Low Adoption;Pending Churn;Undetermined';
		cAdmin.CSM_IndicatorObjects__c = 'Account;Opportunity;Contact';
		cAdmin.CSM_MeetCriteriaColor__c = '#8BC333';
		cAdmin.REN_Opportunity_Related_List__c = 'Contact Roles;Competitors;Partners';
		cAdmin.CSM_Phase_Colors__c = '#54A2CF;#8BC333;#FF8B33;#6F0A96;#BF006D;#00978C;#9E223F;#006BA9;#FBE703';	
		cAdmin.CSM_Play_Objects__c = 'Account;Case;Opportunity;CSM_Account_Plan__c';
		cAdmin.CSM_SCOUT_Installed__c = false;
		cAdmin.CSM_SuccessCriteriaColor__c = '#8BC333';
		cAdmin.CSM_Focus_Category_Max_Records__c = 1000;
		cAdmin.CSM_Overview_Filter_Obj__c = 'Account';
		cAdmin.CSM_Actions_Rec_Limit__c = 2500;
		cAdmin.CSM_Activity_History_Rec_Limit__c = 2500;
		cAdmin.CSM_Asset_Rec_Limit__c = 1000;
		cAdmin.CSM_Focus_Categories_Rec_Limit__c = 10000;
		cAdmin.CSM_Service_Contract_Rec_Limit__c = 1000;
		cAdmin.CSM_Health_Charts_Rec_Limit__c = 5000;
		cAdmin.CSM_Success_Task_Rec_Limit__c = 5000;
		cAdmin.CSM_Opportunity_Rec_Limit__c = 1000;
		cAdmin.CSM_Playbook_Rec_Limit__c = 250;
		cAdmin.CHL_Cross_sell_Up_sell_Record_Limit__c = 750;
		cAdmin.CSM_Overview_Filter_Attributes__c = 'OwnerId;CreatedById;LastModifiedById';
		cAdmin.CSM_Overview_Task_Filter_Attributes__c = 'OwnerId;CreatedById;LastModifiedById';		
		cAdmin.CSM_Overview_SP_Filter_Attribute__c = 'CSM_Renewal_Contact__c;CSM_Renewal_Manager__c;CSM_Support_Contact__c;CSM_Contact__c;CSM_Manager__c;CSM_Exec_Sponsor__c';
		//cAdmin.CSM_ScoutCollector__c = 'https://my.scoutanalytics.com/ptmrg/sat.ashx';
		cAdmin.CSM_Use_Revenue_Link_v2_Canvas_App__c = true;
		cAdmin.REN_Low_Touch_User_URL__c = 'https://lowtouchrenewals.herokuapp.com/';
		cAdmin.CHL_QliCount__c = 100;
		cAdmin.REN_Low_Touch_OLI_Limit__c = 10;
		cAdmin.Inside_Sales_Stages__c = 'Prospecting,Engage,Validate and Discover,Present Solution,Gain Commitment,Close It,Closed';
		cAdmin.REN_IB_Export_Records_Limit__c = 100;
		cAdmin.REN_Set_New_Opportunity_as_Renewal__c = true;
		cAdmin.REN_TimeOut_Limit__c = '10';
		cAdmin.REN_RLI_threshold_for_split_wizard__c = 100;
		upsert cAdmin;
		
		//Needs to run for any upgrade
		insertHelpLinks();
		
	}
	//Batch size custom setting
	private void insertCSMBatchJobConfig() {
		
		List<CSM_Batch_Job_Config__c> cCSMBatchJobConfigList  = new List<CSM_Batch_Job_Config__c>();
		Map<String, CSM_Batch_Job_Config__c> batchJobConfigMap = CSM_Batch_Job_Config__c.getAll();
		
		if(batchJobConfigMap == null) {
			batchJobConfigMap = new Map<String, CSM_Batch_Job_Config__c>();
		}
		if(!batchJobConfigMap.containsKey('CHL_CommunityAnalyticsBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_CommunityAnalyticsBatch', CSM_Batch_Size__c=100));
		}
		if(!batchJobConfigMap.containsKey('CHL_MasterOpportunityPermissionBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_MasterOpportunityPermissionBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('CHL_NeedStatusUpdateBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_NeedStatusUpdateBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('CHL_PartnerAccountAnalyticsBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_PartnerAccountAnalyticsBatch', CSM_Batch_Size__c=1000));
		}
		if(!batchJobConfigMap.containsKey('CHL_ServiceContractShareBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_ServiceContractShareBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('CHL_AssetSharingBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_AssetSharingBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('REN_FiscalYearOLIBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_FiscalYearOLIBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('REN_FiscalYearRRBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_FiscalYearRRBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('REN_QuoteRequestCreationBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_QuoteRequestCreationBatch', CSM_Batch_Size__c=1));
		}
		if(!batchJobConfigMap.containsKey('REN_SegmentTaskCreationBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_SegmentTaskCreationBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('REN_SetOpportunityCloseDateBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_SetOpportunityCloseDateBatch', CSM_Batch_Size__c=1));
		}
		if(!batchJobConfigMap.containsKey('REN_AsyncOppResolutionCLIBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_AsyncOppResolutionCLIBatch', CSM_Batch_Size__c=1));
		}
		if(!batchJobConfigMap.containsKey('REN_AsyncOppResolutionOLIBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_AsyncOppResolutionOLIBatch', CSM_Batch_Size__c=1));
		}
		if(!batchJobConfigMap.containsKey('REN_AsyncOppResolutionRRBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_AsyncOppResolutionRRBatch', CSM_Batch_Size__c=1));
		}
		if(!batchJobConfigMap.containsKey('REN_AsyncOppResolutionAssetBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_AsyncOppResolutionAssetBatch', CSM_Batch_Size__c=1));
		}
		if(!batchJobConfigMap.containsKey('REN_AsyncOppResolutionBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_AsyncOppResolutionBatch', CSM_Batch_Size__c=1));
		}
		if(!batchJobConfigMap.containsKey('CHL_QuoteSyncBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_QuoteSyncBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('CHL_SetQuoteSyncStatusOnOpptyBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_SetQuoteSyncStatusOnOpptyBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('CHL_CreateQuoteAndQLIBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='CHL_CreateQuoteAndQLIBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('REN_AsyncMetricsFieldCalculation')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_AsyncMetricsFieldCalculation', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('REN_FiscalYearOppBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_FiscalYearOppBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('REN_SetOppSyncPendingStatusBatch')) {
			cCSMBatchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='REN_SetOppSyncPendingStatusBatch', CSM_Batch_Size__c=200));
		}
	
		if(!cCSMBatchJobConfigList.isEmpty()) {
			upsert cCSMBatchJobConfigList Name;
		}

	}
	
	private void insertHelpLinks(){
	
		CSM_HelpLinks__c cHelpLinks = CSM_HelpLinks__c.getOrgDefaults();
		cHelpLinks.Admin_Batch_Filter_Activity__c = 'batch-filters';
		cHelpLinks.Admin_Multi_Select_Reporting__c = 'multi-select-reporting';
		cHelpLinks.Admin_Consolidation_Request_Logs__c = 'consolidation-request-logs';
		cHelpLinks.Admin_Opportunity_Generation__c = 'opportunity-generation';
		cHelpLinks.Admin_Opportunity_Updates__c = 'opportunity-updates';
		cHelpLinks.Admin_Mappings__c = 'mapping-administration';
		cHelpLinks.Admin_Mappings_Add_Field__c = 'mapping-administration';
		cHelpLinks.Admin_Channel_Portal_Configuration__c = 'channel-portal-configuration';
		cHelpLinks.Admin_Renewals_Partner_Data_Syncing__c = 'renewal-partner-data-sync';
		cHelpLinks.Consolidate_Opportunity__c = 'consolidate-opportunities';
		cHelpLinks.Admin_Automated_Generation_Log__c = 'automated-generation-log';
		cHelpLinks.Admin_Batch_Generation_Activity__c = 'batch-generation-activity	';
		cHelpLinks.Admin_Install_Base_Data_Rules__c = 'install-base-data-generation';
		cHelpLinks.Admin_Quote_Request_Log__c = 'quote-request-log';
		cHelpLinks.CSM_Admin_Task_Generation_Activity__c='task-generation-activity';
		cHelpLinks.Admin_Low_Touch__c = 'low-touch-clients';
		
		cHelpLinks.CSM_Admin_Focus_Category_Groups__c = 'focus-category-groups';
		cHelpLinks.Admin_Focus_Category_Groups_Create_Edit__c = 'create-edit-focus-category-groups';
		cHelpLinks.CSM_Admin_Focus_Category_Views__c = 'admin-focus-categories';
		cHelpLinks.CSM_Admin_Indicator_Groups__c = 'indicator-groups';
		cHelpLinks.CSM_Admin_Playbooks__c ='playbooks';
		cHelpLinks.Admin_Playbooks_and_Play__c ='create-and-edit-playbooks-and-plays';
		cHelpLinks.CSM_Admin_Plays__c = 'set-up-plays';
		cHelpLinks.CSM_Admin_Success_Plan_Templates__c = 'success-plan-templates';
		cHelpLinks.Admin_Success_Plan_Templates_Edit__c	= 'setup-success-plan-templates';
		cHelpLinks.CSM_Base_Url__c ='https://prism-setup.helpdocsonline.com/';
		cHelpLinks.CSM_Overview__c	='overview-tab';
		cHelpLinks.CSM_Success_Plan_Details__c = 'customer-success-plan-page';
		cHelpLinks.CSM_Success_Plan_Home__c	='add-new-success-plan';
		cHelpLinks.segment_overview__c = 'segmentation';
		//cHelpLinks.REN_Search_and_Move_RR__c = 'search-and-move';
		cHelpLinks.REN_Search_and_Move_RR__c = 'https://prism.helpdocsonline.com/search-move';
		//New Links
		cHelpLinks.CSM_Admin_Plan_Indicators__c = 'define-success-plan-indicators';
		cHelpLinks.CSM_Admin_Plan_Phases__c = 'setup-success-plan-templates';
		cHelpLinks.CSM_Admin_Plan_Playbooks__c = 'setup-success-plan-templates';
		cHelpLinks.CSM_Admin_Play_Criteria__c = 'define-play-criteria';
		cHelpLinks.CSM_Admin_Play_Tasks__c = 'set-up-plays';
		cHelpLinks.CSM_Health_Donut_Chart__c = 'account-health-status-chart';
		cHelpLinks.CSM_Health_Heatmap_Chart__c = 'accounts-by-health-and-days-since-last-health-check';
		cHelpLinks.CSM_Success_Plan_Details_Subtab__c = 'details';
		cHelpLinks.CSM_Success_Tasks__c = 'tasks-tab';
		cHelpLinks.CSM_Task_Complete__c = 'working-with-tasks';
		cHelpLinks.CSM_Task_Dismiss__c = 'working-with-tasks';
		cHelpLinks.CSM_Admin_Tab__c = 'admin-tab';
		cHelpLinks.CSM_Community_URL__c = 'https://srev.force.com/SREVCommunity';
		cHelpLinks.CSM_Organize_Focus_Category_Views__c = 'organize-focus-categories';
		cHelpLinks.REN_Custom_Search_URL__c = 'https://prism.helpdocsonline.com/custom-search';
		upsert cHelpLinks;
    }
	
	/*Fields starting with 'CSM' deleted and replaced with fields starting with 'RLM', migrating data to these corresponding fields
	  Setting up line numbers as well*/
	private void migrateData(){
		integer j= 0;
		String playCritQuery = 'Select ';
		List<String> playCritFldLst = new List<String>{'CSM_Date_Literal_Number__c','CSM_Date_Literal_String__c','CSM_Date_Value__c',
														'CSM_Field_Display_Name__c','CSM_Field_Name__c','CSM_Field_Type__c','CSM_Operator__c',
														'CSM_Is_Specific_Date__c','CSM_Value__c','CSM_Play__c'};
		Set<String> orgPlayCritFldSet = new Set<String> ();												
		for(String fld : playCritFldLst){
			if(hasField('CSM_Play_Criteria__c',fld)){
				playCritQuery += fld + ',';
				orgPlayCritFldSet.add(fld);
			}
		}
		if(!orgPlayCritFldSet.isEmpty()){
			playCritQuery = playCritQuery.removeEnd(',');
			playCritQuery += ' FROM CSM_Play_Criteria__c ORDER BY CSM_Play__c,CreatedDate ASC LIMIT 10000';
			List<CSM_Play_Criteria__c> playCritViewList = Database.query(playCritQuery);
			
			for(integer i = 0; i< playCritViewList.size();i++){
				if(i==0 || playCritViewList[i-1].get('CSM_Play__c') != playCritViewList[i].get('CSM_Play__c')){
					j=1;
				}
				if(orgPlayCritFldSet.contains('CSM_Date_Literal_Number__c')){
					playCritViewList[i].put('RLM_Date_Literal_Number__c',playCritViewList[i].get('CSM_Date_Literal_Number__c'));
				}
				if(orgPlayCritFldSet.contains('CSM_Date_Literal_String__c')){
					playCritViewList[i].put('RLM_Date_Literal_String__c',playCritViewList[i].get('CSM_Date_Literal_String__c'));
				}
				if(orgPlayCritFldSet.contains('CSM_Date_Value__c')){
					playCritViewList[i].put('RLM_Date_Value__c', playCritViewList[i].get('CSM_Date_Value__c'));
				}
				if(orgPlayCritFldSet.contains('CSM_Field_Display_Name__c')){
					playCritViewList[i].put('RLM_Field_Display_Name__c',playCritViewList[i].get('CSM_Field_Display_Name__c'));
				}
				if(orgPlayCritFldSet.contains('CSM_Field_Name__c')){
					playCritViewList[i].put('RLM_Field_Name__c',playCritViewList[i].get('CSM_Field_Name__c'));
				}
				if(orgPlayCritFldSet.contains('CSM_Field_Type__c')){
					playCritViewList[i].put('RLM_Field_Type__c',playCritViewList[i].get('CSM_Field_Type__c'));
				}
				if(orgPlayCritFldSet.contains('CSM_Operator__c')){
					playCritViewList[i].put('RLM_Operator__c',playCritViewList[i].get('CSM_Operator__c'));
				}
				if(orgPlayCritFldSet.contains('CSM_Is_Specific_Date__c')){
					playCritViewList[i].put('RLM_Is_Specific_Date__c',playCritViewList[i].get('CSM_Is_Specific_Date__c'));
				}
				if(orgPlayCritFldSet.contains('CSM_Value__c')){
					playCritViewList[i].put('RLM_Value__c',playCritViewList[i].get('CSM_Value__c'));
				}
					playCritViewList[i].put('RLM_LineNo__c',j);
				j++;
			}
			update playCritViewList;
		}
		
		String focusQuery = 'Select ';
		List<String> focusCatFldLst = new List<String>{'CSM_Date_Literal_Number__c','CSM_Date_Literal_String__c','CSM_Date_Value__c',
														'CSM_Field_Display_Name__c','CSM_Field_Name__c','CSM_Field_Type__c','CSM_Operator__c',
														'CSM_Is_Specific_Date__c','CSM_Value__c','CSM_Date_String__c','CSM_Focus_Category_View__c'};
		Set<String> orgFocusCatFldSet = new Set<String> ();												
		
		for(String fld : focusCatFldLst){
			if(hasField('CSM_Focus_Category_View_Criteria__c',fld)){
				focusQuery += fld + ',';
				orgFocusCatFldSet.add(fld);
			}
		}
		if(!orgFocusCatFldSet.isEmpty()){
			focusQuery = focusQuery.removeEnd(',');
			focusQuery += ' FROM CSM_Focus_Category_View_Criteria__c ORDER BY CSM_Focus_Category_View__c,CreatedDate ASC LIMIT 10000';
			List<CSM_Focus_Category_View_Criteria__c> fcvcList = Database.query(focusQuery);
			for(integer i = 0; i< fcvcList.size();i++){
				if(i==0 || fcvcList[i-1].get('CSM_Focus_Category_View__c') != fcvcList[i].get('CSM_Focus_Category_View__c'))
					j=1;
				if(orgFocusCatFldSet.contains('CSM_Date_Literal_Number__c')){
					fcvcList[i].put('RLM_Date_Literal_Number__c',fcvcList[i].get('CSM_Date_Literal_Number__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Date_Literal_String__c')){
					fcvcList[i].put('RLM_Date_Literal_String__c',fcvcList[i].get('CSM_Date_Literal_String__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Date_Value__c')){
					fcvcList[i].put('RLM_Date_Value__c', fcvcList[i].get('CSM_Date_Value__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Field_Display_Name__c')){
					fcvcList[i].put('RLM_Field_Display_Name__c',fcvcList[i].get('CSM_Field_Display_Name__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Field_Name__c')){
					fcvcList[i].put('RLM_Field_Name__c',fcvcList[i].get('CSM_Field_Name__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Field_Type__c')){
					fcvcList[i].put('RLM_Field_Type__c',fcvcList[i].get('CSM_Field_Type__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Operator__c')){
					fcvcList[i].put('RLM_Operator__c',fcvcList[i].get('CSM_Operator__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Is_Specific_Date__c')){
					fcvcList[i].put('RLM_Is_Specific_Date__c',fcvcList[i].get('CSM_Is_Specific_Date__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Value__c')){
					system.debug('COREEECCCCCT');
					fcvcList[i].put('RLM_Value__c',fcvcList[i].get('CSM_Value__c'));
				}
				if(orgFocusCatFldSet.contains('CSM_Date_String__c')){
					fcvcList[i].put('RLM_Date_String__c',fcvcList[i].get('CSM_Date_String__c'));
				}
					fcvcList[i].put('RLM_LineNo__c',j);
				j++;
			}
			update fcvcList;
		}
		String playQuery = '';
		if(hasField('CSM_Play__c','CSM_Currency_Code__c')){
			playQuery = 'SELECT CSM_Currency_Code__c FROM CSM_Play__c LIMIT 10000';
			List<CSM_Play__c> playList = Database.query(playQuery);
			for(CSM_Play__c play : playList){
				play.put('RLM_Currency_Code__c',play.get('CSM_Currency_Code__c'));
			}
			update playList;
		}
		
		String fcvQuery = '';
		if(hasField('CSM_Focus_Category_View__c','CSM_Currency_Code__c')){
			fcvQuery = 'SELECT CSM_Currency_Code__c FROM CSM_Focus_Category_View__c LIMIT 10000';
			List<CSM_Focus_Category_View__c> fcvList = Database.query(fcvQuery);
			for(CSM_Focus_Category_View__c fcv : fcvList){
				fcv.put('RLM_Currency_Code__c',fcv.get('CSM_Currency_Code__c'));
			}
			update fcvList;
		}
	} 
	
	
	/**** To migrate SPPL Display Name data in Text column ****/
	private void migrateSPPLData(){
		List<CSM_SuccessPlan_Play__c> sucessPlanPlays = [select CSM_Display_Name__c, CSM_Display_Name_Text__c from CSM_SuccessPlan_Play__c limit 50000];
		for(CSM_SuccessPlan_Play__c sucessPlanPlay : sucessPlanPlays){
			sucessPlanPlay.CSM_Display_Name_Text__c = sucessPlanPlay.CSM_Display_Name__c;
		}
		update sucessPlanPlays;
	}
	

	/**** To update SPPB CSM_Account_Plan_Template_1__c column with CSM_Account_Plan_Template__c value ****/
	/*private void migrateSPPBData(){
		List<CSM_Account_Plan_Playbook__c> sucessPlanPlaybooks = [select CSM_Account_Plan__c,CSM_Account_Plan_Template_1__c, CSM_Account_Plan_Template__c from CSM_Account_Plan_Playbook__c where CSM_Account_Plan__c = null limit 10000];
		if(sucessPlanPlaybooks != null && !sucessPlanPlaybooks.isEmpty()){
			for(CSM_Account_Plan_Playbook__c sucessPlanPlaybook : sucessPlanPlaybooks){
				sucessPlanPlaybook.CSM_Account_Plan_Template_1__c = sucessPlanPlaybook.CSM_Account_Plan_Template__c;
			}
		}
		update sucessPlanPlaybooks;
	}*/

	
	
    /**
     * @description: Insert's new Groups.
     * @param
     * @return  
     */
    private void insertGroups() {
    	Set<String> groupNames = new Set<String>();
    	groupNames.add(Label.REN_LBL_CSMGROUP_NAME);
    	groupNames.add(Label.REN_LBL_NETOPSGROUP_NAME);
    	groupNames.add(Label.REN_LBL_RENEWGROUP_NAME);
    	List<Group> groups = [SELECT Id, Name FROM GROUP WHERE DeveloperName IN :groupNames limit 10];
    	
    	Set<String> grpNames = new Set<String>();
    	if (groups!=null){
    		for (Group grp : groups){
    			grpNames.add(grp.Name);
    		}
    	}
    	if (grpNames.contains(Label.REN_LBL_CSMGROUP_NAME)==false){
			insert new Group(DeveloperName = Label.REN_LBL_CSMGROUP_NAME,
	                DoesIncludeBosses = true,
	                DoesSendEmailToMembers = false,
	                Type =Label.CSM_LBL_Group_Type,
	                Name = Label.REN_LBL_CSMGROUP_NAME);
    	}        
    	if (grpNames.contains(Label.REN_LBL_NETOPSGROUP_NAME)==false){
			insert new Group(DeveloperName = Label.REN_LBL_NETOPSGROUP_NAME, 
                DoesIncludeBosses = true,
                DoesSendEmailToMembers = false,
                Type =Label.CSM_LBL_Group_Type,
                Name =Label.REN_LBL_NETOPSGROUP_NAME);
    	}
                
    	if (grpNames.contains(Label.REN_LBL_RENEWGROUP_NAME)==false){
			insert new Group(DeveloperName = Label.REN_LBL_RENEWGROUP_NAME,
                DoesIncludeBosses = true,
                DoesSendEmailToMembers = false,
                Type =Label.CSM_LBL_Group_Type,
                Name =Label.REN_LBL_RENEWGROUP_NAME);
    	}
    	
	}
        
	/** 
	* @description: Finds the namespace for the managed package.
	* @returns the namespace string.
	*/
	private String getNamespace(){
		String nameSpacePrefix = '';
		ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'CSM_Util' limit 1];
		return (String.isNotBlank(cs.nameSpacePrefix) ?  cs.nameSpacePrefix + '__' :  '');
		 
	}
	
	private Boolean hasField(String objName, String fieldName) {
		Boolean fieldExist = false; 
		String nameSpace = getNamespace();
		Map<String, Schema.SObjectField> fsMap = getFieldMap(objName);
		if (!fsMap.isEmpty()){
			if (fsMap.containsKey(fieldName) || fsMap.containsKey(namespace+fieldName)){
				fieldExist = true;
			}
		}
		return fieldExist;
	}
	
	private Map<String, Schema.SObjectField> getFieldMap(String objName) {
		Map<String, Schema.SObjectField> fsMap = new Map<String, Schema.SObjectField>();
		String nameSpace = getNamespace();
		Map<String, Schema.SObjectType> objectNameMap = Schema.GetGlobalDescribe();
		
		Schema.SObjectType objType;
		if (objectNameMap.containsKey(objName)){
			objType = objectNameMap.get(objName);
		}
		if (objectNameMap.containsKey(nameSpace + objName)){
			objType = objectNameMap.get(nameSpace + objName);
		}
		System.debug('ObjType - '+objType);
		if (objType!=null){
			// Get the sObject describe result for the Account object
			fsMap = objType.getDescribe().fields.getMap();
		}
		return fsMap;
	}
	
	private static void setisSpecificDate(){
		List<REN_Line_Criteria__c> lineCritLst = [Select id, RLM_Is_Specific_Date__c,RLM_DateTime_Value__c From REN_Line_Criteria__c Where RLM_DateTime_Value__c != null AND RLM_Is_Specific_Date__c = false LIMIT 10000];
		for(REN_Line_Criteria__c lc : lineCritLst){
			lc.RLM_Is_Specific_Date__c = true;
		}
		update lineCritLst;
		
		List<CSM_Play_Criteria__c> playCritLst = [Select id, RLM_Is_Specific_Date__c,RLM_DateTime_Value__c From CSM_Play_Criteria__c Where RLM_DateTime_Value__c != null AND RLM_Is_Specific_Date__c = false LIMIT 10000];
		for(CSM_Play_Criteria__c pc : playCritLst){
			pc.RLM_Is_Specific_Date__c = true;
		}
		update playCritLst;
				
		List<CSM_Focus_Category_View_Criteria__c> focusCritLst = [Select id, RLM_Is_Specific_Date__c,RLM_DateTime_Value__c From CSM_Focus_Category_View_Criteria__c Where RLM_DateTime_Value__c != null AND RLM_Is_Specific_Date__c = false LIMIT 10000];
		for(CSM_Focus_Category_View_Criteria__c fcvc : focusCritLst){
			fcvc.RLM_Is_Specific_Date__c = true;
		}
		update focusCritLst;
		
	}
	
	private static void implementIsClosedForFocusCategories()
	{
		List<CSM_Focus_Category_View__c> focusCategories = [SELECT CSM_Object_Name__c,CSM_SOQL__c,Id FROM CSM_Focus_Category_View__c WHERE  CSM_Object_Name__c  = 'Task'];
		    
		List<CSM_Focus_Category_View__c> fcUpdateList = new List<CSM_Focus_Category_View__c>();
		String normalizeSOQL = null;
		String newSOQL = null;
		
		for (CSM_Focus_Category_View__c fcView : focusCategories)
		{
		    if (fcView.CSM_SOQL__c != null 
		        && fcView.CSM_SOQL__c.indexOfIgnoreCase('IsClosed') < 0)
		    {
		        normalizeSOQL = fcView.CSM_SOQL__c.normalizeSpace();
		        newSOQL = normalizeSOQL.replace(' FROM', ', IsClosed FROM');
		        fcView.CSM_SOQL__c = newSOQL;
		        fcUpdateList.add(fcView);
		    }
		}
		update fcUpdateList;
	}
	
    public static void updateExistingFC(Boolean onlyAccount){
    	List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
		for(CSM_Focus_Category_View__c fcView : [Select Id, CSM_Object_Name__c, CSM_Columns__c, CSM_SOQL__c, CSM_Currency_Header__c, CSM_Criteria__c,
													(Select Id, CSM_Focus_Category_View__c, CSM_Object_Field_Name__c, CSM_Object_Name__c, 
													CSM_Object_Field_Type__c From CSMFocusCategoryView__r) 
													From CSM_Focus_Category_View__c LIMIT 5000]){
			Boolean addFC = false;
			if(fcView != null && String.isNotBlank(fcView.CSM_Object_Name__c)){
				if (onlyAccount){
					if(fcView.CSM_Object_Name__c.equalsIgnoreCase('Account')){
						// generate Account SOQL
						addFC = generateAccountSOQL(fcView, fcView.CSMFocusCategoryView__r);
					}
				}
				else{
					addFC = true;
					if(fcView.CSM_Object_Name__c.equalsIgnoreCase('Task')){
						// generate Task SOQL
						generateTaskSOQL(fcView, fcView.CSMFocusCategoryView__r);
					}
					else if(fcView.CSM_Object_Name__c.equalsIgnoreCase('Case')){
						// generate Case SOQL
						generateCaseSOQL(fcView, fcView.CSMFocusCategoryView__r);
					}
					else if(fcView.CSM_Object_Name__c.equalsIgnoreCase('Contract')){
						// generate Contract SOQL
						generateContractSOQL(fcView, fcView.CSMFocusCategoryView__r);
					}
					else if(fcView.CSM_Object_Name__c.equalsIgnoreCase('Account')){
						// generate Account SOQL
						addFC = generateAccountSOQL(fcView, fcView.CSMFocusCategoryView__r);
					}
					else {
						// generate Other objects SOQL
						generateOtherObjectSOQL(fcView, fcView.CSMFocusCategoryView__r);
					}
				}
			}
			if (addFC == true){
				fcViewList.add(fcView);
			}
		}
		if(!fcViewList.isEmpty()){
			update fcViewList;
		}
    }
    
    private static void generateTaskSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
    	String TASK_SOQL;
    	if(getRecordTypeExists(new Task())){
			TASK_SOQL = 'SELECT Id, CSM_Risk_Reason__c, Description, WhoId, CSM_Account__c, format(ActivityDate), Subject, WhatId, What.Name, CSM_Play__c, format(CSM_Completed_Date__c), CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_Account_Plan__c, OwnerId, Owner.Name, Status, CSM_Task_State__c, CSM_Play_Task__c, CSM_Play__r.CSM_Display_Name__c,recordtype.name, IsClosed';
		}
		else{
			TASK_SOQL = 'SELECT Id, CSM_Risk_Reason__c, Description, WhoId, CSM_Account__c, format(ActivityDate), Subject, WhatId, What.Name, CSM_Play__c, format(CSM_Completed_Date__c), CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_Account_Plan__c, OwnerId, Owner.Name, Status, CSM_Task_State__c, CSM_Play_Task__c, CSM_Play__r.CSM_Display_Name__c, IsClosed';	
		}
		Set<String> selectColumns = getTaskColumnList(fcvcList, TASK_SOQL);
		if(selectColumns == null){
			selectColumns = new Set<String>();
		}
		addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
		if(!selectColumns.isEmpty()){
			String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
			TASK_SOQL += ', ' + commaSeparatedColumns;
		}
		TASK_SOQL += ' FROM Task Where CSM_Play__c != NULL';
		if(String.isNotBlank(fcView.CSM_Criteria__c)){
			TASK_SOQL += ' and (' + fcView.CSM_Criteria__c + ')';
		}
		system.debug('TASK_SOQL $$$$$$$ '+TASK_SOQL);
		fcView.CSM_SOQL__c = TASK_SOQL;
    }
    
    private static Boolean generateAccountSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
    	String soql = '';
    	Boolean hasSuccessPlan = true;
		Set<String> selectColumns = getColumnList(fcvcList);
		if(selectColumns != null && !selectColumns.isEmpty()){
			if(!selectColumns.contains('CSM_Account_Has_Success_Plan__c') && !selectColumns.contains('ServiceSource1__CSM_Account_Has_Success_Plan__c')){
				hasSuccessPlan = false;
				selectColumns.add('CSM_Account_Has_Success_Plan__c');
			}
			if(!selectColumns.contains('Name')){
				selectColumns.add('Name');
			}
		}else {
            hasSuccessPlan = false;
            selectColumns = new Set<String>();
            selectColumns.add('Name');
            selectColumns.add('CSM_Account_Has_Success_Plan__c');
		}
		
		if (hasSuccessPlan == false) {
			if(String.isNotBlank(fcView.CSM_SOQL__c)) {
				if (!fcView.CSM_SOQL__c.contains('CSM_Account_Has_Success_Plan__c')){
					addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
					String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
					soql += 'Select Id, ' + commaSeparatedColumns;
					soql += ' FROM Account ';
					if(String.isNotBlank(fcView.CSM_Criteria__c)){
						soql += fcView.CSM_Criteria__c;
					}
					system.debug('account soql $$$$$$$ '+soql);
					fcView.CSM_SOQL__c = soql;
					return true;
				}
			}
		}
		return false;
    }    
    
    private static void generateCaseSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
		String soql = '';
		Set<String> selectColumns = getColumnList(fcvcList);
		if(selectColumns != null && !selectColumns.isEmpty()){
			if(!selectColumns.contains('CaseNumber')){
				selectColumns.add('CaseNumber');
			}
		}else{
			selectColumns = new Set<String>();
			selectColumns.add('CaseNumber');
		}
		addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
		String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
		soql += 'Select Id, ' + commaSeparatedColumns;
		soql += ' FROM Case ';
		if(String.isNotBlank(fcView.CSM_Criteria__c)){
			soql += fcView.CSM_Criteria__c;
		}
		system.debug('case soql $$$$$$$ '+soql);
		fcView.CSM_SOQL__c = soql;
    }
    
    private static void generateContractSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
		String soql = '';
		Set<String> selectColumns = getColumnList(fcvcList);
		if(selectColumns != null && !selectColumns.isEmpty()){
			if(!selectColumns.contains('ContractNumber')){
				selectColumns.add('ContractNumber');
			}
		}else{
			selectColumns = new Set<String>();
			selectColumns.add('ContractNumber');
		}
		addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
		String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
		soql += 'Select Id, ' + commaSeparatedColumns;
		soql += ' FROM Contract ';
		if(String.isNotBlank(fcView.CSM_Criteria__c)){
			soql += fcView.CSM_Criteria__c;
		}
		system.debug('Contract soql $$$$$$$ '+soql);
		fcView.CSM_SOQL__c = soql;
    }
    
    private static void addHeaderCurrencyField(Set<String> selectColumns, String headerField){
    	if(String.isNotBlank(headerField)){
	    	headerField = UserInfo.isMultiCurrencyOrganization()
	    					?'FORMAT(CONVERTCURRENCY('+headerField+'))'
	    					:'FORMAT('+headerField+')';
	    	if(!selectColumns.contains(headerField)){
		    	selectColumns.add(headerField);
	    	}
    	}
    }
    
    private static void generateOtherObjectSOQL(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Column__c> fcvcList){
		String soql = '';
		Set<String> selectColumns = getColumnList(fcvcList);
		if(selectColumns != null && !selectColumns.isEmpty()){
			if(!selectColumns.contains('Name')){
				selectColumns.add('Name');
			}
		}else{
			selectColumns = new Set<String>();
			selectColumns.add('Name');
		}
		addHeaderCurrencyField(selectColumns, fcView.CSM_Currency_Header__c);
		String commaSeparatedColumns = String.join(new List<String>(selectColumns), ',');
		soql += 'Select Id, ' + commaSeparatedColumns;
		soql += ' FROM ' + fcView.CSM_Object_Name__c + ' ';
		if(String.isNotBlank(fcView.CSM_Criteria__c)){
			soql += fcView.CSM_Criteria__c;
		}
		system.debug(fcView.CSM_Object_Name__c + ' soql $$$$$$$ '+soql);
		fcView.CSM_SOQL__c = soql;
    }
    
    private static Set<String> getColumnList(List<CSM_Focus_Category_View_Column__c> fcvcList){
    	Set<String> selectColumns = new Set<String>();
    	if(fcvcList != null && !fcvcList.isEmpty()){
			for(CSM_Focus_Category_View_Column__c fcvc : fcvcList){
				if(fcvc != null && String.isNotBlank(fcvc.CSM_Object_Field_Type__c)){
					if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('REFERENCE')){
                        handleReferenceColumns(fcvc);
                        selectColumns.add(fcvc.CSM_Object_Field_Name__c);
                    }else if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Currency')){
						if(UserInfo.isMultiCurrencyOrganization()){
							selectColumns.add('FORMAT(CONVERTCURRENCY('+fcvc.CSM_Object_Field_Name__c+'))');
						}else{
							selectColumns.add('FORMAT('+fcvc.CSM_Object_Field_Name__c+')');
						}
					}else if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Double')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Integer')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Percent')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Date')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Datetime')){
						selectColumns.add('FORMAT('+fcvc.CSM_Object_Field_Name__c+')');
					}else{
						selectColumns.add(fcvc.CSM_Object_Field_Name__c);
					}
				}
			}
    	}
    	return selectColumns;
    }
    
    private static Set<String> getTaskColumnList(List<CSM_Focus_Category_View_Column__c> fcvcList, String taskSOQL){
    	Set<String> selectColumns = new Set<String>();
    	if(fcvcList != null){
			for(CSM_Focus_Category_View_Column__c fcvc : fcvcList){
				if(fcvc != null 
					&& String.isNotBlank(fcvc.CSM_Object_Field_Type__c)
					&& String.isNotBlank(fcvc.CSM_Object_Field_Name__c)
					&& !taskSOQL.contains(fcvc.CSM_Object_Field_Name__c)){
					if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('REFERENCE')){
						handleReferenceColumns(fcvc);
						selectColumns.add(fcvc.CSM_Object_Field_Name__c);
					} else if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Currency')){
						if(UserInfo.isMultiCurrencyOrganization()){
							selectColumns.add('FORMAT(CONVERTCURRENCY('+fcvc.CSM_Object_Field_Name__c+'))');
						}else{
							selectColumns.add('FORMAT('+fcvc.CSM_Object_Field_Name__c+')');
						}
					}else if(fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Double')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Integer')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Percent')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Date')
	                       || fcvc.CSM_Object_Field_Type__c.equalsIgnoreCase('Datetime')){
						selectColumns.add('FORMAT('+fcvc.CSM_Object_Field_Name__c+')');
					}else{
						selectColumns.add(fcvc.CSM_Object_Field_Name__c);
					}
				}
			}
    	}
    	return selectColumns;
    }
    
    private static Boolean getRecordTypeExists(SObject sObj){
		Boolean recordTypeExists = false;
		//Schema.DescribeSObjectResult objectResult = Task.sObjectType.getDescribe();
 		Schema.DescribeSObjectResult objectResult = sObj.getSObjectType().getDescribe();		
		List<Schema.RecordTypeInfo> recordTypeList = objectResult.getRecordTypeInfos();
		for(Schema.RecordTypeInfo option :recordTypeList) {
			if(option.isDefaultRecordTypeMapping() && option.getName() != 'Master' && option.isAvailable()) {
				recordTypeExists = true;
				break;
			}
		}
		return recordTypeExists;		
	}
	
	private static String findNameForLookup(String focusCategoryViewColumn, Map<String, Schema.SObjectField> objFieldInfo){
		string refObjName = '';
		string refRelation = '';
		Schema.DescribeFieldResult fieldDescription = objFieldInfo.get(focusCategoryViewColumn).getDescribe();
        List<Schema.sObjectType> refObjList = fieldDescription.getReferenceTo();
        refObjName = String.valueOf(refObjList[0]);	
        refRelation = fieldDescription.getRelationshipName();
        if(refObjName != 'Case' && refObjName!= 'Contract'){
        	refRelation = refRelation + '.Name';
        }else if(refObjName == 'Case'){
        	refRelation = refRelation + '.CaseNumber';
        }else if(refObjName == 'Contract'){
        	refRelation = refRelation + '.ContractNumber';
        }
        return refRelation;
	}
	
	private static void handleReferenceColumns(CSM_Focus_Category_View_Column__c fcvc){
		String refRelation = '';
		String namespace = 'ServiceSource1__';
		Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = globalDescribe.get(fcvc.CSM_Object_Name__c);
        if(sObjType == null){
            sobjType = globalDescribe.get(namespace + fcvc.CSM_Object_Name__c);
        }
        if(sObjType != null){
            Map<String, Schema.SObjectField> objFieldInfo = sobjType.getDescribe().fields.getMap();
            String fieldName = '';
            fieldName = fcvc.CSM_Object_Field_Name__c;
            refRelation = findNameForLookup(fieldName, objFieldInfo);
            fcvc.CSM_Object_Field_Name__c = refRelation;
        }
	}
	
	private void updateSOQLExistingFC(){
    	list<CSM_Focus_Category_View__c> viewList=[select Id,CSM_Sort_By__c,CSM_SOQL__c,CSM_Object_Name__c from CSM_Focus_Category_View__c where CSM_Sort_By__c=null Limit 10000];
		list<CSM_Focus_Category_View__c> updatedViews=new list<CSM_Focus_Category_View__c>();
		String nameSpace = getNamespace();
		if(viewList!=null){
			for(CSM_Focus_Category_View__c view:viewList){
				String ObjName = view.CSM_Object_Name__c;
				If(ObjName.endsWithIgnoreCase('__c')){
					ObjName  = '';
					ObjName = nameSpace + view.CSM_Object_Name__c;
				}
	    		view.CSM_Sort_By__c=Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap().get('LastModifiedDate').getDescribe().getName();
	    		view.CSM_Sort_Order__c='Desc';
	    		view.CSM_SOQL__c=view.CSM_SOQL__c+' Order By '+ view.CSM_Sort_By__c+' '+view.CSM_Sort_Order__c+' Nulls Last';
	    		updatedViews.add(view);
			}
			update updatedViews; 			
		}		
    }
    
	/* US2502 - Added below function to copy value from RLM_Value__c to new field RLM_Values__c from CSM_Focus_Category_View_Criteria__c,REN_Line_Criteria__c,PlayCriteria,CSM_Batch_Filter_Criteria__c  Object */
	private void copyLogicBuilderRLMValue(){
    	copyPlayCriteriaValues();
    	copyFCCriteriaValues();
    	copyLineCriteriaValues();
    	copyBatchFilterCriteriaValues();
	}
   
   	/* US2502 - Added below function to copy value from RLM_Value__c to new field RLM_Values__c from PlayCriteria Object */ 
	private void copyPlayCriteriaValues(){
		String nameSpace = getNamespace();
	   	if(hasField('CSM_Play_Criteria__c', nameSpace +'RLM_Value__c')){
	   		String queryString = 'select id,RLM_Values__c,RLM_Value__c from CSM_Play_Criteria__c where RLM_Value__c != null Limit 10000';
	      	List<CSM_Play_Criteria__c> playCriteriaList = Database.query(queryString);
				if(playCriteriaList != null){
	          		for(CSM_Play_Criteria__c playObj : playCriteriaList ){
	            		if(playObj.RLM_Values__c == null){
	                   		playObj.RLM_Values__c = playObj.RLM_Value__c;
		    			}
		  			}
				}
			upsert playCriteriaList;
	   }
	}  
   
	/* US2502 - Added below function to copy value from RLM_Value__c to new field RLM_Values__c from CSM_Focus_Category_View_Criteria__c Object */
	private void copyFCCriteriaValues(){
		String nameSpace = getNamespace();
	   	if(hasField('CSM_Focus_Category_View_Criteria__c', nameSpace +'RLM_Value__c')){
	   		String queryString = 'select id,RLM_Values__c,RLM_Value__c from CSM_Focus_Category_View_Criteria__c where RLM_Value__c != null Limit 10000';
	      	List<CSM_Focus_Category_View_Criteria__c> fcViewCriteriaList = Database.query(queryString);
				if(fcViewCriteriaList != null){
	          		for(CSM_Focus_Category_View_Criteria__c fcViewCriteriaObj : fcViewCriteriaList ){
	            		if(fcViewCriteriaObj.RLM_Values__c == null){
	                   		fcViewCriteriaObj.RLM_Values__c = fcViewCriteriaObj.RLM_Value__c;
		    			}
		  			}
				}
			upsert fcViewCriteriaList;
	   }
	}
	
	/* US2502 - Added below function to copy value from RLM_Value__c to new field RLM_Values__c from REN_Line_Criteria__c Object */
	private void copyLineCriteriaValues(){
        String nameSpace = getNamespace();
	   	if(hasField('REN_Line_Criteria__c', nameSpace +'RLM_Value__c')){
	   		String queryString = 'select id,RLM_Values__c,RLM_Value__c from REN_Line_Criteria__c where RLM_Value__c != null Limit 10000';
	      	List<REN_Line_Criteria__c> lineCriteriaList = Database.query(queryString);
				if(lineCriteriaList != null){
	          		for(REN_Line_Criteria__c lineCriteriaObj : lineCriteriaList ){
	            		if(lineCriteriaObj.RLM_Values__c == null){
	                   		lineCriteriaObj.RLM_Values__c = lineCriteriaObj.RLM_Value__c;
		    			}
		  			}
				}
			upsert lineCriteriaList;
	   }
	} 
  
	/* US2502 - Added below function to copy value from RLM_Value__c to new field RLM_Values__c from CSM_Batch_Filter_Criteria__c Object */
	private void copyBatchFilterCriteriaValues(){
        String nameSpace = getNamespace();
	   	if(hasField('CSM_Batch_Filter_Criteria__c', nameSpace +'RLM_Value__c')){
	   		String queryString = 'select id,RLM_Values__c,RLM_Value__c from CSM_Batch_Filter_Criteria__c where RLM_Value__c != null Limit 10000';
	      	List<CSM_Batch_Filter_Criteria__c> batchFilterCriteriaList = Database.query(queryString);
				if(batchFilterCriteriaList != null){
	          		for(CSM_Batch_Filter_Criteria__c batchFilterObj : batchFilterCriteriaList ){
	            		if(batchFilterObj.RLM_Values__c == null){
	                   		batchFilterObj.RLM_Values__c = batchFilterObj.RLM_Value__c;
		    			}
		  			}
				}
			upsert batchFilterCriteriaList;
	   }
	}
	/* US2598: This method is used to activate Standard Pricebook. */
	private void activateStdPricebook(){
		List<Pricebook2> priceBook = [Select Id, Name,IsActive From Pricebook2 Where IsStandard =:true limit 1];
		if(priceBook != null && !priceBook.isEmpty() && priceBook[0].isActive == false){
			priceBook[0].isActive = true;
			update priceBook;
		}
		
	}
	
	/*US2599: This method is used to insert Renewal Status mapping. */
	private void mapRenewalStatusValues(){
		Map<String, String> valueMap = new Map<String, String>();
		String tempValue = '';
		List<REN_Value_Mapping__c> valueMappingRecList = getValueMappingRec('REN_RR_STATUS_MAP');
		
		if(valueMappingRecList.isEmpty() || valueMappingRecList == null){
			Schema.DescribeFieldResult fieldResult = REN_Renews_To__c.REN_Renewal_Status__c.getDescribe();
    		List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
    		for( Schema.PicklistEntry picVal : pickListValues){	  
				if(picVal.getLabel().startsWith('CS') || picVal.getLabel() == Label.CSM_LBL_WON){
					valueMap.put(picVal.getLabel(),Label.CSM_LBL_WON);  
				}
				else if(picVal.getLabel().startsWith('HA') || picVal.getLabel().startsWith('NS') || picVal.getLabel() == Label.CSM_LBL_LOST){
					valueMap.put(picVal.getLabel(),Label.CSM_LBL_LOST);
				}
				else if(picVal.getLabel() == Label.CSM_LBL_OPEN){
					valueMap.put(picVal.getLabel(),Label.CSM_LBL_OPEN);
				}
    		}
    		if(valueMap != null && !valueMap.isEmpty()){
    			for(String key: valueMap.keySet()){
	    			tempValue += key + '=' + (valueMap.containsKey(key) ? valueMap.get(key) : '') + ', ';
	    		}
    		} 		
	    	REN_Value_Mapping__c valueMappingRecord = new REN_Value_Mapping__c();
	    	valueMappingRecord.REN_Value__c = tempValue;
	    	valueMappingRecord.REN_Record_Key__c = 'REN_RR_STATUS_MAP';
	    	upsert valueMappingRecord;
		}
		
	}
	
	public static List<REN_Value_Mapping__c> getValueMappingRec(String recordKey){
     	List<REN_Value_Mapping__c> valueMappingList = new List<REN_Value_Mapping__c>();    
        if(!String.isEmpty(recordKey)){
          	valueMappingList = [select id, name,
    								REN_Record_Key__c,
    								REN_Value__c
          					from REN_Value_Mapping__c
          					where REN_Record_Key__c = :recordKey
          					limit 1];
    	}
        return valueMappingList;
    }
	
	public void populateRRFieldMapping() {
		List<REN_Field_Mappings__c> existingMappingList = [SELECT CreatedById,CreatedDate,Id,Name,OwnerId,REN_Default_Value__c,REN_Field_Data_Type__c,REN_From_Field_API_Name__c,
															REN_From_Object_Api_Name__c,REN_isManualMapping__c,REN_Is_Required__c,REN_To_Field_API_Name__c,REN_To_Object_API_Name__c,SystemModstamp FROM REN_Field_Mappings__c 
															WHERE 
															(REN_From_Object_Api_Name__c = 'OpportunityLineItem' AND REN_To_Object_API_Name__c = 'REN_Renews_To__c') OR
															(REN_From_Object_Api_Name__c = 'Asset' AND REN_To_Object_API_Name__c = 'REN_Renews_To__c') OR
															(REN_From_Object_Api_Name__c = 'ContractLineItem' AND REN_To_Object_API_Name__c = 'REN_Renews_To__c')];
		Set<String> fieldMappingSet = new Set<String>();
		if(existingMappingList != null && !existingMappingList.isEmpty()) {
			for(REN_Field_Mappings__c lst : existingMappingList) {
				fieldMappingSet.add(lst.REN_From_Object_Api_Name__c+'-'+lst.REN_To_Object_API_Name__c);
			}
		}
		List<REN_Field_Mappings__c> fieldMappingList = new List<REN_Field_Mappings__c>();
		createListOLI2RLI(fieldMappingSet, fieldMappingList);
		createListAsset2RLI(fieldMappingSet, fieldMappingList);
		createListCLI2RLI(fieldMappingSet, fieldMappingList);
    	if(fieldMappingList != null && !fieldMappingList.isEmpty()) {
    		insert fieldMappingList;	
    	}
    
	}
	
	private void createListOLI2RLI(Set<String> fieldMappingSet, List<REN_Field_Mappings__c> fieldMappingList) {
		if(!fieldMappingSet.contains('OpportunityLineItem-REN_Renews_To__c')) {
			fieldMappingList.add(createDefaultFieldMapping('Opportunity Line Item → Renewal Relationship', 'OpportunityLineItem', 'REN_Renews_To__c', 'CreatedById', 'OwnerId', 'REFERENCE', true)); 
	    	fieldMappingList.add(createDefaultFieldMapping('Opportunity Line Item → Renewal Relationship', 'OpportunityLineItem', 'REN_Renews_To__c', 'Quantity', namespace + 'REN_Quantity__c', 'NUMBER', false));
	    	fieldMappingList.add(createDefaultFieldMapping('Opportunity Line Item → Renewal Relationship', 'OpportunityLineItem', 'REN_Renews_To__c', 'UnitPrice', namespace + 'REN_Previous_Price__c','CURRENCY', false));
	    	fieldMappingList.add(createDefaultFieldMapping('Opportunity Line Item → Renewal Relationship', 'OpportunityLineItem', 'REN_Renews_To__c', 'REN_Start_Date__c', namespace + 'REN_Start_Date__c','DATE', false));
	    	fieldMappingList.add(createDefaultFieldMapping('Opportunity Line Item → Renewal Relationship', 'OpportunityLineItem', 'REN_Renews_To__c', 'REN_End_Date__c', namespace + 'REN_End_Date__c', 'DATE', false));
		}
	}
	
	private void createListAsset2RLI(Set<String> fieldMappingSet, List<REN_Field_Mappings__c> fieldMappingList) {
		if(!fieldMappingSet.contains('Asset-REN_Renews_To__c')) {
    		fieldMappingList.add(createDefaultFieldMapping('Asset → Renewal Relationship', 'Asset', 'REN_Renews_To__c', 'CreatedById', 'OwnerId','REFERENCE', true));
	    	fieldMappingList.add(createDefaultFieldMapping('Asset → Renewal Relationship', 'Asset', 'REN_Renews_To__c', 'Quantity', namespace + 'REN_Quantity__c','NUMBER',false));
	    	fieldMappingList.add(createDefaultFieldMapping('Asset → Renewal Relationship', 'Asset', 'REN_Renews_To__c', 'Price', namespace + 'REN_Previous_Price__c','CURRENCY', false));
	    	fieldMappingList.add(createDefaultFieldMapping('Asset → Renewal Relationship', 'Asset', 'REN_Renews_To__c', namespace + 'REN_Start_Date__c', namespace + 'REN_Start_Date__c','DATE', false));
	    	fieldMappingList.add(createDefaultFieldMapping('Asset → Renewal Relationship', 'Asset', 'REN_Renews_To__c', namespace + 'REN_End_Date__c', namespace + 'REN_End_Date__c', 'DATE', false));
    	}
	}
	
	private void createListCLI2RLI(Set<String> fieldMappingSet, List<REN_Field_Mappings__c> fieldMappingList) {
		if(!fieldMappingSet.contains('ContractLineItem-REN_Renews_To__c')) {
    		fieldMappingList.add(createDefaultFieldMapping('Contract Line Item → Renewal Relationship', 'ContractLineItem', 'REN_Renews_To__c', 'CreatedById', 'OwnerId','REFERENCE', true));
	    	fieldMappingList.add(createDefaultFieldMapping('Contract Line Item → Renewal Relationship', 'ContractLineItem', 'REN_Renews_To__c', 'Quantity', namespace + 'REN_Quantity__c','NUMBER', false));
	    	fieldMappingList.add(createDefaultFieldMapping('Contract Line Item → Renewal Relationship', 'ContractLineItem', 'REN_Renews_To__c', 'TotalPrice', namespace + 'REN_Previous_Price__c','CURRENCY', false));
	    	fieldMappingList.add(createDefaultFieldMapping('Contract Line Item → Renewal Relationship', 'ContractLineItem', 'REN_Renews_To__c', 'StartDate', namespace + 'REN_Start_Date__c', 'DATE', false));
	    	fieldMappingList.add(createDefaultFieldMapping('Contract Line Item → Renewal Relationship', 'ContractLineItem', 'REN_Renews_To__c', 'EndDate', namespace + 'REN_End_Date__c','DATE', false));
    	}
	}
	
    private REN_Field_Mappings__c createDefaultFieldMapping(String mappingName, String fromObject, String toObject, String fromFieldApiName, String toFieldApiName, String toFieldType, Boolean isRequired){
        REN_Field_Mappings__c newMapping = createDefaultFieldMapping(mappingName,fromObject,toObject,fromFieldApiName,toFieldApiName,toFieldType,isRequired,'');
        return newMapping;
    }
    private REN_Field_Mappings__c createDefaultFieldMapping(String mappingName, String fromObject, String toObject, String fromFieldApiName, String toFieldApiName, String toFieldType, Boolean isRequired, String defaultValue){
        REN_Field_Mappings__c newMapping = new REN_Field_Mappings__c();
        newMapping.REN_From_Object_API_Name__c = fromObject;
        newMapping.Name = mappingName;
        newMapping.REN_To_Field_API_Name__c = toFieldApiName;
        newMapping.REN_To_Object_API_Name__c = toObject;
        newMapping.REN_From_Field_API_Name__c = fromFieldApiName;
        newMapping.REN_Is_Required__c = isRequired;
        newMapping.REN_Field_Data_Type__c = toFieldType;
        newMapping.REN_Default_Value__c = defaultValue;
        return newMapping;
    }
    
	private void insertCustomSearchCustomSetting(InstallContext context) {
		
		String nameSpace = 'ServiceSource1__';
		String nameSpacePrefix21 = 'SSI_ZTH__';
     	List<REN_Custom_Search_Config__c> configRecords = [select name, REN_Parent_Object__c, REN_Field_Set_API_Name__c, REN_Related_Object__c, REN_Grandparent_Relation__c from REN_Custom_Search_Config__c Limit 1000];
     	Set<String> objectSet = new Set<String>();
     	if(configRecords != null && !configRecords.isEmpty()) {
	     	for(REN_Custom_Search_Config__c record : configRecords) {
	     		objectSet.add(record.REN_Parent_Object__c);
	     	}
     	}
     	configRecords = new List<REN_Custom_Search_Config__c>();
     	REN_Custom_Search_Config__c customSearchConfigRec;
     	
     	if(!objectSet.contains('Opportunity')) {
     		customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Opportunity';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Opportunity_Custom_Search';
	     	//customSearchConfigRec.REN_Related_Object__c = '';
	     	customSearchConfigRec.REN_Grandparent_Relation__c = 'AccountId';
	     	configRecords.add(customSearchConfigRec);
     		
     		customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Opportunity by Quote';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Opportunity_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Quote.OpportunityId';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Opportunity by Renewable Line Item';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Opportunity_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = nameSpace + 'REN_Renews_To__c.' + nameSpace + 'REN_Renews_To__c';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Opportunity by Opportunity Line Item';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Opportunity_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'OpportunityLineItem.OpportunityId';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Opportunity by Case';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Opportunity_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Case.' + nameSpacePrefix21 + 'Opportunity__c';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Opportunity by Asset';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Opportunity_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Asset.' + nameSpace + 'REN_Opportunity__c';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Opportunity by Partner Opportunity';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Opportunity_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = nameSpace + 'CHL_Partner_Opportunity__c.' + nameSpace + 'CHL_Opportunity__c';
	     	configRecords.add(customSearchConfigRec);
     	}else{
     		//if(context.previousVersion().compareTo(new Version(3,8)) < 0){
 			List<REN_Custom_Search_Config__c> existingRecords = new List<REN_Custom_Search_Config__c>([select name, REN_Parent_Object__c, REN_Field_Set_API_Name__c, REN_Related_Object__c, REN_Grandparent_Relation__c from REN_Custom_Search_Config__c where REN_Parent_Object__c = 'Opportunity' AND REN_Related_Object__c = null AND REN_Grandparent_Relation__c = null Limit 1]);
            if(!existingRecords.isEmpty()){
                existingRecords[0].REN_Grandparent_Relation__c = 'AccountId';
 				update existingRecords;
            }
     		//}
     	}
     	
     	if(!objectSet.contains('Case')) {
     		customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Case';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Case';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Case_Custom_Search';
	     	//customSearchConfigRec.REN_Related_Object__c = '';
	     	configRecords.add(customSearchConfigRec);
     		
	     	/*customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Case by Opportunity';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Case';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Case_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Opportunity.' + nameSpacePrefix21 + 'Opportunity_Case_Lookup_1__c';
	     	configRecords.add(customSearchConfigRec);*/
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Case by Quote';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Case';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Case_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Quote.' + nameSpacePrefix21 + 'Case__c';
	     	configRecords.add(customSearchConfigRec);
     	}
     	
     	if(!objectSet.contains('Asset')) {
     		customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Asset';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Asset';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Asset_Custom_Search';
	     	//customSearchConfigRec.REN_Related_Object__c = '';
	     	configRecords.add(customSearchConfigRec);
     		
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Asset by Case';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Asset';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Asset_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Case.AssetId';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Asset by Opportunity Line Item';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Asset';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Asset_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'OpportunityLineItem.' + nameSpace + 'REN_Covered_Asset__c';
	     	configRecords.add(customSearchConfigRec);
     	}
     	if(!objectSet.contains('Account')) {
     		customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Account';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Account';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Account_Custom_Search';
	     	//customSearchConfigRec.REN_Related_Object__c = '';
	     	configRecords.add(customSearchConfigRec);
     		
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Account by Contact';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Account';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Account_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Contact.AccountId';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Account by Case';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Account';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Account_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Case.AccountId';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Account by Opportunity';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Account';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Account_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Opportunity.AccountId';
	     	configRecords.add(customSearchConfigRec);
	     	
	     	customSearchConfigRec = new REN_Custom_Search_Config__c();
	     	customSearchConfigRec.Name = 'Account by Asset';
	     	customSearchConfigRec.REN_Parent_Object__c = 'Account';
	     	customSearchConfigRec.REN_Field_Set_API_Name__c = nameSpace + 'REN_Account_Custom_Search';
	     	customSearchConfigRec.REN_Related_Object__c = 'Asset.AccountId';
	     	configRecords.add(customSearchConfigRec);
     	}
     	if(!configRecords.isEmpty()){
     		insert configRecords;
     	}
     }
     
     /* US3017 - This method is used to create PO->PO Mappings PO's recreation during the Split/consolidate process */
     private void createPOToPODefaultMapping() {
		String nameSpace = getNamespace();
        List<REN_Field_Mappings__c> fieldMappingList = new List<REN_Field_Mappings__c>();
        List<REN_Field_Mappings__c> existingMappingList = [SELECT Id,Name,OwnerId,REN_Default_Value__c,REN_Field_Data_Type__c,REN_From_Field_API_Name__c,
															REN_From_Object_Api_Name__c,REN_isManualMapping__c,REN_Is_Required__c,REN_To_Field_API_Name__c,REN_To_Object_API_Name__c FROM REN_Field_Mappings__c 
															WHERE Name = 'Partner Opportunity → Partner Opportunity'];
		if(existingMappingList.isEmpty()){
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', 'Name', 'Name','STRING', true));
			//fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity',nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Sales_Stage__c', nameSpace+'CHL_Sales_Stage__c','PICKLIST', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Color_Commit__c', nameSpace+'CHL_Color_Commit__c','PICKLIST', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c',nameSpace+ 'CHL_Partner_Opportunity__c', nameSpace+'CHL_Close_Date__c', nameSpace+'CHL_Close_Date__c','Date', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Expiration_Date__c', nameSpace+'CHL_Expiration_Date__c','Date', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_EQ__c', nameSpace+'CHL_EQ__c','NUMBER', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_FY__c', nameSpace+'CHL_FY__c','STRING', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Account_1__c', nameSpace+'CHL_Partner_Account_1__c','REFERENCE', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Account_1_Type__c', nameSpace+'CHL_Partner_Account_1_Type__c','PICKLIST', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Account_2__c', nameSpace+'CHL_Partner_Account_2__c','REFERENCE', true));
			fieldMappingList.add(createDefaultFieldMapping('Partner Opportunity → Partner Opportunity', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Opportunity__c', nameSpace+'CHL_Partner_Account_2_Type__c', nameSpace+'CHL_Partner_Account_2_Type__c','PICKLIST', true));
            insert fieldMappingList;
		}	
	}
	
	private void setQliThresholdDefaultLimit(){
		CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();
		if(cAdmin.REN_Low_Touch_OLI_Limit__c == null){
			cAdmin.REN_Low_Touch_OLI_Limit__c = 10;	
		}
		if(cAdmin.CHL_QliCount__c == null){
			cAdmin.CHL_QliCount__c = 100;
		}
		if(cAdmin.Inside_Sales_Stages__c == null){
			cAdmin.Inside_Sales_Stages__c = 'Prospecting,Engage,Validate and Discover,Present Solution,Gain Commitment,Close It,Closed';
		}
		if(cAdmin.REN_IB_Export_Records_Limit__c == null){
			cAdmin.REN_IB_Export_Records_Limit__c = 100;			
		}
		if(cAdmin.REN_TimeOut_Limit__c == null){
			cAdmin.REN_TimeOut_Limit__c = '10';
		}
		if(cAdmin.REN_RLI_threshold_for_split_wizard__c == null){
			cAdmin.REN_RLI_threshold_for_split_wizard__c = 100;
		}
		upsert cAdmin;
	}
	
	private void setNewOpptyAsRenewal(){
		CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();
		if(cAdmin.REN_Set_New_Opportunity_as_Renewal__c == false){
			cAdmin.REN_Set_New_Opportunity_as_Renewal__c = true;
			upsert cAdmin;
		}
		
	}
	
	private void addActiveLanguagesForLT(){
    	Map<String, REN_LT_Active_Languages__c> ltLanguagesMap  = REN_LT_Active_Languages__c.getAll();
		if(ltLanguagesMap == null || ltLanguagesMap.isEmpty() ) {
    		List<REN_LT_Active_Languages__c> activeLanguagesList = new List<REN_LT_Active_Languages__c>();
    		activeLanguagesList.add(setLangaugeForLT('English', 'en-US', 'English'));
    		activeLanguagesList.add(setLangaugeForLT('French', 'fr', 'français'));
    		activeLanguagesList.add(setLangaugeForLT('German', 'de', 'Deutsch'));
    		activeLanguagesList.add(setLangaugeForLT('Italian', 'it', 'italiano'));
    		activeLanguagesList.add(setLangaugeForLT('Spanish', 'es', 'Español'));
    		activeLanguagesList.add(setLangaugeForLT('Chinese (Simplified)', 'zh_CN', '中文'));
    		insert activeLanguagesList;
        }
    }
    
    private REN_LT_Active_Languages__c setLangaugeForLT(String Language, String langCode, String nativeCode){
    	REN_LT_Active_Languages__c lang = new REN_LT_Active_Languages__c();
    	lang.name = Language;
    	lang.REN_LT_Language_Code__c = langCode;
    	lang.REN_LT_Language_Native_Value__c = nativeCode;
    	return lang;
    }
    
    /* US3600 - Removed mappings for REN_Original_Line_Item_ID__c field from OLI and QLI*/
    private void deleteFieldMapping(){
    	List<REN_Field_Mappings__c> existingMappingList = [SELECT id FROM REN_Field_Mappings__c where (REN_From_Field_API_Name__c like '%REN_Original_Line_Item_ID__c' OR  (REN_To_Field_API_Name__c like '%REN_Original_Line_Item_ID__c')) ];
    	if(existingMappingList != null){
    		delete existingMappingList;
    	}
    }
    
    /* private void debugCode(Exception ex){

		CSM_Batch_Result__c	batchResult = new CSM_Batch_Result__c();
		
		batchResult.CSM_Batch_Start_Time__c = System.now();
		batchResult.CSM_Module__c = 'Post Instell Script'; 
		batchResult.CSM_Status__c = 'Failed';
		batchResult.CSM_Objects_Processed__c = 'Post Instell Script'; 
		batchResult.CSM_BatchId__c = 'Failed';
		batchResult.CSM_Error_Description__c = 'Message : ' + ex.getMessage() + '\nLine no : ' + ex.getLineNumber() + '\n getStackTraceString ' + ex.getStackTraceString() + '\n' + ex.getCause();
		insert batchResult;
		
		Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
        list<String> listEmailMembers = new list<String>();
        listEmailMembers.add('servicesource@comitydesigns.com');
        emailTobeSent.setToAddresses(listEmailMembers);
        emailTobeSent.setSubject('Post install exception');
        emailTobeSent.setHtmlBody('Message : ' + ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' getStackTraceString ' + ex.getStackTraceString() + '' + ex.getCause());
        Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
     } */
     
     
     private void populateCaseFieldMapping() {
		List<REN_Field_Mappings__c> existingMappingList = [SELECT CreatedById,CreatedDate,Id,Name,OwnerId,REN_Default_Value__c,REN_Field_Data_Type__c,REN_From_Field_API_Name__c,
															REN_From_Object_Api_Name__c,REN_isManualMapping__c,REN_Is_Required__c,REN_To_Field_API_Name__c,REN_To_Object_API_Name__c,SystemModstamp FROM REN_Field_Mappings__c 
															WHERE 
															(REN_From_Object_Api_Name__c = 'Opportunity' AND REN_To_Object_API_Name__c = 'Case') OR
															(REN_From_Object_Api_Name__c = 'Account' AND REN_To_Object_API_Name__c = 'Case')];
		Set<String> fieldMappingSet = new Set<String>();
		if(existingMappingList != null && !existingMappingList.isEmpty()) {
			for(REN_Field_Mappings__c lst : existingMappingList) {
				fieldMappingSet.add(lst.REN_From_Object_Api_Name__c+'-'+lst.REN_To_Object_API_Name__c);
			}
		}
		List<REN_Field_Mappings__c> fieldMappingList = new List<REN_Field_Mappings__c>();
		createOpptyToCaseDefaultMapping(fieldMappingSet, fieldMappingList);
		createAccountToCaseDefaultMapping(fieldMappingSet, fieldMappingList);
    	if(fieldMappingList != null && !fieldMappingList.isEmpty()) {
    		insert fieldMappingList;	
    	}
    
	}
 	/* US3896 : Default mapping for Opportunity to Case. */
	private void createOpptyToCaseDefaultMapping(Set<String> fieldMappingSet, List<REN_Field_Mappings__c> fieldMappingList) {
		if(!fieldMappingSet.contains('Opportunity-Case')){
			fieldMappingList.add(createDefaultFieldMapping('Opportunity → Case', 'Opportunity', 'Case', 'Id', 'SSI_ZTH__Opportunity__c','REFERENCE', true,''));
			fieldMappingList.add(createDefaultFieldMapping('Opportunity → Case', 'Opportunity', 'Case', 'AccountId', 'AccountId','REFERENCE', true,''));
			fieldMappingList.add(createDefaultFieldMapping('Opportunity → Case', 'Opportunity', 'Case', '','Origin', 'PICKLIST', true,'CRM User'));
		}	
	}
	
	/* US3896 : Default mapping for Account to Case. */
	private void createAccountToCaseDefaultMapping(Set<String> fieldMappingSet, List<REN_Field_Mappings__c> fieldMappingList) {
		if(!fieldMappingSet.contains('Account-Case')){
			fieldMappingList.add(createDefaultFieldMapping('Account → Case', 'Account', 'Case', 'Id', 'AccountId','REFERENCE', true,''));
			fieldMappingList.add(createDefaultFieldMapping('Account → Case', 'Account', 'Case', '','Origin', 'PICKLIST', true,'CRM User'));
		}	
	}
			
}