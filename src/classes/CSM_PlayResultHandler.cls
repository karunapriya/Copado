public with sharing class CSM_PlayResultHandler 
{
 public static void handlePlayResults(List<sObject> playResults)
    {
       SS_LicenseCheck.getUserType();
        Boolean hasCSMAccess = SS_Constants.isCSMNetOpsUser==true;
        Boolean hasRenewAccess = SS_Constants.isRenewNetOpsUser==true;
            
        if (hasCSMAccess || hasRenewAccess) {
        
            List<CSM_Play_Result__c> newPlayResultLst = CSM_PlayResultDataAccess.getPlayResultsById(playResults);
            
            //Contains AccountId
            Set<Id> pendingAcctSet = new Set<Id>();
            Set<Id> attainedAcctSet = new Set<Id>();
            Set<Id> haltedAcctSet = new Set<Id>();
        
            //Contains Play ExternalId
            Set<String> haltedPlaySet = new Set<String>();
            Set<String> attainedPlaySet = new Set<String>();
            Map<String, Set<String>> pendingAccounts2PlayMap = new Map<String, Set<String>>();
            
            List<CSM_Play_Result__c> errorPlayResult = new List<CSM_Play_Result__c>();
            Set<String> tmpPlayExtSet = new Set<String>();
        
            //contains PlayResultId-->PlayResult
            Map<Id, CSM_Play_Result__c> playResultsMap = new Map<Id, CSM_Play_Result__c> (newPlayResultLst);
        
            Map<String, CSM_Play_Result__c> updateInsertPlaysMap = new Map<String, CSM_Play_Result__c>();
            Map<String, CSM_Play_Result__c> updateInsertPlayBookMap = new Map<String, CSM_Play_Result__c>();
            Map<String, CSM_Play_Result__c> accountPlayResult = new Map<String, CSM_Play_Result__c>();
            //Map<String, CSM_Play_Result__c> accountPlayResult2 = new Map<String, CSM_Play_Result__c>(); 
             
            
            Map<Id, CSM_Account_Plan__c> account2AccountPlanMap = new Map<Id, CSM_Account_Plan__c>(); //AccountId --> AccountPlan
            Map<Id, CSM_Account_Plan__c> accountPlanMap = new Map<Id, CSM_Account_Plan__c>(); //change name //AccountPlanId --> AccountPlan
        
        
            // Validation plus keep track of the values where information is not presented so we can update the failure info
            // When introducing Opportunities, replace 'playResult.CSM_Account_Id__c != null' --->> '(playResult.CSM_Account_Id__c != null || playResult.CSM_Opportunity_Id__c != null)'
            for(CSM_Play_Result__c playResult : newPlayResultLst)
            {
                if(playResult.CSM_Play_Result_Id__c != null && playResult.CSM_Resolution_Status__c != null && playResult.CSM_Account_Id__c != null)
                {
                    if(playResult.CSM_Play_External_Id__c !=null)
                    {
                        //Process Resolution Status
                        if(playResult.CSM_Resolution_Status__c.toLowerCase() == CSM_Constants.INT_PLAYRESULT_PENDING.toLowerCase())
                        {
                            pendingAcctSet.add(playResult.CSM_Account_Id__c);
                            tmpPlayExtSet = pendingAccounts2PlayMap.get(playResult.CSM_Account_Id__c);
                            if(tmpPlayExtSet == null)
                            {
                                tmpPlayExtSet = new Set<String>(); 
                            }
                            tmpPlayExtSet.add(playResult.CSM_Play_External_Id__c);
                            pendingAccounts2PlayMap.put(playResult.CSM_Account_Id__c, tmpPlayExtSet);
                            accountPlayResult.put(playResult.CSM_Account_Id__c, playResult);
                            //accountPlayResult2.put(playResult.CSM_Account_Id__c+':'+playResult.CSM_Play_External_Id__c, playResult);
                        }
                        else if(playResult.CSM_Resolution_Status__c.toLowerCase() == CSM_Constants.INT_PLAYRESULT_ATTAINED.toLowerCase())
                        {
                            attainedAcctSet.add(playResult.CSM_Account_Id__c);
                            attainedPlaySet.add(playResult.CSM_Play_External_Id__c);
                            accountPlayResult.put(playResult.CSM_Account_Id__c, playResult);
                        }
                        else if(playResult.CSM_Resolution_Status__c.toLowerCase() == CSM_Constants.INT_PLAYRESULT_HALTED.toLowerCase())
                        {
                            haltedAcctSet.add(playResult.CSM_Account_Id__c);
                            haltedPlaySet.add(playResult.CSM_Play_External_Id__c);
                            accountPlayResult.put(playResult.CSM_Account_Id__c, playResult);
                        }
                        else
                        {
                            //Report Error
                            playResult = addError(playResult, CSM_Constants.INT_RESOLUTION_STATUS_UNRECOGNIZED);
                            errorPlayResult.add(playResult);
                            continue;
                        }
                    }
                    else
                    {
                        //Report Error
                        playResult = addError(playResult, CSM_Constants.INT_PLAY_MISSING);
                        errorPlayResult.add(playResult);
                        continue;
                    }
                }
                
                if(playResult.CSM_Play_Result_Id__c != null && playResult.CSM_Resolution_Status__c == null)
                {
                    //Report Error
                    playResult = addError(playResult, CSM_Constants.INT_RESOLUTION_STATUS_MISSING);
                    errorPlayResult.add(playResult);
                    continue;
                }
                else if(playResult.CSM_Play_Result_Id__c != null && playResult.CSM_Account_Id__c == null)
                {
                    ///Report Error
                    playResult = addError(playResult, CSM_Constants.INT_ACCOUNTID_MISSING);
                    errorPlayResult.add(playResult);
                    continue;
                }
                else if(playResult.CSM_Resolution_Status__c != null && playResult.CSM_Account_Id__c == null)
                {
                    //Report Error
                    playResult = addError(playResult, CSM_Constants.INT_ACCOUNTID_MISSING);
                    errorPlayResult.add(playResult);
                    continue;
                }
                else if(playResult.CSM_Resolution_Status__c != null && playResult.CSM_Play_Result_Id__c == null)
                {
                    //Report Error
                    playResult = addError(playResult, CSM_Constants.INT_PLAYRESULT_MISSING);
                    errorPlayResult.add(playResult);
                    continue;
                }
                else if(playResult.CSM_Account_Id__c != null && playResult.CSM_Resolution_Status__c == null)
                {
                    //Report Error 
                    playResult = addError(playResult, CSM_Constants.INT_RESOLUTION_STATUS_MISSING);
                    errorPlayResult.add(playResult);
                    continue;
                }
                else if(playResult.CSM_Account_Id__c != null && playResult.CSM_Play_Result_Id__c == null)
                {
                    //Report Error 
                    playResult = addError(playResult, CSM_Constants.INT_PLAYRESULT_MISSING);
                    errorPlayResult.add(playResult);
                    continue;
                }
                else
                {
                    //Process Insert/Update Existing PLAYBOOKS, PLAYS. Create playbookplays as needed
                    if(playResult.CSM_Play_External_Id__c != null)
                    {
                        //Insert/update Plays
                        system.debug('insert play');
                        updateInsertPlaysMap.put(playResult.CSM_Play_External_Id__c, playResult);
                        updateInsertPlayBookMap.put(playResult.CSM_Playbook_External_Id__c, playResult);
                    }
                    else if(playResult.CSM_Playbook_External_Id__c != null)
                    {
                        //Insert/update Playbooks
                        system.debug('insert playbook');
                        updateInsertPlayBookMap.put(playResult.CSM_Playbook_External_Id__c, playResult);
                    }
                    else
                    {
                        //Report Error
                        playResult = addError(playResult, CSM_Constants.INT_PLAYBOOK_MISSING + ' AND ' + CSM_Constants.INT_PLAY_MISSING);
                        errorPlayResult.add(playResult);
                        continue;
                    }
                    System.debug('FFF updateInsertPlaysMap - '+updateInsertPlaysMap);
                }
            }
            
            if((updateInsertPlaysMap != null && !updateInsertPlaysMap.isEmpty()) || (updateInsertPlayBookMap != null && !updateInsertPlayBookMap.isEmpty()))
            {
                createUpdatePlaysNBooks(updateInsertPlaysMap, updateInsertPlayBookMap);
            }
            
            if (accountPlayResult != null && !accountPlayResult.isEmpty())
            {
                Map<Id, Account> acctMap = CSM_AccountDataAccess.getAcctMapById(accountPlayResult.keySet());
                accountPlanMap = new Map<Id, CSM_Account_Plan__c>(CSM_AccountPlanDataAccess.getAccountPlansById(accountPlayResult));
    
                if (accountPlanMap != null && !accountPlanMap.isEmpty())
                {
                    //get active accountplan list
                    for (CSM_Account_Plan__c ap : accountPlanMap.values())
                    {
                        account2AccountPlanMap.put(ap.CSM_AccountId__c, ap);
                    }
                }
                Map<String, CSM_Play_Result__c> toCreate_Accts_PlayResults = new Map<String, CSM_Play_Result__c>();
                for(String acctId :accountPlayResult.keySet())
                {
                    if (acctMap.containsKey(acctId))
                    {
                        if(!(account2AccountPlanMap.keySet()).contains(acctId))
                        {
                            toCreate_Accts_PlayResults.put(acctId, accountPlayResult.get(acctId));
                        }
                    }
                    else
                    {
                        CSM_Play_Result__c playResult = addError(accountPlayResult.get(acctId), CSM_Constants.INT_ACCOUNT_ID_INCORRECT);
                        errorPlayResult.add(playResult);
                    }
                }
        
                if (toCreate_Accts_PlayResults != null && !toCreate_Accts_PlayResults.isEmpty())
                {
                    //create automated default template
                    CSM_Account_Plan_Template__c automatedDefault;
                    List<CSM_Account_Plan_Template__c> lstAutomatedTemplates = CSM_AccountPlanTemplateDataAccess.getTemplateByName();
                    
                    if(lstAutomatedTemplates != null && !lstAutomatedTemplates.isEmpty())
                    {
                        automatedDefault = lstAutomatedTemplates[0];
                    }
                    else
                    {
                        automatedDefault = new CSM_Account_Plan_Template__c(CSM_Template_Name__c = CSM_Constants.NAME_AUTOMATED_TEMPLATE, CSM_isActive__c = true, CSM_UseasScout_Default_Template__c = true);
                        insert automatedDefault;
                    }
                    
                    List<CSM_Account_Plan__c> toCreate_SuccessPlans = new List<CSM_Account_Plan__c>();
                    for(CSM_Play_Result__c pl :toCreate_Accts_PlayResults.values())
                    {
                        CSM_Account_Plan__c acctPlan = new CSM_Account_Plan__c();
                        acctPlan.CSM_AccountId__c = pl.CSM_Account_Id__c;
                        acctPlan.CSM_Account_Plan_Template__c = automatedDefault.Id;
                        acctPlan.CSM_Phase_Start_Date__c = system.today();
                        acctPlan.CSM_IsActive__c = true;
                        toCreate_SuccessPlans.add(acctPlan);
                    }
                    
                    
                    if(toCreate_SuccessPlans != null && !toCreate_SuccessPlans.isEmpty())
                    {
                        CSM_Constants.ACCOUNT_PLAN_TRIGGER = false;
                        insert toCreate_SuccessPlans;
                        toCreate_SuccessPlans = new List<CSM_Account_Plan__c>(CSM_AccountPlanDataAccess.getAccountPlansById(toCreate_Accts_PlayResults));
                                        
                        for(CSM_Account_Plan__c ap :toCreate_SuccessPlans)
                        {
                            accountPlanMap.put(ap.Id, ap);
                            account2AccountPlanMap.put(ap.CSM_AccountId__c, ap);
                        }
                    }
                }
                
                // Process Play Results
                if (accountPlayResult != null && !accountPlayResult.isEmpty())
                {              		
                	System.debug('ZZZZ - pendingAccounts2PlayMap - '+pendingAccounts2PlayMap);
                	
                    processPlayResult(account2AccountPlanMap, playResultsMap, accountPlayResult, 
                                      pendingAcctSet, attainedAcctSet, haltedAcctSet, 
                                      pendingAccounts2PlayMap, attainedPlaySet, haltedPlaySet, 
                                      accountPlanMap);
                }
            }
            
            if (!errorPlayResult.isEmpty())
            {
                CSM_PlayResultDataAccess.updatePlayResults(errorPlayResult);
            }
            List<CSM_Play_Result__c> lstPR2Update = new List<CSM_Play_Result__c>();
            List<CSM_Play_Result_History__c> lstPRHistory = new List<CSM_Play_Result_History__c>();
        
            for (CSM_Play_Result__c pr : newPlayResultLst) 
            {
                if (pr.CSM_Failed__c == false)
                {
                    pr.CSM_Processed__c = true;
                    lstPR2Update.add(pr);
                }
                CSM_Play_Result_History__c playHistory = new CSM_Play_Result_History__c();
                playHistory.CSM_Account_Id__c = pr.CSM_Account_Id__c;
                playHistory.CSM_Assignee__c = pr.CSM_Assignee__c; 
                playHistory.CSM_Enter_Date__c = pr.CSM_Enter_Date__c;
                playHistory.CSM_Exit_Date__c = pr.CSM_Exit_Date__c;
                playHistory.CSM_Failed__c = pr.CSM_Failed__c; 
                playHistory.CSM_Failed_Description__c = pr.CSM_Failed_Description__c;
                playHistory.CSM_Playbook_Description__c = pr.CSM_Playbook_Description__c;
                playHistory.CSM_Playbook_External_Id__c = pr.CSM_Playbook_External_Id__c;
                playHistory.CSM_Playbook_Name__c = pr.CSM_Playbook_Name__c;
                playHistory.CSM_Play_Description__c = pr.CSM_Play_Description__c;
                playHistory.CSM_Play_External_Id__c = pr.CSM_Play_External_Id__c;
                playHistory.CSM_Play_Name__c = pr.CSM_Play_Name__c;
                playHistory.CSM_Play_Object__c = pr.CSM_Play_Object__c;
                playHistory.CSM_Play_Result_Id__c = pr.CSM_Play_Result_Id__c;
                playHistory.CSM_Processed__c = pr.CSM_Processed__c;
                playHistory.CSM_Resolution_Status__c = pr.CSM_Resolution_Status__c;
                playHistory.CSM_Subscription_Id__c = pr.CSM_Subscription_Id__c;
                lstPRHistory.add(playHistory);
            }
            CSM_PlayResultDataAccess.updatePlayResults(lstPR2Update);
            CSM_PlayResultHistoryDataAccess.createPlayResultHistory(lstPRHistory);
        }
    }
    
    private static CSM_Play_Result__c addError(CSM_Play_Result__c playResult, String failedDesc)
    {
        playResult.CSM_Failed__c = true;
        playResult.CSM_Failed_Description__c = failedDesc;
        return playResult;
    }
    
      private static void createUpdatePlaysNBooks(Map<String, CSM_Play_Result__c> updateInsertPlaysMap, Map<String, CSM_Play_Result__c> updateInsertPlayBookMap)
    {
        
        Map<String, CSM_Playbook__c> existingPLBMap = new Map<String, CSM_Playbook__c>();
        Map<Id, CSM_Playbook__c> existingPLBMapTmp = new Map<Id, CSM_Playbook__c>();
    
        Map<String, CSM_Play__c> existingPLMap = new Map<String, CSM_Play__c>();
        Map<Id, CSM_Play__c> existingPLMapTmp = new Map<Id, CSM_Play__c>();
    
        List<CSM_Playbook__c> lstPLBUpsert = new List<CSM_Playbook__c>();
        List<CSM_Play__c> lstPLUpsert = new List<CSM_Play__c>();
    
    	//HANDLE PLAYBOOKS
        if(updateInsertPlayBookMap != null && !updateInsertPlayBookMap.isEmpty())
        {
            //Query DB for existing Playbooks, 
            existingPLBMapTmp = CSM_PlaybooksDataAccess.getPlaybookMapByExtId(updateInsertPlayBookMap.keySet());
          
            for(CSM_Playbook__c plb :existingPLBMapTmp.values())
            {
                existingPLBMap.put(plb.CSM_External_Id__c, plb);
            }
            //if any found, update
            for(String plbId :updateInsertPlayBookMap.keySet())
            {
                CSM_Playbook__c playbook;
                if(existingPLBMap.containsKey(plbId))
                {
                    playbook = formPlaybook(existingPLBMap.get(plbId), updateInsertPlayBookMap.get(plbId));
                }
                else
                {
                    playbook = formPlaybook(null, updateInsertPlayBookMap.get(plbId));
                }
                lstPLBUpsert.add(playbook);
            }
        }
        System.debug('VISH lstPLBUpsert - '+lstPLBUpsert);
        if(lstPLBUpsert != null && !lstPLBUpsert.isEmpty())
        {
        	CSM_PlaybooksDataAccess.savePlaybook(lstPLBUpsert);
        }
    
        //HANDLE PLAYS
        Map<String, String> insertedPlays2Playbooks = new Map<String, String>();
        Map<String, CSM_Playbook__c> plays2PlaybooksInserted = new Map<String, CSM_Playbook__c>();
         
        if(updateInsertPlaysMap != null && !updateInsertPlaysMap.isEmpty())
        {
            //Query DB for existing Plays
         
           existingPLMapTmp = CSM_PlaysDataAccess.getPlayMapByExternalId(updateInsertPlaysMap.keySet());
           
           
            //if any found, update
            //else, insert Plays & PlaybookPlays
            for(CSM_Play__c pl :existingPLMapTmp.values())
            {
                existingPLMap.put(pl.CSM_External_Id__c, pl);
            }
            //if any found, update
            for(String plId :updateInsertPlaysMap.keySet())
            {
                CSM_Play__c play;
                if(existingPLMap.containsKey(plId))
                {
                    play = formPlay(existingPLMap.get(plId), updateInsertPlaysMap.get(plId));
                }
                else
                {
                    play = formPlay(null, updateInsertPlaysMap.get(plId));
                    //Eswar Bala: 06-18-2015 - Making the plabook retrieval and map entry common.
                }
                //Eswar Bala: 06-18-2015 - Making the plabook retrieval and map entry common.
               	String plbExt = (updateInsertPlaysMap.get(plId)).CSM_Playbook_External_Id__c;
                insertedPlays2Playbooks.put(plId, plbExt);
                
                lstPLUpsert.add(play);
            }
        }
        
        if(lstPLUpsert != null && !lstPLUpsert.isEmpty())
        {
        	CSM_PlaysDataAccess.savePlays(lstPLUpsert);
        }
    
        //HANDLE PLAYBOOK_PLAYS
        //Get all Plays, ExternalIds, PLBExternalIds from DB that were inserted (based on external Id)
        //Form PlayBookPlays for these
        
        List<CSM_Play__c> lstNewPlays = CSM_PlaysDataAccess.getPlayMapByExternalId(insertedPlays2Playbooks.keySet()).values();
        Map<String, Id> mapNewExternal2PlayId = new Map<String, Id>(); 
        for(CSM_Play__c pl :lstNewPlays)
        {
            mapNewExternal2PlayId.put(pl.CSM_External_Id__c, pl.Id);
        }
        
       
        List<CSM_Playbook__c> lstRelatedPlaybooks = CSM_PlaybooksDataAccess.getPlaybookMapByExtId(new Set<String>(insertedPlays2Playbooks.values())).values();
        Map<String, Id> mapRelatedExternal2PlayBookId = new Map<String, Id>();
        for(CSM_Playbook__c plb :lstRelatedPlaybooks)
        {
            mapRelatedExternal2PlayBookId.put(plb.CSM_External_Id__c, plb.Id);
        }
        
        Set<String> ppKey = new Set<String>();
        for(CSM_PlaybookPlay__C pp: CSM_PlaybookPlayDataAccess.getPlaybookPlayByExternalId(mapRelatedExternal2PlayBookId.keySet(), mapNewExternal2PlayId.keySet())) {
        	ppKey.add(pp.CSM_Playbook__c + '_' + pp.CSM_Play__c);
        }
        System.debug('VVV ppKey - '+ppKey);
        //List<CSM_PlaybookPlay__c> playbookPlays2Upsert = new List<CSM_PlaybookPlay__c>();
        Map<String, CSM_PlaybookPlay__c> mapPlaybookNPlay2PlaybookPlay = new Map<String, CSM_PlaybookPlay__c>(); //Key = (String)PlaybookId+PlayId & value = PlaybookPlay record
        for(String plExt :insertedPlays2Playbooks.keySet())
        {
        	String ppKeyVal = mapRelatedExternal2PlayBookId.get(insertedPlays2Playbooks.get(plExt)) + '_' + mapNewExternal2PlayId.get(plExt);
        	if (!ppKey.contains(ppKeyVal)){
	            CSM_PlaybookPlay__c newPLB_PL = new CSM_PlaybookPlay__c();
	            newPLB_PL.CSM_Play__c = mapNewExternal2PlayId.get(plExt);
	            newPLB_PL.CSM_Playbook__c = mapRelatedExternal2PlayBookId.get(insertedPlays2Playbooks.get(plExt));
	            mapPlaybookNPlay2PlaybookPlay.put(string.valueOf(newPLB_PL.CSM_Playbook__c) + string.valueOf(newPLB_PL.CSM_Play__c), newPLB_PL);
				//playbookPlays2Upsert.add(newPLB_PL);
        	}
        }
        
        if(mapPlaybookNPlay2PlaybookPlay != null && !mapPlaybookNPlay2PlaybookPlay.isEmpty())
        {
        	System.debug('mapPlaybookNPlay2PlaybookPlay - '+mapPlaybookNPlay2PlaybookPlay);
            CSM_PlaybookPlayDataAccess.upsertPlaybookPlay(mapPlaybookNPlay2PlaybookPlay.values());
        }
        
    }
    
     private static void processPlayResult(Map<Id, CSM_Account_Plan__c> accountPlanMap, Map<Id, CSM_Play_Result__c> playResultsMap, 
                            Map<String, CSM_Play_Result__c> accountPlayResult, Set<Id> pendingPlayResult, Set<Id> attainedPlayResult, 
                            Set<Id> haltedPlayResult, Map<String, Set<String>> pendingResultPlayMap, Set<String> attainedResultPlaySet, Set<String> haltedResultPlaySet, 
                            Map<Id, CSM_Account_Plan__c> appMap) 
    {       
        if (accountPlanMap!=null && !accountPlanMap.isEmpty())
        {
            
            Map<String, String> playbookExternalIds = new Map<String, String>();
            Map<String, String> playbookExtIdMap = new Map<String, String>();
            for(CSM_Play_Result__c pr :playResultsMap.values())
            {                                       
                if(pr.CSM_Account_Id__c != null)
                {
                    playbookExternalIds.put(pr.CSM_Playbook_External_Id__c+':'+pr.CSM_Account_Id__c, pr.CSM_Account_Id__c); 
                    playbookExtIdMap.put(pr.CSM_Playbook_External_Id__c, pr.CSM_Account_Id__c);
                }   
            }
            Map<String, String> playbookForExternalIds = new Map<String, String>();
            List<CSM_PlayBook__c> listOfPlaybooks = CSM_PlaybooksDataAccess.getPlaybooksByExtId(playbookExtIdMap);
            //Processing PlayResult Object to create/update playbooks
            for (CSM_Playbook__c playbook : listOfPlaybooks) {
                playbookForExternalIds.put(playbook.CSM_External_Id__c, playbook.Id);
            }
            
            CSM_AccountPlanPlaybookDataAccess.createAccountPlanPlaybook(listOfPlaybooks, playbookForExternalIds, accountPlanMap, appMap, playbookExternalIds);
            
            
            //get the automated accountplan playbooks
            
            List<CSM_Account_Plan_Playbook__c> automatedAccountPlanPlaybooks = CSM_AccountPlanPlaybookDataAccess.getAutomatedAccountPlanPlaybooks(accountPlayResult.KeySet(), playResultsMap, accountPlanMap.values());

            system.debug('automatedAccountPlanPlaybooks::' + automatedAccountPlanPlaybooks);
            if (automatedAccountPlanPlaybooks!=null && !automatedAccountPlanPlaybooks.isEmpty()) {
                Map<String, String> pendingPlayBookMap = new Map<String, String>();
                Map<String, String> attainedPlayBookMap = new Map<String, String>();
                Map<String, String> haltedPlayBookMap = new Map<String, String>();
                Map<String, String> errorAccount = new Map<String, String>();
                Map<String, CSM_Play_Result__c> accountPlayResultPending = new Map<String, CSM_Play_Result__c>();
                Map<String, CSM_Play_Result__c> accountPlayResultAttained = new Map<String, CSM_Play_Result__c>();
                Map<String, CSM_Play_Result__c> accountPlayResultHalted = new Map<String, CSM_Play_Result__c>();
                
                System.debug('Main Play Result - '+accountPlayResult);
	            Set<String> setPlaybookIds = new Set<String>();
	            
	            //Eswar Bala - 11/10/2015 - removing query from loop
	            //get the playbookplays associated with these playbooks
	            for (CSM_Account_Plan_Playbook__c app : automatedAccountPlanPlaybooks) {
                	
                	//get the playbookplays associated with this playbook
                	setPlaybookIds.add(String.valueOf(app.CSM_Playbook__c));
	            }
	            List<CSM_PlaybookPlay__c> playbookPlays = CSM_PlaysDataAccess.getActiveAutomatedPlays(setPlaybookIds);
	            
            	//get the plays from playbookplays which have the externalId present and matches the ones in playResultsMap 
            	if (playbookPlays != null && playbookPlays.size() > 0) {
                	for (CSM_PlaybookPlay__c pbPlay : playbookPlays) {
                		
                		//iterate through the playResultsMap values(containing Play Results) 
			            for(CSM_Play_Result__c pr :playResultsMap.values()) {
			            	                                       
			                if(pr.CSM_Account_Id__c != null && pr.CSM_Play_External_Id__c != null && pr.CSM_Playbook_External_Id__c != null 
			                	&& pbPlay.CSM_Play__c != null && pbPlay.CSM_Play__r.CSM_External_Id__c != null
			                	&& pbPlay.CSM_Playbook__c != null && pbPlay.CSM_Playbook__r.CSM_External_Id__c != null) {
								if (String.valueOf(pr.CSM_Playbook_External_Id__c) == String.valueOf(pbPlay.CSM_Playbook__r.CSM_External_Id__c) &&
									String.valueOf(pr.CSM_Play_External_Id__c) == String.valueOf(pbPlay.CSM_Play__r.CSM_External_Id__c)) {
									if (pr.CSM_Resolution_Status__c != null && pr.CSM_Resolution_Status__c.toLowerCase()  == CSM_Constants.INT_PLAYRESULT_PENDING.toLowerCase()) {
                    					accountPlayResultPending.put(pr.CSM_Account_Id__c + ':' + pbPlay.CSM_Playbook__c + ':'+ pbPlay.CSM_Play__c, pr);           	
									}
									if (pr.CSM_Resolution_Status__c != null && pr.CSM_Resolution_Status__c.toLowerCase()  == CSM_Constants.INT_PLAYRESULT_ATTAINED.toLowerCase()) {
                    					accountPlayResultAttained.put(pr.CSM_Account_Id__c + ':' + pbPlay.CSM_Playbook__c + ':'+ pbPlay.CSM_Play__c, pr);           	
									}
									if (pr.CSM_Resolution_Status__c != null && pr.CSM_Resolution_Status__c.toLowerCase()  == CSM_Constants.INT_PLAYRESULT_HALTED.toLowerCase()) {
                    					accountPlayResultHalted.put(pr.CSM_Account_Id__c + ':' + pbPlay.CSM_Playbook__c + ':'+ pbPlay.CSM_Play__c, pr);           	
									} 										 										 
								}
			                }   
			            }
                	}               	
            	}
                
                /*for (CSM_Account_Plan_Playbook__c app : automatedAccountPlanPlaybooks) {
                    if (pendingPlayResult.contains(app.CSM_Account_Plan__r.CSM_AccountId__c)){
                    	system.debug('enter pendingPlayResult::' + pendingPlayResult);
                        pendingPlayBookMap.put(app.CSM_Playbook__c + ':'+app.CSM_Account_Plan__r.CSM_AccountId__c, app.CSM_Account_Plan__r.CSM_AccountId__c);
                        if (accountPlayResult.containsKey(String.valueOf(app.CSM_Account_Plan__r.CSM_AccountId__c).subString(0, 15))){
                        	accountPlayResultPending.put(app.CSM_Account_Plan__r.CSM_AccountId__c, accountPlayResult.get(String.valueOf(app.CSM_Account_Plan__r.CSM_AccountId__c).subString(0, 15)));           	
                        }
                        if (accountPlayResult.containsKey(app.CSM_Account_Plan__r.CSM_AccountId__c)){
                        	accountPlayResultPending.put(app.CSM_Account_Plan__r.CSM_AccountId__c, accountPlayResult.get(app.CSM_Account_Plan__r.CSM_AccountId__c));
                        }
                        system.debug('pendingPlayBookMap::' + pendingPlayBookMap);
                        system.debug('accountPlayResultPending::' + accountPlayResultPending);
                    }
                    if (attainedPlayResult.contains(app.CSM_Account_Plan__r.CSM_AccountId__c)){
                        attainedPlayBookMap.put(app.CSM_Playbook__c + ':'+app.CSM_Account_Plan__r.CSM_AccountId__c, app.CSM_Account_Plan__r.CSM_AccountId__c);
                        if (accountPlayResult.containsKey(String.valueOf(app.CSM_Account_Plan__r.CSM_AccountId__c).subString(0, 15))){
                        	accountPlayResultAttained.put(app.CSM_Account_Plan__r.CSM_AccountId__c, accountPlayResult.get(String.valueOf(app.CSM_Account_Plan__r.CSM_AccountId__c).subString(0, 15)));
                        }
                        if (accountPlayResult.containsKey(app.CSM_Account_Plan__r.CSM_AccountId__c)){
                        	accountPlayResultAttained.put(app.CSM_Account_Plan__r.CSM_AccountId__c, accountPlayResult.get(app.CSM_Account_Plan__r.CSM_AccountId__c));
                        }
                    }
                    if (haltedPlayResult.contains(app.CSM_Account_Plan__r.CSM_AccountId__c)){
                        haltedPlayBookMap.put(app.CSM_Playbook__c + ':'+app.CSM_Account_Plan__r.CSM_AccountId__c, app.CSM_Account_Plan__r.CSM_AccountId__c);
                        if (accountPlayResult.containsKey(String.valueOf(app.CSM_Account_Plan__r.CSM_AccountId__c).subString(0, 15))){
                        	accountPlayResultHalted.put(app.CSM_Account_Plan__r.CSM_AccountId__c, accountPlayResult.get(String.valueOf(app.CSM_Account_Plan__r.CSM_AccountId__c).subString(0, 15)));
                        }
                        if (accountPlayResult.containsKey(app.CSM_Account_Plan__r.CSM_AccountId__c)){
                        	accountPlayResultHalted.put(app.CSM_Account_Plan__r.CSM_AccountId__c, accountPlayResult.get(app.CSM_Account_Plan__r.CSM_AccountId__c));
                        }
                    }
                }*/
                System.debug('KKK accountPlayResultPending - '+accountPlayResultPending);
                processPendingPlayBooks(accountPlanMap, accountPlayResultPending, pendingPlayBookMap, pendingResultPlayMap, appMap);
                
                processAttainedPlayBooks(accountPlanMap, accountPlayResultAttained, attainedPlayBookMap, attainedResultPlaySet);
                
                processHaltedPlayBooks(accountPlanMap, accountPlayResultHalted, haltedPlayBookMap, haltedResultPlaySet);
                
            }

        }   
    }
    
     private static CSM_Playbook__c formPlaybook(CSM_Playbook__c existingPLB, CSM_Play_Result__c pr)
    {
        CSM_Playbook__c returnedPlb = new CSM_Playbook__c();    
        if(existingPLB != null)
        {
            returnedPlb = existingPLB;
        }
        else
        {
            returnedPlb.CSM_Automated__c = true;
            returnedPlb.CSM_IsActive__c = false;
        }
        returnedPlb.CSM_External_Id__c = pr.CSM_Playbook_External_Id__c;
        
        if(pr.CSM_Playbook_Name__c != null && pr.CSM_Playbook_Name__c.trim() != '')
        {
            if((pr.CSM_Playbook_Name__c).length() > 40)
            {
                returnedPlb.CSM_Display_Name__c = (pr.CSM_Playbook_Name__c).substring(0,39);
            }
            else
            {
                returnedPlb.CSM_Display_Name__c = pr.CSM_Playbook_Name__c;
            }
        }
        returnedPlb.CSM_Long_Description__c = pr.CSM_Playbook_Description__c;
    
        return returnedPlb;
    }
    
     private static CSM_Play__c formPlay(CSM_Play__c existingPL, CSM_Play_Result__c pr)
    {
        CSM_Play__c returnedPl = new CSM_Play__c(); 
        if(existingPL != null)
        {
            returnedPl = existingPL;
        }
        else
        {
            returnedPl.CSM_Automated__c = true;
            returnedPl.CSM_IsActive__c = false;
            returnedPl.CSM_Auto_Complete_Automated_Tasks__c = true;
            returnedPl.CSM_Auto_Dismiss_Automated_Tasks__c = true;
            returnedPl.CSM_External_Id__c = pr.CSM_Play_External_Id__c;
            returnedPl.CSM_Object_Name__c = CSM_Constants.OBJ_TYPE_ACCOUNT;
        }
    
    	//Fix: US675: Ignore the inbound Scout Play Description - commenting the following line 
        //returnedPl.CSM_Play_Description__c = pr.CSM_Play_Description__c;
        returnedPl.CSM_External_Id__c = pr.CSM_Play_External_Id__c;
        if(pr.CSM_Play_Name__c != null && pr.CSM_Play_Name__c.trim() != '')
        {
            if((pr.CSM_Play_Name__c).length() > 40)
            {
                returnedPl.CSM_Display_Name__c = (pr.CSM_Play_Name__c).substring(0,39);
            }
            else
            {
                returnedPl.CSM_Display_Name__c = pr.CSM_Play_Name__c;
            }
        }
        return returnedPl;
    }
    
    private static void processPendingPlayBooks(Map<Id, CSM_Account_Plan__c> accountPlanMap, Map<String, CSM_Play_Result__c> accountPlayResult,
                                         Map<String, String> pendingPlayBookMap, Map<String, Set<String>> pendingResultPlayMap, Map<Id, CSM_Account_Plan__c> appMap) {                      
        
        if (accountPlayResult!=null && !accountPlayResult.isEmpty())
        {
            try
            {
                Map<String, CSM_TaskWrapper> taskPendingMap = new Map<String, CSM_TaskWrapper>();
                List<CSM_Play_Task__c> playtaskPendingList = new List<CSM_Play_Task__c>();
                Set<String> currentAcPlays = new Set<String>();
                //Eswar Bala/Vishal: Fix for Too many SOQL queries
                for(String acctId :pendingResultPlayMap.keySet())
                {
                    currentAcPlays.addAll(pendingResultPlayMap.get(acctId)); 
                }
                List<CSM_Play_Task__c> acctTasks = new List<CSM_Play_Task__c>(); 
                if(currentAcPlays != null && !currentAcPlays.isEmpty())
                {
                    acctTasks = CSM_PlayTaskDataAccess.getActiveAutomatedTasks(currentAcPlays);
                }
                
                if(acctTasks != null && !acctTasks.isEmpty())
                {
                    playtaskPendingList.addAll(acctTasks);
                }                
                
                Set<String> taskProcessingSet = new Set<String>();
                Set<String> existingPRIdSet = new Set<String>();
                
                //get the acctKeySet, parse and get the accountIds from it.
                Set<String> acctKeySet = getAcctKeySetFromAccountPR(accountPlayResult);
                
                system.debug('acctKeySet::' + acctKeySet);
                                
                for (CSM_Task_Processing__c tp : CSM_TaskProcessingDataAccess.getTasksById(playtaskPendingList, acctKeySet))  
                {
                    //Eswar Bala - 10/07/2014 - Set now includes combo of PlayId & SuccessPlanId
                    taskProcessingSet.add(String.valueOf(tp.CSM_Play__c) + ':' + String.valueOf(tp.CSM_Success_Plan__c));
                    existingPRIdSet.add(tp.CSM_Play_Result_Id__c);
                }

                //Eswar Bala - 10/07/2014
                Map<String, List<CSM_Play_Task__c>> playTaskPendingMap = new Map<String, List<CSM_Play_Task__c>>(); 
                for(CSM_Play_Task__c pt :playtaskPendingList)
                {
                    List<CSM_Play_Task__c> tempPlTasks = playTaskPendingMap.get(pt.CSM_Play__r.CSM_External_Id__c);
                    if(tempPlTasks == null)
                    {
                        tempPlTasks = new List<CSM_Play_Task__c>();
                    }
                    tempPlTasks.add(pt);
                    playTaskPendingMap.put(pt.CSM_Play__r.CSM_External_Id__c, tempPlTasks);
                }
                
                if (playTaskPendingList != null)
                {
                    for(String acctId :pendingResultPlayMap.keySet())
                    {
                        Set<String> currentAcctPlays = pendingResultPlayMap.get(acctId);
                        
                        for(String playExtId :currentAcctPlays)
                        {                            
                            List<CSM_Play_Task__c> ptLst = playTaskPendingMap.get(playExtId);
                            
                            if (ptLst != null) {
	                            for(CSM_Play_Task__c pt :ptLst) {
	                            	
	                                //Eswar Bala - 10/07/2014 - Check now includes combo of PlayId & SuccessPlanId
	                                String uniqueTaskProcessingId = String.valueOf(pt.CSM_Play__c) +  ':' + String.valueOf(accountPlanMap.get(acctId).Id);
	                                
                                    CSM_TaskWrapper tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(false, pt, accountPlanMap, acctId);	
                                                                        
                                    if (tw.AccountId != null)
                                    {                                        
                                        //CSM_Play_Result__c currentPR = accountPlayResult.get(tw.AccountId);
                                        //find the currentPR based on pt.CSM_Play__c and tw.PlayId
                                        CSM_Play_Result__c currentPR = retrieveCurrentPlayResult(accountPlayResult, tw.PlayId);

                                        System.debug('currentPR - '+currentPR);
                                        if(currentPR != null && (!taskProcessingSet.contains(uniqueTaskProcessingId) || 
                                        	!existingPRIdSet.contains(currentPR.CSM_Play_Result_Id__c)))
                                		{
                                            tw.playEnterDate = currentPR.CSM_Enter_Date__c;
				                            tw.processingStatus = currentPR.CSM_Resolution_Status__c;
				                          	tw.playResultId = currentPR.CSM_Play_Result_Id__c;
		                                    taskPendingMap.put(tw.AccountId + ':' + tw.PlayId + ':' + pt.id, tw);
                                    	}
                                    	System.debug('taskPendingMap - '+taskPendingMap);
                                	}	
	                            }
	                        }
                        }
                    }                    
                    if (taskPendingMap!=null && !taskPendingMap.isEmpty()){                    	
                        CSM_TaskDataAccess.createUpdateTaskListFromWrapper(taskPendingMap.values(), accountPlayResult);
                    }
                }   
            }
            catch(Exception ex)
            {
                
            }
        }       
    }
    
    
    private static void processAttainedPlayBooks(Map<Id, CSM_Account_Plan__c> accountPlanMap, Map<String, CSM_Play_Result__c> accountPlayResult, Map<String, String> attainedPlayBookMap, Set<String> attainedResultPlaySet)
    {
				        
        if (accountPlayResult!=null && !accountPlayResult.isEmpty()) 
        {
            try
            {
                Map<Id, CSM_TaskWrapper> taskAttainedMap = new Map<Id, CSM_TaskWrapper>();
                    
                //get PlayTasks for the 
                List<CSM_Play_Task__c> playTaskAttainedList = CSM_PlayTaskDataAccess.getActiveAutomatedTasks(attainedResultPlaySet);
                System.debug('playTaskAttainedList - '+playTaskAttainedList);
                Map<Id, CSM_Play_Task__c> playTaskMap = new Map<Id, CSM_Play_Task__c>();
                for(CSM_Play_Task__c pt :playTaskAttainedList)
                {
                    playTaskMap.put(pt.Id, pt);
                }
                System.debug('accountPlayResult.keySet() - '+accountPlayResult.keySet());
				System.debug('playTaskMap - '+playTaskMap);
				
                //get the acctKeySet, parse and get the accountIds from it.
                
                Set<String> acctKeySet = getAcctKeySetFromAccountPR(accountPlayResult);
                
                system.debug('AttainedacctKeySet::' + acctKeySet);				                
                
                Map<Id, CSM_Task_Processing__c> taskProcessingMap = new Map<Id, CSM_Task_Processing__c>(CSM_TaskProcessingDataAccess.getTasksById(playTaskAttainedList, acctKeySet));                
                
                //Eswar Bala
                Map<Id, Id> taskProcessingId2TaskId = new Map<Id, Id>();
                for(CSM_Task_Processing__c tp :taskProcessingMap.values())
                {
                    taskProcessingId2TaskId.put(tp.Id, tp.CSM_Task_Id__c);
                }
                
                for(Id tpId :taskProcessingMap.keySet())
                {
                    CSM_Task_Processing__c currentTaskProc = taskProcessingMap.get(tpId);
                    Id relatedPTId = currentTaskProc.CSM_PlayTask__r.Id;
                    CSM_Play_Task__c relatedPT = playTaskMap.get(relatedPTId);
                            
                    if(relatedPT.CSM_Play__r.CSM_Auto_Complete_Automated_Tasks__c == true && relatedPT.CSM_Play__r.CSM_IsActive__c == true)
                    {
                        CSM_TaskWrapper tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(true, relatedPT, accountPlanMap, currentTaskProc.CSM_Success_Plan__r.CSM_AccountId__c);
                        CSM_Play_Result__c currentAttainedPR;			                
                        
                        if(tw.AccountId != null)
                        {
                            currentAttainedPR = retrieveCurrentPlayResult(accountPlayResult, tw.PlayId);

                            if(currentAttainedPR != null)
                            {
                                tw.playExitDate = currentAttainedPR.CSM_Exit_Date__c;
                            }
                        }
                        system.debug('currentAttainedPR - '+currentAttainedPR);

                        if(currentAttainedPR != null)
                        {
                            tw.processingStatus = currentAttainedPR.CSM_Resolution_Status__c;
                            tw.playResultId = currentAttainedPR.CSM_Play_Result_Id__c;
                        }
                        taskAttainedMap.put(taskProcessingId2TaskId.get(tpId), tw);
                        
                    }
                }
                system.debug('taskAttainedMap$$$' + taskAttainedMap);
                if (!taskAttainedMap.isEmpty())
                {
                    CSM_TaskDataAccess tda = new CSM_TaskDataAccess();
                    tda.completeDismissTasks(taskAttainedMap);
                }
            }
            catch(Exception ex)
            {
                
            }
        }
    }
    
    private static void processHaltedPlayBooks(Map<Id, CSM_Account_Plan__c> accountPlanMap, Map<String, CSM_Play_Result__c> accountPlayResult, Map<String, String> haltedPlayBookMap, Set<String> haltedResultPlaySet)
    {
        
        if (accountPlayResult!=null && !accountPlayResult.isEmpty()) 
        {
            try
            {
                Map<Id, CSM_TaskWrapper> taskHaltedMap = new Map<Id, CSM_TaskWrapper>();
                
                //get PlayTasks for the 
                List<CSM_Play_Task__c> playTaskHaltedList = CSM_PlayTaskDataAccess.getActiveAutomatedTasks(haltedResultPlaySet);
                Map<Id, CSM_Play_Task__c> playTaskMap = new Map<Id, CSM_Play_Task__c>();
                for(CSM_Play_Task__c pt :playTaskHaltedList)
                {
                    playTaskMap.put(pt.Id, pt);
                }

                //get the acctKeySet, parse and get the accountIds from it.
                
                Set<String> acctKeySet = getAcctKeySetFromAccountPR(accountPlayResult); 
                system.debug('AttainedacctKeySet::' + acctKeySet);
                                
                Map<Id, CSM_Task_Processing__c> taskProcessingMap = new Map<Id, CSM_Task_Processing__c>(CSM_TaskProcessingDataAccess.getTasksById(playTaskHaltedList, acctKeySet));
                
                //Eswar Bala
                Map<Id, Id> taskProcessingId2TaskId = new Map<Id, Id>();
                for(CSM_Task_Processing__c tp :taskProcessingMap.values())
                {
                    taskProcessingId2TaskId.put(tp.Id, tp.CSM_Task_Id__c);
                }

                for(Id tpId :taskProcessingMap.keySet())
                {
                    CSM_Task_Processing__c currentTaskProc = taskProcessingMap.get(tpId);
                    Id relatedPTId = currentTaskProc.CSM_PlayTask__r.Id;
                    CSM_Play_Task__c relatedPT = playTaskMap.get(relatedPTId);
                    if(relatedPT.CSM_Play__r.CSM_Auto_Complete_Automated_Tasks__c == true && relatedPT.CSM_Play__r.CSM_IsActive__c == true)
                    {
                        {
                            CSM_TaskWrapper tw = CSM_TaskCreationTriggerUtil.getTaskWrapper(true, relatedPT, accountPlanMap, currentTaskProc.CSM_Success_Plan__r.CSM_AccountId__c);
                            CSM_Play_Result__c currentHaltedPR;
                            String acctIdTmp;
                            if (tw.AccountId != null)
                            {
                            	currentHaltedPR = retrieveCurrentPlayResult(accountPlayResult, tw.PlayId);
                                
                                if(currentHaltedPR != null)
                                {
                                    tw.playExitDate = currentHaltedPR.CSM_Exit_Date__c;
                                }
                            }
	                        system.debug('currentHaltedPR - '+currentHaltedPR);
	
                            if(currentHaltedPR != null)
                            {
                                tw.processingStatus = currentHaltedPR.CSM_Resolution_Status__c;
                                tw.playResultId = currentHaltedPR.CSM_Play_Result_Id__c;
                            }
                            taskHaltedMap.put(taskProcessingId2TaskId.get(tpId), tw);
                        }
                    }
                }
                System.debug('taskHaltedMap - '+taskHaltedMap);
                if (!taskHaltedMap.isEmpty())
                {
                    CSM_TaskDataAccess tda = new CSM_TaskDataAccess();
                    tda.completeDismissTasks(taskHaltedMap);
                }
            }
            catch(Exception ex)
            {
                
            }
        }
    }
    
    private static Set<String> getAcctKeySetFromAccountPR(Map<String, CSM_Play_Result__c> accountPlayResult) {
		
        Set<String> tempAcctKeySet = accountPlayResult.keySet();
        Set<String> acctKeySet = new Set<String>();
        
        if (tempAcctKeySet != null) {
            for (String s: tempAcctKeySet) {
				Integer iend = s.indexOf(':'); 
				if (iend != -1) {
					String tempStr = s.substring(0 , iend); 
					acctKeySet.add(tempStr);
				}
            }
        }
        return acctKeySet;		
	}  
	
	  private static CSM_Play_Result__c retrieveCurrentPlayResult(Map<String, CSM_Play_Result__c> accountPlayResult, String playId) {
    	CSM_Play_Result__c currPlayResult = new CSM_Play_Result__c();
    	
    	//iterate through the playresult keys and find the matching key, that contains the playId
    	for(String prKey :accountPlayResult.keySet()) {
    		system.debug('prKey::' + prKey);
    		Integer iLast = prKey.lastIndexOf(':'); 
    		String playIdFromPRKey = '';
    		if (iLast != -1) {
    			playIdFromPRKey = prKey.substring(iLast+1);     			
    		}
    		if (String.isNotBlank(playIdFromPRKey) && playId.equals(playIdFromPRKey)) {
    			currPlayResult = accountPlayResult.get(prKey);
    			return currPlayResult;
    		}   		
    	}
    	
    	return null;   	
    }   
}