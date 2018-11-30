public with sharing class CSM_AccountBusinessLayer extends CSM_BusinessLayer {
	
	private String VIEW_HEALTH_STATUSES = 'HealthStatus';
	private String SUCCESS_PLAN = 'SuccessPlan';
	private String SUCCESS_PLAN_ACTIVE = 'SuccessPlanActive';
	
	private DAte lowDate;
	private Date highDate;
	
	public CSM_AccountBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
		super(inputWrapper);
		system.debug('Entered CSM_AccountBusinessLayer Constructor $$ ');
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
		system.debug('Entered retrieveSObjectWrapperList  $$ ');
		return getAccountWrapperList();
	}
	
	public CSM_GridResponseWrapper getAccountWrapperList()
	{
		CSM_GridResponseWrapper accountWrapperList = new CSM_GridResponseWrapper();
		
		
		List<sObject> accountList = new List<sobject>();
		if (VIEW_HEALTH_STATUSES.equalsIgnoreCase(this.inputWrapper.viewName)){
			accountList = getAccountHealthStatusList();
			accountWrapperList.header = setAccountHeader();
			//setup the CSM_GridColumnWrapper object for header values, 
			//since this is specific for healthStatus, we know what the headers need to set specifically
			accountWrapperList.hasCheckbox = false;
			accountWrapperList.hasAction = false;
			accountwrapperList.hasDetail = false;
		}
		//setup the CSM_GridRowWrapper for the column values to be fed in it, maintain the order in which the headers are created.
		accountWrapperList.row = setAccountRows(accountList, accountWrapperList.header);
		return accountWrapperList;
	}
	
	/* Desc: if the date range is null, queries to get the health status logic
		If it isn't null, uses the query that leverage date ranges 
	*/
	private List<Sobject> getAccountHealthStatusList() {
		List<Account> tmpList = new List<Account>();
		if(inputWrapper.params != null){
			if (inputWrapper.params.dateRange == null)
	        {   
	            try
	            {
	            	tmpList = CSM_AccountDataAccess.getAccountsByHealthStatusFilterAttr(inputWrapper.params.healthStatus, 
	                			inputWrapper.params.userPrefWrapper.attrFieldName, 
	                			inputWrapper.params.userPrefWrapper.attrFieldType, 
								inputWrapper.params.userPrefWrapper.attrFieldValue,
								inputWrapper.params.userPrefWrapper.attObjectType);
	            }
	            catch (exception ex)
	            {
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage())); 
	            }
	        }
	        else
	        {
				Date lowDate = null;
	            Date highDate = null;
	            if (inputWrapper.params.dateRange == CSM_Constants.MORE_THAN_121)
	            {
	                lowDate = System.today().addDays(-121);
	            }
	            else if (inputWrapper.params.dateRange == CSM_Constants.BETWEEN_91_120)
	            {
	                lowDate = System.today().addDays(-91);
	                highDate = System.today().addDays(-121);
	            }
	            else if (inputWrapper.params.dateRange == CSM_Constants.BETWEEN_61_90)
	            {
	                lowDate = System.today().addDays(-61);
	                highDate = System.today().addDays(-91);
	            }
	            else if (inputWrapper.params.dateRange == CSM_Constants.BETWEEN_31_60)
	            {
	                lowDate = System.today().addDays(-31);
	                highDate = System.today().addDays(-61);
	            }
	            else if (inputWrapper.params.dateRange == CSM_Constants.BETWEEN_0_30)
	            {
	                lowDate = System.today().addDays(-0);
	                highDate = System.today().addDays(-31);
	            }
	            try
	            {
	                //gets account datagetAccountsByHealthStatusAndDateRangeWithFilterAttr
	                //tmpList = CSM_AccountDataAccess.getAccountsByHealthStatusAndDateRangeWithFilter(inputWrapper.params.healthStatus, lowDate, highDate, inputWrapper.params.userPrefWrapper.attrFieldName, inputWrapper.params.userPrefWrapper.attrFieldType, inputWrapper.params.userPrefWrapper.attrFieldValue);
	                tmpList = CSM_AccountDataAccess.getAccountsByHealthStatusAndDateRangeWithFilterAttr(inputWrapper.params.healthStatus, 
	                										lowDate, highDate, inputWrapper.params.userPrefWrapper.attrFieldName, 
	                										inputWrapper.params.userPrefWrapper.attrFieldType, 
	                										inputWrapper.params.userPrefWrapper.attrFieldValue,
	                										inputWrapper.params.userPrefWrapper.attObjectType);
	            }
	            catch (exception ex)
	            {
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage())); 
	            }
	        }
		}
        return tmpList;
	}
	
	private List<CSM_GridColumnWrapper> setAccountHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//This is the build for the Health Status Page (used for charts) 
		if (VIEW_HEALTH_STATUSES.equalsIgnoreCase(this.inputWrapper.viewName)){
			CSM_GridColumnWrapper col1 = new CSM_GridColumnWrapper();
	        col1.apiName = CSM_Constants.OBJ_A_ID;
			col1.label = SObjectType.Account.fields.Name.label;
			//col1.label = 'Name';
			col1.valueCol = CSM_Constants.OBJ_A_NAME;
			col1.lookUpIdCol = CSM_Constants.OBJ_A_ID;
			col1.isSortable = true;
			col1.customColumnSorter = 'customColumnSorter';
			gridClmWrapper.add(col1);
			
			CSM_GridColumnWrapper col2 = new CSM_GridColumnWrapper();
	        col2.apiName = CSM_Constants.OBJ_AP_DISPLAY_NAME;
			col2.label = SObjectType.CSM_Account_Plan__c.fields.Name.label;
			//col2.label = 'Success Plan';
			col2.valueCol = 'SuccessPlan';
			col2.lookUpIdCol = CSM_Constants.OBJ_AP_ID;
			col2.isSortable = false;
			gridClmWrapper.add(col2);
			
			CSM_GridColumnWrapper col3 = new CSM_GridColumnWrapper();
	        col3.apiName = CSM_Constants.OBJ_AP_ACTIVE;
			//col3.label = 'Success Plan Active';
			col3.label = Label.CSM_LBL_SUCCESS_PLAN_ACTIVE;
			col3.valueCol = 'SuccessPlanActive';
			//col.lookUpIdCol = 'Id';
			col3.isSortable = true;
			gridClmWrapper.add(col3);
		}
		return gridClmWrapper;
	} 	
	
	private List<CSM_GridRowWrapper> setAccountRows(List<sObject> acctList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		//If the account list isn't null loop through it building the grid rows. 
		if(acctList != null && !acctList.isEmpty()) {
			for(SObject sObj : acctList) {
				CSM_GridRowWrapper row = new CSM_GridRowWrapper();
            	row.accountId = String.valueOf(sObj.get(CSM_Constants.OBJ_A_ID));
			    row.sObj = sObj;
			    row.namespace = CSM_Util.getNamespace();
			    row.columns = new List<CSM_GridColumnWrapper>();
                row.hasGridImage = false;
                row.isMC = CSM_Util.checkMCEnabled();
                if (colList!=null){
                    row.columns = colList;
                    if(VIEW_HEALTH_STATUSES.equalsIgnoreCase(this.inputWrapper.viewName)) {
						List<SObject> sPlans = sObj.getSObjects('Success_Plans__r');
						row.isActive = false;
						row.hasGridImage = false;
						if (sPlans!=null && !sPlans.IsEmpty()){
							row.hasGridImage = true;
							row.isActive = true;
						}
					}	
					gridRowWrapper.add(row);
				}
			}
		}
	
		return gridRowWrapper;
	}
}