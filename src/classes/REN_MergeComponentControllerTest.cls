@isTest
private class REN_MergeComponentControllerTest {

    static testMethod void REN_MergeComponentControllerTest() {
    	
    	REN_MergeComponentController mergeCompCtrl = new REN_MergeComponentController();
    	
    	mergeCompCtrl.sourceSObjects = new List<SObject>();
    	mergeCompCtrl.sourceSObjects.add(new Account()); 
    	mergeCompCtrl.sourceReadFieldList = new List<REN_MergeOppFieldWrapper>();
    	mergeCompCtrl.sourceReadFieldList.add(new REN_MergeOppFieldWrapper('','',''));
    	mergeCompCtrl.sourceUpdateFieldList = new List<REN_MergeOppFieldWrapper>();
    	mergeCompCtrl.sourceUpdateFieldList.add(new REN_MergeOppFieldWrapper('','',''));    	
    	mergeCompCtrl.sourceUpdateFieldJSON = 'Test';
    	mergeCompCtrl.targetSelectedValueJSON = 'Test1';
    	
		system.assertequals(mergeCompCtrl.sourceSObjects.size(),1);    	
		system.assertequals(mergeCompCtrl.sourceReadFieldList.size(),1);
		system.assertequals(mergeCompCtrl.sourceUpdateFieldList.size(),1);
		system.assertequals(mergeCompCtrl.sourceUpdateFieldJSON,'Test');
		system.assertequals(mergeCompCtrl.targetSelectedValueJSON,'Test1');    	    	    	    	    	
        // TO DO: implement unit test
    }
}