@isTest
private class PreviewController_Test {

    static testMethod void test() {
    
        PageReference pageRef = Page.Preview;
        Test.setCurrentPage(pageRef);
        
        Contact ma = new Contact ();
        ma.LastName ='Lopes';
        ma.Phone = '+351 Portugal';
       
        insert ma;
        
        PreviewController map_controller = new PreviewController(new ApexPages.standardController(ma));
    }
}