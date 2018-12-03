/**
 * Created Date		: Feb 28, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
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
 * abirjepatil					User Story				Feb 28, 2017			1.1					@description
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
private class CSM_FocusCategoryRestrctVisibiltyTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		CSM_Focus_Category_View__c fcView = new CSM_Focus_Category_View__c();
		fcView.csm_display_name__c = 'fcvtest' ;
		
		insert fcView;
		System.assert(fcView.Id != null);	
		
        csm_focus_category_view__share fcvShare = new csm_focus_category_view__share();
        fcvShare.parentid = fcView.id;
    	fcvShare.AccessLevel = 'Read';
        for(String str:csm_util.getAllPublicGroups().keySet()){
        	fcvShare.UserOrGroupId = str;
        	break;        
        }

		insert fcvShare;	
		System.assert(fcvShare.Id != null);	
	}
	
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        CSM_Focus_Category_View__c fcView = [select id from CSM_Focus_Category_View__c limit 1];

       	Test.startTest();
    	PageReference pageRefVF = Page.CSM_FocusCategoryView;
    	Test.setCurrentPageReference(pageRefVF);
		System.currentPageReference().getParameters().put('Id', fcView.Id);    	
        
        CSM_FocusCategoryRestrctVisibiltyCmpCtrl ctrl = new CSM_FocusCategoryRestrctVisibiltyCmpCtrl();
		REN_BaseMainController baseCtrl = new REN_BaseMainController();
		
		ctrl.baseController =    baseCtrl;     
		ctrl.multiSelectWrp = new  CSM_MultiSelectLeftRightListWrapper(Label.CSM_AVAILABLE_SHARE,Label.CSM_SHARE_TO, ctrl.lstLeftGroups, ctrl.lstRightGroups, ctrl.baseController, ctrl.prefix, ctrl.optionsPublicGroups, ctrl.optionsRoles, null, ctrl.optionsUsers, null);        
        
        CSM_MultiSelectLeftRightPicklistCmpCtrl ctrlMulti = new CSM_MultiSelectLeftRightPicklistCmpCtrl(); 
        ctrlMulti.multiSelectWrp = ctrl.multiSelectWrp;
        ctrl.fcViewId = fcview.Id;
        
		ctrl.selectedValue = CSM_Constants.STR_VISI_CERTAIN_GRP_USERS;
		for(string str:ctrl.lstPublictGroups.keySet()){
			ctrlMulti.rightOptionsHidden = str + '&' + 'test';
			ctrlMulti.leftOptionsHidden = str + '&' + 'test';			
		}
		
        ctrl.performSave(fcview.Id);		
		ctrl.selectedValue = CSM_Constants.STR_VISI_ALL_USERS;
        ctrl.performSave(fcview.Id);		
		ctrl.selectedValue = CSM_Constants.STR_VISI_ONLY_ME;
        ctrl.performSave(fcview.Id);

        
		CSM_Util.getShareInformation('Account', fcView.Id);
       	Test.stopTest();
       	        
        List<csm_focus_category_view__share> fcvShare = [select Id from csm_focus_category_view__share where parentid =: fcView.Id and rowcause not in ('Owner', 'Rule')];
        system.assert(fcvShare.isEmpty());
    }
}