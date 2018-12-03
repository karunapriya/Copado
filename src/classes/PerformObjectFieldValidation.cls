Public with sharing  class PerformObjectFieldValidation{
            
    private ObjectFieldValidationDataAccess dataAccess;
    String solnExtnNamespace;
    private set<String> missingFields;
    Set<String> mFields;
    String objName;
    Map<String, Schema.sObjectField> mapOfSObjectFields;
    String endOfErrorMsg='';
 //   String label = Label.Field_Cannot_Update;
    public PerformObjectFieldValidation(){
        dataAccess = new ObjectFieldValidationDataAccess();
        solnExtnNamespace =  Util.solnExtnNameSpace;
        missingFields = new Set<String>();
        mFields = new Set<String>();
        ObjName = '';
        endOfErrorMsg ='Opportunity is Closed/Won'; 
    }
    
    public PerformObjectFieldValidation(Set<String> fieldSet){
    	this();
        missingFields = new Set<String>();
        mFields = fieldSet;
        objName= 'Case';
        endOfErrorMsg = 'Case is created';
        mapOfSObjectFields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    }
    
     public boolean validateObjectFields(String sObjectName){
        objName = sObjectName;
        boolean flag = true;
        mapOfSObjectFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        List<Object_Field_Validation__c> listOfObj = dataAccess.getRecordsByObjectName(sObjectName);
        if(listOfObj != null && listOfObj.size()>0){
            for(Object_Field_Validation__c obj: listOfObj){
                if(!mapOfSObjectFields.containsKey(obj.Field_API_Name__c.toLowerCase())){
                	 flag = false;
                	 // we will continue to cought out all missing fields.
                     missingFields.add(obj.Field_API_Name__c.toLowerCase());
                }else{
                	 mFields.add(mapOfSObjectFields.get(obj.Field_API_Name__c.toLowerCase()).getDescribe().getName());
                }
            }
        }
        return flag;    
    }

    
    public set<String> getMissingFields(){                
        return missingFields;
    }
    
    // List of objects those related Opportunity marked as won
    public void checkForValidUpdate(List<sObject> newObject, Map<id,sObject> oldMap){
        for(sObject newObj: newObject){
           // flagAddErrorMsg = false;
            //allInvalidFieldsToUpdate ='';
            checkObjectFieldValidation(newObj, oldMap.get(newObj.id));
        }
    }
    // Pass old and new Objects for which related Opportunity marked as won
     public boolean checkObjectFieldValidation(sObject newObj, sObject oldObj){
        boolean flagAddErrorMsg = false;
        String allInvalidFieldsToUpdate ='';
        for(String fieldToCheck: mFields){
        	System.debug(fieldToCheck + '\n~~~~: fieldToCheck : ');                  
			if(newObj.get(fieldToCheck) != oldObj.get(fieldToCheck)){
            	flagAddErrorMsg = true;
            	if(mapOfSObjectFields.containsKey(fieldToCheck)){
                	DescribeFieldResult descField = mapOfSObjectFields.get(fieldToCheck).getDescribe();
                	if(descField != null){
                		String fieldLbl = descField.getLabel();
                		if(fieldToCheck.endsWithIgnoreCase('Id') && fieldLbl.endsWithIgnoreCase(' Id')){
                			allInvalidFieldsToUpdate +=  fieldLbl.subString(0,fieldLbl.length()-3) +', ';
                		}else{
                			allInvalidFieldsToUpdate +=  fieldLbl +', ';
                		}
                	}else{
                		allInvalidFieldsToUpdate +=  fieldToCheck +', ';
                	}
                }else{
                	allInvalidFieldsToUpdate +=  fieldToCheck +', ';
                }
            }	        
        }
        if(flagAddErrorMsg){
             allInvalidFieldsToUpdate = allInvalidFieldsToUpdate.subString(0,allInvalidFieldsToUpdate.length()-2);
             newObj.addError(String.format(System.Label.Field_cannot_be_updated, new List<String>{allInvalidFieldsToUpdate, Schema.getGlobalDescribe().get(objName).getDescribe().getLabel(), endOfErrorMsg})); 
        }
        return !flagAddErrorMsg;
    }
            
}