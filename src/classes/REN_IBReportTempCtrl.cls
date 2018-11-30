public class REN_IBReportTempCtrl {
    public String textVal {get; set;}
    public PageReference saveTextVal(){
        System.debug('Total textVal --> ' +textVal.length());
        System.debug('Heap - '+System.Limits.getHeapSize());
        return null;
    }
}