public class ProfilePSAssignmentScript{

        
        
    public Map<String,String> oldToNewProfileMap;
    public Map<String,String> fieldValuesAsPerProfileMap;
    public Map<String,Set<String>> newProfileToPSMap;
    public List<Profile> oldProfilesList{get; set;}
    public List<Profile> newProfilesList{get; set;}
    public Set<id> userToUpdate{get; set;}
    public Map<String,Id> psNameToIdMap ;
    public List<User> UserList{get; set;}
    
    public void AssignProfileAndPS(){
        getOldToNewProfileMap();
        getFieldValuesAsPerProfileMap();
        getNewProfileToPSMap();
        getOldProfilesList();
        getNewProfilesList();
        getUpdatedUsersOldProfilesToNewProfile();
        removePermissionSet();
        createPSNameToIdMap();
        insertPermissionSet();
    }
    public void getOldToNewProfileMap(){
        oldToNewProfileMap = new Map<String,String>();
        oldToNewProfileMap.put('SSI Zenith Sales Rep','PRISM Sales Rep');
        oldToNewProfileMap.put('SSI Zenith Sales Manager','PRISM Sales Manager');
        oldToNewProfileMap.put('SSI Zenith Operations Manager','PRISM Operations Manager');
        oldToNewProfileMap.put('SSI Zenith Operations Rep','PRISM Operations Rep');
        oldToNewProfileMap.put('SSI Zenith Read Only','PRISM Read Only');
        oldToNewProfileMap.put('LT Self-Serve Integrator','PRISM LT Integration User');
        oldToNewProfileMap.put('SSI Zenith Admin','System Administrator');
        oldToNewProfileMap.put('SSI Zenith Integration','PRISM CRUD');
        oldToNewProfileMap.put('SSI Zenith Support','PRISM Read Only');
        oldToNewProfileMap.put('Channel Community Login','PRISM Channel Login');
        oldToNewProfileMap.put('Channel Community','PRISM Channel');
    
    }
    
    public void getFieldValuesAsPerProfileMap(){
        fieldValuesAsPerProfileMap = new Map<String,String>();
        fieldValuesAsPerProfileMap.put('SSI Zenith Sales Rep','Sales Rep');
        fieldValuesAsPerProfileMap.put('SSI Zenith Sales Manager','Sales Manager');
        fieldValuesAsPerProfileMap.put('SSI Zenith Operations Manager','Ops Manager');
        fieldValuesAsPerProfileMap.put('SSI Zenith Operations Rep','Ops Rep');
        fieldValuesAsPerProfileMap.put('SSI Zenith Read Only','Business Intelligence Analyst');
        fieldValuesAsPerProfileMap.put('LT Self-Serve Integrator','DS Integration User');
        fieldValuesAsPerProfileMap.put('SSI Zenith Admin','Admin');
        fieldValuesAsPerProfileMap.put('SSI Zenith Integration','Data Services');
        fieldValuesAsPerProfileMap.put('SSI Zenith Support','None');
        fieldValuesAsPerProfileMap.put('Channel Community Login','Channel Community User');
        fieldValuesAsPerProfileMap.put('Channel Community','Channel Community User');
        
    }
    
    public void getNewProfileToPSMap(){
        newProfileToPSMap = new Map<String,Set<String>>();
        newProfileToPSMap.put('PRISM Sales Rep',new Set <String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Sales_Rep_Restrictions'});
        newProfileToPSMap.put('PRISM Sales Manager', new Set <String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Sales_Manager','PRISM_Sales_Manager_Restrictions',
                                                    'PRISM_Servicesource_Setup_Tab','PRISM_Create_Reports_Dashboards','PRISM_Manage_List_Views','PRISM_Manage_Focus_Categories'});
        newProfileToPSMap.put('PRISM Operations Rep',new Set <String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Ops','PRISM_Ops_Rep_Restrictions' } );
        newProfileToPSMap.put('PRISM Operations Manager',new Set <String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Ops','PRISM_Ops_Manager',
                                                                        'PRISM_Ops_Manager_Restrictions','PRISM_Servicesource_Setup_Tab','PRISM_Create_Reports_Dashboards','PRISM_Manage_List_Views',
                                                                        'PRISM_Manage_Focus_Categories','PRISM_Create_Opportunity'} );
        newProfileToPSMap.put('PRISM Channel',new Set <String>{'PRISM_Channel_Community','PRISM_API_Enabled','PRISM_Base_Quote','PRISM_Base_Entitlement'} );
        newProfileToPSMap.put('PRISM Channel Login',new Set <String>{'PRISM_Channel_Community','PRISM_API_Enabled','PRISM_Base_Quote','PRISM_Base_Entitlement'} );
        newProfileToPSMap.put('PRISM Read Only',new Set <String>{'PRISM_Read_Only','PRISM_Read_Only_Extensions','PRISM_Read_Only_Quote','PRISM_Base_Entitlement','PRISM_Create_Reports_Dashboards'} );
        newProfileToPSMap.put('PRISM CRUD',new Set <String>{'PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote','PRISM_Base_Entitlement','PRISM_Data_Services','PRISM_API_Enabled','PRISM_Servicesource_Setup_Tab',
                                                            'PRISM_View_Setup','PRISM_View_All_Users','PRISM_Customize_Application','PRISM_RLI_Delete','PRISM_View_All_Data'} );
        newProfileToPSMap.put('PRISM LT Integration User',new Set <String>{'PRISM_LT_Integration','PRISM_Servicesource_Setup_Tab','PRISM_Base_Quote'} );
        newProfileToPSMap.put('System Administrator',new Set <String>{'PRISM_Servicesource_Setup_Tab','PRISM_System_Admin','PRISM_Base','PRISM_Base_Extensions','PRISM_Base_Quote',
                                                                    'PRISM_Base_Entitlement','PRISM_Manage_Focus_Categories','PRISM_Play_Maker','PRISM_Create_Opportunity','PRISM_Edit_Delete_OLI'} );
        
    }
    
