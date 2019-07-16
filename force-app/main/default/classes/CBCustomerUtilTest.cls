@IsTest public with sharing class CBCustomerUtilTest 
{
   
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting(); 
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSites();         
         Contact[] contacts = TestdataUtility.insertContacts();
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(site.Id,contacts[1].Id);
         
    }
     @IsTest public static void testCBCreate() 
     {
     chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
     Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
     Test.startTest();
     PageReference pageRef = Page.CBNewCustomerUtil;
     test.setCurrentPageReference(pageRef);
     pageRef.getParameters().put('id',con.Id);
     pageRef.getParameters().put('url','/003/o');
     CBNewCustomerUtil cbu = new CBNewCustomerUtil();
     Test.setMock(HttpCalloutMock.class, new MockCustGenerator('SyncNew'));
     cbu.createCustomer(con.Id);
     chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
     system.debug('testCon--'+testCon);
     Test.stopTest();
     system.assertEquals(string.valueOf(testCon.Contact__c),con.Id);
     }
     
        
     
    /** This method simulate the use case when "Confirm" action is triggered from
     * Contact detail page, contact is created without giving a emailid.
     
     * 1. System assert to ensure that error message is handled when "Confirm" button click user action
     * is done at "Create/Update Customer" page.
     * 3. "Cancel" user action is also handled which will navigate back to contact page.
     */
	 public static CBNewCustomerUtil cusSyncWithNoEmail(Contact con) 
     {
         PageReference pageRef = Page.CBNewCustomerUtil;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('url','/003/o');
         CBNewCustomerUtil cbu = new CBNewCustomerUtil('cbtest1');
         
     	 cbu.createCustomer(con.Id);
         system.assertEquals(cbu.response,'Email ID not available for the Contact. Unable to proceed further. Please update the contact and try again.');
         PageReference redirUrl = cbu.back();
         system.assertEquals(redirUrl.getUrl(),'/'+con.id);
         return cbu;
     }
     
     @IsTest public static void testCBCreateWithExternalId() 
     {
     chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
     Contact con = [select Id,LastName from Contact where LastName='test2' LIMIT 1];
     chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
     system.debug('testCon--'+testCon);
     Test.startTest();
     PageReference pageRef = Page.CBNewCustomerUtil;
     test.setCurrentPageReference(pageRef);
     pageRef.getParameters().put('id',con.Id);//00328000012BSee
     pageRef.getParameters().put('url','/003/o');
     CBNewCustomerUtil cbu = new CBNewCustomerUtil('cbtest1');
     Test.setMock(HttpCalloutMock.class, new MockCustGenerator('SyncExisting'));
     cbu.createCustomer(con.Id);//00328000012BSee
     
     cbu.triggerSync(testCon.chargebeeapps__External_Id__c);
     PageReference p = cbu.back();
     string url = p.getUrl();
     //chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:coid];
     system.debug('url--'+url);
     cbu.redirectToError();
     Test.stopTest();
     system.assert(url.contains('/'+con.Id));
     } 
 }