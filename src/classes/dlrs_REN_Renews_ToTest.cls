/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_REN_Renews_ToTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_REN_Renews_ToTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new REN_Renews_To__c());
    }
}