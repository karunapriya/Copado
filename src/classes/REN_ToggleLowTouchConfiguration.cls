/**
 * Created Date    : Feb 20, 2017
 * Developed By    : Dheeraj, Comity Designs, Inc.
 *
 * Function      : @description -  wrapper for Low touch custom setting configuration
 * Support Email   : email
 * Version      : 1.0
 *
 * Modification Log
 *
 * Developer Name      User Story        Date      Version       Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj          US2032        Feb 20, 2017     1.1          wrapper for Low touch custom setting configuration
 *
 */
public with sharing class REN_ToggleLowTouchConfiguration{
    
    @AuraEnabled
    public boolean isLiveChatActive{get;set;}
  
    @AuraEnabled
    public boolean isDocuSignActive{get;set;}
  
    @AuraEnabled
    public boolean isFileUploadActive{get;set;}
    
    @AuraEnabled
    public boolean isPaymentActive{get;set;}
}