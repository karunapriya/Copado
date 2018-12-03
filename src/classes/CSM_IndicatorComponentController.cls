/**
* @author         Michelle Lairson(michelle@comitydesigns.com)
* @date           07.23.2014
* @description    CSM_IndicatorComponentController for CSM_IndicatorComponent
*/
public with sharing class CSM_IndicatorComponentController 
{
    public String selectedObject {get; set;}
    public String selectedField {get; set;}

    private Map<String, Schema.SObjectField> objectFieldMap;
    private Map<String, Set<SelectOption>> objectSelectOptionMap;
    
    private List<String> indicatorFieldList;
    private Set<String> existingFieldSet;
    public String indicatorId {get; set;}
    public String indicatorField{get; set;}
    public Integer accounttempindicatorCount{get; set;}
    public String accounttempindicatorName{get; set;}
    public String accounttempindicatorList{get; set;}
    /**
	* @description constructor 
	*/
    public CSM_IndicatorComponentController() 
    {
        objectFieldMap = new Map<String, Schema.SObjectField>();
        objectSelectOptionMap = new Map<String, Set<SelectOption>>(); 
        indicatorFieldList = new List<String>{CSM_Constants.OBJ_I_DISPLAY_NAME,
        	CSM_Constants.OBJ_I_INDICATOR_GROUP,CSM_Constants.OBJ_I_FIELD_NAME, 
        	CSM_Constants.OBJ_I_OBJECT_NAME, CSM_Constants.OBJ_I_IS_ACTIVE};
        existingFieldSet = new Set<String>();       
    }
    
    /**
	* @description used to populate Object select list
	* @return list of objects from the custom setting 
	*/
    public List<SelectOption> getObjectList()
    {
        try
        {   
            List<SelectOption> objectList = new List<SelectOption>();           
            objectList.addAll(CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_INDICATORS));
            if (selectedObject == null && !objectList.isEmpty()) 
            {
            	selectedObject = ((SelectOption)objectList[0]).getValue().trim();
            }  
            return objectList;
        }
        catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             return null;
        }
    }
    
     /**
	* @description used to populate Field select list
	* @return a list of fields that have read access
	*/
    public List<SelectOption> getFieldList()
    {
        
        try
        {   
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
                    	DisplayType fieldDisplayType =  tmpfield.getDescribe().	getType();
                        if (String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DATE
                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_STRING
                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_INTEGER
                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PICKLIST
                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_DOUBLE
                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_CURRENCY
                                || String.valueOf(fieldDisplayType) == CSM_Constants.TYPE_PERCENT)
                        {          
                        	if (!existingFieldSet.contains(selectedObject + tmpField.getDescribe().getName()))   
                        	{   
                                selectOptionSet.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
                                objectFieldMap.put(selectedObject + tmpField.getDescribe().getName(), tmpfield);
                            }
                        }
                        for(Integer rowNum=0; rowNum<this.indicatorList.size(); rowNum++)
						{
							IndicatorWrapper wrapper = this.indicatorList.get(rowNum);
							if(wrapper.csmIndicator.CSM_Object_Field_Name__c == tmpField.getDescribe().getName())
							{
							 	selectOptionSet.remove(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
							 	objectFieldMap.remove(selectedObject + tmpField.getDescribe().getName());
							}	
						}
                       
                    }
                    
                    objectSelectOptionMap.put(selectedObject, selectOptionSet);
                    soFieldList.addAll(selectOptionSet);                                       
                }
                
                
            } 
            CSM_Util.sortSelectOptionByLabel(soFieldList);
            return soFieldList;
        }
        catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             return null;
        }
    }   
  
    
     /**
	* @description creae a new row in the data table
	* @return null
	*/
    public PageReference addField()
    {
        if (!String.isBlank(selectedField))
        {
        	Schema.SObjectField objectField = objectFieldMap.get(selectedObject+selectedField);
            IndicatorWrapper newIndicator = new IndicatorWrapper(objectField, selectedObject, selectedField, indicatorGroupId);  
            if (indicatorList == null)
            {
            	indicatorList = new List<IndicatorWrapper>();
            }          
            indicatorList.add(newIndicator);            
            Set<SelectOption> selectOptionSet = objectSelectOptionMap.get(selectedObject);
            SelectOption objectToRemove = new SelectOption(objectField.getDescribe().getName(), objectField.getDescribe().getLabel());
            selectOptionSet.remove(objectToRemove);  
            objectSelectOptionMap.put(selectedObject, selectOptionSet);             
        }
        
        return null;
    }
    
     /**
	* @description Upserts all Indicators for the Indicator Group
	* @return null
	*/
    public PageReference Save()
    {			
    	List<CSM_Indicator__c> listIndicator = new List<CSM_Indicator__c>();
    	try
    	{
			for (IndicatorWrapper indicator:indicatorList) 
			{
			    if (!String.isBlank(indicator.csmIndicator.CSM_Indicator_Display_Name__c))
	            {	
	            	indicator.csmIndicator.Name = indicator.csmIndicator.CSM_Indicator_Display_Name__c;
				    listIndicator.add(indicator.csmIndicator);
	            }
			}
			if (!listIndicator.isEmpty())
			{
			    CSM_IndicatorDataAccess.upsertListIndicator(listIndicator);
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
    	  	   	
		return null;
	}
	
	public PageReference successplantempindicatorList()
	{
		List<CSM_Account_Plan_Template_Indicator__c> accountplantempindiList = new List<CSM_Account_Plan_Template_Indicator__c>();
		accounttempindicatorCount = 0;
		accounttempindicatorName = '';
		accounttempindicatorList = '';
		try
		{
			accountplantempindiList = CSM_AcctPlanTemplateIndicatorDataAccess.getSuccessPlanTempIndicatorAll(indicatorId);
			if(accountplantempindiList != null && !accountplantempindiList.isEmpty())
			{
				accounttempindicatorCount = accountplantempindiList.size();
				if(accounttempindicatorCount <= 5 && accounttempindicatorCount != 0)
				{
					List<String> acctPlanIndList = new List<String>();
					for(CSM_Account_Plan_Template_Indicator__c apti :accountplantempindiList)
					{
						accounttempindicatorName = apti.CSM_Account_Plan_Template__r.CSM_Template_Name__c;
						if(accounttempindicatorName != null)
						{
							acctPlanIndList.add(accounttempindicatorName);
							//accounttempindicatorList += accounttempindicatorName;
							//accounttempindicatorList += '\\n';
						}
						accounttempindicatorName = '';
					}
					accounttempindicatorList = JSON.serialize(acctPlanIndList);
				}
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
		return null;
	}
	/*Delete SuccessPlan and Indicator association and Indicators*/
	public PageReference deleteSuccessPlanIndicator()
	{
		boolean isSuccess;
		List<CSM_Account_Plan_Template_Indicator__c> successplantempindicatorList = new List<CSM_Account_Plan_Template_Indicator__c>();
		List<CSM_Indicator__c> indicatorListForDelete = new List<CSM_Indicator__c>();
		try
		{
			successplantempindicatorList = CSM_AcctPlanTemplateIndicatorDataAccess.getSuccessPlanTempIndicatorAll(indicatorId);
			if(successplantempindicatorList != null && !successplantempindicatorList.isEmpty())		
			{
				isSuccess = CSM_AcctPlanTemplateIndicatorDataAccess.deleteAcctPlanTmplIndicatorList(successplantempindicatorList);
				if(isSuccess == true)
				{
					indicatorListForDelete = CSM_IndicatorDataAccess.getIndicatorById(indicatorId);
					if(indicatorListForDelete != null && !indicatorListForDelete.isEmpty())
					{
						CSM_IndicatorDataAccess.deleteIndicator(indicatorListForDelete);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_INDICATOR_DELETE));
					}
				}
			}
			else
			{
				indicatorListForDelete = CSM_IndicatorDataAccess.getIndicatorById(indicatorId);
				if(indicatorListForDelete != null && !indicatorListForDelete.isEmpty())
				{
					CSM_IndicatorDataAccess.deleteIndicator(indicatorListForDelete);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_INDICATOR_DELETE));
				}
			}
			//this.indicatorList = null;
			
			for(Integer rowNum=0; rowNum<this.indicatorList.size(); rowNum++)
			{
				IndicatorWrapper wrapper = this.indicatorList.get(rowNum);
				if(wrapper.csmIndicator.CSM_Object_Field_Name__c == indicatorField){
					this.indicatorList.remove(rowNum);
					break;
				}	
			}
			
			objectFieldMap = new Map<String, Schema.SObjectField>();
        	objectSelectOptionMap = new Map<String, Set<SelectOption>>();
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
		return null;
	}
	 /**
	* @description Clears all changes since last save
	* @return null
	*/
    public PageReference Cancel()
    {			
    	indicatorList = null;
    	existingFieldSet = new Set<String>();
    	objectSelectOptionMap = new Map<String, Set<SelectOption>>();     	
        return null;
	}
    
     /**
	* @description Creating local reference to the CSM_IndicatorGroupComponentController so that 
	*              setIndicatorComponentControllerMap may be used.
	*/
    public CSM_IndicatorGroupComponentController CSM_IndicatorGroupComponentController
	{ 
		get; 
    	set 
    	{
			if (value != null) 
			{
				CSM_IndicatorGroupComponentController = value;		
						
			}
		}
	}	
    
     /**
	* @description used to set the local indicatorGroupId as well as create a record for this group and controller in the
	*              CSM_IndicatorComponentControllerMap.
	*/
    public Id indicatorGroupId
    {
    	get; 
    	set
    	{    		
    		if (value != null) 
			{
				indicatorGroupId = value;
			    if (CSM_IndicatorGroupComponentController != null)
			    {
				    CSM_IndicatorGroupComponentController.setIndicatorComponentControllerMap(indicatorGroupId, this);
			    }		
			}
    	}
    }
    
    public List<IndicatorWrapper> indicatorList
    {
    	get
    	{
    		try 
    		{
	    		if (indicatorList == null)
	    		{
	    			indicatorList = new List<IndicatorWrapper>();
	    			
	        	    List<CSM_Indicator__c> listOfIndicators = CSM_IndicatorDataAccess.findIndicatorsByGroup(indicatorGroupId);
				    if (listOfIndicators != null)
				    {
				        for (CSM_Indicator__c indicator: listOfIndicators)
				        {
				        	Schema.SObjectField objectField = null;
				        	if (objectFieldMap.containsKey(indicator.CSM_Object_Name__c+indicator.CSM_Object_Field_Name__c))
				        	{
				        		objectField = objectFieldMap.get(indicator.CSM_Object_Name__c+indicator.CSM_Object_Field_Name__c);
				        	}
				        	else 
				        	{
				        	    List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(indicator.CSM_Object_Name__c);
			                    for( Schema.SObjectField tmpfield :fieldList)
			                    {         
			                        if (String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_DATE
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_STRING
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_INTEGER
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_PICKLIST
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_DOUBLE
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_CURRENCY
			                                || String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_PERCENT)
			                                
			                        {                            
			                            
			                            objectFieldMap.put(indicator.CSM_Object_Name__c + tmpField.getDescribe().getName(), tmpfield);
			                        }
			                        objectField = objectFieldMap.get(indicator.CSM_Object_Name__c+indicator.CSM_Object_Field_Name__c);
			                       
			                    }
				        	}
				        	existingFieldSet.add(indicator.CSM_Object_Name__c+indicator.CSM_Object_Field_Name__c);
				        	indicatorList.add(new IndicatorWrapper(indicator,  objectField));			        	
				        }
				    }      
	    		}
	    		return indicatorList;
    		}  	 
	    	catch (Exception ex)
            {            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
                return null;
            }   
    	}
    	set;
    	
    }
    
     /**
	* @description wrapper class used for rows in the data table
	*/
    public with sharing class IndicatorWrapper
    {
        public CSM_Indicator__c csmIndicator {get; set;}
        public String sfFieldName {get; set;}        
       
        
        public IndicatorWrapper(Schema.SObjectField objectField, String selectedObject, String selectedField, Id indicatorGroupId) 
        {
        	csmIndicator = new CSM_Indicator__c();       	
        	csmIndicator.CSM_Indicator_Group__c = indicatorGroupId;
        	csmIndicator.CSM_Object_Field_Name__c = selectedField;
        	csmIndicator.CSM_Object_Name__c = selectedObject;
        	csmIndicator.CSM_Indicator_Display_Name__c = objectField.getDescribe().getLabel();
        	csmIndicator.CSM_IsActive__c = true;
            csmIndicator.CSM_Object_Field_Label__c = objectField.getDescribe().getLabel();
            this.sfFieldName = selectedObject + '.' + selectedField;            
            csmIndicator.CSM_Object_Field_Type__c = String.valueOf(objectField.getDescribe().getType());
        }
        
        public IndicatorWrapper(CSM_Indicator__c indicator,  Schema.SObjectField objectField)
        {
            this.csmIndicator = indicator;
            this.sfFieldName = indicator.CSM_Object_Name__c + '.' + indicator.CSM_Object_Field_Name__c;            
        }
    }
}