public with sharing class CHL_PortalGroupMembersViewBusinessLayer extends CSM_BusinessLayer {
	private String namespace;
    public CHL_PortalGroupMembersViewBusinessLayer(CSM_CustomGridInputWrapper inputWrapper)
    {
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList()
    {
        return getPortalGroupMembersWrapperList();
    }
    
    private CSM_GridResponseWrapper getPortalGroupMembersWrapperList() 
    {   
        CSM_GridResponseWrapper portalGrpMemResponseWrapper = new CSM_GridResponseWrapper();
        this.namespace = CSM_Util.getNamespace();
        try
        {
            portalGrpMemResponseWrapper.header = getGridColumnHeader();
            portalGrpMemResponseWrapper.row = getRecordList(portalGrpMemResponseWrapper.header);
            portalGrpMemResponseWrapper.hasCheckbox = false;
            portalGrpMemResponseWrapper.hasAction = false;
            portalGrpMemResponseWrapper.hasDetail = false;
            system.debug('\n\n~~~gridResponseWrapper: '+portalGrpMemResponseWrapper);
        }
        catch(Exception e)
        {
            portalGrpMemResponseWrapper.errorMessage = e.getMessage();
            system.debug(e);
        }
        return portalGrpMemResponseWrapper;
    }
    
    private List<CSM_GridColumnWrapper> getGridColumnHeader() {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has te be maintained for the headers to be set and the response columns
        //Completion Date
        CSM_GridColumnWrapper portalGroupMemberViewColumn = new CSM_GridColumnWrapper();
        
        //User Name
        portalGroupMemberViewColumn = new CSM_GridColumnWrapper();
        portalGroupMemberViewColumn.apiName = this.namespace + 'CHL_Partner_User__c';
        portalGroupMemberViewColumn.label = 'User Name';
        portalGroupMemberViewColumn.valueCol = 'CHL_Partner_User__r.Name';
        portalGroupMemberViewColumn.isSortable = true;
        portalGroupMemberViewColumn.isDateCol = false;
        portalGroupMemberViewColumn.isCurrencyCol = false;
        portalGroupMemberViewColumn.lookUpIdCol = this.namespace + 'CHL_Partner_User__c';
        gridClmWrapper.add(portalGroupMemberViewColumn);
        
        //Association
        portalGroupMemberViewColumn = new CSM_GridColumnWrapper();
        portalGroupMemberViewColumn.apiName = 'AccountId';
        portalGroupMemberViewColumn.label = 'Association';
        portalGroupMemberViewColumn.valueCol = 'CHL_Partner_User__r.Account.Name';
        portalGroupMemberViewColumn.isSortable = true;
        portalGroupMemberViewColumn.isDateCol = false;
        portalGroupMemberViewColumn.isCurrencyCol = false;
        portalGroupMemberViewColumn.lookUpIdCol = 'CHL_Partner_User__r.AccountId';
        gridClmWrapper.add(portalGroupMemberViewColumn);
        
        //Date Added
        portalGroupMemberViewColumn = new CSM_GridColumnWrapper();
        portalGroupMemberViewColumn.apiName = 'CreatedDate';
        portalGroupMemberViewColumn.label = 'Date Added';
        portalGroupMemberViewColumn.valueCol = 'CreatedDate';
        portalGroupMemberViewColumn.isSortable = true;
        portalGroupMemberViewColumn.isDateCol = true;
        portalGroupMemberViewColumn.isCurrencyCol = false;
        gridClmWrapper.add(portalGroupMemberViewColumn);
        
        //Last Login
        portalGroupMemberViewColumn = new CSM_GridColumnWrapper();
        portalGroupMemberViewColumn.apiName = 'LastLoginDate';
        portalGroupMemberViewColumn.label = 'Last Login';
        portalGroupMemberViewColumn.valueCol = 'CHL_Partner_User__r.LastLoginDate';
        portalGroupMemberViewColumn.isSortable = true;
        portalGroupMemberViewColumn.isDateCol = true;
        portalGroupMemberViewColumn.isCurrencyCol = false;
        gridClmWrapper.add(portalGroupMemberViewColumn);
        
        return gridClmWrapper;
    }
    
    private List<CSM_GridRowWrapper> getRecordList(List<CSM_GridColumnWrapper> colList){
        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
        String userLocale = UserInfo.getLocale();
        List<Sobject> portalGroupMembers = new List<CHL_Portal_Group_Member__c>();
        portalGroupMembers = CHL_PortalGroupDataAccess.getAllPortalGroupMembers(this.inputWrapper.params.taskOrViewId);
        //List<Sobject> portalGroupHierarchyUserList = CHL_Util.getHierarchyUsersByPortalGroupId(this.inputWrapper.params.taskOrViewId);
        //List<SObject> portalGroupIndividualUserList = CHL_Util.getIndividualUsersByPortalGroupId(this.inputWrapper.params.taskOrViewId);
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        //system.debug(portalGroupHierarchyUserList.size()+'ddddd'+portalGroupIndividualUserList.size());
        if (portalGroupMembers != null && !portalGroupMembers.isEmpty()){
            for(SObject partnerUser :portalGroupMembers) {
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
                row.sObj = partnerUser;
                row.columns = new List<CSM_GridColumnWrapper>();
        		row.namespace = this.namespace;
        		if(partnerUser.get(row.namespace+'CHL_Related_Group_Member__c')==null)
        			row.Sobj.put('Name','Individual');
        		row.isMC = CSM_Util.checkMCEnabled();
                if (colList!=null){
                    row.columns = colList;
                    /* for (CSM_GridColumnWrapper colOrig : colList) {
                        CSM_GridColumnWrapper col = colOrig.clone();
                            if (col.valueCol.contains('.')){
                                String[] objSplit = col.valueCol.split('\\.');
                                if (objSplit!=null && objSplit.size()==2) {
                                    col.value = String.valueOf(partnerUser.getSObject(objSplit[0]).get(objSplit[1]));
                                }
                            }
                            else
                            {
                                col.value = String.valueOf(partnerUser.get(col.valueCol));
                            }
                            if (col.isDateCol!=null && col.isDateCol && !col.valueCol.contains('LastLoginDate')) {
                                if(portalGroupMembers!=null && !portalGroupMembers.isEmpty()){
                                    for(CHL_Portal_Group_Member__c portalGroupMember :portalGroupMembers) {
                                        if(String.isNotBlank(portalGroupMember.CHL_Partner_User__c)) {
                                            if(portalGroupMember.CHL_Partner_User__c == partnerUser.id && portalGroupMember.CHL_Related_Group_Member__c != null) {
                                                if ('CreatedDate'.equalsIgnoreCase(col.valueCol) && String.valueOf(portalGroupMember.get(col.valueCol)) != null)
                                                {
                                                    Datetime createdDateVal = Datetime.valueOf(portalGroupMember.get(col.valueCol));
                                                    col.value = CSM_Util.getLocaleFormattedDateValue(userLocale,createdDateVal,localeMap);
                                                    col.hiddenDate = String.valueOfGmt(createdDateVal);
                                                }
                                            }
                                        }
                                    }   
                                }
                            } else if(col.isDateCol!=null && col.isDateCol && col.valueCol.contains('LastLoginDate')) {
                                if(String.isNotBlank(col.value)) {
                                    Datetime lastLoginDateVal = Datetime.valueOf(col.value);
                                    col.value = String.valueOfGmt(lastLoginDateVal);
                                    col.hiddenDate = String.valueOfGmt(lastLoginDateVal); 
                                }
                            }
                                                    
                        row.columns.add(col);
                    }   */
                    gridRowWrapper.add(row);
                }
            }
        }
        /*if (portalGroupIndividualUserList != null && !portalGroupIndividualUserList.isEmpty()){
            for(SObject partnerUser :portalGroupIndividualUserList) {
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
                row.sObj = partnerUser;
                row.sobj.put('Title','Individual');
                row.columns = new List<CSM_GridColumnWrapper>();
             
                if (colList!=null){
                     row.columns = colList;
                    /*for (CSM_GridColumnWrapper colOrig : colList) {
                        CSM_GridColumnWrapper col = colOrig.clone();
                            if (col.valueCol.contains('.')){
                                String[] objSplit = col.valueCol.split('\\.');
                                if (objSplit!=null && objSplit.size()==2) {
                                    col.value = String.valueOf(partnerUser.getSObject(objSplit[0]).get(objSplit[1]));
                                }
                            }
                            else
                            {
                                col.value = String.valueOf(partnerUser.get(col.valueCol));
                            }
                            if (col.isDateCol!=null && col.isDateCol && !col.valueCol.contains('LastLoginDate')) {
                                if(portalGroupMembers!=null && !portalGroupMembers.isEmpty()){
                                    for(CHL_Portal_Group_Member__c portalGroupMember :portalGroupMembers) {
                                        if(String.isNotBlank(portalGroupMember.CHL_Partner_User__c)) {
                                            if(portalGroupMember.CHL_Partner_User__c == partnerUser.id && portalGroupMember.CHL_Related_Group_Member__c == null) {
                                                if ('CreatedDate'.equalsIgnoreCase(col.valueCol) && String.valueOf(portalGroupMember.get(col.valueCol)) != null)
                                                {
                                                    Datetime createdDateVal = Datetime.valueOf(portalGroupMember.get(col.valueCol));
                                                    col.value = CSM_Util.getLocaleFormattedDateValue(userLocale,createdDateVal,localeMap);
                                                    col.hiddenDate = String.valueOfGmt(createdDateVal);
                                                }
                                            }
                                        }
                                    }   
                                }
                            } else if(col.isDateCol!=null && col.isDateCol && col.valueCol.contains('LastLoginDate')) {
                                if(String.isNotBlank(col.value)) {
                                    Datetime lastLoginDateVal = Datetime.valueOf(col.value);
                                    col.value = String.valueOfGmt(lastLoginDateVal);
                                    col.hiddenDate = String.valueOfGmt(lastLoginDateVal); 
                                }
                            }
                            if ('AccountId'.equalsIgnoreCase(col.apiName))
                            {
                                    col.value = 'Individual';
                            }
                            row.columns.add(col);
                    }
                    gridRowWrapper.add(row);
                }
            }
        }*/
        System.debug('ZZZZ - gridRowWrapper - '+gridRowWrapper.size());
        return gridRowWrapper;
    }
}