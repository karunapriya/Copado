/**
 * Created Date		: Jul 2, 2018
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This class creates default records of RS Cofigration,RS Field mapping, RS Lookup Field Mapping and RS DynamicButton for Dell Features.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					User Story				Jul 2, 2018			1.1					@description
 *
 */
public with sharing class Dell_RSConfigurationScript {
	
	public static void createRSConfiguration(){
		
		/* Assignment PS to Users */
        userAssignmentToDellFeaturesPS();
        
		Savepoint sp = Database.setSavepoint();
		 
		try{
            /* RS Config Rec */
            Map<String,Id> rsConfigFlowNameIdMap  = rsConfigRec();
            
            /* RS Lookup Field Mapping Rec */
            insertLookupFieldMappingRecords(rsConfigFlowNameIdMap);
        
            /* RS FieldMapping Rec */
            rsFieldMappingRec(rsConfigFlowNameIdMap);

            /* RS Dynamic_Button data */
            rsDynamicButtonsRec(rsConfigFlowNameIdMap);
            
            /* RS Field Operator data */
            upsertCustomFieldOperators(rsConfigFlowNameIdMap);
            
        } catch (Exception ex) {
            Database.rollback(sp);
    		System.debug('**ex ' + ex.getMessage());
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
        List<REN_RS_Config__c> newNConfigRSConfigList = [SELECT ID FROM REN_RS_Config__c WHERE REN_Flow_Name__c IN ('New and Configure Quote','Credit Balance','Configure New Quote','Configure','Validate','Create Order')];
        if(newNConfigRSConfigList != null && !newNConfigRSConfigList.isEmpty()) {
        	delete newNConfigRSConfigList;
        }
        
        Set<String> flowNameSet = new Set<String>{'Credit Balance','Configure New Quote','Configure','Validate','Create Order','IB Export','Generate IB Export','IB Export Download','s3_presigned_url','Quote Import'};
        List<REN_RS_Config__c> existingRSConfigList = [SELECT REN_Columns__c,REN_Custom_Object__c,REN_Display_Dialog__c,REN_Display_Response_Dialog__c,
																		REN_Flow_Name__c,REN_Invoking_Object__c, REN_Named_Credential__c, REN_Response_Object_Field_Set_Name__c, REN_Field_Set_Name__c,
																	   REN_Named_Credential_URL_Extension__c, REN_Number_Of_Columns__c, REN_Response_Object__c, REN_SOQL__c, REN_Custom_Permission_Name__c 
																	   FROM REN_RS_Config__c WHERE REN_Flow_Name__c IN  :flowNameSet];

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
		
        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Credit_Balance_Request__c',false,true,'Credit Balance',
                'Opportunity','RS_ODATA','/opportunity/dell.CreditBalance','2','Credit_Balance_Response__c',
				'Select Account.Client_Company_ID__c,Account.Account_Picklist_1__c from Opportunity where id = ', 
				'Credit_Balance_Request_Fieldset','Credit_Balance_Response_Fieldset', '', rsConfigExistingRecMap, 'Submit','Back to Opportunity' )));
        
        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Configure_New_Quote_Request__c',false,true,'Configure New Quote',
                'Opportunity','RS_ODATA','/opportunity/dell.NewQuote','2','Configure_New_Quote_Response__c',
				'Select Id, SyncedQuoteId, OwnerId, AccountId, Inside_Sales_Rep_ISR__c from Opportunity where id = ',
				'Configure_New_Quote_Request_Fieldset','Configure_New_Quote_Response_Fieldset',  '', rsConfigExistingRecMap, 'Submit','Cancel')));
       
        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Credit_Balance_Request__c',false,true,'Credit Balance',
                'Quote','RS_ODATA','/quote/dell.CreditBalance','2','Credit_Balance_Response__c',
				'Select Account.Client_Company_ID__c,Account.Account_Picklist_1__c from Quote where id = ',
				'Credit_Balance_Request_Fieldset','Credit_Balance_Response_Fieldset', '', rsConfigExistingRecMap,'Submit','Back to Quote' )));

        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Configure_Request__c',false,true,'Configure',
                'Quote','RS_ODATA','/quote/dell.Configure','2','Configure_Response__c','Select Id, Opportunity.OwnerId, AccountId, Opportunity.Inside_Sales_Rep_ISR__c from Quote where id = ',
				'Configure_Request_Fieldset','Configure_Response_Fieldset','', rsConfigExistingRecMap,'Submit','Cancel' )));
        
        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Validate_Request__c',false,true,'Validate',
                'Quote','RS_ODATA','/quote/dell.Validate','2','Validate_Response__c','Select Id,Opportunity.OwnerId, AccountId, Opportunity.Inside_Sales_Rep_ISR__c from Quote where id = ', 
				'Validate_Request_Fieldset','Validate_Response_Fieldset','', rsConfigExistingRecMap,'Submit','Cancel' )));
        
        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Create_Order_Request__c',true,true,'Create Order',
				'Quote','RS_ODATA','/quote/dell.CollectPayment','2','Create_Order_Response__c',
				'Select id,Local_Currency_Code__c,LocalCurrency_Amount_Rollup__c, OpportunityId from Quote where id = ','Create_Order_Request_Fieldset',
				'Create_Order_Response_Fieldset', '', rsConfigExistingRecMap,'Submit','Cancel' )));
        
        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Credit_Balance_Request__c',false,true,'Credit Balance',
                'Account','RS_ODATA','/account/dell.CreditBalance','2','Credit_Balance_Response__c',
				'Select Client_Company_ID__c,Account_Picklist_1__c from Account where id = ',
				'Credit_Balance_Request_Fieldset','Credit_Balance_Response_Fieldset', '', rsConfigExistingRecMap,'Submit','Back to Account' )));
		
		rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Credit_Balance_Request__c',false,true,'Credit Balance',
                'CHL_Partner_Opportunity__c','RS_ODATA','/Opportunity/dell.CreditBalance','2','Credit_Balance_Response__c',
				'Select Buid__c,Customer_Number__c from CHL_Partner_Opportunity__c where id = ',
				'Credit_Balance_Request_Fieldset','Credit_Balance_Response_Fieldset', '', rsConfigExistingRecMap,'Submit','Back to Partner Opportunity' )));	
				
        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('','Configure_New_Quote_Request__c',false,true,'Configure New Quote',
                'CHL_Partner_Opportunity__c','RS_ODATA','/opportunity/dell.NewQuote','2','Configure_New_Quote_Response__c',
				'Select CHL_Opportunity__c, CHL_Opportunity__r.Id, CHL_Opportunity__r.SyncedQuoteId, CHL_Opportunity__r.OwnerId, CHL_Opportunity__r.AccountId, CHL_Opportunity__r.Inside_Sales_Rep_ISR__c, Id, CHL_Partner_Account_1__c  from CHL_Partner_Opportunity__c where id = ',
				'Configure_New_Quote_PO_Fieldset','Configure_New_Quote_Response_Fieldset',  '', rsConfigExistingRecMap, 'Submit','Cancel')));	
				
		rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('REN_IB_Export_Filterable','',false,true,'IB Export',
                'IBExport__c','RS_ODATA','/IBReport/dell.CustomSearch','','',
				'','REN_IB_Export_Grid','', '', rsConfigExistingRecMap,'','' )));
		
		rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('REN_IB_Export_Filterable','',false,true,'Generate IB Export',
                'IBExport__c','RS_ODATA','/IBReport/dell.Export','','',
				'','REN_IB_Export_Grid','', '', rsConfigExistingRecMap,'','' )));
				
		rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('REN_IB_Export_Filterable','',false,true,'IB Export Download',
                'IBExport__c','RS_ATTACHMENT','/DownloadPresignedUrl','','',
				'','REN_IB_Export_Grid','', '', rsConfigExistingRecMap,'','' )));
		
		//US3472:default records of RS Cofigration for Quote Import flows.		
		rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('',null,false,false,'s3_presigned_url',
        		null,'RS_ATTACHMENT','/PresignedUrl',null,null,null,null,null,null,rsConfigExistingRecMap,'','')));
        
        rsConfigList.add(getRSConfigObj(new REN_RSConfigWrapper('',null,false,false,'Quote Import',
        		null,'RS_ODATA','/opportunity/dell.QuoteImport',null,null,null,null,null,null,rsConfigExistingRecMap,'','')));
                
        return rsConfigList;
    }

    /*
     * @description : This method returns a object of RS Cofigration and it checks key in map. If key is present then it will update the existing RS Cofigration records.
                      If not then it will create new object of RS Cofigration.
    */
    private static REN_RS_Config__c getRSConfigObj(REN_RSConfigWrapper rsConfigWrapperObj){
        REN_RS_Config__c rsConfigObj;
        if(rsConfigWrapperObj.rsConfigExistingRecMap.containsKey(rsConfigWrapperObj.flowName+':'+rsConfigWrapperObj.invokingObj)){
            rsConfigObj = (REN_RS_Config__c) rsConfigWrapperObj.rsConfigExistingRecMap.get(rsConfigWrapperObj.flowName+':'+rsConfigWrapperObj.invokingObj);
        } else {
            rsConfigObj = new REN_RS_Config__c();
        }   
        rsConfigObj.REN_Columns__c = rsConfigWrapperObj.columnsName;
        rsConfigObj.REN_Custom_Object__c = rsConfigWrapperObj.customObj;
        rsConfigObj.REN_Display_Dialog__c = rsConfigWrapperObj.displayDialog;
        rsConfigObj.REN_Display_Response_Dialog__c  = rsConfigWrapperObj.displayResposeDialog;
        rsConfigObj.REN_Flow_Name__c = rsConfigWrapperObj.flowName;
        rsConfigObj.REN_Invoking_Object__c = rsConfigWrapperObj.invokingObj;
        rsConfigObj.REN_Named_Credential__c = rsConfigWrapperObj.namedCredential;
        rsConfigObj.REN_Named_Credential_URL_Extension__c = rsConfigWrapperObj.namedCredentialUrlExt;
        rsConfigObj.REN_Number_Of_Columns__c = rsConfigWrapperObj.noOfCol;
        rsConfigObj.REN_Response_Object__c = rsConfigWrapperObj.responseObj;
        rsConfigObj.REN_SOQL__c = rsConfigWrapperObj.soql;
		rsConfigObj.REN_Field_Set_Name__c = rsConfigWrapperObj.fieldSetName;
		rsConfigObj.REN_Response_Object_Field_Set_Name__c = rsConfigWrapperObj.responseObjectFieldSetName;
		rsConfigObj.REN_Custom_Permission_Name__c = rsConfigWrapperObj.customPermissionName;
		rsConfigObj.REN_Button_Text_for_Submit__c = rsConfigWrapperObj.submitButtonText;
		rsConfigObj.REN_Button_Text_for_Cancel__c = rsConfigWrapperObj.cancelButtonText;
		system.debug('rsConfigObj::::'+rsConfigObj);
        return rsConfigObj;
    }
    
    /*
	* @description : This wrapper class contains mapping key and values which required to create new fieldMapping records.
	*/
	public class REN_RSConfigWrapper {
		String columnsName;
		String customObj;
		Boolean displayDialog;
		Boolean displayResposeDialog; 
		String flowName;
		String invokingObj;
		String namedCredential;
		String namedCredentialUrlExt;
		String noOfCol;
		String responseObj; 
		String soql; 
		String fieldSetName;
		String responseObjectFieldSetName;	
		String customPermissionName;	
		Map<String,REN_RS_Config__c> rsConfigExistingRecMap;
		String submitButtonText;
		String cancelButtonText;
		
		public REN_RSConfigWrapper(String columnsName, String customObj, Boolean displayDialog, Boolean displayResposeDialog, String flowName, String invokingObj, String namedCredential, String  namedCredentialUrlExt, String noOfCol, String responseObj, String soql, String fieldSetName, String responseObjectFieldSetName, String customPermissionName, Map<String,REN_RS_Config__c> rsConfigExistingRecMap,String submitButtonText,String cancelButtonText){
		    this.columnsName = columnsName;
			this.customObj = customObj;
			this.displayDialog = displayDialog;
			this.displayResposeDialog = displayResposeDialog; 
			this.flowName = flowName;
			this.invokingObj = invokingObj;
			this.namedCredential = namedCredential;
			this.namedCredentialUrlExt = namedCredentialUrlExt;
			this.noOfCol = noOfCol;
			this.responseObj = responseObj; 
			this.soql = soql; 
			this.fieldSetName = fieldSetName; 
			this.responseObjectFieldSetName = responseObjectFieldSetName; 
			this.customPermissionName = customPermissionName;
			this.rsConfigExistingRecMap = rsConfigExistingRecMap;
			this.submitButtonText = submitButtonText;
			this.cancelButtonText = cancelButtonText;
		} 

	} 
    /************************ END -- RS Config Records **********************************/	
	
	private static void insertLookupFieldMappingRecords(Map<String,Id> rsConfigFlowNameIdMap) {
		Map<String,List<REN_RS_Lookup_Field_Mapping__c>> rsLookupFieldMapExistingRec = new Map<String,List<REN_RS_Lookup_Field_Mapping__c>>();
        
        List<REN_RS_Lookup_Field_Mapping__c> existingRSLookupFieldMapList = [SELECT Id,Name,REN_Field_API_Name__c,REN_Named_Credential__c,REN_Named_Credential_URL_Extension__c,REN_Object_API_Name__c,REN_RS_Configuration__c 
        																					FROM REN_RS_Lookup_Field_Mapping__c 
        																					WHERE REN_RS_Configuration__c 
        																					IN :rsConfigFlowNameIdMap.values()];

        system.debug('@@@ existingRSLookupFieldMapList '+existingRSLookupFieldMapList);
        if(existingRSLookupFieldMapList != null){
            delete existingRSLookupFieldMapList;
        } 

        List<REN_RS_Lookup_Field_Mapping__c> rsLookupFieldMappingList = createRSLookupFldMappRec(rsConfigFlowNameIdMap);
        system.debug('@@ rsLookupFieldMappingList '+ rsLookupFieldMappingList);
        upsert rsLookupFieldMappingList;	
	}
	
	/* @description : This method is used to create RS Lookup Field mapping records for IB Export */
    private static List<REN_RS_Lookup_Field_Mapping__c> createRSLookupFldMappRec( Map<String,Id> rsConfigFlowNameIdMap) {
        List<REN_RS_Lookup_Field_Mapping__c> rsLookupFieldMappingList = new List<REN_RS_Lookup_Field_Mapping__c>();
        system.debug('@@ rsConfigFlowNameIdMap ' + rsConfigFlowNameIdMap);
        
        rsLookupFieldMappingList.add(getRSLookupFieldMappingObj(rsConfigFlowNameIdMap.get('IB Export:IBExport__c'), 'Bill_To_Customer__c', 'core_organizations__c'));
        rsLookupFieldMappingList.add(getRSLookupFieldMappingObj(rsConfigFlowNameIdMap.get('IB Export:IBExport__c'), 'Customer_Address__c', 'core_addresses__c'));
        rsLookupFieldMappingList.add(getRSLookupFieldMappingObj(rsConfigFlowNameIdMap.get('IB Export:IBExport__c'), 'LOB_Category__c', 'LOBCategory__c'));
        rsLookupFieldMappingList.add(getRSLookupFieldMappingObj(rsConfigFlowNameIdMap.get('IB Export:IBExport__c'), 'Territory__c', 'ClientTerritory__c'));
        rsLookupFieldMappingList.add(getRSLookupFieldMappingObj(rsConfigFlowNameIdMap.get('IB Export:IBExport__c'), 'Country__c', 'Country__c'));
        rsLookupFieldMappingList.add(getRSLookupFieldMappingObj(rsConfigFlowNameIdMap.get('IB Export:IBExport__c'), 'Business_Line__c', 'BusinessLineAlternate__c'));
        return rsLookupFieldMappingList;
        
    }
    
    /* @description : This method is used to create RS Lookup Field Mapping */
    private static REN_RS_Lookup_Field_Mapping__c getRSLookupFieldMappingObj(Id rsConfigId, String objFieldName, String objectAPIName){
        REN_RS_Lookup_Field_Mapping__c rsLookupFieldMappingObj = new REN_RS_Lookup_Field_Mapping__c();
        
        integer cnt = 0;
        rsLookupFieldMappingObj.REN_RS_Configuration__c = rsConfigId;  
        rsLookupFieldMappingObj.REN_Object_API_Name__c = objectAPIName;
        rsLookupFieldMappingObj.REN_Field_API_Name__c = objFieldName;
        rsLookupFieldMappingObj.REN_Named_Credential__c = 'RS_ODATA';
        rsLookupFieldMappingObj.REN_Named_Credential_URL_Extension__c = '/' + objectAPIName.removeEnd('__c');
        return rsLookupFieldMappingObj;
    }
    
    /************************ START -- RS FieldMapping Records *************************/

    /*@description : This method is used to create\Update default records of RS Field Mapping for Dell Automation flows. 
                     Created Map --> Key as RS Config Id + Mapped Field Name + Input Type and value --> FieldMApping Obj.
    */
    private static void rsFieldMappingRec( Map<String,Id> rsConfigFlowNameIdMap) {
        Map<String,REN_RS_Field_Mapping__c> rsFieldMappingExistingRec = new Map<String,REN_RS_Field_Mapping__c>();
        system.debug('@@@ rsConfigFlowNameIdMap.keySet() '+rsConfigFlowNameIdMap.keySet());
        
        List<REN_RS_Field_Mapping__c> existingRSFieldMappingList = [SELECT REN_Custom_Mapped_Field__c,REN_Editable__c,REN_oData_Param__c,REN_Param_Type__c,REN_RS_Config__c 
                                                                    FROM REN_RS_Field_Mapping__c WHERE REN_RS_Config__c IN :rsConfigFlowNameIdMap.values()];

        system.debug('@@@ existingRSFieldMappingList '+existingRSFieldMappingList);
        if(existingRSFieldMappingList != null){
            /*for(REN_RS_Field_Mapping__c rsFieldMappingObj : existingRSFieldMappingList){
                rsFieldMappingExistingRec.put(rsFieldMappingObj.REN_RS_Config__c+':'+rsFieldMappingObj.REN_Custom_Mapped_Field__c+':'+rsFieldMappingObj.REN_Param_Type__c, rsFieldMappingObj);
            }*/
            delete existingRSFieldMappingList;
        } 

        List<REN_RS_Field_Mapping__c> rsFieldMappingList = createRSFieldMappingRec(rsConfigFlowNameIdMap);
        system.debug('@@ rsFieldMappingList '+ rsFieldMappingList);
        upsert rsFieldMappingList;
    }

    /* @description : This method is used to create RS Field mapping records for Dell Automation flows. */
    private static List<REN_RS_Field_Mapping__c> createRSFieldMappingRec( Map<String,Id> rsConfigFlowNameIdMap) {
        List<REN_RS_Field_Mapping__c> rsFieldMappingList = new List<REN_RS_Field_Mapping__c>();
        system.debug('@@ rsConfigFlowNameIdMap Map' + rsConfigFlowNameIdMap);
        /*rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('New Quote:Opportunity'),'oppId__c',true,'oppId','Input','Id',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('New Quote:Opportunity'),'syncedQuoteId__c',true,'syncedQuoteId','Input','syncedQuoteId',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('New Quote:Opportunity'),'salesRepId__c',true,'salesRepId','Input','OwnerId',rsFieldMappingExistingRecMap));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('New Quote:Opportunity'),'customerId__c',true,'customerId','Input','AccountId',rsFieldMappingExistingRecMap));
        */
        //Credit Balance flow
        //Request - Opp
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'buId__c',true,'buid','Input','Account.Account_Picklist_1__c','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'customerNumber__c',true,'customerNum','Input','Account.Client_Company_ID__c','','','',''));
        //Response - Opp
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'id__c',false,'_id','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'buId__c',false,'buId','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'creditLimit__c',false,'creditLimit','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'currentBalance__c',false,'currentBalance','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'customerNum__c',false,'customerNum','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'externalExposure__c',false,'externalExposure','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'remainingCredit__c',false,'remainingCredit','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'totalDebt__c',false,'totalDebt','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'workInProgress__c',false,'workInProgress','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'workInProgressHold__c',false,'workInProgressHold','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Opportunity'),'workInProgressReleased__c',false,'workInProgressReleased','Output','','','','',''));
        
        //Request - Quote
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'buId__c',true,'buid','Input','Account.Account_Picklist_1__c','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'customerNumber__c',true,'customerNum','Input','Account.Client_Company_ID__c','','','',''));
        //Response - Quote
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'id__c',false,'_id','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'buId__c',false,'buId','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'creditLimit__c',false,'creditLimit','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'currentBalance__c',false,'currentBalance','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'customerNum__c',false,'customerNum','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'externalExposure__c',false,'externalExposure','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'remainingCredit__c',false,'remainingCredit','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'totalDebt__c',false,'totalDebt','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'workInProgress__c',false,'workInProgress','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'workInProgressHold__c',false,'workInProgressHold','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Quote'),'workInProgressReleased__c',false,'workInProgressReleased','Output','','','','',''));
        
        //Request - Account
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'buId__c',true,'buid','Input','Account_Picklist_1__c','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'customerNumber__c',true,'customerNum','Input','Client_Company_ID__c','','','',''));
        
        //Response - Account
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'id__c',false,'_id','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'buId__c',false,'buId','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'creditLimit__c',false,'creditLimit','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'currentBalance__c',false,'currentBalance','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'customerNum__c',false,'customerNum','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'externalExposure__c',false,'externalExposure','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'remainingCredit__c',false,'remainingCredit','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'totalDebt__c',false,'totalDebt','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'workInProgress__c',false,'workInProgress','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'workInProgressHold__c',false,'workInProgressHold','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:Account'),'workInProgressReleased__c',false,'workInProgressReleased','Output','','','','',''));
        
        //Request - Credit balance - CHL_Partner_Opportunity__c
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'buId__c',true,'buid','Input','Buid__c','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'customerNumber__c',true,'customerNum','Input','Customer_Number__c','','','',''));
                
        //Credit balance - Partner Opportunity
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'id__c',false,'_id','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'buId__c',false,'buId','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'creditLimit__c',false,'creditLimit','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'currentBalance__c',false,'currentBalance','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'customerNum__c',false,'customerNum','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'externalExposure__c',false,'externalExposure','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'remainingCredit__c',false,'remainingCredit','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'totalDebt__c',false,'totalDebt','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'workInProgress__c',false,'workInProgress','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'workInProgressHold__c',false,'workInProgressHold','Output','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c'),'workInProgressReleased__c',false,'workInProgressReleased','Output','','','','',''));
        
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:Opportunity'),'oppId__c',true,'oppId','Input','Id','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:Opportunity'),'syncedQuoteId__c',true,'syncedQuoteId','Input','syncedQuoteId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:Opportunity'),'salesRepId__c',true,'salesRepId','Input','OwnerId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:Opportunity'),'customerId__c',true,'customerId','Input','AccountId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:Opportunity'),'isrId__c',true,'isrId','Input','Inside_Sales_Rep_ISR__c','','','',''));
        
        //Configure New Quot - Partner Opportunity
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:CHL_Partner_Opportunity__c'),'oppId__c',true,'oppId','Input','CHL_Opportunity__r.Id','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:CHL_Partner_Opportunity__c'),'syncedQuoteId__c',true,'syncedQuoteId','Input','CHL_Opportunity__r.syncedQuoteId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:CHL_Partner_Opportunity__c'),'salesRepId__c',true,'salesRepId','Input','CHL_Opportunity__r.OwnerId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:CHL_Partner_Opportunity__c'),'customerId__c',true,'customerId','Input','CHL_Opportunity__r.AccountId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:CHL_Partner_Opportunity__c'),'isrId__c',true,'isrId','Input','CHL_Opportunity__r.Inside_Sales_Rep_ISR__c','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:CHL_Partner_Opportunity__c'),'resellerOppId__c',true,'resellerOppId','Input','Id','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure New Quote:CHL_Partner_Opportunity__c'),'resellerId__c',true,'resellerId','Input','CHL_Partner_Account_1__c','','','',''));
        
        
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure:Quote'),'quoteId__c',true,'quoteId','Input','Id','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure:Quote'),'salesRepId__c',true,'salesRepId','Input','Opportunity.OwnerId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure:Quote'),'customerId__c',true,'customerId','Input','AccountId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Configure:Quote'),'isrId__c',true,'isrId','Input','Opportunity.Inside_Sales_Rep_ISR__c','','','',''));
        
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Validate:Quote'),'quoteId__c',true,'quoteId','Input','Id','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Validate:Quote'),'salesRepId__c',true,'salesRepId','Input','Opportunity.OwnerId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Validate:Quote'),'customerId__c',true,'customerId','Input','AccountId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Validate:Quote'),'isrId__c',true,'isrId','Input','Opportunity.Inside_Sales_Rep_ISR__c','','','',''));
        
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'quoteId__c',true,'quoteId','Input','Id','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'poNumber__c',true,'poNumber','Input','','','','',''));
        //rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'soNumber__c',true,'soNumber','Input','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'soAmount__c',true,'soAmount','Input','LocalCurrency_Amount_Rollup__c','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'soDate__c',true,'soDate','Input','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'soAmountCurrencyCode__c',true,'soAmountCurrencyCode','Input','Local_Currency_Code__c','Quote','Local_Currency_Code__c','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'winResultReason__c',true,'winResultReason','Input','','REN_Renews_To__c','REN_Renewal_Status__c','Won','CS - Renewed at Par - R@P'));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'lossResultReason__c',true,'lossResultReason','Input','','REN_Renews_To__c','REN_Renewal_Status__c','Lost',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'dealRegistrationNumber__c',true,'dealRegistrationNumber','Input','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'failureUrl__c',false,'failureUrl','Input','$baseURL/$ID','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'successUrl__c',false,'successUrl','Input','$baseURL/$OpportunityId','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'emailToCustomer__c',true,'emailToCustomer','Input','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'emailToSalesRep__c',true,'emailToSalesRep','Input','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'sendByPost__c',true,'sendByPost','Input','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'customerComplianceStatus__c',true,'customerComplianceStatus','Input','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'verifiedAddress__c',true,'verifiedAddress','Input','','','','',''));
        rsFieldMappingList.add(getRSFieldMappingObj(rsConfigFlowNameIdMap.get('Create Order:Quote'),'orderNotes__c',true,'orderNotes','Input','','','','',''));
        return rsFieldMappingList;
        
    }

    /* @description : This method is used to create RS Field Mapping object as per the provided parameters.*/
    private static REN_RS_Field_Mapping__c getRSFieldMappingObj(Id rsConfigId, String customMappedField, boolean isEditable, String oDataParam, String oDataParamType, String objFieldName, String picklistObject, String picklistField, String picklistFilter, String defaultValue){
        REN_RS_Field_Mapping__c rsFieldMappingObj = new REN_RS_Field_Mapping__c();
        rsFieldMappingObj.REN_RS_Config__c = rsConfigId;
        /*system.debug('@@ Map' + rsFieldMappingExistingRecMap);
        system.debug('@@@ Key :: ' + rsConfigId+':'+customMappedField+':'+oDataParamType);
        if(rsFieldMappingExistingRecMap.containsKey(rsConfigId+':'+customMappedField+':'+oDataParamType)){
            rsFieldMappingObj = (REN_RS_Field_Mapping__c) rsFieldMappingExistingRecMap.get(rsConfigId+':'+customMappedField+':'+oDataParamType);
        } else {
            rsFieldMappingObj = new REN_RS_Field_Mapping__c();
            rsFieldMappingObj.REN_RS_Config__c = rsConfigId;
            
        }*/   
        rsFieldMappingObj.REN_Custom_Mapped_Field__c = customMappedField;
        rsFieldMappingObj.REN_Editable__c = isEditable;
        rsFieldMappingObj.REN_oData_Param__c = oDataParam;
        rsFieldMappingObj.REN_Param_Type__c = oDataParamType;
        rsFieldMappingObj.REN_Object_Field_Name__c = objFieldName;
        rsFieldMappingObj.REN_Picklist_Object__c = picklistObject;
        rsFieldMappingObj.REN_Picklist_Field__c = picklistField;
        rsFieldMappingObj.REN_Picklist_Filter__c = picklistFilter;
        rsFieldMappingObj.REN_Picklist_Default_Value__c = defaultValue;
        return rsFieldMappingObj;
    }

    /************************ END -- RS FieldMapping Records *****************************/

    /************************ START -- RS Dynamic Button Records *************************/

    private static void rsDynamicButtonsRec(Map<String,Id> rsConfigFlowNameIdMap){
        List<REN_RS_Dynamic_Button__c> rsDynamicButtonExistingList = [select REN_RS_Action__c,REN_RS_Button_Criteria__c, REN_RS_Button_Label__c, REN_RS_Configuration__c from REN_RS_Dynamic_Button__c];
        //Map<String, REN_RS_Dynamic_Button__c>  rsDynamicButtonMap = new Map<String, REN_RS_Dynamic_Button__c>();
        if(rsDynamicButtonExistingList != null){
            /*for(REN_RS_Dynamic_Button__c rsDynamicButtonObj : rsDynamicButtonExistingList){
                rsDynamicButtonMap.put(rsDynamicButtonObj.REN_RS_Configuration__c+':'+rsDynamicButtonObj.REN_RS_Button_Label__c, rsDynamicButtonObj);
            }*/
            delete rsDynamicButtonExistingList;
        }
        createRSDynamicButtonsRec(rsConfigFlowNameIdMap);
    }

    /* @description : This method is used to create RS Dynamic Button records for Dell Automation flows. */
    private static List<REN_RS_Dynamic_Button__c> createRSDynamicButtonsRec(Map<String,Id> rsConfigFlowNameIdMap) {
        //Need to add criteria temp added pending...
        List<REN_RS_Dynamic_Button__c> rsDynamicButtonList = new List<REN_RS_Dynamic_Button__c>();
        /*rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=New Quote&id=', '',
                                                      'New Quote', rsConfigFlowNameIdMap.get('New Quote:Opportunity')));
        */
		rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Credit Balance&id=','Account.Account_Picklist_1__c  IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3434\',\'3838\',\'5000\',\'5102\',\'5959\',\'6161\',\'6969\',\'69691\')',
                                                      'Credit Balance', rsConfigFlowNameIdMap.get('Credit Balance:Opportunity')));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Credit Balance&id=', 'Account.Account_Picklist_1__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3434\',\'3838\',\'5000\',\'5102\',\'5959\',\'6161\',\'6969\',\'69691\')',
                                                      'Credit Balance', rsConfigFlowNameIdMap.get('Credit Balance:Quote')));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Credit Balance&id=', 'Account_Picklist_1__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3434\',\'3838\',\'5000\',\'5102\',\'5959\',\'6161\',\'6969\',\'69691\')',
                                                       'Credit Balance', rsConfigFlowNameIdMap.get('Credit Balance:Account')));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Credit Balance&id=', 'buId__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3434\',\'3838\',\'5000\',\'5102\',\'5959\',\'6161\',\'6969\',\'69691\')',
                                                       'Credit Balance', rsConfigFlowNameIdMap.get('Credit Balance:CHL_Partner_Opportunity__c')));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Configure New Quote&id=', 'buId__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3434\',\'3838\',\'5000\',\'5102\',\'5959\',\'6161\',\'6969\',\'69691\') and CHL_Opportunity__r.StageName NOT IN (\'PO Received\', \'Closed Sale\', \'No Service\', \'House Account\', \'Open - Consolidated\')',
                                                       'Configure New Quote', rsConfigFlowNameIdMap.get('Configure New Quote:CHL_Partner_Opportunity__c')));                                               
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Configure New Quote&id=', 'Account.Account_Picklist_1__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3434\',\'3838\',\'5000\',\'5102\',\'5959\',\'6161\',\'6969\',\'69691\') and StageName NOT IN (\'PO Received\', \'Closed Sale\', \'No Service\', \'House Account\', \'Open - Consolidated\')',
                                                       'Configure New Quote', rsConfigFlowNameIdMap.get('Configure New Quote:Opportunity')));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Configure&id=', 'Opportunity.StageName NOT IN (\'PO Received\', \'Closed Sale\', \'No Service\', \'House Account\', \'Open - Consolidated\')',
                                                       'Configure', rsConfigFlowNameIdMap.get('Configure:Quote')));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Validate&id=', 'Account.Account_Picklist_1__c IN (\'202\',\'531\',\'546\',\'547\',\'551\',\'552\',\'572\',\'584\',\'592\',\'808\',\'909\',\'1212\',\'1222\',\'1224\',\'1919\',\'2121\',\'2323\',\'2727\',\'2828\',\'2929\',\'3131\',\'3434\',\'3838\',\'5000\',\'5102\',\'5959\',\'6161\',\'6969\',\'69691\') AND Status =\'Completed\'', 
                                                      'Validate', rsConfigFlowNameIdMap.get('Validate:Quote')));
        rsDynamicButtonList.add(getRSDyanmicButtonsObj('/apex/REN_Automation?flow=Create Order&id=', 'Opportunity.StageName NOT IN (\'PO Received\', \'Closed Sale\', \'No Service\', \'House Account\', \'Open - Consolidated\') AND Status =\'Validated\'', 
                                                       'Create Order', rsConfigFlowNameIdMap.get('Create Order:Quote')));
        upsert rsDynamicButtonList;
        return rsDynamicButtonList;
    }

    /* @description : This method is used to create RS Dynamic Button object as per the provided parameters.*/
    private static REN_RS_Dynamic_Button__c getRSDyanmicButtonsObj(String actionName, String buttonCriteria, String buttonLabel, Id rsConfigId){
        REN_RS_Dynamic_Button__c dynamicButtonObj = new REN_RS_Dynamic_Button__c();
        dynamicButtonObj.REN_RS_Configuration__c = rsConfigId;
        /*if(rsDynamicButtonMap.containsKey(rsConfigId+':'+buttonLabel)){
            dynamicButtonObj = (REN_RS_Dynamic_Button__c) rsDynamicButtonMap.get(rsConfigId+':'+buttonLabel);
        }else {
            dynamicButtonObj = new REN_RS_Dynamic_Button__c();
            dynamicButtonObj.REN_RS_Configuration__c = rsConfigId;
        }*/
        dynamicButtonObj.REN_RS_Action__c = actionName;
        dynamicButtonObj.REN_RS_Button_Criteria__c =  buttonCriteria;
        dynamicButtonObj.REN_RS_Button_Label__c = buttonLabel; 
        return dynamicButtonObj;
    }

    /************************ END -- RS Dynamic Button Records *************************/  
	
	/* This method used to assigned new Prism IB Export - Object Access and Prism Dell Automation, to all the active users who have 'Prism' profile. */
    @future
	public static void userAssignmentToDellFeaturesPS() {
        Set<String> restrictedProfilesSet = new Set<String>{'Prism Read Only' , 'Prism Channel', 'Prism Channel Login', 'Prism LT Integration User', 'Prism IS Rep', 'Prism IS Manager'};
    	Map<Id,User> userMap = new map<Id,User>([Select id,name,Profile.Name from User where  isActive = true AND Profile.Name NOT IN :restrictedProfilesSet AND (Profile.Name Like 'Prism%' OR Profile.Name Like 'System Administrator')]);
		ID dellAutomationPsId = null;
		Set<String> permissionsetSet = new Set<String>{'Prism_Dell_Automation','PRISM_IB_Export_Object_Access'};
    	List<PermissionSet> psList = [SELECT id, name,ProfileId FROM PermissionSet where name IN :permissionsetSet limit 10 ];		
		Map<Id, PermissionSet> dellAutomationPsIdMap = new Map<Id, PermissionSet>(psList);
			
		if(dellAutomationPsIdMap != null){
			List<PermissionSetAssignment>  dellFeaturesPsList  = new List<PermissionSetAssignment>();
			for(User userObj : userMap.values()){
				for(Id psId : dellAutomationPsIdMap.keySet()) {
					dellFeaturesPsList.add(new PermissionSetAssignment(PermissionSetId = psId, AssigneeId = userObj.Id));	
				}
			}
			if(!dellFeaturesPsList.isEmpty()){
				database.insert(dellFeaturesPsList, false);
				//insert dellAutomationPsList;
				System.debug('***dellFeaturesPsList ' + dellFeaturesPsList);
			}
		}
        
    }
    
    /* This method is created to create/update RS Field Operator records */
    
    private static void upsertCustomFieldOperators(Map<String,Id> rsConfigFlowNameIdMap){
        if(rsConfigFlowNameIdMap != null && !rsConfigFlowNameIdMap.isEmpty() && rsConfigFlowNameIdMap.containsKey('IB Export:IBExport__c')){
            List<REN_RS_Field_Operator__c> upsertRSFieldOperatorList = new List<REN_RS_Field_Operator__c>();
            Set<String> fieldApiNameSet = new Set<String>();
            Id rsConfigId = rsConfigFlowNameIdMap.get('IB Export:IBExport__c');
            
            List<REN_RS_Field_Operator__c> existingRSFieldOpList = [Select REN_Field_API_Name__c, REN_Operators__c from REN_RS_Field_Operator__c where REN_RS_Configuration__c =: rsConfigId];
        	
            for(REN_RS_Field_Operator__c rsFldOp : existingRSFieldOpList){
                if(rsFldOp.REN_Field_API_Name__c != null && rsFldOp.REN_Field_API_Name__c.equalsIgnoreCase('Customer_APOS_Rep__c')){
                    rsFldOp.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                    fieldApiNameSet.add('Customer_APOS_Rep__c');
                    upsertRSFieldOperatorList.add(rsFldOp);
                }else if(rsFldOp.REN_Field_API_Name__c != null && rsFldOp.REN_Field_API_Name__c.equalsIgnoreCase('Current_Owner_Sales_Rep__c')){
                    rsFldOp.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                    fieldApiNameSet.add('Current_Owner_Sales_Rep__c');
                    upsertRSFieldOperatorList.add(rsFldOp);
                }else if(rsFldOp.REN_Field_API_Name__c != null && rsFldOp.REN_Field_API_Name__c.equalsIgnoreCase('Partner_Customer_Affinity_Hierarchy__c')){
                    rsFldOp.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                    fieldApiNameSet.add('Partner_Customer_Affinity_Hierarchy__c');
                    upsertRSFieldOperatorList.add(rsFldOp);
                }else if(rsFldOp.REN_Field_API_Name__c != null && rsFldOp.REN_Field_API_Name__c.equalsIgnoreCase('Partner_Customer_Affinity_Id__c')){
                    rsFldOp.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                    fieldApiNameSet.add('Partner_Customer_Affinity_Id__c');
                    upsertRSFieldOperatorList.add(rsFldOp);
                }else if(rsFldOp.REN_Field_API_Name__c != null && rsFldOp.REN_Field_API_Name__c.equalsIgnoreCase('Partner_Customer_Number__c')){
                    rsFldOp.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                    fieldApiNameSet.add('Partner_Customer_Number__c');
                    upsertRSFieldOperatorList.add(rsFldOp);
                }
            }
            
            if(!fieldApiNameSet.contains('Customer_APOS_Rep__c')){
                REN_RS_Field_Operator__c rsFldOpObj = new REN_RS_Field_Operator__c();
                rsFldOpObj.REN_Field_API_Name__c = 'Customer_APOS_Rep__c';
                rsFldOpObj.REN_RS_Configuration__c = rsConfigId;
                rsFldOpObj.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                upsertRSFieldOperatorList.add(rsFldOpObj);
            }
            
            if(!fieldApiNameSet.contains('Current_Owner_Sales_Rep__c')){
                REN_RS_Field_Operator__c rsFldOpObj = new REN_RS_Field_Operator__c();
                rsFldOpObj.REN_Field_API_Name__c = 'Current_Owner_Sales_Rep__c';
                rsFldOpObj.REN_RS_Configuration__c = rsConfigId;
                rsFldOpObj.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                upsertRSFieldOperatorList.add(rsFldOpObj);
            }
            
            if(!fieldApiNameSet.contains('Partner_Customer_Affinity_Hierarchy__c')){
                REN_RS_Field_Operator__c rsFldOpObj = new REN_RS_Field_Operator__c();
                rsFldOpObj.REN_Field_API_Name__c = 'Partner_Customer_Affinity_Hierarchy__c';
                rsFldOpObj.REN_RS_Configuration__c = rsConfigId;
                rsFldOpObj.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                upsertRSFieldOperatorList.add(rsFldOpObj);
            }
            
            if(!fieldApiNameSet.contains('Partner_Customer_Affinity_Id__c')){
                REN_RS_Field_Operator__c rsFldOpObj = new REN_RS_Field_Operator__c();
                rsFldOpObj.REN_Field_API_Name__c = 'Partner_Customer_Affinity_Id__c';
                rsFldOpObj.REN_RS_Configuration__c = rsConfigId;
                rsFldOpObj.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                upsertRSFieldOperatorList.add(rsFldOpObj);
            }
            
            if(!fieldApiNameSet.contains('Partner_Customer_Number__c')){
                REN_RS_Field_Operator__c rsFldOpObj = new REN_RS_Field_Operator__c();
                rsFldOpObj.REN_Field_API_Name__c = 'Partner_Customer_Number__c';
                rsFldOpObj.REN_RS_Configuration__c = rsConfigId;
                rsFldOpObj.REN_Operators__c = 'Equals; Not Equal To; IN; NOT IN';
                upsertRSFieldOperatorList.add(rsFldOpObj);
            }
            
            if(!upsertRSFieldOperatorList.isEmpty()){
                upsert upsertRSFieldOperatorList;
            }
        }
    }
}