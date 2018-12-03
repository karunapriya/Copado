/**
 * Created Date		: Dec 6, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Data access for Segment Member object
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1863					Dec 6, 2016		1.0					Initial development
 *
 */
public with sharing class REN_SegmentMemberDataAccess {

	private static List<String> readFieldsList = new List<String> {
													REN_Constants.OBJ_SM_ASSET,
													REN_Constants.OBJ_SM_OPPORTUNITY,
													REN_Constants.OBJ_SM_SEGMENT,
													REN_Constants.OBJ_SM_SEGMENT_PRIMARY_CONTACT
			    								};
	
	private static List<String> writeFieldsList = new List<String> {
													REN_Constants.OBJ_SM_ASSET,
													REN_Constants.OBJ_SM_OPPORTUNITY,
													//REN_Constants.OBJ_SM_SEGMENT,
													REN_Constants.OBJ_SM_SEGMENT_PRIMARY_CONTACT
			    								};	    								
	
	/*
	** @Description: Get segment members by segments
	** @Param segmentIds: List of segment members
	*/
	public static List<REN_Segment_Member__c> getMembersBySegmentIds(Set<String> segmentIds) {
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SEGMENT_MEMBER, readFieldsList, CSM_Constants.DML_OPERATION_READ);
        
        return [SELECT REN_Asset__c, REN_Opportunity__c, REN_Segment__c, REN_Segment_Primary_Contact__c FROM REN_Segment_Member__c WHERE REN_Segment__c IN :segmentIds];
	}	

	/*
	** @Description: Insert segment members
	** @Param segmentMembers: Segment member objects to be inserted
	*/
	public static List<REN_Segment_Member__c> insertSegmentMembers(List<REN_Segment_Member__c> segmentMembers) {
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SEGMENT_MEMBER, writeFieldsList, CSM_Constants.DML_OPERATION_INSERT);
		insert segmentMembers;
		return segmentMembers;
	}

	public static List<REN_Segment_Member__c> getSegmentMembersForClause(String whereClause){
     	Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ASSETS);
		String soql = 'Select Id,REN_Opportunity__r.Name, REN_Opportunity__r.StageName ,REN_Opportunity__r.Account.Name,FORMAT(REN_Opportunity__r.CloseDate),REN_Opportunity__r.Owner.Name,'+
            		  'REN_Asset__r.Name, REN_Asset__r.Product2.Name, REN_Asset__r.Contact.Name,REN_Asset__r.Account.Name,' +(UserInfo.isMultiCurrencyOrganization()?'convertCurrency(REN_Opportunity__r.REN_Renewal_Target__c),convertCurrency(REN_Asset__r.price),':'format(REN_Opportunity__r.REN_Renewal_Target__c),format(REN_Asset__r.price),')+
            		  'FORMAT(REN_Asset__r.REN_Start_Date__c),FORMAT(REN_Asset__r.REN_End_Date__c),REN_Segment_Primary_Contact__r.Name';
		if(UserInfo.isMultiCurrencyOrganization()){
			soql += ', CurrencyIsoCode';
		}
		if(CSM_AccessController.hasField('REN_Segment_Member__c',CHL_Util.quoteExtnNameSpace + 'REN_SyncedQuote_Id__c')){
			soql += ',' + CHL_Util.quoteExtnNameSpace + 'REN_SyncedQuote_Id__c' + ',' +CHL_Util.quoteExtnNameSpace + 'REN_SyncedQuote_Id__r.Name';
		}
		whereClause = (String.isBlank(whereClause) ? ' WHERE ID != null ' : whereClause) + ' AND (REN_Opportunity__c != null OR REN_Asset__c != null)';
		soql += ' From REN_Segment_Member__c ' + whereClause  + ' LIMIT ' + limitVal;
		system.debug('soql : ' + soql);
		List<REN_Segment_Member__c> SegMemList = Database.query(soql);	
		//system.debug('SegMemList'+SegMemList);
    	return SegMemList;
	}
 
	public static void deletesegmember(List<REN_Segment_Member__c> segmemberDelete){
        List<String> noAccessList = CSM_AccessController.getInstance(
            ).returnNoPermissionFieldsNameList('REN_Segment_Member__c',
            CSM_Constants.DML_OPERATION_DELETE, null);
        
        //No need to check if access list is empty.  If user cannot delete then exception will be thrown
        delete segmemberDelete;
    }
}