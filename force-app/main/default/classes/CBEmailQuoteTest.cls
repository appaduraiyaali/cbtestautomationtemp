@IsTest public with sharing class CBEmailQuoteTest 
{
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c sites = TestdataUtility.getSites();
         
        Contact[] contacts = TestdataUtility.insertContacts();
         Opportunity[] opt = TestdataUtility.insertOpportunity();
        chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites.Id,contacts[0].Id);
        chargebeeapps__CB_Subscription__c subs = TestdataUtility.insertSub();
        List<chargebeeapps__CB_Quote__c> quote = TestdataUtility.insertQuote();
        System.debug('quote - '+quote);
         
         
    }
    @IsTest public static void testEmail() 
     {
         
         String cbId='1';
         chargebeeapps__CB_Quote__c quote= [select Id,Name,chargebeeapps__CB_Quote_Id__c from chargebeeapps__CB_Quote__c where chargebeeapps__CB_Quote_Id__c=:cbId];
         Test.startTest();
         PageReference ref = Page.Email_quote;
         test.setCurrentPageReference(ref);
         System.debug('quote id - '+quote.Id);
         ref.getParameters().put('id',quote.Id);
         CBEmailQuote ceq = new CBEmailQuote();
         Test.setMock(HttpCalloutMock.class, new Mocks.MockQuoteAcceptanceLinkGenerator());
         ceq.send();
         Test.stopTest();
     }


}