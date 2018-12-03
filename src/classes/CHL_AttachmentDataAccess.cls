public with sharing class CHL_AttachmentDataAccess {
	
	/**
      * @description : This method returns list of Attachments associated to ParentId.
      * @param : Accepts set of IDs 
    */
	public static List<SObject> getAttachmentListByParentId(set<Id> IdSet) {
		return getAttachmentListByParentId(IdSet,false);
	}
	
	public static List<SObject> getAttachmentListByParentId(set<Id> IdSet, boolean bodyRequire) {
		String attColumnString = 'select Id, ParentId, name, LastModifiedBy.name, LastModifiedDate, CreatedBy.name, CreatedDate';
		if(bodyRequire) {
			attColumnString = attColumnString + ',body,contenttype';
		}
		List<String> attFieldList = new List<String>{CHL_Constants.OBJ_PO_NAME, CHL_Constants.STR_PARENT, CHL_Constants.OBJ_ATT_LAST_MODIFIED_DATE};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_ATTACHMENT, attFieldList, CSM_Constants.DML_OPERATION_READ);
		String queryString = attColumnString+' from Attachment where ParentId in:IdSet order by createddate desc limit 1000';
		List<Attachment> attachmentList = Database.query(queryString);
		return attachmentList;
	}
	
	/**
      * @description : This method returns Map of parent Id and its corresponding Attachments associated to that ParentId.
      * @param : Accepts set of parent IDs 
    */
	public static Map<String, SObject> getAttachmentMapByParentId(set<Id> IdSet) {
		Map<String, SObject> attachmentMap = new Map<String, SObject>();
		for(SObject sobj: getAttachmentListByParentId(IdSet)) {
			attachmentMap.put((String)(sobj.get('ParentId')),sobj);
		}
		return attachmentMap;
	}
	
	/*public static List<Attachment> getAttFrmLowDollorClient() {
		return [SELECT Id from Attachment where ParentId in (Select Id from REN_Low_Dollar_Client__c ) order by createddate desc limit 1];
	}*/
	
	//DE2063 - Commented 
	/*public static void saveAttachments(List<Attachment> attLst) {
		List<String> attFieldList = new List<String>{CHL_Constants.OBJ_PO_NAME, CHL_Constants.STR_PARENT, CHL_Constants.OBJ_ATT_LAST_MODIFIED_DATE};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_ATTACHMENT, attFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert attLst;
	} */
}