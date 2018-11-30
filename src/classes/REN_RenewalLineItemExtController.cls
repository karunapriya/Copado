/**
 * Created Date     : Oct 27, 2016
 * Developed By     : prashant, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * prashant                 User Story              Oct 27, 2016            1.1                 @description
 *
*/
public with sharing class REN_RenewalLineItemExtController {
	public boolean isCurrencyFieldRequired {get;set;}
	public boolean hasQuote {get;set;}
	public boolean showQuotePopUp {get;set;}
	public String oppID{get; set;}
	private list<Opportunity> oportunityToUpdate;
	private REN_Renews_To__c rliRecord{get;set;}
	private ApexPages.StandardController stdController;
	private boolean isNewRRRequest;
    private String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
	private boolean isSolutionExtnInstalled = CSM_AccessController.hasField('Opportunity', solnExtnNamespace + 'Local_Renewal_Target__c');
	public string namespace{get;set;}
	
	public REN_RenewalLineItemExtController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){ 
           stdController.addFields(new List<String>{'REN_Renewal_Target_Multiplier__c'});
        }
		this.stdController = stdController;
    	rliRecord=(REN_Renews_To__c)this.stdController.GetRecord();
    	oppID=rliRecord.REN_Renews_To__c;
        isCurrencyFieldRequired = false;
        showQuotePopUp=false;
        hasQuote=false;
        isNewRRRequest = (rliRecord.id == null);
        rliRecord.OwnerId = UserInfo.getUserId();
        namespace = CSM_Util.getNamespace();
        if(oppID != null && CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId')){
		    oportunityToUpdate = REN_OpportunityDataAccess.getFilteredRecordsList('Opportunity', new Set<String> {'SyncedQuoteId'}, new Set<Id>{oppID}, null, null, null);
		    hasQuote = (oportunityToUpdate[0].get('SyncedQuoteId') != null);
		}
        if(UserInfo.isMultiCurrencyOrganization())  {
            isCurrencyFieldRequired = true;
            if(rliRecord.id==null){
            	rliRecord.put('CurrencyIsoCode',(String)oportunityToUpdate[0].get('CurrencyIsoCode'));
        	}
            List<Schema.FieldSetMember> fieldSetList = Schema.SObjectType.REN_Renews_To__c.FieldSets.REN_Create_New_RR.getFields();
            if(!fieldSetList.isEmpty()){
                for(Schema.FieldSetMember f : fieldSetList) {
                    if(f.getFieldPath() == REN_Constants.REN_CURRENCY_ISO_CODE){
                        isCurrencyFieldRequired = false;
                        break;
                    }
                }
            }
        }
    }
     
     public void validatePopup() {
     	String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		showQuotePopUp=false;
	    List<Schema.FieldSetMember> fieldSetList = Schema.SObjectType.REN_Renews_To__c.FieldSets.REN_Create_New_RR.getFields();  
		String nameSpace = CSM_Util.getNamespace();
		//if(SS_Constants.isSimplifiedDataModelEnabled){
			if(hasQuote && rliRecord.id!=null){
				list<REN_Renews_To__c> rliUpdatedValues=REN_RenewRelationshipDataAccess.getRenewalRelationship(new set<String>{rliRecord.id});
				if(!fieldSetList.isEmpty()){
					for(Schema.FieldSetMember f : fieldSetList) {
	                	if( (f.getFieldPath() == nameSpace + 'REN_Previous_Price__c' && rliRecord.REN_Previous_Price__c != rliUpdatedValues[0].REN_Previous_Price__c) ||
	                		(f.getFieldPath() == nameSpace + 'REN_Renewal_Target_Multiplier__c' && rliRecord.REN_Renewal_Target_Multiplier__c != rliUpdatedValues[0].REN_Renewal_Target_Multiplier__c )){
	                   		showQuotePopUp=true;
	                   		break;
	                	}		
						if(isSolutionExtnInstalled &&
						(f.getFieldPath() == solnExtnNamespace + 'Previous_Local_Currency_Code__c' && rliRecord.get(solnExtnNamespace + 'Previous_Local_Currency_Code__c') != rliUpdatedValues[0].get(solnExtnNamespace + 'Previous_Local_Currency_Code__c') ||
						f.getFieldPath() == solnExtnNamespace + 'Previous_Local_Currency_Amount__c' && rliRecord.get(solnExtnNamespace + 'Previous_Local_Currency_Amount__c') != rliUpdatedValues[0].get(solnExtnNamespace + 'Previous_Local_Currency_Amount__c') )){
							showQuotePopUp=true;
							break;
						}	
					}
				}
			}else if(rliRecord.id==null ){
				showQuotePopUp=true;
			}
     	//}
	 }
    
    public PageReference saveRli() {
    	PageReference detailPage=null;
    	Savepoint sp = Database.setSavepoint();
    	try{
    		CSM_TriggerManager.disableAllTriggers();
	    	List<Schema.FieldSetMember> rrFieldSetMemberList =  SObjectType.REN_Renews_To__c.FieldSets.REN_Create_New_RR.getFields();  
	    	Set<String> rrFieldsForFLS = new Set<String>{'Name', 'REN_Renews_To__c', 'REN_Renewal_Target_Multiplier__c', 'REN_Renews_To__c', 'REN_Quantity__c', 'REN_Previous_Price__c'};
	    	if(isSolutionExtnInstalled){
	    		rrFieldsForFLS.add(solnExtnNamespace + 'Previous_Local_Currency_Amount__c');
	    		rrFieldsForFLS.add(solnExtnNamespace + 'Previous_Local_Currency_Code__c');
	    		if(UserInfo.isMultiCurrencyOrganization()){
	    			rrFieldsForFLS.add('CurrencyIsoCode');
	    		}
	    	}
	    	
	    	rrFieldsForFLS = REN_Util.getFieldNameSetFromFieldSet(rrFieldSetMemberList, rrFieldsForFLS);  
	    	List<String> fieldListForCRUD = new List<String>(rrFieldsForFLS);
	    	
			CSM_TriggerManager.TriggerHandler triggerHandler;
			if(SS_Constants.isSimplifiedDataModelEnabled){			
				triggerHandler = new REN_RRSimplifiedTriggerHandler();
			}else{
				triggerHandler = new REN_RenewalRelationshipTriggerHandler();
			}
			List<REN_Renews_To__c> newRecordList = new List<REN_Renews_To__c>{rliRecord};
	    	if(isNewRRRequest){//Insert case
	    		rliRecord.id = null;
	    		triggerHandler.onBeforeInsert(newRecordList, null);
		    	REN_RenewRelationshipDataAccess.insertRLI(new List<REN_Renews_To__c>{rliRecord},  fieldListForCRUD);
	    		triggerHandler.onAfterInsert(newRecordList, new Map<ID,REN_Renews_To__c>(newRecordList));

	    	}else{//Update case
	    		List<REN_Renews_To__c> oldRliRecordList = REN_RenewRelationshipDataAccess.getRliList(new Set<ID>{rliRecord.id},  fieldListForCRUD);
	    		if(oldRliRecordList != null && !oldRliRecordList.isEmpty()){
		    		System.debug(oldRliRecordList + '\n' + rliRecord);
		    		//Include Before update logic here
		    		triggerHandler.onBeforeUpdate(oldRliRecordList, newRecordList, new Map<ID,REN_Renews_To__c>(oldRliRecordList), new Map<ID,REN_Renews_To__c>(newRecordList));
		    		REN_RenewRelationshipDataAccess.updateRenewalRelationship(new List<REN_Renews_To__c>{rliRecord},  fieldListForCRUD);
	    			//Include After update logic here
		    		triggerHandler.onAfterUpdate(oldRliRecordList, newRecordList, new Map<ID,REN_Renews_To__c>(oldRliRecordList), new Map<ID,REN_Renews_To__c>(newRecordList));
	    		}
	    	}
			if(!ApexPages.hasMessages()){	
				detailPage = new PageReference('/' + rliRecord.id);
			}else{
				Database.rollback(sp);
			}
		}catch(DMLException ex){
			system.debug('*********** stack debug'+ ex.getStackTraceString());
            Database.rollback(sp);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,ex.getDmlMessage(0));
			ApexPages.addMessage(msg);
 			/* Added For DE2943 */
       }catch(Exception e){
       	system.debug('*********** stack debug'+ e.getStackTraceString());
			Database.rollback(sp);
            system.debug('ApexPages value : ' + ApexPages.getMessages() );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
		return detailPage;
    }
    
    public PageReference removeSyncQuoteAndSave() {
    	Savepoint sp = Database.setSavepoint();
    	PageReference detailPage=null;
		CSM_TriggerManager.disableAllTriggers();
    	try{
			if(hasQuote){
	    		oportunityToUpdate[0].put('SyncedQuoteId', null);
	    		REN_OpportunityDataAccess.updateOpportunitySObject(oportunityToUpdate, new List<String>{'SyncedQuoteId'});    
		 	}
			detailPage=saveRli();
    	}catch(Exception e){
        	Database.rollback(sp);
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Invalid Input - ' + e.getMessage());
            system.debug('ApexPages value : ' + ApexPages.getMessages() );
            ApexPages.addMessage(myMsg);
            detailPage=null;
        }        
        return detailPage;
    }
}