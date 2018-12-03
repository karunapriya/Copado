/**
 * Created Date     : Oct 30, 2016
 * Developed By     : Sheetal, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Sheetal                    User Story              Oct 30, 2016            1.1                 @description
 *
 */
public with sharing class CHL_SetPrimaryOnQuoteExtnController {

    

    /**
     * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
    private ApexPages.StandardController stdController  { get; set; }
    public SObject quoteRecord {get;set;}
    public Set<Id> quoteRecordIds {get; set;}
    public boolean isError{get;set;}
    public CHL_SetPrimaryOnQuoteExtnController(ApexPages.StandardController stdController) {
        isError = false;
        this.stdController = stdController;
        this.quoteRecord = this.stdController.getRecord();
        quoteRecordIds = new Set<Id>();
        quoteRecordIds.add(this.quoteRecord.id);
    }
    public PageReference saveAndReturn()
    {
    	Savepoint sp = Database.setSavepoint();
        try {
        	CSM_TriggerManager.disableAllTriggers();
            BasePackageParam params = new BasePackageParam();
            params.sObjIds = quoteRecordIds;
            params.className = 'CHL_QuoteExtension';
            params.methodName = 'markPrimaryQuote';
            SS_BasePackageAccess.getInstance().paramJson = JSON.serialize(params);
            SS_BasePackageAccess.getInstance().invoke();
            PageReference parentPage = new PageReference('/' + this.quoteRecord.id);
            parentPage.setRedirect(true);
            return parentPage;
        } catch(Exception ex) {
            isError = true;
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
         }
    }
    
    public class BasePackageParam {
        public Set<Id> sObjIds;
        public String className;
        public String methodName;
    }
}