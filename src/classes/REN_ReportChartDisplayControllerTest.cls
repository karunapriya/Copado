@isTest(SeeAllData=true)
private class REN_ReportChartDisplayControllerTest {
	
	static testMethod void myUnitTest() {
		REN_ReportChartDisplayController cntrl = new REN_ReportChartDisplayController();
		List<Folder> folderListTest;
		list<ID> leftSelectedOptionsTest = new list<ID>();
		list<ID> rightSelectedOptionsTest = new list<ID>();
		cntrl.selectReports();	
		cntrl.leftPickList = new list<SelectOption>();
		cntrl.rightPickList = new list<SelectOption>();
		cntrl.leftSelectedOptions = new list<ID>();
		cntrl.rightSelectedOptions = new list<ID>();
		
		folderListTest =  [select id,Name from Folder where Name='CSM Templates'];
		
		List<Report> reportList = [SELECT id, Name FROM Report WHERE OwnerId in (SELECT id FROM folder where developerName = 'CSM_Reports') and name != null order by name limit 10];
		system.assert(reportList != null);
		
		for(Integer i=0; i <= reportList.size()-1;i++ ){
			if(i > 1){
				cntrl.leftPickList.add(new SelectOption(reportList[i].id,reportList[i].Name)); 
				if(Math.mod(i, 2) == 0){
					leftSelectedOptionsTest.add(reportList[i].id); 
				}
			}else{
				cntrl.rightPickList.add(new SelectOption(reportList[0].id,reportList[i].Name));
				rightSelectedOptionsTest.add(reportList[i].id);
			}
			
		}
		cntrl.rightSelectedOptions.addAll(rightSelectedOptionsTest);
		cntrl.moveRightToLeft();
		cntrl.leftSelectedOptions.addAll(leftSelectedOptionsTest);
		cntrl.moveLeftToRight();
		cntrl.rightSelectedOptions = leftSelectedOptionsTest;
		cntrl.moveUp();
		cntrl.rightSelectedOptions = leftSelectedOptionsTest;
		cntrl.moveDown();
		cntrl.saveUserPreferences();
		boolean b= cntrl.isReportInFolder;
		b= cntrl.isSelectedReportsInFolder;
		cntrl.getUserPref();
	
	}
	
}