public with sharing class REN_SegmentAdditionalDetailsController{
	private string parentId;
	public String segmentIds {get; set;}
	public CSM_DataGridAttribute assetGridAttribute{get; set;}
	public Boolean showDataGrid{get; set;}
    public Id deletesegmemberId {get; set;}
    public Boolean showBackButton {get; set;}
    public String segmentName {get; set;}
    
     public Boolean hasRenewAccess {
        get;
        private set;
    }
    public Boolean theLinksAreVisible {
        get;
        private set;
    }
    
    public String helpParam {
        get;
        set;
    }
        
    public REN_SegmentAdditionalDetailsController() {
        this.parentId = apexpages.currentPage().getParameters().get('parentId');
        this.showDataGrid = true;
        this.setGridAttributes();
        
        if(apexpages.currentPage().getParameters().get('src') != null) {
        	showBackButton = true;
        } else {
        	showBackButton = false;
        }
        
        List<REN_Segment__c> segments = REN_SegmentDataAccess.getSegmentsById(new Set<String>{ this.parentId });
				
		if(segments != null && !segments.isEmpty()) {
			this.segmentName = segments[0].Name;
		}
        
        //helpParam = Label.REN_LBL_SERVICE_CONTRACTS;
        this.theLinksAreVisible = true;
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        system.debug('hasRenewAccess='+hasRenewAccess);
        if (ApexPages.currentPage().getParameters().get(CSM_Constants.ADMIN_HYPERLINK_FLAG) == 'false') {
            this.theLinksAreVisible = false;
        }     
    }

    public PageReference deletesegmember(){
    	try{	
			system.debug('deletesegmemberId $$$$$$$ '+deletesegmemberId);
			List<REN_Segment_Member__c> listsegmembers = new List<REN_Segment_Member__c>();
	        system.debug('delete ..');
	        List<String> deleteList = new List<String>();
	        if(!String.isBlank(segmentIds)){
		        deleteList = segmentIds.split('-');
		        for(String delItem :deleteList)
		        {
		        	listsegmembers.add(new REN_Segment_Member__c(Id=delItem));
		        }			
			    REN_SegmentMemberDataAccess.deletesegmember(listsegmembers);
	        }
		}
		catch (Exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
            return null;
        } 
    	return null;		
	}
    
    /*
	** @Description: Navigate back
	*/
	public PageReference backButtonClick() {
		PageReference pageRef;
		String src = ApexPages.currentPage().getParameters().get('src');
		
		if(src != null) {
			if(src == 'segmentdetail') {
				pageRef = Page.REN_SegmentDetail;
				pageRef.getParameters().put('id', this.parentId);
				pageRef.getParameters().put('tabCategory', 'Playmaker');
			} else {
				return null;
			}
		} else {
			return null;
		}
		
		pageRef.setRedirect(true);
		return pageRef;
	}
    
    private void setGridAttributes() {
		assetGridAttribute = new CSM_DataGridAttribute();        
	    assetGridAttribute.tableName = 'SegMember';
	    assetGridAttribute.objectType ='SegmentMember';
	    assetGridAttribute.viewName ='SegmentMember';
	    assetGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
	    assetGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
	    assetGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
	    assetGridAttribute.gridToolBarId='grid-toolbar';
	    assetGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
       	assetGridAttribute.showExport=CSM_Constants.GRID_ATTR_TRUE;
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
        
        List<REN_Segment__c> segments = REN_SegmentDataAccess.getSegmentsById(new Set<String>{this.parentId});
        	
        system.debug('Type='+segments[0].REN_Type__c);
	   	if(segments[0].REN_Type__c == REN_Constants.OBJ_SE_TYPE_ABRLM) {
          	gridInputParams.selectedTaskFilter= segments[0].REN_Type__c;
		} else if(segments[0].REN_Type__c == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
            gridInputParams.selectedTaskFilter= segments[0].REN_Type__c;
		}
            
        gridInputParams.selectedFilterClause='Where REN_Segment__c = \'' + this.parentId + '\'';
        assetGridAttribute.params = JSON.serialize(gridInputParams);
    	
    }
    
}