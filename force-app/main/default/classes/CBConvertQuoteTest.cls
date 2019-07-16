@IsTest public with sharing class CBConvertQuoteTest 
{
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c sites = TestdataUtility.getSites();
         
        Contact[] contacts = TestdataUtility.insertContacts();
         Opportunity[] opt = TestdataUtility.insertOpportunity();
         TestdataUtility.insertProducts();
         TestdataUtility.insertCoupons();
         TestdataUtility.insertSub();
        chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites.Id,contacts[0].Id);
        TestdataUtility.insertQuote();
        
        for(Contact c:contacts){
            TestdataUtility.insertContactSite(sites.Id,c.Id);
        }
        
         
    }
    @IsTest public static void testConvert() 
     {
         
         String cbId='1';
         chargebeeapps__CB_Quote__c quote= [select Id,Name,chargebeeapps__CB_Quote_Id__c from chargebeeapps__CB_Quote__c where chargebeeapps__CB_Quote_Id__c=:cbId];
         Test.startTest();
         PageReference ref = Page.ConvertQuote;
         test.setCurrentPageReference(ref);
         System.debug('quote id - '+quote.Id);
         ref.getParameters().put('id',quote.Id);
         CBConvertQuote ceq = new CBConvertQuote();
         Test.setMock(HttpCalloutMock.class, new MockEstSubResponse1Generator());
         ceq.populate();
         Test.stopTest();
     }
     
     @IsTest public static void testupdateConvert() 
     {
         
         String cbId='2';
         chargebeeapps__CB_Quote__c quote= [select Id,Name,chargebeeapps__CB_Quote_Id__c from chargebeeapps__CB_Quote__c where chargebeeapps__CB_Quote_Id__c=:cbId];
         Test.startTest();
         PageReference ref = Page.ConvertQuote;
         test.setCurrentPageReference(ref);
         System.debug('quote id - '+quote.Id);
         ref.getParameters().put('id',quote.Id);
         CBConvertQuote ceq = new CBConvertQuote();
         Test.setMock(HttpCalloutMock.class, new MockUpSubResponseGenerator());
         ceq.populate();
         Test.stopTest();
     }


}