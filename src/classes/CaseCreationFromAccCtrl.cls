public with sharing class CaseCreationFromAccCtrl {
 	private Account accDetail {get; set;}
    private Contact conDetail {get;set;}
	
    public CaseCreationFromAccCtrl(ApexPages.StandardController controller) {
		Account acc = (Account) controller.getRecord();
	    List<Account> accList = [Select id,Name from Account where id=: acc.id];
	    accDetail = accList[0];	           
    }   
   	public PageReference getRedirect() {   	
    	pageReference pageRef;
    	try{
    		List<Contact> contactDetail = ContactDataAccess.getContactBySystemUserReference(new Set<String>{UserInfo.getUserID()});
	        if(contactDetail.size()>0) {
	        	conDetail = contactDetail[0];
				pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&cas4_lkid='+accDetail.id+'&cas4='+accDetail.Name+'&cas3_lkid='+conDetail.id+'&cas3='+conDetail.Name+'&cas11=CRM User&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo&cancelURL='+accDetail.id+'');
	        }
	        else{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,System.Label.LBL_CONTACT_NOT_VALID));
	        }
	    }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e.getMessage());
            ApexPages.addMessage(myMsg);
            return  pageRef=null;
        }
        return pageRef;
    }
}