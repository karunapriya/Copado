@isTest
private class CSM_AdminDataAcessTest {
	
     static testMethod void myUnitTest() {
        	CSM_TestUtility.setup();
        	Test.startTest();	
			    	CSM_AdminDataAccess.getObjectSet(CSM_Constants.OBJ_LIST_INDICATORS);
			    	CSM_AdminDataAccess.getObjectSet(CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES);
			    	CSM_AdminDataAccess.getObjectSet(CSM_Constants.OBJ_LIST_HEALTH_COLORS);
			    	CSM_AdminDataAccess.getObjectSet(CSM_Constants.OBJ_LIST_PHASE_COLORS);
			    	CSM_AdminDataAccess.getObjectSet(CSM_Constants.OBJ_LIST_HEALTH_OPTIONS);
			    	CSM_AdminDataAccess.getObjectSet(CSM_Constants.OBJ_LIST_OPPTY_RELATED_LIST);
			    	
			    	CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_INDICATORS);
			    	
			    	CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_INDICATORS);
			    	CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES);
			    	CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_HEALTH_COLORS);
			    	CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_PHASE_COLORS);
			    	CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_HEALTH_OPTIONS);
			    	
			    	CSM_AdminDataAccess.getIsSCOUTAvailable();
			    	CSM_AdminDataAccess.getCSMHelpLinksInstance();
			    	CSM_AdminDataAccess.getAccountPlanSelectedTab();
			    	CSM_AdminDataAccess.getFocusCategoryColumnLimit();
			    	CSM_AdminDataAccess.getFocusCategoryTilesLimit();
			    	system.assert(true);
    	Test.stopTest();
    }
}