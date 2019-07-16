@IsTest public with sharing class CBCancelSubscriptionTest
{
    
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();        
         TestdataUtility.insertSiteDetails();         
         Contact[] contacts = TestdataUtility.insertContacts();         
         chargebeeapps__CB_Subscription__c subs = TestdataUtility.insertSub();
         
    }
     @IsTest public static void testCancel() 
     {
     chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
     chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
     string subid = sub.Id;
     Test.startTest();
     PageReference pageRef = Page.Cancel_subscription;
     test.setCurrentPageReference(pageRef);
     pageRef.getParameters().put('sub_id',subid);//a0J2800000JDBbb
     Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
     CBCancelSubscription cbu = new CBCancelSubscription();
     Test.setMock(HttpCalloutMock.class, new MockCancelResponseGenerator());
     cbu.show1();
     cbu.CancelSub();
     Test.stopTest();
     system.assertequals(cbu.showPopup,false);
     }
     @IsTest public static void testImmediately() 
     {
     chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
     chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
     string subid = sub.Id;
     Test.startTest();
     PageReference pageRef = Page.Cancel_subscription;
     test.setCurrentPageReference(pageRef);
     pageRef.getParameters().put('sub_id',subid);
     Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
     CBCancelSubscription cbu1 = new CBCancelSubscription();
     Test.setMock(HttpCalloutMock.class, new MockCancelResponseGenerator());
     cbu1.show1();
     cbu1.save();
     Integer callouts = Limits.getCallouts();
     Test.stopTest();
     system.assertequals(2,callouts);
     }
     @IsTest public static void testEot() 
     {
      chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
     chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
     string subid = sub.Id;
     Test.startTest();
     PageReference pageRef = Page.Cancel_subscription;
     test.setCurrentPageReference(pageRef);
     pageRef.getParameters().put('sub_id',subid);
     Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
     CBCancelSubscription cbu = new CBCancelSubscription();
     Test.setMock(HttpCalloutMock.class, new MockCancelResponseGenerator());
     cbu.show2();
     cbu.save();
     Integer callouts = Limits.getCallouts();
     Test.stopTest();
     system.assertequals(2,callouts);
     }
     
     
}