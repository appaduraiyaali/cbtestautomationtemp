@IsTest public with sharing class RedirectToChargebeeTest{

    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         
         TestdataUtility.insertSub();
      
    }
    @IsTest public static void testRedirect(){
        chargebeeapps__CB_Subscription__c sub = [select Id,Name,chargebeeapps__CB_Site__c,
                                                  chargebeeapps__CB_Subscription_Id__c,chargebeeapps__Company__c
                                                 from chargebeeapps__CB_Subscription__c where chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD'];
         Test.startTest();
        ApexPages.currentPage().getParameters().put('sub_id',sub.Id);
        RedirectToChargebee redirect = new RedirectToChargebee();
        PageReference p = redirect.setSubId();
        string url = p.getUrl();
        redirect.back();
        Test.stopTest();
        system.assert(url.contains('/admin-console/subscriptions/'));
        
    }
}