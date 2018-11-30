/**
 * Created Date		: Feb 16, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * abirjepatil					User Story				Feb 16, 2017			1.1					@description
 * 
 */
public with sharing class CSM_FocusCategoryRestrctVisibiltyCmpCtrl  extends REN_BaseChildController {
	
	public List<SelectOption> lstVisibility {get;set;}
	public List<SelectOption> lstGroups {get;set;}
	public List<SelectOption> lstLeftGroups {get;set;}	
	public List<SelectOption> lstRightGroups {get;set;}	
	public List<SelectOption> optionsPublicGroups {get;set;}	
	public List<SelectOption> optionsRoles {get;set;}	
	//public List<SelectOption> optionsRolesSubords {get;set;}
	public List<SelectOption> optionsUsers {get;set;}		
	public Map<String, String> lstPublictGroups {get;set;}	
	public Map<String, String> lstRoles {get;set;}	
	//public Map<String, String> lstRoleAndSubordinates {get;set;}	
	public Map<String, String> lstUsers {get;set;}	
	public String selectedValue {get;set;}	
	public Id fcViewId {get;set;}	
	public String selectedGroup {get;set;}	
	public String prefix {get;set;}	
	public boolean isNetOpsUser {get;set;}	
	public CSM_MultiSelectLeftRightListWrapper multiSelectWrp {get; set;}
    Map<String,Map<String,String>> userTypeToGroupIdnNameMap;
    Map<String,Map<String,String>> userTypeToUserIdnNameMap;

	public REN_BaseMainController baseController  {get; set{
			baseController = value;
			this.objectNameSuper = 'CSM_Focus_Category_View_Visibility__c';	    			
			this.baseMainController = value;	    			
			
			multiSelectWrp = new  CSM_MultiSelectLeftRightListWrapper(Label.CSM_AVAILABLE_SHARE,Label.CSM_SHARE_TO, this.lstLeftGroups, this.lstRightGroups, baseController, prefix, optionsPublicGroups, optionsRoles, null, optionsUsers, null);
		}
	}	
	
    public CSM_FocusCategoryRestrctVisibiltyCmpCtrl() {
    	super();
    	
    	prefix = 'rv';
    	String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
    	Boolean isSolExtSalesManager = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_SalesManager);
    	Boolean isSolExtOpsManager = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_OperationServicesEditUser);
    	isNetOpsUser = (SS_LicenseCheck.getInstance().isCSMEnabled || SS_LicenseCheck.getInstance().isRenewEnabled || isSolExtSalesManager || isSolExtOpsManager);
		this.fcViewId = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_IG_ID);
		this.selectedGroup = '';

		lstVisibility = new List<SelectOption>();
		lstGroups = new List<SelectOption>();
		
		setInitialData();
		
		Set<String> selectedGroups;	
		String selectedVisibility;
		CSM_ShareWrapper shareWrap;					
		if(!String.isEmpty(fcViewId)){
			shareWrap = CSM_Util.getShareInformation(CSM_Constants.OBJ_FCV, fcViewId);
			selectedVisibility = shareWrap.visibility;		
			selectedGroups = shareWrap.shareIds;
		}
		
		if(selectedGroups == null){
			selectedGroups = new Set<String>();
		}	

		this.lstRightGroups = new List<SelectOption>();	
		UserSelectedOptionWrapper userSelOptObj = new UserSelectedOptionWrapper();
        userSelOptObj.lstOptions = this.lstRightGroups;
        userSelOptObj.lstGroups = lstPublictGroups;
        userSelOptObj.selectedGroups = selectedGroups;
        userSelOptObj.refresh = false;
        userSelOptObj.groupPrefix = Label.REN_LBL_PUBLIC_GROUP_CATEGORY + ':';
        
		assignSelectedOptions(userSelOptObj);
        
        if(userTypeToGroupIdnNameMap != null && !userTypeToGroupIdnNameMap.isEmpty()){
            if(userTypeToGroupIdnNameMap.containsKey('Internal')){
                userSelOptObj.lstGroups = userTypeToGroupIdnNameMap.get('Internal');
                userSelOptObj.groupPrefix = Label.REN_LBL_ROLE_CATEGORY + ':';
                assignSelectedOptions(userSelOptObj);	
            }
            if(userTypeToGroupIdnNameMap.containsKey('Partner')){
                userSelOptObj.lstGroups = userTypeToGroupIdnNameMap.get('Partner');
                userSelOptObj.groupPrefix = Label.REN_LBL_PORTAL_ROLE_CATEGORY + ':';
                assignSelectedOptions(userSelOptObj);	
            }
        }
        
		if(userTypeToUserIdnNameMap != null && !userTypeToUserIdnNameMap.isEmpty()){
            if(userTypeToUserIdnNameMap.containsKey('Internal')){
                userSelOptObj.lstGroups = userTypeToUserIdnNameMap.get('Internal');
                userSelOptObj.groupPrefix = Label.CHL_GA_USER_CATEGORY + ':';
                assignSelectedOptions(userSelOptObj);
            }
            if(userTypeToUserIdnNameMap.containsKey('Partner')){
                userSelOptObj.lstGroups = userTypeToUserIdnNameMap.get('Partner');
                userSelOptObj.groupPrefix = Label.REN_LBL_PARTNER_USERS + ':';
                assignSelectedOptions(userSelOptObj);
            }
        }
		
		lstVisibility.add(new SelectOption(CSM_Constants.STR_VISI_ONLY_ME,Label.CSM_VISIBLE_ME));
		if(isNetOpsUser){
			lstVisibility.add(new SelectOption(CSM_Constants.STR_VISI_ALL_USERS,Label.CSM_VISIBLE_ALL));		
		}else{
			lstVisibility.add(new SelectOption(CSM_Constants.STR_VISI_ALL_USERS,'',true));		
		}
		lstVisibility.add(new SelectOption(CSM_Constants.STR_VISI_CERTAIN_GRP_USERS,Label.CSM_VISIBLE_SPECIFIC));
		
		if(!String.isEmpty(selectedVisibility)){
				selectedValue = selectedVisibility;	
		}else{
			 	selectedValue = CSM_Constants.STR_VISI_ONLY_ME;
		}
		/*US2730: Removing Role and Subordinates value from the select list. */
		lstGroups.add(new SelectOption(CSM_Constants.STR_PUBLIC_GROUP,CSM_Constants.STR_PUBLIC_GROUP));
		lstGroups.add(new SelectOption(CSM_Constants.STR_ROLES,CSM_Constants.STR_ROLES));		
		//lstGroups.add(new SelectOption(CSM_Constants.STR_ROLES_WITH_SUBORD,CSM_Constants.STR_ROLES_WITH_SUBORD));
		lstGroups.add(new SelectOption(CSM_Constants.STR_USERS,CSM_Constants.STR_USERS));		

		selectedGroup = CSM_Constants.STR_PUBLIC_GROUP;
	}
	
	/*public PageReference refreshGroupValues(){
		strSearch = '';
		CSM_ShareWrapper shareWrap = CSM_Util.getShareInformation(CSM_Constants.OBJ_FCV, fcViewId);
		String selectedVisibility = shareWrap.visibility;		
		
		Set<String> selectedGroups = shareWrap.shareIds;
		
		if(selectedGroups == null){
			selectedGroups = new Set<String>();
		}	

		this.lstLeftGroups = new List<SelectOption>();
		assignOptions(this.lstLeftGroups, lstPublictGroups);
		assignOptions(this.lstLeftGroups, lstRoles);
		assignOptions(this.lstLeftGroups, lstUsers);		

        multiSelectWrp = new  CSM_MultiSelectLeftRightListWrapper(Label.CSM_AVAILABLE_SHARE,Label.CSM_SHARE_TO, this.lstLeftGroups, this.lstRightGroups, baseController,prefix, optionsPublicGroups, optionsRoles, optionsRolesSubords, optionsUsers, null);		
		return null;
	}*/
	
	public void performSave(String fcviewId){
		CSM_MultiSelectLeftRightPicklistCmpCtrl picklistCtrl = referPicklistCtrl();
		
		List<CSM_Focus_Category_View__Share> fcvShareList = CSM_FocusCategoryViewDataAccess.retrieveFocusCategoryViewShare(fcviewId);
		List<CSM_Focus_Category_View__Share> newfcvShareList = new List<CSM_Focus_Category_View__Share>();		

        if(selectedValue == CSM_Constants.STR_VISI_CERTAIN_GRP_USERS){
        	system.debug('bbbbbbbbbbbbbb - ' + picklistCtrl.rightOptionsHidden);
				if(!String.isBlank(picklistCtrl.rightOptionsHidden)){
			        String[] parts = picklistCtrl.rightOptionsHidden.split('&');
			        for (Integer i=0; i<parts.size()/2; i++) {
						populateShare(fcvShareList,newfcvShareList, null,parts,i );
			        }
			        
					CSM_FocusCategoryViewDataAccess.deleteFocusCategoryViewShare(newfcvShareList);
					//deleteShare(fcviewId);
			        insertShare(newfcvShareList);
		        }
        }else if(selectedValue == CSM_Constants.STR_VISI_ALL_USERS){
			//deleteShare(fcviewId);
			
	    	Set<String> developerNames = new Set<String>();
	    	//developerNames.add(CSM_Constants.STR_ALL_PRTR_USERS);
	    	developerNames.add(CSM_Constants.STR_ALL_INTERNAL_USERS);
	    	//developerNames.add(CSM_Constants.STR_ALL_CUST_PORT_USERS);

    		List<Group> groupList = CSM_FocusCategoryViewDataAccess.retrieveIdsForGroups(developerNames);
    		
    		for(Group grp:groupList){
				populateShare(fcvShareList,newfcvShareList, grp, null,null);	        	
    		}
			CSM_FocusCategoryViewDataAccess.deleteFocusCategoryViewShare(newfcvShareList);
	        insertShare(newfcvShareList);
        }else if(selectedValue == CSM_Constants.STR_VISI_ONLY_ME){
	    	List<CSM_Focus_Category_View__Share> lstfcvShare = new List<CSM_Focus_Category_View__Share>();
	    	CSM_Focus_Category_View__Share fcvShare = new CSM_Focus_Category_View__Share();	    	
	    	fcvShare.parentId = fcviewId;
	    	
	    	lstfcvShare.add(fcvShare);
        	
			CSM_FocusCategoryViewDataAccess.deleteFocusCategoryViewShare(lstfcvShare);			
			//deleteShare(fcviewId);
        }
	}
	
	private CSM_MultiSelectLeftRightPicklistCmpCtrl referPicklistCtrl(){
		Map<String, REN_BaseChildController> baseChildControllerMap = baseController.getBaseChildControllerMap();

		REN_BaseChildController baseChildController = baseChildControllerMap.get(prefix + 'CSM_Focus_Category_View__c');
		if(baseChildController instanceof CSM_MultiSelectLeftRightPicklistCmpCtrl){
			return (CSM_MultiSelectLeftRightPicklistCmpCtrl)baseChildController;
		}

		return null;
	}
	
	private void assignSelectedOptions(UserSelectedOptionWrapper selectionWrapObj){
		for(String str: selectionWrapObj.lstGroups.keySet()){
			if(selectionWrapObj.selectedGroups.contains(str)){
				if(!String.isEmpty(selectionWrapObj.lstGroups.get(str))){
					selectionWrapObj.lstOptions.add(new SelectOption(str,selectionWrapObj.groupPrefix + selectionWrapObj.lstGroups.get(str)));					
				}
			}
		}
	}

	private void assignOptions(List<SelectOption> lstOptions, Map<String, String> lstGroups, String groupPrefix){
		for(String str: lstGroups.keySet()){
			if(!String.isEmpty(lstGroups.get(str))){
				lstOptions.add(new SelectOption(str,groupPrefix + lstGroups.get(str)));	
			}
		}
	}
	
	private void deleteShare(String fcviewId){
        List<CSM_Focus_Category_View__Share> fcvShareListDelete = CSM_FocusCategoryViewDataAccess.retrieveFocusCategoryViewShare(fcviewId);
        if(fcvShareListDelete != null && !fcvShareListDelete.isEmpty()){
        	CSM_FocusCategoryViewDataAccess.deleteFocusCategoryViewShare(fcvShareListDelete);
        }
	}
	
	private void insertShare(List<CSM_Focus_Category_View__Share> fcvShareList){
        if(fcvShareList != null && !fcvShareList.isEmpty()){
        	CSM_FocusCategoryViewDataAccess.insertFocusCategoryViewShare(fcvShareList);
        }
	}

	private void populateShare(List<CSM_Focus_Category_View__Share> fcvShareList, List<CSM_Focus_Category_View__Share> newfcvShareList, Group grp,String[] parts, integer i){
    	CSM_Focus_Category_View__Share fcvShare = new CSM_Focus_Category_View__Share();
    	fcvShare.parentId = fcviewId;
    	if(grp != null){
    		fcvShare.userOrGroupId = grp.Id;    	
    	} else if(parts != null){
			fcvShare.userOrGroupId = parts[i*2];    	
    	}
    	if(fcvShareList != null && !fcvShareList.isEmpty()){
	    	for(CSM_Focus_Category_View__Share alreadyShared: fcvShareList){
	    		if(fcvShare.userOrGroupId == alreadyShared.userOrGroupId){
	    			fcvShare.Id = alreadyShared.Id;
	    			break;
	    		}
	    	}
    	}

    	fcvShare.accessLevel = 'Read';
    	newfcvShareList.add(fcvShare);
	}

	/** 
	* @description: Finds all the internal users.
	* @returns the list of user Ids.
	*/
	private List<User> getAllInternalUsers(){
		List<User> allUsers = [Select id,name,username,UserType from User where Profile.UserLicense.Name !='Chatter Free' AND Profile.UserLicense.Name !='Chatter External' AND Profile.UserLicense.Name !='Chatter Only' AND Profile.Name != 'PRISM Channel Login' AND Profile.Name != 'PRISM Channel'  AND isActive = true and UserType != 'Guest' and Profile.Name != 'Customer Portal Manager' and id !=: UserInfo.getUserId()]; //where User.Profile.UserLicense.Name != 'Partner Community' AND User.Profile.Name != 'Channel Community' AND UserType != 'PowerPartner' and isActive = true and id !=: UserInfo.getUserId()];
		return allUsers;
	}
    
    private void setInitialData(){
		lstPublictGroups = CSM_Util.getAllPublicGroups();
		lstUsers = new Map<String,String>();
		userTypeToUserIdnNameMap = new Map<String,Map<String,String>>();
        
		this.lstLeftGroups = new List<SelectOption>();
        
        for(User userObj : getAllInternalUsers()){
            String userName = (String.isEmpty(userObj.Name) ? userObj.username : userObj.Name);
            if(userObj.UserType == 'PowerPartner'){
                if(userTypeToUserIdnNameMap.containsKey('Partner')){
                    userTypeToUserIdnNameMap.get('Partner').put(userObj.Id,userName);
                }else{
                    userTypeToUserIdnNameMap.put('Partner', new Map<String,String>{userObj.Id=>userName});
                }
            }else{
                if(userTypeToUserIdnNameMap.containsKey('Internal')){
                    userTypeToUserIdnNameMap.get('Internal').put(userObj.Id,userName);
                }else{
                    userTypeToUserIdnNameMap.put('Internal', new Map<String,String>{userObj.Id=>userName});
                }
            }
            lstUsers.put(userObj.Id,userName);
        }		
		
		this.optionsPublicGroups = new List<SelectOption>();
		assignOptions(this.optionsPublicGroups, lstPublictGroups,Label.REN_LBL_PUBLIC_GROUP_CATEGORY + ':');		

        userTypeToGroupIdnNameMap = CSM_Util.getAllRoles();
        this.optionsRoles = new List<SelectOption>();
        lstRoles = new Map<String,String>();
        
        if(userTypeToGroupIdnNameMap != null && !userTypeToGroupIdnNameMap.isEmpty()){
            if(userTypeToGroupIdnNameMap.containsKey('Internal')){
                assignOptions(this.optionsRoles, userTypeToGroupIdnNameMap.get('Internal'), Label.REN_LBL_ROLE_CATEGORY + ':');
                lstRoles.putAll(userTypeToGroupIdnNameMap.get('Internal'));
                assignOptions(this.lstLeftGroups, userTypeToGroupIdnNameMap.get('Internal'), Label.REN_LBL_ROLE_CATEGORY + ':');
            }
            if(userTypeToGroupIdnNameMap.containsKey('Partner')){
                assignOptions(this.optionsRoles, userTypeToGroupIdnNameMap.get('Partner'), Label.REN_LBL_PORTAL_ROLE_CATEGORY + ':');
                lstRoles.putAll(userTypeToGroupIdnNameMap.get('Partner'));
                assignOptions(this.lstLeftGroups, userTypeToGroupIdnNameMap.get('Partner'), Label.REN_LBL_PORTAL_ROLE_CATEGORY + ':');
            }
        }
        
		this.optionsUsers = new List<SelectOption>();
		
        if(userTypeToUserIdnNameMap != null && !userTypeToUserIdnNameMap.isEmpty()){
            if(userTypeToUserIdnNameMap.containsKey('Internal')){
                assignOptions(this.optionsUsers, userTypeToUserIdnNameMap.get('Internal'), Label.CHL_GA_USER_CATEGORY + ':');
                assignOptions(this.lstLeftGroups, userTypeToUserIdnNameMap.get('Internal'),Label.CHL_GA_USER_CATEGORY + ':');
            }
            if(userTypeToUserIdnNameMap.containsKey('Partner')){
                assignOptions(this.optionsUsers, userTypeToUserIdnNameMap.get('Partner'), Label.REN_LBL_PARTNER_USERS + ':');
                assignOptions(this.lstLeftGroups, userTypeToUserIdnNameMap.get('Partner'),Label.REN_LBL_PARTNER_USERS + ':');
            }
        }
        
		assignOptions(this.lstLeftGroups, lstPublictGroups, Label.REN_LBL_PUBLIC_GROUP_CATEGORY + ':');		
	}
	
	public class UserSelectedOptionWrapper{
        List<SelectOption> lstOptions;
        Map<String, String> lstGroups;
        Set<String> selectedGroups;
        Boolean refresh;
        String groupPrefix;
    }
}