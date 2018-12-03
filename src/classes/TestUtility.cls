public with sharing class TestUtility {
    public static List<Product2> createProducts(Integer recordCount){
        List<Product2> product2List = new List<Product2>();
        for (integer i=1; i<=recordCount; i++){
            Product2 prod = new Product2();
            prod.Name = 'TestProduct' + i;
            prod.IsActive = true;
            prod.ProductCode = 'TP' + i;
            product2List.add(prod);
        }
        //insert product2List;
        return product2List;
    }
    
    public static List<PricebookEntry> createPricebookEntry(List<Product2> product2List, Id pricebook2Id){
        
        if(pricebook2Id == null){
            List<Pricebook2> pbList = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where p.IsStandard = true LIMIT 1];
            if(pbList != null && !pbList.isEmpty()){
                pricebook2Id = pbList[0].id;
            }
        }
        System.debug('pricebook2Id===' + pricebook2Id);
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        Integer i = 1;
        for(Product2 a: product2List){
            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = a.id;
            pbe.Pricebook2Id = pricebook2Id;
            pbe.UnitPrice = i++ * 100 + 1;
            pbe.IsActive = true;
            pricebookEntryList.add(pbe);
        }
        return pricebookEntryList;
    }
    
    public static List<OpportunityLineItem> createOplis(List<Opportunity> opportunityList, List<PricebookEntry> pbeList){
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
        for(Opportunity oppty : opportunityList){
            for(PricebookEntry pbe : pbeList){
                opliList.add(new OpportunityLineItem(OpportunityId = oppty.Id, Quantity = 2, TotalPrice = 20, PricebookEntryId = pbe.Id));
            }
        }
        return opliList;
    }
}