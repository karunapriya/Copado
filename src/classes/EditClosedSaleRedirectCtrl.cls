public with sharing class EditClosedSaleRedirectCtrl {
    private String oppId;
	public EditClosedSaleRedirectCtrl(ApexPages.standardController standardController) {
    	oppId = ApexPages.currentPage().getParameters().get('Id');
	}
    
    public PageReference returnPage(){
        String returnpage = '/apex/REN_EditClosedSaleOppty?id=' + oppId;
        Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity where Id =: oppId limit 1];
        if(opp != null){
            returnpage += (opp.StageName == 'Closed Sale') ? '&stageValid=true' : '&stageValid=false';
        }
        return (new PageReference(returnpage));
    }
}