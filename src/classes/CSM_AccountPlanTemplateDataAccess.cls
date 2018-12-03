public with sharing class CSM_AccountPlanTemplateDataAccess {
    

    public static CSM_Account_Plan_Template__c populateAccountPlanTemplateInformation(String templateId) {
        CSM_Account_Plan_Template__c accountPlanTemplate = new CSM_Account_Plan_Template__c();
        try {
            if(templateId != null)
            {
                
                List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_ID, CSM_Constants.OBJ_APT_NAME, CSM_Constants.OBJ_APT_DISPLAY_NAME,CSM_Constants.OBJ_APT_ISACTIVE,CSM_Constants.OBJ_APT_CURRENCY_CODE,CSM_Constants.OBJ_APT_USEAS_SCOUT_DEF};
                
                CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
                
                    List<CSM_Account_Plan_Template__c> tList = new List<CSM_Account_Plan_Template__c>();
                    tList = [select id, 
                                    name, 
                                    CSM_Template_Name__c,
                                    CSM_isActive__c,CSM_Opp_Dates_TimeLines__c,CSM_Opp_Date__c,CSM_Currency_Code__c,CSM_UseasScout_Default_Template__c,
                                    CreatedById, LastModifiedById
                               from CSM_Account_Plan_Template__c 
                              where id = :templateId limit 1];
                    if(!tList.isEmpty())
                    {
                        accountPlanTemplate = tList[0];
                    }
            }
                
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
            
        }
        return accountPlanTemplate;
    }
    
    public static List<CSM_Account_Plan_Template__c> populateAccountPlanTemplateInformation() {
        List<CSM_Account_Plan_Template__c> accountPlanTemplateList = new List<CSM_Account_Plan_Template__c>();
        try {
            List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_ID, CSM_Constants.OBJ_APT_NAME, CSM_Constants.OBJ_APT_DISPLAY_NAME, CSM_Constants.OBJ_APT_ISACTIVE,
            											CSM_Constants.OBJ_APT_PHASE_COUNT, CSM_Constants.OBJ_APT_ACT_IND_CNT};
                                                                                                    
           	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
                                                                                                    
            List<String> appFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_PLAYBOOK};
                                                                                                   
            CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, appFieldList, CSM_Constants.DML_OPERATION_READ);
            
            List<String> playbookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED};
                                                                                                   
           	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOK, playbookFieldList, CSM_Constants.DML_OPERATION_READ);
                                                                                                    
                        accountPlanTemplateList = [select id, 
                                                          name, 
                                                          CSM_Template_Name__c, 
                                                          CSM_isActive__c,
                                                          CSM_Phase_Count__c,
	                                    				  CSM_Active_Indicators_Count__c,
	                                    				  CreatedDate,
	                                    				  CreatedBy.Name, 
	                                    				  LastModifiedDate, 
	                                    				  LastModifiedBy.Name,
                                                          (Select Id, CSM_Playbook__r.CSM_Automated__c 
                                                            From Account_Plan_Playbooks__r  where csm_account_plan__c = null Limit 1000)
                                                     from CSM_Account_Plan_Template__c limit 2000];
            
                
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
            
        }
        return accountPlanTemplateList;
    }
    
    public static boolean updateTemplateAvailable() {
        try {
            List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_ISACTIVE,CSM_Constants.OBJ_APT_DISPLAY_NAME};
            List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APT,
                        CSM_Constants.DML_OPERATION_UPDATE, fcFieldList);
                     
            if(noAccessList.isEmpty())
            {
                return true;
            }
            else
            {
                String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCG + ':'+String.valueOf(noAccessList)};
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
                    System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE + ' ' + arguments));
                return false;
            }
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
            return false;
        }
    }
    public static boolean createTemplateAvailable() {
        try {
            List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_ISACTIVE,CSM_Constants.OBJ_APT_DISPLAY_NAME};
            List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APT,
                        CSM_Constants.DML_OPERATION_INSERT, fcFieldList);
            if(noAccessList.isEmpty())
            {
                return true;
            }
            else
            {
                String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCG + ':'+String.valueOf(noAccessList)};
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
                System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE + ' ' + arguments));
                return false;
            }
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
            return false;
        }
    }
    
    public static List<CSM_Account_Plan_Template__c> saveTemplate(List<CSM_Account_Plan_Template__c> accountPlanTemplatesToSave)
    {
        
        List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_ISACTIVE,CSM_Constants.OBJ_APT_DISPLAY_NAME,CSM_Constants.OBJ_APT_USEAS_SCOUT_DEF};
                  
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        
            upsert accountPlanTemplatesToSave;          
        
        return accountPlanTemplatesToSave;
    }
    
    public static List<CSM_Account_Plan_Template__c> getTemplateByName() {
        List<CSM_Account_Plan_Template__c> tList = new List<CSM_Account_Plan_Template__c>();
        try {
                
            List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_ID, CSM_Constants.OBJ_APT_DISPLAY_NAME, CSM_Constants.OBJ_APT_ISACTIVE,CSM_Constants.OBJ_APT_USEAS_SCOUT_DEF};
                                                                           
            CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
            
            
                tList = [SELECT Id, 
                                CSM_Template_Name__c, 
                                CSM_isActive__c
                           FROM CSM_Account_Plan_Template__c
                           WHERE CSM_UseasScout_Default_Template__c = true LIMIT 1];
            
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
            
        }
        return tList;
    }
    
    
    /*Added for US320 to get the success plan names and count to which the to be deleted SP template belongs to*/   
    public static List<SObject> getAllSuccessPlansforSPTemplates(String templateId) 
    {

        List<String> apFieldList = new List<String>{CSM_Constants.OBJ_AP_ACCOUNT_PLAN_TEMPLATE,CSM_Constants.OBJ_AP_DISPLAY_NAME};
        //List<String> acFieldList = new List<String>{CSM_Constants.OBJ_A_NAME}; 
           
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, apFieldList, CSM_Constants.DML_OPERATION_READ);
        
        //List<String> acnoAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_ACCOUNT,
        //    CSM_Constants.DML_OPERATION_READ, acFieldList);   
        
        List<SObject> successPlans;
        
            //if (acnoAccessList.isEmpty()){
                successPlans= [Select CSM_DisplayName__c From CSM_Account_Plan__c where CSM_Account_Plan_Template__c =: templateId];            
            //}
            //else {
            //  String[] arguments = new String[] {CSM_Constants.OBJ_ACCOUNT + ':'+String.valueOf(acnoAccessList)};
            //   throw new CSM_AccessController.AccessControlDmlException( String.format(
            //   System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
            //}
       
        //System.Debug('GroupList - ' + tmpGroups[0].getSObject('CSM_Focus_Category_Column__r').get('CSM_Focus_Category_Group__c'));
        return successPlans; 
    }
    
    
    /*public static void deleteSPTemplate(CSM_Account_Plan_Template__c successPlanTemplate) 
    {
    	
    }*/
    
    /*Added for US320 to delete the Success Plan Template*/
    public static void deleteSPTemplate(List<CSM_Account_Plan_Template__c> successPlanTemplateList) 
    {
        System.Savepoint sp;
        try{
            //List<CSM_Account_Plan_Template__c> successPlanTemplateList = new List<CSM_Account_Plan_Template__c>();
            //successPlanTemplateList.add(successPlanTemplate);
            List<CSM_Account_Plan_Playbook__c> successPlanPlaybooks = new List<CSM_Account_Plan_Playbook__c>();
            
            if (successPlanTemplateList != null && !successPlanTemplateList.isEmpty()) {
            	successPlanPlaybooks = getSuccessPlanPlaybookLinks(successPlanTemplateList[0].Id);
            }
            sp = Database.setSavepoint();
                        
            /* Explicitly delete the playbook and success plan template linkages because it is a lookup relation*/
            
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APP, null, CSM_Constants.DML_OPERATION_DELETE);
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APP_ACCT_TEMPLATE, null, CSM_Constants.DML_OPERATION_DELETE);
            delete successPlanPlaybooks;            
            delete successPlanTemplateList;     
        }
        catch (exception ex)
        {
            Database.rollback(sp);          
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }   

    }


    /*Added for US320 to get the playbooks linked to the, to be deleted SP template*/   
    public static List<CSM_Account_Plan_Playbook__c> getSuccessPlanPlaybookLinks(String templateId) 
    {

        List<String> appFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK,CSM_Constants.OBJ_APP_ACCT_TEMPLATE};
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APP, appFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<CSM_Account_Plan_Playbook__c> successPlanPlaybooks;
        
            successPlanPlaybooks= [Select CSM_Playbook__c From CSM_Account_Plan_Playbook__c where CSM_Account_Plan_Template__c =: templateId];
        
        //System.Debug('GroupList - ' + tmpGroups[0].getSObject('CSM_Focus_Category_Column__r').get('CSM_Focus_Category_Group__c'));
        return successPlanPlaybooks; 
    }

    
    public static void cloneTemplate(List<CSM_Account_Plan_Template__c> templateList){
        Map<Id, CSM_Account_Plan_Template__c> currentToCloneTemplateMap = new Map<Id, CSM_Account_Plan_Template__c>();
        if(templateList != null && !templateList.isEmpty()){
            for(CSM_Account_Plan_Template__c foundTemplate : templateList){
                CSM_Account_Plan_Template__c cloneTemplate = foundTemplate.clone(false, true);
                String cloneName = System.label.CSM_ClONE_ACC_PLAN_TEMPLATE_PREFIX + ' ' + cloneTemplate.CSM_Template_Name__c;
                if(cloneName.length() > CSM_Constants.ACCOUNT_PLAN_TEMPLATE_NAME_SIZE){
                    cloneName = cloneName.left(CSM_Constants.ACCOUNT_PLAN_TEMPLATE_NAME_SIZE);
                }
                cloneTemplate.CSM_isActive__c = true;
                cloneTemplate.CSM_Template_Name__c = cloneName;
                currentToCloneTemplateMap.put(foundTemplate.Id, cloneTemplate);
            }
            saveTemplate(currentToCloneTemplateMap.values());
            Map<Id, Id> templateToCloneIdMap = new Map<Id, Id>();
            for(Id templateId : currentToCloneTemplateMap.keySet()){
                CSM_Account_Plan_Template__c cloneTemplate = currentToCloneTemplateMap.get(templateId);
                if(cloneTemplate != null){
                    templateToCloneIdMap.put(templateId, cloneTemplate.Id);
                }
            }
            if(!templateToCloneIdMap.isEmpty()){
                CSM_AcctPlanTemplatePlaybooksDataAccess.cloneAccountPlanPlayBooks(templateToCloneIdMap);
                if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){
                    CSM_AcctPlanTemplateIndicatorDataAccess.cloneAccountPlanTemplateIndicator(templateToCloneIdMap);
                    if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){
                        CSM_AccountPlanTemplatePhasesDataAccess.cloneAccountPlanTemplatePhase(templateToCloneIdMap);
                    }
                }
            }
        }
    }
    
    
    public static String getIndicatorCurrencyCode(String templateId) {
        String currencyCode = '';
        try {
            if(templateId != null)
            {
                
                List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APT_CURRENCY_CODE};
                
                CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
                
                
                    List<CSM_Account_Plan_Template__c> tList = new List<CSM_Account_Plan_Template__c>();
                    tList = [select CSM_Currency_Code__c
                               from CSM_Account_Plan_Template__c 
                              where id = :templateId limit 1];
                    if(!tList.isEmpty())
                    {
                        currencyCode = tList[0].CSM_Currency_Code__c;
                    }
                
            }
                
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
            
        }
        return currencyCode;
    }
    
    public static Map<ID, CSM_Account_Plan_Template__c> getTemplateWithPhasesMap(Set<ID> templateIdSet)
    {
    	List<String> aptFieldList = new List<String>{CSM_Constants.OBJ_APT_ID, CSM_Constants.OBJ_APT_NAME};
    	List<String> appFieldList = new List<String>{CSM_Constants.OBJ_APPH_NAME, CSM_Constants.OBJ_APPH_LENGTH,
    		                        CSM_Constants.OBJ_APPH_ORDER, CSM_Constants.OBJ_APPH_PHASE_NAME}; 
    	
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, aptFieldList, CSM_Constants.DML_OPERATION_READ);
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APPH, appFieldList, CSM_Constants.DML_OPERATION_READ);
    	
        return new Map<ID, CSM_Account_Plan_Template__c>(
	        [Select c.Name, c.Id, (Select name, CSM_Length__c, CSM_Order__c, CSM_Phase_Name__c 
	                                 From Account_Plan_Phases__r 
	                             order by CSM_Order__c) From CSM_Account_Plan_Template__c c where ID in :templateIdSet limit 100]);	
    }
    
    /*public static CSM_Account_Plan_Template__c getTemplateForAssignment(string templateId)
    {
    	List<String> aptFieldList = new List<String>{CSM_Constants.OBJ_APT_ID, CSM_Constants.OBJ_APT_DISPLAY_NAME};
    	
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, aptFieldList, CSM_Constants.DML_OPERATION_READ);
    	
        CSM_Account_Plan_Template__c acctPlanTemplate =   [select Id, CSM_Template_Name__c, CreatedById, LastModifiedById from CSM_Account_Plan_Template__c c where ID = :templateId];
        return 	acctPlanTemplate;
    }*/
    
     public static List<CSM_Account_Plan_Template__c> insertTemplate(List<CSM_Account_Plan_Template__c> accountPlanTemplatesToSave)
    {
        List<String> aptFieldList = new List<String>{CSM_Constants.OBJ_APT_DISPLAY_NAME, 
        	CSM_Constants.OBJ_APT_ISACTIVE, CSM_Constants.OBJ_APT_USEAS_SCOUT_DEF};
                  
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APT, aptFieldList, CSM_Constants.DML_OPERATION_INSERT);
        
        insert accountPlanTemplatesToSave;          
        
        return accountPlanTemplatesToSave;
    }
}