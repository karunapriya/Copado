public with sharing class CaseQuoteToCorrectCtrl {
    
    public Case thisCase = new Case();
    public List<Quote> quoteList {get; set;}
    
    public CaseQuoteToCorrectCtrl(ApexPages.StandardController controller) {
        thisCase = (Case)controller.getRecord();
        quoteList = getQuoteToCorrect();
    }
    
    public List<Quote> getQuoteToCorrect(){
        List<Quote> quoteToCorrectList = new List<Quote>();
        if(thisCase.id != null){
            quoteToCorrectList = QuoteDataAccess.getQuoteListByCaseAndStatus(new Set<String>{thisCase.id}, 'Fail');
        }

        return quoteToCorrectList;
    }
}