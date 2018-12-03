global with sharing class OLITriggerInvocationHandler extends SS_FeatureInvocation.FeatureHandler {
    
    global override void featureInvocation(Object parameters) {
        OpportunityLineItemTriggerHandlerHelper.validateFieldsUpdatesBeforeUpdate(parameters);
    }
}