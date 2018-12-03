global class CHL_PostInstallationScript implements InstallHandler{
    
    global void onInstall(InstallContext context) {
        try {
             if (context.previousVersion() == null) {
                generateData();
             } else {
             	insertFieldMappings();
                createRLIToQLIDefaultMapping();  
                insertRLIFieldMappings();
                /*if(context.previousVersion().compareTo(new Version(3,3))<=0){
			 		insertRLIFieldMappings();
			 	}*/
             }
        } catch (Exception ex){
            
        }
    }
    
    /** 
    * @description: Finds the namespace for the managed package.
    * @returns the namespace string.
    */
    private String getNamespace(){
        String nameSpacePrefix = '';
        ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'CSM_Util' limit 1];
        return (String.isNotBlank(cs.nameSpacePrefix) ?  cs.nameSpacePrefix + '__' :  '');
    }
    
    
    private String getExtPackageNamespace(){
        String nameSpacePrefix = '';
        List<ApexTrigger> tr =[select NamespacePrefix from ApexTrigger where Name like:'%CHL_QuoteLineItemTrigger%'];
        return (String.isNotBlank(tr[0].nameSpacePrefix) ?  tr[0].nameSpacePrefix + '__' :  '');
    }
    
    public void generateData() {
        insertFieldMappings();
        insertTriggerEnablement();
        createRLIToQLIDefaultMapping();
        insertRLIFieldMappings();
    }
    
    //To create default mappings for Quote Sync. for US1066 - US1069.
    private void insertFieldMappings(){
        List<REN_Field_Mappings__c> existingMappingList = [SELECT Id,Name FROM REN_Field_Mappings__c WHERE Name = 'Quote → Opportunity' OR Name = 'Opportunity → Quote' ];
    	if(existingMappingList.isEmpty() || existingMappingList == null) {	
	    	List<REN_Field_Mappings__c> fieldMappingList = new List<REN_Field_Mappings__c>();
	        REN_Field_Mappings__c fieldMappingObj;            
	        String nameSpace = getNamespace();
	        String extNameSpace = getExtPackageNamespace();
	        String LBL_QUOTE_OPPTY = 'Quote → Opportunity';
	        String LBL_OPPTY_TO_QUOTE = 'Opportunity → Quote';           
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'TEXTAREA','Description','Description','Opportunity','Quote',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'TEXTAREA','Description','Description','Quote','Opportunity',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'TEXTAREA','Description','Description','QuoteLineItem', 'OpportunityLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'PERCENT','Discount','Discount','QuoteLineItem', 'OpportunityLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'DOUBLE','Quantity','Quantity','QuoteLineItem' , 'OpportunityLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'DATE',extNameSpace +'CHL_Start_Date__c',namespace + 'REN_Start_Date__c','QuoteLineItem', 'OpportunityLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'DATE',namespace + 'REN_Start_Date__c',extNameSpace +'CHL_Start_Date__c','OpportunityLineItem','QuoteLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'DATE',extNameSpace +'CHL_End_Date__c',namespace +'REN_End_Date__c','QuoteLineItem', 'OpportunityLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'DATE',namespace +'REN_End_Date__c',extNameSpace +'CHL_End_Date__c','OpportunityLineItem','QuoteLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'TEXTAREA' ,'Description','Description','OpportunityLineItem','QuoteLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'PERCENT','Discount','Discount','OpportunityLineItem','QuoteLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'DOUBLE','Quantity','Quantity','OpportunityLineItem','QuoteLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY, 'BOOLEAN',namespace +'REN_Is_CLM_Renewal__c', extNameSpace +'CHL_Is_CLM_Renewal__c', 'OpportunityLineItem', 'QuoteLineItem',true, ''));            
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE, 'BOOLEAN',extNameSpace +'CHL_Is_CLM_Renewal__c',namespace +'REN_Is_CLM_Renewal__c' , 'QuoteLineItem', 'OpportunityLineItem',true, ''));            
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'CURRENCY','UnitPrice','UnitPrice','QuoteLineItem','OpportunityLineItem',true,''));
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'CURRENCY','UnitPrice','UnitPrice', 'OpportunityLineItem','QuoteLineItem',true, ''));
	        fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'DATE','ServiceDate','ServiceDate','QuoteLineItem','OpportunityLineItem',true,''));            
	        fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'DATE','ServiceDate','ServiceDate', 'OpportunityLineItem','QuoteLineItem',true, ''));
	        if(fieldMappingList != null){
	            insert fieldMappingList;
	        }
    	}     
    }
    
    private void insertRLIFieldMappings() {
    	String nameSpace = getNamespace();
        String extNameSpace = getExtPackageNamespace();
    	List<REN_Field_Mappings__c> existingMappingList = [SELECT Id,Name FROM REN_Field_Mappings__c WHERE (REN_To_Object_API_Name__c = 'OpportunityLineItem' AND REN_From_Object_Api_Name__c = 'QuoteLineItem' AND REN_To_Field_API_Name__c = 'REN_Renewable_Line_Item__c' AND REN_From_Field_API_Name__c = 'REN_Renewable_Line_Item__c') OR ((REN_To_Object_API_Name__c = 'QuoteLineItem' AND REN_From_Object_Api_Name__c = 'OpportunityLineItem' AND REN_To_Field_API_Name__c = 'REN_Renewable_Line_Item__c' AND REN_From_Field_API_Name__c = 'REN_Renewable_Line_Item__c'))];
		//Name = 'Quote → Opportunity' OR Name = 'Opportunity → Quote' ];
    	if(existingMappingList.isEmpty() || existingMappingList == null) {	
	    	List<REN_Field_Mappings__c> fieldMappingList = new List<REN_Field_Mappings__c>();
	    	
	        String LBL_QUOTE_OPPTY = 'Quote → Opportunity';
	        String LBL_OPPTY_TO_QUOTE = 'Opportunity → Quote'; 
	    	fieldMappingList.add(createFieldMapping(LBL_QUOTE_OPPTY,'REFERENCE',namespace + 'REN_Renewable_Line_Item__c',extNameSpace +'REN_Renewable_Line_Item__c','OpportunityLineItem','QuoteLineItem',true,''));
		   	fieldMappingList.add(createFieldMapping(LBL_OPPTY_TO_QUOTE,'REFERENCE',extNameSpace +'REN_Renewable_Line_Item__c',namespace +'REN_Renewable_Line_Item__c','QuoteLineItem', 'OpportunityLineItem',true,''));
		   	if(fieldMappingList != null){
	            insert fieldMappingList;
	        }
    	}
    }
    
    private REN_Field_Mappings__c createFieldMapping(String mappingName, String dataType, String toName, String fromName, String toObject, 
                                                    String fromObject, Boolean isRequired, String defaultValue) {
        REN_Field_Mappings__c fm = new REN_Field_Mappings__c();
        fm.name = mappingName;
        fm.REN_Field_Data_Type__c = dataType;
        fm.REN_To_Field_API_Name__c = toName;
        fm.REN_From_Field_API_Name__c = fromName;
        fm.REN_To_Object_API_Name__c = toObject;
        fm.REN_From_Object_Api_Name__c = fromObject;
        fm.REN_Is_Required__c = isRequired;
        fm.REN_Default_Value__c = defaultValue;
        return fm;
    }
    
    /* @description: Enabled Quote and QLI trigger in TriggerEnablement custom setting. Added as part of US2597  */
    private void insertTriggerEnablement() {
        CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
        cTriggerEnablement.CHL_QuoteTrigger__c = true;
        cTriggerEnablement.CHL_QuoteLineTrigger__c = true;
        upsert cTriggerEnablement;
   }
   //US3069 : Added for Renewal Relationship → Quote Line Items (TODO: Need to call method once version check is added )
   private void createRLIToQLIDefaultMapping() {		
        List<REN_Field_Mappings__c> existingMappingList = [SELECT Id,Name FROM REN_Field_Mappings__c WHERE (REN_From_Object_Api_Name__c = 'REN_Renews_To__c' AND REN_To_Object_API_Name__c = 'QuoteLineItem' AND Name = 'Renewal Relationship → Quote Line Item') ];
		if(existingMappingList.isEmpty() || existingMappingList == null){	
			String nameSpace = getNamespace();
	        String extNameSpace = getExtPackageNamespace();
	        String LBL_RLI_QLI = 'Renewal Relationship → Quote Line Item';
	        List<REN_Field_Mappings__c> fieldMappingList = new List<REN_Field_Mappings__c>();
			fieldMappingList.add(createFieldMapping(LBL_RLI_QLI,'DOUBLE','Quantity',namespace+'REN_Quantity__c', 'QuoteLineItem',namespace+'REN_Renews_To__c',true, ''));
			fieldMappingList.add(createFieldMapping(LBL_RLI_QLI,'CURRENCY','UnitPrice',namespace+'REN_Previous_Price__c', 'QuoteLineItem',namespace+'REN_Renews_To__c',true, ''));
			//fieldMappingList.add(createFieldMapping(LBL_RLI_QLI,'STRING',extNameSpace+'REN_Original_Line_Item_ID__c',namespace+'REN_Original_Line_Item_ID__c', 'QuoteLineItem',namespace+'REN_Renews_To__c',true, ''));
			fieldMappingList.add(createFieldMapping(LBL_RLI_QLI,'DATE',extNameSpace+'CHL_Start_Date__c',namespace+'REN_Start_Date__c', 'QuoteLineItem',namespace+'REN_Renews_To__c',false, ''));
			fieldMappingList.add(createFieldMapping(LBL_RLI_QLI,'DATE',extNameSpace+'CHL_End_Date__c',namespace+'REN_End_Date__c', 'QuoteLineItem',namespace+'REN_Renews_To__c',false, ''));
			if(fieldMappingList != null && !fieldMappingList.isEmpty()){
				insert fieldMappingList;
			}			
		}	
	}     
}