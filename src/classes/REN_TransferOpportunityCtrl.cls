public with sharing class REN_TransferOpportunityCtrl {
    public List<objectFieldWrapper> lookupfieldWrapperList{get;set;}
    public objectFieldWrapper lookupfieldWrapper{get;set;}
    public String searchValue {get;set;}
    List<SelectOption> wrappers {get;set;} 
    public String selectedRecords {get;set;}
    public String selectedUserId {get;set;}
    Set<String> recordIdSet {get;set;}
    public String selectedRecordid {get;set;}
    public Boolean hasError {get;set;}
    public REN_TransferOpportunityCtrl(){
        hasError = false;
    	lookupfieldWrapperList = new List<objectFieldWrapper>();
    }
    
    public void setRecords(){
        recordIdSet = REN_Util.convertCSVtoSet(this.selectedRecords, '-');
    }
    
    public void setSelectedId(){
        //selectedRecordId = ApexPages.currentPage().getParameters().get('selectedRecordId');
        System.debug('selectedRecordId == ' + selectedRecordId);
    }
    
    public void transferRecords(){
        List<Opportunity> recordsToUpdate = new List<Opportunity>();
        try{
            hasError = false;
            System.debug('selectedRecordid == ' + selectedRecordId);
            System.debug('recordIdSet == ' + recordIdSet);
            if(this.recordIdSet != null && !this.recordIdSet.isEmpty() && selectedRecordId != null){
                for(String recordId : this.recordIdSet){
                    Opportunity oppty = new Opportunity(Id = (Id)recordId, OwnerId = (Id)selectedRecordId);
                    recordsToUpdate.add(oppty);
                }
                
            }
            CSM_TriggerManager.disableAllTriggers();
            System.debug('recordsToUpdate == ' + recordsToUpdate);
            update recordsToUpdate;
            //REN_OpportunityDataAccess.updateOpportunityforRenewals(recordsToUpdate);
            System.debug('recordsToUpdate == ' + recordsToUpdate);
            
        }catch(Exception e){
            hasError = true;
			System.debug(e );
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));      
		}
        
    }
    
    public void searchRecords(){
        if(searchValue != null){
            lookupfieldWrapperList.clear();
            String query = 'SELECT Name, Id, Profile.Name, UserRole.Name FROM User WHERE isActive = true AND Name like \'%' + searchValue + '%\'';
            List<User> userList = (List<User>)Database.query(query);
            objectFieldWrapper obWrapper;
            For(User user : UserList){
                obWrapper = new objectFieldWrapper();
                obWrapper.fullName = user.Name;
                obWrapper.profile = user.profile.Name;
                obWrapper.role = user.userRole.Name;
				obWrapper.recordId = user.Id;
                obWrapper.isSelected = false;
                lookupfieldWrapperList.add(obWrapper);
            }
        }
    }
    public class objectFieldWrapper{
        public boolean isSelected {get;set;}
    	public String recordId{get;set;}
        public String fullName{get;set;}
        public String profile{get;set;}
        public String role{get;set;}
    }  
}