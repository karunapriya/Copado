Public class createPONPRR {
    private static List<String> OPPORTUNITY_STAGES = new List<String>{'Not Contacted',
                                                        'Contacted',
                                                        'Quote Request',
                                                        'In Review',
                                                        'Quote Completed',
                                                        'Quote Delivered',
                                                        'Customer Commitment',
                                                        'PO Received'};
                                                        
     public void createPartnerOpportunity(Integer parterOpptyPerMO){ 
        List<Contact> contactList = [Select Id, AccountId, Account.Name From Contact Where AccountId in (Select Id from Account where isPartner=true)];
        List<CHL_Partner_Opportunity__c> partnerOpptyList = new List<CHL_Partner_Opportunity__c>();
        Map<Id, Opportunity> renewOpptyMap = new Map<Id, Opportunity>([Select Id, name,
                                                StageName, AccountId, 
                                                Amount, CloseDate, REN_Earliest_Expiration_Date__c,
                                                Probability,
                                                (Select Id From Renew_To__r)
                                             From Opportunity 
                                             Where Name Like 'LK- Flipkart- Oppty%' AND REN_Is_CLM_Renewal__c=:true]);
        integer OptyCount = 0;          
        for(Opportunity oppty : renewOpptyMap.values()){
            for(Integer i=0; i<parterOpptyPerMO; i++){
                Integer randomContactIndex = Math.round(Math.random()*(contactList.size() - 1));
                if(randomContactIndex <= 0){
                    randomContactIndex = 0;
                }
                Contact randomContact1 = contactList.get(randomContactIndex);
                Contact randomContact2 = contactList.get(randomContactIndex);
                Integer randomNo = Math.round(Math.random()*7);
                CHL_Partner_Opportunity__c partnerOppty = new CHL_Partner_Opportunity__c();
                string poName = oppty.Name + ' - ' + randomContact1.Account.Name;
                partnerOppty.Name = poName.length() > 80 ? poName.substring(0,79) : poName; 
                //partnerOppty.ownerId = ChannelUser.Id;    
                partnerOppty.CHL_Opportunity__c = oppty.Id;
                partnerOppty.CHL_Partner_Account_1__c = randomContact1.AccountId;
                partnerOppty.CHL_Partner_Account_2__c = randomContact2.AccountId;
                partnerOppty.CHL_Partner_Account_1_Contact__c = randomContact1.Id;
                partnerOppty.CHL_Partner_Account_2_Contact__c = randomContact2.Id;
                //partnerOppty.CHL_Partner_Account_1_Type__c = 'Reseller';
                //partnerOppty.CHL_Partner_Account_2_Type__c = 'Distributor';
                partnerOppty.CHL_Incumbent__c = Math.mod(i, 2)==0?true:false;
                partnerOppty.CHL_Amount__c = oppty.Amount;
                partnerOppty.CHL_Close_Date__c = oppty.CloseDate;
                partnerOppty.CHL_Probability__c = oppty.Probability;
                partnerOppty.CHL_Sales_Stage__c = OPPORTUNITY_STAGES[randomNo];
                /*if(i == 0 && OptyCount == ((OptyCount/2)*2)) {
                    partnerOppty.CHL_Syncing__c = 'To Master Opportunity';
                } else if(i == 0 && OptyCount != ((OptyCount/2)*2)) {
                    partnerOppty.CHL_Syncing__c = 'From Master Opportunity';
                }*/
                partnerOppty.CHL_Expiration_Date__c = Date.newInstance(2016, randomContactIndex+1, 16);
                partnerOpptyList.add(partnerOppty);
            }
            OptyCount = OptyCount + 1;
        }
        insert partnerOpptyList;
        createPartnerRenewalRelationship(partnerOpptyList, renewOpptyMap);
        //createQuotes(partnerOpptyList,2,renewOpptyMap);
    }
    
    private void createPartnerRenewalRelationship(List<CHL_Partner_Opportunity__c> partnerOpptyList, Map<Id, Opportunity> renewOpptyMap){
        List<CHL_Partner_Renewal_Relationship__c> prrList = new List<CHL_Partner_Renewal_Relationship__c>();
        for(CHL_Partner_Opportunity__c partnerOppty : partnerOpptyList){
            List<REN_Renews_To__c> renewalRelationList = renewOpptyMap.get(partnerOppty.CHL_Opportunity__c).Renew_To__r;
            for(REN_Renews_To__c renRelation : renewalRelationList){
                CHL_Partner_Renewal_Relationship__c partnerRR = new CHL_Partner_Renewal_Relationship__c(
                                                                CHL_Partner_Opportunity__c = partnerOppty.Id,
                                                                CHL_Renewal_Relationship__c = renRelation.Id);
                prrList.add(partnerRR);
            }
        }
        insert prrList;
    }
}