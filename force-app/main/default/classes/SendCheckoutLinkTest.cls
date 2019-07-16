@IsTest public with sharing class SendCheckoutLinkTest 
{
   
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
        TestdataUtility.insertSiteDetails();
         
        TestdataUtility.insertContacts();
        TestdataUtility.insertOpportunity();
        TestdataUtility.insertSub();
    }
     @IsTest public static void test1() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,con.Id);
         Test.startTest();
         PageReference pageRef = Page.CBNewCustomerUtil;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('link_url','https://cbtest1.chargebee.com');
         pageRef.getParameters().put('uid','abcdef');
         pageRef.getParameters().put('opp_id',opt.Id);
         pageRef.getParameters().put('domain','cbtest1');
         SendCheckoutLink scl = new SendCheckoutLink();
         scl.fetchCusMeta();
         scl.send();
         scl.redirectToError('err','obj');
         Integer callouts = Limits.getCallouts();
         system.assertequals(0,callouts);
     }
}