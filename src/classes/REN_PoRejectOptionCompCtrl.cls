public with sharing class REN_PoRejectOptionCompCtrl {    
    public List<wrapperclassStatus> renewalPicklist{get;set;} 
    Public List <REN_Field_Mappings__c> fieldMappingList=new List <REN_Field_Mappings__c>(); 
    Set<REN_Field_Mappings__c> setOfInvalidFM= new Set<REN_Field_Mappings__c>();
    
    public PageReference saveUpdatedStatus() {
    List <REN_Field_Mappings__c> fieldMappingToInsertList=new List <REN_Field_Mappings__c>();    
    List <REN_Field_Mappings__c> fieldMappingToDeleteList=new List <REN_Field_Mappings__c>();  
    Map<String,String> valuePresentMap=new Map<String,String>();
    try{          
        for(wrapperclassStatus renewalValue:renewalPicklist)
        {              
            REN_Field_Mappings__c fieldMapInsert=new REN_Field_Mappings__c();                                 
            if(renewalValue.isSelected==true)
            {   
                if(renewalValue.displayName=='')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.REN_DISPLAY_NAME_CANNOT_BLANK));  
                    return null;                    
                }
                valuePresentMap.put(renewalValue.oldStatus, renewalValue.displayName);
                integer count=0;
                system.debug('+++'+valuePresentMap);
                for(String fieldName:valuePresentMap.keySet())
                {
                    if(valuePresentMap.get(fieldName)==renewalValue.displayName)
                    {
                        count++;
                        if(count>1)
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.REN_DISPLAY_NAME_UNIQUE));  
                            return null;    
                        }
                    }
                }                                               
                fieldMapInsert.REN_Default_Value__c=renewalValue.displayName;
                fieldMapInsert.REN_To_Field_API_Name__c=renewalValue.oldStatus;
                fieldMapInsert.REN_From_Object_Api_Name__c='RENEW_STATUS_FIELD';
                fieldMappingToInsertList.add(fieldMapInsert);                                                             
            }           
        }                        
        for(REN_Field_Mappings__c mappValue:fieldMappingList)
        {                
            for(integer newValue=0;newValue<fieldMappingToInsertList.size();newValue++)
            {
                if(mappValue.REN_To_Field_API_Name__c==fieldMappingToInsertList[newValue].REN_To_Field_API_Name__c)
                {
                    mappValue.REN_Default_Value__c=fieldMappingToInsertList[newValue].REN_Default_Value__c;
                    fieldMappingToInsertList.remove(newValue);                                            
                }                    
            }
        }
        fieldMappingList.addAll(fieldMappingToInsertList);
        this.fieldMappingList=REN_FieldMappingsDataAccess.upsertFieldMappings(fieldMappingList);                                                                                   
        for(wrapperclassStatus renewalValue:renewalPicklist)
        {
            List<REN_Field_Mappings__c> fieldMapdelete=new List<REN_Field_Mappings__c>();               
            if(renewalValue.isSelected==False)
            {                                
                if(renewalValue.fieldMapping!=null){ 
                    fieldMappingToDeleteList.add(renewalValue.fieldMapping);
                }
            }     
            
        }
        for(REN_Field_Mappings__c fldMapping:setOfInvalidFM){
            fieldMappingToDeleteList.add(fldMapping);
        }
        REN_FieldMappingsDataAccess.deleteFieldMappings(fieldMappingToDeleteList);                             
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 
                                                   String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[]{'Mappings '})));    
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        return null;        
    }    
    public pagereference Cancel()
    {
        PageReference pageRef = Page.REN_RenewalMappings;
        pageRef.getParameters().put('tabCategory', 'Renewal');        
        pageRef.setRedirect(true);
        return pageRef;
    }      
    public  List<wrapperclassStatus> getpickListvalue() {
        renewalPicklist=new List<wrapperclassStatus>();
        fieldMappingList=REN_FieldMappingsDataAccess.getFieldMappingListByConfig('', 'RENEW_STATUS_FIELD'); 
        Schema.DescribeFieldResult fieldResult =REN_Renews_To__c.REN_Renewal_Status__c.getDescribe();
        List<Schema.PicklistEntry> pickListValue = fieldResult.getPicklistValues();                                   
        Set<String> listOfValidPicklistValue = new Set<String>();
        for( Schema.PicklistEntry listValue : pickListValue){
            listOfValidPicklistValue.add(listValue.label);
        }
        
        for( Schema.PicklistEntry listValue : pickListValue)               
        {        
            boolean isvalPresentFlag=false;                  
            for(REN_Field_Mappings__c mapValue:fieldMappingList)
            {
                if(mapValue.REN_To_Field_API_Name__c==listValue.Label)
                {
                    //valuePresentMap.put(listValue.Label, mapValue.REN_Default_Value__c);
                    //valuePresentMap.add(mapValue.REN_Default_Value__c);
                    renewalPicklist.add(new wrapperclassStatus(listValue.Label,True,mapValue.REN_Default_Value__c,mapValue));                      
                    isvalPresentFlag=true;
                }                                                                            
                if(!listOfValidPicklistValue.contains(mapValue.REN_To_Field_API_Name__c)){
                    setOfInvalidFM.add(mapValue);
                }
            }
            if(isvalPresentFlag==false)
            {
                renewalPicklist.add(new wrapperclassStatus(listValue.Label,False,'',null));
            }
        }                                                              
        return renewalPicklist;
    }
    public with sharing class wrapperclassStatus {
        public String oldStatus { get; set; }                    
        public Boolean isSelected { get; set; }
        public String displayName{get;set;}
        public String fldToUpdate{get;set;}
        REN_Field_Mappings__c fieldMapping;
        public wrapperclassStatus(String oldValue,Boolean Selected,String newStatusValue,REN_Field_Mappings__c fieldMapping) 
        {
            oldStatus = oldValue;                     
            isSelected = Selected;                        
            displayName = newStatusValue;  
            fldToUpdate = newStatusValue;
            this.fieldMapping = fieldMapping; 
        }
    }
}