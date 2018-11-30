public with sharing class CSM_FocusCategoryViewColumnCmpCtrl extends REN_BaseChildController {
    
    public String prefix {get;set;}
    public CSM_MultiSelectLeftRightListWrapper multiSelectWrp {get; set;}
    public String selectedObject {get; set;}
    
    public CSM_FocusCategoryViewController CSM_FocusCategoryViewController { 
		get;
		
    	set {
    		try {
				if (value != null) {
					CSM_FocusCategoryViewController = value;		
					objectNameSuper = 'CSM_Focus_Category_View_Column__c';
					this.baseMainController = value;
				
					multiSelectWrp = new  CSM_MultiSelectLeftRightListWrapper(
													Label.CSM_AvailableFields,
													Label.CSM_SelectedFields, 
													lstLeftGroups, 
													lstRightGroups, 
													CSM_FocusCategoryViewController, 
													prefix, 
													null, 
													null, 
													null, 
													null,
													8);
				}
			} catch(exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
			}
		}
	}	
    
    public String fcViewId {
    	get;
    	
    	set {
    		try {
	    		if (value != null) {
					fcViewId = value;
					
				   	if (CSM_FocusCategoryViewController != null) {
					    CSM_FocusCategoryViewController.setFCVCComponentControllerMap(fcViewId, this);
				    }
				}
			} catch(exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
			}
    	}
    }
     
    private Map<String, Schema.SObjectField> objectFieldMap { 
    	get { 		
    		if(objectFieldMap == null) {
    			objectFieldMap = new Map<String, Schema.SObjectField>();

    			List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(selectedObject);
    			
    			for(Schema.SObjectField tmpfield :fieldList) {       
                	if (!String.valueOf(tmpField).toLowerCase().contains(REN_Constants.OBJ_OPP_FORECAST_CATEGORY_2) &&
                		!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.IS_HIGH_PRIORITY) && 
                		!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.CONTRACT_ID)) {
	                	DisplayType fieldDisplayType =  tmpfield.getDescribe().getType();

	                    if (String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DATE
	                    			|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DATETIME
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_STRING
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_INTEGER
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PICKLIST
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DOUBLE
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_CURRENCY
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PERCENT
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_REFERENCE
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_TEXTAREA
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_LONGTEXTAREA
                                    || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_BOOLEAN) {
							objectFieldMap.put(tmpField.getDescribe().getName(), tmpfield);
						}
		        	}
		    	}
    		}
    		
    		return objectFieldMap;
    	}
    	
    	set;
    }
    
    public List<SelectOption> lstLeftGroups {
    	get {
    		if(lstLeftGroups == null) {
    			lstLeftGroups = new List<SelectOption>();
    			
    			for(String key: objectFieldMap.keySet()){
    				Schema.SObjectField field = objectFieldMap.get(key);
    				
    				if(!findInLstRightGroups(field.getDescribe().getName())) {
    					lstLeftGroups.add(new SelectOption(field.getDescribe().getName(), field.getDescribe().getLabel()));
    				}
    			}
    			
    			CSM_Util.sortSelectOptionByLabel(lstLeftGroups);
    		}
    		
    		return lstLeftGroups;
    	}
    	
    	set;
    }
    		
	public List<SelectOption> lstRightGroups {
		get {
			if(lstRightGroups == null) {
				lstRightGroups = new List<SelectOption>();
				
				for(CSM_Focus_Category_View_Column__c fcvc: fcvcList) { 					
					Schema.SObjectField field = objectFieldMap.get(fcvc.CSM_Object_Field_Name__c);
					lstRightGroups.add(new SelectOption(field.getDescribe().getName(), field.getDescribe().getLabel()));
				}
			}
			
			return lstRightGroups;
		}

		set;
	}
	
	public List<CSM_Focus_Category_View_Column__c> fcvcList {
    	get {
    		if (fcvcList == null)
    		{
    			if(fcViewId == null) {
    				fcvcList = new List<CSM_Focus_Category_View_Column__c>();
    			} else {
        	    	fcvcList = CSM_FocusCategoryViewColumnDataAccess.findFCVCByViewID(fcViewId);
    			} 
    		}
    		
    		return fcvcList;
    	}
    	
    	set;
    }
    
    public CSM_FocusCategoryViewColumnCmpCtrl() {
    	super();
    	prefix = 'fcvc';
    }
    
    public Boolean findInLstRightGroups(String fieldName) {
    	for(SelectOption option: lstRightGroups) {
    		if(option.getLabel() == fieldName) {
    			return true;
    		}
    	}
    	
    	return false;
    }

	private CSM_MultiSelectLeftRightPicklistCmpCtrl referPicklistCtrl() {
		Map<String, REN_BaseChildController> baseChildControllerMap = CSM_FocusCategoryViewController.getBaseChildControllerMap();

		REN_BaseChildController baseChildController = baseChildControllerMap.get(prefix + 'CSM_Focus_Category_View__c');
		if(baseChildController instanceof CSM_MultiSelectLeftRightPicklistCmpCtrl){
			return (CSM_MultiSelectLeftRightPicklistCmpCtrl)baseChildController;
		}

		return null;
	}
    
    public PageReference Save() {
    	try {
	    	CSM_MultiSelectLeftRightPicklistCmpCtrl picklistCtrl = referPicklistCtrl();

	    	boolean successful = CSM_FocusCategoryViewColumnDataAccess.deleteFCVColumn(fcvcList);
	    	fcvcList.clear();
	    	
	    	for(SelectOption option :lstRightGroups) {
	    		String refObject = '';
				Schema.SObjectField objectField = objectFieldMap.get(option.getValue());
				
				CSM_Focus_Category_View_Column__c newFcvc = new CSM_Focus_Category_View_Column__c();
				newFcvc.CSM_Focus_Category_View__c = fcViewId;
				newFcvc.CSM_Object_Field_Name__c = objectField.getDescribe().getName();
				newFcvc.CSM_Object_Field_Type__c = String.valueOf(objectField.getDescribe().getType());
				newFcvc.CSM_Object_Name__c = selectedObject;
				newFcvc.Name = objectField.getDescribe().getLabel();
				
				if(String.valueOf(objectField.getDescribe().getType()) == CSM_Constants.TYPE_REFERENCE) {
	        		Schema.DescribeFieldResult F = objectField.getDescribe();
	        		List<Schema.sObjectType> P = F.getReferenceTo();
	        		refObject = String.valueOf(P[0]);
	        	}
	        	
	        	if(refObject == 'Account') {
	        		newFcvc.CSM_Display_Name__c = 'Account';
	        	}
	        	else {
	        		newFcvc.CSM_Display_Name__c = objectField.getDescribe().getLabel();
	        	}
		        	
	    		fcvcList.add(newFcvc);
	    	}

	    	CSM_FocusCategoryViewColumnDataAccess.upsertFCVC(fcvcList);
    	} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		} 	 
    	
    	return null;
	}
}
    
