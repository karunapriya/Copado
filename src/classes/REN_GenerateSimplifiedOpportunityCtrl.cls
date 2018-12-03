/**
 * Created Date     : Jul 19, 2017
 * Developed By     : Dheeraj, Comity Designs, Inc.
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
 * Dheeraj                  US2551              Jul 19, 2017            1.1                 @description
 * 
 */
public with sharing class REN_GenerateSimplifiedOpportunityCtrl {
    public Opportunity renewOpportunity{get;set;}
    public OpportunityLineItem masterOli{get;set;}
    public List<REN_RenewLineWrapper> lstOfRLIWrapper{get;set;}
    public List<REN_OpptLineWrapper> opliWrapperList{get;set;} 
    private Map<String,OpportunityLineItem> mapOfOliForAssets;
    private Map<String,OpportunityLineItem> mapOfOliForSC;
    private Map<String,OpportunityLineItem> mapOfCombinedOli;
    List<OpportunityLineItem> lstOfCombinedOli;
     Map<Id,PriceBookEntry> mapofOppToPBE;
    private static final Boolean entitlementPkgInstalled = CSM_AccessController.hasField(
                                                            REN_Constants.OBJ_OPPORTUNITY, 
                                                            CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
    private Map<String,List<REN_Renews_To__c>> mapOfRLI ;
    private String oppId;
    private String contractId;
    private List<Opportunity> currentOpp;
    REN_GenerateSimplifiedOpptyCtrlHelper genSimplified;
    public List<String> lstOfAssetsId;
    Map<Id,Asset> mapOfAssets;
    List<Asset> lstOfAsset;
    List<Opportunity> oppLst;
    List<PricebookEntry> pbeList{get;set;}
    List<sObject> scLst;
    Map<Id,sObject> mapOfContractlineItem;
    public String namespace{get;set;}
    
    public REN_GenerateSimplifiedOpportunityCtrl(ApexPages.StandardController standardController) {
        String assetsId;
        SS_License__c productIdSetting= SS_License__c.getOrgDefaults();
        
        lstOfAssetsId = new List<String>();
        lstOfAsset = new List<Asset>();
        if(productIdSetting!=null && productIdSetting.Simplified_Data_Model_Is_Enabled__c){
	        genSimplified = new REN_GenerateSimplifiedOpptyCtrlHelper();
	        List<REN_Field_Mappings__c> lstFieldMapp = genSimplified.getOpportunityMapping(REN_Constants.OBJ_OPPORTUNITY,REN_Constants.OBJ_OPPORTUNITY);
	        lstOfRLIWrapper = new List<REN_RenewLineWrapper>();
	        opliWrapperList = new List<REN_OpptLineWrapper>();
	        lstOfCombinedOli= new List<OpportunityLineItem>();
	        mapOfAssets = new Map<Id,Asset>();
	        namespace = CSM_Util.getNamespace();
	        
	        mapOfCombinedOli = new Map<String,OpportunityLineItem>();
	        
	        oppId = ApexPages.currentpage().getparameters().get('id');
	        if(String.isBlank(oppId)){
	            oppId = ApexPages.currentpage().getparameters().get('parentId');
	        }
	        contractId = ApexPages.currentpage().getParameters().get('contractId');
	        if(String.isNotBlank(contractId)){
	        	scLst = REN_ServiceContractsDataAccess.getServiceContractListForMerge(new set<Id>{Id.valueOf(contractId)});
	        }
	        assetsId = ApexPages.currentpage().getparameters().get('assetIds');
	        if(String.isNotBlank(assetsId)){
	            lstOfAssetsId = assetsId.split('-');
	            if(!lstOfAssetsId.isEmpty()){
	                lstOfAsset = genSimplified.getAssetsDetail(lstOfAssetsId);              
	            }
	        }
	        if(String.isNotBlank(oppId)){
	            currentOpp = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{oppId});
	        }
	        renewOpportunity= genSimplified.getRenewOpp(lstOfAsset,currentOpp,assetsId,scLst);
	        if(!lstOfAsset.isEmpty()){
	            mapOfAssets = new Map<Id,Asset>(lstOfAsset);   
	            CSM_Util.setAppliedCurrency(renewOpportunity, CSM_Util.getAppliedCurrency(lstOfAsset[0])); 
	        }
	        
	        masterOli = new OpportunityLineItem();
	        masterOli.Quantity = 1;
	       
	        if(lstOfAsset.isEmpty() && String.isBlank(contractId)){
	            mapOfOliForAssets = genSimplified.getValidOli(REN_Constants.OBJ_ASSET,oppId);
	            mapOfOliForSC = genSimplified.getValidOli(REN_Constants.OBJ_SERVICE_CONTRACT,oppId);
	            mapOfCombinedOli.putAll(mapOfOliForAssets);
	            mapOfCombinedOli.putAll(mapOfOliForSC);
	            lstOfCombinedOli.addAll(mapOfOliForAssets.values());
	            lstOfCombinedOli.addAll(mapOfOliForSC.values());
	            lstFieldMapp = genSimplified.getOpportunityMapping(REN_Constants.OBJ_RENEW_LINE_ITEM,REN_Constants.OBJ_OPPTY_LINE_ITEM);
	            mapOfRLI = genSimplified.getRLIList(lstFieldMapp,lstOfCombinedOli,REN_Constants.OBJ_OPPTY_LINE_ITEM);
	        }else if(!lstOfAsset.isEmpty()){
	            mapOfRLI = genSimplified.getRLIList(genSimplified.getOpportunityMapping(
	                                  REN_Constants.OBJ_RENEW_LINE_ITEM,
	                                  REN_Constants.OBJ_ASSET),lstOfAsset,REN_Constants.OBJ_ASSET);
	        }else if(String.isNotBlank(contractId)){
	        	List<REN_Field_Mappings__c> lstOfMapping = genSimplified.getOpportunityMapping(REN_Constants.OBJ_RENEW_LINE_ITEM,REN_Constants.OBJ_CONTRACT_LINE_ITEM);
	        	Set<String> setOfFieldsToQuery = new Set<String>();
	        	Set<String> fieldSet = REN_Util.getFromFldsToQuery(lstOfMapping);
	        	mapOfContractlineItem = new Map<Id,sObject>(REN_ContractLineItemDataAccess.getCLIfromSCId(new Set<Id>{Id.valueOf(contractId)},fieldSet));
	        	mapOfRLI = genSimplified.getRLIList(genSimplified.getOpportunityMapping(
	                                  REN_Constants.OBJ_RENEW_LINE_ITEM,
	                                  REN_Constants.OBJ_CONTRACT_LINE_ITEM),mapOfContractlineItem.values(),REN_Constants.OBJ_SERVICE_CONTRACT);
	            
	        }
	        
	        
	       
	        try{
	            if(productIdSetting.Renewal_Amount_Product_Id__c!=null){
	                if(currentOpp!=null && lstOfAsset.isEmpty()){
	                    mapofOppToPBE = REN_PricebookDataAccess.getOppToPbEntry(currentOpp,productIdSetting.Renewal_Amount_Product_Id__c);
	                }else if(!lstOfAsset.isEmpty()){
	                    pbeList  = REN_PricebookDataAccess.getStandardPBE(productIdSetting.Renewal_Amount_Product_Id__c,genSimplified.getStdPriceBook().Id,CSM_Util.getAppliedCurrency(lstOfAsset[0]));
	                }else if(String.isNotBlank(contractId)){
	                	if(UserInfo.isMultiCurrencyOrganization()){
	                		pbeList = REN_PricebookDataAccess.getStandardPBE(productIdSetting.Renewal_Amount_Product_Id__c,''+scLst.get(0).get('Pricebook2Id'),''+scLst.get(0).get('CurrencyIsoCode'));
	                	}else{
	                		pbeList = REN_PricebookDataAccess.getStandardPBE(productIdSetting.Renewal_Amount_Product_Id__c,''+scLst.get(0).get('Pricebook2Id'),null);
	                	}
	                }
	            }else{
	                  throw new InvalidDataException(System.Label.REN_MISSING_RENEWAL_AMOUNT_ID);
	            }
	            
	            if(mapOfRLI!=null && !mapOfRLI.isEmpty()){
	            	lstOfRLIWrapper = genSimplified.getRliWrapper(mapOfRLI,mapOfCombinedOli,mapOfOliForAssets,mapOfOliForSC,lstOfAsset,mapOfAssets,masterOli,mapOfContractlineItem);
	                    
		            REN_OpptLineWrapper oliWrapper = new REN_OpptLineWrapper();
		            oliWrapper.opLine = masterOli;
		            oliWrapper.customId = 0;
		            if(currentOpp!=null && currentOpp.size()>0 && lstOfAsset.isEmpty()){
		                oliWrapper.opportunityProduct =mapofOppToPBE.get(currentOpp.get(0).Id).Product2.Name;
		            }else{
		                oliWrapper.opportunityProduct =pbeList.get(0).Product2.Name;
		            }
		            opliWrapperList.add(oliWrapper);
	            }
	        }catch(Exception e){
	            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
	        }
        }
    }
    
     public PageReference cancel() {
      PageReference pageRef;
      if(String.isNotBlank(this.oppId )){
        pageRef = new PageReference('/' + this.oppId);
      }else{        
        pageRef = new PageReference('/' + this.contractId);
      }
        return pageRef;
    }
    
     public PageReference save(){
        Savepoint spBeforeOpptCreate = Database.setSavepoint();
        try{
        	CSM_TriggerManager.disableAllTriggers();
            if(lstOfRLIWrapper==null || lstOfRLIWrapper.isEmpty()){
                throw new InvalidDataException(System.Label.REN_ERR_OPPORTUNITY_WITHOUT_RR);
            } 
            //Added for US3283
            if(CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c')){
        		renewOpportunity.put('Opportunity_Name__c', renewOpportunity.Name);
            }
            /*DE3344 : In case error occurs then we rollback Oppty creation, however Id is retained in rollback. 
            			When we correct the data and re-submit it gives error like ID cannot be specified in insert call.
            			In catch we are assigning ID as Null, so here if ID is null then make a clone of that record to remove Id.*/
            if(renewOpportunity.Id == null){
                renewOpportunity = renewOpportunity.clone(false);
            }
            REN_OpportunityDataAccess.insertOpportunity(new List<Opportunity>{renewOpportunity});
            /* Start -- Added for  US3283 */
            Boolean hasCSMAccess = SS_LicenseCheck.getInstance().isCSMEnabled;
		    Set<Id> accountIdsSet = new Set<Id>();	
		    List<sObject> oppObjList = new List<sObject>();
		    if(renewOpportunity.accountId != null){
					accountIdsSet.add(renewOpportunity.accountId);
					oppObjList.add((sObject)renewOpportunity);
		     } 	
             if(hasCSMAccess && !(accountIdsSet.isEmpty())){ 
				CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountIdsSet, oppObjList, CSM_Constants.OBJ_TYPE_OPPORTUNITY);
			 }
            /* End */
            if(currentOpp!=null && !currentOpp.isEmpty()&&lstOfAsset.isEmpty() && currentOpp.get(0).AccountId == null){
                throw new InvalidDataException(System.Label.REN_ERR_ASSETS_NOT_CREATED);
            }
            List<REN_Renews_To__c> lstOfRli = new List<REN_Renews_To__c>();
            Map<String,String> srcInAndOutMapOpp = new Map<String,string>();
            Map<String,String> srcInAndOutMapSC = new Map<String,string>();
            Map<String,OpportunityLineItem> mapOfOli2CreateAsset = new Map<String,OpportunityLineItem>(); 
            Map<String,OpportunityLineItem> mapOfOli2CreateSC = new Map<String,OpportunityLineItem>();
            for(REN_RenewLineWrapper rliWrapper: lstOfRLIWrapper){
            	REN_Renews_To__c rr = rliWrapper.renewLine;
          		rr.REN_Renews_To__c = renewOpportunity.Id;
           		if (UserInfo.isMultiCurrencyOrganization()){
                	rr.put('CurrencyIsoCode',(String)renewOpportunity.get('CurrencyIsoCode'));	
            	}	                           
                if(!lstOfAssetsId.isEmpty()){
                    rr.REN_Asset__c = rliWrapper.sourceOpptLnId;
                }else if(mapOfContractlineItem!=null){
					rr.put(CSM_Util.nameSpacePrefix21+'REN_Contract_Line_Item__c',mapOfContractlineItem.get(rliWrapper.sourceOpptLnId).get('Id'));
				}else{
                    if(mapOfOliForAssets.containsKey(rliWrapper.sourceOpptLnId) && rliWrapper.typeOfRli==REN_Constants.OBJ_ASSET){
                        mapOfOli2CreateAsset.put(rliWrapper.sourceOpptLnId,mapOfCombinedOli.get(rliWrapper.sourceOpptLnId));
                    }
                    if(mapOfOliForSC.containsKey(rliWrapper.sourceOpptLnId)&& rliWrapper.typeOfRli==REN_Constants.OBJ_SERVICE_CONTRACT){
                        mapOfOli2CreateSC.put(rliWrapper.sourceOpptLnId,mapOfCombinedOli.get(rliWrapper.sourceOpptLnId));
                    }
                }
	            rr.REN_Renewal_Target_Multiplier__c = rr.REN_Renewal_Target_Multiplier__c == null ? 1 : rr.REN_Renewal_Target_Multiplier__c;
	            if(rr.REN_Previous_Price__c != null){
	                rr.REN_Renewal_Target__c = rr.REN_Previous_Price__c * rr.REN_Renewal_Target_Multiplier__c;
	            }else{
	                rr.REN_Renewal_Target__c = 0;
	            }
                
                lstOfRli.add(rr);
            }
            if(currentOpp!=null && !currentOpp.isEmpty()&& lstOfAssetsId.isEmpty()){
                srcInAndOutMapOpp.put(renewOpportunity.Id,currentOpp.get(0).Id);
            	genSimplified.createSourceOutBoundForOpp(srcInAndOutMapOpp); 
            }
                       
            if(lstOfAssetsId.isEmpty() && mapOfContractlineItem==null){
                Map<String,Asset> mapOfOli2Asset = genSimplified.createAssets(mapOfOli2CreateAsset,genSimplified.getOpportunityMapping(REN_Constants.OBJ_ASSET, REN_Constants.OBJ_OPPTY_LINE_ITEM));
                List<sObject> lstOfSc = new List<sObject>();
                Map<String,sObject> mapOfCLI = new Map<String,sObject>();            
                if(entitlementPkgInstalled){
                    
                        lstOfSc=genSimplified.getServiceContract(srcInAndOutMapSC,currentOpp,renewOpportunity,mapOfOliForSC);
                        
                        if(!srcInAndOutMapSC.isEmpty()){
                                genSimplified.createSourceOutBoundForSC(srcInAndOutMapSC);
                        }
                        mapOfCLI = genSimplified.getContractLineItem(currentOpp,lstOfSc,mapOfOli2CreateSC.values());
                    
                }
                if(mapOfOli2Asset!=null || !mapOfOli2Asset.isEmpty()){
                    for(Asset ast: mapOfOli2Asset.values()){
                        ast.AccountId = currentOpp.get(0).AccountId;
                        ast.REN_Opportunity__c = currentOpp.get(0).Id;
                    }
                    List<Database.SaveResult> lstOfRslt = REN_AssetDataAccess.insertAssets(mapOfOli2Asset.values());
                    if(lstOfRslt!=null){
                        String msg = '';
                        for(Database.SaveResult sr: lstOfRslt){
                            if(!sr.isSuccess()){
                                for(Database.Error err : sr.getErrors()) {
                                    msg += err.getStatusCode() + ': ' + err.getMessage()+' ';
                                }
                                throw new InvalidDataException(msg);
                            }
                        }
                    }
                }
                for(REN_RenewLineWrapper rliWrapper: lstOfRLIWrapper){
                    if(mapOfOli2Asset.containsKey(rliWrapper.sourceOpptLnId) && rliWrapper.typeOfRli==REN_Constants.OBJ_ASSET){
                        rliWrapper.renewLine.REN_Asset__c = mapOfOli2Asset.get(rliWrapper.sourceOpptLnId).Id;
                    }else if(mapOfCLI.containsKey(rliWrapper.sourceOpptLnId) && rliWrapper.typeOfRli==REN_Constants.OBJ_SERVICE_CONTRACT){
                        rliWrapper.renewLine.put(CSM_Util.nameSpacePrefix21+'REN_Contract_Line_Item__c',mapOfCLI.get(rliWrapper.sourceOpptLnId).get('Id'));
                        rliWrapper.renewLine.put(CSM_Util.nameSpacePrefix21+'REN_Service_Contract__c',lstOfSc.get(0).get('Id')); 
                    }
                }                               
            }else if(mapOfContractlineItem!=null){
				
				scLst.get(0).put(CSM_Util.nameSpacePrefix21+'REN_Renewal_Opportunity__c',renewOpportunity.Id);
				REN_ServiceContractsDataAccess.upsertServiceContractList(scLst);
				srcInAndOutMapSC.put(''+scLst.get(0).get('Id'),''+renewOpportunity.Id);
				genSimplified.createSourceOutBoundForSC(srcInAndOutMapSC);
			}
            REN_RRSimplifiedTriggerHandler.isMaualOppGeneration = true;
            REN_RRSimplifiedTriggerHelper.processRliRecords(lstOfRli);
            
            /*DE3344 : In case error occurs then we rollback RLI creation, however Id is retained in rollback for the success records. 
            			When we correct the data and re-submit it gives error like ID cannot be specified in insert call.
            			so here we make a clone of that record to remove Id.*/ 
            List<REN_Renews_To__c> rlisToBeInsertedList = new List<REN_Renews_To__c>();
            for(REN_Renews_To__c rli : lstOfRli){             
                if(rli.Id != null){
                    rlisToBeInsertedList.add(rli.clone(false));                  
                }
                else{
                	rlisToBeInsertedList.add(rli);
                }
            }
            List<Database.SaveResult> rliInserted = REN_RenewRelationshipDataAccess.insertRenewalRelationship(rlisToBeInsertedList);
            if(rliInserted != null && !rliInserted.isEmpty()){
            	for(Database.SaveResult result: rliInserted){
	                if(!result.isSuccess()){
	                    renewOpportunity.Id = null;
	                	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,String.valueOf(result.getErrors().get(0).getMessage())));
						Database.rollback(spBeforeOpptCreate);
	                    lstOfRLIWrapper = new List<REN_RenewLineWrapper>();
	                    lstOfRLIWrapper = genSimplified.getRliWrapper(mapOfRLI,mapOfCombinedOli,mapOfOliForAssets,mapOfOliForSC,lstOfAsset,mapOfAssets,masterOli,mapOfContractlineItem);
						return null;    
	                }   
            	}	
            }           
            PageReference pageRef;
            if(renewOpportunity!=null && renewOpportunity.Id != null){
              pageRef = new PageReference('/' + renewOpportunity.Id);
            }
            REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(new Set<Id>{renewOpportunity.Id}); 
            return pageRef;
       }catch(Exception e){
       		renewOpportunity.Id = null;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
           	Database.rollback(spBeforeOpptCreate);
           	lstOfRLIWrapper = new List<REN_RenewLineWrapper>();
	        lstOfRLIWrapper = genSimplified.getRliWrapper(mapOfRLI,mapOfCombinedOli,mapOfOliForAssets,mapOfOliForSC,lstOfAsset,mapOfAssets,masterOli,mapOfContractlineItem);
      		return null;
       }       
       return null;
    }
    
    public void calculateOliTotal(){
        Integer total =0;
        for(REN_RenewLineWrapper rliWrapper: lstOfRLIWrapper){
            if(rliWrapper.renewLine.REN_Previous_Price__c!=null){
                if(rliWrapper.renewLine.REN_Renewal_Target_Multiplier__c!=null){
                    total += Integer.valueOf(rliWrapper.renewLine.REN_Previous_Price__c) * Integer.valueOf(rliWrapper.renewLine.REN_Renewal_Target_Multiplier__c);
                }else{
                    total += Integer.valueOf(rliWrapper.renewLine.REN_Previous_Price__c);
                }
            }
        }
        if(opliWrapperList!=null && !opliWrapperList.isEmpty()){
            opliWrapperList.get(0).opLine.UnitPrice = total;
        }
    }
    public String getJsonArray()
    {
      return JSON.serialize(lstOfRLIWrapper).replaceAll('\\\'','\\\\\'');
    }
    public class InvalidDataException extends Exception{}
}