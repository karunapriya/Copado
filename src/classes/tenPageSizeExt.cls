public class tenPageSizeExt {
    public List<Opportunity> selected{get; set;}
    public tenPageSizeExt.tenPageSizeExt(ApexPages.StandardSetController controller){
        selected = [SELECT stageName, closeDate, name from Opportunity LIMIT 100];
    }
}