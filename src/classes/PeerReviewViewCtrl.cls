public with sharing class PeerReviewViewCtrl {
    public Peer_Review__c thisPeerReview {get; set;}
    public List<SelectOption> CaseRecordTypeOptions = new List<SelectOption>();
    public List<SelectOption> BusinessLineOptions = new List<SelectOption>();
    public List<SelectOption> EngagementTypeOptions = new List<SelectOption>();
    public List<SelectOption> OpportunityTypeOptions = new List<SelectOption>();
    public List<SelectOption> SSITheatreOptions = new List<SelectOption>();
    public List<SelectOption> ClientTerritoryOptions = new List<SelectOption>();
    public List<SelectOption> ClientRegionOptions = new List<SelectOption>();
    public boolean PeerReviewEdit {get; set;}
    
    public PeerReviewViewCtrl(ApexPages.StandardController controller) {
        thisPeerReview = (Peer_Review__c)controller.getRecord();
        setCaseRecordTypeOptions();
        setBusinessLineOptions();
        setEngagementTypeOptions();
        setOpportunityTypeOptions();
        setSSITheatreOptions();
        setClientTerritoryOptions();
        setClientRegionOptions();
        initialize();
    }
    
    public void initialize() {
        PeerReviewEdit = false;
    }
    
    public List<SelectOption> getCaseRecordTypeOptions() {
        return CaseRecordTypeOptions;
    }
    
    public void setCaseRecordTypeOptions() {
    	RecordType objRecordType = new RecordType();
    	Set<Id> recordTypeIds = new Set<Id>();
    	recordTypeIds.add(objRecordType.Id);
        CaseRecordTypeOptions.add(new SelectOption('', '--'+Label.LBL_NONE+'--'));
        for(RecordType recordTypeList: CaseDataAccess.getRecordTypeIdByCase(recordTypeIds)){
            CaseRecordTypeOptions.add(new SelectOption(recordTypeList.Id, recordTypeList.Name));        
        }
    }
    
    public List<SelectOption> getBusinessLineOptions() {
        return BusinessLineOptions;
    }
    
    public void setBusinessLineOptions() {
        BusinessLineOptions.add(new SelectOption('', '--'+Label.LBL_NONE+'--'));
        Schema.DescribeFieldResult BusinessLineDescription = Opportunity.Business_Line__c.getDescribe();
        for (Schema.Picklistentry picklistEntry: BusinessLineDescription.getPicklistValues()){
            BusinessLineOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    }
    
    public List<SelectOption> getEngagementTypeOptions() {
        return EngagementTypeOptions;
    }
    
    public void setEngagementTypeOptions() {
        EngagementTypeOptions.add(new SelectOption('', '--'+Label.LBL_NONE+'--'));
        Schema.DescribeFieldResult EngagementTypeDescription = Opportunity.Engagement_Type__c.getDescribe();
        for (Schema.Picklistentry picklistEntry: EngagementTypeDescription.getPicklistValues()){
            EngagementTypeOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    }
    
    public List<SelectOption> getOpportunityTypeOptions() {
        return OpportunityTypeOptions;
    }
    
    public void setOpportunityTypeOptions() {
        OpportunityTypeOptions.add(new SelectOption('', '--'+Label.LBL_NONE+'--'));
        Schema.DescribeFieldResult OpportunityTypeDescription = Opportunity.Opportunity_Type__c.getDescribe();
        for (Schema.Picklistentry picklistEntry: OpportunityTypeDescription.getPicklistValues()){
            OpportunityTypeOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    }
    
    public List<SelectOption> getSSITheatreOptions() {
        return SSITheatreOptions;
    }
    
    public void setSSITheatreOptions() {
        SSITheatreOptions.add(new SelectOption('', '--'+Label.LBL_NONE+'--'));
        Schema.DescribeFieldResult SSITheatreDescription = Opportunity.SSI_Theatre__c.getDescribe();
        for (Schema.Picklistentry picklistEntry: SSITheatreDescription.getPicklistValues()){
            SSITheatreOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    }
    
    public List<SelectOption> getClientTerritoryOptions() {
        return ClientTerritoryOptions;
    }
    
    public void setClientTerritoryOptions() {
        ClientTerritoryOptions.add(new SelectOption('', '--'+Label.LBL_NONE+'--'));
        Schema.DescribeFieldResult ClientTerritoryDescription = Opportunity.Client_Territory__c.getDescribe();
        for (Schema.Picklistentry picklistEntry: ClientTerritoryDescription.getPicklistValues()){
            ClientTerritoryOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    }
    
    public List<SelectOption> getClientRegionOptions() {
        return ClientRegionOptions;
    }
    
    public void setClientRegionOptions() {
        ClientRegionOptions.add(new SelectOption('', '--'+Label.LBL_NONE+'--'));
        Schema.DescribeFieldResult ClientRegionDescription = Opportunity.Client_Region__c.getDescribe();
        for (Schema.Picklistentry picklistEntry: ClientRegionDescription.getPicklistValues()){
            ClientRegionOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    }
    
    public void onPeerReviewEdit() {
        PeerReviewEdit = true;
    }
    
    public void offPeerReviewEdit() {
        PeerReviewEdit = false;
    }
    
    public void cancelEdit() {
        initialize();
    }
}