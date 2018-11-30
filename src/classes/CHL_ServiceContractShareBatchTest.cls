@isTest(SeeAllData = false)
public class CHL_ServiceContractShareBatchTest {

    static testMethod void setup() {
    	CSM_TestDataSetup test=new CSM_TestDataSetup();
    	List<Account> accList=test.createAccount(4);
    	String namespace=CSM_Util.nameSpacePrefix21;
    	
    	if(CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1__c') && CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2__c')) 
    	{
    		
    		List<SObject> scList=new List<SObject>();
    	
        	SObject sObj = Schema.getGlobalDescribe().get('ServiceContract').newSObject();
        	sObj.put('Name','Service Contract test1');
        	sObj.put('AccountId',accList[0].Id);
        	sObj.put(namespace+'CHL_Partner_Account_2__c',accList[1].id);
        	scList.add(sObj);
        
       	 	SObject sObj2 = Schema.getGlobalDescribe().get('ServiceContract').newSObject();
        	sObj2.put('Name','Service Contract test2');
        	sObj2.put('AccountId',accList[2].Id);
        	sObj2.put(namespace+'CHL_Partner_Account_1__c',accList[3].id);
        	scList.add(sObj2);
        
        insert scList;
        system.assert(scList != null);
        }
       
    }
    public static boolean isNegative;
    static testMethod void myunitTest()
    {
        
        Test.StartTest();
		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
        String jobID = system.schedule('servicecontracttest', strDateTime, new CHL_ServiceContractShareSchdDispatcher());
		String jobID1 = Database.executeBatch(new CHL_ServiceContractShareBatch());
		Test.StopTest();
		system.assert(jobID1 != null);
		system.assert(jobID != null);
    }
    
    static testMethod void myunitTest2()
    {
        isNegative=true;
        Test.StartTest();
		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
        String jobID = system.schedule('servicecontracttest', strDateTime, new CHL_ServiceContractShareSchdDispatcher());
		String jobID1 = Database.executeBatch(new CHL_ServiceContractShareBatch());
		Test.StopTest();
		system.assert(jobID != null);
		system.assert(jobID1 != null);
    }
    
    
}