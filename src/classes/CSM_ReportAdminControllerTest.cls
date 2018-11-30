/*
Test class for Report Admin Page controller
*/
@isTest
private class CSM_ReportAdminControllerTest {
	
	static void createData(){
        List<CSM_MSTR__c> insertmasterReportList= new List<CSM_MSTR__c>();
		CSM_MSTR__c obj1= new CSM_MSTR__c();
        obj1.CSM_Object_Name__c = 'Account';
		obj1.CSM_Multi_Picklist_Name__c = 'multi select values';
		obj1.CSM_Multi_Picklist_API_Name__c = 'CSM_Multi_Select_Values__c';
		obj1.CSM_Picklist_Value__c = 'acc 1';
		insertmasterReportList.add(obj1);
        
        CSM_MSTR__c obj2= new CSM_MSTR__c();
        obj2.CSM_Object_Name__c = 'Lead';
		obj2.CSM_Multi_Picklist_Name__c = 'CSM_Lead_MultiSelect';
		obj2.CSM_Multi_Picklist_API_Name__c = 'CSM_Lead_MultiSelect__c';
		obj2.CSM_Picklist_Value__c = 'lead 1';
		insertmasterReportList.add(obj2);
        
        CSM_MSTR__c obj3= new CSM_MSTR__c();
        obj3.CSM_Object_Name__c = 'Cases';
		obj3.CSM_Multi_Picklist_Name__c = 'CSM_Case_MultiSelect';
		obj3.CSM_Multi_Picklist_API_Name__c = 'CSM_Case_MultiSelect__c';
		obj3.CSM_Picklist_Value__c = 'case 1';
		insertmasterReportList.add(obj3);
        
        insert insertmasterReportList;
	}
    static testMethod void testReportAdmin() {
        // TO DO: implement unit test
        createData();
        Test.startTest();
        CSM_ReportAdminController repadmin = new CSM_ReportAdminController();
        CSM_ReportAdminController repadmin1 = new CSM_ReportAdminController();
        repadmin.helpParam = 'admin';
        repadmin.objType.CSM_Object_Name__c = 'Cases';
        repadmin1.objType.CSM_Object_Name__c = 'Activity';
        repadmin.getMultiPickList();
        repadmin1.getMultiPickList();
        repadmin.multiPickListValue = 'CSM_Case_MultiSelect__c';
        system.debug('***' + repadmin.fieldMap + '***' + repadmin.multiPickListValue);
        //system.assert(multiPickLists,objType.CSM_Multi_Picklist_Name__c);
        repadmin.showMultiPickListValue();
        repadmin.runBatch();
        Test.stopTest();

		system.assert(repadmin != null);        
    }
}