@isTest
public class REN_PoRejectOptionCompCtrlTest {
    public  static testMethod void testFieldMappings()
    {
        REN_PoRejectOptionCompCtrl PoReject=new REN_PoRejectOptionCompCtrl();
        List <REN_Field_Mappings__c> fieldMappingList;        
        
        PoReject.getpickListvalue();
        system.debug(PoReject.renewalPicklist);
        PoReject.renewalPicklist[0].isSelected=True;
        PoReject.renewalPicklist[0].displayName='Test';
        PoReject.saveUpdatedStatus();        
        system.assertEquals(PoReject.fieldMappingList[0].REN_Default_Value__c, 'Test');
        PoReject.renewalPicklist[0].isSelected=True;
        PoReject.renewalPicklist[0].displayName='TestField';
        PoReject.saveUpdatedStatus();        
        PoReject.getpickListvalue();
        system.assertEquals(PoReject.fieldMappingList[0].REN_Default_Value__c, 'TestField');
        PoReject.renewalPicklist[0].isSelected=False;
        PoReject.renewalPicklist[0].displayName='TestField';
        PoReject.saveUpdatedStatus();        
        PoReject.Cancel();
    }
    
    

}