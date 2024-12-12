@isTest(SeeAllData=true)
public class RHX_TEST_npe03_Recurring_Donation {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM npe03__Recurring_Donation__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new npe03__Recurring_Donation__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}