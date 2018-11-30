public with sharing class REN_BaseRelatedList {
    public static List<REN_RelatedListWrapper> getRelatedWrapperList(String mappingName, Set<String> rlmExistingFieldSet, 
    																Map<String, Schema.SObjectField> rlmObjectFieldMap,
    																Set<SelectOption> opportunityRelatedSet,
    																Map<String, SelectOption> opportunityRelatedMap) {
		String selectedObject = CSM_Constants.OBJ_OPPORTUNITY_LINE_ITEM;
		List<REN_RelatedListWrapper> relatedWrapperList = new List<REN_RelatedListWrapper>();
		List <REN_Related_List__c> listOfRelatedListRecords = REN_RelatedListDataAccess.getRelatedListRecordsByConfig(mappingName);
		if (listOfRelatedListRecords != null) {
			for (REN_Related_List__c rl: listOfRelatedListRecords) {
				Schema.SObjectField objectField = rlmObjectFieldMap.get(rl.REN_Related_List_Type__c);
				rlmExistingFieldSet.add(rl.REN_Related_List_Type__c);
				relatedWrapperList.add(new REN_RelatedListWrapper(rl, objectField));
				if (opportunityRelatedMap.containsKey(rl.REN_Related_List_Type__c)){
	            	opportunityRelatedSet.remove(opportunityRelatedMap.get(rl.REN_Related_List_Type__c));
	            }
			}
		}
		return relatedWrapperList;
	}
	    
	public static void saveRelatedList(List<REN_RelatedListWrapper> WrapperList) {
        try {
			if (!WrapperList.isEmpty()) {
			    List <REN_Related_List__c> renRelatedList = new List <REN_Related_List__c>();
		        for (REN_RelatedListWrapper rlw:WrapperList) {
	                renRelatedList.add(rlw.renRelatedList); 
		    	}
			    //system.debug('renRelatedList::'+renRelatedList);
			    REN_RelatedListDataAccess.upsertRelatedListRecords(renRelatedList);
			}
            
        } catch (exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
        }
    }
       /**
    * @description wrapper class used for rows in the data table
    */
	public with sharing class REN_RelatedListWrapper {
		public REN_Related_List__c renRelatedList {
			get;
			set;
		}
		public String sfFieldName {
			get;
			set;
		}
		public REN_RelatedListWrapper(String selectedObject, String selectedField, String mappingName) {
			renRelatedList = new REN_Related_List__c();
			renRelatedList.Name = mappingName;
			renRelatedList.REN_Object_API_Name__c = selectedObject;
			renRelatedList.REN_Related_List_Type__c = selectedField;
		}
		public REN_RelatedListWrapper(REN_Related_List__c relatedListRec, Schema.SObjectField objectField) {
			this.renRelatedList = relatedListRec;
			this.sfFieldName = relatedListRec.REN_Related_List_Type__c + '.' + relatedListRec.REN_Related_List_Type__c;
		}
	}
}