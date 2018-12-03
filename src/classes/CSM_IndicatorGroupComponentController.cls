/**
* @author         Michelle Lairson(michelle@comitydesigns.com)
* @date           07.23.2014
* @description    CSM_IndicatorGroupComponentController for CSM_IndicatorGroupComponent
*/
public with sharing class CSM_IndicatorGroupComponentController 
{
	public String successfulSave {get; set;}  
	public String indicatorGroupName {get; set;}
	public boolean renderErrorOnSave {get; set;}
	public boolean disableNewButton {get; set;}
		
	private Map<Id, CSM_IndicatorComponentController> indicatorComponentControllerMap;
	
	/**
	* @description get method to return the Indicator Controller Map
	*/
	public  Map<Id, CSM_IndicatorComponentController> getIndicatorComponentControllerMap()
	{
		return indicatorComponentControllerMap;
	}
	
	/**
	* @description get method to return the Indicator Controller Map
	* @param the Indicator Group Id assocated with this controller
	* @param the controller assocated with thsi Indicator Group Id
	*/
	public void setIndicatorComponentControllerMap(Id key, CSM_IndicatorComponentController compController)
	{
		if (indicatorComponentControllerMap == null)
		{
			indicatorComponentControllerMap = new Map<Id, CSM_IndicatorComponentController>();			
		}
		indicatorComponentControllerMap.put(key, compController);
	}
	
	/**
	* @description Clear the changes made from last Save
	*/
	public PageReference clearChanges() 
	{
		try
        {   
        	if (indicatorComponentControllerMap != null)
		    { 
		        for (CSM_IndicatorComponentController indicatorController: indicatorComponentControllerMap.values())
		        {
		        	indicatorController.Cancel();
		        }
		    }
	        return null;
        }
        catch(Exception ex)
        {       
        	
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
    		return null;
        }
	}
	
	/**
	* @description Save the Indicators from all the Indicator Groups	
	*/
    public PageReference saveIndicators()
    {
    	try
        {   
        	if (indicatorComponentControllerMap != null)
		    {
		        for (CSM_IndicatorComponentController indicatorController: indicatorComponentControllerMap.values())
		        {
		        	indicatorController.Save();
		        }
		        if(!ApexPages.HasMessages(ApexPages.SEVERITY.ERROR))
				{				
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_INDICATOR_SAVE));
				}
		    }
		    return null;
        }
        catch(Exception ex)
        {       
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
    		return null;
        }
    }
   
     /**
	* @description saves a new indicator group and closes the dialog
	*/
    public void saveNewIndicatorGroup() 
    {        
    	try
    	{
    		
    		successfulSave = 'false';
    		renderErrorOnSave = true;
	        if (String.isBlank(indicatorGroupName))
	        {
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING, Label.CSM_MSG_ENTER_NAME));
	        }
	        else
	        {	        	
	        	
	            CSM_Indicator_Group__c indicatorGroup = new CSM_Indicator_Group__c();
	        	indicatorGroup.CSM_Display_Name__c = indicatorGroupName;
	        	List<CSM_Indicator_Group__c> indicatorGroupList = new List<CSM_Indicator_Group__c>();
	        	indicatorGroupList.add(indicatorGroup);
	        	CSM_IndicatorGroupDataAccess.insertIndicatorGroup(indicatorGroupList);
	        	successfulSave = 'true';
	        	renderErrorOnSave = false;        	
	        }
    	}
    	catch(Exception e)
    	{    	
    		 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
    	}
            
    } 
    
    public void cancelNewIndicatorGroup() 
    {
    	renderErrorOnSave = false;
    }
       
  
     /**
	* @description retrieves groups to be used in the IndicatorComponent
	* @return a list of indicator groups
	*/
    public List<CSM_Indicator_Group__c> getIndicatorGroups ()       
    {
    	try
    	{ 
    		List<CSM_Indicator_Group__c> indicatorGroupList = CSM_IndicatorGroupDataAccess.getAllIndicatorGroups();
    		disableNewButton = !indicatorGroupList.isEmpty();
            return indicatorGroupList;
    	}
    	catch(Exception e)
    	{    	
    		 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
    		 return new List<CSM_Indicator_Group__c>();
    	}
    	       
    }
    
     /**
	* @description Use this controller in the children CSM_IndicatorComponentControllers so that 
	*              the setIndicatorComponentControllerMap may be called.
	* @return this controller
	*/
    public CSM_IndicatorGroupComponentController getThis() 
	{
    	return this;
	}
}