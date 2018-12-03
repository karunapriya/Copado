@isTest
private class AAA_CompilationIssueTest {

    static testMethod void test_UserDetail() {
        List<User> userList = AAA_CompilationIssue.currentUserDetails;
        system.assert(userList != null);
    }
}