global class PostInstallationScript implements InstallHandler {

	 String errorDetails = '';
	
	global void onInstall(InstallContext context) {
		if (context.previousVersion() == null){
			setZenithCustomSetting(errorDetails);
			insertTriggerEnablement();
		}else if (context.previousVersion()!= null){
        	if (context.previousVersion().compareTo(new Version(2,26))<0){
                setZenithCustomSetting(errorDetails);
            }
            if(context.previousVersion().compareTo(new Version(3,18))<0){
            	upgradeObjectFieldsValidations();	
            }
        }
        deleteCannedFCRecords(context);
        insertObjectFieldsValidations();
        createCannedFCRecords(context);
        insertUsersToPublicGroups();
        insertCSMBatchJobConfig();
        updateSOQLExistingFCV();
        upsertCustomSearchConfig();
        if(!String.isBlank(errorDetails)){
        	sendEmail(errorDetails);
        }
   }
   
   public void upsertCustomSearchConfig(){
   		List<REN_Custom_Search_Config__c> existingRecords = [Select Name, REN_Mass_Update_FieldSet_Name__c, REN_RS_Request_Limit_Threshold__c, REN_RS_High_Watermark_Threshold__c from REN_Custom_Search_Config__c where Name = 'Opportunity' limit 1];

		if(existingRecords != null && !existingRecords.isEmpty()){
			if(existingRecords[0].REN_Mass_Update_FieldSet_Name__c == null){
				existingRecords[0].REN_Mass_Update_FieldSet_Name__c = 'REN_Opportunity_Mass_Update';
			}
			
			if(existingRecords[0].REN_RS_Request_Limit_Threshold__c == null){
				existingRecords[0].REN_RS_Request_Limit_Threshold__c = 1000;
			}
			
			if(existingRecords[0].REN_RS_High_Watermark_Threshold__c == null){
				existingRecords[0].REN_RS_High_Watermark_Threshold__c = 1000;
			}
		    
		    update existingRecords;
		}else{
		    REN_Custom_Search_Config__c customSearchConfigRec = new REN_Custom_Search_Config__c();
		    customSearchConfigRec.Name = 'Opportunity';
		    customSearchConfigRec.REN_Parent_Object__c = 'Opportunity';
		    customSearchConfigRec.REN_Mass_Update_FieldSet_Name__c = 'REN_Opportunity_Mass_Update';
		    customSearchConfigRec.REN_Field_Set_API_Name__c = 'REN_Opportunity_Custom_Search';
		    customSearchConfigRec.REN_RS_Request_Limit_Threshold__c = 1000;
			customSearchConfigRec.REN_RS_High_Watermark_Threshold__c = 1000;
		    
		    insert customSearchConfigRec;
		}
   }
   
   //Created as a part of DE3200: Removed Previous_Local_Currency__c field and added Previous_Local_Currency_Code__c and Previous_Local_Currency_Amount__c
  public void upgradeObjectFieldsValidations(){
   		List<Object_Field_Validation__c> listOfObj  = [SELECT id,field_api_name__c FROM Object_Field_Validation__c WHERE field_api_name__c IN('Previous_Local_Currency__c','Previous_Local_Currency_Code__c','Previous_Local_Currency_Amount__c') AND object_api_name__c = 'REN_Renews_To__c' limit 100];
   		List<Object_Field_Validation__c> objToInsertList = new List<Object_Field_Validation__c>(); 
   		Map<String,Object_Field_Validation__c> objMap = new Map<String,Object_Field_Validation__c>();
   		if(listOfObj != null && !listOfObj.isEmpty()){
   			for(Object_Field_Validation__c obj : listOfObj){
   				objMap.put(obj.field_api_name__c,obj);	
   			}
   		}
   		if(objMap.containsKey('Previous_Local_Currency__c')){
   			delete objMap.get('Previous_Local_Currency__c');
   		}
        if(!objMap.containsKey('Previous_Local_Currency_Code__c')){
        	objToInsertList.add(new Object_Field_Validation__c(field_api_name__c='Previous_Local_Currency_Code__c',object_api_name__c='REN_Renews_To__c'));   
        }
        if(!objMap.containsKey('Previous_Local_Currency_Amount__c')){
        	objToInsertList.add(new Object_Field_Validation__c(field_api_name__c='Previous_Local_Currency_Amount__c',object_api_name__c='REN_Renews_To__c'));   
        }   			
   	    if(!objToInsertList.isEmpty()){
   			insert objToInsertList;
   		} 
   }
   
   public void insertObjectFieldsValidations(){
   		
   		List<Object_Field_Validation__c> listOfObj  = [Select id from Object_Field_Validation__c limit 1];
   		   		
   		if(listOfObj==null || !(listOfObj.size()>0)){ 
	   		listOfObj = new List<Object_Field_Validation__c>(); 
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='REN_End_Date__c',object_api_name__c='REN_Renews_To__c'));
			//Removed as a part of DE3200
			//listOfObj.add(new Object_Field_Validation__c(field_api_name__c='Previous_Local_Currency__c',object_api_name__c='REN_Renews_To__c'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='Previous_Local_Currency_Code__c',object_api_name__c='REN_Renews_To__c'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='Previous_Local_Currency_Amount__c',object_api_name__c='REN_Renews_To__c'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='REN_Renewal_Target__c',object_api_name__c='REN_Renews_To__c'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='Batch_Type__c',object_api_name__c='REN_Renews_To__c'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='CLM_Latest_End_Date__c',object_api_name__c='Quote'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='CHL_Start_Date__c',object_api_name__c='QuoteLineItem'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='CHL_End_Date__c',object_api_name__c='QuoteLineItem'));
			listOfObj.add( new Object_Field_Validation__c(field_api_name__c='Local_Currency__c',object_api_name__c='QuoteLineItem'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='Quantity',object_api_name__c='QuoteLineItem'));
			listOfObj.add( new Object_Field_Validation__c(field_api_name__c='UnitPrice',object_api_name__c='QuoteLineItem'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='TotalPrice',object_api_name__c='QuoteLineItem'));
			
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='REN_Start_Date__c',object_api_name__c='OpportunityLineItem'));
			listOfObj.add( new Object_Field_Validation__c(field_api_name__c='REN_End_Date__c',object_api_name__c='OpportunityLineItem'));
			listOfObj.add( new Object_Field_Validation__c(field_api_name__c='Local_Currency__c',object_api_name__c='OpportunityLineItem'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='Quantity',object_api_name__c='OpportunityLineItem'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='UnitPrice',object_api_name__c='OpportunityLineItem'));
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='TotalPrice',object_api_name__c='OpportunityLineItem'));
			
			listOfObj.add(new Object_Field_Validation__c(field_api_name__c='CloseDate',object_api_name__c='Opportunity'));
			//listOfObj.add( new Object_Field_Validation__c(field_api_name__c='StageName',object_api_name__c='Opportunity'));
			listOfObj.add( new Object_Field_Validation__c(field_api_name__c='Business_Line__c',object_api_name__c='Opportunity'));
			listOfObj.add( new Object_Field_Validation__c(field_api_name__c='SSI_Booking_Date__c',object_api_name__c='Opportunity'));
			listOfObj.add( new Object_Field_Validation__c(field_api_name__c='Client_Booking_Date__c',object_api_name__c='Opportunity'));
			
			 
			insert listOfObj;
   		}
   		
   		listOfObj  = [Select id from Object_Field_Validation__c WHERE field_api_name__c='StageName' AND object_api_name__c='Opportunity'];
   		if(listOfObj != null && !listOfObj.isEmpty()){ 
   			for(Object_Field_Validation__c obj: listOfObj){
   				obj.isActive__c = false;
   			}
   			update listOfObj;
   		}
   		
   }
  
    public void sendEmail(String MessageDetails){
    	Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
            list<String> listEmailMembers = new list<String>();
            listEmailMembers.add('servicesource@comitydesigns.com');
            emailTobeSent.setToAddresses(listEmailMembers);
            emailTobeSent.setSubject('Post install exception');
        //  emailTobeSent.setHtmlBody('Message : ' + ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' getStackTraceString ' + ex.getStackTraceString() + '' + ex.getCause());
			emailTobeSent.setHtmlBody (errorDetails);           
            Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
    }

    /********
    function : setZenithCustomSetting
    Reads values from static resource and inserts in appropriate custom setting.
    **************/
    private void setZenithCustomSetting(String eDetails){
    	List<StaticResource> zenithCustomSettingResourceLst = [select Body from StaticResource where Name = 'ZenithReportUrls'
    															 OR Name = 'ZenithDashboardTabElements' ORDER BY Name];
    												 
    	try{														 
    		if(zenithCustomSettingResourceLst != null && !zenithCustomSettingResourceLst.isEmpty()){
    			List<Zenith_Dashboard_Tab_Elements__c> zenDTabElLst = Zenith_Dashboard_Tab_Elements__c.getall().values();
    		
    			if(zenithCustomSettingResourceLst[0] != null && zenDTabElLst != null && zenDTabElLst.isEmpty()){
    				List<Zenith_Dashboard_Tab_Elements__c> zenithDashboardLSt = (List<Zenith_Dashboard_Tab_Elements__c>) JSON.deserialize(zenithCustomSettingResourceLst[0].Body.toString(), List<Zenith_Dashboard_Tab_Elements__c>.class);
					insert zenithDashboardLSt;
 				}
 			
 				List<Zenith_Report_Urls__c> repUrlLst = Zenith_Report_Urls__c.getall().values();
    		
    			if(zenithCustomSettingResourceLst[1] != null && repUrlLst != null && repUrlLst.isEmpty()){
 					List<Zenith_Report_Urls__c> zenithURLLSt = (List<Zenith_Report_Urls__c>) JSON.deserialize(zenithCustomSettingResourceLst[1].Body.toString(), List<Zenith_Report_Urls__c>.class);
 					insert zenithURLLSt;
    			}
					
    		}
    	}
    	
    	catch (Exception ex){
    		 if(!String.isBlank(errorDetails)){
    			errorDetails += '<br>' + ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' StackTraceString : ' + ex.getStackTraceString() + 'Cause :' + ex.getCause();
    		} else {
    				errorDetails = ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' StackTraceString : ' + ex.getStackTraceString() + 'Cause :' + ex.getCause();
    		}
    	}	
    }
    
  
	/* Desc - This  method is used to set all the triggers as true in TriggerEnablement custom settings. 
    */
	private void insertTriggerEnablement() {
		CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
		cTriggerEnablement.Account_Trigger__c = true;
		cTriggerEnablement.OperationsTarget_Trigger__c = true;
		cTriggerEnablement.PeerReview_Trigger__c = true;
		cTriggerEnablement.ProactiveRule_LineItem_Trigger__c = true;
		cTriggerEnablement.ProactiveRule_Trigger__c = true;
		cTriggerEnablement.SalesTarget_Trigger__c = true;
		cTriggerEnablement.User_Trigger__c = true;
		upsert cTriggerEnablement;
	}
	
	//Insert record to batch size custom setting
	private void insertCSMBatchJobConfig() {
		List<CSM_Batch_Job_Config__c> batchJobConfigList  = new List<CSM_Batch_Job_Config__c>();
		
		Map<String, CSM_Batch_Job_Config__c> batchJobConfigMap = CSM_Batch_Job_Config__c.getAll();
		if(batchJobConfigMap == null){
			batchJobConfigMap = new Map<String, CSM_Batch_Job_Config__c>();
		}
		if(!batchJobConfigMap.containsKey('SE_CaseCreationBatch')){
			batchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='SE_CaseCreationBatch', CSM_Batch_Size__c=200));
		}
		if(!batchJobConfigMap.containsKey('SE_CaseTargetDateBatch')){
			batchJobConfigList.add(new CSM_Batch_Job_Config__c(Name='SE_CaseTargetDateBatch', CSM_Batch_Size__c=200));
		}
		
		if(!batchJobConfigList.isEmpty()){
			upsert batchJobConfigList Name;
		}
	}

