public with sharing class CaseQuoteReviewCtrl {
    public Case thisCase = new Case();
    public List<Quote> quoteList {get; set;}
    public Boolean isEditMode {get; set;}
    public Boolean containQuoteFlag {get; set;}
    private Case mCase = new Case();
    public CaseQuoteReviewCtrl(ApexPages.StandardController controller) {
        thisCase = (Case)controller.getRecord();
        Id currentPageId  = ApexPages.currentPage().getParameters().get('Id');
        initialize();
    }
    
    public void initialize(){
        isEditMode = false;
        quoteList = getRelatedQuote();
    }
    
    public void activateEditMode() {
        isEditMode = true;
    }
    
    public void deactivateEditMode() {
        isEditMode = false;
    }
    
    public void undoChanges() {
        initialize();
    }
    
    public List<Quote> getRelatedQuote(){
        List<Quote> quoteList = new List<Quote>();
        if(thisCase.ParentId!= null){
            quoteList = QuoteDataAccess.getQuoteByCase(new Set<String>{thisCase.ParentId});
        }
        if(quoteList.size() > 0) containQuoteFlag = true;
        return quoteList;
    }
    
    public PageReference saveChanges(){
        Map<Id, Quote> quoteMap = new Map<Id, Quote>(getRelatedQuote());
        List<Quote> quoteToUpdate = new List<Quote>();
       
        for(Quote quo : quoteList){
            if(quo.Review_Status__c != quoteMap.get(quo.Id).Review_Status__c 
                || quo.Error_Category__c != quoteMap.get(quo.Id).Error_Category__c){
                quoteToUpdate.add(quo);
            }
        }
        
        try{
        	//CSM_TriggerManager.disableAllTriggers();
            if(quoteToUpdate.size() > 0) QuoteDataAccess.updateQuoteList(quoteToUpdate);
            
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        
        deactivateEditMode();
        return null;
    }
}