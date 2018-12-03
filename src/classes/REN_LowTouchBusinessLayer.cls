public with sharing abstract class REN_LowTouchBusinessLayer {

	public abstract String getResponse(Set<String> oppIdSet);
	public abstract String postResponse(Set<String> oppIdSet, REN_LowTouchPayLoad payLoad);
}