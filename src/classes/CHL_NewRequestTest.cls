@isTest 
public class CHL_NewRequestTest {
    
    static testMethod void getFieldOptionsTest() {
        Test.startTest();
        Object fldOptions = CHL_CommunityLandingController.getRequestOptions('');
        Test.stopTest();
        CHL_NewRequestResponseWrapper resp = (CHL_NewRequestResponseWrapper)fldOptions;
        system.assert(!resp.requestType.isEmpty());
    }
    
    static testMethod void saveRequestTest() {
        CHL_Partner_Opportunity__c chlpartnerObj = new CHL_Partner_Opportunity__c(); 
        chlpartnerObj.name = 'opportunity for Partner Test';
        insert chlpartnerObj;
        CHL_NewRequestCreationWrapper nw = new CHL_NewRequestCreationWrapper();
        
        nw.type.id = 'Pricing Request';
        nw.type.value = 'Pricing Request';

        nw.account.id = CSM_TestDataUtility.createAccount(1)[0].id;
        nw.account.value = CSM_TestDataUtility.createAccount(1)[0].id;
        
        nw.relatedObject.id  =chlpartnerObj.id;
        nw.relatedObject.value  ='Opportunity';
        
        nw.priority.id ='High';
        nw.priority.value ='High';
        
        nw.message = 'MSG';
        nw.subject = 'Test Subject';
        
        String rq = JSON.serialize(nw);
        Test.startTest();
        Object savedReq = CHL_CommunityLandingController.saveRequest(rq);
        Test.stopTest();
        CHL_NewRequestCreationResponseWrapper resp = (CHL_NewRequestCreationResponseWrapper)savedReq;
        system.assert(resp.recordId != null); 
    }
    
    static testMethod void searchRelatedToTest() {
        CHL_Partner_Opportunity__c chlpartnerObj = new CHL_Partner_Opportunity__c(); 
        chlpartnerObj.name = 'opportunity for Partner Test';
        insert chlpartnerObj;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = chlpartnerObj.id;
        //SOSL does not return results in Test context,we have to set the results
        Test.setFixedSearchResults(fixedSearchResults);
        CHL_RelatedToSearchRequest req = new CHL_RelatedToSearchRequest();
        req.objectType = 'Opportunity';
        req.searchString = 'opportunity';
        String rwt = JSON.serialize(req);
        Test.startTest();
        Object oppSearch = CHL_CommunityLandingController.searchRelated(rwt);
        Test.stopTest();
        List<CHL_RelatedToSearchResponse> respList = (List<CHL_RelatedToSearchResponse>)oppSearch;
        system.assert(respList<>null);
    }
    
    static testMethod void searchRelatedToServiceContractTest() {
        List<Account> accList = CSM_TestDataUtility.createAccount(1);
        //insert accList;
        SObject newServiceContract = CSM_AccessController.newSObject(REN_Constants.OBJ_SERVICE_CONTRACT);
        if(newServiceContract != null){
            newServiceContract.put(REN_Constants.OBJ_SC_NAME,'New SContract');
            newServiceContract.put('AccountId',accList[0].Id);
            insert newServiceContract;
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = newServiceContract.id;
            //SOSL does not return results in Test context,we have to set the results
            Test.setFixedSearchResults(fixedSearchResults);
            CHL_RelatedToSearchRequest req = new CHL_RelatedToSearchRequest();
            req.objectType = 'Service Contract';
            req.searchString = 'SContract';
            req.accountId = accList[0].Id;
            String rwt = JSON.serialize(req);
            Test.startTest();
            Object oppSearch = CHL_CommunityLandingController.searchRelated(rwt);
            Test.stopTest();
            List<CHL_RelatedToSearchResponse> respList = (List<CHL_RelatedToSearchResponse>)oppSearch;
            system.assert(respList[0].id != null);
        }
    }
}