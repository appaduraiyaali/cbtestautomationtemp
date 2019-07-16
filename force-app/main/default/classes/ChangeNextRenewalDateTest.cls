@IsTest
public class ChangeNextRenewalDateTest 
{
   
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         TestdataUtility.insertSub();
        
    }
    
     @IsTest public static void test1() 
     {
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         Test.startTest();
         PageReference pageRef = Page.ChangeNextRenewalDate;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',sub.chargebeeapps__CB_Id__c);
         pageRef.getParameters().put('pk',subid);
         Test.setMock(HttpCalloutMock.class, new MockCreditNoteResponseGenerator());
         ChangeNextRenewalDate rd = new ChangeNextRenewalDate();
         rd.newrd = '2018-03-27 02:00';
         rd.prorate = true;
         rd.invoiceOpt = 'INVOICE_NOW';
         PageReference p = rd.save();   
         Test.stopTest();
    	 system.assertEquals(p.getUrl(),'/'+subid);
     }
     
     
 }