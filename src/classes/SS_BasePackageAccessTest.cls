/**
 * Created Date		: Nov 15, 2016
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: US1686 & US1705. Test coverage for global access class.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US1686 & US1705			Nov 15, 2016	1.1					Test coverage for global access class
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */
@isTest
private class SS_BasePackageAccessTest {

    static testMethod void myUnitTest() {
        SS_BasePackageAccess.getInstance().paramJson = '{"sObjIds":null,"className":"CHL_QuoteExtension","methodName":"markPrimaryQuote"}';
        system.assert(SS_BasePackageAccess.getInstance().paramJson!=null);
        SS_BasePackageAccess.getInstance().invoke();
        
        SS_BasePackageAccess.getInstance().paramJson = '{"sObjIds":null,"className":"CHL_QuoteExtension","methodName":"createDistributorQuotesAndQlis"}';
        system.assert(SS_BasePackageAccess.getInstance().paramJson!=null);
        SS_BasePackageAccess.getInstance().invoke();
    }
}