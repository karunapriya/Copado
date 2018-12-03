public with sharing class PeerReviewDataAccess {
	
public  static List<Peer_Review__c>  getPeerReviewByTypeAndOwner(String recordType, String ownerId, String businessLine, String engagementType, String opportunityType, String ssiTheatre, String clientTerritory, String clientRegion, 
            List<Quote> quoteList, String additionalConditionQuery) {
   
        String namespace = Util.solnExtnNameSpace;
        List<String> peerReviewFields = new List<String> {'Id', 'CurrencyIsoCode',
        	namespace + 'Business_Line__c', namespace + 'Case_Record_Type__c',
            namespace + 'Case_Record_Type__c',namespace + 'Client_Region__c', 
            namespace + 'Client_Territory__c', namespace + 'Current_Counter__c', 
            namespace + 'Engagement_Type__c', 
            namespace + 'Max_Amount__c', namespace + 'Min_Amount__c', namespace + 'Opportunity_Type__c',
            namespace + 'Review_Threshold__c', namespace + 'SSI_Theatre__c',namespace + 'User__c',
            namespace + 'Is_Active__c'};
        
         Util.checkCRUD_FLS('Peer_Review__c', peerReviewFields, Constants.DML_OPERATION_READ);
   		 String finalQuery = '';
    	 String initialQuery = 'SELECT Id, ' + 
            'CurrencyIsoCode, ' +
            'Business_Line__c, ' + 
            'Case_Record_Type__c, ' + 
            'Client_Region__c, ' + 
            'Client_Territory__c, ' + 
            'Current_Counter__c, ' + 
            'Engagement_Type__c, ' + 
            'Max_Amount__c, ' + 
            'Min_Amount__c, ' + 
            'Opportunity_Type__c, ' + 
            'Review_Threshold__c, ' + 
            'SSI_Theatre__c, ' + 
            'User__c ' + 
            'FROM Peer_Review__c ' + 
            'WHERE Is_Active__c = true ' + 
            'AND Case_Record_Type__c = \'' + recordType + '\' ' + 
            'AND (User__c = \'' + ownerId + '\' OR User__c = null)';
           
        initialQuery += (String.isNotBlank(businessLine) ? 'AND (Business_Line__c = \'' + businessLine + '\' OR Business_Line__c = null) ' : ' AND Business_Line__c = null ') ;
		initialQuery += (String.isNotBlank(engagementType) ? 'AND (Engagement_Type__c = \'' + engagementType + '\' OR Engagement_Type__c = null) ' : ' AND Engagement_Type__c = null ') ;	     
		initialQuery += (String.isNotBlank(opportunityType) ? 'AND (Opportunity_Type__c = \'' + opportunityType + '\' OR Opportunity_Type__c = null) ' : ' AND Opportunity_Type__c = null ') ;	  
		initialQuery += (String.isNotBlank(ssiTheatre) ? 'AND (SSI_Theatre__c = \'' + ssiTheatre + '\' OR SSI_Theatre__c = null) ' : ' AND SSI_Theatre__c = null ') ;	
		initialQuery += (String.isNotBlank(clientTerritory) ? 'AND (Client_Territory__c = \'' + clientTerritory + '\' OR Client_Territory__c = null) ' : ' AND Client_Territory__c = null ') ;
		initialQuery += (String.isNotBlank(clientRegion) ? 'AND (Client_Region__c = \'' + clientRegion + '\' OR Client_Region__c = null) ' : ' AND Client_Region__c = null ') ;
       	finalQuery = 'ORDER BY User__c ASC NULLS FIRST';
    	System.debug('\n~~~~: final query of this '+initialQuery + additionalConditionQuery + finalQuery);
       	return Database.query(initialQuery + additionalConditionQuery + finalQuery);
    }
        
     public  static List<Peer_Review__c>  getPeerReviewByType(Set<Id> caseRecordTypeIds, Set<Id> caseOwnerIds, 
             Set<String> caseBusinessLines, Set<String> caseEngagementTypes, Set<String> caseOpptTypes,
             Set<String> caseSSITheaters, Set<String> caseClientTerritories, Set<String> caseClientRegions,
             Set<String> casesToGetQuotesSet)
     {
         String namespace = Util.solnExtnNameSpace;
         List<String> peerReviewFields = new List<String> {'Id', 'CurrencyIsoCode',
         	namespace + 'Business_Line__c', namespace + 'Case_Record_Type__c',
            namespace + 'Case_Record_Type__c',namespace + 'Client_Region__c', namespace + 'Client_Territory__c', Util.solnExtnNameSpace + 'Current_Counter__c', Util.solnExtnNameSpace + 'Engagement_Type__c', 
            namespace + 'Max_Amount__c', namespace + 'Min_Amount__c', namespace + 'Opportunity_Type__c', 
            namespace + 'Review_Threshold__c', namespace + 'SSI_Theatre__c',namespace + 'User__c',
            namespace + 'Is_Active__c'};
        
         Util.checkCRUD_FLS('Peer_Review__c', peerReviewFields, Constants.DML_OPERATION_READ);
         
         String initialQuery = '';
         String finalQuery = '';
         initialQuery += 'SELECT Id, ' + 
			            'CurrencyIsoCode, ' +
			            'Business_Line__c, ' + 
			            'Case_Record_Type__c, ' + 
			            'Client_Region__c, ' + 
			            'Client_Territory__c, ' + 
			            'Current_Counter__c, ' + 
			            'Engagement_Type__c, ' + 
			            'Max_Amount__c, ' + 
			            'Min_Amount__c, ' + 
			            'Opportunity_Type__c, ' + 
			            'Review_Threshold__c, ' + 
			            'SSI_Theatre__c, ' + 
			            'User__c ' + 
			            'FROM Peer_Review__c ' + 
			            'WHERE Is_Active__c = true ' + 
			            'AND Case_Record_Type__c IN :caseRecordTypeIds ';
         
         System.debug('\n111~~~~\n caseOpptTypes: ' + caseOpptTypes);
        
         if(!caseOwnerIds.isEmpty())
         {
         	 initialQuery += 'AND (User__c IN :caseOwnerIds) '; 
         }
         System.debug(caseBusinessLines.isEmpty() + '\n111~~~~\n caseBusinessLines: ' + caseBusinessLines);
         if(!caseBusinessLines.isEmpty())
         {
         	 initialQuery += 'AND (Business_Line__c IN :caseBusinessLines) ';
         }
         if(!caseEngagementTypes.isEmpty())
         {
         	 initialQuery += 'AND (Engagement_Type__c IN :caseEngagementTypes) ';
         }
         if(!caseOpptTypes.isEmpty()) 
         {
         	initialQuery += 'AND (Opportunity_Type__c IN :caseOpptTypes) ';
         }
         if(!caseSSITheaters.isEmpty()) {
         	 initialQuery += 'AND (SSI_Theatre__c IN :caseSSITheaters) ';
         }
         if(!caseClientTerritories.isEmpty())
         {
         	 initialQuery += 'AND (Client_Territory__c IN :caseClientTerritories) ';
         }
         if(!caseClientRegions.isEmpty()) 
         {
         	initialQuery += 'AND (Client_Region__c IN :caseClientRegions) ';
         }
		 finalQuery = 'ORDER BY User__c ASC NULLS FIRST';
		
		 System.debug('final query '+initialQuery + finalQuery);
         return Database.query(initialQuery + finalQuery);
     }
     
    // To update peer review's Current Counter.
    public static boolean updatePeerReviewCurrentCounter(List<Case> lstPeerReviewCases) {
    	Case cs = lstPeerReviewCases[0];
        Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
        String additionalConditionQuery = '';
        String finalQuery = '';
        Integer quoteTotalCount = 0;
        Integer quoteCurrentCount = 0;
        boolean isReviewCaseRequired = false;
        String namespace = Util.solnExtnNameSpace;
        String initialQuery = 'SELECT Id, ' + 
            'CurrencyIsoCode, ' +
            'Business_Line__c, ' + 
            'Case_Record_Type__c, ' + 
            'Client_Region__c, ' + 
            'Client_Territory__c, ' + 
            'Current_Counter__c, ' + 
            'Engagement_Type__c, ' + 
            'Max_Amount__c, ' + 
            'Min_Amount__c, ' + 
            'Opportunity_Type__c, ' + 
            'Review_Threshold__c, ' + 
            'SSI_Theatre__c, ' + 
            'User__c ' + 
            'FROM Peer_Review__c ' + 
            'WHERE Is_Active__c = true ' + 
            'AND Case_Record_Type__c = \'' + cs.RecordTypeId + '\' ' + 
            'AND (User__c = \'' + cs.OwnerId + '\' OR User__c = null)';
            
        initialQuery += (cs.Business_Line__c != null ? ' AND (Business_Line__c = \'' + cs.Business_Line__c + '\' OR Business_Line__c = null) ' : ' AND Business_Line__c = null ') ;
        initialQuery += (cs.Engagement_Type__c != null ? ' AND (Engagement_Type__c = \'' + cs.Engagement_Type__c + '\' OR Engagement_Type__c = null) ' : ' AND Engagement_Type__c = null ');
        initialQuery += (cs.Opportunity_Type__c != null ? ' AND (Opportunity_Type__c = \'' + cs.Opportunity_Type__c + '\' OR Opportunity_Type__c = null) ' : ' AND Opportunity_Type__c = null ');
        initialQuery += (cs.SSI_Theatre__c != null ? ' AND (SSI_Theatre__c = \'' + cs.SSI_Theatre__c + '\' OR SSI_Theatre__c = null) ' : ' AND SSI_Theatre__c = null ');
        initialQuery += (cs.Client_Territory__c != null ? ' AND (Client_Territory__c = \'' + cs.Client_Territory__c + '\' OR Client_Territory__c = null) ' : ' AND Client_Territory__c = null ');
        initialQuery += (cs.Client_Region__c != null ? ' AND (Client_Region__c = \'' + cs.Client_Region__c + '\' OR Client_Region__c = null) ' : ' AND Client_Region__c = null ');
                       
        if(cs.RecordTypeId == ZS.Case_Quote_Request_Record_Type_Id__c){
            List<Quote> quoteList = [SELECT Id, CurrencyIsoCode, TotalPrice FROM Quote WHERE Case__c = :cs.Id];
            quoteTotalCount = quoteList.size();
            quoteCurrentCount = 0;
            
            if(quoteTotalCount > 0) additionalConditionQuery += 'AND (';
            for(Quote quo : quoteList){
                quoteCurrentCount++;
                additionalConditionQuery += '(CurrencyIsoCode = \'' + quo.CurrencyIsoCode + '\' ' + 
                    'AND (Min_Amount__c <= ' + quo.TotalPrice + ' OR Min_Amount__c = null) ' +
                    'AND (Max_Amount__c >= ' + quo.TotalPrice + ' OR Max_Amount__c = null))';
                if(quoteCurrentCount != quoteTotalCount) additionalConditionQuery += ' OR ';
            }
            if(quoteTotalCount > 0) additionalConditionQuery += ') ';
        }
        else quoteTotalCount = 1;
        
        finalQuery = 'ORDER BY User__c ASC NULLS FIRST';
        
        System.debug('##### Complete Query: ' + initialQuery + additionalConditionQuery + finalQuery);
        Util.checkCRUD_FLS('Peer_Review__c', new List<String>{'CurrencyIsoCode', namespace + 'Business_Line__c', namespace + 'Case_Record_Type__c', namespace + 'Client_Region__c', namespace + 'Client_Territory__c', namespace + 'Current_Counter__c', namespace + 'Engagement_Type__c', namespace + 'Max_Amount__c', namespace + 'Min_Amount__c', namespace + 'Opportunity_Type__c', namespace + 'Review_Threshold__c', namespace + 'SSI_Theatre__c', namespace + 'User__c'}, Constants.DML_OPERATION_READ);
        List<Peer_Review__c> prList = Database.query(initialQuery + additionalConditionQuery + finalQuery);
        System.debug('##### prList: ' + prList);

        for(Peer_Review__c pr : prList){
            pr.Current_Counter__c = Integer.valueOf(pr.Current_Counter__c) + quoteTotalCount;
            if(Integer.valueOf(pr.Current_Counter__c) >= Integer.valueOf(pr.Review_Threshold__c) || cs.ParentId != null){ 
                isReviewCaseRequired = true;
            }
        }
        if(prList.size() > 0){
	        Util.checkCRUD_FLS('Peer_Review__c', new List<String>{namespace + 'Current_Counter__c'}, Constants.DML_OPERATION_UPDATE);
        	 update prList;
        }
        if(cs.ParentId != null && cs.Sub_Case_Type__c == 'Correction'){
        	isReviewCaseRequired = true;
        }
        return isReviewCaseRequired;
        	
    }     
}