//------------------------------US2209-------------Start -----------------
    
    /**
      * @description : This method used to create canned FC ,If version is greater that March release i.e 2.79.
    */
    private void createCannedFCRecords(InstallContext context){
		Map<String,String> grpMap = insertPublicGroup();
    	List<CSM_Focus_Category_View__c> availableFcViewList  = [select id from CSM_Focus_Category_View__c where name in ('Cases On Hold', 'My Quote Completed Opps', 'My Opportunities Expiring this Week', 'Opportunities Expiring this Week', 'Open Escalated Cases', 'Completed Quotes today', 'My Overdue cases', 'My Cases due today', 'My Escalated Cases', 'Upcoming Unassigned cases', 'Overdue Unassigned cases', 'Cases due today', 'Escalated Cases', 'My opps with an On Hold Case', 'All Quote Completed Opps', 'My Opps with Unsuccessful Quote/Booking', 'Opps with Unsuccessful Quotes & Bookings', 'My Opportunities 90 DIA', 'My Not contacted Opportunities', 'My Carryover opportunities', 'My Top Deals (Oppt amount > 10K)', 'My Opps likely to close this month', 'Opportunities 90 DIA', 'Not contacted Opportunities', 'Carryover opportunities', 'Top Deals (Oppt amount > 10K)', 'Opportunities likely to close this month', 'My Quote Cases', 'My Booking cases', 'My On hold cases', 'Unassigned cases', 'My All other cases', 'Quote Cases', 'Booking cases', 'On hold cases', 'All Other Cases')];
		if(availableFcViewList == null || availableFcViewList.isEmpty()){
			List<CSM_Focus_Category_View__c> fcViewList  = createFCViewCardsRecords();
			insertFCViewcriteriaForCards(fcViewList);
			insertColoumsFCView(fcViewList);
			createFCShareRecordsForGroups(fcViewList, grpMap);
		} 
	}
	
	/**
      * @description : This method used to create canned FC. Added as part of US2209.
    */
    private List<CSM_Focus_Category_View__c> createFCViewCardsRecords(){
		List<CSM_Focus_Category_View_Column__c> fcViewColList = new List<CSM_Focus_Category_View_Column__c>();
		Map<String,String> caseRecordTypeMap = getCaseRecordTypeMap();
		String currencyCode = getCorpCurrency();
		// CARDS
		List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>{
			//0
			new CSM_Focus_Category_View__c( 
			Name = 'Opportunities 90 DIA', 
			CSM_Columns__c = 'Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c, Account.Name, Owner.name', 
			CSM_Criteria__c = 'WHERE (REN_Earliest_Expiration_Date__c > NEXT_N_DAYS:89)', 
			CSM_Display_Name__c = 'Opportunities 90 DIA', 
			CSM_Filter_By_Owner_Value__c = 'All Opportunities', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, FORMAT(REN_Earliest_Expiration_Date__c), Account.Name, Owner.name from Opportunity WHERE (REN_Earliest_Expiration_Date__c > NEXT_N_DAYS:89)', 
			RLM_Currency_Code__c = currencyCode
			),
			//1
		    new CSM_Focus_Category_View__c( 
		    Name = 'Not contacted Opportunities', 
			CSM_Columns__c = 'REN_Earliest_Expiration_Date__c, Account.Name, Amount, CloseDate, StageName, Owner.name', 
			CSM_Criteria__c = 'WHERE (StageName = \'Not Contacted\')', 
			CSM_Display_Name__c = 'Not contacted Opportunities', 
			CSM_Filter_By_Owner_Value__c = 'All Opportunities', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, FORMAT(REN_Earliest_Expiration_Date__c), Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, Owner.name from Opportunity WHERE (StageName = \'Not Contacted\')', 
		    RLM_Currency_Code__c = currencyCode
			),
			//2
			new CSM_Focus_Category_View__c( 
			Name = 'Top Deals (Oppt amount > 10K)', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c, Owner.name', 
			CSM_Criteria__c = 'WHERE (Amount >= '+currencyCode+'10000.00 AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\'  AND (REN_Earliest_Expiration_Date__c = THIS_QUARTER OR REN_Earliest_Expiration_Date__c = LAST_QUARTER))', 
			CSM_Display_Name__c = 'Top Deals (Oppt amount > 10K)', 
			CSM_Filter_By_Owner_Value__c = 'All Opportunities', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, FORMAT(REN_Earliest_Expiration_Date__c), Owner.name from Opportunity WHERE (Amount >= '+currencyCode+'10000.00 AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND (REN_Earliest_Expiration_Date__c = THIS_QUARTER OR REN_Earliest_Expiration_Date__c = LAST_QUARTER))', 
			RLM_Currency_Code__c = currencyCode, 
			RLM_Filter_Logic__c = '1 AND 2 AND 3 AND 4 AND (5 OR 6)'
		    ), 
			//3
			new CSM_Focus_Category_View__c( 
			Name = 'Opportunities likely to close this month', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c, Owner.name', 
	        CSM_Criteria__c = 'WHERE (Commit_Level__c = \'Green\' AND CloseDate = THIS_MONTH AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\')', 
			CSM_Display_Name__c = 'Opportunities likely to close this month', 
			CSM_Filter_By_Owner_Value__c = 'All Opportunities', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
		    CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), FORMAT(REN_Earliest_Expiration_Date__c), StageName, Owner.name, Name from Opportunity WHERE (Commit_Level__c = \'Green\' AND CloseDate = THIS_MONTH AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\')', 
			RLM_Currency_Code__c = 'USD'
		    //RLM_Filter_Logic__c = '1 AND 2 AND (3 OR 4 OR 5)'
			),
			//4
			new CSM_Focus_Category_View__c( 
		    Name = 'Quote Cases', 
			CSM_Columns__c = 'CaseNumber, Contact.Name, Subject, Priority, CreatedDate, Target_Date__c, Status, Owner.Name', 
			CSM_Criteria__c = 'WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Quote Request')+'\' AND (Status = \'New\' OR Status = \'Work In Progress\' OR Status = \'On Hold\'))', 
			CSM_Display_Name__c = 'Quote Cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
	        CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, Contact.Name, Subject, Priority, FORMAT(CreatedDate), FORMAT(Target_Date__c), Status, Owner.Name from Case WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Quote Request')+'\' AND (Status = \'New\' OR Status = \'Work In Progress\' OR Status = \'On Hold\'))', 
			RLM_Currency_Code__c = 'USD', 
		    RLM_Filter_Logic__c = '1 AND (2 OR 3 OR 4)'
	        ), 
		    //5
			new CSM_Focus_Category_View__c( 
			Name = 'Booking cases', 
		    CSM_Columns__c = 'CaseNumber, Contact.Name, Subject, Priority, CreatedDate, Target_Date__c, Status, Owner.Name', 
			CSM_Criteria__c = 'WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Booking Request')+'\' AND (Status = \'New\' OR Status = \'Work In Progress\' OR Status = \'On Hold\'))', 
			CSM_Display_Name__c = 'Booking cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, Contact.Name, Subject, Priority, FORMAT(CreatedDate), FORMAT(Target_Date__c), Status, Owner.Name from Case WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Booking Request')+'\' AND (Status = \'New\' OR Status = \'Work In Progress\' OR Status = \'On Hold\'))', 
			RLM_Currency_Code__c = 'USD', 
			RLM_Filter_Logic__c = '1 AND (2 OR 3 OR 4)'
			), 
			//6 
			new CSM_Focus_Category_View__c( 
		    Name = 'On hold cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, On_Hold_Reason__c, Target_Date__c, Owner.Name', 
		    CSM_Criteria__c = 'WHERE (Status = \'On Hold\')', 
			CSM_Display_Name__c = 'On hold cases', 
		    CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Case', 
		    CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, On_Hold_Reason__c, FORMAT(Target_Date__c), Owner.Name from Case WHERE (Status = \'On Hold\')', 
			RLM_Currency_Code__c = 'USD'
		    ),  
			//7 
		    new CSM_Focus_Category_View__c( 
			Name = 'All Other Cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Subject, Priority, Target_Date__c, Status, Owner.Name', 
			CSM_Criteria__c = 'WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Data Processing Request')+'\' OR RecordTypeId = \''+caseRecordTypeMap.get('Data Update Request')+'\' OR RecordTypeId = \''+caseRecordTypeMap.get('Lead Submission')+'\')', 
			CSM_Display_Name__c = 'All Other Cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Subject, Priority, FORMAT(Target_Date__c), Status, Owner.Name from Case WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Data Processing Request')+'\' OR RecordTypeId = \''+caseRecordTypeMap.get('Data Update Request')+'\' OR RecordTypeId = \''+caseRecordTypeMap.get('Lead Submission')+'\')', 
			RLM_Currency_Code__c = currencyCode, 
			RLM_Filter_Logic__c = '1 OR 2 OR 3'
			),
		    //8 // need to add coloums
		    new CSM_Focus_Category_View__c( 
			Name = 'Cases On Hold', 
			CSM_Columns__c = 'CaseNumber, Contact.Name, Subject, Priority, CreatedDate, On_Hold_Reason__c, Target_Date__c, Owner.Name', 
			CSM_Criteria__c = 'WHERE (Status = \'On Hold\')', 
			CSM_Display_Name__c = 'Cases On Hold', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = '	select id ,CaseNumber, Contact.Name, Subject, Priority, FORMAT(CreatedDate), On_Hold_Reason__c, FORMAT(Target_Date__c), Owner.Name from Case WHERE (Status = \'On Hold\')', 
			RLM_Currency_Code__c = currencyCode), 
			//9
			new CSM_Focus_Category_View__c( 
			Name = 'Opportunities Expiring this Week', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c, Owner.name', 
			CSM_Criteria__c = 'WHERE (REN_Earliest_Expiration_Date__c = THIS_WEEK AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND StageName != \'Open - Consolidated\'))', 
			CSM_Display_Name__c = 'Opportunities Expiring this Week', 
			CSM_Filter_By_Owner_Value__c = 'All Opportunities', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, FORMAT(REN_Earliest_Expiration_Date__c), Owner.name from Opportunity WHERE (REN_Earliest_Expiration_Date__c = THIS_WEEK AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND StageName != \'Open - Consolidated\')', 
			RLM_Currency_Code__c = currencyCode
			//RLM_Filter_Logic__c = '1 AND (2 OR 3 OR 4 OR 5)'
			),
			//10
			new CSM_Focus_Category_View__c( 
			Name = 'Cases due today', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Subject, Priority, Target_Date__c, MilestoneStatus, Owner.Name', 
			CSM_Criteria__c = 'WHERE (Target_Date__c = TODAY)', 
			CSM_Display_Name__c = 'Cases due today', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Subject, Priority, FORMAT(Target_Date__c), MilestoneStatus, Owner.Name from Case WHERE (Target_Date__c = TODAY)', 
			RLM_Currency_Code__c = currencyCode
			), 
			//11
			new CSM_Focus_Category_View__c( 
			Name = 'Escalated Cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, Target_Date__c, MilestoneStatus, Owner.Name', 
			CSM_Criteria__c = 'WHERE (IsEscalated = true AND Status != \'Closed\' AND Status != \'Closed - Unsuccessfully\')', 
			CSM_Display_Name__c = 'Escalated Cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Subject, Priority, FORMAT(Target_Date__c), MilestoneStatus, Owner.Name, Contact.Name from Case WHERE (IsEscalated = true AND Status != \'Closed\' AND Status != \'Closed - Unsuccessfully\')', 
			//RLM_Filter_Logic__c = '1 AND (2 OR 3)',
			RLM_Currency_Code__c = currencyCode 
			),
			//12
			new CSM_Focus_Category_View__c( 
			Name = 'All Quote Completed Opps', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, Ops_Stage__c, REN_Earliest_Expiration_Date__c , Owner.name', 
			CSM_Criteria__c = 'WHERE (StageName = \'Quote Completed\')', 
			CSM_Display_Name__c = 'All Quote Completed Opps', 
			CSM_Filter_By_Owner_Value__c = 'All Opportunities', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, Ops_Stage__c, FORMAT(REN_Earliest_Expiration_Date__c), Owner.name from Opportunity WHERE (StageName = \'Quote Completed\')', 
			RLM_Currency_Code__c = currencyCode), 
			//13
			new CSM_Focus_Category_View__c( 
			Name = 'My Overdue cases', 
			CSM_Columns__c = 'CaseNumber,RecordType.Name, Contact.Name, Subject, Priority, Target_Date__c, Status, MilestoneStatus', 
			CSM_Criteria__c = 'WHERE (Target_Date__c < TODAY OR Milestone_Status_Reporting__c = \'Open Violation\')', 
			CSM_Display_Name__c = 'My Overdue cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id, RecordType.Name, Contact.Name, Subject, Priority, FORMAT(Target_Date__c), Status, MilestoneStatus, CaseNumber from Case WHERE (Target_Date__c < TODAY OR Milestone_Status_Reporting__c = \'Open Violation\')', 
			RLM_Filter_Logic__c = '1 OR 2',
			RLM_Currency_Code__c = currencyCode
			),
			//14
			new CSM_Focus_Category_View__c( 
		    Name = 'My Not contacted Opportunities', 
			CSM_Columns__c = 'REN_Earliest_Expiration_Date__c, Account.Name, Amount, CloseDate, StageName', 
			CSM_Criteria__c = 'WHERE (StageName = \'Not Contacted\')', 
			CSM_Display_Name__c = 'My Not contacted Opportunities', 
			CSM_Filter_By_Owner_Value__c =  'My Opportunities', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, FORMAT(REN_Earliest_Expiration_Date__c), Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName from Opportunity WHERE (StageName = \'Not Contacted\')', 
		    RLM_Currency_Code__c = currencyCode 
			),
            //15
			new CSM_Focus_Category_View__c( 
			Name = 'My Top Deals (Oppt amount > 10K)', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c', 
			CSM_Criteria__c = 'WHERE (Amount >= '+currencyCode+'10000.00 AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\'  AND (REN_Earliest_Expiration_Date__c = THIS_QUARTER OR REN_Earliest_Expiration_Date__c = LAST_QUARTER))', 
			CSM_Display_Name__c = 'My Top Deals (Oppt amount > 10K)', 
			CSM_Filter_By_Owner_Value__c =  'My Opportunities', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, FORMAT(REN_Earliest_Expiration_Date__c) from Opportunity WHERE (Amount >= '+currencyCode+'10000.00 AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\'  AND (REN_Earliest_Expiration_Date__c = THIS_QUARTER OR REN_Earliest_Expiration_Date__c = LAST_QUARTER))', 
			RLM_Currency_Code__c = currencyCode, 
			RLM_Filter_Logic__c = '1 AND 2 AND 3 AND 4 AND (5 OR 6)'
		    ), 
			//16
			new CSM_Focus_Category_View__c( 
			Name = 'My Opps likely to close this month', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, REN_Earliest_Expiration_Date__c, StageName, Commit_Level__c', 
	        CSM_Criteria__c = 'WHERE (Commit_Level__c = \'Green\' AND CloseDate = THIS_MONTH AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\')', 
			CSM_Display_Name__c = 'My Opps likely to close this month', 
			CSM_Filter_By_Owner_Value__c =  'My Opportunities', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
		    CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), FORMAT(REN_Earliest_Expiration_Date__c), StageName, Commit_Level__c, Name from Opportunity WHERE (Commit_Level__c = \'Green\' AND CloseDate = THIS_MONTH AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\')', 
			RLM_Currency_Code__c = currencyCode
		    //RLM_Filter_Logic__c = '1 AND 2 AND (3 OR 4 OR 5)'
			),
			//17
			new CSM_Focus_Category_View__c( 
			Name = 'My Opportunities 90 DIA', 
			CSM_Columns__c = 'Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c, Account.Name', 
			CSM_Criteria__c = 'WHERE (REN_Earliest_Expiration_Date__c > NEXT_N_DAYS:89)', 
			CSM_Display_Name__c = 'My Opportunities 90 DIA', 
			CSM_Filter_By_Owner_Value__c =  'My Opportunities', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, FORMAT(REN_Earliest_Expiration_Date__c), Account.Name from Opportunity WHERE (REN_Earliest_Expiration_Date__c > NEXT_N_DAYS:89)', 
			RLM_Currency_Code__c = currencyCode
			),
			//18 //Case Recordtype = Quote Request
			new CSM_Focus_Category_View__c( 
		    Name = 'My Quote Cases', 
			CSM_Columns__c = 'CaseNumber, Contact.Name, Subject, Priority, CreatedDate, Target_Date__c, Status, MilestoneStatus', 
			CSM_Criteria__c = 'WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Quote Request')+'\' AND (Status = \'New\' OR Status = \'Work In Progress\' OR Status = \'On Hold\'))', 
			CSM_Display_Name__c = 'My Quote Cases', 
			CSM_Filter_By_Owner_Value__c = 'My Cases', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
	        CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, Contact.Name, Subject, Priority, FORMAT(CreatedDate), FORMAT(Target_Date__c), Status, MilestoneStatus from Case  WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Quote Request')+'\' AND (Status = \'New\' OR Status = \'Work In Progress\' OR Status = \'On Hold\'))', 
			RLM_Currency_Code__c = currencyCode, 
		    RLM_Filter_Logic__c = '1 AND (2 OR 3 OR 4)'
	        ), 
			 //19 //Case Recordtype = Booking Request
			new CSM_Focus_Category_View__c( 
			Name = 'My Booking cases', 
		    CSM_Columns__c = 'CaseNumber, Contact.Name, Subject, Priority, CreatedDate, Target_Date__c, Status, MilestoneStatus', 
			CSM_Criteria__c = 'WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Booking Request')+'\' AND (Status = \'New\' OR Status = \'Work In Progress\' OR Status = \'On Hold\'))', 
			CSM_Display_Name__c = 'My Booking cases', 
			CSM_Filter_By_Owner_Value__c = 'My Cases', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, Contact.Name, Subject, Priority, FORMAT(CreatedDate), FORMAT(Target_Date__c), Status, MilestoneStatus from Case WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Booking Request')+'\' AND (Status = \'New\' OR Status = \'Work In Progress\' OR Status = \'On Hold\'))', 
			RLM_Currency_Code__c = currencyCode, 
			RLM_Filter_Logic__c = '1 AND (2 OR 3 OR 4)'
			), 
			//20 
			new CSM_Focus_Category_View__c( 
		    Name = 'My On hold cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, CreatedDate, On_Hold_Reason__c, Target_Date__c', 
		    CSM_Criteria__c = 'WHERE (Status = \'On Hold\')', 
			CSM_Display_Name__c = 'My On hold cases', 
		    CSM_Filter_By_Owner_Value__c = 'My Cases', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Case', 
		    CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, FORMAT(CreatedDate), On_Hold_Reason__c, FORMAT(Target_Date__c) from Case WHERE (Status = \'On Hold\')', 
			RLM_Currency_Code__c = currencyCode
		    ),  
			//21 //Case Recordtype = (Data Processing, Data Update, Lead Submission)
		    new CSM_Focus_Category_View__c( 
			Name = 'My All other cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, Target_Date__c, Status, MilestoneStatus', 
			CSM_Criteria__c = 'WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Data Processing Request')+'\' OR RecordTypeId = \''+caseRecordTypeMap.get('Data Update Request')+'\' OR RecordTypeId = \''+caseRecordTypeMap.get('Lead Submission')+'\')', 
			CSM_Display_Name__c = 'My All other cases', 
			CSM_Filter_By_Owner_Value__c = 'My Cases', 
			CSM_IsTile__c = false,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, FORMAT(Target_Date__c), Status, MilestoneStatus from Case WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Data Processing Request')+'\' OR RecordTypeId = \''+caseRecordTypeMap.get('Data Update Request')+'\' OR RecordTypeId = \''+caseRecordTypeMap.get('Lead Submission')+'\')', 
			RLM_Currency_Code__c = currencyCode, 
			RLM_Filter_Logic__c = '1 OR 2 OR 3'
			),
			//22 
			new CSM_Focus_Category_View__c( 
			Name = 'My Quote Completed Opps', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, Ops_Stage__c, REN_Earliest_Expiration_Date__c', 
			CSM_Criteria__c = 'WHERE (StageName = \'Quote Completed\')', 
			CSM_Display_Name__c = 'My Quote Completed Opps', 
			CSM_Filter_By_Owner_Value__c =  'My Opportunities', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, Ops_Stage__c, FORMAT(REN_Earliest_Expiration_Date__c) from Opportunity WHERE (StageName = \'Quote Completed\')', 
			RLM_Currency_Code__c = currencyCode),
			//23
			new CSM_Focus_Category_View__c( 
			Name = 'My Opportunities Expiring this Week', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c', 
			CSM_Criteria__c = 'WHERE (REN_Earliest_Expiration_Date__c = THIS_WEEK AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND StageName != \'Open - Consolidated\')', 
			CSM_Display_Name__c = 'My Opportunities Expiring this Week', 
			CSM_Filter_By_Owner_Value__c =   'My Opportunities', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, FORMAT(REN_Earliest_Expiration_Date__c) from Opportunity WHERE (REN_Earliest_Expiration_Date__c = THIS_WEEK AND StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND StageName != \'Open - Consolidated\')', 
			RLM_Currency_Code__c = currencyCode),
			//RLM_Filter_Logic__c = '1 AND (2 OR 3 OR 4 OR 5)'),
            //24
			new CSM_Focus_Category_View__c( 
			Name = 'My Cases due today', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, Target_Date__c, Status, MilestoneStatus', 
			CSM_Criteria__c = 'WHERE (Target_Date__c = TODAY)', 
			CSM_Display_Name__c = 'My Cases due today', 
			CSM_Filter_By_Owner_Value__c = 'My Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, FORMAT(Target_Date__c), Status, MilestoneStatus from Case WHERE (Target_Date__c = TODAY)', 
			RLM_Currency_Code__c = currencyCode
			),
			//25
			new CSM_Focus_Category_View__c( 
			Name = 'My Escalated Cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, Target_Date__c, Status, MilestoneStatus', 
			CSM_Criteria__c = 'WHERE (IsEscalated = true AND Status != \'Closed\' AND Status != \'Closed - Unsuccessfully\')', 
			CSM_Display_Name__c = 'My Escalated Cases', 
			CSM_Filter_By_Owner_Value__c = 'My Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = '	select id, CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, FORMAT(Target_Date__c), Status, MilestoneStatus from Case WHERE (IsEscalated = true AND Status != \'Closed\' AND Status != \'Closed - Unsuccessfully\')', 
			//RLM_Filter_Logic__c = '1 AND (2 OR 3)',
			RLM_Currency_Code__c = currencyCode 
			),
			//26
			new CSM_Focus_Category_View__c( 
			Name = 'My Opps with Unsuccessful Quote/Booking', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, Ops_Stage__c, REN_Earliest_Expiration_Date__c', 
			CSM_Criteria__c = 'WHERE (Ops_Stage__c = \'Unsuccessful\')', 
			CSM_Display_Name__c = 'My Opps with Unsuccessful Quote/Booking', 
			CSM_Filter_By_Owner_Value__c =  'My Opportunities', 
			CSM_IsTile__c = true,
			CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, Ops_Stage__c, FORMAT(REN_Earliest_Expiration_Date__c) from Opportunity WHERE (Ops_Stage__c = \'Unsuccessful\')', 
			RLM_Currency_Code__c = currencyCode
			),
			//27
			new CSM_Focus_Category_View__c( 
			Name = 'Open Escalated Cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, Target_Date__c, Escalation_Reason__c, Owner.Name', 
			CSM_Criteria__c = 'WHERE (IsEscalated = true AND Status != \'Closed\' AND Status != \'Closed - Unsuccessfully\')', 
			CSM_Display_Name__c = 'Open Escalated Cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, FORMAT(Target_Date__c),Escalation_Reason__c, Owner.Name from Case WHERE (IsEscalated = true AND Status != \'Closed\' AND Status != \'Closed - Unsuccessfully\')', 
			//RLM_Filter_Logic__c = '1 AND (2 OR 3)',
			RLM_Currency_Code__c = currencyCode 
			), 
			//28
			new CSM_Focus_Category_View__c( 
			Name = 'Unassigned cases',
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Subject, Priority, Target_Date__c, MilestoneStatus, CreatedDate, Contact.Name', 
			CSM_Criteria__c = 'WHERE (Assignment_Date__c  = null)', 
			CSM_Display_Name__c = 'Unassigned cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = false,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Subject, Priority, FORMAT(Target_Date__c), MilestoneStatus, FORMAT(CreatedDate), Contact.Name from Case WHERE (Assignment_Date__c  = null)', 
			RLM_Currency_Code__c = currencyCode 
			), 
			//29
			new CSM_Focus_Category_View__c( 
			Name = 'Completed Quotes today', 
			CSM_Columns__c = 'CaseNumber, Contact.Name, Subject, Priority, ClosedDate, Target_Date__c, Status, Owner.Name', 
			CSM_Criteria__c = 'WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Quote Request')+'\' AND (Status = \'Closed\' OR Status = \'Closed - Unsuccessfully\') AND ClosedDate = TODAY)', 
			CSM_Display_Name__c = 'Completed Quotes today', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, Contact.Name, Subject, Priority, FORMAT(ClosedDate), FORMAT(Target_Date__c), Status, Owner.Name from Case WHERE (RecordTypeId = \''+caseRecordTypeMap.get('Quote Request')+'\' AND (Status = \'Closed\' OR Status = \'Closed - Unsuccessfully\') AND ClosedDate = TODAY)', 
			RLM_Filter_Logic__c = '1 AND (2 OR 3) AND 4',
			RLM_Currency_Code__c = currencyCode 
			),
			//30
			new CSM_Focus_Category_View__c( 
			Name = 'My Carryover opportunities', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c', 
			CSM_Criteria__c = 'WHERE StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND REN_Earliest_Expiration_Date__c < THIS_QUARTER)', 
			CSM_Display_Name__c = 'My Carryover opportunities', 
			CSM_Filter_By_Owner_Value__c = 'My Opportunities', 
			CSM_IsTile__c = false,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, FORMAT(REN_Earliest_Expiration_Date__c) from Opportunity WHERE (StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND REN_Earliest_Expiration_Date__c < THIS_QUARTER)', 
			//RLM_Filter_Logic__c = '(1 OR 2 OR 3) AND 4',
			RLM_Currency_Code__c = currencyCode 
			),
			//31
			new CSM_Focus_Category_View__c( 
			Name = 'Carryover opportunities', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, REN_Earliest_Expiration_Date__c, Owner.name', 
			CSM_Criteria__c = 'WHERE StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND REN_Earliest_Expiration_Date__c < THIS_QUARTER)', 
			CSM_Display_Name__c = 'Carryover opportunities', 
			CSM_Filter_By_Owner_Value__c = 'All Opportunities', 
			CSM_IsTile__c = false,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, FORMAT(REN_Earliest_Expiration_Date__c), Owner.name from Opportunity WHERE (StageName != \'No Service\' AND StageName != \'House Account\' AND StageName != \'Closed Sale\' AND REN_Earliest_Expiration_Date__c < THIS_QUARTER)', 
			//RLM_Filter_Logic__c = '(1 OR 2 OR 3) AND 4',
			RLM_Currency_Code__c = currencyCode 
			),
			//32
			new CSM_Focus_Category_View__c( 
			Name = 'Opps with Unsuccessful Quotes & Bookings', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, Ops_Stage__c, REN_Earliest_Expiration_Date__c, Owner.Name', 
			CSM_Criteria__c = 'WHERE (Ops_Stage__c != \'Unsuccessful\')', 
			CSM_Display_Name__c = 'Opps with Unsuccessful Quotes & Bookings', 
			CSM_Filter_By_Owner_Value__c = 'All Opportunities', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, Name, Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, Ops_Stage__c, FORMAT(REN_Earliest_Expiration_Date__c), Owner.Name from Opportunity WHERE (Ops_Stage__c != \'Unsuccessful\')', 
			RLM_Currency_Code__c = currencyCode 
			),
			//33
			new CSM_Focus_Category_View__c( 
			Name = 'Upcoming Unassigned cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Subject, Priority, Target_Date__c, MilestoneStatus, CreatedDate, Contact.Name', 
			CSM_Criteria__c = 'WHERE (Assignment_Date__c  = null AND Target_Date__c >= TODAY)', 
			CSM_Display_Name__c = 'Upcoming Unassigned cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id ,CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, FORMAT(CreatedDate), FORMAT(Target_Date__c), MilestoneStatus from Case WHERE (Assignment_Date__c  = null AND Target_Date__c >= TODAY)', 
			RLM_Currency_Code__c = currencyCode 
			), 
			//34
			new CSM_Focus_Category_View__c( 
			Name = 'Overdue Unassigned cases', 
			CSM_Columns__c = 'CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, CreatedDate, Target_Date__c, MilestoneStatus', 
			CSM_Criteria__c = 'WHERE (Assignment_Date__c  = null AND (Target_Date__c < TODAY OR Milestone_Status_Reporting__c = \'open violation\'))', 
			CSM_Display_Name__c = 'Overdue Unassigned cases', 
			CSM_Filter_By_Owner_Value__c = 'All Cases', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,CSM_Object_Name__c = 'Case', 
			CSM_SOQL__c = 'select id, CaseNumber, RecordType.Name, Contact.Name, Subject, Priority, FORMAT(CreatedDate), FORMAT(Target_Date__c), MilestoneStatus from Case WHERE (Assignment_Date__c  = null AND (Target_Date__c < TODAY OR Milestone_Status_Reporting__c = \'open violation\'))', 
			RLM_Filter_Logic__c = '1 AND (2 OR 3)',
			RLM_Currency_Code__c = currencyCode 
			),
			//35
			new CSM_Focus_Category_View__c( 
			Name = 'My opps with an On Hold Case', 
			CSM_Columns__c = 'Account.Name, Amount, CloseDate, StageName, Ops_Stage__c, REN_Earliest_Expiration_Date__c', 
			CSM_Criteria__c = 'WHERE (Ops_Stage__c = \'On Hold\')', 
			CSM_Display_Name__c = 'My opps with an On Hold Case', 
			CSM_Filter_By_Owner_Value__c = 'My Opportunities', 
			CSM_IsTile__c = true,CSM_Is_Active__c = true,
			CSM_Object_Name__c = 'Opportunity', 
			CSM_SOQL__c = 'select id, name , Account.Name, FORMAT(convertCurrency(Amount)), FORMAT(CloseDate), StageName, Ops_Stage__c, FORMAT(REN_Earliest_Expiration_Date__c) from Opportunity WHERE (Ops_Stage__c = \'On Hold\')', 
			RLM_Currency_Code__c = currencyCode 
			)
		};
		insert fcViewList;
		return fcViewList;
	}
	
	/**
      * @description : This method used for creating criteria for Canned FC. Added as part of US2209.
    */
	private void insertFCViewcriteriaForCards(List<CSM_Focus_Category_View__c> fcViewList){
		
		List<CSM_Focus_Category_View_Criteria__c> fcViewCriteriaList =  new List<CSM_Focus_Category_View_Criteria__c>();
		Map<String,String> caseRecordTypeMap = getCaseRecordTypeMap();
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[0].id, 'Earliest Expiration Date', 'REN_Earliest_Expiration_Date__c', 'DATE', '>', null,1,89,'NEXT_N_DAYS'));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[1].id, 'Stage', 'StageName', 'PICKLIST', '=', 'Not Contacted',1,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[2].id, 'Amount', 'Amount', 'CURRENCY', '>=', '10000',1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[2].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'No Service',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[2].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'House Account',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[2].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Closed Sale',4,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[2].id, 'Earliest Expiration Date','REN_Earliest_Expiration_Date__c', 'DATE', '=', null,5,null,'THIS_QUARTER'));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[2].id, 'Earliest Expiration Date','REN_Earliest_Expiration_Date__c', 'DATE', '=', null,6,null,'LAST_QUARTER'));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[3].id, 'Commit Level', 'Commit_Level__c', 'PICKLIST', '=', 'Green',1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[3].id, 'Close Date', 'CloseDate', 'DATE', '=', null,2,null,'THIS_MONTH'));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[3].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'No Service',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[3].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'House Account',4,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[3].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Closed Sale',5,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[4].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Quote Request'),1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[4].id, 'Status', 'Status', 'PICKLIST', '=', 'New',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[4].id, 'Status', 'Status', 'PICKLIST', '=', 'Work In Progress',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[4].id, 'Status', 'Status', 'PICKLIST', '=', 'On Hold',4,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[5].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Booking Request'),1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[5].id, 'Status', 'Status', 'PICKLIST', '=', 'New',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[5].id, 'Status', 'Status', 'PICKLIST', '=', 'Work In Progress',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[5].id, 'Status', 'Status', 'PICKLIST', '=', 'On Hold',4,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[6].id, 'Status', 'Status', 'PICKLIST', '=', 'On Hold',1,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[7].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Data Processing Request'),1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[7].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Data Update Request'),2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[7].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Lead Submission'),3,null,null));
         
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[8].id, 'Status', 'Status', 'PICKLIST', '=', 'On Hold',1,null,null));
		
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[9].id, 'Earliest Expiration Date','REN_Earliest_Expiration_Date__c', 'DATE', '=', null,1,null,'THIS_WEEK'));
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[9].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'No Service',2,null,null));
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[9].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'House Account',3,null,null));
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[9].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Closed Sale',4,null,null));
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[9].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Open - Consolidated',5,null,null));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[10].id, 'Target Date', '	Target_Date__c', 'DATETIME', '=', null,1,null,'TODAY'));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[11].id, 'Escalated', 'IsEscalated', 'BOOLEAN', '=', 'true',1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[11].id, 'Status', 'Status', 'PICKLIST', '!=', 'Closed',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[11].id, 'Status', 'Status', 'PICKLIST', '!=', 'Closed - Unsuccessfully',3,null,null));
		
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[12].id, 'Stage', 'StageName', 'PICKLIST', '=', 'Quote Completed',1,null,null));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[13].id, 'Target Date', 'Target_Date__c', 'DATETIME', '<', null,1,null,'TODAY'));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[13].id, 'Milestone Status (Reporting)', 'Milestone_Status_Reporting__c', 'STRING', '=','Open Violation',2,null,null));

	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[14].id, 'Stage', 'StageName', 'PICKLIST', '=', 'Not Contacted',1,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[15].id, 'Amount', 'Amount', 'CURRENCY', '	>=', '10000',1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[15].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'No Service',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[15].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'House Account',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[15].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Closed Sale',4,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[15].id, 'Earliest Expiration Date','REN_Earliest_Expiration_Date__c', 'DATE', '=', null,5,null,'THIS_QUARTER'));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[15].id, 'Earliest Expiration Date','REN_Earliest_Expiration_Date__c', 'DATE', '=', null,6,null,'LAST_QUARTER'));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[16].id, 'Commit Level', 'Commit_Level__c', 'PICKLIST', '=', 'Green',1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[16].id, 'Close Date', 'CloseDate', 'DATE', '=', null,2,null,'THIS_MONTH'));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[16].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'No Service',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[16].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'House Account',4,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[16].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Closed Sale',5,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[17].id, 'Earliest Expiration Date', 'REN_Earliest_Expiration_Date__c', 'DATE', '>', null,1,89,'NEXT_N_DAYS'));
        
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[18].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Quote Request'),1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[18].id, 'Status', 'Status', 'PICKLIST', '=', 'New',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[18].id, 'Status', 'Status', 'PICKLIST', '=', 'Work In Progress',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[18].id, 'Status', 'Status', 'PICKLIST', '=', 'On Hold',4,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[19].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Booking Request'),1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[19].id, 'Status', 'Status', 'PICKLIST', '=', 'New',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[19].id, 'Status', 'Status', 'PICKLIST', '=', 'Work In Progress',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[19].id, 'Status', 'Status', 'PICKLIST', '=', 'On Hold',4,null,null));

        fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[20].id, 'Status', 'Status', 'PICKLIST', '=', 'On Hold',1,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[21].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Data Processing Request'),1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[21].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Data Update Request'),2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[21].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Lead Submission'),3,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[22].id, 'Stage', 'StageName', 'PICKLIST', '=', 'Quote Completed',1,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[23].id, 'Earliest Expiration Date','REN_Earliest_Expiration_Date__c', 'DATE', '=', null,1,null,'THIS_WEEK'));
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[23].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'No Service',2,null,null));
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[23].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'House Account',3,null,null));
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[23].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Closed Sale',4,null,null));
	    fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[23].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Open - Consolidated',5,null,null));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[24].id, 'Target Date', '	Target_Date__c', 'DATETIME', '=', null,1,null,'TODAY'));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[25].id, 'Escalated', 'IsEscalated', 'BOOLEAN', '=','true',1,null,null));
        fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[25].id, 'Status', 'Status', 'PICKLIST', '!=', 'Closed',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[25].id, 'Status', 'Status', 'PICKLIST', '!=', 'Closed - Unsuccessfully',3,null,null));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[26].id, 'Ops Stage', 'Ops_Stage__c', 'PICKLIST', '=', 'Unsuccessful',1,null,null));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[27].id, 'Escalated', 'IsEscalated', 'BOOLEAN', '=', 'true',1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[27].id, 'Status', 'Status', 'PICKLIST', '!=', 'Closed',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[27].id, 'Status', 'Status', 'PICKLIST', '!=', 'Closed - Unsuccessfully',3,null,null));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[28].id, 'Assignment Date','Assignment_Date__c ', 'DATE', '=', null,1,null,null));
		
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[29].id, 'RecordType', 'RecordTypeId', 'REFERENCE', '=', caseRecordTypeMap.get('Quote Request'),1,null,null));
        fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[29].id, 'Status', 'Status', 'PICKLIST', '=', 'Closed',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[29].id, 'Status', 'Status', 'PICKLIST', '=', 'Closed - Unsuccessfully',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[29].id, 'Date/Time Closed','ClosedDate', 'DATE', '=', null,4,null,'TODAY'));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[30].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'No Service',1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[30].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'House Account',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[30].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Closed Sale',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[30].id, 'Earliest Expiration Date','REN_Earliest_Expiration_Date__c', 'DATE', '<', null,4,null,'THIS_QUARTER'));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[31].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'No Service',1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[31].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'House Account',2,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[31].id, 'Stage', 'StageName', 'PICKLIST', '!=', 'Closed Sale',3,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[31].id, 'Earliest Expiration Date','REN_Earliest_Expiration_Date__c', 'DATE', '<', null,4,null,'THIS_QUARTER'));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[32].id, 'Ops Stage', 'Ops_Stage__c', 'PICKLIST', '=', 'Unsuccessful',1,null,null));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[33].id, 'Assignment Date','Assignment_Date__c ', 'DATE', '=', null,1,null,null));
        fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[33].id, 'Target Date', '	Target_Date__c', 'DATETIME', '>=', null,1,null,'TODAY'));

		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[34].id, 'Assignment Date','Assignment_Date__c ', 'DATE', '=', null,1,null,null));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[34].id, 'Target Date', 'Target_Date__c', 'DATETIME', '<', null,2,null,'TODAY'));
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[34].id, 'Milestone Status (Reporting)', 'Milestone_Status_Reporting__c', 'STRING', '=','Open Violation',3,null,null));

		//35 Criteria
		fcViewCriteriaList.add(createFCCriteriaViewRec(fcViewList[35].id, 'Ops Stage', 'Ops_Stage__c', 'PICKLIST', '=', 'On Hold',1,null,null));
		
		insert fcViewCriteriaList;
	}
	
	
	

    /**
      * @description : This method used for creating coloums for Canned FC. Added as part of US2209.
    */
	private void insertColoumsFCView(List<CSM_Focus_Category_View__c> fcViewList){

		List<CSM_Focus_Category_View_Column__c> fcViewColList = new List<CSM_Focus_Category_View_Column__c>();

		fcViewColList.add(createColOppFCView(fcViewList[0].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[0].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[0].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[0].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[0].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[0].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[0].id,'Owner ID', 'OwnerId', 'REFERENCE', 'Opportunity'));

		fcViewColList.add(createColOppFCView(fcViewList[1].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[1].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[1].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[1].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[1].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[1].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[1].id,'Owner ID', 'OwnerId', 'REFERENCE', 'Opportunity'));

		fcViewColList.add(createColOppFCView(fcViewList[2].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[2].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[2].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[2].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[2].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[2].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[2].id,'Owner ID', 'OwnerId', 'REFERENCE', 'Opportunity'));

		fcViewColList.add(createColOppFCView(fcViewList[3].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[3].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[3].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[3].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[3].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[3].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[3].id,'Owner ID', 'OwnerId', 'REFERENCE', 'Opportunity'));

		fcViewColList.add(createColOppFCView(fcViewList[4].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[4].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[4].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[4].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[4].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[4].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[4].id,'Status','Status','PICKLIST','Case' ));
        fcViewColList.add(createColOppFCView(fcViewList[4].id,'Owner ID','OwnerId','REFERENCE','Case' ));
		
		 
		fcViewColList.add(createColOppFCView(fcViewList[5].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[5].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[5].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[5].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[5].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[5].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[5].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[5].id,'Owner ID','OwnerId','REFERENCE','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[6].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[6].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[6].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[6].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[6].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[6].id,'On Hold Reason','On_Hold_Reason__c','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[6].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[6].id,'Owner ID','OwnerId','REFERENCE','Case' ));

		fcViewColList.add(createColOppFCView(fcViewList[7].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[7].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[7].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[7].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[7].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[7].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[7].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[7].id,'Owner ID','OwnerId','REFERENCE','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[8].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[8].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[8].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[8].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[8].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[8].id,'On Hold Reason','On_Hold_Reason__c','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[8].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[8].id,'Owner ID','OwnerId','REFERENCE','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[9].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[9].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[9].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[9].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[9].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[9].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[9].id,'Owner ID', 'OwnerId', 'REFERENCE', 'Opportunity'));
		
		fcViewColList.add(createColOppFCView(fcViewList[10].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[10].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[10].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[10].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[10].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[10].id,'Milestone Status','MilestoneStatus','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[10].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[10].id,'Owner ID','OwnerId','REFERENCE','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[11].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[11].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[11].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[11].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[11].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[11].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[11].id,'Milestone Status','MilestoneStatus','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[11].id,'Owner ID','OwnerId','REFERENCE','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[12].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[12].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[12].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[12].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[12].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[12].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[12].id,'Owner ID', 'OwnerId', 'REFERENCE', 'Opportunity'));
		
		fcViewColList.add(createColOppFCView(fcViewList[13].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[13].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[13].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[13].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[13].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[13].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[13].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[13].id,'Milestone Status','MilestoneStatus','STRING','Case' ));
	   
        fcViewColList.add(createColOppFCView(fcViewList[14].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[14].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[14].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[14].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[14].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[14].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));

		fcViewColList.add(createColOppFCView(fcViewList[15].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[15].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[15].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[15].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[15].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[15].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[16].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[16].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[16].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[16].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[16].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[16].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[16].id,'Commit Level','Commit_Level__c','PICKLIST','Opportunityase'));
		
		fcViewColList.add(createColOppFCView(fcViewList[17].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[17].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[17].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[17].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[17].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[17].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
        
		fcViewColList.add(createColOppFCView(fcViewList[18].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[18].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[18].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[18].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[18].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[18].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[18].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[18].id,'Milestone Status','MilestoneStatus','STRING','Case' ));

		fcViewColList.add(createColOppFCView(fcViewList[19].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[19].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[19].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[19].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[19].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[19].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[19].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[19].id,'Milestone Status','MilestoneStatus','STRING','Case' ));

		fcViewColList.add(createColOppFCView(fcViewList[20].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[20].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[20].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[20].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[20].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[20].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[20].id,'On Hold Reason','On_Hold_Reason__c','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[20].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[21].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[21].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[21].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[21].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[21].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[21].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[21].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[21].id,'Milestone Status','MilestoneStatus','STRING','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[22].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[22].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[22].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[22].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[22].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[22].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));

		fcViewColList.add(createColOppFCView(fcViewList[23].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[23].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[23].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[23].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[23].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[23].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[24].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[24].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[24].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[24].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[24].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[24].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[24].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[24].id,'Milestone Status','MilestoneStatus','STRING','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[25].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[25].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[25].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[25].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[25].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[25].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[25].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[25].id,'Milestone Status','MilestoneStatus','STRING','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[26].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[26].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[26].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[26].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[26].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[26].id,'Ops Stage','Ops_Stage__c','Picklist','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[26].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[27].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[27].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[27].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[27].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[27].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[27].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[27].id,'Owner ID','OwnerId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[27].id,'Escalation Reason','Escalation_Reason__c','TEXTAREA','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[28].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[28].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[28].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[28].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[28].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[28].id,'Milestone Status','MilestoneStatus','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[28].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[28].id,'Contact Name','ContactId','REFERENCE','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[29].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[29].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[29].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[29].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[29].id,'Closed Date','ClosedDate','DATETIME','Case'));
		fcViewColList.add(createColOppFCView(fcViewList[29].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[29].id,'Status','Status','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[29].id,'Owner ID','OwnerId','REFERENCE','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[30].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[30].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[30].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[30].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[30].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[30].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[31].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[31].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[31].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[31].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[31].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[31].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[31].id,'Owner ID', 'OwnerId', 'REFERENCE', 'Opportunity'));
		
		fcViewColList.add(createColOppFCView(fcViewList[32].id,'Name','Name','STRING','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[32].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[32].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[32].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[32].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[32].id,'Ops Stage','Ops_Stage__c','Picklist','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[32].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[32].id,'Owner ID', 'OwnerId', 'REFERENCE', 'Opportunity'));
		
		fcViewColList.add(createColOppFCView(fcViewList[33].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[33].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[33].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[33].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[33].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[33].id,'Milestone Status','MilestoneStatus','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[33].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[33].id,'Contact Name','ContactId','REFERENCE','Case' ));
		
		fcViewColList.add(createColOppFCView(fcViewList[34].id,'Case Number','CaseNumber','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[34].id,'Record Type ID','RecordTypeId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[34].id,'Contact Name','ContactId','REFERENCE','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[34].id,'Subject','Subject','STRING','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[34].id,'Priority','Priority','PICKLIST','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[34].id,'Created Date','CreatedDate','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[34].id,'Target Date','Target_Date__c','DATETIME','Case' ));
		fcViewColList.add(createColOppFCView(fcViewList[34].id,'Milestone Status','MilestoneStatus','STRING','Case' ));

		fcViewColList.add(createColOppFCView(fcViewList[35].id,'Account','AccountId','REFERENCE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[35].id,'Amount','Amount','CURRENCY','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[35].id,'Close Date','CloseDate','DATE','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[35].id,'Stage','StageName','PICKLIST','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[35].id,'Ops Stage','Ops_Stage__c','Picklist','Opportunity' ));
		fcViewColList.add(createColOppFCView(fcViewList[35].id,'Earliest Expiration Date','REN_Earliest_Expiration_Date__c','DATE','Opportunity' ));
		
		insert fcViewColList;
	}
	
	/**
    * @description : This method used for sharing FC with the respective punlic groups. Added as part of US2209.
    */
	private void createFCShareRecordsForGroups(List<CSM_Focus_Category_View__c> fcViewList, Map<String,String> grpMap){
		
		List<CSM_Focus_Category_View__Share> shareFCViewList =  new List<CSM_Focus_Category_View__Share>();
		shareFCViewList.add(createShareFCViewRec(fcViewList[0].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[1].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[2].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[3].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[4].id,grpMap.get('Operations Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[5].id,grpMap.get('Operations Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[6].id,grpMap.get('Operations Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[7].id,grpMap.get('Operations Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[8].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[9].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[10].id,grpMap.get('Operations Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[11].id,grpMap.get('Operations Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[12].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[13].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[14].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[15].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[16].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[17].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[18].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[19].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[20].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[21].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[22].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[23].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[24].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[25].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[26].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[27].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[28].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[29].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[30].id,grpMap.get('Sales Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[31].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[32].id,grpMap.get('Sales Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[33].id,grpMap.get('Operations Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[33].id,grpMap.get('Operations Rep')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[34].id,grpMap.get('Operations Manager')));
		shareFCViewList.add(createShareFCViewRec(fcViewList[35].id,grpMap.get('Sales Rep')));

		insert shareFCViewList;
	}
    
	/**
    * @description : This method used for record creation of coloums for Canned FC. Added as part of US2209.
    */
	private CSM_Focus_Category_View_Column__c createColOppFCView(Id fcViewID,String displayName, String fieldApiName, String fieldType, String objectName){
		CSM_Focus_Category_View_Column__c  fcViewColObj1 = new CSM_Focus_Category_View_Column__c();
		fcViewColObj1.CSM_Display_Name__c = displayName;
		fcViewColObj1.CSM_Focus_Category_View__c = fcViewID;
		fcViewColObj1.CSM_Object_Field_Name__c = fieldApiName;
		fcViewColObj1.CSM_Object_Field_Type__c = fieldType;
		fcViewColObj1.CSM_Object_Name__c = objectName;
		return fcViewColObj1;
	}
    
	/**
    * @description : This method used for record creation of criteria for Canned FC. Added as part of US2209.
    */
	private CSM_Focus_Category_View_Criteria__c createFCCriteriaViewRec(Id fcViewId, String displayName, String apiName, String fieldType, String operator, string value, Integer lineNo, Integer dateLiteral, String dateLiteralStr){
		CSM_Focus_Category_View_Criteria__c  fcViewCriteriaObj = new CSM_Focus_Category_View_Criteria__c();
		fcViewCriteriaObj.CSM_Focus_Category_View__c = fcViewId;
		fcViewCriteriaObj.RLM_Field_Display_Name__c = displayName;
		fcViewCriteriaObj.RLM_Field_Name__c = apiName;
		fcViewCriteriaObj.RLM_Field_Type__c = fieldType;
		fcViewCriteriaObj.RLM_LineNo__c = lineNo;
		fcViewCriteriaObj.RLM_Operator__c= operator;
		fcViewCriteriaObj.RLM_Values__c = value;
		fcViewCriteriaObj.RLM_Date_Literal_Number__c = dateLiteral;
		fcViewCriteriaObj.RLM_Date_Literal_String__c= dateLiteralStr;
		if(	displayName == 'Assignment Date'){
			fcViewCriteriaObj.RLM_Is_Specific_Date__c = true;
		} else { 
			fcViewCriteriaObj.RLM_Is_Specific_Date__c = false;
		}
		return fcViewCriteriaObj;
	}

	/**
    * @description : This method used for public group creation. Before creation of groups it checks in Org ,If not then only it will create Groups.
					 Added as part of US2209.
    */
	private Map<String,String> insertPublicGroup(){
		List<Group> groupListAvailable = [select id,name from Group where name in ('Sales Manager','Sales Rep','Operations Manager','Operations Rep','Booking Team','Data Processing Team','Data Update Team','Escalation Team','Individual - Sales','Lead Submission Team','Quote Request Team','Reporting Team','Review Team') ];
		List<Group> groupList = new List<Group>();
		Set<String> availableGroupSet;
		Map<String,String> groupDetailsMap = new Map<String,String>();
		if(groupListAvailable==null || !(groupListAvailable.size()>0)){
			groupList.add(createPublicGroupRecord('Sales Manager'));
			groupList.add(createPublicGroupRecord('Sales Rep'));
			groupList.add(createPublicGroupRecord('Operations Manager'));
			groupList.add(createPublicGroupRecord('Operations Rep'));
			groupList.add(createPublicGroupRecord('Booking Team'));
			groupList.add(createPublicGroupRecord('Data Processing Team'));
			groupList.add(createPublicGroupRecord('Data Update Team'));
			groupList.add(createPublicGroupRecord('Escalation Team'));
			groupList.add(createPublicGroupRecord('Individual - Sales'));
			groupList.add(createPublicGroupRecord('Lead Submission Team'));
			groupList.add(createPublicGroupRecord('Quote Request Team'));
			groupList.add(createPublicGroupRecord('Reporting Team'));
			groupList.add(createPublicGroupRecord('Review Team'));
			insert groupList;
		} else {
			availableGroupSet = new Set<String>();
			for(Group grp : groupListAvailable){
				availableGroupSet.add(grp.name);
				groupDetailsMap.put(grp.name,grp.id);
			}
			if(!availableGroupSet.Contains('Sales Manager')){
			   groupList.add(createPublicGroupRecord('Sales Manager'));
			}
			
			if(!availableGroupSet.Contains('Sales Rep')){
			   groupList.add(createPublicGroupRecord('Sales Rep'));
			}
			
			if(!availableGroupSet.Contains('Operations Manager')){
			   groupList.add(createPublicGroupRecord('Operations Manager'));
			}
			
			if(!availableGroupSet.Contains('Operations Rep')){
			   groupList.add(createPublicGroupRecord('Operations Rep'));
			}
			
			if(!availableGroupSet.Contains('Booking Team')){
			   groupList.add(createPublicGroupRecord('Booking Team'));
			}
			
			if(!availableGroupSet.Contains('Data Processing Team')){
			   groupList.add(createPublicGroupRecord('Data Processing Team'));
			}
			
			if(!availableGroupSet.Contains('Data Update Team')){
			   groupList.add(createPublicGroupRecord('Data Update Team'));
			}
			
			if(!availableGroupSet.Contains('Escalation Team')){
			   groupList.add(createPublicGroupRecord('Escalation Team'));
			}
			
			if(!availableGroupSet.Contains('Individual - Sales')){
			   groupList.add(createPublicGroupRecord('Individual - Sales'));
			}
			
			if(!availableGroupSet.Contains('Lead Submission Team')){
			   groupList.add(createPublicGroupRecord('Lead Submission Team'));
			}
			
			if(!availableGroupSet.Contains('Quote Request Team')){
			   groupList.add(createPublicGroupRecord('Quote Request Team'));
			}
			
			if(!availableGroupSet.Contains('Reporting Team')){
			   groupList.add(createPublicGroupRecord('Reporting Team'));
			}
			
			if(!availableGroupSet.Contains('Review Team')){
			   groupList.add(createPublicGroupRecord('Review Team'));
			}
						
			if(groupList != null){
				insert groupList;
			}
		}
		
		for(Group grp : groupList){
			groupDetailsMap.put(grp.name,grp.id);
		}
		
		return groupDetailsMap;
	}
	
	/**
    * @description : This method used for public group record creation. Added as part of US2209.
    */
	private Group createPublicGroupRecord(String groupName){
		Group groupObj = new Group();
		groupObj.Name = groupName;
		return groupObj;
	}

	/**
    * @description : This method used for record creation for sharing Public groups and Canned FC. Added as part of US2209.
    */
	private CSM_Focus_Category_View__Share createShareFCViewRec(ID fcView,ID GroupId){
		CSM_Focus_Category_View__Share fcViewShareObj = new CSM_Focus_Category_View__Share();
		fcViewShareObj.ParentId = fcView;
		fcViewShareObj.UserOrGroupId = GroupId;
		fcViewShareObj.AccessLevel = 'Edit';
		return fcViewShareObj;
	}

	/**
    * @description : This method used for case record type details. Added as part of US2209.
    */
	private map<String,String> getCaseRecordTypeMap(){	  
		map<String,String> recordTypeMap = new map<String,String>();
		List<RecordType> recTypeList =  [SELECT Id,Name FROM RecordType where SobjectType = 'Case'];
		for(RecordType rtObj : recTypeList){
			recordTypeMap.put(rtObj.Name, rtObj.id);
		}
		return recordTypeMap;
	}
    
	/**
    * @description : This method used for to get corporate currency code. Added as part of US2209.
    */
	private String getCorpCurrency(){         
        String corporateCurrencyIsoCode; 
        if (UserInfo.isMultiCurrencyOrganization()){
        	List<String> fieldList = new List<String>{'conversionrate', 'isocode','IsActive','IsCorporate'};
           // CSM_Util.checkCRUD_FLS('currencytype', fieldList, CSM_Constants.DML_OPERATION_READ);
            String q='select IsoCode, ConversionRate from CurrencyType where IsActive=true and IsCorporate=true';
            List<SObject> currencies = Database.query(q);
            if (currencies.size()>0){
                corporateCurrencyIsoCode=(String)currencies[0].get('ISOCode');  
            }
        } 
        return corporateCurrencyIsoCode;
    }
//------------------------------US2209-------------END    	--------------------------US2209-------------END    	

/**

* @description : This method used to insert users  into public groups having permission set  Operations Manager, Operations Rep, SalesMgr, SalesRep
*/
	
	public void insertUsersToPublicGroups()
	{
		Set<String> sExtPermissionSetName = new Set<String>{'SSI_Zenith_Operation_Services_Manager_Permission','SSI_Zenith_Operation_Services_Rep_Permission','SSI_Zenith_Sales_Manager_Permission','SSI_Zenith_Sales_Rep_Permission','PRISM_Ops_Manager_Restrictions','PRISM_Ops_Rep_Restrictions','PRISM_Sales_Manager_Restrictions','PRISM_Sales_Rep_Restrictions'};
	    Set<Id> setUsersSM = new Set<Id>();
	    Set<Id> setUsersSR = new Set<Id>();
	    Set<Id> setUsersOM = new Set<Id>();
	    Set<Id> setUsersOR = new Set<Id>();
	   	Map<String,Id> mapOfUserTOPermissionSet = new Map<String,Id>();
	   	for(PermissionSetAssignment userPerSet : [SELECT Id, PermissionSet.Name,AssigneeId
	                                             FROM PermissionSetAssignment WHERE PermissionSet.Name IN:sExtPermissionSetName]){
			if((userPerSet.PermissionSet.Name == 'SSI_Zenith_Operation_Services_Manager_Permission') || (userPerSet.PermissionSet.Name == 'PRISM_Ops_Manager_Restrictions')){
		    	setUsersOM.add(userPerSet.AssigneeId);	 
			}
		 	if((userPerSet.PermissionSet.Name == 'SSI_Zenith_Operation_Services_Rep_Permission') || (userPerSet.PermissionSet.Name == 'PRISM_Ops_Rep_Restrictions')){
         		setUsersOR.add(userPerSet.AssigneeId);	 
			}
			if((userPerSet.PermissionSet.Name == 'SSI_Zenith_Sales_Manager_Permission') || (userPerSet.PermissionSet.Name == 'PRISM_Sales_Manager_Restrictions')){
     			setUsersSM.add(userPerSet.AssigneeId);	 
		    }
		 	if((userPerSet.PermissionSet.Name == 'SSI_Zenith_Sales_Rep_Permission') || (userPerSet.PermissionSet.Name == 'PRISM_Sales_Rep_Restrictions')){
         		setUsersSR.add(userPerSet.AssigneeId);	 
		 	}
	    }
	    Map<String,Id> mapOfGroupToGM = new  Map<String,Id>();
	   	for(Group gr:[select id,name from Group where name in ('Sales Manager','Sales Rep','Operations Manager','Operations Rep') AND Type = 'Regular']){
	    	mapOfGroupToGM.put(gr.name,gr.id);
	    }
	    List<GroupMember> gmList = new List<GroupMember>();
	    if((sExtPermissionSetName.contains('SSI_Zenith_Sales_Manager_Permission'))
	    || (sExtPermissionSetName.contains('PRISM_Sales_Manager_Restrictions'))){
	    	for(Id setOfUser:setUsersSM){
	    		if(mapOfGroupToGM.containskey('Sales Manager')){
	    				gmList = insertGMList(gmList,mapOfGroupToGM.get('Sales Manager'),setOfUser);
	    				system.debug('gmList'+gmList);
	    		}
	    	}
	    }
	    if((sExtPermissionSetName.contains('SSI_Zenith_Sales_Rep_Permission'))
	    || (sExtPermissionSetName.contains('PRISM_Sales_Rep_Restrictions'))){
	    	for(Id setOfUser:setUsersSR){
	    		if(mapOfGroupToGM.containskey('Sales Rep')){
	    				gmList = insertGMList(gmList,mapOfGroupToGM.get('Sales Rep'),setOfUser);
	    				system.debug('gmList'+gmList);
	    		}
	    	}
	    }
		if((sExtPermissionSetName.contains('SSI_Zenith_Operation_Services_Manager_Permission'))
		|| (sExtPermissionSetName.contains('PRISM_Ops_Manager_Restrictions'))){
	    	for(Id setOfUser:setUsersOM){
	    		if(mapOfGroupToGM.containskey('Operations Manager')){
	    				gmList = insertGMList(gmList,mapOfGroupToGM.get('Operations Manager'),setOfUser);
	    				system.debug('gmList'+gmList);
	    		}
	    	}
	    }
	    if((sExtPermissionSetName.contains('SSI_Zenith_Operation_Services_Rep_Permission'))
	    || (sExtPermissionSetName.contains('PRISM_Ops_Rep_Restrictions'))){
	    	for(Id setOfUser:setUsersOR){
	    		if(mapOfGroupToGM.containskey('Operations Rep')){
	    				gmList = insertGMList(gmList,mapOfGroupToGM.get('Operations Rep'),setOfUser);
	    				system.debug('gmList'+gmList);
	    		}
	    	}
	    }
        insert gmList;
	}
					
	public List<GroupMember> insertGMList(List<GroupMember> gmList ,Id groupId, Id userId){
		GroupMember objGroupMember = new GroupMember();
	  	objGroupMember.GroupId = groupId;
	   	objGroupMember.UserOrGroupId = userId;
	    gmList.add(objGroupMember); 
	    return gmList;
	}
	
	/* Added for DE2387 */
	private void deleteCannedFCRecords(InstallContext context){
        if(context.previousVersion() != null && context.previousVersion().compareTo(new Version(2,88)) < 0){
     		List<CSM_Focus_Category_View__c> availableFcViewList  = [select id from CSM_Focus_Category_View__c where name in ('Cases On Hold', 'My Quote Completed Opps', 'My Opportunities Expiring this Week', 'Opportunities Expiring this Week', 'Open Escalated Cases', 'Completed Quotes today', 'My Overdue cases', 'My Cases due today', 'My Escalated Cases', 'Upcoming Unassigned cases', 'Overdue Unassigned cases', 'Cases due today', 'Escalated Cases', 'My opps with an On Hold Case', 'All Quote Completed Opps', 'My Opps with Unsuccessful Quote/Booking', 'Opps with Unsuccessful Quotes & Bookings', 'My Opportunities 90 DIA', 'My Not contacted Opportunities', 'My Carryover opportunities', 'My Top Deals (Oppt amount > 10K)', 'My Opps likely to close this month', 'Opportunities 90 DIA', 'Not contacted Opportunities', 'Carryover opportunities', 'Top Deals (Oppt amount > 10K)', 'Opportunities likely to close this month', 'My Quote Cases', 'My Booking cases', 'My On hold cases', 'Unassigned cases', 'My All other cases', 'Quote Cases', 'Booking cases', 'On hold cases', 'All Other Cases')];
     		if(availableFcViewList != null && !availableFcViewList.isEmpty()){
     			delete availableFcViewList;
     		}
        }
     }
     
     /**DE2550:This method is used to update existing SOQL of focus category **/
    private void updateSOQLExistingFCV(){
    	try{
	    	List<CSM_Focus_Category_View__c> updatedFcvList=new List<CSM_Focus_Category_View__c>();
			List<CSM_Focus_Category_View__c> fcvList=[SELECT CSM_Columns__c,CSM_Display_Name__c,CSM_Criteria__c,CSM_Filter_By_Owner_Value__c,CSM_SOQL__c,Id,Name 
													  FROM CSM_Focus_Category_View__c 
													  WHERE CSM_Filter_By_Owner_Value__c LIKE '%My%' LIMIT 5000];
													  
				if(fcvList!=null){
					for(CSM_Focus_Category_View__c fcv:fcvList) {
						if(!String.isBlank(fcv.CSM_SOQL__c)) {
			  				if(!(fcv.CSM_SOQL__c.toLowerCase().contains('ownerid = <placeholder>'))) {
			    				if(fcv.CSM_SOQL__c.toLowerCase().contains('where')) {
			    					if(fcv.CSM_SOQL__c.toLowerCase().contains('order by')) {
			    						String[] soqlArr = fcv.CSM_SOQL__c.split('order by');
			    						if(soqlArr.size() != 2) {
			    							soqlArr = fcv.CSM_SOQL__c.split('Order By');
			    						}
			    						fcv.CSM_SOQL__c = soqlArr[0] + ' and ownerId = <placeholder>' + ' Order By ' + soqlArr[1];
			                    		updatedFcvList.add(fcv);
			    					} else {
			    						fcv.CSM_SOQL__c += ' and ownerId = <placeholder>';
			                    		updatedFcvList.add(fcv);
			    					}
			    				} else {
			    					if(fcv.CSM_SOQL__c.toLowerCase().contains('order by')) {
			    						String[] soqlArr = fcv.CSM_SOQL__c.split('order by');
			    						if(soqlArr.size() != 2) {
			    							soqlArr = fcv.CSM_SOQL__c.split('Order By');
			    						}
			    						fcv.CSM_SOQL__c = soqlArr[0] + ' where ownerId = <placeholder>' + ' Order By ' + soqlArr[1];
			                    		updatedFcvList.add(fcv);
			    					} else {
			    						fcv.CSM_SOQL__c += ' where ownerId = <placeholder>';
			                    		updatedFcvList.add(fcv);
			    			        }                      		
			    				}
			    			}
						}
					}
					update updatedFcvList;
				}
			}catch(Exception e){
				errorDetails = e.getMessage() + 'Line no : ' + e.getLineNumber() + ' StackTraceString : ' + e.getStackTraceString() + 'Cause :' + e.getCause();
			}	
	}
}