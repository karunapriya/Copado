/**
 * Created Date     : Dec 5, 2016
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
 * Dheeraj                  US1836              Dec 5, 2016         1.1                 @description
 *
 */
public with sharing class CHL_SegmentEventHandler {

    
 private static CHL_SegmentEventHandler segment;
    
    private CHL_SegmentEventHandler(){}
    
    public static CHL_SegmentEventHandler newInstance(){
        if(segment == null){
            segment = new CHL_SegmentEventHandler();            
        }
        return segment;
    }
        
    public String getEventStructure(WrapperClass wrapper){           
       String response;         
       if(wrapper!=null){
           response =  (JSON.serialize(wrapper)); 
       }
       System.debug('Response > '+response);
       return response;
    }
   
    public class WrapperClass{
        public String userId{get;set;}
        public String event{get;set;}
        public String type{get;set;}
        public Properties properties{get;set;}
        
        public WrapperClass(String eventName,String action ,String category, String label, Integer value, String accType, String userName){
            properties = new Properties();
            userId = 'D_SOURCE_123';
            event = eventName;
            type='track';
            properties.TENANT_ID = UserInfo.getOrganizationId();
            properties.TENANT_NAME = UserInfo.getOrganizationName();
            if(accType!=null){
                properties.ACCOUNT_TYPE = accType;
                properties.ACCOUNT_ID='';
                properties.ACCOUNT_NAME = '';
                properties.USER_ID = '';
                properties.USER_NAME= '';
            }else{ 
                if(userName == null){
                    properties.USER_ID = UserInfo.getUserId();
                    properties.USER_NAME = (String.isNotBlank(UserInfo.getFirstName())?UserInfo.getFirstName():'') +' '+ (String.isNotBlank(UserInfo.getLastName())?UserInfo.getLastName():'');
                }else{
                    // This code will run for forgot password where we don't have user context.
                    List<User> listOfUser = [Select id,FirstName, LastName from User where userName = :userName];
                    if(listOfUser!=null && !listOfUser.isEmpty()){
                        properties.USER_ID= listOfUser.get(0).id;
                        properties.USER_NAME= (String.isNotBlank(listOfUser.get(0).FirstName)?listOfUser.get(0).FirstName:'') +' '+ (String.isNotBlank(listOfUser.get(0).LastName)?listOfUser.get(0).LastName:'');
                    }else{
                        properties.USER_ID= null;
                        properties.USER_NAME=null;
                    }
                }
            }
            properties.category= category;
            properties.label= label;
            properties.value= value;
            
        }
        
    }
    
    public class Properties{
        public String TENANT_ID {get;set;}
        public String TENANT_NAME{get;set;}
        public String ACCOUNT_ID{get;set;}
        public String ACCOUNT_TYPE{get;set;}
        public String ACCOUNT_NAME{get;set;}
        public String USER_ID{get;set{
            USER_ID = value;
            if(String.isNotBlank(value) && String.isBlank(ACCOUNT_TYPE)){
                List<User> listOfUser = [Select id,Contact.Account.Id,ContactId,Contact.Account.Name,Contact.Account.CHL_Partner_Account_Type__c from User where Id =: value];
                if(listOfUser!=null && listOfUser.size()>0 && String.isNotBlank(''+listOfUser.get(0).ContactId)){
                    this.ACCOUNT_ID = listOfUser.get(0).Contact.Account.Id;
                    this.ACCOUNT_NAME = listOfUser.get(0).Contact.Account.Name;
                    this.ACCOUNT_TYPE = listOfUser.get(0).Contact.Account.CHL_Partner_Account_Type__c;
                }
            }
          }
        }
        public String USER_NAME{get;set;}
        public String category{get;set;}
        public String label{get;set;} 
        public Integer value{get;set;}
   }
   
   public class BatchUpload{
       List<WrapperClass> batch{get;set;}
       
       public BatchUpload(List<WrapperClass> wrapEvent){
           batch = wrapEvent;
       }
   }   
  
}