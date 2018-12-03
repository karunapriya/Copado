public with sharing class PeerReviewUtils {
    
    // Pre-check to define whether the case should go through the Peer Review process.
    public static boolean peerReviewPreCheck(Case cs) {
        List<Quote> quoteList = QuoteDataAccess.getQuoteByCase(new Set<String>{cs.Id});
        Integer quoteTotalCount = 0;
        Integer quoteCurrentCount = 0;
        String additionalConditionQuery = '';
        Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
        boolean closedFlag = true;
        if(cs.RecordTypeId == ZS.Case_Quote_Request_Record_Type_Id__c){
        	
            quoteTotalCount = quoteList.size();
            quoteCurrentCount = 0;
        
	        if(quoteTotalCount > 0) {
	        	additionalConditionQuery += 'AND (';
	        }
            for(Quote quo : quoteList){
                quoteCurrentCount++;
                additionalConditionQuery += '(CurrencyIsoCode = \'' + quo.CurrencyIsoCode + '\' ' + 
                    'AND (Min_Amount__c <= ' + quo.TotalPrice + ' OR Min_Amount__c = null) ' +
                    'AND (Max_Amount__c >= ' + quo.TotalPrice + ' OR Max_Amount__c = null))';
                if(quoteCurrentCount != quoteTotalCount) additionalConditionQuery += ' OR ';
            }
            if(quoteTotalCount > 0) {
            	 additionalConditionQuery += ') ';
            }
        }
        else {
        	quoteTotalCount = 1;
        }
        List<Peer_Review__c> prList = PeerReviewDataAccess.getPeerReviewByTypeAndOwner(cs.RecordTypeId, cs.OwnerId, 
            cs.Business_Line__c, cs.Engagement_Type__c, cs.Opportunity_Type__c, cs.SSI_Theatre__c, cs.Client_Territory__c, 
            cs.Client_Region__c, quoteList, additionalConditionQuery);
        
        for(Peer_Review__c pr : prList){
            pr.Current_Counter__c = Integer.valueOf(pr.Current_Counter__c) + quoteTotalCount;
            if(Integer.valueOf(pr.Current_Counter__c) >= Integer.valueOf(pr.Review_Threshold__c)) closedFlag = false;
        }
        
        return closedFlag;
    }
    // To update peer review's Current Counter.
    public static void peerReviewTracker(List<Case> lstPeerReviewCases) {   
    	Case cs = lstPeerReviewCases[0]; 	
        boolean isReviewCaseRequired = PeerReviewDataAccess.updatePeerReviewCurrentCounter(lstPeerReviewCases);
        if(isReviewCaseRequired){
            generateReviewCase(new Map<ID, Case>{cs.id => cs});
        }
    }  

    //To generate review case.
    public static void generateReviewCase(Map<Id, Case> reviewCasesMap){
        Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
        Map<String, Case> reviewOwnerIds2Case = new Map<String, Case>();
        Set<String> caseIdSet = new Set<String>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Case c :reviewCasesMap.values()){
        	reviewOwnerIds2Case.put(c.OwnerId, c);
        }
        List<Contact> contactList = ContactDataAccess.getContactsBySystemUserRefs(reviewOwnerIds2Case.keySet());        
        Map<Id, Contact> caseOwnerId2ContactMap = new Map<Id, Contact>();
         
        for(Contact c :contactList){
        	caseOwnerId2ContactMap.put(c.System_User_Reference__c, c);
        }
        
        List<Case> reviewCases2Insert = new List<Case>();
        for(Id contactId :reviewOwnerIds2Case.keySet()){
        	Contact con = caseOwnerId2ContactMap.get(contactId);
        	Case c = reviewOwnerIds2Case.get(con.System_User_Reference__c);
        	
        	if(c.RecordTypeId == ZS.Case_Quote_Request_Record_Type_Id__c){
        	 	Case reviewCase = new Case(RecordTypeId = ZS.Case_Review_Request_Record_Type_Id__c,
					                ParentId = c.Id,
					                AccountId = c.AccountId,
					                EntitlementId = c.EntitlementId,
					                ContactId = con.Id,
					                Status = 'New',
					                Priority = c.Priority,
					                Origin = 'CRM User',
					                Subject = Label.LBL_QUOTE_REVIEW + ' - ' + c.CaseNumber,
					                Description = Label.MSG_QUOTE_REQUEST,
					                Opportunity__c = c.Opportunity__c,
					                Original_Case_1P__c = (c.Original_Case_1P__c != null) ? c.Original_Case_1P__c : c.Id,
					                Sub_Case_Type__c = 'Quote',
					                Original_Quoter_1P__c = (c.Original_Quoter_1P__c != null) ? c.Original_Quoter_1P__c : c.OwnerId,
					                Quote_Type__c = c.Quote_Type__c);
	            reviewCases2Insert.add(reviewCase);
        	 }
        	 else if(c.RecordTypeId == ZS.Case_Booking_Request_Record_Type_Id__c){
        	 	Case reviewCase = new Case(RecordTypeId = ZS.Case_Review_Request_Record_Type_Id__c,
		                			ParentId = c.Id,
					                AccountId = c.AccountId,
					                EntitlementId = c.EntitlementId,
					                ContactId = con.Id,
					                Status = 'New',
					                Priority = c.Priority,
					                Origin = 'CRM User',
					                Subject = Label.LBL_BOOKING_REVIEW + ' - ' + c.CaseNumber,
					                Description = Label.LBL_BOOKING_REQUEST,
					                Opportunity__c = c.Opportunity__c,
					                Original_Case_1P__c = (c.Original_Case_1P__c != null) ? c.Original_Case_1P__c : c.Id,
					                Sub_Case_Type__c = 'Booking',
					                Original_Quoter_1P__c = (c.Original_Quoter_1P__c != null) ? c.Original_Quoter_1P__c : c.OwnerId,
					                Contract_Amount__c = c.Contract_Amount__c);
            	reviewCases2Insert.add(reviewCase);
        	 }
        	 caseIdSet.add(c.Id);
        	 oppIdSet.add(c.Opportunity__c);
        }
        
        if(!reviewCases2Insert.isEmpty()){
        	String namespace = Util.solnExtnNameSpace;
        	List<String> caseFLSList = new List<String> {'RecordTypeId','ParentId',
        		'AccountId','ContactId','Status','Priority','Origin', 'Subject','Description',
        		namespace + 'Opportunity__c', namespace + 'Original_Case_1P__c', 
        		namespace + 'Original_Case_1P__c', namespace + 'Sub_Case_Type__c',
        		namespace + 'Original_Quoter_1P__c', namespace + 'Contract_Amount__c',
        		namespace + 'Quote_Type__c'};
        	CaseTriggerHandlerHelper.updateInReviewStatus(caseIdSet); 
            Map<Id,Opportunity> mapOfOpp = new Map<Id,Opportunity>(OpportunityDataAccess.getOpportunityDetailsById(oppIdSet, new List<String>{'Ops_Stage__c','StageName'}, new List<String>{'RecordType.Name'}));
        	List<Opportunity> impactedOppList  = CaseTriggerHandlerHelper.updateReviewRequestCase(reviewCases2Insert,mapOfOpp);
            OpportunityDataAccess.updateOpportunityList(impactedOppList, new List<String>{'Ops_Stage__c'});		        		        			           
        	CaseDataAccess.insertCases(reviewCases2Insert, caseFLSList);        	
        }
    }

    // Return the count of each Review Status.
    public static Map<String, Integer> getQuoteReviewStatusCount(String caseId){
        Map<String, Integer> reviewStatusCountMap = new Map<String, Integer>();
        Map<Id, Quote> quoteMap = QuoteDataAccess.getQuoteMapByCase(new Set<String> {caseId});
        for(Quote quo : quoteMap.values()){
            if(reviewStatusCountMap.get(quo.Review_Status__c) != null) reviewStatusCountMap.put(quo.Review_Status__c, reviewStatusCountMap.get(quo.Review_Status__c) + 1);
            else reviewStatusCountMap.put(quo.Review_Status__c, 1);
        }
        return reviewStatusCountMap;
    }
      
     public static void generateRevisionCase(List<Case> csList){
        Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
        Set<String> ownerIdSet = new Set<String>();
        for(Case csaeObj : csList){
        	ownerIdSet.add(csaeObj.OwnerId);
        }
        List<Contact> conList = ContactDataAccess.getContactsBySystemUserRefs(ownerIdSet);
       
        map<String,Id> comMap = new map<String,Id>();
        for(Contact conObj : conList){
        	comMap.put(conObj.System_User_Reference__c,conObj.Id);
        }
        List<Case> updateCaseLst = new List<Case>();
        String namespace = Util.solnExtnNameSpace;
        List<String> caseFLSList = new List<String> {'RecordTypeId','ParentId',
        		'AccountId','ContactId','Status','Priority','Origin', 'Subject','Description',
        		namespace + 'Opportunity__c', namespace + 'Original_Case_1P__c', 
        		namespace + 'Original_Case_1P__c', namespace + 'Sub_Case_Type__c',
        		namespace + 'Original_Quoter_1P__c'};
        for(Case cs : csList){
        
	        if(cs.Sub_Case_Type__c == 'Quote'){
	            Case revisionCase = new Case(RecordTypeId = ZS.Case_Quote_Request_Record_Type_Id__c,
	                ParentId = cs.Id,
	                AccountId = cs.AccountId,
	                EntitlementId = cs.EntitlementId,
	                ContactId = comMap.get(cs.OwnerId),
	                Status = 'New',
	                Priority = cs.Priority,
	                Origin = 'CRM User',
	                Subject = Label.LBL_QUOTE_REVISION + ' - ' + cs.CaseNumber ,
	                Description = Label.MSG_FAILED_QUOTES,
	                Opportunity__c = cs.Opportunity__c,
	                Original_Case_1P__c = (cs.Original_Case_1P__c != null) ? cs.Original_Case_1P__c : cs.Id,
	                Sub_Case_Type__c = 'Correction',
	                Original_Quoter_1P__c = cs.Original_Quoter_1P__c,
	                Quote_Request_Type__c = 'Correction Request',
	                Quote_Type__c = cs.Quote_Type__c);
	                updateCaseLst.add(revisionCase);
	                caseFLSList.add(namespace + 'Quote_Request_Type__c');
	                caseFLSList.add(namespace + 'Quote_Type__c');
	            //insert revisionCase;
	        }
	        
	        if(cs.Sub_Case_Type__c == 'Booking'){
	            Case revisionCase = new Case(RecordTypeId = ZS.Case_Booking_Request_Record_Type_Id__c,
	                ParentId = cs.Id,
	                AccountId = cs.AccountId,
	                EntitlementId = cs.EntitlementId,
	                ContactId = comMap.get(cs.OwnerId),
	                Status = 'New',
	                Priority = cs.Priority,
	                Origin = 'CRM User',
	                Subject = Label.LBL_BOOKING_REVISION + ' - ' + cs.CaseNumber,
	                Description = Label.MSG_REVISE_BOOKING,
	                Opportunity__c = cs.Opportunity__c,
	                Original_Case_1P__c = (cs.Original_Case_1P__c != null) ? cs.Original_Case_1P__c : cs.Id,
	                Sub_Case_Type__c = 'Correction',
	                Original_Quoter_1P__c = cs.Original_Quoter_1P__c,
	                Contract_Amount__c = cs.Contract_Amount__c);
	                updateCaseLst.add(revisionCase);
	                caseFLSList.add(namespace + 'Contract_Amount__c');
	            //insert revisionCase;
	        }
        }
        if(updateCaseLst.size() > 0) { 	 
        	CaseDataAccess.insertCases(updateCaseLst, caseFLSList);	
        }
    }
    
    public static void originalCaseStatusClosed(List<Case> csList){
        Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
        List<Case> caseToUpdateList = new List<Case>();
        for(Case pc : CaseDataAccess.getCasesByRecordTypeAndIds(csList)){
            pc.Status = 'Closed';
            caseToUpdateList.add(pc);
        }
       
        
        if(caseToUpdateList.size() > 0) {
            CaseDataAccess.updateCases(caseToUpdateList, new List<String>{'Status'});
        }
    }
}