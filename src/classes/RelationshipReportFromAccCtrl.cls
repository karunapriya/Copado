public with sharing class RelationshipReportFromAccCtrl {
	private List<Account> accList {get;set;}
    private Account acc {get;set;}
	public RelationshipReportFromAccCtrl(ApexPages.StandardController controller) {
		acc = (Account) controller.getRecord();
		accList = new List<Account> ([Select id,ParentId from Account where ParentId =: acc.Id OR id=:acc.id]);
	}   
  
	public PageReference getRedirect() {   
		pageReference pageRef;
		try {
				List<Report> reportList = [SELECT Id FROM Report where name = 'Relationship Report'];
				Report reportDetail = reportList[0];
				String newURL = '/' + reportDetail.id + '?pc1=ACCOUNT_ID&pn1=eq&pv1=';
				
				for(Integer i=0; i< accList.size(); i++){
					if(accList[i].id == acc.id){
						if(accList[i].parentId != Null){
							newURL += accList[i].parentId + ',';
						}
					}
					newURL += accList[i].id + ',';
				}
				newURL = newURL.removeEnd(',');
				pageRef = new PageReference(newURL) ;

		}catch(Exception e){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' +System.Label.MSG_NO_ACCESS);
			ApexPages.addMessage(myMsg);
			return  pageRef=null;
		}
    	return pageRef.setRedirect(true);
   }
}