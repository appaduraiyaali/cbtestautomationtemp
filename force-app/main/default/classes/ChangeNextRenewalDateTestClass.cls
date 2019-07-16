@IsTest
public class ChangeNextRenewalDateTestClass
{

    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
             
         TestdataUtility.insertSub();
        
    }
    
    @IsTest
    public static void testProrate()
    {
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         Test.startTest();
         PageReference pageRef = Page.ChangeNextRenewalDate;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',sub.chargebeeapps__CB_Id__c);//1mkVvwZQYZrOPS3c40
         pageRef.getParameters().put('pk',subid);//a0J2800000JDBbg
         Test.setMock(HttpCalloutMock.class, new MockCreditNoteResponseGenerator());
         ChangeNextRenewalDate rd = new ChangeNextRenewalDate();
         
         rd.prorate = false;
         rd.invoiceOpt = 'INVOICE_NOW';
         rd.newrd = '2018-04-20 00:00:00';
         PageReference p = rd.save(); 
         Test.stopTest();
         system.debug(p.getUrl());
         system.assertEquals(p.getUrl(),'/'+subid);
    
    }
    
    @IsTest
    public static void testCreditNote()
    {
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         Test.startTest();
         PageReference pageRef = Page.ChangeNextRenewalDate;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',sub.chargebeeapps__CB_Id__c);//1mkVvwZQYZrOPS3c40
         pageRef.getParameters().put('pk',subid);//a0J2800000JDBbg
         ChangeNextRenewalDate rd = new ChangeNextRenewalDate();
         rd.prorate = true;
         rd.invoiceOpt = 'INVOICE_NOW';
         rd.newrd = '2018-04-20 00:00:00';
         Test.setMock(HttpCalloutMock.class, new MockCreditNoteResponseGenerator());
         rd.populate();
         PageReference p = rd.save();   
    	 system.debug(p.getUrl());
         string url = p.getUrl();
         Test.stopTest();
    	 system.assert(url.contains('/'+subid));
    }
    @IsTest
    public static void testCancel()
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
         ChangeNextRenewalDate rd = new ChangeNextRenewalDate();
         rd.errFlag=true;
         rd.prorate = true;
         rd.invoiceOpt = 'INVOICE_NOW';
         rd.newrd = '2018-04-20 00:00:00';
         Test.setMock(HttpCalloutMock.class, new MockUnbilledChargesResponseGenerator());
         rd.preview();
         PageReference p = rd.Cancel();
         string url = p.getUrl();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__ChangeNextRenewalDate'));
     
    }
    @IsTest
    public static void testInvoiceNote()
    {
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         Test.startTest();
         PageReference pageRef = Page.ChangeNextRenewalDate;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',sub.chargebeeapps__CB_Id__c);//1mkVvwZQYZrOPS3c40
         pageRef.getParameters().put('pk',subid);//a0J2800000JDBbg
         ChangeNextRenewalDate rd = new ChangeNextRenewalDate();
         rd.prorate = true;
         rd.invoiceOpt = 'INVOICE_NOW';
         rd.newrd = '2018-10-20 00:00:00';
         Test.setMock(HttpCalloutMock.class, new MockInvoiceNoteResponseGenerator());
         rd.populate();
         PageReference p = rd.save(); 
         Test.stopTest();
    	 system.assertEquals(p.getUrl(),'/'+subid);
    
    }
    
    @IsTest
    public static void testInvoiceOpt()
    {
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__SubscriptionId__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         Test.startTest();
         PageReference pageRef = Page.ChangeNextRenewalDate;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',sub.chargebeeapps__CB_Id__c);//1mkVvwZQYZrOPS3c40
         pageRef.getParameters().put('pk',subid);//a0J2800000JDBbg
         ChangeNextRenewalDate rd = new ChangeNextRenewalDate();
         rd.prorate = true;
         rd.invoiceOpt = 'INVOICE_NOW';
         rd.newrd = '2018-04-20 00:00:00';
         Test.setMock(HttpCalloutMock.class, new MockCreditNoteResponseGenerator());
         rd.populate();
         PageReference p = rd.save();
         Test.stopTest();
    	 system.assertEquals(p.getUrl(),'/'+subid);   
    
    
    }


}