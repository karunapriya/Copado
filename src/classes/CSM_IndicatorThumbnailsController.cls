public with sharing class CSM_IndicatorThumbnailsController
{
		
	public String accountId {get; set;}
	public String acctPlanTemplateId {get; set;}
	//MF Changed for viewState
	private transient List<CSM_IndicatiorThumbnailWrapper> indicatorWrapperList;
	//MF Changed for viewState 
	//public Account AcctObject;
	private transient Account acctObject;
	public boolean mcEnabled {get; set;}	
	
	public List<CSM_IndicatiorThumbnailWrapper> getIndicatorWrapperList ()
	{
		mcEnabled = UserInfo.isMultiCurrencyOrganization();
		CSM_IndicatorRetriever retriever = new CSM_IndicatorRetriever();
		indicatorWrapperList = retriever.getIndicatorWrapperList(acctPlanTemplateId, accountId);
			
		return indicatorWrapperList;
	}
	
	public Account getAcctObject()
	{
	    try
	    {
	    	List<Account> acctList = CSM_AccountDataAccess.getAccountInformationById(accountId);
	        if (acctList != null && !acctList.isEmpty())
	        {
	        	acctObject = acctList[0];
	        	return acctObject;
	        }	
	    }
	    
	    catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             
        }
        return null;
	}
	   
}