/**
 * Created Date		: Oct 9, 2017
 * Developed By		: admin, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * admin					User Story				Oct 9, 2017			1.1					@description
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Comity Designs, Inc. 2017 - All Rights Reserved.
 */
@isTest
private class CSM_ManageHomePageDisplayCtrlTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		csm_focus_category_view__c fcv1 = insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\' AND CSM_Is_Active__c=true','SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue',true);
		System.assert(fcv1.Id != null);		
		csm_focus_category_view__c fcv2 = insertFCV('View Account Test1', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'', 'SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue',false);
		System.assert(fcv2.Id != null);
		List<csm_focus_category_view__c> fcvList = [select id, CSM_Display_Name__c, CSM_isTile__c from csm_focus_category_view__c limit 2];
		createFCDisplayOrderRecord(fcvList);
	}
	
	public static CSM_Focus_Category_View__c insertFCV(String displayName, String columns, String criteria, String soql, String objName,String currencyHeader, boolean isTiles) {
		CSM_Focus_Category_View__c fcv = new CSM_Focus_Category_View__c();
		fcv.CSM_Display_Name__c = displayName;
		fcv.CSM_Columns__c = columns;
		fcv.CSM_Criteria__c = criteria;
		fcv.CSM_SOQL__c = soql;
		fcv.CSM_Object_Name__c = objName;
		fcv.CSM_Currency_Header__c = currencyHeader;
		fcv.CSM_Filter_By_Owner_Value__c = 'My Account';
		fcv.CSM_IsTile__c = isTiles;		
		fcv.CSM_Is_Active__c = true;		
		insert fcv;
		return fcv;
	}
	
	public static void createFCDisplayOrderRecord(List<CSM_Focus_Category_View__c> fcvList) {
		List<CSM_Focus_Category_Display_Order__c> displayOrderRecords = new List<CSM_Focus_Category_Display_Order__c>();
		CSM_Focus_Category_Display_Order__c displayOrderRec;
		for(CSM_Focus_Category_View__c record : fcvList) {
		 	displayOrderRec = new CSM_Focus_Category_Display_Order__c();
		 	displayOrderRec.CSM_Order__c = 1;
		 	displayOrderRec.CSM_Type__c = record.CSM_isTile__c? 'Tile':'Card';
		 	displayOrderRec.CSM_User_Id__c = System.UserInfo.getUserId();
		 	displayOrderRec.CSM_Focus_Category_View_Id__c = record.id;
		 	displayOrderRecords.add(displayOrderRec);
		}
		insert displayOrderRecords;
	}
	
    static testMethod void getUsersTest() {
    	Test.startTest();
	        List<User> userList = [select id from user limit 1];
	        Object sobj1;
	        sobj1 = CSM_ManageHomePageDisplayCtrl.getUsersForManager('');
	        system.assert(sobj1<>null);
	   	Test.stopTest(); 
     }
     
     static testMethod void getFocusCategoriesTest() {
    	Test.startTest();
    		CSM_ManageHomePageDisplayCtrl controller = new CSM_ManageHomePageDisplayCtrl();
	        List<User> userList = [select id, FirstName from user limit 1];
	        Object sobj1;
	        sobj1 = CSM_ManageHomePageDisplayCtrl.getFocusCategories('{\"id\":\"' +userList[0].id + '",\"name\":\"'+ userList[0].FirstName +'"}');
	        system.assert(sobj1<>null);
	   	Test.stopTest(); 
     } 
     
     static testMethod void saveFocusCategoriesTest() {
    	Test.startTest();
	        List<User> userList = [select id from user limit 1];
	        
	        List<CSM_Focus_Category_View__c> fcvList = [select Id, name from CSM_Focus_Category_View__c limit 2];
	        Object sobj1;
	        sobj1 = CSM_ManageHomePageDisplayCtrl.saveFocusCategories('{"tiles":[{"visible":true,"order":1,"name":"' + fcvList[0].name + '","id":"' + fcvList[0].id + '"}],"defaultTilesLayout":false,"defaultCardsLayout":false,"cards":[{"visible":true,"order":1,"name":"' + fcvList[1].name+ '","id":"' + fcvList[1].id + '"}]}');
	        system.assert(sobj1<>null);
	   	Test.stopTest(); 
     }  
     
     static testMethod void focusCategoryOrderWrapper() {
     	csm_focus_category_view__c fcv1 = insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'','SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue',true);
		System.assert(fcv1.Id != null);	
     	List<CSM_Focus_Category_View__c> fcvList = [select id, CSM_Display_Name__c, CSM_isTile__c from CSM_Focus_Category_View__c limit 3];
     	List<CSM_Focus_Category_Display_Order__c> displayOrderRecords = [select id, CSM_Focus_Category_View_Id__c,CSM_Order__c, CSM_Type__c, CSM_User_Id__c from CSM_Focus_Category_Display_Order__c where CSM_Focus_Category_View_Id__c != null order by CSM_Order__c Asc];
     	CSM_FocusCategoryResponseWrapper wrap = CSM_ManageHomePageDisplayCtrlHelper.getFocusCategoryOrderWrapper(fcvList ,displayOrderRecords);
     }
     
     static testMethod void focusCategoryOrderWrapper_1() {
     	csm_focus_category_view__c fcv1 = insertFCV('View Account Test', 'BillingCity, BillingState, ShippingCity, ShippingState', 'WHERE BillingState=\'GA\'','SELECT Id, Name, BillingCity, BillingState FROM Account WHERE BillingState=\'GA\'', 'Account','AnnualRevenue',true);
		System.assert(fcv1.Id != null);	
     	List<CSM_Focus_Category_View__c> fcvList = [select id, CSM_Display_Name__c, CSM_isTile__c from CSM_Focus_Category_View__c limit 3];
     	List<CSM_Focus_Category_Display_Order__c> displayOrderRecords = new List<CSM_Focus_Category_Display_Order__c>();
     	CSM_FocusCategoryResponseWrapper wrap = CSM_ManageHomePageDisplayCtrlHelper.getFocusCategoryOrderWrapper(fcvList ,displayOrderRecords);
     }
}