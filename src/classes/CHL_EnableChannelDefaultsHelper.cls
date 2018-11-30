/**
 * Created Date     : Sep 28, 2017
 * Developed By     : Nidhi, Comity Designs, Inc.
 *
 * Function         : This controller is used on service source setup page for Enabling Channel defaults settings. Added as part of US2771,
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                 US2771             Sep 28, 2017            1.1                 @description
 *
 */
public with sharing class CHL_EnableChannelDefaultsHelper {
	
	/*
    * @description : This method inserts default records on Channel Portal Configuration page, Renewal Partner Data Sync  and Mappings page.				
	*/
	public void createChlPortalDefaultConfigRec(){
		if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty())   {
			insertChannelPortalConfigRecords();
			createSalesStageMappingRec();
			setDefaultMappings();
		}
	}
	 
    /*
    * @description : This method inserts default records on Channel Portal Configuration page.  				
	*/
	private void insertChannelPortalConfigRecords(){
		List<CHL_Opportunity_Status_Log__c> oppStatusLogList = new List<CHL_Opportunity_Status_Log__c>();
		
		CHL_Opportunity_Status_Log__c oppStatusLogObj = new CHL_Opportunity_Status_Log__c();
		oppStatusLogObj.CHL_Available_Sales_Stages__c = 'Not Contacted;Contacted;Quote Request;Quote Delivered;In Review;Customer Commitment;PO Received;';
		oppStatusLogObj.CHL_Display_Pipeline_Sales_Stages__c = 'Not Contacted;Contacted;Quote Request;Quote Delivered;In Review;Customer Commitment;PO Received;Closed Sale;No Service;';
		oppStatusLogObj.CHL_Show_Oppty_for_Unavailable_Stage__c = true;
		oppStatusLogObj.CHL_Active_Languages__c  = 'en_US-English;';
		oppStatusLogObj.CHL_Days_between_Update__c = 30;
		oppStatusLogObj.CHL_Days_before_Expiration__c = 120;
		oppStatusLogObj.CHL_Exclude_Sales_Stages__c = 'Open - Consolidated;Closed Sale;House Account;No Service;';
		oppStatusLogObj.CHL_Quote_PDF_Option__c	= 'Notes & Attachment';
		oppStatusLogList.add(oppStatusLogObj);
		CHL_OpptyStatusLogDataAccess.upsertOpportunityStatusLogList(oppStatusLogList);
	}
    
    /*
    * @description : This method inserts records for partner opportunity sales stage for winning and losing partner opportunities in Channel Portal Configuration page.  				
	*/
	private void createSalesStageMappingRec(){
		List<CHL_Sales_Stage_Mapping__c> salesStagemappingList = CHL_SalesStageMappingDataAccess.getSalesStageMapping();
		if(salesStagemappingList == null || salesStagemappingList.isEmpty()) {
			List<CHL_Sales_Stage_Mapping__c> salesStageList = new List<CHL_Sales_Stage_Mapping__c>();
			salesStageList.add(new CHL_Sales_Stage_Mapping__c (CHL_Master_Opportunity_Sales_Stage__c = 'Closed Sale' ,CHL_Partner_Opportunity_Sales_Stage__c= 'Closed Sale', CHL_Partner_Opportunity_Type__c = 'Winning Partner Opportunities'));
			salesStageList.add(new CHL_Sales_Stage_Mapping__c (CHL_Master_Opportunity_Sales_Stage__c = 'No Service' ,CHL_Partner_Opportunity_Sales_Stage__c= 'No Service', CHL_Partner_Opportunity_Type__c = 'All Partner Opportunities'));
			salesStageList.add(new CHL_Sales_Stage_Mapping__c (CHL_Master_Opportunity_Sales_Stage__c = 'Closed Sale' ,CHL_Partner_Opportunity_Sales_Stage__c= 'No Service', CHL_Partner_Opportunity_Type__c = 'Losing Partner Opportunities'));
			CHL_SalesStageMappingDataAccess.saveSalesStageMapping(salesStageList);
		}
	}
    
    /*
    * @description :This method inserts/update default mappings which is required for channel configation. Below mapping records has been created\updated.
      				Quote → Opportunity
      				Opportunity → Quote
      				Partner Opportunity → Master Opportunity
	*/
	private void setDefaultMappings(){
		List<REN_Field_Mappings__c>  fieldMappingList = REN_FieldMappingsDataAccess.retrieveAllFieldMappings();
		Map<String, REN_Field_Mappings__c> fieldMappingMap = new Map<String, REN_Field_Mappings__c>();
		List<REN_Field_Mappings__c> fieldMappingRecList = new List<REN_Field_Mappings__c>();
		REN_Field_Mappings__c fieldMappingObj;
		
		String quoteExtnNameSpace = CHL_Util.quoteExtnNameSpace;
		String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
		String csmNamespace = CSM_Util.getNamespace();
		//Sting objectName
		for(REN_Field_Mappings__c fieldMapObj : fieldMappingList){	
			if(fieldMapObj.REN_To_Object_API_Name__c != null && fieldMapObj.REN_From_Object_Api_Name__c != null && fieldMapObj.REN_To_Object_API_Name__c != null){
				/*if(fieldMapObj.Name.equalsIgnoreCase('Partner Opportunity → Partner Opportunity')) {
					fieldMappingMap.put(csmNamespace+fieldMapObj.REN_From_Object_Api_Name__c + ':' + fieldMapObj.REN_To_Field_API_Name__c + ':' +csmNamespace+ fieldMapObj.REN_To_Object_API_Name__c, fieldMapObj);
				} else if(fieldMapObj.Name.equalsIgnoreCase('Renewal Relationship → Quote Line Item')) {
					fieldMappingMap.put(csmNamespace+fieldMapObj.REN_From_Object_Api_Name__c + ':' + fieldMapObj.REN_To_Field_API_Name__c + ':' + fieldMapObj.REN_To_Object_API_Name__c, fieldMapObj);
				}
				else */
				if(fieldMapObj.REN_To_Object_API_Name__c.containsIgnoreCase('Quote') || fieldMapObj.REN_From_Object_Api_Name__c.containsIgnoreCase('Quote') || fieldMapObj.REN_To_Object_API_Name__c.containsIgnoreCase('CHL_Partner_Opportunity__c') ){
					fieldMappingMap.put(fieldMapObj.REN_From_Object_Api_Name__c + ':' + fieldMapObj.REN_To_Field_API_Name__c + ':' + fieldMapObj.REN_To_Object_API_Name__c, fieldMapObj);
				}
				/*if(fieldMapObj.Name.equalsIgnoreCase('Renewal Relationship → Quote Line Item')) {
					fieldMappingMap.put(csmNamespace+fieldMapObj.REN_From_Object_Api_Name__c + ':' + fieldMapObj.REN_To_Field_API_Name__c + ':' + fieldMapObj.REN_To_Object_API_Name__c, fieldMapObj);
				}*/
			}		
		}
		//system.debug('fieldMappingMap :: '+fieldMappingMap);
		
		
        //Quote → Opportunity
        //Mapping KEY : FROM OBject:TO OBJECT FIELD:TO OBJECT
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Quote:Description:Opportunity', Label.REN_LBL_QUOTE_TO_OPPTY, 'Quote', 'Opportunity','Description','Description','TEXTAREA', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Quote:'+csmNamespace+'CHL_Partner_Account_1_Type__c:Opportunity', Label.REN_LBL_QUOTE_TO_OPPTY, 'Quote', 'Opportunity',quoteExtnNameSpace+'CHL_Partner_Account_1_Type__c', csmNamespace+'CHL_Partner_Account_1_Type__c', 'PICKLIST', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Quote:'+csmNamespace+'CHL_Partner_Account_2_Type__c:Opportunity', Label.REN_LBL_QUOTE_TO_OPPTY, 'Quote', 'Opportunity',quoteExtnNameSpace+'CHL_Partner_Account_2_Type__c', csmNamespace+'CHL_Partner_Account_2_Type__c', 'PICKLIST', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Quote:'+csmNamespace+'CHL_Partner_Account_1_Contact__c:Opportunity', Label.REN_LBL_QUOTE_TO_OPPTY, 'Quote', 'Opportunity',quoteExtnNameSpace+'CHL_Partner_Account_1_Contact__c',csmNamespace+'CHL_Partner_Account_1_Contact__c', 'REFERENCE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Quote:'+csmNamespace+'CHL_Partner_Account_2__c:Opportunity', Label.REN_LBL_QUOTE_TO_OPPTY, 'Quote', 'Opportunity',quoteExtnNameSpace+'CHL_Partner_Account_2__c',csmNamespace+'CHL_Partner_Account_2__c', 'REFERENCE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Quote:'+csmNamespace+'CHL_Partner_Account_2_Contact__c:Opportunity', Label.REN_LBL_QUOTE_TO_OPPTY, 'Quote', 'Opportunity',quoteExtnNameSpace+'CHL_Partner_Account_2_Contact__c',csmNamespace+'CHL_Partner_Account_2_Contact__c', 'REFERENCE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Quote:'+csmNamespace+'CHL_Partner_Account_1__c:Opportunity', Label.REN_LBL_QUOTE_TO_OPPTY, 'Quote', 'Opportunity',quoteExtnNameSpace+'CHL_Partner_Account_1__c',csmNamespace+'CHL_Partner_Account_1__c', 'REFERENCE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Quote:'+csmNamespace+'CHL_Incumbent__c:Opportunity', Label.REN_LBL_QUOTE_TO_OPPTY, 'Quote', 'Opportunity',quoteExtnNameSpace+'CHL_Incumbent__c',csmNamespace+'CHL_Incumbent__c', 'BOOLEAN', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('QuoteLineItem:'+csmNamespace+'REN_Start_Date__c:OpportunityLineItem', Label.REN_LBL_QUOTE_TO_OPPTY, 'QuoteLineItem', 'OpportunityLineItem',quoteExtnNameSpace+'CHL_Start_Date__c',csmNamespace+'REN_Start_Date__c','DATE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('QuoteLineItem:'+csmNamespace+'REN_End_Date__c:OpportunityLineItem', Label.REN_LBL_QUOTE_TO_OPPTY, 'QuoteLineItem', 'OpportunityLineItem',quoteExtnNameSpace+'CHL_End_Date__c', csmNamespace+'REN_End_Date__c','DATE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('QuoteLineItem:Description:OpportunityLineItem', Label.REN_LBL_QUOTE_TO_OPPTY, 'QuoteLineItem', 'OpportunityLineItem','Description','Description', 'TEXTAREA', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('QuoteLineItem:Discount:OpportunityLineItem', Label.REN_LBL_QUOTE_TO_OPPTY, 'QuoteLineItem', 'OpportunityLineItem','Discount','Discount', 'PERCENT', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('QuoteLineItem:Quantity:OpportunityLineItem', Label.REN_LBL_QUOTE_TO_OPPTY, 'QuoteLineItem', 'OpportunityLineItem','Quantity','Quantity', 'DOUBLE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('QuoteLineItem:'+csmNamespace+'REN_Is_CLM_Renewal__c:OpportunityLineItem', Label.REN_LBL_QUOTE_TO_OPPTY, 'QuoteLineItem', 'OpportunityLineItem',quoteExtnNameSpace+'CHL_Is_CLM_Renewal__c',csmNamespace+'REN_Is_CLM_Renewal__c', 'BOOLEAN', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('QuoteLineItem:UnitPrice:OpportunityLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'QuoteLineItem', 'OpportunityLineItem','UnitPrice', 'UnitPrice', 'CURRENCY', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('QuoteLineItem:ServiceDate:OpportunityLineItem', Label.REN_LBL_QUOTE_TO_OPPTY, 'QuoteLineItem', 'OpportunityLineItem','ServiceDate','ServiceDate', 'DATE', true,fieldMappingMap) ));
  
        //Opportunity → Quote
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Opportunity:Description:Quote', Label.REN_LBL_OPPTY_TO_QUOTE, 'Opportunity', 'Quote','Description', 'Description','TEXTAREA', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('OpportunityLineItem:Discount:QuoteLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'OpportunityLineItem', 'QuoteLineItem','Discount', 'Discount', 'PERCENT', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('OpportunityLineItem:Quantity:QuoteLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'OpportunityLineItem', 'QuoteLineItem','Quantity','Quantity', 'DOUBLE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('OpportunityLineItem:'+quoteExtnNameSpace+'CHL_Start_Date__c:QuoteLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'OpportunityLineItem', 'QuoteLineItem',csmNamespace+'REN_Start_Date__c',quoteExtnNameSpace+'CHL_Start_Date__c', 'DATE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('OpportunityLineItem:'+quoteExtnNameSpace+'CHL_End_Date__c:QuoteLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'OpportunityLineItem', 'QuoteLineItem',csmNamespace+'REN_End_Date__c',quoteExtnNameSpace+'CHL_End_Date__c', 'DATE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('OpportunityLineItem:'+quoteExtnNameSpace+'CHL_Is_CLM_Renewal__c:QuoteLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'OpportunityLineItem', 'QuoteLineItem',csmNamespace+'REN_Is_CLM_Renewal__c', quoteExtnNameSpace+'CHL_Is_CLM_Renewal__c', 'BOOLEAN', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('OpportunityLineItem:UnitPrice:QuoteLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'OpportunityLineItem', 'QuoteLineItem','UnitPrice', 'UnitPrice', 'CURRENCY', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('OpportunityLineItem:ServiceDate:QuoteLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'OpportunityLineItem', 'QuoteLineItem','ServiceDate','ServiceDate', 'DATE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('OpportunityLineItem:Description:QuoteLineItem', Label.REN_LBL_OPPTY_TO_QUOTE, 'OpportunityLineItem', 'QuoteLineItem','Description', 'Description', 'TEXTAREA', true,fieldMappingMap) ));

		//Partner Opportunity → Master Opportunity
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Opportunity:'+csmNamespace+'CHL_Sales_Stage__c:'+csmNamespace+'CHL_Partner_Opportunity__c', Label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY, 'Opportunity', csmNamespace+'CHL_Partner_Opportunity__c','StageName', csmNamespace+'CHL_Sales_Stage__c', 'PICKLIST', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Opportunity:'+csmNamespace+'CHL_Probability__c:'+csmNamespace+'CHL_Partner_Opportunity__c', Label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY, 'Opportunity', csmNamespace+'CHL_Partner_Opportunity__c','Probability', csmNamespace+'CHL_Probability__c', 'PERCENT', false,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Opportunity:'+csmNamespace+'CHL_Close_Date__c:'+csmNamespace+'CHL_Partner_Opportunity__c', Label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY, 'Opportunity', csmNamespace+'CHL_Partner_Opportunity__c','CloseDate', csmNamespace+'CHL_Close_Date__c', 'DATE', false,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Opportunity:'+csmNamespace+'CHL_Expiration_Date__c:'+csmNamespace+'CHL_Partner_Opportunity__c', Label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY, 'Opportunity', csmNamespace+'CHL_Partner_Opportunity__c',csmNamespace+'REN_Earliest_Expiration_Date__c', csmNamespace+'CHL_Expiration_Date__c', 'DATE', false,fieldMappingMap) ));
		if(CSM_AccessController.hasField('Opportunity', solExtNameSpace+'Commit_Level__c')) {
			fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper('Opportunity:'+csmNamespace+'CHL_Color_Commit__c:'+csmNamespace+'CHL_Partner_Opportunity__c', Label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY, 'Opportunity', csmNamespace+'CHL_Partner_Opportunity__c',solExtNameSpace+'Commit_Level__c', csmNamespace+'CHL_Color_Commit__c', 'PICKLIST', false,fieldMappingMap) ));
		}
		
		//US3017 : Added for Partner Opportunity → Partner Opportunity mapping.
	    fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:Name:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', 'Name', 'Name','STRING', true,fieldMappingMap)));
		//fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_Sales_Stage__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO ,csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Sales_Stage__c', csmNamespace+'CHL_Sales_Stage__c','PICKLIST', true,fieldMappingMap)));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_Color_Commit__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Color_Commit__c', csmNamespace+'CHL_Color_Commit__c','PICKLIST', true,fieldMappingMap)));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_Close_Date__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c',csmNamespace+ 'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Close_Date__c', csmNamespace+'CHL_Close_Date__c','Date', true,fieldMappingMap)));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_Expiration_Date__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Expiration_Date__c', csmNamespace+'CHL_Expiration_Date__c','Date', true,fieldMappingMap)));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_EQ__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_EQ__c', csmNamespace+'CHL_EQ__c','NUMBER', true,fieldMappingMap)));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_FY__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_FY__c', csmNamespace+'CHL_FY__c','STRING', true,fieldMappingMap)));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_Partner_Account_1__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Account_1__c', csmNamespace+'CHL_Partner_Account_1__c','REFERENCE', true,fieldMappingMap)));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_Partner_Account_1_Type__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Account_1_Type__c', csmNamespace+'CHL_Partner_Account_1_Type__c','PICKLIST', true,fieldMappingMap)));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_Partner_Account_2__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Account_2__c', csmNamespace+'CHL_Partner_Account_2__c','REFERENCE', true,fieldMappingMap)));
	    fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'CHL_Partner_Opportunity__c:'+csmNamespace+'CHL_Partner_Account_2_Type__c:' +csmNamespace+'CHL_Partner_Opportunity__c',Label.CHL_LBL_PO_TO_PO , csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Opportunity__c', csmNamespace+'CHL_Partner_Account_2_Type__c', csmNamespace+'CHL_Partner_Account_2_Type__c','PICKLIST', true,fieldMappingMap)));
		
		//US3069 : Added for Renewal Relationship → Quote Line Items
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'REN_Renews_To__c:Quantity:QuoteLineItem', Label.CHL_LBL_RLI_TO_QLI, csmNamespace+'REN_Renews_To__c', 'QuoteLineItem',csmNamespace+'REN_Quantity__c','Quantity', 'DOUBLE', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'REN_Renews_To__c:UnitPrice:QuoteLineItem', Label.CHL_LBL_RLI_TO_QLI, csmNamespace+'REN_Renews_To__c', 'QuoteLineItem',csmNamespace+'REN_Previous_Price__c','UnitPrice', 'CURRENCY', true,fieldMappingMap) ));
		//fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'REN_Renews_To__c:'+quoteExtnNameSpace+'REN_Original_Line_Item_ID__c:QuoteLineItem', Label.CHL_LBL_RLI_TO_QLI, csmNamespace+'REN_Renews_To__c', 'QuoteLineItem',csmNamespace+'REN_Original_Line_Item_ID__c',quoteExtnNameSpace+'REN_Original_Line_Item_ID__c', 'STRING', true,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'REN_Renews_To__c:'+quoteExtnNameSpace+'CHL_End_Date__c:QuoteLineItem', Label.CHL_LBL_RLI_TO_QLI,csmNamespace+ 'REN_Renews_To__c', 'QuoteLineItem',csmNamespace+'REN_End_Date__c',quoteExtnNameSpace+'CHL_End_Date__c', 'DATE', false,fieldMappingMap) ));
		fieldMappingRecList.add(getMappingsRecords(new REN_MappingWrapper(csmNamespace+'REN_Renews_To__c:'+quoteExtnNameSpace+'CHL_Start_Date__c:QuoteLineItem', Label.CHL_LBL_RLI_TO_QLI, csmNamespace+'REN_Renews_To__c', 'QuoteLineItem',csmNamespace+'REN_Start_Date__c',quoteExtnNameSpace+'CHL_Start_Date__c', 'DATE', false,fieldMappingMap) ));
		
		
		REN_FieldMappingsDataAccess.upsertFieldMappings(fieldMappingRecList);
	}

	/*
    * @description : This method returns a object of fielmapping and it checks key in map. If key is present then it will update the existing fieldmapping records.
                     If not then it will create new object of FieldMappings.
	*/
	private REN_Field_Mappings__c getMappingsRecords(REN_MappingWrapper mappingWrapperObj ){
		REN_Field_Mappings__c fieldMappingObj ;
		//system.debug('KEY :: '+mappingWrapperObj.mappingKey+'\n MAP :: '+mappingWrapperObj.fieldMappingMap);
		if(!mappingWrapperObj.fieldMappingMap.containsKey(mappingWrapperObj.mappingKey)){
			fieldMappingObj = createFieldMapping(mappingWrapperObj.mappingName,mappingWrapperObj.toFieldType,mappingWrapperObj.toFieldApiName,mappingWrapperObj.fromFieldApiName,mappingWrapperObj.toObject,mappingWrapperObj.fromObject,mappingWrapperObj.isRequiredMapping,'');
		} else if(mappingWrapperObj.fieldMappingMap.containsKey(mappingWrapperObj.mappingKey)){
			fieldMappingObj = (REN_Field_Mappings__c) mappingWrapperObj.fieldMappingMap.get(mappingWrapperObj.mappingKey);
			fieldMappingObj.REN_From_Field_API_Name__c = mappingWrapperObj.fromFieldApiName;
		}
		return fieldMappingObj;
	}

	/*
    * @description : This method is used to create the new objects of fielmapping as per the values provided.
	*/
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

	/*
	* @description : This wrapper class contains mapping key and values which required to create new fieldMapping records.
	*/
	public class REN_MappingWrapper {
		public String mappingKey;
		public String mappingName;
		public String fromObject;
		public String toObject;
		public String fromFieldApiName;
		public String toFieldApiName;
		public String toFieldType;
		public Boolean isRequiredMapping;
		public Map<String, REN_Field_Mappings__c> fieldMappingMap;

		public REN_MappingWrapper(String mappingKey, String mappingName, String fromObject, String toObject, String fromFieldApiName, String toFieldApiName, String toFieldType, Boolean isRequiredMapping, Map<String, REN_Field_Mappings__c> fieldMappingMap){
			this.mappingKey = mappingKey;
			this.mappingName = mappingName;
			this.fromObject = fromObject;
			this.toObject = toObject;
			this.fromFieldApiName = fromFieldApiName;
			this.toFieldApiName = toFieldApiName;
			this.toFieldType = toFieldType;
			this.fieldMappingMap = fieldMappingMap;
			this.isRequiredMapping = isRequiredMapping;
		} 

	}
	
    
}