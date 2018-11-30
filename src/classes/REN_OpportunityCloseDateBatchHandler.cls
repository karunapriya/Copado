public with sharing class REN_OpportunityCloseDateBatchHandler {
	
	public static List<String> getMostCommonVal(List<String> valList){
		Map<String,Integer> valCountMap = new Map<String,Integer>();
		for(String val : valList){
			if(valCountMap.containsKey(val)){
				valCountMap.put(val,valCountMap.get(val)+1);
			}
			else{
				valCountMap.put(val,1);
			}
		}
		List<String> highestKeyList = CSM_Util.getKeyHighstValfrmMap(valCountMap);
		return highestKeyList;
	}

	public Date getCloseDate(List<String> assetDateList, Map<Id,OpportunityLineItem> oliMap, Map<id,Date> oliDateMap,String formula){
		Date closeDate = null;
		System.debug('assetDateList::::'+assetDateList);
		Map<String,Decimal> assetDateCountMap = new Map<String,Decimal>();
		assetDateList.sort();
		if(!assetDateList.isEmpty() && formula.equalsIgnoreCase(REN_Constants.EARLIEST_DATE)){
			closeDate = date.valueOf(assetDateList[0]);
		}
		else if(!assetDateList.isEmpty() && formula.equalsIgnoreCase(REN_Constants.LATEST_DATE)){
			closeDate = date.valueOf(assetDateList[assetDateList.size()-1]);
		}
		else if(!assetDateList.isEmpty() && formula.equalsIgnoreCase(REN_Constants.COMMON_DATE)){
			List<String> highestKeyList = REN_OpportunityCloseDateBatchHandler.getMostCommonVal(assetDateList);
			closeDate = date.valueOf(highestKeyList[0]);
		}
		else if(!assetDateList.isEmpty() && formula.equalsIgnoreCase(REN_Constants.VALUABLE_DATE)){
			Decimal decimalValue;
			Integer integerValue;
			for(String oliId : oliDateMap.keySet()){
				if(assetDateCountMap.containsKey(''+oliDateMap.get(oliId))){
					decimalValue = assetDateCountMap.get(''+oliDateMap.get(oliId))+ oliMap.get(oliId).TotalPrice;
					integerValue = decimalValue.intValue();
					assetDateCountMap.put(''+oliDateMap.get(oliId),decimalValue);
				}
				else{
					decimalValue = oliMap.get(oliId).TotalPrice;
					integerValue = decimalValue.intValue();
					assetDateCountMap.put(''+oliDateMap.get(oliId),decimalValue);
				}
			}
			List<String> highestKeyList = CSM_Util.getKeyHighstValfrmMap(assetDateCountMap);
			closeDate = date.valueOf(highestKeyList[0]);
		}
		system.debug('closeDate:~~'+closeDate);
		return closeDate;
	}
}