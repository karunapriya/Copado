/**
 * Created Date		: Oct 3, 2016
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: This class will return response for type down serach for Global search in Community.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi					US1624				Oct 3, 2016			1.1					Channel Portal - Global Search
 *
 */
public with sharing class CHL_GlobalSearchBusinessLayer {

   //private Map<String,String> mapOfRLIToPO = new Map<String,String>();

    /**
	 * @description : Used to construct the wrapper which will be used to show 10 results on type down serach based on object rank.
     * @param : Accept the search string
     * @return : wrapper to show search result on type down search 
     */
	public static object ConstructGlobalSearch(String inputParams){
		//CHL_QuickSearchInputWrapper searchObj = new CHL_QuickSearchInputWrapper();
        //searchObj = (CHL_QuickSearchInputWrapper) JSON.deserialize(inputParams, CHL_QuickSearchInputWrapper.class);
        CHL_CommunityLandingController.AccountSearch searchObj = new CHL_CommunityLandingController.AccountSearch();
        searchObj = (CHL_CommunityLandingController.AccountSearch) JSON.deserialize(inputParams, CHL_CommunityLandingController.AccountSearch.class);
        String searchString = searchObj.q;//'con';//
        String objectType = searchObj.ot; //'PARTNER_CONTACT';
		String nameSpacePrefix = CSM_Util.getNamespace();
		List<CHL_GlobalSearchWrapper> globalSearchWrpList = new List<CHL_GlobalSearchWrapper>();
		Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
        if(String.isNotBlank(searchString) && String.isBlank(objectType)) {
			Integer queryLimit = 10;
			String quoteQuery = '';
			String cliQuery = '';		
			String ParentId = '';
			Map<String,String> mapOfRLIToPO = new Map<String,String>();
			if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
				string currentUserAccountId = acc <> null ? acc.id : null;
		        string whereClause = ' Where ('+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Account_1__c =: currentUserAccountId OR '+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Account_2__c =: currentUserAccountId) ';
		        boolean is2TierEnabled = false;
				if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty())   {
		            is2TierEnabled = (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpacePrefix+'CHL_Enable_2_Tier_Pricing__c');
		        }
		        if(is2TierEnabled) {
			        //string currentUserAccountType = CHL_Util.currentUserDetails[0].Account.CHL_Partner_Account_Type__c;
					if(CHL_Constants.STR_RESELLER.equalsIgnoreCase(currentUserAccountType) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c')){
						whereClause += ' AND '+CHL_Util.quoteExtnNameSpace+'CHL_Is_Distributor_Quote__c = false';
					}	 				
		        }
		        if(Test.isRunningTest()) {
					quoteQuery = ' ,' + CHL_Constants.OBJ_QUOTE +'(Id,Name limit '+queryLimit+')';
		        } else {
		        	quoteQuery = ' ,' + CHL_Constants.OBJ_QUOTE +'(Id,Name,'+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c'+whereClause+' limit '+queryLimit+')';
		        }
			}
			if(CSM_AccessController.hasObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM)) {
				cliQuery = ' ,' + REN_Constants.OBJ_CONTRACT_LINE_ITEM +'(Id,LineItemNumber,ServiceContract.accountID limit '+queryLimit+')';
			}
			string queryString = 'FIND\''+ searchString +'*\' IN All Fields Returning Account (Id,Name limit '+queryLimit+') ,'+nameSpacePrefix+'CHL_Partner_Opportunity__c (Id,Name limit '+queryLimit+'),Case(Id,Subject limit '+queryLimit+'),Asset (Id,Name,AccountId limit '+queryLimit+'),'+nameSpacePrefix+'REN_Renews_To__c (Id,Name limit '+queryLimit+') ,Contact (Id,Name,AccountId limit '+queryLimit+') '+quoteQuery+cliQuery ; //,CHL_Portal_Content__c (Id,Name limit '+queryLimit+')
			system.debug('queryString::'+queryString);
			
			List<List<SObject>>searchList = search.query(queryString);
			system.debug('searchList::'+searchList);
			
			for(integer objRank=1; objRank <=8; objRank++) {
				if(globalSearchWrpList != null && globalSearchWrpList.size() == queryLimit) {
					break;
				}
				else if(globalSearchWrpList == null || globalSearchWrpList.size() < queryLimit) {
					List<sObject> sobjectList = getObjectListForRank(objRank,searchList,mapOfRLIToPO);
					system.debug('Map after method : '+mapOfRLIToPO);
					if(sobjectList != null && !sobjectList.isEmpty()) {
						integer recordLimit = sobjectList.size() <= (queryLimit - globalSearchWrpList.size())?sobjectList.size():queryLimit - globalSearchWrpList.size();
						for(integer i=0; i<recordLimit; i++) {
							if(getObjectTypeForRank(objRank) == 'AS' || getObjectTypeForRank(objRank) == 'CN') {
								ParentId = (String)sobjectList[i].get('AccountId');
							} else if(getObjectTypeForRank(objRank) == 'CT') {
								sObject scObj = sobjectList[i].getSobject('ServiceContract');
								ParentId = (String)scObj.get('AccountId');
							} else if(getObjectTypeForRank(objRank) == 'QU') {
								ParentId = !Test.isRunningTest() ? (String)sobjectList[i].get(CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c') : (String)sobjectList[i].get('Id');
							} else if(getObjectTypeForRank(objRank) == 'LI') {
								if(mapOfRLIToPO != null && mapOfRLIToPO.containsKey((String)sobjectList[i].get('Id'))) {
									ParentId = mapOfRLIToPO.get((String)sobjectList[i].get('Id'));
								}
							} else {
								ParentId = (String)sobjectList[i].get('Id');
							}
							CHL_GlobalSearchWrapper gsearchObj = new CHL_GlobalSearchWrapper(sobjectList[i],getObjectTypeForRank(objRank),ParentId);
							gsearchObj.id = (String)sobjectList[i].get('Id');
							if(getObjectTypeForRank(objRank) == 'RQ') {
								gsearchObj.name = (String)sobjectList[i].get('subject');
							} else if(getObjectTypeForRank(objRank) == 'CT') {
								gsearchObj.name = (String)sobjectList[i].get('LineItemNumber');
							} else {
								gsearchObj.name = (String)sobjectList[i].get('Name');
							}
							globalSearchWrpList.add(gsearchObj);
						}
					}
				}
			}	
        } 
        //Below code is added as part of US1626, Opportunity Filter enhancement
        else if(String.isNotBlank(objectType)) {      		
        	globalSearchWrpList.addAll(CHL_QueryBuilderUtil.getSearchOptions(objectType, searchString));
        }
		system.debug('globalSearchWrpList : '+globalSearchWrpList.size()+'\n '+globalSearchWrpList);
		return globalSearchWrpList;
	}
	
	

	
	/*
	@description : Method to construct Map of Object rank and its corresponding serach result list.
	*/
	public static List<sObject> getObjectListForRank(Integer Rank, List<List<sObject>> searchList, Map<String,string> RLIToPOMap){
		List<sObject> poList = new List<sObject>();
		List<sObject> accList = new List<sObject>();
		List<sObject> caseList = new List<sObject>();
		List<sObject> quoteList = new List<sObject>();
		List<sObject> assetList = new List<sObject>();
		List<sObject> cliList = new List<sObject>();
		List<sObject> rliList = new List<sObject>();
		//List<sObject> helpfulLinkList = new List<sObject>();
		List<sObject> contactList = new List<sObject>();
		List<sObject> filteredRliList = new List<sObject>();
		Set<String> rliIdSet = new Set<String>();
		system.debug('searchList Size : '+searchList.size());
		if(searchList != null && !searchList.isEmpty()) {
			accList.addAll(searchList[0]);
			poList.addAll(searchList[1]);
			caseList.addAll(searchList[2]);
			assetList.addAll(searchList[3]);
			rliList.addAll(searchList[4]);
			//helpfulLinkList.addAll(searchList[5]);
			contactList.addAll(searchList[5]);
			if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
				quoteList.addAll(searchList[searchList.size() - 2]);
			}
			if(CSM_AccessController.hasObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM)) {
				cliList.addAll(searchList[searchList.size() - 1]);
			}
		}
		List<CHL_Partner_Renewal_Relationship__c> partnerRenwalList = CHL_PartnerRenRelationshipDataAccess.getPrtnrRenRelFromRenRel(new List<String>{'Id','CHL_Partner_Opportunity__c'},rliList);
		for(CHL_Partner_Renewal_Relationship__c prr:partnerRenwalList) {
			RLIToPOMap.put(prr.CHL_Renewal_Relationship__c,prr.CHL_Partner_Opportunity__c); //id
			rliIdSet.add(prr.CHL_Renewal_Relationship__c);
		}
		filteredRliList = REN_RenewRelationshipDataAccess.getRRByIds(rliIdSet);
		system.debug('PO LIST '+poList+'accList'+accList.size()+'\n RLIToPOMap : '+RLIToPOMap);
		Map<Integer,List<Sobject>> objectRankMap = new Map<Integer,List<Sobject>>();
		objectRankMap.put(1,poList);
		objectRankMap.put(2,quoteList);
		objectRankMap.put(3,accList);
		objectRankMap.put(4,filteredRliList); // partnerRenwalList
		objectRankMap.put(5,assetList);
		objectRankMap.put(6,cliList);
		objectRankMap.put(7,caseList);
		objectRankMap.put(8,contactList);
		return objectRankMap.containsKey(Rank) ? objectRankMap.get(Rank) : null;
	}
	
	/*
	@description : Method to construct Map of Object rank and its corresponding object type
	*/
	public static string getObjectTypeForRank(Integer Rank){
		Map<Integer,String> objectTypeRankMap = new Map<Integer,String>();
		objectTypeRankMap.put(1,'OP');
		objectTypeRankMap.put(2,'QU');
		objectTypeRankMap.put(3,'AC');
		objectTypeRankMap.put(4,'LI');
		objectTypeRankMap.put(5,'AS');
		objectTypeRankMap.put(6,'CT');
		objectTypeRankMap.put(7,'RQ');
		objectTypeRankMap.put(8,'CN');
		return objectTypeRankMap.containsKey(Rank) ? objectTypeRankMap.get(Rank) : '';
	}

	/*public class GlobalSearchWrapper {
        public String id;
        public String type;
        public String name;
        public string pid;
    
        public GlobalSearchWrapper(sObject sObj, String objType, String ParentId) {
            if(sObj != null) {
	            this.id = (String)sObj.get('Id');
	            this.type = objType;
	            if(objType == 'RQ') {
					this.name = (String)sObj.get('subject');
				} else if(objType == 'CT') {
					this.name = (String)sObj.get('LineItemNumber');
				} else {
					this.name = (String)sObj.get('Name');
				}
				this.pid = ParentId;
            } 
        }
    }*/	
}