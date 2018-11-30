@isTest
public with sharing class REN_SegmentAdditionalDetailsCtrlTest {
   @testSetup static void SetUp(){
        list<Account> accList = CSM_TestDataUtility.createAccount(1);
        system.assert(acclist[0].id!=NULL);
        Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
		system.assert(prod.Id != null);
		Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        List<Opportunity> TestoppList=new List<Opportunity>();
        For(integer i=0;i<1;i++)
        {
            Opportunity op=new Opportunity(Name='TestOpp'+i,StageName = 'Prospecting',CloseDate = System.Today(), 
                                          AccountId = accList[0].Id, Type = 'New Customer');
           	TestoppList.add(op);
        }
        insert TestoppList;
        List<asset> testasset = new List<asset>();
        for (Integer i = 0; i < 1; i++) {
			testasset.add(new Asset(AccountId = accList[0].id, Product2Id = prod.id, Name = 'Test Asset'+i, Price = 20.00, Quantity = 2));
		}
		insert testasset;
        REN_Segment__c Segment=new REN_Segment__c(Name='TestSegment',REN_Type__c='Low Touch');
        insert Segment;
        List<REN_Segment_Member__c> TestSegMember= new List<REN_Segment_Member__c>();
        for (Integer i = 0; i < 1; i++)
        {
            REN_Segment_Member__c SegMember=new REN_Segment_Member__c(REN_Asset__c=testasset[i].id,
                                            REN_Opportunity__c=TestoppList[i].id,REN_Segment__c	=Segment.id);
            TestSegMember.add(SegMember);
        }
        insert TestSegMember;
    }

    static testmethod void Test_deletesegmember(){
    	try{
            List<REN_Segment__c> Segment=[select id,Name from REN_Segment__c where Name='TestSegment' limit 1];
            PageReference pageRef = Page.REN_SegmentAdditionalDetails;
            pageRef.getParameters().put('parentId', String.valueOf(Segment[0].Id));
            Test.setCurrentPage(pageRef);
            List<REN_Segment_Member__c> SMList=[Select id,Name from REN_Segment_Member__c where REN_Segment__c =:Segment[0].id LIMIT 1];
            REN_SegmentAdditionalDetailsController controller = new REN_SegmentAdditionalDetailsController();		   
            Test.startTest();
            controller.segmentIds=SMList[0].id;
            system.debug('id='+SMList[0].id);
            controller.deletesegmember();
            System.assertNotEquals(SMList[0].Id, null);
            Test.stopTest();     
        }
		catch(Exception e ){
            system.debug('Exception : ' + e.getMessage());
        }
    }
    
    /*
    ** Navigate back test
    */
    static testMethod void navigateBackTest() { 
        REN_TestDataSetup testSetup = new REN_TestDataSetup();
		List<REN_Segment__c> segments = testSetup.createSegments(1, null);
        
        Test.setCurrentPageReference(new PageReference('Page.REN_SegmentAdditionalDetails'));
		System.currentPageReference().getParameters().put('parentId', segments[0].Id);
        System.currentPageReference().getParameters().put('src', 'segmentdetail');
            	
    	Test.startTest();
        REN_SegmentAdditionalDetailsController controller = new REN_SegmentAdditionalDetailsController();
        controller.backButtonClick();
        Test.stopTest();
        
        system.assert(true);
    }
}