/**
 * Created Date		: Jun 29, 2018
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This class creates default records of RS Cofigration and RS Lookup Field mapping.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US3471				   Jun 29, 2018	    1.1					This class creates default records of RS Cofigration and RS Lookup Field mapping.
 *
 */
public with sharing class Dell_IBExportConfigScript {

    
	public static void createIBExportConfiguration(){
		Savepoint sp = Database.setSavepoint();
		 
		try{
			//ServiceSource1__
    		String baseNamespace = '';
           /* RS Config Rec */
            insertRSConfigurationRecords(baseNamespace);
            
            userAssignmentToDellPS();
            
        } catch (Exception ex) {
            Database.rollback(sp);
    		System.debug('**ex ' + ex.getMessage());
        }
	}
	private static void insertRSConfigurationRecords(String baseNamespace) {
		
    	Set<String> flowNameList = new Set<String>{'IB Export','Generate IB Export','IB Export Download'};
    	String queryString = 'Select Id, ' + baseNamespace + 'REN_Invoking_Object__c, ' + baseNamespace + 'REN_Named_Credential__c, ' + 
        baseNamespace + 'REN_Named_Credential_URL_Extension__c, ' + baseNamespace + 'REN_Field_Set_Name__c, ' + baseNamespace + 'REN_Flow_Name__c, ' + 
        baseNamespace + 'REN_Columns__c, ' + baseNamespace + 'REN_Custom_Object__c, ' + baseNamespace + 'REN_Custom_Permission_Name__c, ' + 
        baseNamespace + 'REN_Display_Dialog__c, ' + baseNamespace + 'REN_SOQL__c from ' + baseNamespace + 'REN_RS_Config__c where ' + 
        baseNamespace + 'REN_Flow_Name__c IN : flowNameList';
                
	    System.debug('** ' + queryString);
	    
	    List<sObject> rsConfigList = Database.query(queryString);
	    
		System.debug('** ' + rsConfigList);
	    //If RS Configuration record exists
	    if(rsConfigList == null || rsConfigList.isEmpty()){
			
			List<sObject> rsObjToInsertList = new List<sObject>();
	        
	        sObject rsConfigObj = Schema.getGlobalDescribe().get(baseNamespace + 'REN_RS_Config__c').newSObject();
	        	rsConfigObj.put(baseNamespace + 'REN_Flow_Name__c','IB Export');
	            rsConfigObj.put(baseNamespace + 'REN_Invoking_Object__c','IBReport__c');
	            rsConfigObj.put(baseNamespace + 'REN_Field_Set_Name__c','REN_IB_Export_Grid');
	            rsConfigObj.put(baseNamespace + 'REN_Columns__c','REN_IB_Export_Filterable');
	            rsConfigObj.put(baseNamespace + 'REN_Named_Credential__c','RS_Echo');
	            rsConfigObj.put(baseNamespace + 'REN_Named_Credential_URL_Extension__c','/odata/frb1/dell_report/IBReport/dell.CustomSearch');
				
				rsObjToInsertList.add(rsConfigObj);
	            
			rsConfigObj = Schema.getGlobalDescribe().get(baseNamespace + 'REN_RS_Config__c').newSObject();
	        	rsConfigObj.put(baseNamespace + 'REN_Flow_Name__c','Generate IB Export');
	            rsConfigObj.put(baseNamespace + 'REN_Invoking_Object__c','IBReport__c');
	            rsConfigObj.put(baseNamespace + 'REN_Field_Set_Name__c','REN_IB_Export_Grid');
	            rsConfigObj.put(baseNamespace + 'REN_Columns__c','REN_IB_Export_Filterable');
	            rsConfigObj.put(baseNamespace + 'REN_Named_Credential__c','RS_Echo');
	            rsConfigObj.put(baseNamespace + 'REN_Named_Credential_URL_Extension__c','/odata/frb1/dell_report/IBReport/dell.Export');
				
				rsObjToInsertList.add(rsConfigObj);
				
			rsConfigObj = Schema.getGlobalDescribe().get(baseNamespace + 'REN_RS_Config__c').newSObject();
	        	rsConfigObj.put(baseNamespace + 'REN_Flow_Name__c','IB Export Download');
	            rsConfigObj.put(baseNamespace + 'REN_Named_Credential__c','RS_Echo');
	            rsConfigObj.put(baseNamespace + 'REN_Named_Credential_URL_Extension__c','/upload/dell/DownloadPresignedUrl');
				
				rsObjToInsertList.add(rsConfigObj);
				
	        	insert rsObjToInsertList;
			
			Map<String,Id> rsConfigFlowNameIdMap = new Map<String,Id>();
			
			if(rsObjToInsertList != null){
	            for(SObject rsConfigRec : rsObjToInsertList){
	                rsConfigFlowNameIdMap.put((String)rsConfigRec.get(baseNamespace + 'REN_Flow_Name__c'), (Id)rsConfigRec.get('Id'));
	            }
	        }
	        Set<Id> reConfigFlowIdSet = new Set<Id>();
	        reConfigFlowIdSet.add((Id)rsConfigFlowNameIdMap.get('IB Export'));
			insertLookupFieldMappingRecords(reConfigFlowIdSet, baseNamespace);
			
	    }else if(rsConfigList != null && !rsConfigList.isEmpty()){
			
			for(sObject obj : rsConfigList){
	            System.debug('** ' + obj.get(baseNamespace + 'REN_Flow_Name__c'));
				if(flowNameList.contains((String)obj.get(baseNamespace + 'REN_Flow_Name__c'))){
					flowNameList.remove((String)obj.get(baseNamespace + 'REN_Flow_Name__c'));
				}
			}
			System.debug('** ' + flowNameList);
			if(flowNameList.contains('IB Export')){
				sObject rsConfigObj = Schema.getGlobalDescribe().get(baseNamespace + 'REN_RS_Config__c').newSObject();
					rsConfigObj.put(baseNamespace + 'REN_Flow_Name__c','IB Export');
					rsConfigObj.put(baseNamespace + 'REN_Invoking_Object__c','IBReport__c');
					rsConfigObj.put(baseNamespace + 'REN_Field_Set_Name__c','REN_Generate_IB_Export');
					rsConfigObj.put(baseNamespace + 'REN_Columns__c','REN_IB_Export_Filterable');
					rsConfigObj.put(baseNamespace + 'REN_Named_Credential__c','RS_Echo');
					rsConfigObj.put(baseNamespace + 'REN_Named_Credential_URL_Extension__c','/odata/frb1/dell_report/IBReport/dell.CustomSearch');
					
					insert rsConfigObj;
					
					Set<Id> reConfigFlowIdSet = new Set<Id>();
	        		reConfigFlowIdSet.add((Id)rsConfigObj.get('Id'));
					insertLookupFieldMappingRecords(reConfigFlowIdSet, baseNamespace);
			}
			
			if(flowNameList.contains('Generate IB Export')){
				sObject rsConfigObj = Schema.getGlobalDescribe().get(baseNamespace + 'REN_RS_Config__c').newSObject();
					rsConfigObj.put(baseNamespace + 'REN_Flow_Name__c','Generate IB Export');
					rsConfigObj.put(baseNamespace + 'REN_Invoking_Object__c','IBReport__c');
					rsConfigObj.put(baseNamespace + 'REN_Field_Set_Name__c','REN_Generate_IB_Export');
					rsConfigObj.put(baseNamespace + 'REN_Columns__c','REN_IB_Export_Filterable');
					rsConfigObj.put(baseNamespace + 'REN_Named_Credential__c','RS_Echo');
					rsConfigObj.put(baseNamespace + 'REN_Named_Credential_URL_Extension__c','/odata/frb1/dell_report/IBReport/dell.Export');
					
					insert rsConfigObj;
			}
			
			if(flowNameList.contains('IB Export Download')){
				sObject rsConfigObj = Schema.getGlobalDescribe().get(baseNamespace + 'REN_RS_Config__c').newSObject();
					rsConfigObj.put(baseNamespace + 'REN_Flow_Name__c','IB Export Download');
					rsConfigObj.put(baseNamespace + 'REN_Named_Credential__c','RS_Echo');
					rsConfigObj.put(baseNamespace + 'REN_Named_Credential_URL_Extension__c','/upload/dell/DownloadPresignedUrl');
					
					insert rsConfigObj;
			}
			
	    }

		
	}
	private static void insertLookupFieldMappingRecords(Set<Id> rsConfigurationRecordId, String baseNamespace) {
		List<sObject> rsLookupObjToInsertList = new List<sObject>();
				
			sObject rsLookupAddObj = Schema.getGlobalDescribe().get(baseNamespace + 'REN_RS_Lookup_Field_Mapping__c').newSObject();
	        	rsLookupAddObj.put(baseNamespace + 'REN_RS_Configuration__c', new List<Id> (rsConfigurationRecordId)[0]);
	            rsLookupAddObj.put(baseNamespace + 'REN_Object_API_Name__c','core_organizations__c');
	            rsLookupAddObj.put(baseNamespace + 'REN_Field_API_Name__c','Bill_To_Customer__c');
	            rsLookupAddObj.put(baseNamespace + 'REN_Named_Credential__c','RS_Echo');
	            rsLookupAddObj.put(baseNamespace + 'REN_Named_Credential_URL_Extension__c','/odata/frb1/dell/core_organizations');
	        	
	            rsLookupObjToInsertList.add(rsLookupAddObj);
	        
	        sObject rsLookupOrgObj = Schema.getGlobalDescribe().get(baseNamespace + 'REN_RS_Lookup_Field_Mapping__c').newSObject();
	        	rsLookupOrgObj.put(baseNamespace + 'REN_RS_Configuration__c', new List<Id> (rsConfigurationRecordId)[0]);
	            rsLookupOrgObj.put(baseNamespace + 'REN_Object_API_Name__c','core_addresses__c');
	            rsLookupOrgObj.put(baseNamespace + 'REN_Field_API_Name__c','Customer_Address__c');
	            rsLookupOrgObj.put(baseNamespace + 'REN_Named_Credential__c','RS_Echo');
	            rsLookupOrgObj.put(baseNamespace + 'REN_Named_Credential_URL_Extension__c','/odata/frb1/dell/core_addresses');
	        	
	            rsLookupObjToInsertList.add(rsLookupOrgObj);
				
				insert rsLookupObjToInsertList;
	}
	
	/* This method used to assigned new Prism IB Export - Object Access, to all the active users who have 'Prism' profile. */
    @future
	public static void userAssignmentToDellPS() {
        List<User> userList = [Select id,name,Profile.Name from User where Profile.Name like '%Prism%' and isActive = true];
        List<PermissionSetAssignment>  psaList  = new List<PermissionSetAssignment>();
        PermissionSet ps = [SELECT name,ProfileId FROM PermissionSet where name = 'PRISM_IB_Export_Object_Access'];
            
        if(userList != null && ps != null){
            for(User user : userList){
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psaList.add(new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = user.id));
            }
        }
        
        if(psaList != null){
            insert psaList;
        }
    } 
}