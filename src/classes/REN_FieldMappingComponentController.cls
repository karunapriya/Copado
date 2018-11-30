public with sharing class REN_FieldMappingComponentController extends REN_BaseChildController {

    private List <Schema.SObjectField> fromFieldList;
    private List <Schema.SObjectField> toFieldList;
    private Map<String, List<SelectOption>> typeFromFieldMap;
    private String namespace;
    set<String> setIgnoreFields;
    
    public List<SelectOption> toFieldOptionList{get;set;}
    public String selectedField{get;set;}
    public List<FieldMappingWrapper> fieldMappingList;
    public String customFieldMappingId{get;set;}
    public FieldMappingWrapper currentMapping{get;set;}
    public Boolean isShow{get;set;}
    public String defaultValue{get;set;}
    static public boolean isDefaultPanelShow{get;set;}
    public Boolean isDefaultMappingValid{get;set;}
    public String parentIds{get;set;}
    public List<REN_Field_Mappings__c> fieldMappingsToDelete {get;set;}
    public Set<String> deletedFieldSet;
    public String helpParam {get;set;}
    
    public REN_FieldMappingInputWrapper fmInputWrapper{
        get;
        set{
            if(value != null){
                this.fmInputWrapper = value;
                //system.debug('this.fmInputWrapper $$$$$$$ '+this.fmInputWrapper);
                //system.debug('this.fieldMappingList $$$$$$$ '+this.fieldMappingList);
                if(String.isNotBlank(this.fmInputWrapper.fromObjectName) && this.fromFieldList == null){
                    Set<String> ignoreFieldSet = new Set<String>{CSM_Constants.CURRENCY_ISO_CD};    
                    if (REN_Constants.OBJ_REN_RENEWS_TO.equalsIgnoreCase(this.fmInputWrapper.fromObjectName)) {
                        //ignoreFieldSet.add(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO_PRODUCT_ID);
                        ignoreFieldSet.add(REN_Constants.FLD_NAME);
                    }
                    ignoreFieldSet.add(REN_Constants.OBJ_OPP_FORECAST_CATEGORY);
                    //this.fromFieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(this.fmInputWrapper.fromObjectName, ignoreFieldSet); 
                    this.fromFieldList = getAllFieldList(this.fmInputWrapper.fromObjectName, ignoreFieldSet); // Added for DE1677
                    this.typeFromFieldMap = CSM_AccessController.getInstance().getTypeToFieldListMap(fromFieldList);
                    
                    this.typeFromFieldMap.get(CSM_Constants.TYPE_REFERENCE).addAll(CSM_AccessController.getInstance()
                                        .getFormulaFields(fromFieldList, CSM_Constants.TYPE_STRING));
                   
                }
                if(String.isNotBlank(this.fmInputWrapper.toObjectName) && this.toFieldList == null){
                    //this.toFieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(this.fmInputWrapper.toObjectName==CHL_Constants.PARTNER_OPPORTUNITY_FROM_NAME?CHL_Constants.OBJ_PARTNER_OPPORTUNITY:this.fmInputWrapper.toObjectName);
                     this.toFieldList = getAllFieldList(this.fmInputWrapper.toObjectName == CHL_Constants.PARTNER_OPPORTUNITY_FROM_NAME?CHL_Constants.OBJ_PARTNER_OPPORTUNITY:this.fmInputWrapper.toObjectName, null); // Added for DE1677
                }
                if(String.isNotBlank(this.fmInputWrapper.mappingName) 
                    && (this.fieldMappingList == null || this.fieldMappingList.isEmpty())){
                    this.objectNameSuper = this.fmInputWrapper.mappingName;
                    this.baseMainController = this.fmInputWrapper.baseMainController;
                    this.fieldMappingList = new List<FieldMappingWrapper>();
                    this.toFieldOptionList = new List<SelectOption>();
                }
                isDefaultPanelShow = this.fmInputWrapper.isDefaultShow;
                parentIds=this.fmInputWrapper.parentIdsToRefresh;
            }
        }
    }
    
    public REN_FieldMappingComponentController(){
        super();
        this.isDefaultMappingValid = false;
        this.isShow = false;
        this.namespace = CSM_Util.getNamespace();
        this.populateIgnorableFields();
        fieldMappingsToDelete=new List<REN_Field_Mappings__c>();
        deletedFieldSet = new Set<String>();
        helpParam = CSM_Constants.HELP_MAPPINGS_ADD_FIELD;
    }
    
    private void populateIgnorableFields(){
        setIgnoreFields = new set<String>();
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_CONSOLIDATED);
        //setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_CONSOLIDATED_TO);          
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_NOTIFY_OPPT_OWNER);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_FLD_IS_CLM_RENEWAL);
       // setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPPLN_FLD_CVD_ASSET);
        //setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPPLN_FLD_CVD_PRD);
        //Lumesse fields reference removal
        //setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_ORIGINATOR);
        //setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_PARENT);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_APPEND_RENEWAL_OPPTY);
        setIgnoreFields.add(REN_Constants.OBJ_OPP_PROBABILITY);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_EARLIEST_EXPIRATION_DATE);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_RENEWAL_TARGET);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_RENEWAL_TARGET_LOST);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_RENEWAL_TARGET_RESOLVED);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_RENEWAL_TARGET_WON);
        setIgnoreFields.add(REN_Constants.OBJ_OPP_PRICEBOOK_ID);
        //setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_CLM_RENEWAL);
        setIgnoreFields.add(REN_Constants.OBJ_OPP_FORECAST_CATEGORY);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPP_APPEND_SC);
        setIgnoreFields.add(REN_Constants.OBJ_ASSET_PRODUCT2ID);
        setIgnoreFields.add(REN_Constants.REN_CURRENCY_ISO_CODE);
        setIgnoreFields.add(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED);
        setIgnoreFields.add(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED_TO);
            //For DE380
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OLI_SOURCE_OPLI_ID);
            //setIgnoreFields.add(REN_Constants.OBJ_OP_CAMPAIGNID);
            //setIgnoreFields.add(REN_Constants.OBJ_SCLI_ASSETID);
            //setIgnoreFields.add(REN_Constants.OBJ_SC_CONTACT);
        setIgnoreFields.add(this.namespace + REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID);
        setIgnoreFields.add(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
        setIgnoreFields.add(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SCLI_OPLI_ID);
        setIgnoreFields.add(this.namespace + CHL_Constants.OBJ_PO_AMOUNT);
        setIgnoreFields.add(this.namespace + CHL_Constants.OBJ_PO_STATUS);
        //setIgnoreFields.add(this.namespace + 'REN_Original_Line_Item_ID__c');
        //setIgnoreFields.add(CHL_Util.quoteExtnNameSpace + 'REN_Original_Line_Item_ID__c'); 
        
    }
    
    public List<FieldMappingWrapper> getFieldMappingList() {
        try {
            if (this.fmInputWrapper != null) {
            //Eswar Bala: Ignore from mapping all the fields that are added for backend purposes
            system.debug('this.fmInputWrapper.toObjectName $$$$$$$ ' + this.fmInputWrapper.toObjectName);
            if (this.fmInputWrapper.toObjectName != REN_Constants.OBJ_OPPORTUNITY && this.fmInputWrapper.toObjectName != CSM_Constants.OBJ_CASE && this.fmInputWrapper.fromObjectName != REN_Constants.OBJ_ASSET) {
                setIgnoreFields.add(REN_Constants.OBJ_SC_ACCOUNT);
            }
            
            if(this.fmInputWrapper.toObjectName == CSM_Constants.OBJ_CASE){
            	setIgnoreFields.add(REN_Constants.OBJ_SC_CONTACT);
            }
           /* if (this.fmInputWrapper.toObjectName != CHL_Constants.OBJ_QUOTELINEITEM && this.fmInputWrapper.fromObjectName != REN_Constants.OBJ_REN_RENEWS_TO) {
                setIgnoreFields.add(this.namespace + 'REN_Original_Line_Item_ID__c');
        		setIgnoreFields.add(CHL_Util.quoteExtnNameSpace + 'REN_Original_Line_Item_ID__c'); 
            } */
            
            //us933
            if (this.fmInputWrapper.toObjectName == REN_Constants.OBJ_REN_RENEWS_TO && this.fmInputWrapper.fromObjectName == REN_Constants.OBJ_OPPTY_LINE_ITEM) {
                //setIgnoreFields.add(this.namespace+ 'REN_Asset__c');
                /***** US2699 : Asset & CLI to RLI mappings for Install base generation *****
                setIgnoreFields.add(this.namespace+ 'REN_Quantity__c');*/
                setIgnoreFields.add(this.namespace+ 'REN_Previous_Opportunity__c');
                setIgnoreFields.add(this.namespace+ 'REN_Source_Opportunity__c');
                /***** US2699 : Asset & CLI to RLI mappings for Install base generation *****
                setIgnoreFields.add(this.namespace+ 'REN_End_Date__c');
                setIgnoreFields.add(this.namespace+ 'REN_Start_Date__c');*/
                setIgnoreFields.add(this.namespace+ 'REN_Renews_To__c');
                //setIgnoreFields.add(this.namespace+ 'REN_Renewal_Product_Line_Id__c');
                setIgnoreFields.add(this.namespace+ 'REN_FY__c');
                setIgnoreFields.add(this.namespace+ 'REN_EQ__c');
                setIgnoreFields.add(this.namespace+ 'REN_Expiration_Quarter_Year__c');
                setIgnoreFields.add(this.namespace+ 'REN_Product__c');
                /***** US2699 : Asset & CLI to RLI mappings for Install base generation *****
                setIgnoreFields.add(this.namespace+ 'REN_Previous_Price__c');*/
                setIgnoreFields.add(this.namespace+ 'REN_Renewal_Target__c');
                setIgnoreFields.add(this.namespace+ 'REN_Renewal_Status__c');
                setIgnoreFields.add(this.namespace+ 'REN_Contract_Line_Item__c');
                setIgnoreFields.add(this.namespace+ 'REN_Service_Contract__c');
                setIgnoreFields.add(this.namespace+ 'Renews_To_Contract_Line_Item__c');
                setIgnoreFields.add(this.namespace+ 'Name');
            }
            if(this.fmInputWrapper.mappingName != system.label.REN_LBL_RR_TO_OPLI && this.fmInputWrapper.mappingName != system.label.REN_LBL_OPLI_TO_RR){
	            setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPPLN_FLD_CVD_ASSET);
	        	setIgnoreFields.add(this.namespace + REN_Constants.OBJ_OPPLN_FLD_CVD_PRD);  
            }      
            if (SS_Constants.isSimplifiedDataModelEnabled && this.fmInputWrapper.toObjectName == REN_Constants.OBJ_REN_RENEWS_TO && this.fmInputWrapper.mappingName == system.label.REN_LBL_ASSET_TO_RR) {
               // setIgnoreFields.add(this.namespace+ 'REN_Asset__c');
                setIgnoreFields.add(this.namespace+ 'REN_Renews_To__c');
                //setIgnoreFields.add(this.namespace+ 'REN_Renewal_Product_Line_Id__c');
                setIgnoreFields.add(this.namespace+ 'REN_Product__c');
                setIgnoreFields.add(this.namespace+ 'REN_Is_End_Date_Modified__c');
                setIgnoreFields.add(this.namespace+ 'Name');
            }
            //Added for US1066 - Quote Sync.
            if (this.fmInputWrapper.mappingName == system.label.REN_LBL_QUOTE_TO_OPPTY && this.fmInputWrapper.toObjectName == REN_Constants.OBJ_OPPTY_LINE_ITEM ){
                 setIgnoreFields.remove(this.namespace + REN_Constants.OBJ_OPP_FLD_IS_CLM_RENEWAL);
            }   
            //Added for US1059 - PO details fields should be EXCLUDED from the mapping screen from partner opportunity to master opportunity
            if (this.fmInputWrapper.mappingName == system.label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY && this.fmInputWrapper.toObjectName == this.namespace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY) {
                setIgnoreFields.add(this.namespace+ 'CHL_Partner_Account_1__c');
                setIgnoreFields.add(this.namespace+ 'CHL_Partner_Account_1_Contact__c');
                setIgnoreFields.add(this.namespace+ 'CHL_Partner_Account_1_Type__c');
                setIgnoreFields.add(this.namespace+ 'CHL_Partner_Account_2__c');
                setIgnoreFields.add(this.namespace+ 'CHL_Partner_Account_2_Contact__c');
                setIgnoreFields.add(this.namespace+ 'CHL_Partner_Account_2_Type__c');
                setIgnoreFields.add(this.namespace+ 'CHL_Incumbent__c');
                if(this.fmInputWrapper.mappingName != system.label.REN_LBL_OPP_TO_PO) {
                	setIgnoreFields.add('Name');
                }
            }
            List<Schema.SObjectField> toFieldListTmp = new List<Schema.SObjectField>();
            List<Schema.SObjectField> fromFieldListTmp = new List<Schema.SObjectField>();
            String s = '';
            String s1 = '';
            if (this.toFieldList != null) {
                for (Schema.SObjectField toField: this.toFieldList) {
                    Schema.DescribeFieldResult fieldDescribe = toField.getDescribe();
                    s += ', ' + fieldDescribe.getName();
                    
                    if (!setIgnoreFields.contains(fieldDescribe.getName())) {
                        toFieldListTmp.add(toField);
                        s1 += ', ' + fieldDescribe.getName();
                    }
                }
                system.debug(s+'***'+s1);
                this.toFieldList = toFieldListTmp;
            }
            
            if (this.fromFieldList != null) {
                for (Schema.SObjectField fromField: this.fromFieldList) {
                    Schema.DescribeFieldResult fieldDescribe = fromField.getDescribe();
                    if (!setIgnoreFields.contains(fieldDescribe.getName())) {
                        fromFieldListTmp.add(fromField);
                    }
                }
                this.fromFieldList = fromFieldListTmp;
            }
            
            if (fieldMappingList != null && this.fieldMappingList.isEmpty()) {
                Set <String > addedFields = new Set < String > ();
                List < REN_Field_Mappings__c > fMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
                this.fmInputWrapper.mappingName, this.fmInputWrapper.toObjectName,
                this.fmInputWrapper.fromObjectName);
                    if (fMappingList.isEmpty()) {
                        for (Schema.SObjectField toField: this.toFieldList) {
                            Schema.DescribeFieldResult fieldDescribe = toField.getDescribe();
                            if (fmInputWrapper.toObjectName == this.namespace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY && fmInputWrapper.mappingName!=system.label.REN_LBL_OPP_TO_PO) {
                                setIgnoreFields.add(CHL_Constants.FLD_MAP_OWNERID);
                                if(fieldDescribe.getName() == this.namespace + CHL_Constants.OBJ_PO_SALES_STAGE) {
                                    REN_Field_Mappings__c newMapping = createFieldMapping(fieldDescribe.getName(),fieldDescribe.getType());
                                    DisplayType toType = fieldDescribe.getType();
                                    this.fieldMappingList.add(new FieldMappingWrapper(newMapping,
                                                                this.typeFromFieldMap.get(String.valueOf(toType)),
                                                                true, fieldDescribe.getLabel()));
                                }
                            }
                            if(fmInputWrapper.mappingName == system.label.REN_LBL_OPP_TO_PO){
                                    if(fieldDescribe.getName().equalsIgnoreCase('Name')){
                                        REN_Field_Mappings__c newMapping = createFieldMapping(fieldDescribe.getName(),fieldDescribe.getType());
                                        DisplayType toType = fieldDescribe.getType();
                                        System.debug('Size of fieldMappingList =====>> '+fieldMappingList.size());
                                        System.debug('toType***'+toType);
                                        fieldMappingList.clear();
                                        FieldMappingWrapper fMapping = new FieldMappingWrapper(newMapping,
                                                                    this.typeFromFieldMap.get(String.valueOf(toType)),
                                                                    true, fieldDescribe.getLabel());
                                        fMapping.isRequired = true;                            
                                                              
                                        this.fieldMappingList.add(fMapping);
                                    }
                            }
                            
                            if ((fmInputWrapper.mappingName != system.label.REN_LBL_CASE_TO_CASE_QR ) && fieldDescribe.isUpdateable() && !fieldDescribe.isNillable() && !fieldDescribe.isCalculated() && !setIgnoreFields.contains(fieldDescribe.getName()) && string.valueOf(fieldDescribe.getType()) != 'BOOLEAN') {
                                REN_Field_Mappings__c newMapping = createFieldMapping(fieldDescribe.getName(),fieldDescribe.getType());
                                DisplayType toType = fieldDescribe.getType();
                                this.fieldMappingList.add(new FieldMappingWrapper(newMapping,
                                                            this.typeFromFieldMap.get(String.valueOf(toType)),
                                                            true, fieldDescribe.getLabel()));
                            }
                            
                            if (fmInputWrapper.mappingName == system.label.REN_LBL_CASE_TO_CASE_QR) {
                            	if(fieldDescribe.getName().equalsIgnoreCase('Status') || fieldDescribe.getName().equalsIgnoreCase('Description') || fieldDescribe.getName().equalsIgnoreCase('SSI_ZTH__Quote_Type__c')){
	                                REN_Field_Mappings__c newMapping = createFieldMapping(fieldDescribe.getName(),fieldDescribe.getType());
	                                DisplayType toType = fieldDescribe.getType();
	                                this.fieldMappingList.add(new FieldMappingWrapper(newMapping,
	                                                            null,
	                                                            true, fieldDescribe.getLabel()));
                            	}
                            }
                            
                        }
                    } else {
                        for (REN_Field_Mappings__c fieldMapping: fMappingList) {
                            this.fieldMappingList.add(new FieldMappingWrapper(fieldMapping, this));
                            addedFields.add(fieldMapping.REN_To_Field_API_Name__c);
                        }
                    }
                    this.toFieldOptionList = CSM_AccessController.getInstance().getFieldList(toFieldList, addedFields);
                }
            } else {
                    FieldMappingList = new List < FieldMappingWrapper > ();
            }
        } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getStackTraceString()));
        }
        return this.fieldMappingList;
    }
    
    public PageReference save(){
        if(!this.fieldMappingList.isEmpty()){
            List<REN_Field_Mappings__c> fieldMappingsToUpsert = new List<REN_Field_Mappings__c>();
            if(fmInputWrapper.toObjectName == this.namespace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY && (fmInputWrapper.mappingName !=System.label.REN_LBL_OPP_TO_PO && fmInputWrapper.mappingName !=System.label.CHL_LBL_PO_TO_PO)){
                for(FieldMappingWrapper wrapper : this.fieldMappingList){
                    if(!deletedFieldSet.contains(wrapper.fieldMapping.REN_To_Field_API_Name__c)){
                       /* if(wrapper.fieldMapping.REN_Field_Data_Type__c  == CHL_Constants.PICKLIST){
                            String pickList1 = String.valueOf(wrapper.fieldMapping.REN_To_Field_API_Name__c);
                            String pickList2 = String.valueOf(wrapper.fieldMapping.REN_From_Field_API_Name__c);
                            if(pickListValidation(new Opportunity(), new CHL_Partner_Opportunity__c(), pickList1, pickList2)){
                                validateDefaultValue(wrapper);
                                fieldMappingsToUpsert.add(wrapper.fieldMapping);
                            }else {
                                fieldMappingsToUpsert.clear();  
                               // throw new NoValueMatchedException(Label.CHL_LBL_PICKLIST_VALIDATION_MSG);       
                            } */
                      //  } else {
             				 validateDefaultValue(wrapper);
                             fieldMappingsToUpsert.add(wrapper.fieldMapping);
                         //    fieldMappingsToUpsert.add(wrapper.fieldMapping);

                       // }
                    }
                }
                if(fieldMappingsToDelete!=null){
                    REN_FieldMappingsDataAccess.deleteFieldMappings(fieldMappingsToDelete);
                    fieldMappingsToDelete.clear();
                }
                
                if(fieldMappingsToUpsert != null){
                    REN_FieldMappingsDataAccess.upsertFieldMappings(fieldMappingsToUpsert);
                }
                
                deletedFieldSet.clear();
            } else {

                for(FieldMappingWrapper wrapper : this.fieldMappingList){
            		system.debug(' savewrap- ' + wrapper); 
            		if(wrapper.fieldMapping.Name != system.label.REN_LBL_CASE_TO_CASE_QR){
                		validateDefaultValue(wrapper);            		
            		}               	
                    fieldMappingsToUpsert.add(wrapper.fieldMapping);
                }
                if(fieldMappingsToDelete!=null){
                    REN_FieldMappingsDataAccess.deleteFieldMappings(fieldMappingsToDelete);
                    fieldMappingsToDelete.clear();
                }
                if(fieldMappingsToUpsert != null){
                    REN_FieldMappingsDataAccess.upsertFieldMappings(fieldMappingsToUpsert);
                }
                deletedFieldSet.clear();
          }
        }
        return null;    
    }
    
    
    /*public boolean pickListValidation(sObject toObject, sObject fromObject, String pickListToObj, String pickListFromObj) {

        Map < String, Schema.SobjectField > fieldDefinitionFromObj = CSM_AccessController.fetchAllFieldNames(toObject.getSobjectType());
        Map < String, Schema.SobjectField > fieldDefinitionToObj = CSM_AccessController.fetchAllFieldNames(fromObject.getSobjectType());

        Schema.DescribeFieldResult fieldResult1 = fieldDefinitionToObj.get(pickListToObj).getDescribe();
        List < Schema.PicklistEntry > ple1 = fieldResult1.getPicklistValues();

        Schema.DescribeFieldResult fieldResult2 = fieldDefinitionFromObj.get(pickListFromObj).getDescribe();
            List < Schema.PicklistEntry > ple2 = fieldResult2.getPicklistValues();


        Set<string>  PickList1Set = new Set<string>();
        for(Schema.PicklistEntry p :  ple2){
            PickList1Set.add(String.valueOf(p.getValue()));
        }

        Set<string>  PickList2Set = new Set<string>();
        for(Schema.PicklistEntry p :  ple1){
            PickList2Set.add(String.valueOf(p.getValue()));
        }
        if ((PickList2Set.containsAll(PickList1Set) ) && (PickList1Set.containsAll(PickList2Set))){
            return true;

        } else {
            return false;
        }
    } */
    
    public PageReference addFieldMapping(){
        if(isDependentField(this.currentMapping.fieldMapping.REN_To_Field_API_Name__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_UNIT_AND_TOTAL_PRICE_CAN_NOT_ADD_TOGETHER));
        }else{

            this.currentMapping.fieldMapping.REN_Default_Value__c = this.defaultValue; 
			if(fmInputWrapper.mappingName == system.label.REN_LBL_CASE_TO_CASE_QR){
	            this.currentMapping.fieldMapping.REN_From_Field_API_Name__c = null;
			}  
			          
            try
            {
                 validateDefaultValue(this.currentMapping);              
            
            } catch (FieldMappingFormatException fmfe) 
            {
                this.defaultValue = '';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, fmfe.getMessage()));
                return null;
            } 

            this.currentMapping.fieldMapping.REN_Default_Value__c = this.defaultValue; 

            this.fieldMappingList.add(this.currentMapping);
            this.defaultValue = '';
            //Priya: saving single mapping US406
            try {
                if (fmInputWrapper.toObjectName != this.namespace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY) {
                    REN_FieldMappingsDataAccess.upsertFieldMappings(new List < REN_Field_Mappings__c > {
                    this.currentMapping.fieldMapping});
                    deletedFieldSet.remove(currentMapping.fieldMapping.REN_To_Field_API_Name__c);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                    String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[] {'Mappings '})));
                }
            } catch (system.DmlException dmlEx) {
                if (!dmlEx.getDmlType(0).equals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, dmlEx.getMessage()));
                }
            }
             catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
            }
        removeSelectedField();
        }
        this.isShow = false;
        return null;
    }
    
    private Boolean isDependentField(String fieldName){
        Boolean isDependentField = false;
        if('TotalPrice'.equals(fieldName)){
            for(FieldMappingWrapper wrapper : this.fieldMappingList){
                if('UnitPrice'.equals(wrapper.fieldMapping.REN_To_Field_API_Name__c)){
                    isDependentField = true;
                    break;
                }
            }
        }else if('UnitPrice'.equals(fieldName)){
            for(FieldMappingWrapper wrapper : this.fieldMappingList){
                if('TotalPrice'.equals(wrapper.fieldMapping.REN_To_Field_API_Name__c)){
                    isDependentField = true;
                    break;
                }
            }
        }
        return isDependentField;
    }
    
    public PageReference updateFromFields(){
        this.currentMapping.fieldMapping.REN_To_Field_API_Name__c = this.selectedField;
        this.currentMapping.populateFromOptions();
        return null;
    }
    
    public PageReference cancel() {
        this.isShow = false;
        return null;
    }
    
    public PageReference deleteFieldMapping(){
        try{
            FieldMappingWrapper wrapper = findFieldMappingById();
            if(String.isNotBlank(wrapper.fieldMapping.Id)){
                if(Schema.sObjectType.REN_Field_Mappings__c.isDeletable()){
                    system.debug('wrapper.fieldMapping --->'+wrapper.fieldMapping);
                    fieldMappingsToDelete.add(wrapper.fieldMapping);
                    deletedFieldSet.add(wrapper.fieldMapping.REN_To_Field_API_Name__c);
                }else{
                    String[] arguments = new String[] {REN_Constants.OBJ_FM};
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.CSM_MSG_OBJECT_NOT_DELETABLE, arguments)));
                }
            }
            addSelectedField(wrapper.fieldMapping.REN_To_Field_API_Name__c);
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    public PageReference showPopup() {
        //Priya: saving single mapping US406
        try{
            save();
            isDefaultMappingValid = true;
        }catch(system.DmlException dmlEx){
            if(!dmlEx.getDmlType(0).equals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, dmlEx.getMessage()));
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        if(isDefaultMappingValid){
            this.selectedField = this.toFieldOptionList.get(0).getValue();
            DisplayType totype=null;
            currentMapping = new FieldMappingWrapper(createFieldMapping(this.selectedField,totype), this);
            isShow = true;
        }
        return null;
    }
    
    private REN_Field_Mappings__c createFieldMapping(String toFieldApiName,DisplayType toFieldType){
        REN_Field_Mappings__c newMapping = new REN_Field_Mappings__c();
        newMapping.REN_From_Object_API_Name__c = this.fmInputWrapper.fromObjectName;
        newMapping.Name = this.fmInputWrapper.mappingName;
        newMapping.REN_To_Field_API_Name__c = toFieldApiName;
        newMapping.REN_To_Object_API_Name__c = this.fmInputWrapper.toObjectName;
        newMapping.REN_Default_Value__c = '';
        newMapping.REN_Field_Data_Type__c=String.valueOf(toFieldType);
        return newMapping;
    }
    
    private FieldMappingWrapper findFieldMappingById(){
        FieldMappingWrapper foundWrapper;
        if(String.isNotBlank(this.customFieldMappingId)){
            for(Integer i=0; i<this.fieldMappingList.size(); i++){
                FieldMappingWrapper wrapper = this.fieldMappingList.get(i);
                if(String.isNotBlank(wrapper.customId) 
                    && wrapper.customId.equals(this.customFieldMappingId)){
                    foundWrapper = wrapper;
                    this.fieldMappingList.remove(i);
                    break;
                }
            }
        }
        return foundWrapper;
    }
    
    private void removeSelectedField(){
        for(Integer i=0; i<this.toFieldOptionList.size(); i++){
            SelectOption sp = this.toFieldOptionList.get(i);
            if(sp.getValue().equals(this.selectedField)){
                this.toFieldOptionList.remove(i);
                break;
            }
        }
    }
    
    private void addSelectedField(String toFieldName){
        for(Schema.SObjectField toField : this.toFieldList){
            Schema.DescribeFieldResult fieldDescribe = toField.getDescribe();
            if(toFieldName.equals(fieldDescribe.getName())){
                this.toFieldOptionList.add(new SelectOption(fieldDescribe.getName(), fieldDescribe.getLabel()));
                break;
            }
        }
        CSM_Util.sortSelectOptionByLabel(this.toFieldOptionList);
    }
    
    public class FieldMappingWrapper{
        private final String DEFAULT_VALUE = '--Default Value--';
        public REN_Field_Mappings__c fieldMapping{get;set;}
        public List<SelectOption> mappedFieldList{get;set;}
        public String customId{get;set;}
        public String fieldLabel{get;set;}
        public Boolean isRequired{get;set;}
        private REN_FieldMappingComponentController controller{get;set;}
        
        public FieldMappingWrapper(REN_Field_Mappings__c fieldMapping, REN_FieldMappingComponentController controller){
            this.fieldMapping = fieldMapping;
            this.controller = controller;
            this.isRequired = this.fieldMapping.REN_Is_Required__c;
            populateFromOptions();
            this.customId = String.isBlank(fieldMapping.Id)?String.valueOf(Datetime.now().getTime()):fieldMapping.Id;
        }
        
        public FieldMappingWrapper(REN_Field_Mappings__c fieldMapping, List<SelectOption> mappedFieldList, 
                                    Boolean isRequired, String fieldLabel){
            this.fieldMapping = fieldMapping;
            this.mappedFieldList = new List<SelectOption>();
            if(isDefaultPanelShow){
                this.mappedFieldList.add(new SelectOption('', DEFAULT_VALUE));
            }
			if(mappedFieldList != null){
	            this.mappedFieldList.addAll(mappedFieldList);
	            setFromFieldAPIName();
			}
            system.debug('mappedFieldList---------->'+mappedFieldList);
            this.isRequired = isRequired;
            this.fieldMapping.REN_Is_Required__c = isRequired;
            this.fieldLabel = fieldLabel;
        }
        
        private void setFromFieldAPIName() {
            List<SelectOption> mappedFieldLst= new List<SelectOption>();
            for (SelectOption so : this.mappedFieldList) {
                //if(!so.getValue().equals(REN_Constants.OBJ_OPP_FORECAST_CATEGORY)){
                        mappedFieldLst.add(so);
                //}
            }
            this.mappedFieldList.clear();
            this.mappedFieldList.addAll(mappedFieldLst);
            for (SelectOption so : this.mappedFieldList) {
                if (String.isBlank(this.fieldMapping.REN_Default_Value__c) 
                    && String.isBlank(this.fieldMapping.REN_From_Field_API_Name__c)
                    && so.getValue().equals(this.fieldMapping.REN_To_Field_API_Name__c)) {
                    this.fieldMapping.REN_From_Field_API_Name__c = so.getValue();
                    break;
                }
            }
        }
        
        public void populateFromOptions(){
            this.mappedFieldList = new List<SelectOption>();
            if(isDefaultPanelShow){
             this.mappedFieldList.add(new SelectOption('', DEFAULT_VALUE));
            }
            for(Schema.SObjectField toField : controller.toFieldList){
                Schema.DescribeFieldResult fieldDescribe = toField.getDescribe();
                DisplayType toType = fieldDescribe.getType();
                if(String.isNotBlank(controller.selectedField) 
                        && controller.selectedField.equals(fieldDescribe.getName())
                    || fieldDescribe.getName().equals(fieldMapping.REN_To_Field_API_Name__c)){
                    this.fieldMapping.REN_Field_Data_Type__c = String.valueOf(toType);
                    this.fieldLabel = fieldDescribe.getLabel();
                    if(controller.typeFromFieldMap.containsKey(String.valueOf(toType))){
                        this.mappedFieldList.addAll(controller.typeFromFieldMap.get(String.valueOf(toType)));
                        
                        if(controller.fmInputWrapper.toObjectName == CSM_Constants.OBJ_CASE && String.valueOf(toType) == 'REFERENCE' && controller.typeFromFieldMap.containsKey('ID')){
                            this.mappedFieldList.addAll(controller.typeFromFieldMap.get('ID'));
                        }
                        
                        setFromFieldAPIName();
                    }
                    break;
                }
            }
        }
    }
    
    /* @description : This method that can be used for obtaining all the fields details without checking the field level permission as per the requested Object. 
    				  Added as part of DE1677.
    * @param Object Name as string, Set of Fields name which we don't want to mapped.
    * @param List of Schema.SObjectField fields from the requested Obj.
	*/  
	private List<Schema.SObjectField> getAllFieldList(String objName, Set<String> ignorableFieldSet){
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		//Added if condition for DE1822
		if(objName.containsIgnoreCase('__c') && !objName.startsWithIgnoreCase(CSM_Util.getNamespace())) {
			objName = CSM_Util.getNamespace()+objName;
		}
		Schema.SobjectType oType = gd.get(objName);
		 List<Schema.SObjectField> objFieldList;
		 if(oType  != null){
		 	objFieldList = new List<Schema.SObjectField>();
		 	Map<String, Schema.SobjectField> objAllFieldName = CSM_AccessController.fetchAllFieldNames(oType);
			for(String fieldName : objAllFieldName.keyset()){
				if((ignorableFieldSet == null ) || (ignorableFieldSet != null && !ignorableFieldSet.Contains('fieldName') )){// Not null condition check only required for From option
				    objFieldList.add(objAllFieldName.get(fieldName));
				}
			}
		 }
		 return objFieldList;
	}
	
	private void validateDefaultValue(FieldMappingWrapper wrapper)
    {
        if (String.isNotBlank(wrapper.fieldMapping.REN_Default_Value__c))
        {
            try
            {
                if (wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Integer)))
                {
                    Integer.valueOf(wrapper.fieldMapping.REN_Default_Value__c);
                }
                else if (wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Currency)))
                {
                  
                    Decimal.valueOf(wrapper.fieldMapping.REN_Default_Value__c);
                }
                else if (wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Double))
                        || wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Percent)))
                {
                    Double.valueOf(wrapper.fieldMapping.REN_Default_Value__c);
                }
                else if(wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.DateTime)))
                {
                    DateTime.valueOf(wrapper.fieldMapping.REN_Default_Value__c);
                } 
                else if (wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Date)))
                {
                    Date.valueOf(wrapper.fieldMapping.REN_Default_Value__c);
                }
                else if(wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Boolean)))
                {
                    if (!wrapper.fieldMapping.REN_Default_Value__c.equalsIgnoreCase('true')
                        && !wrapper.fieldMapping.REN_Default_Value__c.equalsIgnoreCase('false'))
                    {
                        
                        String expectedFormat = ' ' +String.format(Label.LBL_SAVE_EXPECTED_FORMAT, 
                            new String[]{'TRUE OR FALSE'});
                        throw new FieldMappingFormatException(String.format(Label.MSG_DEFAULT_MAPPING_ERROR, 
                        new String[]{wrapper.fieldLabel, wrapper.fieldMapping.REN_Field_Data_Type__c,expectedFormat}));
                    }
                }
            } catch (System.TypeException ste)
            {
                String dateFormatString = '';
                if(wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Date)))
                {
                    dateFormatString = ' ' +String.format(Label.LBL_SAVE_EXPECTED_FORMAT, 
                            new String[]{'yyyy-mm-dd'});
               
                }
                else if (wrapper.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.DateTime)))
                {
                    dateFormatString = ' ' +String.format(Label.LBL_SAVE_EXPECTED_FORMAT, 
                            new String[]{'yyyy-mm-dd hh:mm:ss'});
                }
                
                
                throw new FieldMappingFormatException(String.format(Label.MSG_DEFAULT_MAPPING_ERROR, 
                new String[]{wrapper.fieldLabel, wrapper.fieldMapping.REN_Field_Data_Type__c,dateFormatString}));
                
            }
        }       
    }
	
    public with sharing class NoValueMatchedException extends Exception {}
    public with sharing class DependedFieldException extends Exception {}
    public with sharing class FieldMappingFormatException extends Exception{}
}