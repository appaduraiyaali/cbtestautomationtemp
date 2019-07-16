@isTest
private class TestUpdateInvoiceDueCount {
  
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
        TestdataUtility.insertSiteDetails();
            
        chargebeeapps__CB_Subscription__c subs = TestdataUtility.insertSub();
        TestdataUtility.insertInvoices(subs.Id);
    }
    @isTest static void TestUpdateInvoiceDueCount() {
        chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
        
        chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
        chargebeeapps__CB_Invoice__c getInv = [select Id,Name,chargebeeapps__SubscriptionId__c from chargebeeapps__CB_Invoice__c where chargebeeapps__SubscriptionId__c=:sub.Id];
                                               
        //getInv.id = getInv.Id;
        getInv.chargebeeapps__PONumber__c = '012345';
        Test.startTest();
        update getInv;
        Test.stopTest();
        system.assertEquals(getInv.chargebeeapps__PONumber__c,'012345');
    }
    
}