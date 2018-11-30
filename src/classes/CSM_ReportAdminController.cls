public with sharing class CSM_ReportAdminController {
    public String helpParam {get; set;}
    public CSM_MSTR__c objType {get; set;}
    public String multiPickListValue {get; set;}
    public List<SelectOption> multiPickLists = new List<SelectOption>();
    public Map<String, Schema.SObjectField> fieldMap;
    
    
    public CSM_ReportAdminController(){
    	helpParam = CSM_Constants.HELP_MULTI_SELECT_REPORTING;
    	fieldMap = new Map<String, Schema.SObjectField>();
    	objType= new CSM_MSTR__c();
    	}
    
    public List<SelectOption> getMultiPickList(){
		   	
    	try{
    		multiPickLists.clear();
	    	Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    		
			if(string.valueOf(objType.CSM_Object_Name__c).equalsIgnoreCase('Activity')){
	        	objType.CSM_Object_Name__c = 'Task';
	        }
			
			Schema.SObjectType ObjectSchema = schemaMap.get(objType.CSM_Object_Name__c);
	        fieldMap = ObjectSchema.getDescribe().fields.getMap();
	        
	        for (String fieldName: fieldMap.keySet()) 
	        {  
	        	Schema.DisplayType FldType= fieldMap.get(fieldName).getDescribe().getType();
	        	String FldLabel= fieldMap.get(fieldName).getDescribe().getLabel();
	        	if(string.valueOf(FldType).equalsIgnoreCase('MULTIPICKLIST'))
	        	{	
	            	multiPickLists.add(new SelectOption(fieldName,FldLabel));
	        	}
	        }		
    	}
    	catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
        return multiPickLists;
    }
    
    public PageReference showMultiPickListValue(){
    	return null;
    }
    
    public PageReference runBatch(){
    	PageReference redirectTo;
    	List<CSM_MSTR__c> insertmasterReportList = new List<CSM_MSTR__c>();
   		List<CSM_MSTR__c> deletemasterReportList = new List<CSM_MSTR__c>();
    	Set<CSM_MSTR__c> presentMasterRecordSet= new Set<CSM_MSTR__c>();
    	Set<String> pickListValuesSet= new Set<String>();
    	Set<String> presentMasterPicklistSet= new Set<String>();
    	CSM_MSTR__c tempObj= new CSM_MSTR__c();
    	
    	try{
    		if(String.isNotBlank(objType.CSM_Object_Name__c) && String.isNotBlank(multiPickListValue) && fieldMap != null && !fieldMap.isEmpty())
		    {
		    	Schema.DescribeFieldResult fieldResult= fieldMap.get(multiPickListValue).getDescribe();
		    	
		    	List<Schema.PicklistEntry> pickListValuesList = fieldResult.getPicklistValues();
		    	
		    	List<CSM_MSTR__c> mstrRecords = CSM_MultiSelectPicklistDataAccess.getMstrRecordsByName(multiPickListValue);
		    	for(CSM_MSTR__c msrt : mstrRecords)
				{
					presentMasterPicklistSet.add(msrt.CSM_Picklist_Value__c);
					presentMasterRecordSet.add(msrt);
				}
		    	
		    	//To create list for records to be inserted in MSTR
		    	for(Schema.PicklistEntry pl: pickListValuesList){
		    		if(!presentMasterPicklistSet.contains(pl.getValue())){
		    			tempObj.CSM_Object_Name__c = objType.CSM_Object_Name__c;
			    		tempObj.CSM_Multi_Picklist_Name__c = fieldResult.getLabel();
			    		tempObj.CSM_Multi_Picklist_API_Name__c = fieldResult.getName().replace(CSM_Util.getNamespace(), '');
			    		tempObj.CSM_Picklist_Value__c = pl.getValue();
			    		insertmasterReportList.add(tempObj);
			    		tempObj = new CSM_MSTR__c();
		    		}
		    		pickListValuesSet.add(pl.getValue());
		    	}
		    	
		    	//To create list for master object records to be deleted which are not in picklist
		    	for(CSM_MSTR__c m: presentMasterRecordSet){
		    		if(!pickListValuesSet.contains(string.valueOf(m.CSM_Picklist_Value__c))){
		    			deletemasterReportList.add(m);
		    		}	
		    	}
		    	
		    	//DML insert
                if(insertmasterReportList!= null || !insertmasterReportList.isEmpty()){
                    CSM_MultiSelectPicklistDataAccess.insertMstrRecords(insertmasterReportList);
                }
               
                //DML delete
                if(deletemasterReportList!= null || !deletemasterReportList.isEmpty()){
                    CSM_MultiSelectPicklistDataAccess.deleteMstrRecords(deletemasterReportList);
                }
		    	
		    	//Batch is called
		    	CSM_MultiSelectPicklistReportHandler.mstrRefreshByBatch(objType.CSM_Object_Name__c,multiPickListValue);
		    	
		    	Schema.DescribeSObjectResult result= CSM_MSTR__c.SObjectType.getDescribe();
		    	redirectTo = new PageReference('/' + result.getKeyPrefix() + '/o');
    		}  	
    	}
    	catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
        
        return redirectTo;
	}
   
}