/**
 * Created Date     : Sep 2, 2016
 * Developed By     : Tanvi, Comity Designs, Inc.
 *
 * Function         : This is helper class which contains logic to create Portal groups on load of portal group migration data. This class is part of unmanged package.
 * Support Email    : tanvi@comitydesigns.com
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Tanvi                    US1541              Sep 2, 2016         1.1                 @description
 *
 */
public with sharing class CHL_PortalGroupMigrationTriggerHelper {

    
    /**
     * @description : this method gets call from trigger handler, which contains logic to create portal group based on load file of portal group migration.
     * @param : newRecordsMap from trigger
     * 
     */
    public static void handlePortalGroupCreation(Map<Id, CHL_PortalGroup_Migration_Data__c>newRecordsMap){
        List<CHL_Portal_Group__c> portalGrpList = new List<CHL_Portal_Group__c>();
        Map<String,Set<String>> companyNUserEmailsMap = new Map<String,Set<String>>();
        Set<String> userEmailSet = new Set<String>();
        Set<String> accountNameSet = new Set<String>();
        Map<String,Set<String>> companyNAccountMap = new Map<String,Set<String>>();
        Set<String> portalGroupNameSet = new Set<String>();
        for(CHL_PortalGroup_Migration_Data__c pgData: newRecordsMap.values()) {
            if(String.isNotBlank(pgData.CHL_Company__c)) {
                if(String.isNotBlank(pgData.CHL_User_Email__c)) {
                    Set<String> userEmails = companyNUserEmailsMap.get(pgData.CHL_Company__c);                          
                    if(userEmails == null){
                        userEmails = new Set<String>();
                    }
                    userEmails.add(pgData.CHL_User_Email__c);                           
                    companyNUserEmailsMap.put(pgData.CHL_Company__c,userEmails);    
                    portalGroupNameSet.add(pgData.CHL_Company__c);
                    userEmailSet.add(pgData.CHL_User_Email__c);
                } //else 
                if(String.isNotBlank(pgData.CHL_Account_Name__c)) {
                    Set<String> accountNames = companyNAccountMap.get(pgData.CHL_Company__c);                           
                    if(accountNames == null){
                        accountNames = new Set<String>();
                    }
                    accountNames.add(pgData.CHL_Account_Name__c);                           
                    companyNAccountMap.put(pgData.CHL_Company__c,accountNames);
                    portalGroupNameSet.add(pgData.CHL_Company__c);
                    accountNameSet.add(pgData.CHL_Account_Name__c);
                }
            }
        }
        for(String strAccount:portalGroupNameSet) {
            CHL_Portal_Group__c pgAccObj = new CHL_Portal_Group__c();
            pgAccObj.name = strAccount;
            portalGrpList.add(pgAccObj);
        }
        //List<CHL_Portal_Group__c> portalGroupList = CHL_PortalGroupDataAccess.savePortalGroup(portalGrpList);
        List<Database.SaveResult> portalGroupResultList  = Database.insert(portalGrpList, false);
        //upsert portalGrpList;
        Set<Id> insertedRecordIds = new Set<Id>();
        for (Database.SaveResult sr : portalGroupResultList) {
            if (sr.isSuccess()) {
                insertedRecordIds.add(sr.getId());
            }
        }
        portalGrpList = [select Id,name,CHL_Public_Group__c from CHL_Portal_Group__c where Name in :portalGroupNameSet limit 10000];
        system.debug('userEmails : '+'::'+userEmailSet+'::'+accountNameSet);
        List<User> userList = getUsersByEmail(userEmailSet);
        List<User> userAccList = getUsersByAccountName(accountNameSet);
        userList.addall(userAccList);       
        system.debug('userList : '+userList+'\n :: MAPS : '+companyNUserEmailsMap+'::'+companyNAccountMap);
        CreateGroupMembers(userList,portalGrpList,companyNUserEmailsMap,companyNAccountMap);
        
        
    }
    
    /**
     * @description : Below method gets call from handlePortalGroupCreation, which contains logic to create portal group members for the portal group created.
     * @param : list of users, Portal group list and Maps
     * 
     */
    private static void CreateGroupMembers(List<User> userList, List<CHL_Portal_Group__c> portalGroupList,Map<String,Set<String>> companyNUserEmailsMap,Map<String,Set<String>> companyNAccountMap) {
        List<CHL_Portal_Group_Member__c> portalGrpMemberList = new List<CHL_Portal_Group_Member__c>();
        List<CHL_Portal_Group_Member__c> pgmAccountList = new List<CHL_Portal_Group_Member__c>();
        CHL_Portal_Group_Member__c pgmObj;
        //Map<String,List<CHL_Portal_Group_Member__c>> portalGroupNMembersMap = new Map<String,List<CHL_Portal_Group_Member__c>>();
        Map<String,Set<Id>> userEmailMap = new Map<String,Set<Id>>();
        Map<String,Set<Id>> userAccountMap = new Map<String,Set<Id>>();
        Map<String,Set<Id>> publicGroupNameMap = new Map<String,Set<Id>>();
        Map<String,String> portalGrpNPublicGrpMap = new Map<String,String>();
        List<String> publicgroupNames = new List<String>();
        Set<Id> pgUserIds = new Set<Id>();
        for(User usr:userList) {
            Set<Id> userIds = userEmailMap.get(usr.Email);                          
            if(userIds == null){
                userIds = new Set<Id>();
            }
            userIds.add(usr.Id);                            
            userEmailMap.put(usr.Email,userIds);
            Set<Id> userAccIds = userAccountMap.get(usr.Account.Name);                          
            if(userAccIds == null){
                userAccIds = new Set<Id>();
            }
            userAccIds.add(usr.Id);                         
            userAccountMap.put(usr.Account.Name,userAccIds);
        }
        for(CHL_Portal_Group__c pg:portalGroupList) {           
            if(string.isNotBlank(pg.CHL_Public_Group__c)) {
                portalGrpNPublicGrpMap.put(pg.name,pg.CHL_Public_Group__c);
            }
            if(companyNUserEmailsMap.containskey(pg.name)) {
                system.debug('IN D IF : '+(companyNUserEmailsMap.get(pg.name))+' \n : '+pg.name);
                //Set<String> userEmailIds = companyNUserEmailsMap.get(pg.name);
                for(String strEmail : companyNUserEmailsMap.get(pg.name)) {
                    if(userEmailMap != null && userEmailMap.containsKey(strEmail)) {
                        for(Id usrId: userEmailMap.get(strEmail)) {
                            pgmObj = new CHL_Portal_Group_Member__c();
                            pgmObj.CHL_Portal_Group__c = pg.Id;
                            pgmObj.CHL_Partner_User__c = usrId;
                            //pgmObj.CHL_Partner_Account__c = usr.AccountId;
                            portalGrpMemberList.add(pgmObj);
                            pgUserIds = publicGroupNameMap.get(pg.name);                            
                            if(pgUserIds == null){
                                pgUserIds = new Set<Id>();
                            }
                            pgUserIds.add(usrId);                           
                            publicGroupNameMap.put(pg.Name,pgUserIds);
                        }
                    }
                }
                
            } //else 
            if(companyNAccountMap.containskey(pg.name)) {                   
                system.debug('IN D IF companyNAccountMap: '+(companyNAccountMap.get(pg.name))+' \n : '+pg.name);
                for(String strAccName : companyNAccountMap.get(pg.name)) {
                    if(userAccountMap != null && userAccountMap.containsKey(strAccName)) {
                        for(Id usrAccId: userAccountMap.get(strAccName)) {
                            pgmObj = new CHL_Portal_Group_Member__c();
                            pgmObj.CHL_Portal_Group__c = pg.Id;
                            pgmObj.CHL_Partner_User__c = usrAccId;
                            //pgmObj.CHL_Partner_Account__c = usrAcc.AccountId;
                            pgmAccountList.add(pgmObj);
                            pgUserIds = publicGroupNameMap.get(pg.name);                            
                            if(pgUserIds == null){
                                pgUserIds = new Set<Id>();
                            }
                            pgUserIds.add(usrAccId);                            
                            publicGroupNameMap.put(pg.name,pgUserIds);
                        }
                    }
                }
            }
            //publicgroupNames.add(pg.name);
        }
        
        portalGrpMemberList.addAll(pgmAccountList);
        system.debug('portalGrpMemberList AFTER :: '+portalGrpMemberList+'\n '+JSON.serialize(portalGrpMemberList));
        system.debug('pgmAccountList AFTER :: '+pgmAccountList+'\n '+JSON.serialize(pgmAccountList));
        system.debug('portalGrpMemberList : '+portalGrpMemberList+' :: \n publicGroupNameMap '+publicGroupNameMap);
        
        //CHL_PortalGroupDataAccess.savePortalGroupMembers(portalGrpMemberList); //This method is outside of package.
        upsert portalGrpMemberList;
        publicgroupNames.addAll(publicGroupNameMap.keySet());
        
        List<Group> publicGroupList = [select id,name from Group where name in :publicGroupNameMap.keySet() limit 10000];
        if(publicGroupList == null) {
            publicGroupList = new List<Group>();
        } else if(publicGroupList.size() != publicgroupNames.size()) {    
            for(String grpName : publicgroupNames){     
                if(portalGrpNPublicGrpMap != null && !portalGrpNPublicGrpMap.containskey(grpName)){
                    Group groupObj = new Group();
                    groupObj.Name = grpName;
                    publicGroupList.add(groupObj);                      
                }               
            }
        }
        
        //List<Database.SaveResult> publicGroupResultList = new List<Database.SaveResult>();
        if(publicGroupList != null){
            upsert publicGroupList;
            //publicGroupResultList  = Database.insert(publicGroupList, false);
        }
        /*for (Database.SaveResult sr : publicGroupResultList) {
            if (sr.isSuccess()) {
                insertedRecordIds.add(sr.getId());
            }
        }*/
        Map<Id,Set<Id>> publicGroupMap = new Map<Id,Set<Id>>();
        Set<Id> insertedRecordIds = new Set<Id>();
        List<CHL_Portal_Group__c> portalGrpListToUpdate = new List<CHL_Portal_Group__c>();
        Map<String,Id> publicGroupNameIdMap = new Map<String,Id>();
        for(Group pg:publicGroupList) { 
            if(String.isNotBlank(pg.name) && publicGroupNameMap.containskey(pg.name)) {
                publicGroupMap.put(pg.id,publicGroupNameMap.get(pg.name));
                publicGroupNameIdMap.put(pg.name,pg.id);
            }
        }
        for(CHL_Portal_Group__c poralgrpObj : portalGroupList) {
            if(String.isNotBlank(poralgrpObj.name) && publicGroupNameIdMap.containsKey(poralgrpObj.name)) {
                poralgrpObj.CHL_Public_Group__c = publicGroupNameIdMap.get(poralgrpObj.name);
                portalGrpListToUpdate.add(poralgrpObj);
            }
        }
        if(portalGrpListToUpdate != null && !portalGrpListToUpdate.isEmpty()) {
            update portalGrpListToUpdate;
        }
        CreatePublicGroupMembers(JSON.serialize(publicGroupMap)); //  
        //return portalGrpMemberList;
    }
     /**
     * @description:  Below method contains logic to create public group members, this is future method due to Mixed DML issue.
     * @param publicGroupMapSerialized : This parameter is serialized of map. Future method parameters are limited to primitives and collections of primitives. Map with collections not supported.
     * 
     */
    @future
    public static void CreatePublicGroupMembers(String publicGroupMapSerialized) {
        try {
            Map<Id,Set<Id>> publicGroupMap = (Map<Id, Set<Id>>)JSON.deserialize(publicGroupMapSerialized, Map<Id, Set<Id>>.class);
            system.debug('IN D CreatePublicGroupMembers '+publicGroupMapSerialized+'::'+publicGroupMap);
            List<GroupMember> groupMemberList = new List<GroupMember>();
            //List<Group> publicGroupList = CHL_PublicGroupDataAccess.FindPublicGroups(publicGroupMap.keyset());
            List<Group> publicGroupList = [select id,name from Group where  Id in :publicGroupMap.keyset() limit 1000];
            for(Group pg:publicGroupList) {         
                if(publicGroupMap.containskey(pg.id)) {
                    for(Id userId:publicGroupMap.get(pg.id)) {
                        GroupMember newGroupMember=new GroupMember();
                        newGroupMember.GroupId = pg.Id;
                        newGroupMember.UserOrGroupId =  userId;
                        groupMemberList.add(newGroupMember);
                    }
                    
                }
            }
            //CHL_PublicGroupDataAccess.SaveGroupMember(groupMemberList);
            upsert groupMemberList;
            system.debug('groupMemberList : '+groupMemberList);
        }catch(Exception e){
            Set<Id> userIdSet = new Set<Id>{userInfo.getUserId()};
            REN_Util.sendEmailNotification(userIdSet, System.label.CHL_LBL_PUBLIC_GROUP_CREATION_FAILED_MAIL_SUBJECT, System.label.CHL_LBL_PUBLIC_GROUP_CREATION_FAILED_MAIL_TEXT+e.getMessage());
        }
        //return portalGrpMemberList;
    }
    
      /*
    @Description: Below method return list of users by email ids, it will use for US1541
    */
    public static List<User> getUsersByEmail(set<String> emailIdSet) {
        return [select id,name,ContactId,AccountId,Email,Account.Name from User where Email IN :emailIdSet and isActive = true AND User.Profile.UserLicense.Name LIKE 'Partner Community%' 
                AND User.Profile.Name LIKE 'Channel Community%' AND UserType = :CHL_CONSTANTS.PARTNER_USER limit 1000];
    }
    
    /*
    @Description: Below method return list of users for corresponding account names, it will use for US1541
    */
    public static List<User> getUsersByAccountName(set<String> accountNameSet) {
        return [select id,name,ContactId,AccountId,Email,Account.Name from User where Account.Name IN :accountNameSet and isActive = true AND User.Profile.UserLicense.Name LIKE 'Partner Community%' 
                AND User.Profile.Name LIKE 'Channel Community%' AND UserType = :CHL_CONSTANTS.PARTNER_USER limit 1000];
    }
    
    
}