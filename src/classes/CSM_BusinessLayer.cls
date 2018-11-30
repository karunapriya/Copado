public with sharing abstract class CSM_BusinessLayer {

	protected CSM_CustomGridInputWrapper inputWrapper;
	public CSM_BusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
		this.inputWrapper = inputWrapper;
	}
	public abstract CSM_GridResponseWrapper retrieveSObjectWrapperList();
}