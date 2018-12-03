@isTest
private class CHL_ManagePickListValuesContrlTest {
	static testMethod void Test_Positive() {
		User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
		insert adminUser;
		List<PermissionSetAssignment> lstPSAssignments = new List<PermissionSetAssignment>();
		PermissionSet ps = CHL_TestUtility.getPermissionSet('PRISM_Base');
		lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
		insert lstPSAssignments;
		System.RunAs(adminUser) {
			List <String> destinationList = new List <String> ();
			destinationList.add('TestDest');
			destinationList.add('TestDest1');
			destinationList.add('TestDest2');
			List <String> sourceList = new List <String> ();
			sourceList.add('TestSrc');
			sourceList.add('TestSrc1');
			CHL_ChannelPartnerAdminPageCtrl cpAdmin = new CHL_ChannelPartnerAdminPageCtrl();
			CHL_MultiSelectListWrapper multiSelectWrpObj = new  CHL_MultiSelectListWrapper('avlblSS',Label.CHL_LBL_NOT_AVAILABLE_TO_PARTNER,Label.CHL_LBL_AVAILABLE_TO_PARTNER, sourceList, destinationList,'avlbsalesRght','avlbsalesLft','moveUp','moveDown',cpAdmin,true,0);
			CHL_ManagePickListValuesContrl cntrl = new CHL_ManagePickListValuesContrl();
			cntrl.multiSelectWrp = multiSelectWrpObj;
			cntrl.targetSelectedOptions = new List <String> ();
			cntrl.destinationSelectedOptions = new List <String> ();
			cntrl.targetSelectedOptions.add('TestSrc');
			cntrl.destinationSelectedOptions.add('TestDest2');
			System.assert(cntrl.targetSelectedOptions != null);
			cntrl.moveUp();
			cntrl.moveDown();
			cntrl.moveLeftToRight();
			cntrl.moveRightToLeft();
			Test.startTest();
				cntrl.getAllOptionsFromRight();
			Test.stopTest();
		}
	}
	
	static testMethod void Test_NoneOptions() {
		User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
		insert adminUser;
		List<PermissionSetAssignment> lstPSAssignments = new List<PermissionSetAssignment>();
		PermissionSet ps = CHL_TestUtility.getPermissionSet('PRISM_Base');
		lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
		insert lstPSAssignments;
		System.RunAs(adminUser) {
			List <String> destinationList = new List <String> ();
			destinationList.add(CHL_Constants.STR_NONE);
			List <String> sourceList = new List <String> ();
			sourceList.add(CHL_Constants.STR_NONE);
			CHL_ChannelPartnerAdminPageCtrl cpAdmin = new CHL_ChannelPartnerAdminPageCtrl();
			CHL_MultiSelectListWrapper multiSelectWrpObj = new  CHL_MultiSelectListWrapper('avlblSS',Label.CHL_LBL_NOT_AVAILABLE_TO_PARTNER,Label.CHL_LBL_AVAILABLE_TO_PARTNER, sourceList, destinationList,'avlbsalesRght','avlbsalesLft','moveUp','moveDown',cpAdmin,true,0);
			CHL_ManagePickListValuesContrl cntrl = new CHL_ManagePickListValuesContrl();
			cntrl.multiSelectWrp = multiSelectWrpObj;
			cntrl.targetSelectedOptions = new List <String> ();
			cntrl.destinationSelectedOptions = new List <String> ();
			cntrl.targetSelectedOptions.add('TestSrc');
			cntrl.destinationSelectedOptions.add('TestDest2');
			System.assert(cntrl.targetSelectedOptions != null);
			cntrl.moveUp();
			cntrl.moveDown();
			cntrl.moveLeftToRight();
			cntrl.moveRightToLeft();
			Test.startTest();
				cntrl.getAllOptionsFromRight();
			Test.stopTest();
		}
	}

	static testMethod void Test_Positive1() {
		User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
		insert adminUser;
		List<PermissionSetAssignment> lstPSAssignments = new List<PermissionSetAssignment>();
		PermissionSet ps = CHL_TestUtility.getPermissionSet('PRISM_Base');
		lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
		insert lstPSAssignments;
		System.RunAs(adminUser) {
			CHL_ChannelPartnerAdminPageCtrl cpAdmin = new CHL_ChannelPartnerAdminPageCtrl();
			List <String> destinationList = new List <String> ();
			destinationList.add('TestDest');
			destinationList.add('TestDest1');
			List <String> sourceList = new List <String> ();
			CHL_MultiSelectListWrapper multiSelectWrpObj = new  CHL_MultiSelectListWrapper('avlblSS',Label.CHL_LBL_NOT_AVAILABLE_TO_PARTNER,Label.CHL_LBL_AVAILABLE_TO_PARTNER, sourceList, destinationList,'avlbsalesRght','avlbsalesLft','moveUp','moveDown',cpAdmin,true,0);
			
			//To Cover multiple Add and Remove Scenarios
			//To check None Option for Right Option List
			destinationList.clear();
			sourceList.add('TestSrc');
			sourceList.add('TestSrc1');
			sourceList.add('TestDest1');
			System.assert(sourceList != null);
			
			CHL_MultiSelectListWrapper multiSelectWrpObj1 = new  CHL_MultiSelectListWrapper('avlblSS',Label.CHL_LBL_NOT_AVAILABLE_TO_PARTNER,Label.CHL_LBL_AVAILABLE_TO_PARTNER, sourceList, destinationList,'avlbsalesRght','avlbsalesLft','moveUp','moveDown',cpAdmin,true,0);
			
			//To check None Option for Left Option List
			sourceList.clear();
			sourceList.add('TestSrc');
			sourceList.add('TestSrc1');

			destinationList.clear();
			destinationList.add('TestDest');
			destinationList.add('TestDest1');

			CHL_MultiSelectListWrapper multiSelectWrpObj2 = new  CHL_MultiSelectListWrapper('avlblSS',Label.CHL_LBL_NOT_AVAILABLE_TO_PARTNER,Label.CHL_LBL_AVAILABLE_TO_PARTNER, sourceList, destinationList,'avlbsalesRght','avlbsalesLft','moveUp','moveDown',cpAdmin,true,0);
			
			CHL_ManagePickListValuesContrl cntrl = new CHL_ManagePickListValuesContrl();
			
			cntrl.multiSelectWrp = multiSelectWrpObj2;
			cntrl.targetSelectedOptions = new List < String > ();
			cntrl.targetSelectedOptions.add('TestSrc');
			cntrl.targetSelectedOptions.add('TestSrc1');
			Test.startTest();
			 cntrl.moveLeftToRight();
			Test.stopTest();
			system.assert(!String.isBlank(cntrl.getAllOptionsFromRight()));
		}
	}
	
}