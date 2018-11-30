public with sharing class REN_EmailRecipientDataAccess {
	/*public static List<REN_Email_Recipient__c> getEmailRecipient(String batchId)
    {  
        List<String> fcFieldList = new List<String>{REN_CONSTANTS.REN_RECIP,REN_CONSTANTS.REN_USER,REN_CONSTANTS.REN_EMAIL_RECIP};
              
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_EMAIL_RECIP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
        //REN_Email_Recipient__c emailRecipient = new REN_Email_Recipient__c();
        List<REN_Email_Recipient__c> emailRep = new List<REN_Email_Recipient__c>();
        
            if(!String.isEmpty(batchId))
    		{
    		
          	emailRep = [select  Id,
          						REN_Batch__c,
          						REN_Recipient__c,
          						REN_User__c
          					from REN_Email_Recipient__c
          					where REN_Batch__c = :batchId limit 1];
    		}
        
        return emailRep;
    }*/
    
    public static List<REN_Email_Recipient__c> getEmailRecipients(String batchId){
    	
    	List< REN_Email_Recipient__c > emailRecepientList = new List< REN_Email_Recipient__c >();
    	CSM_UTIL.checkCRUD_FLS(REN_CONSTANTS.OBJ_EMAIL_RECIP,new List<String>{'REN_Recipient__c'},CSM_Constants.DML_OPERATION_READ);
    	if(!String.isEmpty(batchId))
    	{
			emailRecepientList = [Select REN_Recipient__c FROM REN_Email_Recipient__c WHERE REN_Batch__c = : batchId];
    	}
		
		return emailRecepientList;
    }
    
    public static List<REN_Email_Recipient__c> saveEmailRecip(List<REN_Email_Recipient__c> emailRecip)
    {
        
        List<String> fcFieldList = new List<String>{REN_CONSTANTS.REN_RECIP,REN_CONSTANTS.REN_USER,REN_CONSTANTS.REN_EMAIL_RECIP};         
      	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_EMAIL_RECIP, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        
        upsert emailRecip;          
        
        return emailRecip;
    }
    
    public static List<SObject> getUsers(String batchId)
    {
    	List<User> selectedEmailReps = new List<User>();
    	List<String> fcFieldList = new List<String>{REN_CONSTANTS.REN_RECIP,REN_CONSTANTS.REN_USER,REN_CONSTANTS.REN_EMAIL_RECIP};
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_EMAIL_RECIP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
    	
    		if(!String.isEmpty(batchId))
    		{
    			selectedEmailReps = [select id, 
    										name, 
    										email 
    								from user 
    								where id IN (select REN_User__c from REN_Email_Recipient__c where REN_Batch__c = :batchId)];
        	}
    	
        return selectedEmailReps;
    }
    
    public static Boolean deleteEmailRecip(List<User> emailRecip, String batchId)
    {
        List<REN_Email_Recipient__c> emailRep = new List<REN_Email_Recipient__c>();
        List<String> fcFieldList = new List<String>{REN_CONSTANTS.REN_RECIP,REN_CONSTANTS.REN_USER,REN_CONSTANTS.REN_EMAIL_RECIP};        
       	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_EMAIL_RECIP, fcFieldList, CSM_Constants.DML_OPERATION_DELETE);
        
        	REN_Email_Recipient__c emailRepRecord = new REN_Email_Recipient__c();
        	for(User recipients : emailRecip)
        	{
        		emailRepRecord = [select Id 
        						from REN_Email_Recipient__c 
        						where REN_User__c IN (SELECT ID FROM USER WHERE ID = :recipients.ID) and REN_Batch__c = :batchId LIMIT 1];
        		emailRep.add(emailRepRecord);
        	}
        	delete emailRep;
        	return true;
    }
    
    public static List<User> getAllUsersForSelection()
    {
    	List<User> selectedEmailReps = new List<User>();
    	List<String> fcFieldList = new List<String>{CSM_CONSTANTS.OBJ_FCC_ID,CSM_CONSTANTS.OBJ_FCC_NAME,CSM_CONSTANTS.CSM_EMAIL};
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_USER, fcFieldList, CSM_Constants.DML_OPERATION_READ);
    	
    			selectedEmailReps = [select id, 
    										name, 
    										email 
    								from user where IsActive = true limit 10000];
    	
        return selectedEmailReps;
    }
    
    public static List<User> getUser(Id userId)
    {
    	List<User> selectedEmailReps = new List<User>();
    	List<String> fcFieldList = new List<String>{CSM_CONSTANTS.OBJ_FCC_ID,CSM_CONSTANTS.OBJ_FCC_NAME,CSM_CONSTANTS.CSM_EMAIL};
        
       	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_USER, fcFieldList, CSM_Constants.DML_OPERATION_READ);
    	
    	
    			selectedEmailReps = [select id, 
    										name, 
    										email 
    								from user where id = :userId];
    	
        return selectedEmailReps;
    }
}