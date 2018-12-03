public with sharing class CaseCreationFromOppCtrl {
    
    private Opportunity oppDetail {get; set;}
    private Contact conDetail {get;set;}
	
    public CaseCreationFromOppCtrl(ApexPages.StandardController controller) {
    	Opportunity op = (Opportunity )controller.getRecord();
        List<Opportunity> oppList = OpportunityDataAccess.getOpportunityListById(new Set<String>{op.id});
        oppDetail = oppList[0];	           
    }   
   
    public PageReference getRedirect() {   	
    	pageReference pageRef;
    	try{
    		Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
    		List<Contact> contactDetail = ContactDataAccess.getContactBySystemUserReference(new Set<String>{UserInfo.getUserID()});
    		if(contactDetail.size() > 0){
		        conDetail = contactDetail[0];
				pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&cancelURL=' + oppDetail.get('id') +
				          '&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo' + '&'+
		            	  ZS.Case_Opportunity_LKID__c +'_lkid=' + oppDetail.get('id') + 
		            	  '&CF' + ZS.Case_Opportunity_LKID__c+ '=' +oppDetail.get('Name') +
		            	  '&cas4_lkid='+ oppDetail.get('AccountId') +
		             	  '&cas3_lkid='+conDetail.get('id') + 
		            	  '&cas3='+ conDetail.get('Name')
		            	  );
		            	  
    		}
    		else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,System.Label.LBL_CONTACT_NOT_VALID));
    		}
    	}catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e.getMessage());
            ApexPages.addMessage(myMsg);
            return  pageRef=null;
        }
            	
        return pageRef;//.setRedirect(true);
    }
}