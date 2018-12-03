public with sharing class CSM_DialogBoxBusinessLayer extends CSM_DialogBusinessLayer {
    
    public CSM_DialogBoxBusinessLayer(CSM_DialogInputParams inputWrapper) {
        super(inputWrapper);
    }
    
    public override List<Map<String, String>> retrieveObjectWrapperList() {
        return getRecordsWrapperList();
    }
    
    private List<Map<String, String>> getRecordsWrapperList() {
        List<Map<String, String>> objList = new List<Map<String, String>>();
        
        try { 
            CSM_DialogInputParams paramsVal = this.inputWrapper; 
            Map<String, String> idValPair = new Map<String, String>();
            List<SelectOption> objectList = new List<SelectOption>();
            
            if(paramsVal.objectType.equalsIgnoreCase(CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES)){                         
                objectList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES);
            } else if(paramsVal.objectType.equalsIgnoreCase(CSM_Constants.STR_PARTNER_SYNCING)){
            	objectList = getSyncingOptions();
            }
            
			if(!objectList.isEmpty()){
	            for(SelectOption obj:objectList){
	                if(String.isNotBlank(obj.getValue())){
	                    idValPair = new Map<String, String>();
	                    idValPair.put('id', obj.getValue());
	                    idValPair.put('value', obj.getLabel());
	                    objList.add(idValPair);
	                }
	            }
			}
        } catch(Exception e) {
            system.debug(e.getStackTraceString());              
        }
        
        return objList;
    }
    
    private List<SelectOption> getSyncingOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(CHL_Constants.SYNCING_OPTION_TO_MO,Label.CHL_SYNCING_TO_MASTER_OPTY)); 
        options.add(new SelectOption(CHL_Constants.SYNCING_OPTION_FROM_MO,Label.CHL_SYNCING_FROM_MASTER_OPTY)); 
        options.add(new SelectOption(CSM_Constants.STR_NONE,Label.CHL_STOP_SYNCING)); 
        return options; 
    }  
}