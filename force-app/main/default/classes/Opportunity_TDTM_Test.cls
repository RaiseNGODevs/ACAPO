@isTest
public class Opportunity_TDTM_Test {
    @isTest
    public static void test(){
        npsp__Trigger_Handler__c triggerHandler = new npsp__Trigger_Handler__c();
        triggerHandler.Name = 'Opportunity_TDTM';
        triggerHandler.npsp__Class__c = 'Opportunity_TDTM';
        triggerHandler.npsp__Object__c = 'Opportunity';
        triggerHandler.npsp__Trigger_Action__c = 'BeforeInsert';
        triggerHandler.npsp__Active__c = true;
        triggerHandler.npsp__Load_Order__c = 0;
        triggerHandler.npsp__Asynchronous__c = false;
        insert triggerHandler;
        
        Contact c = new Contact(lastname = 'test');
        insert c;
        
        Test.startTest();
        
        insert new Opportunity(
        	name = 'test',
            amount = 123,
            closeDate = Date.today(),
            StageName = 'Posted',
            npsp__Primary_Contact__c = c.id
        );
        
        Test.stopTest();
    }
}