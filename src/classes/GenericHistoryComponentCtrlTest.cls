@isTest(SeeAllData=true) 
/* SeeAllData=true as History record is not generated in Test class need to cover GenericHistoryComponentCtrl. */
private class GenericHistoryComponentCtrlTest {

     static testMethod void testGenericHistoryComp(){
        Test.startTest(); 
            Account accObj = new  Account();
           
	        GenericHistoryComponentCtrl controller = new GenericHistoryCOmponentCtrl();
	        controller.myObject = accObj;
	        controller.getObjectHistory();
	        
	        String fieldLabel = GenericHistoryComponentCtrl.returnFieldLabel('Min_Amount__c');
	        System.assertNotEquals(null, fieldLabel);
	        
	        fieldLabel = GenericHistoryComponentCtrl.returnFieldLabel('testThis');
	        System.assert(String.isEmpty(fieldLabel));
        Test.stopTest();
    }
}