// Old class back up

/*public with sharing class CSM_FocusCategoryViewColumnCmpCtrl {
    public String selectedField {get; set;}

    private Map<String, Schema.SObjectField> objectFieldMap;
    private Map<String, Set<SelectOption>> objectSelectOptionMap;
    
    private Set<String> existingFieldSet;
    public String guidToCompare {get; set;}
       
    //**
	//* @description constructor 
	//*
    public CSM_FocusCategoryViewColumnCmpCtrl() 
    {
        objectFieldMap = new Map<String, Schema.SObjectField>();
        objectSelectOptionMap = new Map<String, Set<SelectOption>>(); 
        existingFieldSet = new Set<String>();     
    }
    
    public String selectedObject {
    	get; 
    	set{
    		if (value != null){
    			selectedObject =value;
    			List<SelectOption> soFieldList = setDescribeFields();
    		}
    	}
    }
    
    private List<SelectOption> setDescribeFields() {
    	existingFieldSet.add(selectedObject+REN_Constants.OBJ_OPP_FORECAST_CATEGORY_2);
    	List<SelectOption> soFieldList = new List<SelectOption>();
        if (!String.isBlank(selectedObject))
        {   
            
            if (objectSelectOptionMap.containsKey(selectedObject))
            {
            	soFieldList = new List<SelectOption>(objectSelectOptionMap.get(selectedObject));                	                 
            }
            else 
            {                    
                Set<SelectOption> selectOptionSet = new Set<SelectOption>();
                List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(selectedObject);
                for( Schema.SObjectField tmpfield :fieldList)
                {       
                	if (!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.IS_HIGH_PRIORITY) && 
                		!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.CONTRACT_ID)){
	                	DisplayType fieldDisplayType =  tmpfield.getDescribe().getType();
	                    if (String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DATE
	                    			|| String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DATETIME
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_STRING
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_INTEGER
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PICKLIST
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DOUBLE
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_CURRENCY
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PERCENT
	                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_REFERENCE) {  
	                        if (!existingFieldSet.contains(selectedObject + tmpField.getDescribe().getName())) {   
								selectOptionSet.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
								objectFieldMap.put(selectedObject + tmpField.getDescribe().getName(), tmpfield);
	                        }
						}
                	}
                }
                
                objectSelectOptionMap.put(selectedObject, selectOptionSet);
                soFieldList.addAll(selectOptionSet);                                       
            }
            
            
        } 
        return soFieldList;
    }
    
     //**
	//* @description used to populate Field select list
	//* @return a list of fields that have read access
	//*
    public List<SelectOption> getFieldList()
    {
        
        try
        {   
            List<SelectOption> soFieldList = setDescribeFields();
            if (soFieldList!=null && !soFieldList.isEmpty()){
            	CSM_Util.sortSelectOptionByLabel(soFieldList);
            }
            return soFieldList;
        }
        catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             return null;
        }
    }   
    
    //**
	//* @description creae a new row in the data table
	//* @return null
	//*
    public PageReference addField()
    {
        if (!String.isBlank(selectedField))
        {
        	Schema.SObjectField objectField = objectFieldMap.get(selectedObject+selectedField);
            FCVCWrapper newFCVC = new FCVCWrapper(objectField, selectedObject, selectedField, fcViewId, CSM_Util.NewGuid());            
            fcvcList.add(newFCVC);            
            Set<SelectOption> selectOptionSet = objectSelectOptionMap.get(selectedObject);
            SelectOption objectToRemove = new SelectOption(objectField.getDescribe().getName(), objectField.getDescribe().getLabel());
            selectOptionSet.remove(objectToRemove);  
            objectSelectOptionMap.put(selectedObject, selectOptionSet);             
            
        }
        
        return null;
    }
    
    //**
	//* @description delete the given play criteria
	//* @return PageReference 
	//*
    public PageReference deleteColumn()
    {
    	List<CSM_Focus_Category_View_Column__c> columnToDelete = new List<CSM_Focus_Category_View_Column__c>();
    	try
    	{
	    	if(guidToCompare != null)
	    	{
	    		for(integer i=0; i< fcvcList.size(); i++)
	    		{
	    			if(guidToCompare == fcvcList[i].guid)
	    			{
	    				if(fcvcList[i].csmFCVC.id != null)
	    				{
	    					columnToDelete.add(fcvcList[i].csmFCVC);
	    				}
	    				existingFieldSet.remove(selectedObject+fcvcList[i].csmFCVC.CSM_Object_Field_Name__c);
	    				Schema.SObjectField objectField = objectFieldMap.get(selectedObject+fcvcList[i].csmFCVC.CSM_Object_Field_Name__c);
	            		Set<SelectOption> selectOptionSet = objectSelectOptionMap.get(selectedObject);
			            SelectOption objectToAdd = new SelectOption(objectField.getDescribe().getName(), objectField.getDescribe().getLabel());
			            selectOptionSet.add(objectToAdd);  
			            objectSelectOptionMap.put(selectedObject, selectOptionSet);  
	    				fcvcList.remove(i);
	    				break;
	    			}	
	    		}
	    		
	    	}
	    	if(!columnToDelete.isEmpty())
	    	{
	    		boolean successful = CSM_FocusCategoryViewColumnDataAccess.deleteFCVColumn(columnToDelete);
	    	}
	    }
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
    	return null;
    }
        
    //**
	//* @description Upserts all Indicators for the Indicator Group
	//* @return null
	//*
    public PageReference Save()
    {			
		List<CSM_Focus_Category_View_Column__c> listFCVC = new List<CSM_Focus_Category_View_Column__c>();
		try
		{
			for (FCVCWrapper fcvc:fcvcList) 
			{
			    if (!String.isBlank(fcvc.csmFCVC.CSM_Display_Name__c))
	            {	
	            	fcvc.csmFCVC.Name = fcvc.csmFCVC.CSM_Display_Name__c;
				    listFCVC.add(fcvc.csmFCVC);
	            }
			}
			if (!fcvcList.isEmpty())
			{
			    CSM_FocusCategoryViewColumnDataAccess.upsertFCVC(listFCVC);
			}
    	}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		} 	   	
		return null;
	}
    
    //**
	//* @description Creating local reference to the CSM_IndicatorGroupComponentController so that 
	//*              setIndicatorComponentControllerMap may be used.
	//*
    public CSM_FocusCategoryViewController CSM_FocusCategoryViewController
	{ 
		get; 
    	set 
    	{
			if (value != null) 
			{
				CSM_FocusCategoryViewController = value;		
						
			}
		}
	}	
    
    //**
	//* @description used to set the local indicatorGroupId as well as create a record for this group and controller in the
	//*              CSM_IndicatorComponentControllerMap.
	//*
    public String fcViewId
    {
    	get; 
    	set
    	{    		
    		if (value != null) 
			{
				fcViewId = value;
				if (fcViewId!=null){
					fcvcList = fcvcList;  
				}
			    if (CSM_FocusCategoryViewController != null)
			    {
				    CSM_FocusCategoryViewController.setFCVCComponentControllerMap(fcViewId, this);
			    }		
			}
    	}
    }
    
    public List<FCVCWrapper> fcvcList
    {
    	get
    	{
    		try 
    		{
	    		if (fcvcList == null)
	    		{
	    			fcvcList = new List<FCVCWrapper>();
	    			
	        	    List<CSM_Focus_Category_View_Column__c> listFCVC = CSM_FocusCategoryViewColumnDataAccess.findFCVCByViewID(fcViewId);
				    if (listFCVC != null)
				    {
				        for (CSM_Focus_Category_View_Column__c fcvc: listFCVC)
				        {
				        	Schema.SObjectField objectField = null;
				        	if (objectFieldMap.containsKey(fcvc.CSM_Object_Name__c+fcvc.CSM_Object_Field_Name__c))
				        	{
				        		objectField = objectFieldMap.get(fcvc.CSM_Object_Name__c+fcvc.CSM_Object_Field_Name__c);
				        	}
				        	else 
				        	{
				        	    List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(fcvc.CSM_Object_Name__c);
			                    for( Schema.SObjectField tmpfield :fieldList)
			                    {         
			                        if (!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.IS_HIGH_PRIORITY) && 
                						!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.CONTRACT_ID)){
										if (String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_DATE
											|| String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_DATETIME
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_STRING
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_INTEGER
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_PICKLIST
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_DOUBLE
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_CURRENCY
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_PERCENT
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_REFERENCE)
				                        {                             
		                                	objectFieldMap.put(fcvc.CSM_Object_Name__c + tmpField.getDescribe().getName(), tmpfield);
	                                	}
		                                objectField = objectFieldMap.get(fcvc.CSM_Object_Name__c+fcvc.CSM_Object_Field_Name__c);
			                        }
			                    }
				        	}
				        	existingFieldSet.add(fcvc.CSM_Object_Name__c+fcvc.CSM_Object_Field_Name__c);
				        	fcvcList.add(new FCVCWrapper(fcvc,  objectField, CSM_Util.NewGuid()));			        	
				        }
				    }      
	    		}
	    		return fcvcList;
    		}  	 
	    	catch (Exception ex)
            {            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
                return null;
            }   
    	}
    	set;
    	
    }

	//**
	//* @description wrapper class used for rows in the data table
	//*
    public with sharing class FCVCWrapper
    {
        public CSM_Focus_Category_View_Column__c csmFCVC {get; set;}
        public String sfFieldLabel {get; set;}
        public String sfFieldName {get; set;}        
		public String guid {get; set;}
		
        
        public FCVCWrapper(Schema.SObjectField objectField, String selectedObject, String selectedField, Id indicatorGroupId, String newGuid) 
        {
        	String refObject = '';
        	csmFCVC = new CSM_Focus_Category_View_Column__c();       	
        	csmFCVC.CSM_Focus_Category_View__c = indicatorGroupId;
        	csmFCVC.CSM_Object_Field_Name__c = selectedField;
        	csmFCVC.CSM_Object_Name__c = selectedObject;
        	//csmFCVC.CSM_Display_Name__c = objectField.getDescribe().getLabel();
        	if(String.valueOf(objectField.getDescribe().getType()) == CSM_Constants.TYPE_REFERENCE)
        	{
        		Schema.DescribeFieldResult F = objectField.getDescribe();
        		List<Schema.sObjectType> P = F.getReferenceTo();
        		refObject = String.valueOf(P[0]);
        	}
        	
        	if(refObject == 'Account')
        	{
        		csmFCVC.CSM_Display_Name__c = 'Account';
        	}
        	else
        	{
        		csmFCVC.CSM_Display_Name__c = objectField.getDescribe().getLabel();
        	}
        	csmFCVC.Name = csmFCVC.CSM_Display_Name__c;
        	this.sfFieldLabel = objectField.getDescribe().getLabel();
            this.sfFieldName = selectedObject + '.' + selectedField;            
            guid = newGuid;
            csmFCVC.CSM_Object_Field_Type__c = String.valueOf(objectField.getDescribe().getType());
        }
        
        public FCVCWrapper(CSM_Focus_Category_View_Column__c fcvc,  Schema.SObjectField objectField, String newGuid)
        {
            this.csmFCVC = fcvc;
            this.sfFieldLabel = fcvc.CSM_Object_Field_Name__c;
            this.sfFieldName = fcvc.CSM_Object_Name__c + '.' + this.sfFieldLabel;           
            guid = newGuid; 
        }
    }
}*/