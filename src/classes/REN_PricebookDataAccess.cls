public with sharing class REN_PricebookDataAccess {
	
	public static List<PricebookEntry> getProductToPbEntry(Id localPricbook2ID,Set<Id> assetProductIds, String recordCurrencyCode){
		String queryString = '' ;	
		List<String> pbFieldsList = new List<String>{REN_Constants.FLD_ID, 'Product2Id', REN_Constants.OBJ_OPP_PRICEBOOK_ID};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PricebookEntry, pbFieldsList, CSM_Constants.DML_OPERATION_READ); 
		if(UserInfo.isMultiCurrencyOrganization())	{
			queryString = 'Select Id, Product2.Name, Pricebook2Id, CurrencyIsoCode From PricebookEntry where Product2Id IN :assetProductIds and Pricebook2Id =:localPricbook2ID and CurrencyIsoCode =:recordCurrencyCode LIMIT 2000'; 
    	}
		else	{
			queryString = 'Select Id, Product2.Name, Pricebook2Id from PricebookEntry where Product2Id IN :assetProductIds and Pricebook2Id =:localPricbook2ID LIMIT 2000'; 
		}
		List<PricebookEntry> pbEntryList = Database.query(queryString);
		return pbEntryList;
	}
	
	public static Map <ID, PricebookEntry> getPbEntryDetail(Set<ID> pricebookEntryIdSet){
		List<String> pbFieldsList = new List<String>{REN_Constants.FLD_ID, REN_Constants.OBJ_OPP_PRICEBOOK_ID};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PricebookEntry, pbFieldsList, CSM_Constants.DML_OPERATION_READ); 
		return new Map <ID, PricebookEntry>([Select p.Product2Id, p.Id From PricebookEntry p where p.id in :pricebookEntryIdSet LIMIT 50000]);
	}
	
	public static List<Pricebook2> getPriceBookDetail(){
		List<String> pbFieldsList = new List<String>{REN_Constants.FLD_ID,  REN_Constants.FLD_NAME};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PRICEBOOK, pbFieldsList, CSM_Constants.DML_OPERATION_READ); 
		return [Select Id, Name From Pricebook2 Where IsActive=:true];
	}
	
	/**
    *Method: this method will get opportunity and corresponding PriceBookEntry map
    *
    *productId: Id of the product you want to search for
    *lstOfOpp:  List of Opportunity for which we need to find the corresponding PBE.
    *
    *User Story: US2497
    **/    
    public static Map<Id,PricebookEntry> getOppToPbEntry(List<Opportunity> lstOfOpp,String productId){
        
        Map<Id,PricebookEntry> mapOfOppToPriceBE = new Map<Id,PriceBookEntry>();
        Set<String> setOfPriceBook = new Set<String>();
        Set<String> setOfCurrencyCode = new Set<String>();
        boolean isMultyCurrency = UserInfo.isMultiCurrencyOrganization();
        Map<Id,List<Opportunity>> mapOfPBtoOpp = new Map<Id,List<Opportunity>>();
        
        for(Opportunity obj : lstOfOpp){
            setOfPriceBook.add(''+obj.PriceBook2Id);
            if(isMultyCurrency){
                setOfCurrencyCode.add(''+obj.get('CurrencyIsoCode'));
            }
            List<Opportunity> oppList = mapOfPBtoOpp.get(obj.PriceBook2Id);
            if(oppList==null){
                oppList = new List<Opportunity>();                
            }
            oppList.add((Opportunity)obj);
            mapOfPBtoOpp.put(obj.PriceBook2Id,oppList);
        }
        
        
        String queryString = '' ;
        
        List<String> pbFieldsList = new List<String>{REN_Constants.FLD_ID, 'Product2Id', REN_Constants.OBJ_OPP_PRICEBOOK_ID};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PricebookEntry, pbFieldsList, CSM_Constants.DML_OPERATION_READ); 
        queryString = 'Select Id, Product2.Name, Product2Id,UnitPrice,Pricebook2Id';
        if(isMultyCurrency){
         queryString +=',CurrencyIsoCode From PricebookEntry where Product2Id = :productId and Pricebook2Id IN:setOfPriceBook and CurrencyIsoCode IN :setOfCurrencyCode'; 
        }
        else{
            queryString += ' from PricebookEntry where Product2Id =:productId and Pricebook2Id IN:setOfPriceBook'; 
        }
        
        List<PricebookEntry> pbEntryList = Database.query(queryString);
        
        for(PricebookEntry pbe: pbEntryList){
            if(mapOfPBtoOpp.containsKey(pbe.Pricebook2Id)){
                for(Opportunity opp : mapOfPBtoOpp.get(pbe.Pricebook2Id)){
                    if(isMultyCurrency){
	                    if(opp.get('CurrencyIsoCode') == pbe.get('CurrencyIsoCode')){
	                    	mapOfOppToPriceBE.put(opp.Id,pbe);
	                    }
                    }else{
                	  	mapOfOppToPriceBE.put(opp.Id,pbe);
                    }
                }
            }
        }
        return mapOfOppToPriceBE;
    }
    
    public static List<PricebookEntry> getStandardPBE(String productId,String priceBook, String currencyCode){
    	boolean isMultyCurrency = UserInfo.isMultiCurrencyOrganization();
    	List<String> pbFieldsList = new List<String>{REN_Constants.FLD_ID, 'Product2Id', REN_Constants.OBJ_OPP_PRICEBOOK_ID};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PricebookEntry, pbFieldsList, CSM_Constants.DML_OPERATION_READ); 
        String queryString = 'Select Id, Product2.Name, Product2Id,UnitPrice,Pricebook2Id';
        if(isMultyCurrency){
         queryString +=',CurrencyIsoCode From PricebookEntry where Product2Id = :productId and Pricebook2Id =:priceBook and CurrencyIsoCode = :currencyCode'; 
        }
        else{
            queryString += ' from PricebookEntry where Product2Id =:productId and Pricebook2Id =:priceBook'; 
        }
        
        List<PricebookEntry> pbEntryList = Database.query(queryString);
        return pbEntryList;
    }
    
    /* This method is used to get standard PriceBook. User story - US2598*/
    public static List<Pricebook2> getStandardPriceBook(){
		List<String> pbFieldsList = new List<String>{REN_Constants.FLD_ID,  REN_Constants.FLD_NAME, REN_Constants.IS_ACTIVE};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PRICEBOOK, pbFieldsList, CSM_Constants.DML_OPERATION_READ); 
		return [Select Id, Name,IsActive From Pricebook2 Where IsStandard =:true limit 1];
	}
	
	public static Map<Id, List<PricebookEntry>> getOppToPbEntries(List<Opportunity> lstOfOpp,Set<Id> productIds){
        
        Map<Id,List<PricebookEntry>> mapOfOppToPriceBE = new Map<Id,List<PriceBookEntry>>();
        Set<String> setOfPriceBook = new Set<String>();
        Set<String> setOfCurrencyCode = new Set<String>();
        boolean isMultyCurrency = UserInfo.isMultiCurrencyOrganization();
        Map<Id,List<Opportunity>> mapOfPBtoOpp = new Map<Id,List<Opportunity>>();
        
        for(Opportunity obj : lstOfOpp){
	System.debug(Limits.getCpuTime()  + ': CPU \n1--------HEAP: ' + Limits.getHeapSize() );
            setOfPriceBook.add(''+obj.PriceBook2Id);
            if(isMultyCurrency){
                setOfCurrencyCode.add(''+obj.get('CurrencyIsoCode'));
            }
            List<Opportunity> oppList = mapOfPBtoOpp.get(obj.PriceBook2Id);
            if(oppList==null){
                oppList = new List<Opportunity>();                
            }
            oppList.add((Opportunity)obj);
            mapOfPBtoOpp.put(obj.PriceBook2Id,oppList);
        }
        
        
        String queryString = '' ;
        
        List<String> pbFieldsList = new List<String>{REN_Constants.FLD_ID, 'Product2Id', REN_Constants.OBJ_OPP_PRICEBOOK_ID};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PricebookEntry, pbFieldsList, CSM_Constants.DML_OPERATION_READ); 
        queryString = 'Select Id, Product2.Name, Product2Id,UnitPrice,Pricebook2Id';
        if(isMultyCurrency){
         	queryString +=',CurrencyIsoCode From PricebookEntry where Product2Id IN :productIds and Pricebook2Id IN:setOfPriceBook and CurrencyIsoCode IN :setOfCurrencyCode'; 
        }
        else{
            queryString += ' from PricebookEntry where Product2Id IN :productIds and Pricebook2Id IN:setOfPriceBook'; 
        }
        
        List<PricebookEntry> pbEntryList = Database.query(queryString);
        List<PricebookEntry> pbEList = new List<PricebookEntry>();
        for(PricebookEntry pbe: pbEntryList){
			System.debug(Limits.getCpuTime()  + ': CPU \n2--------HEAP: ' + Limits.getHeapSize() );
            if(mapOfPBtoOpp.containsKey(pbe.Pricebook2Id)){
                for(Opportunity opp : mapOfPBtoOpp.get(pbe.Pricebook2Id)){
					pbEList = new List<PricebookEntry>();

                	if(!mapOfOppToPriceBE.containsKey(opp.id)) {
                		mapOfOppToPriceBE.put(opp.Id, pbEList);
                	}
            		if(isMultyCurrency){
	                    if(opp.get('CurrencyIsoCode') == pbe.get('CurrencyIsoCode')){
	                    	mapOfOppToPriceBE.get(opp.Id).add(pbe);
	                    }
                    }else{
                    	mapOfOppToPriceBE.get(opp.Id).add(pbe);
                    }
 					System.debug(Limits.getCpuTime()  + ': CPU \n3--------HEAP: ' + Limits.getHeapSize() );                   
                }
            }
        }
        return mapOfOppToPriceBE;
    }
    
    /* US3021 : This method is used to get map of ProductId and PriceBookEntry based on RLIs.*/
	public static Map<Id,PricebookEntry> getProductIdToPriceBookEntryMap(List<Opportunity> oppList,Set<Id> productIdsSet){
		Map<Id, PricebookEntry> prodIdToPriceBookEntryMap = new Map<Id, PricebookEntry>();
		Set<Id> priceBookIdsSet = new Set<Id>();
        Set<String> currencyCodeSet = new Set<String>();
		Boolean isMultiCurrencyEnabled = UserInfo.isMultiCurrencyOrganization();
		List<String> pbeFieldsList = new List<String>{REN_Constants.FLD_ID, 'Product2Id', REN_Constants.OBJ_OPP_PRICEBOOK_ID};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PricebookEntry, pbeFieldsList, CSM_Constants.DML_OPERATION_READ);
		for(Opportunity obj : oppList){
            priceBookIdsSet.add((Id)obj.PriceBook2Id);
            if(isMultiCurrencyEnabled){
                currencyCodeSet.add((String)obj.get('CurrencyIsoCode'));
            }
        }
        String queryString = 'Select Id, Product2Id, Pricebook2Id';
        if(isMultiCurrencyEnabled){
			queryString +=',CurrencyIsoCode From PricebookEntry where Product2Id IN: productIdsSet and Pricebook2Id IN: priceBookIdsSet and CurrencyIsoCode IN: currencyCodeSet'; 
        }
        else{
            queryString += ' from PricebookEntry where Product2Id IN: productIdsSet and Pricebook2Id IN: priceBookIdsSet'; 
        }
        system.debug('queryString ::'+queryString);
        List<PricebookEntry> pbeList = Database.query(queryString);
		for(PricebookEntry pbe : pbeList){
			prodIdToPriceBookEntryMap.put(pbe.Product2Id, pbe);
		}
		return prodIdToPriceBookEntryMap;		
     }
     
}