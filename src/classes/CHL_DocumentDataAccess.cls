/**
 * Created Date		: Apr 23, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Data access for Document object SOQL and DML
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					US3249				Apr 23, 2018			1.1					@description
 *
 */
public with sharing class CHL_DocumentDataAccess {

 	public static List<Document> getQuoteTemplate() {
 		List<String> docFieldList = new List<String>{'Id','Name','ContentType','Type','body'};
		CSM_Util.checkCRUD_FLS('Document', docFieldList, CSM_Constants.DML_OPERATION_READ);
        return [select id, Name, ContentType, Type,body from Document Where Name = 'QuoteTemplate'];
    }
    public static void upsertDocument(List<Document> docList){
    	List<String> docFieldList = new List<String>{'Id','Name','ContentType','Type','AuthorId','FolderId','body'};
		CSM_Util.checkCRUD_FLS('Document', docFieldList, CSM_Constants.DML_OPERATION_UPSERT);
    	upsert docList;   	
    }
    public static List<Folder> getFolder() {
 		List<String> docFieldList = new List<String>{'Id','name'};
		CSM_Util.checkCRUD_FLS('Folder', docFieldList, CSM_Constants.DML_OPERATION_READ);
        return [select id from Folder Where Name = 'Service Source'];
    }
}