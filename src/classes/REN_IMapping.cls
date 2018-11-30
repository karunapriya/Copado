public interface REN_IMapping {

	List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey);
	List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey, Map<Id, Id> sourceToRenewalMap);
	Map<Id, SObject> applyMappingMap(List<SObject> objectList, String toFromObjectKey);
}