    public void getOldProfilesList(){
        oldProfilesList = [select id,name , (select id,profileId,profile.Name,CHL_Persona__c from users) from Profile where Name IN('SSI Zenith Sales Rep',
                                                                                                   'SSI Zenith Sales Manager',
                                                                                                   'SSI Zenith Operations Manager',
                                                                                                   'SSI Zenith Operations Rep',
                                                                                                   'SSI Zenith Read Only',
                                                                                                   'LT Self-Serve Integrator',
                                                                                                   'SSI Zenith Admin',
                                                                                                   'SSI Zenith Integration',
                                                                                                   'SSI Zenith Support',
                                                                                                   'Channel Community Login',
                                                                                                   'Channel Community')];
                                                                           
    }
    
    public void getNewProfilesList(){
        newProfilesList = [select id,name from Profile where Name IN('PRISM Operations Manager',
                                                                                'PRISM Operations Rep',
                                                                                'PRISM Sales Manager',
                                                                                'PRISM Sales Rep',
                                                                                'PRISM Read Only',
                                                                                'PRISM LT Integration User',
                                                                                'System Administrator',
                                                                                'PRISM CRUD',
                                                                                'PRISM Channel',
                                                                                'PRISM Channel Login',
                                                                                'PRISM Read Only')];
                                                                                
    }
    
    public void getUpdatedUsersOldProfilesToNewProfile(){
        Map<String ,String> profileNameToIdMap = new  map<String ,String>();
        for(Profile newprofile : newProfilesList){
            profileNameToIdMap.put(newprofile.name,newprofile.id);
        }
        userToUpdate = new Set<id>();
        List<user> userListToUpdate = new List<user>();
        for(Profile oldprofile : oldProfilesList){
            for(user usr : oldprofile.users){
                if(oldToNewProfileMap != null && oldToNewProfileMap.containskey(usr.profile.name)){ 
                    if(profileNameToIdMap.get(oldToNewProfileMap.get(usr.profile.name)) != null){
                        usr.profileid = profileNameToIdMap.get(oldToNewProfileMap.get(usr.profile.name));
                    }
                    usr.CHL_Persona__c = fieldValuesAsPerProfileMap.get(usr.profile.name);
                    userToUpdate.add(usr.id);
                    userListToUpdate.add(usr);
                }
            }
        }
        system.debug('userListToUpdate-->'+userListToUpdate);
        if(userListToUpdate != null && !userListToUpdate.isEmpty()){
            update userListToUpdate;
        }   
    }
    
    Public void removePermissionSet(){
        UserList = [select id,ProfileId,Profile.Name, (select id,PermissionSet.name,PermissionSet.NamespacePrefix from permissionsetassignments) from user where id IN : userToUpdate AND IsActive = true]; 
        List<permissionsetassignment> removedPermisionListAssiment = new List<permissionsetassignment>();  
        for(user use : UserList){
            for(permissionsetassignment PSA : use.permissionsetassignments){
                if(PSA.PermissionSet.NamespacePrefix  == 'ServiceSource1' || PSA.PermissionSet.NamespacePrefix  == 'ServiceSourceQ' || PSA.PermissionSet.NamespacePrefix  == 'ServiceSourceEN' 
                    ||  PSA.PermissionSet.NamespacePrefix  == 'SSI_ZTH'){
                    removedPermisionListAssiment.add(PSA);
                }
            }
        }
        delete removedPermisionListAssiment;
    }
    
    public void createPSNameToIdMap(){
        Set<String> permissionSetNames = new Set<String>();
        for(String profileName : newProfileToPSMap.keySet()){
            permissionSetNames.addAll(newProfileToPSMap.get(profileName));
        }
        List<PermissionSet> PSList =[SELECT Id,Name  FROM PermissionSet where Name IN: permissionSetNames]; 
        psNameToIdMap =new Map<String,Id>();
        for(PermissionSet ps: PSlist){
             psNameToIdMap.put(ps.Name,ps.id);
        }
    }
    
    public void insertPermissionSet(){
        List<User> AfterDeletePSAUserList = [select id,ProfileId,Profile.Name, (select id,PermissionSetId from permissionsetassignments) from user where id IN : userToUpdate AND IsActive = true]; 
        Map<id,Set<id>> userToPSMap = new Map<id,Set<id>>();
        for(user use : AfterDeletePSAUserList){
            Set<id> PSidSet = new Set<id>();
            for(permissionsetassignment PSA : use.permissionsetassignments){
                PSidSet.add(PSA.PermissionSetId);
            }
            userToPSMap.put(use.id,PSidSet);
        }
        List<PermissionSetAssignment> newPSA = new List<PermissionSetAssignment>(); 
        for(user usr : UserList){
            Set<id> PSRelatedToUser = userToPSMap.get(usr.id);
            if(newProfileToPSMap.containskey(usr.profile.Name)){ 
                 for(String PS : newProfileToPSMap.get(usr.profile.Name)){              
                    if(psNameToIdMap.get(PS) != null && !PSRelatedToUser.contains(psNameToIdMap.get(PS))){
                        PermissionSetAssignment newPSARecord = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psNameToIdMap.get(PS));
                        newPSA.add(newPSARecord);
                    }
                }
            }
        }
        upsert newPSA;
    }
}