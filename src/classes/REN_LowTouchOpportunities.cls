/**
 * Created Date     : April, 09 2018
 * Developed By     : Nidhi, Comity Designs, Inc.
 *
 * Function         : @description - Handling operations related to Low Touch Opportunities
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                   User Story              April, 09 2018    1.0         Handling operations related to Low Touch Opportunities   
 *
 */
public with sharing class REN_LowTouchOpportunities {
	
	/* This method is used to validated syncQuote, quotePDF and primary contact validation, update opportunity stage.*/
    public static REN_JSONAPIPayLoad updateOppStageOnLoad(REN_LowTouchUtil.LowTouchWrapper ltWrapper){
        final String COMMIT_LEVEL = 'Commit_Level__c';
        final String QUOTE_DELIVERED = 'Quote Delivered';
        final String OBJ_OPP_QUOTE_NUMBER = 'LT_Synced_Quote_Number__c';
		
    	List<REN_JSONAPIPayLoad.Error> errorList = ltWrapper.payLoad.errors;
    	ltWrapper.payLoad.status = 'SUCCESS';
    	String oppId;
    	Savepoint sp = Database.setSavepoint();
        try {
        	if(!ltWrapper.oppIdSet.isEmpty()){
        		oppId =(new List<Id>(ltWrapper.oppIdSet))[0];
            	         
                List<Opportunity> oppList = REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(new List<String>{oppId},false);
                if(!oppList.isEmpty()){
	                if(!Test.isRunningTest() && (String.isBlank((String)oppList[0].get('syncedquoteid')) || (String)oppList[0].get('syncedquoteid') == null)) {
	                	ltWrapper.payLoad.status = 'ERROR';
	                	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, Label.REN_LT_SYNCED_QUOTE_ERR, Label.REN_LT_SYNCED_QUOTE_ERR));
	                    REN_LowTouchUtil.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, Label.REN_LT_SYNCED_QUOTE_ERR, oppId); 
	                } else if(oppList[0].isClosed) {
	                	ltWrapper.payLoad.status = 'ERROR';
	                	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, Label.CHL_LBL_OPP_CLOSED, Label.CHL_LBL_OPP_CLOSED));
	                    REN_LowTouchUtil.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, Label.CHL_LBL_OPP_CLOSED, oppId); 
	               }else {
                        if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+COMMIT_LEVEL)){
                            sObject obj = (sObject) oppList[0];
                            obj.put(CSM_Util.nameSpacePrefixSolnExtn+COMMIT_LEVEL, 'Red');
                            oppList[0] = (Opportunity) obj;
                        }
                        oppList[0].StageName = QUOTE_DELIVERED;
                        OpportunityStage oppStage = REN_OpportunityDataAccess.getProbabilityValueByStage(QUOTE_DELIVERED);
                        oppList[0].Probability = oppStage.DefaultProbability;                        
	                    List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(new set<String>{oppId});
	                    //Contact primaryContact ;
	                    if(!opptyRoleList.isEmpty()){
	                        oppList[0].REN_Primary_Contact__c = opptyRoleList[0].contactId;
	                        //primaryContact = new Contact(Id=oppList[0].REN_Primary_Contact__c);
	                        //primaryContact.REN_Prefered_Language_Code__c = ltWrapper.langCode != null && ltWrapper.langCode != '' ?ltWrapper.langCode : '';
	                    } else {
	                    	ltWrapper.payLoad.status = 'ERROR';
	                		errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, Label.REN_INVALID_CONTACT, Label.REN_INVALID_CONTACT));
	                    	REN_LowTouchUtil.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, System.label.REN_INVALID_CONTACT, oppId); 
	                    }
	                    if(ltWrapper.payLoad.status == 'SUCCESS'){
	                    	/*List<String> contactFieldList = new List<String>{'REN_Prefered_Language_Code__c','HasOptedOutOfEmail'};
            				CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_CONTACT, contactFieldList,CSM_Constants.DML_OPERATION_UPDATE);        	
	                    	CSM_ContactDataAccess.updateContact(new List<contact>{primaryContact}, new List<String>{'Id','REN_Prefered_Language_Code__c'});
	                    	*/
	                    	List<String> opportunityFieldList = new List<String>{'REN_Primary_Contact__c','REN_LT_Renewal_Details__c',REN_Constants.OBJ_OPP_PROBABILITY,REN_Constants.OBJ_OPP_STAGE};
            				CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_UPDATE);   
	                    	REN_OpportunityDataAccess.updateOpportunitySObject(oppList, new List<String>{'Id','Probability','REN_LT_Renewal_Details__c'});
	                    }
	                }
	            }
            }
        } catch(Exception e){
            Database.rollback(sp);
            ltWrapper.payLoad.status = 'ERROR';
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, 'Exception occured', e.getMessage()));
            REN_LowTouchUtil.updateErrorLog(system.label.CHL_LBL_STAGE_ONLOAD, e.getMessage(), oppId);
            ltWrapper.payLoad.errors = errorList;
        }
        ltWrapper.payLoad.errors = errorList;
        return ltWrapper.payLoad;
    }
    
    /* This method handles 'Buy Now' flow and update opportunity stage, commit level and also create Booking Request case */
    public static REN_JSONAPIPayLoad handelOpportunityOnBuyNow(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	final String COMMIT_LEVEL='Commit_Level__c';
    	final String PO_RECEIVED ='PO Received';
        final String COMMIT_LEVEL_YELLOW = 'Yellow';
    	String orderMethod = payLoad.data != null && payLoad.data[0].attributes.containsKey('orderMethod') ? payLoad.data[0].attributes.get('orderMethod') : '';
    	Map<String, String> orderMethodMap = getOrderMethodMap();
    	List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
    	payLoad.status = 'SUCCESS';
    	System.Savepoint sp = Database.setSavepoint();
        try {
            List<Opportunity> oppList = REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(new List<String>(oppIdSet));
            if(!oppList.isEmpty()){
                oppList[0].StageName = PO_RECEIVED;
                oppList[0].REN_Notify_Opportunity_Owner__c  = true;
                
                oppList[0].REN_LT_Renewal_Details__c = orderMethodMap != null  && orderMethodMap.containsKey(orderMethod) ? orderMethodMap.get(orderMethod) : orderMethodMap.get('PP');
                OpportunityStage oppStage = REN_OpportunityDataAccess.getProbabilityValueByStage(PO_RECEIVED);
                oppList[0].Probability = oppStage.DefaultProbability;
            	if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+COMMIT_LEVEL)) {
                	oppList[0].put(CSM_Util.nameSpacePrefixSolnExtn+COMMIT_LEVEL, COMMIT_LEVEL_YELLOW);
            	}
                CSM_CaseDataAccess.createBookingRequest(oppList[0].id);
                REN_OpportunityDataAccess.updateOpportunitySObject(new List<Opportunity>{oppList[0]}, new List<String>{'StageName','REN_LT_Renewal_Details__c','REN_Notify_Opportunity_Owner__c','Probability'});
            	if(payLoad.data != null){
		        	if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c')){
		        		payLoad.data[0].attributes.put('quoteNumber', (String)oppList[0].get(CSM_Util.nameSpacePrefixSolnExtn+'LT_Synced_Quote_Number__c'));
		        	}
		        	payLoad.data[0].attributes.put('StageName', 'PO_RECEIVED');
		        }
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            payLoad.status = 'ERROR';
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', 'Error', 'Exception occured', ex.getMessage()));
            REN_LowTouchUtil.updateErrorLog(system.label.REN_LBL_REN_OPP_UPDS, ex.getMessage(), (new List<String>(oppIdSet))[0]);
            payLoad.errors = errorList;
        }
        payLoad.errors = errorList;
        
        return payLoad;
    }
    
    private static Map<String, String> getOrderMethodMap(){
    	Map<String, String> orderMethodMap = new Map<String, String>();
    	orderMethodMap.put('PO', Label.REN_PAY_VIA_PO);
    	orderMethodMap.put('DS', Label.REN_SIGN_VIA_DOCUSIGN);
    	orderMethodMap.put('PP', Label.REN_PAY_VIA_CREDIT_CARD);
    	return orderMethodMap;
    }
    
}