@istest
public class REN_SegmentMemberBusinessLayerTest {
   
    public static list<REN_Segment__c> Seg;
   
    static void SetUp(){
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
        seg= new list<REN_Segment__c>();
       REN_Segment__c OppSegment=new REN_Segment__c(Name='TestOppSegment',REN_Type__c='Low Touch');
        seg.add(OppSegment);
       REN_Segment__c AssetSegment=new REN_Segment__c(Name='TestAssetSegment',REN_Type__c='ABRLM');
        seg.add(AssetSegment);
		insert seg;
        List<REN_Segment_Member__c> TestSegMember= new List<REN_Segment_Member__c>();
        for (Integer i = 0; i < 1; i++)
        {
            REN_Segment_Member__c SegMember=new REN_Segment_Member__c(REN_Asset__c=testasset[i].id,
                                            REN_Opportunity__c=TestoppList[i].id,REN_Segment__c	=seg[i].id);
            TestSegMember.add(SegMember);
        }
        insert TestSegMember;
    }
   
     static testMethod void Test_getSMWrapperListForAsset(){
        SetUp();
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
        //gridParams.selectedFilterClause='Where REN_Segment__c = \'' + seg[1].id + '\'';
        gridParams.selectedFilterClause='Where REN_Segment__c != null';
        
        list<REN_Segment__c> Segment=[select Name,REN_Type__c from REN_Segment__c where id =: seg[1].id];
        gridParams.selectedTaskFilter=Segment[0].REN_Type__c;
        
         inputWrapper.params = gridParams;
        CSM_BusinessLayer businessLayer = new REN_SegmentMemberBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
        system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	system.assert(responseWrapper.row != null);
    	system.assert(!responseWrapper.row.isEmpty());
    	//system.assertEquals(responseWrapper.hasAction, true);
    	system.assertEquals(responseWrapper.hasCheckbox, true);
    	system.assertEquals(responseWrapper.hasDetail, false);
    	Test.stopTest();
    }
    
     static testMethod void Test_getSMWrapperListForOpp(){
        SetUp();
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
        //gridParams.selectedFilterClause='Where REN_Segment__c = \'' + seg[0].id + '\'';
        gridParams.selectedFilterClause='Where REN_Segment__c != null';
        
        list<REN_Segment__c> Segment=[select Name,REN_Type__c from REN_Segment__c where id =: seg[0].id];
        gridParams.selectedTaskFilter=Segment[0].REN_Type__c;
        
         inputWrapper.params = gridParams;
        CSM_BusinessLayer businessLayer = new REN_SegmentMemberBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
        system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	system.assert(responseWrapper.row != null);
    	system.assert(!responseWrapper.row.isEmpty());
    	//system.assertEquals(responseWrapper.hasAction, true);
    	system.assertEquals(responseWrapper.hasCheckbox, true);
    	system.assertEquals(responseWrapper.hasDetail, false);
    	Test.stopTest();
    }

}