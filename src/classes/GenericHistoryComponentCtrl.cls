public with sharing class GenericHistoryComponentCtrl {

    // External variables
    public SObject myObject {get; set;}
    public Integer recordLimit {get; set;}
    public static String objectLabel {get;}
    
    // Internal Variables
    public objectHistoryLine[] objectHistory; 
    
    public static final Map<String, Schema.SObjectType> mySObjectTypeMap = Schema.getGlobalDescribe();
    public static Map<String, Schema.SObjectField> myObjectFieldMap;
    public static List<Schema.PicklistEntry> historyFieldPicklistValues;
    
    public List<objectHistoryLine> getObjectHistory() {
    
        Id myObjectId = String.valueOf(myObject.get('Id'));
        Schema.DescribeSObjectResult objectDescription = myObject.getSObjectType().getDescribe();
    
        myObjectFieldMap = objectDescription.fields.getMap();
        objectLabel = String.valueOf(objectDescription.getLabel());
    
        //Get the name of thew history table
        String objectHistoryTableName = objectDescription.getName();
        //if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name
        if(objectDescription.isCustom()) {
            objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
        }
        objectHistoryTableName = objectHistoryTableName + 'History';
    
        Schema.DescribeFieldResult objectHistoryFieldField = mySObjectTypeMap.get(objectHistoryTableName).getDescribe().fields.getMap().get('Field').getDescribe();
        historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();
    
        List<objectHistoryLine> objectHistory = new List<objectHistoryLine>();
        String prevDate = '';
    
        if(recordLimit== null){
            recordLimit = 100;
        }
        List<sObject> historyList = DynamicObjectDataAccess.getHistoryByTableNameAndParent(objectHistoryTableName, myObjectId, recordLimit);
    
        for(Integer i = 0; i < historyList.size(); i++) {
            sObject historyLine = historyList.get(i);
            if((historyLine.get('newValue') == null && historyLine.get('oldValue') == null) 
                || (historyLine.get('newValue') != null && !(string.valueOf(historyLine.get('newValue')).startsWith('005') || string.valueOf(historyLine.get('newValue')).startsWith('00G')))
                || (historyLine.get('oldValue') != null && !(string.valueOf(historyLine.get('oldValue')).startsWith('005') || string.valueOf(historyLine.get('oldValue')).startsWith('00G')))) {
                objectHistoryLine tempHistory = new objectHistoryLine();
        
                if(String.valueOf(historyLine.get('CreatedDate')) != prevDate) {
                    tempHistory.theDate = String.valueOf(historyLine.get('CreatedDate'));
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                    tempHistory.who = String.valueOf(historyLine.get('CreatedById'));
                }
                else {
                    tempHistory.theDate = '';
                    tempHistory.who = '';
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                }
                
                prevDate = String.valueOf(historyLine.get('CreatedDate'));
                String fieldLabel = GenericHistoryComponentCtrl.returnFieldLabel(String.valueOf(historyLine.get('Field')));

                if(String.valueOf(historyLine.get('Field')) == 'created') {
                    tempHistory.action = 'Created.';
                }
                else if(historyLine.get('oldValue') != null && historyLine.get('newValue') == null) {
                    try {
                        tempHistory.action = tempHistory.action = 'Deleted ' + Date.valueOf(historyLine.get('oldValue')).format() + ' in ';
                     	tempHistory.actionFieldLabel = fieldLabel;
                     	tempHistory.isDeleted = true;
                    }
                    catch (Exception e){
                        tempHistory.action = 'Deleted ' + String.valueOf(historyLine.get('oldValue')) + ' in ';
                        tempHistory.actionFieldLabel =  fieldLabel;
                        tempHistory.isDeleted = true;
                    }
                }
                else{
                    String fromText = '';
                    if(historyLine.get('oldValue') != null) {
                        try {
                            fromText = ' from ' + Date.valueOf(historyLine.get('oldValue')).format();
                        }
                        catch(Exception e) {
                            fromText = ' from ' + String.valueOf(historyLine.get('oldValue'));
                        }
                    }
    
                    String toText = '';
                    if(historyLine.get('oldValue') != null) {
                        try {
                            toText = Date.valueOf(historyLine.get('newValue')).format();
                        }
                        catch(Exception e) {
                            toText = String.valueOf(historyLine.get('newValue'));
                        }
                    }
                
                    if(toText != '') {
                        tempHistory.action = 'Changed ';
                        tempHistory.changeBold1 = fieldLabel;
                        tempHistory.changeFrom = fromText;
                        tempHistory.changeBold2 = toText;
                        tempHistory.isChanged = true;
                    }
                    else {
                        tempHistory.action = 'Changed ';
                        tempHistory.changeBold1 = fieldLabel;
                        tempHistory.isChanged = true;
                    }
                }
    
                // Add to the list
                objectHistory.add(tempHistory);
            }
        }
    
        Set<String> userIdList = new Set<String>();
        for(objectHistoryLine myHistory : objectHistory) {
            userIdList.add('' + myHistory.userId);
        }
        
        Map<Id, User> userIdMap = new Map<ID, User>(UserDataAccess.getUsersByIds(userIdList));
    
        for(objectHistoryLine myHistory : objectHistory) {
            if(userIdMap.containsKey(myHistory.userId) & (myHistory.who != '')) {
                myHistory.who = userIdMap.get(myHistory.who).Name;
            }
        }
    
        return objectHistory;
    } 
    
    // Function to return Field Label of a object field given a Field API name
    public Static String returnFieldLabel(String fieldName) {
    
        if(GenericHistoryComponentCtrl.myObjectFieldMap.containsKey(fieldName)) {
            return GenericHistoryComponentCtrl.myObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : historyFieldPicklistValues) {
                if(pickList.getValue() == fieldName) {
                    if(pickList.getLabel() != null) {
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
            }
        }
        return '';
    }

    public class objectHistoryLine {
        public String theDate {get; set;}
        public String who {get; set;}
        public Id userId {get; set;} 
        public String action {get; set;}
        public String actionFieldLabel {get; set;}
        public Boolean isChanged {get; set;} 
        public String changeBold1 {get; set;}
        public String changeBold2 {get; set;}
        public String changeFrom {get; set;}
        public Boolean isDeleted {get; set;}
    }
}