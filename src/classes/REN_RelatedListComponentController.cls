public with sharing class REN_RelatedListComponentController extends REN_BaseChildController {
	public Set<SelectOption> opportunityRelatedSet = new Set<SelectOption>();
    public Map<String, SelectOption> opportunityRelatedMap = new Map<String, SelectOption>();
    public String selectedField { get; set; }  
    public String recordId { get; set; }
    private List<REN_BaseRelatedList.REN_RelatedListWrapper> renRelatedWrapperList;
    private Set<String> existingFieldSet = new Set<String>();
    private Map<String, Schema.SObjectField> objectFieldMap = new Map<String, Schema.SObjectField>();
      
	public String objectName {
		get; 
		set {
			//System.debug('value - '+value);
			if (value != null){
				objectName = value;
				//System.debug('objectName - '+objectName);
				getOpptyRelatedSet();
				if (mappingName != null){
					renRelatedWrapperList = REN_BaseRelatedList.getRelatedWrapperList(mappingName, existingFieldSet, objectFieldMap, 
	            										opportunityRelatedSet, opportunityRelatedMap);
				}
    	        //System.debug('opportunityRelatedSet - '+opportunityRelatedSet);
			}
		}
	}
	
	public List<SelectOption> getOpportunityRelatedList() {
		List<SelectOption> opptyRelatedList = new List<SelectOption>();
		opptyRelatedList.addAll(opportunityRelatedSet);
		opptyRelatedList.sort();
		return opptyRelatedList;
    }
    
    public void save(){
    	
    }
	
	private void getOpptyRelatedSet() {
    	for (String val : CSM_AdminDataAccess.getObjectSet(objectName)) {
    		String[] valStr = val.split('=');
    		SelectOption selOption;
    		if (valStr!=null && valStr.size()>1){
    			selOption = new SelectOption(valStr[0], valStr[1]);
    		} else {
    			selOption = new SelectOption(valStr[0], valStr[0]);
    		}
    		opportunityRelatedSet.add(selOption);
			opportunityRelatedMap.put(valStr[0], selOption);
    	}
    }
		
	public String mappingName {
		get;
		set {
			//System.debug('renRelatedWrapperList - '+objectName + ' = ' + renRelatedWrapperList);
			if (value != null && (renRelatedWrapperList==null || renRelatedWrapperList.isEmpty())){
				this.mappingName = value;
				this.objectNameSuper = value;
				//System.debug('In mappingName - '+mappingName);
				if (objectName != null){
					renRelatedWrapperList = REN_BaseRelatedList.getRelatedWrapperList(mappingName, existingFieldSet, objectFieldMap, 
	            										opportunityRelatedSet, opportunityRelatedMap);
				}
    	        //System.debug('opportunityRelatedSet - '+opportunityRelatedSet);
				
			}
		}
	}
	    
    public List<REN_BaseRelatedList.REN_RelatedListWrapper> getRENRelatedWrapperList() {
		return renRelatedWrapperList;
    }
	        
	/**
    * @description creae a new row in the data table
    * @return null
    */
    public PageReference AddField() {
    	//System.debug('mappingName - '+mappingName);
		//System.debug('selectedField - '+selectedField);
				
        if (!String.isBlank(selectedField) && !String.isBlank(mappingName) ) {
        	 REN_BaseRelatedList.REN_RelatedListWrapper newFieldMapping = new REN_BaseRelatedList.REN_RelatedListWrapper(objectName, selectedField, mappingName);  
            if (renRelatedWrapperList == null) {
                renRelatedWrapperList = new List<REN_BaseRelatedList.REN_RelatedListWrapper>();
            }
            if (opportunityRelatedMap.containsKey(selectedField)){
            	opportunityRelatedSet.remove(opportunityRelatedMap.get(selectedField));
            }
            //System.debug('opportunityRelatedSet - '+opportunityRelatedSet);
            REN_BaseRelatedList.saveRelatedList(new List<REN_BaseRelatedList.REN_RelatedListWrapper>{newFieldMapping});
            renRelatedWrapperList.add(newFieldMapping);     
            //system.debug('renRelatedWrapperList::'+renRelatedWrapperList);
        }
        return null;
    }

	// The method to remove an item from the list
    public PageReference removeRelatedList(){
    	if(Schema.sObjectType.REN_Related_List__c.isDeletable()){
    		REN_RelatedListDataAccess.deleteRelatedListRecords(new List<REN_Related_List__c>{new REN_Related_List__c(Id=recordId)});
			renRelatedWrapperList = REN_BaseRelatedList.getRelatedWrapperList(mappingName, existingFieldSet, objectFieldMap, 
	            										opportunityRelatedSet, opportunityRelatedMap);
	        //System.debug('selectedField - '+selectedField);
	        //System.debug('opportunityRelatedSet - '+opportunityRelatedSet);
		    if (opportunityRelatedMap.containsKey(selectedField)){
	        	opportunityRelatedSet.add(opportunityRelatedMap.get(selectedField));
	        }
	        //System.debug('selectedField - '+selectedField);
	        //System.debug('opportunityRelatedSet - '+opportunityRelatedSet);
    	}else{
    		String[] arguments = new String[] {REN_Constants.OBJ_RL};
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.CSM_MSG_OBJECT_NOT_DELETABLE, arguments)));
    	}
	    return null;
    }
}