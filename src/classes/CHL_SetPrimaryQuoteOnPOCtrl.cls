/**
 * Created Date		: Feb 2, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This page will show all the quotes records in a grid related to Partner Opportunity.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2049					Feb 2, 2017		1.1					Created in Sprint705
 *
 */
public with sharing class CHL_SetPrimaryQuoteOnPOCtrl {
     public String ptnrOpptyId {get;set;}
     public CSM_DataGridAttribute quoteGridAttribute{get;set;}
     public String recordId{get;set;}
	 public CHL_SetPrimaryQuoteOnPOCtrl() {
         ptnrOpptyId = ApexPages.currentPage().getParameters().get('Id');   
         system.debug('\n ptnrOpptyId::'+ptnrOpptyId);
         setGridAttributes();
    }
    
    private void setGridAttributes()
    {
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
        quoteGridAttribute = new CSM_DataGridAttribute();
        quoteGridAttribute.tableName = CHL_Constants.QUOTE_ON_PO;
    	quoteGridAttribute.objectType = CHL_Constants.QUOTE_ON_PO_OBJ;
    	quoteGridAttribute.viewName = CHL_Constants.QUOTE_ON_PO;
    	quoteGridAttribute.gridSize=25;
    	quoteGridAttribute.gridToolBarId = CSM_Constants.GRID_ATTR_TOOLBAR;
        quoteGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
        //quoteGridAttribute.stateSave=CSM_Constants.GRID_ATTR_FALSE;
        quoteGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
        quoteGridAttribute.showExport=CSM_Constants.GRID_ATTR_FALSE;
        quoteGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
        
        gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.opptyId = ptnrOpptyId;
     	quoteGridAttribute.params = JSON.serialize(gridInputParams);
     	
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
        quoteGridAttribute.userDateFormat = localeMap.get(userInfo.getLocale());
        
    }
    
    public PageReference setPrimaryQuote() {
    	Savepoint sp = Database.setSavepoint();
        pagereference detailPage = null;
    	try {
    		CSM_TriggerManager.disableAllTriggers();
	    	system.debug('\n\n RecordId::'+recordId);
	 		Set<Id> quoteIds = new Set<Id>();
	 		quoteIds.add((Id)recordId);
	    	List<SObject> quoteList = CHL_QuoteDataAccess.getSyncedQuotesById(quoteIds);
	    	Set<Id> poIdSet = new Set<Id>();
	    		
	    	if(quoteList != null && quoteList.size() == 1) {
	    		if(((Boolean)quoteList[0].get(CHL_Util.quoteExtnNameSpace +'CHL_Partner_Primary__c'))!= true) {
	    			//quoteList[0].put(CHL_Util.quoteExtnNameSpace +'CHL_Partner_Primary__c',true);
	    			poIdSet.add((Id)quoteList[0].get(CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c'));
	    		} else {
	    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.CHL_ERR_PRIMARY_QUOTE));
	    		}
	    		CHL_QuoteSyncHandler.handleQuotePrimary(quoteList, poIdSet);    	
    			CHL_QuoteExtension.handlePOUpdationFromQuote(poIdSet);
	    	}
	    	system.debug('\n\n quoteList::'+quoteList);
	    	if(!ApexPages.hasMessages()) {
	    		//PageReference pageRef = new PageReference('/'+ptnrOpptyId);
	    		detailPage = new PageReference('/' + ptnrOpptyId);
	    		//return pageRef;
	    	} else {
	    		Database.rollback(sp);
	    		//return null;
	    	}
    	} catch (Exception ex) {
    		Database.rollback(sp);
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
    		ApexPages.addMessage(msg);
    		//return null;
    	}
    	return detailPage;
    }
    
    public PageReference returnURL() {
    	PageReference pageRef = new PageReference('/'+ptnrOpptyId);
    	return PageRef;		
    }
}