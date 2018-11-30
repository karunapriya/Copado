public with sharing class REN_OpptSplitCompController{
	public List<OpportunityLineItem> lstAllOpptLines;
	public list<REN_OpptLineWrapper> lstAllOpptLinesW;
    public List<List<REN_OpptLineWrapper>> lstofLstAllOpptLinesW{get; set;}
	public list<OpportunityLineItem> lstSelectedOpptLines{get; set;}
	public String selectedOpptType {get; set;}
	public Boolean showOpptPicker {get; set;}
	public Boolean showAsInput {get; set;}
	public Boolean showTarget {get; set;}
	public OpportunityLineItem opLn {get; set;}
	public String opportunityId4Split{get; set;}
	public String oppLinesStr{get; set;}
	
	public String rrIdsStr{get; set;}
	public Set<String> selectedIdSetForRR = new Set<String>();
	public List<REN_Renews_To__c> selectedRRList{get; set;}
	Public List<List<RRWrapper>> rrWrapperListofList {get; set;}
	public List<Schema.FieldSetMember> oliFieldSetMemberList{get; set;}
	public List<Schema.FieldSetMember> rrFieldSetMemberList{get; set;}
	
	
	public Id targetOpptId;
	public Opportunity targetOppt{get; set;}
	public set<Id> setPreselectedOl = new set<Id>();
	public list<String> lstPreselectedOl = new list<String>();
	
	public Opportunity currentOpptDisplayed {get; set;}
	public List<Opportunity> opportunityDetails{get; set;}
	
	public string recordCurrencyCode{get;set;} // created for US454
	
	public String isConsolidatedRR {get; set;}  // created for us976
	public boolean isQuoteEnabled {get; set;}  // created for us976
	public String isValidRli {get; set;}
	public boolean hasSyncedPO {get;set;}
	
    private Set<String> oliDefaultFieldsSet;
    private Set<String> oliFieldsSetForQuery;

    private Set<String> rrDefaultFieldsSet;
    private Set<String> rrFieldsSetForQuery;
    public Boolean isRliLimitExceeded {get;set;}
    
    //US3640
    public Decimal splitCounter;
    public String oppNameStr;
    public boolean isOppSplitCounter;
    public boolean isOppNameExceedChar;

	public boolean isValidData {
		get{
			return !(
				(String.isNotBlank(rrIdsStr) || String.isNotBlank(isConsolidatedRR)) 
			);
		} 
		set;
	}
	public boolean isQuoteEnabledOnTargetOpp {
		get{
			return (
			(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId') && currentOpptDisplayed.get('SyncedQuoteId') != null 
			&& (
				( (String.isNotBlank(isValidRli) && isValidRli.equalsIgnoreCase('true'))  ) 
				|| String.isNotBlank(isConsolidatedRR ) || String.valueOf(SS_Constants.isSimplifiedDataModelEnabled).equalsIgnoreCase('true'))
			   )
			);
		} 
	}
	
	public REN_OpptSplitCompController(){
	    splitCounter = 0;
	    oppNameStr= '';
		system.debug('isValidRli-->'+isValidRli);
		opln = new OpportunityLineItem();
		lstofLstAllOpptLinesW = new List<List<REN_OpptLineWrapper>>();
		rrWrapperListofList = new List<List<RRWrapper>>();
        targetOppt = new Opportunity();
        currentOpptDisplayed = new Opportunity();
        showOpptPicker = false;
        showAsInput = true;
        showTarget = false;
        // isQuoteEnabledOnTargetOpp=false;
        isQuoteEnabled = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId');
        rrFieldSetMemberList =  SObjectType.REN_Renews_To__c.FieldSets.REN_Renewal_Line_Items_on_Split.getFields();  
        oliFieldSetMemberList =  SObjectType.OpportunityLineItem.FieldSets.REN_Product_Line_Items_on_Split.getFields();  

        oliDefaultFieldsSet = new Set<String>();
        oliFieldsSetForQuery = REN_Util.getFieldNameSetFromFieldSet(oliFieldSetMemberList, oliDefaultFieldsSet);

        rrDefaultFieldsSet = new Set<String>{'Name', 'REN_Renews_To__c', 'REN_Product__c', 'REN_Start_Date__c', 'REN_End_Date__c', 'REN_Previous_Price__c', 'REN_Renewal_Target__c', 'REN_Quantity__c', 'REN_Asset__c', 'REN_Renewal_Status__c', 'REN_Source_Opportunity__c', 'REN_Previous_Opportunity__c'};
        rrFieldsSetForQuery = REN_Util.getFieldNameSetFromFieldSet(rrFieldSetMemberList, rrDefaultFieldsSet);
        isOppSplitCounter = CSM_Admin__c.getOrgDefaults().REN_Opp_Split_Counter_Feature__c;
        
	}

	
	public List<SelectOption> getOpptTypes(){
		// VCP - LABEL
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('none', Label.CSM_VAL_NONE));
        options.add(new SelectOption('new', Label.CSM_LBL_NEW_OPPORTUNITY));
        options.add(new SelectOption('clone', Label.REN_LBL_NEW_CLONED_OPPTY));
        options.add(new SelectOption('existing', Label.REN_LBL_EXISTING_OPPORTUNITY));	
        return options;
    }
    
    public PageReference processOpptTypeChange(){
    	try{
            lstAllOpptLinesW = new list<REN_OpptLineWrapper>();
            system.debug('Executing change. selectedOpptType : ' + selectedOpptType);
            system.debug('opportunityId4Split : ' + opportunityId4Split);
            opportunityDetails = CSM_OpportunityDataAccess.getDetailFieldSetById(opportunityId4Split);
            system.debug('opportunityDetails : ' + opportunityDetails);
            //US3640
            isOppNameExceedChar = false;
            if(isOppSplitCounter && selectedOpptType != 'existing'){
	            splitCounter = (opportunityDetails[0].REN_Split_Counter__c == null ? 0 : opportunityDetails[0].REN_Split_Counter__c);
	            splitCounter = splitCounter + 1;
	            oppNameStr = String.format(Label.REN_LBL_APPEND_SPLIT_OPP_NAME, new List<String>{opportunityDetails[0].name,String.valueOf(splitCounter)});
        		if(oppNameStr.length() > 120 ){
        			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,Label.REN_LBL_OPP_NAME_EXCEED_WARNING));
        		    isOppNameExceedChar = true;
        		}
            }
            hasSyncedPO = false;
            if(selectedOpptType == 'existing'){
                showAsInput = false;
                showOpptPicker = true;
                showTarget = false;
                if(opLn.OpportunityId != null && targetOppt != null){
                    showTarget = true;
                }
            } else if(selectedOpptType == 'new'){	
            	rrWrapperListofList = new List<List<RRWrapper>>();
            	lstofLstAllOpptLinesW = new List<List<REN_OpptLineWrapper>>();
                opLn.OpportunityId = null;
                showAsInput = true;
                showOpptPicker = false;
                showTarget = true;
                getAllOpptLines(opportunityId4Split);
                getAllRecordsFromRR(opportunityId4Split);
            } else if(selectedOpptType == 'clone'){	
            	rrWrapperListofList = new List<List<RRWrapper>>();
            	lstofLstAllOpptLinesW = new List<List<REN_OpptLineWrapper>>();
                opLn.OpportunityId = null;
                showAsInput = true;
                showOpptPicker = false;
                showTarget = true;
                getAllOpptLines(opportunityId4Split);
                getAllRecordsFromRR(opportunityId4Split);
            } else if(selectedOpptType == 'none'){
                opLn.OpportunityId = null;
                showAsInput = false;
                showOpptPicker = false;
                showTarget = false;
            }
            currentOpptDisplayed = returnTargetOpportunity(selectedOpptType);
            //Below code is added for US454		
            if(selectedOpptType != 'none')	{
                SObject thisOpty = opportunityDetails[0];
                recordCurrencyCode = CSM_Util.getRecordLevelCurrency(thisOpty,false);
                if(String.isEmpty(recordCurrencyCode)){
                    recordCurrencyCode = '$';
                }
            }
            //US3460
            if(isOppSplitCounter){
            	if(selectedOpptType == 'clone' || selectedOpptType == 'new'){
            		currentOpptDisplayed.name = String.format(Label.REN_LBL_APPEND_SPLIT_OPP_NAME, new List<String>{opportunityDetails[0].name,String.valueOf(splitCounter)});
            	}
            }
            Integer recordCount = 0;
            List<REN_OpptLineWrapper> tempOpptLineWrpList = new List<REN_OpptLineWrapper>();
            //US3469 Support more than 1000 OLI
            for(REN_OpptLineWrapper opptLineObj : lstAllOpptLinesW){
                if(tempOpptLineWrpList.size() == 1000){
                    lstofLstAllOpptLinesW.add(tempOpptLineWrpList);
                    tempOpptLineWrpList = new List<REN_OpptLineWrapper>();
                    recordCount = 0;
                }
                tempOpptLineWrpList.add(opptLineObj);
                recordCount++;
            }
            if(!tempOpptLineWrpList.isEmpty()){
                lstofLstAllOpptLinesW.add(tempOpptLineWrpList);
            	tempOpptLineWrpList = null;
            }
           
    	}catch(Exception e){
    		system.debug('\n\n~~~~Error:' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    	}
    	return null;
    }
    
    public PageReference opportunityPicked(){
    	try{
	    	SS_Validations__c ssValidationsGlobal = SS_Validations__c.getOrgDefaults();
	    	lstAllOpptLinesW = new list<REN_OpptLineWrapper>();
			set<String> setFieldsRequested = REN_OpportunityDataAccess.getFieldsByFieldSet('Opportunity Split Edit');
			setFieldsRequested.addAll(REN_OpportunityDataAccess.getFieldsByFieldSet('Opportunity Read Only'));
			if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId')){
				setFieldsRequested.add('SyncedQuoteId');
			}
			setFieldsRequested.add('Probability');
			setFieldsRequested.add('CHL_QuoteSyncStatus__c');
			setFieldsRequested.add('REN_Renewal_Metrics_Status__c');
		    setFieldsRequested.add('REN_Split_Counter__c');
			targetOppt = REN_OpportunityDataAccess.getOpportunityById(String.valueOf(opLn.OpportunityId), setFieldsRequested);
			list<CHL_Partner_Opportunity__c> poList = CHL_PartnerOpportunityDataAccess.getPartnerOptyByOpportunity (new set<Id>{targetOppt.id});
	        hasSyncedPO = poList != null && !poList.isEmpty() ? true : false; 
			system.debug('Picked oppt : ' + opLn);
			showTarget = true;
			getAllOpptLines(opportunityId4Split);
			getAllRecordsFromRR(opportunityId4Split);
	    	currentOpptDisplayed = targetOppt;
	    	//todo: 
	    	if(currentOpptDisplayed != null && currentOpptDisplayed.Pricebook2Id != null){
		    	if(opportunityDetails[0].Id==targetOppt.Id){
		    		if(String.isNotBlank(isConsolidatedRR)){
		    			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
				    	Label.REN_MSG_PREVENT_SAME_SOURCE_TARGET_CONSOLIDATE));
		    		} else if(String.isNotBlank(rrIdsStr)){
		    			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
				    	Label.REN_MSG_PREVENT_SAME_SOURCE_TARGET_SPLIT));
		    		}
				    showTarget = false;
		    	} else if(opportunityDetails[0].Pricebook2Id != targetOppt.Pricebook2Id){
		    		ApexPages.Message pricebookMismatchErrMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.REN_MSG_MATCHING_PRICEBOOKS);
	            	ApexPages.addMessage(pricebookMismatchErrMsg);
	            	showTarget = false;
		    	} //Below condition is added as part of US455
		    	else if(UserInfo.isMultiCurrencyOrganization() && (String)opportunityDetails[0].get(REN_Constants.REN_CURRENCY_ISO_CODE) != (String)targetOppt.get(REN_Constants.REN_CURRENCY_ISO_CODE))	{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.REN_LBL_CURRENCY_ERROR_MSG));
					showTarget = false;
				} else if((targetOppt.CHL_QuoteSyncStatus__c != null && targetOppt.CHL_QuoteSyncStatus__c != 'None') 
					|| (targetOppt.REN_Renewal_Metrics_Status__c != null && targetOppt.REN_Renewal_Metrics_Status__c != 'Calculated') ){
					if(String.isNotBlank(isConsolidatedRR)){
        				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_PREVENT_CONSOLIDATE_IF_BATCHES_RUNNING));						
					} else if(String.isNotBlank(rrIdsStr)){		
	        			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_PREVENT_SPLIT_IF_BATCHES_RUNNING));
					}
				    showTarget = false;
	        	}
	    	}
    	}catch(Exception e){
    		system.debug('\n\n~~~~Error:' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    	}
		return null;
    }
    
    private Opportunity returnTargetOpportunity(String selectedOpptType){
    	targetOppt = new Opportunity(OwnerId = UserInfo.getUserId(),AccountId = opportunityDetails[0].AccountId, Name = opportunityDetails[0].Name);
    	set<String> setFieldsRequested = REN_OpportunityDataAccess.getFieldsByFieldSet('Opportunity Split Edit');
		setFieldsRequested.addAll(REN_OpportunityDataAccess.getFieldsByFieldSet('Opportunity Read Only'));
    	if(selectedOpptType == 'clone'){
			Opportunity tmpExising = REN_OpportunityDataAccess.getOpportunityById(opportunityId4Split, setFieldsRequested);
			targetOppt = tmpExising.clone(false, true);
    	}
   		CSM_Util.setAppliedCurrency(targetOppt, ((opportunityDetails == null || opportunityDetails.isEmpty()) ? null : CSM_Util.getAppliedCurrency(opportunityDetails[0])));//US452 
    	return targetOppt;
    }
    
    private void getAllRecordsFromRR(Id oId){ //US930
    	System.debug(rrIdsStr + '\n----------isConsolidatedRR: ' + isConsolidatedRR);
    	List<RRWrapper> rrWrapperList = new List<RRWrapper>();
    	isRliLimitExceeded = false;
    	Decimal rliThreshold = CSM_Admin__c.getOrgDefaults().REN_RLI_threshold_for_split_wizard__c;
    	if(String.isBlank(rrIdsStr) &&  String.isBlank(isConsolidatedRR)){
    		return;
    	}
    	selectedRRList = null;
    	String clmNamespace = CSM_Util.getNamespace();
	    if(!String.isBlank(rrIdsStr)){
			List<String> selectedIdList = rrIdsStr.split('-');
			for(String s: selectedIdList){
				selectedIdSetForRR.add((ID)s);
			}
			if(selectedIdSetForRR != null && !selectedIdSetForRR.isEmpty() && selectedIdSetForRR.size() > rliThreshold){
	        	isRliLimitExceeded = true;
	        }
	        selectedRRList = REN_RenewRelationshipDataAccess.getRenewalRelationshipByIds(rrFieldsSetForQuery, selectedIdSetForRR, rrDefaultFieldsSet);	        
	        
	    }else{
    	 	//consoildated 
    		selectedRRList = REN_RenewRelationshipDataAccess.getRenewalRelationshipByOpportunityIds(new Set<ID>{ID.valueOf(opportunityId4Split)}, rrFieldsSetForQuery, rrDefaultFieldsSet,NULL);
    	}
    	system.debug('---'+selectedRRList);
    	Set<ID> oppLISet = new set<ID>();
		if(selectedRRList!=null && !isRliLimitExceeded){
			Map<Id, OpportunityLineItem> oppProdMap = new Map<Id, OpportunityLineItem>(REN_OpportunityLineItemDataAccess.getOpportunityLineItemListByRLIRelationship(new Map<Id, REN_Renews_To__c>(selectedRRList).keySet()));
			if(oppProdMap != null){
		    	oppLISet = oppProdMap.keySet();
			}
			Map<ID, OpportunityLineItem> oliMap = new Map<ID, OpportunityLineItem>();
			System.debug(oppLISet + '\n~~~~~~~oliFieldsSetForQuery\n' + oliFieldsSetForQuery);
			if(oppLISet != null && !oppLISet.isEmpty()){
				List<OpportunityLineItem> oliListForRR = REN_OpportunityLineItemDataAccess.getOpportunityLineItemsByOppIdWithlineItemId(oId, oppLISet, oliFieldsSetForQuery);
				oliMap = new Map<ID, OpportunityLineItem>(oliListForRR);
				Integer unitPriceScale = CSM_Util.getFieldScale('OpportunityLineItem','UnitPrice');
				for(OpportunityLineItem ol : oliListForRR){
					REN_OpptLineWrapper olW = new REN_OpptLineWrapper();
					olW.opLine = ol;
					olW.opLine.UnitPrice = olW.opLine.UnitPrice == null?0:olW.opLine.UnitPrice.setScale(unitPriceScale, RoundingMode.CEILING);
					olw.isSelected = true;
                    lstAllOpptLinesW.add(olW);
				}
			}
			rrWrapperList = new list<RRWrapper>();
			Integer previousPriceScale = CSM_Util.getFieldScale(clmNamespace +'REN_Renews_To__c', clmNamespace +'REN_Previous_Price__c');
			for(REN_Renews_To__c rr :selectedRRList){
				RRWrapper rrW = new RRWrapper();
				rr.REN_Previous_Price__c = rr.REN_Previous_Price__c == null?0:rr.REN_Previous_Price__c.setScale(previousPriceScale, RoundingMode.CEILING);
				rrW.rrObj = rr;
				rrW.isSelected = true;
				rrWrapperList.add(rrW);
			}
		}
		//As part of US3842, we won't be showing target Opptys RLIs-OLIs on the interim page. -(deprecated code)
    	
    	//To handle more than 1000 records to show on VF page
    	if(rrWrapperList != null && !rrWrapperList.isEmpty()){
	    	List<RRWrapper> tempRRList = new List<RRWrapper>();
	    	Integer recordCounter = 0;
	    	for(RRWrapper rrObj : rrWrapperList){
	    		if(tempRRList.size() == 1000){
	    			rrWrapperListofList.add(tempRRList);
	    			tempRRList = new List<RRWrapper>();
	                recordCounter = 0;
	    		}
	    		tempRRList.add(rrObj);
	    		recordCounter++;
	    	}
	        if(!tempRRList.isEmpty()){
	            rrWrapperListofList.add(tempRRList);
	    		tempRRList = null;
	        }
	    	rrWrapperList = null;
    	}
    }
    
    
    private void getAllOpptLines(Id oId){
        if(String.isBlank(oppLinesStr)){
    		return;
    	}
    	if(oppLinesStr != null && oppLinesStr.trim() != ''){
        	lstPreselectedOl = oppLinesStr.split('-');
        }
        for(String oplTmp :lstPreselectedOl) {
        	ID olID;
        	try{
        		olID = oplTmp;
        	}catch (System.StringException e){}
        	setPreselectedOl.add(olID);
        }
    	System.debug(oppLinesStr + '\n\n1~~~~setPreselectedOl: ' +  setPreselectedOl);
    	lstAllOpptLines = REN_OpportunityLineItemDataAccess.getOpportunityLineItemsByOppIdWithlineItemId(oId, setPreselectedOl, oliFieldsSetForQuery);
    	System.debug(oId + '\n\n2~~~~lstAllOpptLines: ' +  lstAllOpptLines);
        
    	for(OpportunityLineItem ol : lstAllOpptLines){
    		REN_OpptLineWrapper olW = new REN_OpptLineWrapper();
    		olW.opLine = ol;
    		olw.isSelected = setPreselectedOl.contains(ol.Id);
    		lstAllOpptLinesW.add(olW);    		
    	}
    	
    	if(selectedOpptType == 'existing'){
    		lstAllOpptLines = REN_OpportunityLineItemDataAccess.getOpportunityLineItemsByOppIdWithlineItemId(opLn.OpportunityId, new Set<ID>(), oliFieldsSetForQuery);
    		for(OpportunityLineItem ol : lstAllOpptLines){
	    		REN_OpptLineWrapper olW = new REN_OpptLineWrapper();
	    		olW.opLine = ol;
	    		olw.isSelected = false;
	    		lstAllOpptLinesW.add(olW);
	    	}
    	}
    }
	
	public PageReference splitSelected(){	
		Savepoint sp = Database.setSavepoint();
		CSM_TriggerManager.disableAllTriggers();
		PageReference prTargetOppt;
		lstSelectedOpptLines = new List<OpportunityLineItem>();
		for(REN_OpptLineWrapper olW :lstAllOpptLinesW){
			if(olW.isSelected == true){
				lstSelectedOpptLines.add(olW.opLine);
			}
		}
		map<id,Opportunity> SourceOpportunityDetailsIds= new map<id,Opportunity>(opportunityDetails);
		
		system.debug('Selected Oppt Lines : ' + lstSelectedOpptLines);
		if(selectedOpptType != 'existing'){
				targetOppt = currentOpptDisplayed;
		}
		
		try{
			//Create New Opportunity - Optional
			if(selectedOpptType != 'existing'){
				targetOppt = currentOpptDisplayed;
				Boolean recordTypeExists = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'RecordTypeId');
		        if (recordTypeExists && opportunityDetails[0].get('RecordTypeId') != null){
		            targetOppt.put('RecordTypeId',(String)opportunityDetails[0].get('RecordTypeId'));
		        }
			}
			//Boolean IsConsolidated=false;
			String actionName = REN_Constants.STR_SPLIT;
			if(String.isNotBlank(isConsolidatedRR)){
			   actionName = REN_Constants.STR_CONSOLIDATE;
			}
			//US3640 
			if(isOppSplitCounter && selectedOpptType != 'existing'){
				if(checkIsMaxLimitForName(targetOppt.name, oppNameStr)){
					opportunityDetails[0].REN_Split_Counter__c = splitCounter;
				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_OPP_NAME_EXCEED_ERROR));
					return null;
				}
			} 
			String ErrorMsg='';//call to common consolidate method
			ErrorMsg = REN_ConsolidateHandler.finalConsolidation(lstSelectedOpptLines,selectedRRList, actionName, opportunityDetails, targetOppt);			
			if(String.isNotBlank(ErrorMsg)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ErrorMsg));
				Database.rollback(sp);
				return null;
			}
			CHL_ManageSplitConsolidatePRR.handlePRRSplitAndConsolidate(selectedRRList, opportunityDetails, targetOppt, actionName);
			prTargetOppt = new ApexPages.StandardController(targetOppt).view();
		    prTargetOppt.setRedirect(true);
		}catch(Exception e){
			system.debug('\n\nError: ' + e);
			Database.rollback(sp);
			targetOppt.Id = null;
			ApexPages.Message genericErrMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(genericErrMsg);
			prTargetOppt = null;
		}
		return prTargetOppt;
	}
	
	public PageReference cancel(){
		PageReference prCurrentOppt;		
		//Updated code to handle Attempt to derefernce error on click of Cancel, if Opty type is not selected
		if(opportunityDetails !=null)	{
			prCurrentOppt = new ApexPages.StandardController(opportunityDetails[0]).view();
		} else {
			opportunityDetails = CSM_OpportunityDataAccess.getDetailFieldSetById(opportunityId4Split);
			prCurrentOppt = new ApexPages.StandardController(opportunityDetails[0]).view();
		}	
		
		if(String.isNotBlank(rrIdsStr) || (String.isNotBlank(isConsolidatedRR) && isConsolidatedRR.equals('true'))){
			prCurrentOppt = page.REN_RenewalRelationshipBulkEdit;
			prCurrentOppt.getParameters().put('OpptId', opportunityDetails[0].id);
		}
    	prCurrentOppt.setRedirect(true);
    	return prCurrentOppt;
	}
	
	public with sharing class RRWrapper{
		public REN_Renews_To__c rrObj {get; set;}
		public OpportunityLineItem opLine{get; set;}
		public Boolean isSelected {get; set;} 
		
		public RRWrapper(){
			opLine= new OpportunityLineItem();
		}
	}
    /* US3640 - Below method added to check the splited Opp. Name has been updated, return true else false */
	public Boolean checkIsMaxLimitForName(String oppName, String oppNameSplitCounter){
		Boolean isValid = true;
		if(isOppNameExceedChar){
			String nameStr = oppNameSplitCounter.mid(0,120);
        	if (oppName.equals(nameStr)){
        		isValid = false;
        	}
		}
		return isValid;
	}
}