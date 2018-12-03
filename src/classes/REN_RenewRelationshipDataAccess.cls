public with sharing class REN_RenewRelationshipDataAccess {

    public static CSM_Admin__c getCSMAdminInstance() {
        return CSM_Admin__c.getInstance();
    }
    public static List<SObject> getDataUsingFieldMappings( String objectName, List<REN_Field_Mappings__c> fieldMappingList, Set<String> additionalFieldSet,String filterStr) {
        Set<String> fieldSet = REN_Util.getFromFldsToQuery(fieldMappingList);
        if(additionalFieldSet != null && additionalFieldSet.isEmpty()){
            fieldSet.addAll(additionalFieldSet);
        }
        return getDataUsingFieldSet(objectName, null, fieldSet, filterStr);
    }

    public static List<SObject> getDataUsingFieldSet( String objectName, List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet,String filterStr) {
        
        Set<String> fsFieldSet = new Set<String>();
        Set<String> refrenceFieldSet = new Set<String>();
        String queryString = '';
        String nameSpace = CSM_Util.getNamespace();
        SObject sObj = CSM_AccessController.newSObject(objectName);
        Map<String, Schema.SobjectField> fields = sObj.getSObjectType().getDescribe().fields.getMap();
        for(Schema.FieldSetMember fld :fieldSetMemberList){
            String fldStr = fld.getFieldPath();
            //US2419 - Commented code
            /*if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }*/
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
                String fName = null;
                //String fieldPath = fldStr.remove(nameSpace); //US2419
                DescribeFieldResult dfr = fields.get(fldStr).getDescribe(); //US2419
                //DescribeFieldResult dfr = fields.get(fld.getFieldPath()).getDescribe();
                    List<Schema.SObjectType> oTypeList = dfr.getReferenceTo();
                    if(!oTypeList.isEmpty()){
                        String refObjName = oTypeList[0].getDescribe().getName();
                        if(CSM_AccessController.hasField(refObjName, 'Name')){
                            fName = dfr.getRelationshipName() + '.Name';
                        }else if (fld.getFieldPath().contains('REN_Contract_Line_Item__c')){
                            fName = dfr.getRelationshipName() + '.LineItemNumber';
                        }
                    }
                if(String.isNotBlank(fName) && !refrenceFieldSet.contains(fName)){
                    queryString += ', ' + fName; 
                     refrenceFieldSet.add(fName);
                }
            }
            
            if(!refrenceFieldSet.contains(fld.getFieldPath())){
                   
                if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DOUBLE) ||
                    fld.getType().equals(Schema.DisplayType.CURRENCY) || fld.getType().equals(Schema.DisplayType.DATETIME)){
                    if (UserInfo.isMultiCurrencyOrganization() && fld.getType().equals(Schema.DisplayType.CURRENCY)){
                        queryString += ', format(convertCurrency(' + fld.getFieldPath() + '))';
                    } else {
                        queryString += ', format(' + fld.getFieldPath() + ')';
                    }
                }
                else {   
                    queryString += ', ' + fld.getFieldPath();
                }
            } 
            system.debug('***'+fld);
            if(!fld.getFieldPath().contains('.')){
                fsFieldSet.add(fldStr);
            }
            refrenceFieldSet.add(fldStr);
        }
        if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
            queryString += ', CurrencyIsoCode';
            fsFieldSet.add('CurrencyIsoCode');
            
        }
        if(additionalFieldSet != null){
            for(String s : additionalFieldSet){
                if(!refrenceFieldSet.contains(s)){
                    fsFieldSet.add(s);
                    queryString += ','+ s;  
                }
            }
        }
        List<String> fsFieldList = new List<String>(fsFieldSet);
        
        CSM_Util.checkCRUD_FLS(objectName , fsFieldList, CSM_Constants.DML_OPERATION_READ);
        integer recordLimit = (integer)getCSMAdminInstance().REN_Manage_Renewal_Records_Limit__c;
        if(String.isNotBlank(filterStr)){
            if(recordLimit != null){
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE id != null ' + (String.isBlank(filterStr) ? '':(' AND (' + filterStr + ' )') +' limit ' +recordLimit);
            }else{
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE id != null ' + (String.isBlank(filterStr) ? '':(' AND (' + filterStr + ' )'));
            }
        }
        else{
            if(recordLimit != null){
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE id != null ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )') +' limit ' +recordLimit);
            }else{
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE id != null ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )'));
            }
        }
         system.debug(fieldSetMemberList + '\n\n queryString in RenRelationship --- :: ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
    
    public static List<SObject> getRliDataUsingFieldSet( String objectName, List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet,String filterStr,Set<String> firstFilterSet,Set<String> strSet,boolean showValidRli) {
        
        Set<String> fsFieldSet = new Set<String>();
        Set<String> refrenceFieldSet = new Set<String>();
        String queryString = '';
        String nameSpace = CSM_Util.getNamespace();
        SObject sObj = CSM_AccessController.newSObject(objectName);
        Map<String, Schema.SobjectField> fields = sObj.getSObjectType().getDescribe().fields.getMap();
        for(Schema.FieldSetMember fld :fieldSetMemberList){
             String fldStr = fld.getFieldPath();
           /* if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }*/
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
                String fName = null;
              //  String fieldPath = fldStr.remove(nameSpace);
                DescribeFieldResult dfr = fields.get(fldStr).getDescribe();
                //DescribeFieldResult dfr = fields.get(fld.getFieldPath()).getDescribe();
                    List<Schema.SObjectType> oTypeList = dfr.getReferenceTo();
                    if(!oTypeList.isEmpty()){
                        String refObjName = oTypeList[0].getDescribe().getName();
                        if(CSM_AccessController.hasField(refObjName, 'Name')){
                            fName = dfr.getRelationshipName() + '.Name';
                        }
                    }
                if(String.isNotBlank(fName) && !refrenceFieldSet.contains(fName)){
                    queryString += ', ' + fName; 
                     refrenceFieldSet.add(fName);
                }
            }
            if(!refrenceFieldSet.contains(fld.getFieldPath()) && fld.getType().equals(Schema.DisplayType.PICKLIST)){
            	queryString += ', toLabel(' + fld.getFieldPath() + ')';
            	refrenceFieldSet.add(fldStr);
            }
            if(!refrenceFieldSet.contains(fld.getFieldPath())){
                   
                if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DOUBLE) ||
                    fld.getType().equals(Schema.DisplayType.CURRENCY) || fld.getType().equals(Schema.DisplayType.DATETIME)){
                    if (UserInfo.isMultiCurrencyOrganization() && fld.getType().equals(Schema.DisplayType.CURRENCY)){
                        queryString += ', format(convertCurrency(' + fld.getFieldPath() + '))';
                    } else {
                        queryString += ', format(' + fld.getFieldPath() + ')';
                    }
                }
                else {   
                    queryString += ', ' + fld.getFieldPath();
                }
            } 
            system.debug('***'+fld);
            if(!fld.getFieldPath().contains('.')){
                fsFieldSet.add(fldStr);
            }
            refrenceFieldSet.add(fldStr);
        }
        if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
            queryString += ', CurrencyIsoCode';
            fsFieldSet.add('CurrencyIsoCode');
            
        }
        if(additionalFieldSet != null){
            for(String s : additionalFieldSet){
                if(!refrenceFieldSet.contains(s)){
                    //fsFieldSet.add(s);
                    queryString += ','+ s;  
                }
            }
        }
        List<String> fsFieldList = new List<String>(fsFieldSet);
        
        CSM_Util.checkCRUD_FLS(objectName , fsFieldList, CSM_Constants.DML_OPERATION_READ);
        integer recordLimit = (integer)getCSMAdminInstance().REN_Search_And_Move_Records_Limit__c;
        if(String.isNotBlank(filterStr)){
            if (strSet != null && !strSet.isEmpty() && showValidRli){
                filterStr+= ' AND REN_Renews_To__r.StageName NOT IN : strSet ';
            }
            if(!showValidRli){
                filterStr= ''+filterStr+' AND REN_Renews_To__c!=null';
            }
            if(recordLimit != null){
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )') +' limit ' +recordLimit);
            }else{
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )'));
            }
        }
        else{
            if(recordLimit != null){
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )') +' limit ' +recordLimit);
            }else{
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )'));
            }
        }
         system.debug(fieldSetMemberList + '\n\n queryString in RenRelationship --- :: ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
    
    public static List<SObject> getRliToShowNoResultFound( String objectName, List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet,String filterStr,Set<String> firstFilterSet,Set<String> strSet,boolean showValidRli) {
        
        Set<String> fsFieldSet = new Set<String>();
        Set<String> refrenceFieldSet = new Set<String>();
        String queryString = '';
        String nameSpace = CSM_Util.getNamespace();
        SObject sObj = CSM_AccessController.newSObject(objectName);
        Map<String, Schema.SobjectField> fields = sObj.getSObjectType().getDescribe().fields.getMap();
        for(Schema.FieldSetMember fld :fieldSetMemberList){
            String fldStr = fld.getFieldPath();
           /* if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }*/
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
                String fName = null;
              //  String fieldPath = fldStr.remove(nameSpace);
                DescribeFieldResult dfr = fields.get(fldStr).getDescribe();
                //DescribeFieldResult dfr = fields.get(fld.getFieldPath()).getDescribe();
                    List<Schema.SObjectType> oTypeList = dfr.getReferenceTo();
                    if(!oTypeList.isEmpty()){
                        String refObjName = oTypeList[0].getDescribe().getName();
                        if(CSM_AccessController.hasField(refObjName, 'Name')){
                            fName = dfr.getRelationshipName() + '.Name';
                        }
                    }
                if(String.isNotBlank(fName) && !refrenceFieldSet.contains(fName)){
                    queryString += ', ' + fName; 
                     refrenceFieldSet.add(fName);
                }
            }
            
            if(!refrenceFieldSet.contains(fld.getFieldPath())){
                   
                if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DOUBLE) ||
                    fld.getType().equals(Schema.DisplayType.CURRENCY) || fld.getType().equals(Schema.DisplayType.DATETIME)){
                    if (UserInfo.isMultiCurrencyOrganization() && fld.getType().equals(Schema.DisplayType.CURRENCY)){
                        queryString += ', convertCurrency(' + fld.getFieldPath() + ')';
                    } else {
                        queryString += ',' + fld.getFieldPath();
                    }
                }
                else {   
                    queryString += ', ' + fld.getFieldPath();
                }
            } 
            system.debug('***'+fld);
            if(!fld.getFieldPath().contains('.')){
                fsFieldSet.add(fldStr);
            }
            refrenceFieldSet.add(fldStr);
        }
        if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
            queryString += ', CurrencyIsoCode';
            fsFieldSet.add('CurrencyIsoCode');
            
        }
        if(additionalFieldSet != null){
            for(String s : additionalFieldSet){
                if(!refrenceFieldSet.contains(s)){
                    //fsFieldSet.add(s);
                    queryString += ','+ s;  
                }
            }
        }
        List<String> fsFieldList = new List<String>(fsFieldSet);
        
        CSM_Util.checkCRUD_FLS(objectName , fsFieldList, CSM_Constants.DML_OPERATION_READ);
        integer recordLimit = (integer)getCSMAdminInstance().REN_Search_And_Move_Records_Limit__c;
        if(String.isNotBlank(filterStr)){
            if (strSet != null && !strSet.isEmpty() && showValidRli){
                filterStr+= ' AND REN_Renews_To__r.StageName NOT IN : strSet ';
            }
            if(recordLimit != null){
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )') +' limit ' +recordLimit);
            }else{
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )'));
            }
        }
        else{
            if(recordLimit != null){
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )') +' limit ' +recordLimit);
            }else{
                queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   REN_Renews_To__c WHERE ' + (String.isBlank(filterStr) ? '':(' (' + filterStr + ' )'));
            }
        }
         system.debug(fieldSetMemberList + '\n\n queryString in RenRelationship --- :: ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
    
    public static List<REN_Renews_To__c> upsertRenewalRelationship(List<REN_Renews_To__c> renewRelationshipList){
        List<String> renewRelationFields = new List<String>{REN_Constants.OBJ_REN_RENEWS_TO_ASSET, 
                                                            REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO,
                                                            //REN_Constants.OBJ_REN_RENEWS_TO_ORIG_LINE_ITEM,
                                                            REN_Constants.OBJ_REN_RENEWS_TO_PREVIOUS_PRICE,
                                                            REN_Constants.OBJ_REN_RENEWS_TO_END_DATE,
                                                            REN_Constants.OBJ_REN_RENEWS_TO_START_DATE
                                                           };
        List<String> noAccessFieldList = CSM_AccessController.getInstance()
                                            .returnNoPermissionFieldsNameList(REN_Constants.OBJ_REN_RENEWS_TO, 
                                            CSM_Constants.DML_OPERATION_UPSERT, renewRelationFields);
        if (noAccessFieldList.isEmpty())
        {
            upsert renewRelationshipList;
        }
        else
        {
             String[] arguments = new String[] {REN_Constants.OBJ_REN_RENEWS_TO + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
    
        return renewRelationshipList;
    }
   
  
    public static void updateRenewalRelationship(List<REN_Renews_To__c> renewRelationshipList){
        List<String> renewRelationFields = new List<String>{REN_Constants.OBJ_REN_RENEWS_TO_ASSET, 
                                                            REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO,
                                                            //REN_Constants.OBJ_REN_RENEWS_TO_ORIG_LINE_ITEM,
                                                            REN_Constants.OBJ_REN_RENEWS_TO_PREVIOUS_PRICE,
                                                            REN_Constants.OBJ_FLD_END_DATE
                                                           };
        List<String> noAccessFieldList = CSM_AccessController.getInstance()
                                            .returnNoPermissionFieldsNameList(REN_Constants.OBJ_REN_RENEWS_TO, 
                                            CSM_Constants.DML_OPERATION_UPDATE, renewRelationFields);
        if (noAccessFieldList.isEmpty())
        {
            update renewRelationshipList;
        }
        else
        {
             String[] arguments = new String[] {REN_Constants.OBJ_REN_RENEWS_TO + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
        }    
    }

    public static List<REN_Renews_To__c> getRenewalRelationshipsWithAssetRenewal(Set<String> assetIdSet){
        if(assetIdSet == null || assetIdSet.isEmpty()){
            return null;
        }
        List<String> fieldList = new List<String>{'REN_Renews_To__c', 'REN_Asset__c','Name', 'Id'};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ);
        List<REN_Renews_To__c> renewalMappingList = [Select  r.REN_Asset__c,r.REN_Renewal_Status__c,r.REN_Asset__r.Name, r.REN_Asset__r.SerialNumber, r.REN_Asset__r.Product2.Name, r.REN_Asset__r.Quantity 
                , r.REN_Asset__r.Price, r.REN_Asset__r.Status, r.REN_Asset__r.REN_End_Date__c, r.REN_Asset__r.REN_Start_Date__c, r.REN_Asset__r.REN_Opportunity__r.Id, r.REN_Asset__r.REN_Opportunity__r.name
                , r.REN_Asset__r.REN_Opportunity__r.StageName, r.REN_Asset__r.REN_Opportunity__r.CloseDate,  r.REN_Renews_To__c, r.REN_Renews_To__r.name
                , r.REN_Renews_To__r.StageName, r.REN_Renews_To__r.CloseDate
            From REN_Renews_To__c r WHERE r.REN_Renews_To__c!= null and r.REN_Asset__c in :assetIdSet];
        return renewalMappingList;
    }
    
    public static List<REN_Renews_To__c> getRenewalRelationshipsWithServiceContracts(Set<String> contractLineItemIdSet, Set<String> oppLineItemIdSet){
        List<REN_Renews_To__c> renewalRelationshipList = new List<REN_Renews_To__c>();
        Set<String> fieldNameSet = CSM_Util.getColumnsNames(REN_Constants.OBJ_REN_RENEWS_TO);
        List<String> fieldList = new List<String> (fieldNameSet);
        String columnString = String.join(fieldList, ', ');
        if((contractLineItemIdSet == null && oppLineItemIdSet == null ) || ((contractLineItemIdSet == null ||contractLineItemIdSet.isEmpty()) && (oppLineItemIdSet == null || oppLineItemIdSet.isEmpty()))|| String.isBlank(columnString)){
            return null;
        } 
        
        // VCP - ORG21 check
        Boolean hasContractLineItemFieldField = CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM);
        
        // VCP - ORG21 check
        if (CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT)){
            fieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT);
        }
        
        // VCP - ORG21 check
        if (hasContractLineItemFieldField==true){
            fieldList.add(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM);
        }
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ);
        String queryString = 'Select ' + columnString + ' from REN_Renews_To__c where IsDeleted = false ';
        
        if(contractLineItemIdSet != null && !contractLineItemIdSet.isEmpty() && hasContractLineItemFieldField==true){
            // VCP - ORG21 check
            queryString += ' AND ' + CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c in :contractLineItemIdSet '; 
        }
       
        system.debug('\n\n~~~~ queryString:' + queryString);
        renewalRelationshipList = Database.query(queryString);
        return renewalRelationshipList;
    }
    
    public static List<REN_Renews_To__c> getRenewalRelationshipForOppty(Set<String> opptyIds){
        List<REN_Renews_To__c> renewalRelationshipList = new List<REN_Renews_To__c>();
        
               List<String> fieldList = new List<String>{'REN_Renews_To__c', 'REN_Product__c', 'REN_Asset__c','Name', 'Id', 'REN_Start_Date__c', 'REN_Renewal_Target__c', 
                                'REN_Renewal_Status__c', 'REN_Product__c', 'REN_Previous_Price__c','REN_End_Date__c', 'OwnerId', 'Name' };

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ);
        String queryString = 'Select id, REN_Renews_To__c, Name, REN_Product__c, REN_Start_Date__c, REN_End_Date__c, REN_Previous_Price__c, REN_Renewal_Target__c, REN_Product__r.name, ' + 
            'REN_Asset__c, REN_Asset__r.name, REN_Renewal_Status__c ';

       if((CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c') && (CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c'))  )){
            String SCFileds =','+ CSM_Util.nameSpacePrefix21 +'REN_Service_Contract__c,'+ CSM_Util.nameSpacePrefix21  + 'REN_Service_Contract__r.name,' +  CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c';
            queryString += SCFileds;
        }
        queryString+=' FROM REN_Renews_To__c';

        if(opptyIds != null && !opptyIds.isEmpty()){
            queryString += ' WHERE REN_Renews_To__c IN:opptyIds '; 
        }
        system.debug('\n\n~~~~ queryString:' + queryString);
        renewalRelationshipList = Database.query(queryString);
        return renewalRelationshipList;
    }
    
    public static List<REN_Renews_To__c> getRenewalRelationshipByIds(Set<String> setRenewalIds){
        List<REN_Renews_To__c> renewalRelationshipList = new List<REN_Renews_To__c>();
        
        List<String> fieldList = new List<String>{'REN_Renews_To__c', 'REN_Product__c', 'REN_Asset__c','Name', 'Id', 'REN_Start_Date__c', 'REN_Quantity__c', 'REN_Renewal_Target__c', 
                                'REN_Renewal_Status__c', 'REN_Product__c', 'REN_Previous_Price__c', 'REN_End_Date__c', 'OwnerId', 'Name' };
        
        if((CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c'))) {
            fieldList.add(CSM_Util.nameSpacePrefix21 +'REN_Contract_Line_Item__c');
        }
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ);
        
        String queryString = 'Select id, Name, REN_Renews_To__c, REN_Product__c, REN_Start_Date__c, REN_End_Date__c, REN_Previous_Price__c, REN_Renewal_Target__c, REN_Product__r.name, REN_Quantity__c ,' + 
            'REN_Asset__c, REN_Asset__r.name, REN_Renewal_Status__c, REN_Source_Opportunity__c, REN_Previous_Opportunity__c ';
        
        if((CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c'))) {
            queryString += ', ' + CSM_Util.nameSpacePrefix21 + 'REN_Contract_Line_Item__c';
        }
        queryString += ' from REN_Renews_To__c';

        if(setRenewalIds != null){
            integer recordLimit = (integer)getCSMAdminInstance().REN_Manage_Renewal_Records_Limit__c;
            if(recordLimit != null){
                queryString += ' WHERE Id IN :setRenewalIds limit '+recordLimit;
            }
            else{
                queryString += ' WHERE Id IN :setRenewalIds';
            }
        }
        system.debug('\n\n~~~~ queryString:' + queryString);
        renewalRelationshipList = Database.query(queryString);
        return renewalRelationshipList;
    }
    
    public static List<REN_Renews_To__c> getRenewalRelationship(Set<String> setRenewalIds){
        List<REN_Renews_To__c> renewalRelationshipList = new List<REN_Renews_To__c>();
        
        List<String> fieldList = new List<String>{'REN_Renewal_Target__c','REN_Renewal_Target_Multiplier__c', 'REN_Previous_Price__c' };

        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ);
        String queryString = 'Select id,REN_Renewal_Target_Multiplier__c,REN_Previous_Price__c';
        
        String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', solnExtnNamespace + 'Local_Renewal_Target__c');
        if(isSolutionExtnInstalled){
            queryString += ', ' + solnExtnNamespace + 'Previous_Local_Currency_Code__c' + ', ' + solnExtnNamespace + 'Previous_Local_Currency_Amount__c';
        }
        if(setRenewalIds != null){
            
                queryString += ' From REN_Renews_To__c WHERE Id IN :setRenewalIds';
        }
        system.debug('\n\n~~~~ queryString:' + queryString);
        renewalRelationshipList = Database.query(queryString);
        return renewalRelationshipList;
    }
    

    public static List<REN_Renews_To__c> getRenewalRelationshipByFilter(Set<String> fieldSet, String filter) {
        List<String> fieldList = new List<String>();
        fieldList.addAll(fieldSet);
        
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ);
        
        String selectFields = String.join(fieldList, ', ');
        
        String queryString = 'SELECT ' + selectFields + ' FROM REN_Renews_To__c ';
        
        if(String.isNotEmpty(filter)) {
            queryString += ' ' + filter;
        }
        queryString += ' Limit 40000';
        
        System.debug('getRenewalRelationshipByFilter : ------>' + queryString);
        return Database.query(queryString);
    }

    public static List<REN_Renews_To__c> getRenewalRelationshipByIds(Set<String> fieldSet,Set<String> setRenewalIds){
        return getRenewalRelationshipByIds(fieldSet, setRenewalIds, fieldSet);
    }
    
    public static List<REN_Renews_To__c> getRenewalRelationshipByIds(Set<String> fieldSet,Set<String> setRenewalIds, Set<String> fieldNameSetCrudFlsCheck){
        List<REN_Renews_To__c> renewalRelationshipList = new List<REN_Renews_To__c>();
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, new List<String>(fieldNameSetCrudFlsCheck), CSM_Constants.DML_OPERATION_READ);
        String commaSepratedList= String.join(new List<String>(fieldSet), ',');
        String queryString = 'Select '+commaSepratedList+' from REN_Renews_To__c';
        if(setRenewalIds != null){
            integer recordLimit = (integer)getCSMAdminInstance().REN_Manage_Renewal_Records_Limit__c;
            if(recordLimit != null){
                queryString += ' WHERE Id IN :setRenewalIds limit '+recordLimit;
            }
            else{
                queryString += ' WHERE Id IN :setRenewalIds';
            }
        }
        system.debug(setRenewalIds + '\n\n~~~~ queryString:' + queryString);
        renewalRelationshipList = Database.query(queryString);
        return renewalRelationshipList;
    }
    
    public static List<REN_Renews_To__c> getRenewalRelationshipByOpportunityIds(Set<ID> oppIdSet, Set<String> fieldSet, Set<String> fieldNameSetCrudFlsCheck,Integer recLimit){
        List<REN_Renews_To__c> renewalRelationshipList = new List<REN_Renews_To__c>();
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, new List<String>(fieldNameSetCrudFlsCheck), CSM_Constants.DML_OPERATION_READ);
        String commaSepratedList= String.join(new List<String>(fieldSet), ',');
        String queryString = 'Select '+commaSepratedList+' from REN_Renews_To__c';
        if(oppIdSet != null && !oppIdSet.isEmpty()){
            queryString += ' WHERE REN_Renews_To__c IN :oppIdSet ';
        }
        if(recLimit!=NULL){
            queryString += ' limit :recLimit';
        }
        system.debug(oppIdSet + '\n\n~~~~ queryString:' + queryString);
        renewalRelationshipList = Database.query(queryString);
        return renewalRelationshipList;
    }
    
    //Added for US392
    public static void deleteRenewalRelationship(List<REN_Renews_To__c> renewRelationshipList){
                            
        List<String> fieldList = new List<String>{'REN_Renews_To__c', 'REN_Asset__c','Name', 'Id'};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_DELETE);
        
        delete renewRelationshipList;
    }
    
    public static List<REN_Renews_To__c> getLstRenewalRelationships(List<Asset> lstAsset){
                            
        List<String> renwalFieldsLst = new List<String>{REN_Constants.OBJ_REN_RENEWS_TO_ASSET, 
                                                           REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO, renwalFieldsLst, CSM_Constants.DML_OPERATION_UPDATE); 
       
        return [Select Id, REN_Asset__c, REN_Renews_To__c From REN_Renews_To__c Where REN_Asset__c IN :lstAsset];
            
    }
    
    public static List<REN_Renews_To__c> getLstRenRelationshipsByContractIds(set<Id> setChangedContractIds){
        List<String> fieldList = new List<String>{'REN_Renews_To__c','REN_Asset__c','REN_Renewal_Target__c', 'REN_End_Date__c', 'REN_Renewal_Target_Multiplier__c', 'REN_Renewal_Status__c', 'REN_Previous_Price__c'};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ); 
        String renewalRelationshipQ = 'Select REN_Renews_To__c,REN_Asset__c, REN_Renewal_Target__c, ' + 
                                                'REN_End_Date__c, REN_Renewal_Target_Multiplier__c, REN_Renewal_Status__c, REN_Previous_Price__c';
            // VCP - ORG21 check
            if(CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM)) {
                // VCP - ORG21 check
                renewalRelationshipQ += ', ' + CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM;
            }
            renewalRelationshipQ += ' From REN_Renews_To__c ';
            // VCP - ORG21 check
            if(CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM)) {
                // VCP - ORG21 check
                renewalRelationshipQ += 'WHERE '+CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM +' IN :setChangedContractIds';
            }
            
            system.debug('renewalRelationshipQ before Query : ' + renewalRelationshipQ);
            return Database.query(renewalRelationshipQ);
            
    }
    
    public static List<REN_Renews_To__c> getLstRenRelationshipsByRenewalProductLineID(set<Id> setenewalProductLineIds){
        List<String> fieldList = new List<String>{'REN_Asset__c'};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ); 
        String qryString = 'SELECT REN_Asset__c';
            
        // VCP - ORG21 check
        if (CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM)){
            qryString += ', ' + CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM;
        }
            
        qryString += ' FROM REN_Renews_To__c where Id in :setenewalProductLineIds';
            
        system.debug('qryString : ' + qryString);
        return Database.query(qryString);
    }
    
    public static List<REN_Renews_To__c> getLstRenRelationshipByRenewalStatus(List<Opportunity> oppList){
        List<String> fieldList = new List<String>{ 'REN_Renewal_Status__c'};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ); 
        String qryString = 'Select Id,REN_Renewal_Status__c from REN_Renews_To__c where REN_Renews_To__c IN : oppList';
        system.debug('qryString : ' + qryString);
        return Database.query(qryString);
    }
    
   public static List<REN_Renews_To__c> getLstRenRelationshipByOppSet(Set<String> opptyIds){
        List<String> fieldList = new List<String>{'REN_Product__c','REN_Renewal_Status__c','REN_Quantity__c','REN_New_End_Date__c','REN_New_Start_Date__c','REN_Previous_Price__c','REN_Start_Date__c','REN_End_Date__c'};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ); 
        String qryString = 'Select Id, REN_Renewal_Status__c, REN_Renews_To__c,REN_End_Date__c,REN_Product__c,REN_Quantity__c,REN_New_Start_Date__c,REN_New_End_Date__c,REN_Previous_Price__c,REN_Start_Date__c from REN_Renews_To__c where REN_Renews_To__c IN : opptyIds';
        system.debug('qryString : ' + qryString);
        return Database.query(qryString);
    }
    
   
    public static List<Database.SaveResult> insertRenewalRelationship(List<SObject> renewalRelationshipList){
        List<Database.SaveResult> queryResultList = null;
        if(!renewalRelationshipList.isEmpty()){
            List<String> renewalRelationshipFieldList = new List<String>{REN_Constants.OBJ_REN_RENEWS_TO_ASSET, 
                                                            REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO,
                                                            //REN_Constants.OBJ_REN_RENEWS_TO_ORIG_LINE_ITEM,
                                                            REN_Constants.OBJ_REN_RENEWS_TO_PREVIOUS_PRICE,
                                                            REN_Constants.OBJ_REN_RENEWS_TO_END_DATE,
                                                            REN_Constants.OBJ_REN_RENEWS_TO_START_DATE};     
            CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO, renewalRelationshipFieldList, CSM_Constants.DML_OPERATION_INSERT);                                                
            queryResultList = Database.insert(renewalRelationshipList , false);
        }
        return queryResultList;
    }
    public static void updateRenewalRelationship(List<REN_Renews_To__c> renewRelationshipList,  List<String> fieldList){
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_UPDATE);    
        update renewRelationshipList;  
    }
    public static List<REN_Renews_To__c> getRliList(Set<ID> rliIdSet,  List<String> fieldList){
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ);    
        String qryString = 'SELECT '+ String.join(fieldList, ',') + ' FROM REN_Renews_To__c '+ 'WHERE ID in :rliIdSet';
        return Database.query(qryString);
    }
    public static void insertRLI(List<REN_Renews_To__c> renewRelationshipList,  List<String> fieldList){
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_INSERT);    
        insert renewRelationshipList;  
    }
    public static List<SObject> getRenRelationshipBySOSL(CHL_GridInputWrapper inputWrapper)
    {
        List<SObject> renewalLst = new List<sObject>();
        String namespacePrefix = CSM_Util.getNamespace();
        String fieldList = CHL_Util.getQueryStringFromFieldSet(namespacePrefix + CHL_Constants.PARTNER_REN_RELATIONSHIP_FIELDSET_NAME,namespacePrefix + 'REN_Renews_To__c' );
        fieldList = fieldList.removeStartIgnoreCase('select ');
        fieldList = fieldList.removeEndIgnoreCase(' from '+namespacePrefix + 'REN_Renews_To__c');
        system.debug('fieldList AFTER Remove '+fieldList);
        Integer queryLimit = inputWrapper.lm == 5 ? 5 : 2000;
        String queryString = 'FIND\''+ inputWrapper.q +'*\' IN All Fields Returning ' + namespacePrefix + REN_Constants.OBJ_REN_RENEWS_TO+ ' ('+fieldList+' ORDER BY Id Desc) Limit '+queryLimit;
        List<List<SObject>>searchList = search.query(queryString);
        system.debug('searchList::'+searchList);
        if(searchList != null && searchList.size()>0){
            renewalLst.addAll(searchList[0]);
        }
        return renewalLst;
    }
    
    public static List<REN_Renews_To__c> getRRByIds(Set<String> setRenewalIds){
        List<REN_Renews_To__c> renewalRelationshipList = new List<REN_Renews_To__c>();
        List<String> fieldList = new List<String>{'Id'};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, fieldList, CSM_Constants.DML_OPERATION_READ);
        String queryString = 'Select id, Name from REN_Renews_To__c';
        if(setRenewalIds != null){
            integer recordLimit = (integer)getCSMAdminInstance().REN_Manage_Renewal_Records_Limit__c;
            if(recordLimit != null) {
                queryString += ' WHERE Id IN :setRenewalIds limit '+recordLimit;
            } else {
                queryString += ' WHERE Id IN :setRenewalIds';
            }
        }
        system.debug('\n\n~~~~ queryString:' + queryString);
        renewalRelationshipList = Database.query(queryString);
        return renewalRelationshipList;
    }
}