/**
 * Created Date     : June 15, 2018
 * Developed By     : Nidhi, Comity Designs, Inc.
 *
 * Function         : This class creates default records of RS Cofigration,RS Field mapping and RS DynamicButton for Dell Automation flows.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                 US3529            June 15, 2018            1.1                 @description
 *
 */
public with sharing class Dell_AutomationConfigScript {
    
    /*@description : This method insert\update records with default values of RS Cofigration,RS Field mapping and RS DynamicButton for Dell Automation flows. */
    public static void createFlowsData(){
        
        /* Assignment PS to Users */
        userAssignmentToDellPS();
        
        Savepoint sp = Database.setSavepoint();
        try{
           /* RS Config Rec */
            Map<String,Id> rsConfigFlowNameIdMap  = rsConfigRec();
        
            /* RS FieldMapping Rec */
            rsFieldMappingRec(rsConfigFlowNameIdMap);

            /* RS Dynamic_Button data */
            rsDynamicButtonsRec(rsConfigFlowNameIdMap);
        } catch (Exception e) {
            System.debug('@@@ rollback=== ' + e);
            Database.rollback(sp);
        }
         
        
    }

    /************************ START -- RS Config Records *************************/

    /*@description : This method is used to create\Update default records of RS Cofigration for Dell Automation flows. 
      @ return param : Returns Map --> Key as FlowName and value --> record Id of the particular Flow.
    */
    private static Map<String,Id> rsConfigRec() {
        Map<String,Id> rsConfigFlowNameIdMap = new Map<String,Id>();
        Map<String,REN_RS_Config__c> rsConfigExistingRec = new Map<String,REN_RS_Config__c>();
        List<REN_RS_Config__c> rsConfigList;
        List<REN_RS_Config__c> existingRSConfigList = [SELECT REN_Columns__c,REN_Custom_Object__c,REN_Display_Dialog__c,REN_Display_Response_Dialog__c,REN_Flow_Name__c,REN_Invoking_Object__c, REN_Named_Credential__c,
                                                       REN_Named_Credential_URL_Extension__c, REN_Number_Of_Columns__c, REN_Response_Object__c, REN_SOQL__c 
                                                       FROM REN_RS_Config__c WHERE REN_Flow_Name__c IN ('NewQuote','Credit Balance','New and Configure Quote','Configure Quote','Configure','Validate','Create Order') ];

        if(existingRSConfigList != null){
            for(REN_RS_Config__c rsConfigObj : existingRSConfigList){
                rsConfigExistingRec.put(rsConfigObj.REN_Flow_Name__c+':'+rsConfigObj.REN_Invoking_Object__c, rsConfigObj);
            }
        } 

        rsConfigList = createRSConfigRec(rsConfigExistingRec);
        upsert rsConfigList;

        if(rsConfigList != null){
            for(REN_RS_Config__c rsConfigObj : rsConfigList){
                rsConfigFlowNameIdMap.put(rsConfigObj.REN_Flow_Name__c+':'+rsConfigObj.REN_Invoking_Object__c, rsConfigObj.id);
            }
        }
        return rsConfigFlowNameIdMap;
    }

    /*@description : This method is used to create default records of RS Cofigration for Dell Automation flows. */
    private static List<REN_RS_Config__c> createRSConfigRec(Map<String,REN_RS_Config__c> rsConfigExistingRecMap) {

        List<REN_RS_Config__c> rsConfigList = new List<REN_RS_Config__c>();

        rsConfigList.add(getRSConfigObj('','NewQuote_Request__c',true,true,'NewQuote','Opportunity','RS_Echo','/odata/frb1/dell/opportunity/dell.NewQuote',
                '2','NewQuote_Response__c','Select Id, SyncedQuoteId, OwnerId, AccountId from  Opportunity where id = ',rsConfigExistingRecMap));

        rsConfigList.add(getRSConfigObj('','Credit_Balance_Request__c',true,true,'Credit Balance',
                'Opportunity','RS_Echo','/odata/frb1/dell/opportunity/dell.CreditBalance','2','Credit_Balance_Response__c','Select Account.client_company_id__c,Account.account_picklist_1__c from Opportunity where id = ', rsConfigExistingRecMap ));
        
        rsConfigList.add(getRSConfigObj('','New_Configure_Quote_Request__c',true,true,'New and Configure Quote',
                'Opportunity','RS_Echo','/odata/frb1/dell/opportunity/dell.NewQuote','2','New_Configure_Quote_Response__c','Select Id, SyncedQuoteId, OwnerId,AccountId from Opportunity where id = ', rsConfigExistingRecMap));
       
        rsConfigList.add(getRSConfigObj('','Credit_Balance_Request__c',true,true,'Credit Balance',
                'Quote','RS_Echo','/odata/frb1/dell/quote/dell.CreditBalance','2','Credit_Balance_Response__c','Select Account.client_company_id__c,Account.account_picklist_1__c from Quote where id = ', rsConfigExistingRecMap ));

        rsConfigList.add(getRSConfigObj('','Configure_Request__c',true,true,'Configure',
                'Quote','RS_Echo','/odata/frb1/dell/quote/dell.Configure','2','Configure_Response__c','Select Id from Quote where id = ', rsConfigExistingRecMap ));
        
        rsConfigList.add(getRSConfigObj('','Validate_Request__c',true,true,'Validate',
                'Quote','RS_Echo','/odata/frb1/dell/quote/dell.Validate','2','Validate_Response__c','Select Id from Quote where id = ', rsConfigExistingRecMap ));
        
        rsConfigList.add(getRSConfigObj('',
                'Create_Order_Request__c',true,true,'Create Order',
                'Quote','RS_Echo','/odata/frb1/dell/quote/dell.CollectPayment','2','Create_Order_Response__c','Select id,currencyISOCOde from Quote where id = ', rsConfigExistingRecMap ));
        
        rsConfigList.add(getRSConfigObj('','Credit_Balance_Request__c',true,true,'Credit Balance',
                'Account','RS_Echo','/odata/frb1/dell/account/dell.CreditBalance','2','Credit_Balance_Response__c','Select client_company_id__c,account_picklist_1__c from Account where id = ', rsConfigExistingRecMap ));
        
        return rsConfigList;
    }

    /*
     * @description : This method returns a object of RS Cofigration and it checks key in map. If key is present then it will update the existing RS Cofigration records.
                      If not then it will create new object of RS Cofigration.
    */
    private static REN_RS_Config__c getRSConfigObj(String columnsName, String customObj, Boolean displayDialog, Boolean displayResposeDialog, String flowName, String invokingObj, String namedCredential, String  namedCredentialUrlExt, String noOfCol, String responseObj, String soql, Map<String,REN_RS_Config__c> rsConfigExistingRecMap){
        REN_RS_Config__c rsConfigObj;
        if(rsConfigExistingRecMap.containsKey(flowName+':'+invokingObj)){
            rsConfigObj = (REN_RS_Config__c) rsConfigExistingRecMap.get(flowName+':'+invokingObj);
        } else {
            rsConfigObj = new REN_RS_Config__c();
        }   
        rsConfigObj.REN_Columns__c = columnsName;
        rsConfigObj.REN_Custom_Object__c = customObj;
        rsConfigObj.REN_Display_Dialog__c = displayDialog;
        rsConfigObj.REN_Display_Response_Dialog__c  = displayResposeDialog;
        rsConfigObj.REN_Flow_Name__c = flowName;
        rsConfigObj.REN_Invoking_Object__c = invokingObj;
        rsConfigObj.REN_Named_Credential__c = namedCredential;
        rsConfigObj.REN_Named_Credential_URL_Extension__c = namedCredentialUrlExt;
        rsConfigObj.REN_Number_Of_Columns__c = noOfCol;
        rsConfigObj.REN_Response_Object__c = responseObj;
        rsConfigObj.REN_SOQL__c = soql;
        return rsConfigObj;

    }

    /************************ END -- RS Config Records **********************************/

    /************************ START -- RS FieldMapping Records *************************/

    /*@description : This method is used to create\Update default records of RS Field Mapping for Dell Automation flows. 
                     Created Map --> Key as RS Config Id + Mapped Field Name + Input Type and value --> FieldMApping Obj.
    */
    private static void rsFieldMappingRec( Map<String,Id> rsConfigFlowNameIdMap) {
        Map<String,REN_RS_Field_Mapping__c> rsFieldMappingExistingRec = new Map<String,REN_RS_Field_Mapping__c>();
        system.debug('@@@ rsConfigFlowNameIdMap.keySet() '+rsConfigFlowNameIdMap.keySet());
        
        List<REN_RS_Field_Mapping__c> existingRSFieldMappingList = [SELECT REN_Custom_Mapped_Field__c,REN_Editable__c,REN_Filter__c,REN_oData_Action_Name__c,REN_oData_Param_Label__c,REN_oData_Param__c,REN_Param_Type__c,REN_RS_Config__c 
                                                                    FROM REN_RS_Field_Mapping__c WHERE REN_RS_Config__c IN :rsConfigFlowNameIdMap.values()];

        system.debug('@@@ existingRSFieldMappingList '+existingRSFieldMappingList);
        if(existingRSFieldMappingList != null){
            for(REN_RS_Field_Mapping__c rsFieldMappingObj : existingRSFieldMappingList){
                rsFieldMappingExistingRec.put(rsFieldMappingObj.REN_RS_Config__c+':'+rsFieldMappingObj.REN_Custom_Mapped_Field__c+':'+rsFieldMappingObj.REN_Param_Type__c, rsFieldMappingObj);
            }
        } 

        List<REN_RS_Field_Mapping__c> rsFieldMappingList = createRSFieldMappingRec(rsConfigFlowNameIdMap,rsFieldMappingExistingRec);
        system.debug('@@ rsFieldMappingList '+ rsFieldMappingList);
        upsert rsFieldMappingList;
    }

    /* @description : This method is used to create RS Field mapping records for Dell Automation flows. */
    private static List<REN_RS_Field_Mapping__c> createRSFieldMappingRec( Map<String,Id> rsConfigFlowNameIdMap,Map<String,REN_RS_Field_Mapping__c> rsFieldMappingExistingRecMap) {
        List<REN_RS_Field_Mapping__c> rsFieldMappingList = new List<REN_RS_Field_Mapping__c>();
        system.debug('@@ rsConfigFlowNameIdMap Map' + rsConfigFlowNameIdMap);
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('NewQuote:Opportunity'),'oppId__c',true,'oppId','Input','Id',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('NewQuote:Opportunity'),'syncedQuoteId__c',true,'syncedQuoteId','Input','syncedQuoteId',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('NewQuote:Opportunity'),'salesRepId__c',true,'salesRepId','Input','OwnerId',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('NewQuote:Opportunity'),'customerId__c',true,'customerId','Input','AccountId',rsFieldMappingExistingRecMap));
        
        //Credit Balance flow
        //Request - Opp
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'buId__c',true,'buId','Input','Account.account_picklist_1__c',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'customerNumber__c',true,'customerNumber','Input','Account.client_company_id__c',rsFieldMappingExistingRecMap));
        //Response - Opp
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'id__c',false,'_id','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'creditBalance__c',false,'creditBalance','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'creditLimit__c',false,'creditLimit','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'debtsTotal__c',false,'debtsTotal','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'externalExposure__c',false,'externalExposure','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'onholdOrders__c',false,'onholdOrders','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'openTransactions__c',false,'openTransactions','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'releasedOrders__c',false,'releasedOrders','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'remainingCredit__c',false,'remainingCredit','Output','',rsFieldMappingExistingRecMap));
        
        //Request - Quote
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'buId__c',true,'buId','Input','Account.account_picklist_1__c',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'customerNumber__c',true,'customerNumber','Input','Account.client_company_id__c',rsFieldMappingExistingRecMap));
        //Response - Quote
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'id__c',false,'_id','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'creditBalance__c',false,'creditBalance','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'creditLimit__c',false,'creditLimit','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'debtsTotal__c',false,'debtsTotal','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'externalExposure__c',false,'externalExposure','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'onholdOrders__c',false,'onholdOrders','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'openTransactions__c',false,'openTransactions','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'releasedOrders__c',false,'releasedOrders','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'remainingCredit__c',false,'remainingCredit','Output','',rsFieldMappingExistingRecMap));
        
        //Request - Account
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'buId__c',true,'buId','Input','account_picklist_1__c',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'customerNumber__c',true,'customerNumber','Input','client_company_id__c',rsFieldMappingExistingRecMap));
        
        //Response - Account
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'id__c',false,'_id','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'creditBalance__c',false,'creditBalance','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'creditLimit__c',false,'creditLimit','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'debtsTotal__c',false,'debtsTotal','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'externalExposure__c',false,'externalExposure','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'onholdOrders__c',false,'onholdOrders','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'openTransactions__c',false,'openTransactions','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'releasedOrders__c',false,'releasedOrders','Output','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'remainingCredit__c',false,'remainingCredit','Output','',rsFieldMappingExistingRecMap));
        
        
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('New and Configure Quote:Opportunity'),'oppId__c',true,'oppId','Input','Id',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('New and Configure Quote:Opportunity'),'syncedQuoteId__c',true,'syncedQuoteId','Input','syncedQuoteId',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('New and Configure Quote:Opportunity'),'salesRepId__c',true,'salesRepId','Input','OwnerId',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('New and Configure Quote:Opportunity'),'customerId__c',true,'customerId','Input','AccountId',rsFieldMappingExistingRecMap));
        
        
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure:Quote'),'quoteId__c',true,'quoteId','Input','Id',rsFieldMappingExistingRecMap));
        
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Validate:Quote'),'quoteId__c',true,'quoteId','Input','Id',rsFieldMappingExistingRecMap));
        
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'quoteId__c',true,'quoteId','Input','Id',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'poNumber__c',true,'poNumber','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'soNumber__c',true,'soNumber','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'soAmount__c',true,'soAmount','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'soDate__c',true,'soDate','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'soAmountCurrencyCode__c',true,'soAmountCurrencyCode','Input','currencyISOCOde',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'winResultReason__c',true,'winResultReason','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'dealRegistrationNumber__c',true,'dealRegistrationNumber','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'failureUrl__c',false,'failureUrl','Input','$baseURL/$ID',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'successUrl__c',false,'successUrl','Input','$baseURL/$ID',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'emailToCustomer__c',true,'emailToCustomer','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'emailToSalesRep__c',true,'emailToSalesRep','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'sendByPost__c',true,'sendByPost','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'customerComplianceStatus__c',true,'customerComplianceStatus','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'verifiedAddress__c',true,'verifiedAddress','Input','',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'orderNotes__c',true,'orderNotes','Input','',rsFieldMappingExistingRecMap));
        return rsFieldMappingList;
        
    }

    /* @description : This method is used to create RS Field Mapping object as per the provided parameters.*/
    private static REN_RS_Field_Mapping__c getRSFieldMappingObj(Id rsConfigId, String customMappedField, boolean isEditable, String oDataParam, String oDataParamType, String objFieldName, Map<String,REN_RS_Field_Mapping__c> rsFieldMappingExistingRecMap){
        REN_RS_Field_Mapping__c rsFieldMappingObj;
        system.debug('@@ Map' + rsFieldMappingExistingRecMap);
        system.debug('@@@ Key :: ' + rsConfigId+':'+customMappedField+':'+oDataParamType);
        if(rsFieldMappingExistingRecMap.containsKey(rsConfigId+':'+customMappedField+':'+oDataParamType)){
            rsFieldMappingObj = (REN_RS_Field_Mapping__c) rsFieldMappingExistingRecMap.get(rsConfigId+':'+customMappedField+':'+oDataParamType);
        } else {
            rsFieldMappingObj = new REN_RS_Field_Mapping__c();
            rsFieldMappingObj.REN_RS_Config__c = rsConfigId;
            
        }   
        rsFieldMappingObj.REN_Custom_Mapped_Field__c = customMappedField;
        rsFieldMappingObj.REN_Editable__c = isEditable;
        //rsFieldMappingObj.REN_oData_Action_Name__c = oDataActionName;
        rsFieldMappingObj.REN_oData_Param__c = oDataParam;
        //rsFieldMappingObj.REN_oData_Param_Label__c = oDataParamLabel;
        rsFieldMappingObj.REN_Param_Type__c = oDataParamType;
        rsFieldMappingObj.REN_Object_Field_Name__c = objFieldName;
        return rsFieldMappingObj;
    }

    /************************ END -- RS FieldMapping Records *****************************/

    /************************ START -- RS Dynamic Button Records *************************/

    private static void rsDynamicButtonsRec(Map<String,Id> rsConfigFlowNameIdMap){
        List<REN_RS_Dynamic_Button__c> rsDynamicButtonExistingList = [select REN_RS_Action__c,REN_RS_Button_Criteria__c, REN_RS_Button_Label__c, REN_RS_Configuration__c from REN_RS_Dynamic_Button__c];
        Map<String, REN_RS_Dynamic_Button__c>  rsDynamicButtonMap = new Map<String, REN_RS_Dynamic_Button__c>();
        if(rsDynamicButtonExistingList != null){
            for(REN_RS_Dynamic_Button__c rsDynamicButtonObj : rsDynamicButtonExistingList){
                rsDynamicButtonMap.put(rsDynamicButtonObj.REN_RS_Configuration__c+':'+rsDynamicButtonObj.REN_RS_Button_Label__c, rsDynamicButtonObj);
            }
        }
        createRSDynamicButtonsRec(rsConfigFlowNameIdMap,rsDynamicButtonMap);
    }

    /* @description : This method is used to create RS Dynamic Button records for Dell Automation flows. */
    private static List<REN_RS_Dynamic_Button__c> createRSDynamicButtonsRec(Map<String,Id> rsConfigFlowNameIdMap, Map<String, REN_RS_Dynamic_Button__c>  rsDynamicButtonMap) {
        //Need to add criteria temp added pending...
        List<REN_RS_Dynamic_Button__c> rsDynamicButtonList = new List<REN_RS_Dynamic_Button__c>();
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=NewQuote&id=', '',
                                                      'New Quote', rsConfigFlowNameIdMap.get('NewQuote:Opportunity'), rsDynamicButtonMap));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Credit Balance&id=','Account.account_picklist_1__c  IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3232\',\'3434\',\'3838\',\'439\',\'1313\',\'1401\',\'1717\', \'1841\',\'3535\',\'4013\',\'4042\',\'4046\',\'4065\',\'4075\',\'4081\',\'4444\',\'4545\',\'7460\',\'7465\',\'8242\',\'8270\',\'340000\',\'340434\',\'340439\',\'340442\',\'340443\', \'348270\')',
                                                      'Credit Balance', rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'), rsDynamicButtonMap));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Credit Balance&id=', 'Account.account_picklist_1__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3232\',\'3434\',\'3838\',\'439\',\'1313\',\'1401\',\'1717\', \'1841\',\'3535\',\'4013\',\'4042\',\'4046\',\'4065\',\'4075\',\'4081\',\'4444\',\'4545\',\'7460\',\'7465\',\'8242\',\'8270\',\'340000\',\'340434\',\'340439\',\'340442\',\'340443\', \'348270\')',
                                                      'Credit Balance', rsConfigFlowNameIdMap.get('Credit Balance:Quote'), rsDynamicButtonMap));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Credit Balance&id=', 'account_picklist_1__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3232\',\'3434\',\'3838\',\'439\',\'1313\',\'1401\',\'1717\', \'1841\',\'3535\',\'4013\',\'4042\',\'4046\',\'4065\',\'4075\',\'4081\',\'4444\',\'4545\',\'7460\',\'7465\',\'8242\',\'8270\',\'340000\',\'340434\',\'340439\',\'340442\',\'340443\', \'348270\')',
                                                       'Credit Balance', rsConfigFlowNameIdMap.get('Credit Balance:Account'), rsDynamicButtonMap));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=New and Configure Quote&id=', 'Account.account_picklist_1__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3232\',\'3434\',\'3838\',\'439\',\'1313\',\'1401\',\'1717\', \'1841\',\'3535\',\'4013\',\'4042\',\'4046\',\'4065\',\'4075\',\'4081\',\'4444\',\'4545\',\'7460\',\'7465\',\'8242\',\'8270\',\'340000\',\'340434\',\'340439\',\'340442\',\'340443\', \'348270\') and StageName NOT IN (\'PO Received\', \'Closed Sale\', \'No Service\', \'House Account, Open - Consolidated\')',
                                                       'New and Configure Quote', rsConfigFlowNameIdMap.get('New and Configure Quote:Opportunity'), rsDynamicButtonMap));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Configure&id=', 'Opportunity.StageName NOT IN (\'PO Received\', \'Closed Sale\', \'No Service\', \'House Account, Open - Consolidated\')',
                                                       'Configure', rsConfigFlowNameIdMap.get('Configure:Quote'), rsDynamicButtonMap));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Validate&id=', 'Account.account_picklist_1__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3232\',\'3434\',\'3838\',\'439\',\'1313\',\'1401\',\'1717\', \'1841\',\'3535\',\'4013\',\'4042\',\'4046\',\'4065\',\'4075\',\'4081\',\'4444\',\'4545\',\'7460\',\'7465\',\'8242\',\'8270\',\'340000\',\'340434\',\'340439\',\'340442\',\'340443\', \'348270\')', 
                                                      'Validate', rsConfigFlowNameIdMap.get('Validate:Quote'), rsDynamicButtonMap));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Create Order&id=', 'Opportunity.StageName NOT IN (\'PO Received\', \'Closed Sale\', \'No Service\', \'House Account\', \'Open - Consolidated\') AND Status =\'Validated\'', 
                                                       'Create Order', rsConfigFlowNameIdMap.get('Create Order:Quote'), rsDynamicButtonMap));
        upsert rsDynamicButtonList;
        return rsDynamicButtonList;
    }

    /* @description : This method is used to create RS Dynamic Button object as per the provided parameters.*/
    private static REN_RS_Dynamic_Button__c getRSDyanmicButtonsObj(String actionName, String buttonCriteria, String buttonLabel, Id rsConfigId, Map<String, REN_RS_Dynamic_Button__c>  rsDynamicButtonMap){
        REN_RS_Dynamic_Button__c dynamicButtonObj;
        if(rsDynamicButtonMap.containsKey(rsConfigId+':'+buttonLabel)){
            dynamicButtonObj = (REN_RS_Dynamic_Button__c) rsDynamicButtonMap.get(rsConfigId+':'+buttonLabel);
        }else {
            dynamicButtonObj = new REN_RS_Dynamic_Button__c();
            dynamicButtonObj.REN_RS_Configuration__c = rsConfigId;
        }
        dynamicButtonObj.REN_RS_Action__c = actionName;
        dynamicButtonObj.REN_RS_Button_Criteria__c =  buttonCriteria;
        dynamicButtonObj.REN_RS_Button_Label__c = buttonLabel; 
        return dynamicButtonObj;
    }

    /************************ END -- RS Dynamic Button Records *************************/  
    
    
    /* This method used to assigned new PS - Prism Dell Automation, to all the active users who have 'Prism' profile. */
    @future
    public static void userAssignmentToDellPS() {
        List<User> userList = [Select id,name,Profile.Name from User where Profile.Name like '%Prism%' and isActive = true];
        List<PermissionSetAssignment>  psaList  = new List<PermissionSetAssignment>();
        PermissionSet ps = [SELECT name,ProfileId FROM PermissionSet where name = 'Prism_Dell_Automation'];
            
        if(userList != null && ps != null){
            for(User user : userList){
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psaList.add(new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = user.id));
            }
        }
        
        if(psaList != null){
            insert psaList;
        }
    }  
}