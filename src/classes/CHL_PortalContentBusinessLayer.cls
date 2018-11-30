public with sharing class CHL_PortalContentBusinessLayer {
	
	public static List<CHL_PortalContentWrapper> getPortalContents(String inputvalue) {
    	List<CHL_Portal_Content__c> portalContentList = CHL_PortalContentDataAccess.portalContentsList;
        List<CHL_PortalContentWrapper> portalWrapperList = new List<CHL_PortalContentWrapper>();
        List<CHL_PortalContentWrapper.CHL_Category> portalCategoryWrapperList; // = new List<CHL_PortalContentWrapper.CHL_Category>();
        Map<String,List<CHL_PortalContentWrapper.CHL_Category>> categoryWrpMap  = new Map<String,List<CHL_PortalContentWrapper.CHL_Category>>();
        String urlValue = '', contentType = '', description = '';
        Set<Id> contentIds = new Set<Id>();
        sObject attchmentObj;
        for(CHL_Portal_Content__c portalCont: portalContentList)    {
        	if(!String.isBlank((portalCont.CHL_Type__c)) && (portalCont.CHL_Type__c).equalsIgnoreCase('Attachment')) {
            	contentIds.add(portalCont.Id);
        	}
        }
        Map<String,sObject> attachmentsMap = CHL_AttachmentDataAccess.getAttachmentMapByParentId(contentIds);
        system.debug('attachmentsMap : '+attachmentsMap);
        for(CHL_Portal_Content__c pc: portalContentList)    {
            CHL_PortalContentWrapper wrp = new CHL_PortalContentWrapper();
            urlValue = '';
            contentType = '';
            if(!String.isBlank((pc.CHL_Type__c)) && (pc.CHL_Type__c).equalsIgnoreCase('Attachment')) {
                contentType = Label.CHL_LBL_FILE; //'FILE';
                if(attachmentsMap.containskey(String.valueof(pc.Id))) {
                    attchmentObj = attachmentsMap.get(String.valueof(pc.Id));
                    urlValue = attchmentObj != null ? Site.getPathPrefix()+'/servlet/servlet.FileDownload?file=' + String.valueOf(attchmentObj.get('id')) : ''; 
                }
                system.debug('####attchmentObj '+attchmentObj + ':: '+String.valueof(pc.Id));
             } else {
                contentType = Label.CHL_LBL_URL; //'URL';
                urlValue = pc.CHL_Weblink_URL__c; 
                if(!String.isBlank(urlValue) && urlValue != null) {
                	urlValue = urlValue.startsWithIgnoreCase('http') ? urlValue : 'http://'+urlValue;
                }
            }
            description = !String.isblank(pc.CHL_Description__c) ? pc.CHL_Description__c : '';
            if(!String.isBlank(pc.CHL_Category__c)) {
                CHL_PortalContentWrapper.CHL_Category categoryWrp = new CHL_PortalContentWrapper.CHL_Category();
                portalCategoryWrapperList = categoryWrpMap.get(pc.CHL_Category__c);
                if(portalCategoryWrapperList == null || portalCategoryWrapperList.isEmpty()) {
                	portalCategoryWrapperList = new List<CHL_PortalContentWrapper.CHL_Category>(); 
                }
                categoryWrp.label = pc.name;
                categoryWrp.url = !String.isBlank(urlValue) ? urlValue : ''; 
                categoryWrp.description = description;
                categoryWrp.type = contentType;
                portalCategoryWrapperList.add(categoryWrp);
                categoryWrpMap.put(pc.CHL_Category__c,portalCategoryWrapperList);
            } else {
                wrp.label = pc.name;
                wrp.url = !String.isBlank(urlValue) ? urlValue : ''; 
                wrp.description = description;//pc.CHL_Description__c;
                wrp.type = contentType;//pc.CHL_Type__c;
                portalWrapperList.add(wrp);
            }
        }
        Schema.DescribeFieldResult fieldResult = CHL_Portal_Content__c.CHL_Category__c.getDescribe();
		
        if(categoryWrpMap != null) {
            for(Schema.PicklistEntry plVal : fieldResult.getPicklistValues()) { // updated for Loop: DE1696, to maintain order of Category picklist values.
            	if(categoryWrpMap.containsKey(plVal.getValue())) {
            		 CHL_PortalContentWrapper wrpCategory = new CHL_PortalContentWrapper();
	                 wrpCategory.type = Label.CHL_LBL_CATEGORY; //'CATEGORY';
	                 wrpCategory.children = categoryWrpMap.get(plVal.getValue());
	                 wrpCategory.label = plVal.getLabel();
               		 portalWrapperList.add(wrpCategory);
            	}
            }
        }
        system.debug('categoryWrpMap :: '+categoryWrpMap);
        system.debug('portalWrapperList : '+portalWrapperList+'\n ~~'+JSON.serialize(portalWrapperList));
        return portalWrapperList;
	}
}