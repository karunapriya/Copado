/**
 * Created Date     : Apr 20, 2017
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
 * Dheeraj                  US2293,94               Apr 20, 2017            1.1                 Upsell CrossSell
 *
 */
public with sharing class CHL_ManageUpsellCrossSellCtrl {
    
    
    public transient List<sObject> lstOfQLI{get;set;}
    public List<QLIDetailWrapper> lstOfWrapp{get;set;}    
    private Set<Id> setOfOriginalId;
    //transient Map<Id,Id> mapOfOliToOrgId;
    sObject currentQ;
    public List<Schema.FieldSetMember> fldMembers{get;set;}
    public String qExtentionPrefix{get;set;}
    private set<Id> existingCrossSellIds;
    private final String CROSSSELL = 'Cross-Sell';
    private final String UPSELL='Upsell';
    Map<Id,Id> mapOfRliIdToQLi;
    Map<String,sObject> mapOfUpSell= new Map<String,sObject>();
    TypeValidateWrapper typeValWrap=new TypeValidateWrapper();
    Map<String,List<sObject>> mapOfCrossSell= new Map<String,List<sObject>>();
    Map<Id,sObject> mapOfQLI;
    String quoteId;
    List<String> originalProduct;
    public Boolean simplifiedDataModelIsEnabled {get; set;}
    
    //Variable required for pagination
    public String numberOfRecord{get;set;}
    public List<SelectOption> listOfNumbers{get;set;}
    Map<Id,QLIDetailWrapper> mapOfQliToWrapper;
    private Integer recordLimit;
          
    public CHL_ManageUpsellCrossSellCtrl() {
        this.simplifiedDataModelIsEnabled = SS_Constants.isSimplifiedDataModelEnabled;
        quoteId = ApexPages.currentPage().getParameters().get('id');
        numberOfRecord = '10';
        listOfNumbers = new List<SelectOption>{new SelectOption('5','5'),new SelectOption('10','10'),new SelectOption('20','20'),new SelectOption('50','50'),new SelectOption('100','100'),new SelectOption('200','200')};
        recordLimit = 0;
        
        
        //check if the Simplified data model is enabled for this org
        if (this.simplifiedDataModelIsEnabled){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.REN_CROSSSELL_UPSELL_NOT_FOR_SIMPLIFIED_DATA_MODEL)); 
            return;         
        } else {
            
            mapOfQliToWrapper = new Map<Id, QLIDetailWrapper>();
            lstOfQLI= new List<sObject>();
            Set<Id> setQuoteId = new Set<Id>();       
            lstOfWrapp = new List<QLIDetailWrapper>();
            originalProduct = new List<String>();       
            existingCrossSellIds = new Set<Id>();
            qExtentionPrefix = CHL_Util.quoteExtnNameSpace;
            //List<REN_Renews_To__c> lstOfRLI;
            List<OpportunityLineItem> lstOfOLI;
            setOfOriginalId = new Set<Id>();
            //mapOfOliToOrgId = new Map<Id,Id>();
            mapOfRliIdToQLi = new Map<Id,Id>();
            
            if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && !Test.isRunningTest()) {
               fldMembers = CHL_Util.getFieldSet(qExtentionPrefix+'CHL_Up_Cross_Sell_Detail','QuoteLineItem');
            }
            //String quoteId = ApexPages.currentPage().getParameters().get('id');
            try{
                if(!String.isEmpty(quoteId)){
                    setQuoteId.add(quoteId);
                    lstOfQLI = getQLI(setQuoteId);
                    Set<String> lstOfQFld = new Set<String>{'id','OpportunityId','IsSyncing'};
                    List<sObject> lstOfQ = CHL_QuoteDataAccess.retrieveQuotesById(setQuoteId,lstOfQFld);
                    currentQ = lstOfQ.get(0);
                    Set<String> setOppId = new Set<String>{String.valueOf(currentQ.get('OpportunityId'))};
                    //lstOfRLI= REN_RenewRelationshipDataAccess.getRenewalRelationshipForOppty(setOppId);
                    lstOfOLI = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(setOppId);
                    for(sObject q: lstOfQLI){
                        if(q.get(qExtentionPrefix+'CHL_Cross_Sell_Id__c')!=null){
                            existingCrossSellIds.add((Id)q.get(qExtentionPrefix+'CHL_Cross_Sell_Id__c'));
                        }
                    }
                    mapOfQli = new Map<Id, sObject>(lstOfQLI);
                }
                for(SObject qli:lstOfQLI){
                    //if(setOfOriginalId.contains((Id)qli.get(qExtentionPrefix+'REN_Original_Line_Item_ID__c'))){
                  	if (String.isNotBlank((String)qli.get(qExtentionPrefix+'REN_Renewable_Line_Item__c'))) {
                        originalProduct.add(String.valueOf(qli.getSObject('product2').get('Name'))+' - '+qli.get(qExtentionPrefix+'REN_Renewable_Line_Item__c'));
                        //mapOfOrgIdToQLi.put((Id)qli.get(qExtentionPrefix+'REN_Original_Line_Item_ID__c'),qli.Id);
                        mapOfRliIdToQLi.put((Id)qli.get(qExtentionPrefix+'REN_Renewable_Line_Item__c'),qli.Id);
                    }
                }
                CSM_Admin__c adminSettings = CSM_AdminDataAccess.getCSMAdminInstance();
                if(adminSettings==null || adminSettings.CHL_Cross_sell_Up_sell_Record_Limit__c==null ||adminSettings.CHL_Cross_sell_Up_sell_Record_Limit__c==0){
                    recordLimit = 5000;
                }else{
                    recordLimit = Integer.valueOf(adminSettings.CHL_Cross_sell_Up_sell_Record_Limit__c);
                }
                init(); 
                
            }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg);
                return;
            }
        }
        
        
    }
    
    
   public class TypeValidateWrapper{
       public boolean isQuantityDowngraded{get;set;}
       public boolean isInvalidForUpCrossSell{get;set;}
       public boolean isInvalidForUpsell{get;set;}
       public boolean isInvalidForTypeUpdate{get;set;}
        TypeValidateWrapper(){
            isQuantityDowngraded=false;
            isInvalidForUpCrossSell=false;
            isInvalidForUpsell=false;
            isInvalidForTypeUpdate=false;
        }       
    } 
    
    public class QLIDetailWrapper{
        public sObject qli{get;set;}
        public boolean isUpCrossSell{get;set;}
        
        public List<SelectOption> lstOfOriginalQli{get;set;}
        public String selectedQLIForSell{get;set;}
        public String preTypeVal{get;set;}
        public Decimal preQuantity;
        
        @testVisible   
        //QLIDetailWrapper(sObject qli,set<Id> setOfOriginalId, List<String> originalProduct,String qExtPrefix,Map<Id,sObject> mapOfQli){
        QLIDetailWrapper(sObject qli, List<String> originalProduct,String qExtPrefix,Map<Id,sObject> mapOfQli){
            
            this.qli =qli;
            
            preQuantity = (decimal)qli.get('Quantity');
            
            //if(setOfOriginalId.contains((Id)qli.get(qExtPrefix+'REN_Original_Line_Item_ID__c'))){
            if (String.isNotBlank((String)qli.get(qExtPrefix+'REN_Renewable_Line_Item__c'))) {
                this.isUpCrossSell = false;
            }else{
                this.isUpCrossSell = true; 
                if(qli.get(qExtPrefix+'CHL_Type__c')!=null){
                    preTypeVal = string.valueOf(qli.get(qExtPrefix+'CHL_Type__c')); 
                }
                lstOfOriginalQli = new List<SelectOption>();
                lstOfOriginalQli.add(new SelectOption('','-None-'));
                if(String.valueOf(qli.get(qExtPrefix+'CHL_Cross_Sell_Id__c'))!=null && mapOfQli!=null){
                    //selectedQLIForSell = mapOfQli.get((Id)qli.get(qExtPrefix+'CHL_Cross_Sell_Id__c'))!=null ? String.valueOf(mapOfQli.get((Id)qli.get(qExtPrefix+'CHL_Cross_Sell_Id__c')).getSObject('product2').get('Name'))+' - '+mapOfQli.get((Id)qli.get(qExtPrefix+'CHL_Cross_Sell_Id__c')).get(qExtPrefix+'REN_Original_Line_Item_ID__c'): '';
                    selectedQLIForSell = mapOfQli.get((Id)qli.get(qExtPrefix+'CHL_Cross_Sell_Id__c'))!=null ? String.valueOf(mapOfQli.get((Id)qli.get(qExtPrefix+'CHL_Cross_Sell_Id__c')).getSObject('product2').get('Name'))+' - '+mapOfQli.get((Id)qli.get(qExtPrefix+'CHL_Cross_Sell_Id__c')).get(qExtPrefix+'REN_Renewable_Line_Item__c'): '';
                }
                for(String originalQLI:originalProduct){
                   lstOfOriginalQli.add(new SelectOption(originalQLI,originalQLI));
                }
            }
            
        }
        
    }
    
    public void getInit(){
        preserveTheState();
        init();
    }
    
    public void init(){
        lstOfWrapp = new List<QLIDetailWrapper>();
        for(SObject qli:(List<SObject>)setCon.getRecords()){
          
           if(mapOfQliToWrapper!=null && mapOfQliToWrapper.containsKey((Id)qli.get('Id'))){
               lstOfWrapp.add(mapOfQliToWrapper.get((Id)qli.get('Id')));
           }else{
               //QLIDetailWrapper qliWrapper = new QLIDetailWrapper(qli.clone(true),setOfOriginalId,originalProduct,qExtentionPrefix,mapOfQli);
               QLIDetailWrapper qliWrapper = new QLIDetailWrapper(qli.clone(true), originalProduct,qExtentionPrefix,mapOfQli);
               lstOfWrapp.add(qliWrapper);
           }
        }
    }
    
    public ApexPages.StandardSetController setCon{
    get{
        if(setCon==null){
            //setCon = new ApexPages.StandardSetController(Database.getQueryLocator(CHL_Util.getQueryStringFromFieldSet(qExtentionPrefix+'CHL_Up_Cross_Sell_Detail','QuoteLineItem')+' where quoteId =: quoteId order by '+ qExtentionPrefix+'REN_Original_Line_Item_ID__c limit '+recordLimit));
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(CHL_Util.getQueryStringFromFieldSet(qExtentionPrefix+'CHL_Up_Cross_Sell_Detail','QuoteLineItem')+' where quoteId =: quoteId order by '+ qExtentionPrefix+'REN_Renewable_Line_Item__c limit '+recordLimit));
            
        }
        setCon.setPageSize(Integer.valueOf(numberOfRecord));
        return setCon;
    }set;
    }

    private List<sObject> getQLI(set<Id> quoteId) {
        //String query = 'SELECT '+qExtentionPrefix+'CHL_Cross_Sell_Id__c,'+qExtentionPrefix+'CHL_Type__c,'+qExtentionPrefix+'REN_Renewable_Line_Item__c,'+qExtentionPrefix+'REN_Original_Line_Item_ID__c,Product2.Name FROM QuoteLineItem';//CHL_Util.getQueryStringFromFieldSet(qExtentionPrefix+'CHL_Up_Cross_Sell_Detail','QuoteLineItem');
        String query = 'SELECT '+qExtentionPrefix+'CHL_Cross_Sell_Id__c,'+qExtentionPrefix+'CHL_Type__c,'+qExtentionPrefix+'REN_Renewable_Line_Item__c, Product2.Name FROM QuoteLineItem';//CHL_Util.getQueryStringFromFieldSet(qExtentionPrefix+'CHL_Up_Cross_Sell_Detail','QuoteLineItem');
        return Database.query(query+' where quoteId In: quoteId');
    }
    
    public String validateType(TypeValidateWrapper typeValWrapper)
    {
        string errorMsg='';
        if(typeValWrapper.isInvalidForTypeUpdate){
            errorMsg=Label.CHL_ERR_UPDATE_TYPE;
        }
        if(typeValWrapper.isInvalidForUpsell){
            errorMsg= Label.CHL_ERR_UPSELL_MULTIPLE_PRODUCT;
        }
        if(typeValWrapper.isInvalidForUpCrossSell){
            errorMsg= Label.CHL_ERR_UP_CROSS_SELL_SAME_PRODUCT;
        }
        //Commented purposefully
        /*if(typeValWrapper.isQuantityDowngraded){
            errorMsg= Label.CHL_ERR_UP_CROSS_SELL_DOWNGRADE_NOT_ALLOWED;
        }*/
        return errorMsg;
    }
    
    public pageReference saveUpCrossSellProduct(){
        Savepoint sp = Database.setSavepoint();
        
        try{
            if(mapOfQliToWrapper!=null){
                preserveTheState();
                lstOfWrapp = mapOfQliToWrapper.values(); 
            }
            
            mapOfCrossSell = new Map<String,List<sObject>>();
            typeValWrap.isInvalidForUpCrossSell = false;
            typeValWrap.isInvalidForTypeUpdate = false;
            
            for(QLIDetailWrapper wrapper: lstOfWrapp){           
                //if(!setOfOriginalId.contains((Id)wrapper.qli.get(qExtentionPrefix+'REN_Original_Line_Item_ID__c'))){
                if (String.isBlank((String)wrapper.qli.get(qExtentionPrefix+'REN_Renewable_Line_Item__c'))) {
                    if(wrapper.qli.get(qExtentionPrefix+'CHL_Type__c')!=null){
                        if(wrapper.preTypeVal!=null && !string.valueOf(wrapper.qli.get(qExtentionPrefix+'CHL_Type__c')).equals(wrapper.preTypeVal)){
                              typeValWrap.isInvalidForTypeUpdate = true;
                              break;
                        }
                    
                    if(string.valueOf(wrapper.qli.get(qExtentionPrefix+'CHL_Type__c')).equals(UPSELL)){
                       
                        if(mapOfCrossSell.containsKey(wrapper.selectedQLIForSell)){
                            typeValWrap.isInvalidForUpCrossSell = true;
                            break;
                        }else{
                            if(mapOfUpSell.containsKey(wrapper.selectedQLIForSell)){
                                typeValWrap.isInvalidForUpsell = true;
                                break;
                            }else{
                                if(wrapper.selectedQLIForSell!=null){
                                   mapOfUpSell.put(wrapper.selectedQLIForSell,wrapper.qli);
                                }
                            }
                        }
                    }else if(string.valueOf(wrapper.qli.get(qExtentionPrefix+'CHL_Type__c')).equals(CROSSSELL)){
                        if(wrapper.preTypeVal!=null && !string.valueOf(wrapper.qli.get(qExtentionPrefix+'CHL_Type__c')).equals(wrapper.preTypeVal)){
                            typeValWrap.isInvalidForTypeUpdate = true;
                            break;
                        }
                        if(mapOfUpSell.containsKey(wrapper.selectedQLIForSell)){
                            typeValWrap.isInvalidForUpCrossSell = true; 
                            break; 
                        }else{
                            if(wrapper.selectedQLIForSell!=null){
                                List<sObject> lstOfCrossSellProduct = mapOfCrossSell.get(wrapper.selectedQLIForSell);
                                if(lstOfCrossSellProduct == null){
                                    lstOfCrossSellProduct = new List<sObject>();
                                }
                                lstOfCrossSellProduct.add(wrapper.qli);
                                mapOfCrossSell.put(wrapper.selectedQLIForSell,lstOfCrossSellProduct);
                            }
                        }
                    }
                    }else if(wrapper.preTypeVal!=null){
                        typeValWrap.isInvalidForTypeUpdate = true;
                        break;
                    }            
                }
                if((decimal)wrapper.qli.get('Quantity')!=wrapper.preQuantity){
                    if(((decimal)wrapper.qli.get('Quantity'))>wrapper.preQuantity){
                        if(wrapper.qli.get(qExtentionPrefix +'CHL_Type__c')==null || !string.valueOf(wrapper.qli.get(qExtentionPrefix+'CHL_Type__c')).equals(CROSSSELL)){
                      wrapper.qli.put(qExtentionPrefix+'CHL_Type__c',UPSELL); 
                        }                
                    }
                }
                mapOfQLI.put((Id)wrapper.qli.get('Id'), wrapper.qli);
            }        
           //Identify for CrossSell to any Upsell qli
            for(String crossQLI: mapOfCrossSell.keySet()){
                List<String> listOfId = crossQLI.split(' - ');
                if(listOfId.size()>1){
                    String qliId = mapOfRliIdToQLi.get(listOfId.get(listOfId.size()-1));
                    sObject orgQLI = mapOfQLI.get(qliId);
                    if(orgQLI != null && orgQLI.get(qExtentionPrefix+'CHL_Type__c')!=null && String.valueOf(orgQLI.get(qExtentionPrefix+'CHL_Type__c')).equals('Upsell')){
                       
                       typeValWrap.isInvalidForUpCrossSell = true; 
                       break;
                    }
                }
            }
            
            //Identify for upSell to any CrossSell qli
            for(String crossQLI: mapOfUpSell.keySet()){
                List<String> listOfId = crossQLI.split(' - ');
                if(listOfId.size()>1){
                    String qliId = mapOfRliIdToQLi.get(listOfId.get(listOfId.size()-1));
                    sObject orgQLI = mapOfQLI.get(qliId);
                    if(orgQLI != null && orgQLI.get(qExtentionPrefix+'CHL_Type__c')!=null && existingCrossSellIds.contains((Id)orgQLI.get('Id'))){
                       typeValWrap.isInvalidForUpCrossSell = true; 
                       break;
                    }
                }
            }
            String errorMsg=validateType(typeValWrap);
            if(String.isNotBlank(errorMsg)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,errorMsg));
                    init();
                    return null;
                }       
            updateUPCrossSell();
            if(currentQ!=null){
                PageReference pr = new PageReference('/'+currentQ.Id);
                return pr;
            }else{
                return null;
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            return null;
        }       
    }
    
    public void updateUPCrossSell(){ 
        Map<sObject,sObject> mapOfUpsellOrgProduct = new Map<sObject,sObject>();
        Map<sObject,List<sObject>> mapOfCrossSellOrgProduct = new Map<sObject,List<sObject>>();
        Map<Id,sObject> mapOfQliToDelete = new Map<Id,sObject>();
        //Map<Id,Id> mapOrgIdToBeUpdatedOLI = new Map<Id,Id>();
        for(String orgQLIUpSell: mapOfUpSell.keySet()){
            sObject qli = mapOfUpSell.get(orgQLIUpSell);
            List<String> listOfId = orgQLIUpSell.split(' - ');
            if(listOfId.size()>1){
                String qliId = mapOfRliIdToQLi.get(listOfId.get(listOfId.size()-1));
                sObject orgQLI = mapOfQLI.get(qliId);
                /*if(currentQ != null && (boolean)currentQ.get('isSyncing')){
                    //mapOrgIdToBeUpdatedOLI.put((Id)qli.get(qExtentionPrefix+'REN_Original_Line_Item_ID__c'),(Id)orgQLI.get(qExtentionPrefix+'REN_Original_Line_Item_ID__c'));
                    mapOrgIdToBeUpdatedOLI.put((Id)qli.get(qExtentionPrefix+'REN_Renewable_Line_Item__c'),(Id)orgQLI.get(qExtentionPrefix+'REN_Renewable_Line_Item__c')); 
                }*/
                //qli.put(qExtentionPrefix+'REN_Original_Line_Item_ID__c',orgQLI.get(qExtentionPrefix+'REN_Original_Line_Item_ID__c'));
                qli.put(qExtentionPrefix+'REN_Renewable_Line_Item__c',orgQLI.get(qExtentionPrefix+'REN_Renewable_Line_Item__c'));
                mapOfQliToDelete.put((Id)orgQLI.get('Id'),orgQLI);
            }            
        }
        List<sObject> lstToUpsellUpdate = new List<sObject>();
        for(QLIDetailWrapper wrapper: lstOfWrapp){
            if(!mapOfQliToDelete.containsKey((Id)wrapper.qli.get('Id'))){
                lstToUpsellUpdate.add(wrapper.qli); 
            }
        }        
        for(String crossQLI: mapOfCrossSell.keySet()){
            List<String> listOfId = crossQLI.split(' - ');
            List<sObject> qli = mapOfCrossSell.get(crossQLI);
            if(listOfId.size()>1){
                String qliId=mapOfRliIdToQLi.get(listOfId.get(listOfId.size()-1));
                sObject orgQLI = mapOfQLI.get(qliId);
                for(sObject obj: qli){
                    obj.put(qExtentionPrefix+'CHL_Cross_Sell_Id__c',orgQLI.get('Id'));
                }
            }
        }
        if(lstToUpsellUpdate!=null && !lstToUpsellUpdate.isEmpty()){
            //CHL_QuoteLineItemDataAccess.updateQuoteLineItem(new set<String>{qExtentionPrefix+'CHL_Cross_Sell_Id__c',qExtentionPrefix +'CHL_Type__c',qExtentionPrefix+'REN_Original_Line_Item_ID__c','Quantity'}, lstToUpsellUpdate);
            CHL_QuoteLineItemDataAccess.updateQuoteLineItem(new set<String>{qExtentionPrefix+'CHL_Cross_Sell_Id__c',qExtentionPrefix +'CHL_Type__c','Quantity'}, lstToUpsellUpdate);
        }        
        /*if(!mapOrgIdToBeUpdatedOLI.isEmpty()){
            updateOliOriginalId(mapOrgIdToBeUpdatedOLI);
        }*/
        if(mapOfQliToDelete!=null && !mapOfQliToDelete.isEmpty()){
            CHL_QuoteLineItemDataAccess.deleteQuotesLineItems(new list<Sobject>{mapOfQliToDelete.values()});
        }
    }
    public pageReference cancelUpCrossSellProduct(){
        if (this.simplifiedDataModelIsEnabled) {
            PageReference pr = new PageReference('/'+quoteId);
            return pr;
        } else {
            if(currentQ!=null){
                PageReference pr = new PageReference('/'+currentQ.Id);
                return pr;
            }else{
                return null;
            }
        }
    }
     
    /**this will fetch the set of records to display on the next page */
    public void nextPage(){
       preserveTheState();
       setCon.next();
       init();   
    }
    
     /**this will fetch the set of records to display on the previous page */
    public void previousPage(){
       preserveTheState();
       setCon.previous();
       init();
    }
    
    public void moveToFirstPage(){
       preserveTheState();
       setCon.first();
       init();
    }
    
    public void moveToLastPage(){
       preserveTheState();
       setCon.last();
       init();
    }
    
     /** indicates whether there are more records after the current page set.*/
     public Boolean hasNext {
     get {
       return setCon!=null?setCon.getHasNext():false;
     }
     set;
     }
     
     /** indicates whether there are more records before the current page set.*/
     public Boolean hasPrevious {
     get {
       return setCon!=null?setCon.getHasPrevious():false;
     }
     set;
     }
     
     /** returns the page number of the current page set*/
     public Integer pageNumber {
     get {
       return setCon.getPageNumber();
     }
     set;
     }
    
     /** return total number of pages for page set*/
     Public Integer getTotalPages(){
         Decimal totalSize = setCon.getResultSize();
         Decimal pageSize = setCon.getPageSize();
         Decimal pages = totalSize/pageSize;
         return (Integer)pages.round(System.RoundingMode.CEILING);
     }
     

     private void preserveTheState(){
         for(QLIDetailWrapper wrap: lstOfWrapp){
             mapOfQliToWrapper.put((Id)wrap.qli.get('Id'),wrap);
         }
     }
     
}