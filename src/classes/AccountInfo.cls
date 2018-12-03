@RestResource(urlMapping='/updateAccountDescription/*')  
global with sharing class AccountInfo
{      
     @HttpPost    
     global static String updateAccountDetails()     
     {          
          System.debug('Response returened');
            List<String> opptyFieldList = new List<String>{'Description'};
           List<Opportunity> opptyList = [SELECT Name, Description FROM Opportunity WHERE Name = 'new SO' Limit 1];
           opptyList[0].Description = 'Test';
           CSM_Util.checkCRUD_FLS('Opportunity', opptyFieldList, CSM_Constants.DML_OPERATION_UPDATE);
           update opptyList;
          
          return 'Hi, Opportunity Updated Successfully using REST API';        
     }
}