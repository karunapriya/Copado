/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
*/
@isTest
private class CSM_CustomPaginatorTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        List<Account> accountList = CSM_TestDataUtility.createAccount(7);
        Test.startTest();
        
        CSM_CustomPaginator paginator  = new CSM_CustomPaginator();
        paginator.pageNumber = 1;
        paginator.pageSize = 5;
        paginator.totalPages = 0;
        //paginator.resourcesList = accountList;
        //MF change to use paginator methods
        paginator.initiateResourcesList(accountList); 
        system.debug('paginator $$ ' + paginator.getResults());
        
        List<Account> theAccountLIst = paginator.getResults();
        paginator.updatePages();
        paginator.last();
        paginator.first();
        paginator.getHasNext();
        paginator.getHasPrevious();
        Integer pgCount = paginator.getPageCount();
        system.assertEquals(pgCount,2);
        system.assertEquals(theAccountLIst.size(), 5);
        paginator.getTotalPages();
        paginator.getResultSize();
        paginator.Previous();
        
        paginator.Next();
        
    	List<Account> queryAccount = new List<Account>();
        queryAccount = [select id, name from Account limit 1000]; 
    
    	CSM_CustomPaginator paginator2 = new CSM_CustomPaginator();
        paginator2.pageNumber = 1;
        paginator2.pageSize = 5;
        paginator2.totalPages = 0;
        paginator2.initiateSetController(queryAccount);
        
        
        List<Account> theAccountLIst2 = paginator.getResults();
        paginator2.updatePages();
        paginator2.last();
        paginator2.first();
        paginator2.getHasNext();
        paginator2.getHasPrevious();
        Integer pgCount2 = paginator.getPageCount();
        system.assertEquals(pgCount2,2);
        system.assertEquals(theAccountLIst2.size(), 5);
        paginator2.getTotalPages();
        paginator2.getResultSize();
        paginator2.Previous();    
        
        Test.stopTest();
    }
    
    
}