/**
 * Created Date		: Apr 17, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Upload quote import template to document object
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					US3249				Apr 17, 2018			1.1					Upload quote import template to document object
 *
 */
public with sharing class REN_UploadTemplateCtrl {

    public transient Blob attachFile {get;set;}
    public String contentType { get; set; }
    public String name {get;set;}
    
     public void uploadTemplate(){  
     	try{
     		if(attachFile != null){
     			List<Document> docList = CHL_DocumentDataAccess.getQuoteTemplate();
		     	List<Folder> folderList = CHL_DocumentDataAccess.getFolder();
		     	List<Document> docToUpsert = new List<Document>();
		     	Document doc;
		     	if(docList == null || docList.isEmpty()){
		     		doc = new Document();
		     	}
		     	else{
		     		doc = docList[0];
		     	}
		     	doc.name = 'QuoteTemplate';
		     	doc.body = attachFile;
		     	doc.contentType = contentType;
				doc.Type = name.split('\\.')[1];
		     	doc.AuthorId = UserInfo.getUserId();
		    	doc.FolderId = folderList[0].id;
		    	docToUpsert.add(doc);	
		    	if(docToUpsert != null && !docToUpsert.isEmpty()) {
		    		CHL_DocumentDataAccess.upsertDocument(docToUpsert);
		    		CSM_AdminLinksComponentController.hasTemplate = true;
		    	}
		    	if(!ApexPages.hasMessages(ApexPages.Severity.ERROR))
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, System.Label.REN_LBL_QUOTE_IMPORT_MSG));	
				}    	
     		}		     	
     	}  
     	catch(Exception e){
     		if(attachFile.size() > 5242880){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.REN_LBL_MAX_FILE_SIZE_IMPORT));
			}
			else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
			}
     	}
    }
}