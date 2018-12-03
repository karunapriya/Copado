public with sharing class CHL_NoteDataAccess {
	
	/**
      * @description : This method returns list of notes associated with the partner Opp.
      * @param : Accepts  Partner opportunity ID.    
    */
	public static List<SObject> getNoteListByPartnerOpp(Id partnerOppId) {
		List<String> noteFieldList = new List<String>{CHL_Constants.OBJ_NOTE_BODY};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_NOTE, noteFieldList, CSM_Constants.DML_OPERATION_READ);
		String queryString ='SELECT CreatedById,CreatedDate,Id,Body,CreatedBy.name FROM Note where ParentId =:partnerOppId Order by LastmodifiedDate DESC LIMIT 1000';
		List<Note> noteList = Database.query(queryString);
		return noteList;
	}

	/**
      * @description : This method returns list of caseComments associated with Case.
      * @param : Accepts Case ID.    
    */
	public static List<SObject> getCaseCommentByCaseId(Id caseId) {
		List<String> caseCommentFieldList = new List<String>{CHL_Constants.CASE_CREATED_DATE,CHL_Constants.OBJ_CASECOMM_COMMENTBODY, CHL_Constants.OBJ_CASECOMM_CREATED_BY_ID };
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_CASECOMMENT, caseCommentFieldList, CSM_Constants.DML_OPERATION_READ);
		String queryString ='Select CommentBody, CreatedBy.name, CreatedById, CreatedDate from CaseComment where ParentId =: caseId Order by CreatedDate DESC Limit 1000';
		List<CaseComment> caseCommentList = Database.query(queryString);
		return caseCommentList;
	}
	
	/*public static void insertNotes(List<Note> noteList) {
		List<String> noteFieldList = new List<String>{CHL_Constants.STR_PARENT,'title',CHL_Constants.OBJ_NOTE_BODY};
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_NOTE , noteFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert noteList;
	} */

}