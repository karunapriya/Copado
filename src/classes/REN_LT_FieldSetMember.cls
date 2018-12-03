public class REN_LT_FieldSetMember {

    @AuraEnabled
    public String fieldPath { get;set; }

    @AuraEnabled
    public String label { get;set; }

    @AuraEnabled
    public Boolean required { get;set; }

    @AuraEnabled
    public String type { get; set; }


    public REN_LT_FieldSetMember(Schema.FieldSetMember f) {
        //this.DBRequired = f.DBRequired;
        this.fieldPath = f.fieldPath;
        this.label = f.label;
        this.required = f.required;
        this.type = '' + f.getType();
        System.debug(f + '\n~~~~Field in FieldSet: ' + this);
    }


    public static List<REN_LT_FieldSetMember> getFields(String typeName, String fsName,Map<String,String> mapOfTranslatedLabels) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        System.debug(fsName +'\n\n4~~~~typeName:' + typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<REN_LT_FieldSetMember> fieldSetMemberList = new List<REN_LT_FieldSetMember>();
        System.debug(fsMap +'\n\n4~~~~FieldS:' + typeName);
        for (Schema.FieldSetMember f: fieldSet) {
            REN_LT_FieldSetMember member = new REN_LT_FieldSetMember(f);
            member.label = mapOfTranslatedLabels != null && mapOfTranslatedLabels.containsKey(f.fieldPath) ? mapOfTranslatedLabels.get(f.fieldPath) : f.label;
            fieldSetMemberList.add(member);
        }
        return fieldSetMemberList;
    }
    
    /*public static ValidationRules getValidationRules(List<REN_LT_FieldSetMember> fieldSetMemberList) {
    	ValidationRules vRule = new ValidationRules();
		for (REN_LT_FieldSetMember fsMember: fieldSetMemberList) {
			       // this.fieldPath = f.fieldPath;
			       // this.label = f.label;
			       // this.required = f.required;
			       // this.type = '' + f.getType();
			if(fsMember.required){
				vRule.addValidation(fsMember.fieldPath, 'required', true, String.format(System.Label.REN_LBL_FIELD_IS_REQUIRED, new String[] {fsMember.label}));
			}
			if(fsMember.type == 'EMAIL'){
				vRule.addValidation(fsMember.fieldPath, 'email', true, String.format(System.Label.CHL_Valid_Email, new String[] {fsMember.label}));
			}
		}
        return vRule;
    }*/
    
    public class ValidationRules{
	    @AuraEnabled
	    public String errorLabelContainer { get;set; }
    	
	    @AuraEnabled
	    public String wrapper { get;set; }
    	
	    /*@AuraEnabled
	    public String submitHandler { get;set; }*/
    	
	    /*@AuraEnabled
	    public String invalidHandler { get;set; }*/
    	
	    @AuraEnabled
	    public Map<String, Map<String, Object>> rules { get;set; }
    	
	    @AuraEnabled
	    public Map<String, Map<String, String>> messages { get;set; }
	    
	    public ValidationRules(){
	    	errorLabelContainer = '#error-message';//Div tag ID where you want to show all messages
	    	wrapper = 'li'; //Set blank for displaying messages with each field.
	    	rules = new Map<String, Map<String, Object>>();
	    	messages = new Map<String, Map<String, String>>();
	    }
	    
	    /*public void addValidation(String fieldName, String validationKey, Object validationValue, String errorMessage){
	    	if(!rules.containsKey(fieldName)){
	    		rules.put(fieldName, new Map<String, Object>());
	    		messages.put(fieldName, new Map<String, String>());
	    	}
	    	rules.get(fieldName).put(validationKey, validationValue);
	    	messages.get(fieldName).put(validationKey, errorMessage);
	    }*/
    }
    
}