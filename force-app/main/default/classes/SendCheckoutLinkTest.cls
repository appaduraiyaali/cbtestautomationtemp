@IsTest public with sharing class SendCheckoutLinkTest 
{
   
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
        TestdataUtility.insertSiteDetails();
        
        TestdataUtility.insertContacts();
        chargebeeapps__CB_Sites__c site = TestdataUtility.getSite();
        Contact validcontact=TestdataUtility.getValidContact();
        TestdataUtility.associateContactToSite(site.Id,validcontact.Id);
        TestdataUtility.insertOpportunity();
        TestdataUtility.insertSub();
    }
     @IsTest public static void test1() 
     {
         
         Contact con = TestdataUtility.getValidContact();
         
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         
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