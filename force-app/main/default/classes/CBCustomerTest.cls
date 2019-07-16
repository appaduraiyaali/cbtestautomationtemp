@IsTest public with sharing class CBCustomerTest
{
   
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
        
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSites();
         Contact[] contacts = TestdataUtility.insertContacts();
         TestdataUtility.insertContactSite(site.Id,contacts[0].Id);         
    }

     @IsTest public static void testCBCreate() 
     {
     
     chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
     Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         
     Test.startTest();
     PageReference pageRef = Page.CBNewCustomer;
     test.setCurrentPageReference(pageRef);
     pageRef.getParameters().put('id',con.Id);//00328000003Pcc4
     pageRef.getParameters().put('url','/003/o');
     pageRef.getParameters().put('action','sync');
     CBNewCustomer cbu = new CBNewCustomer();
     Test.setMock(HttpCalloutMock.class, new MockCustGenerator('Positive'));
     cbu.checkPermissions();
     cbu.getSiteDetails();
     cbu.selectedSites='cbtest1';
     cbu.displayEnabledMessage();
     cbu.createCustomer();
     cbu.checkPermissions();
     cbu.back();
     cbu.action='sync';
     chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
     system.debug('testCon'+testCon);
     Test.stopTest();
     system.assertEquals(string.valueOf(testCon.Contact__c),con.Id);
     cbu.redirectToError('hello','world');
     cbu.ToError();
    
     }
     
    /* This method simulates the test case when "Confirm" button click UserAction
     * is triggered for a Contact which is not synched to CB. 
     * The following cases are verified
     * Sync the Contact details to CB and asserts both positive and negative case
     * from Server Mock response 
     */ 
     public static void createSubsActionUnsynchedCust(Contact con,string action,string contactType)
     {
         chargebeeapps__CB_Sites__c[] sites = TestdataUtility.getSiteList();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSites(); 
         
         Test.startTest();
         
         PageReference pageRef = Page.CBNewCustomer;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('url','/003/o');
         if(action == 'create_sub')
         {
             pageRef.getParameters().put('action','create_sub');
         }
         else if(action == 'sync')
         {
             pageRef.getParameters().put('action','sync');
         }
         CBNewCustomer cbu = new CBNewCustomer();  
         
         List<selectOption> siteList = new List<selectOption>();
         siteList.add(new SelectOption('-1','Select'));
         siteList.add(new SelectOption(sites[0].Name,sites[0].Name));
         siteList.add(new SelectOption(sites[1].Name,sites[1].Name));   
         List<selectOption> domainlist = cbu.getSiteDetails();
         cbu.selectedSites='cbtest1'; 
         string siteId = cbu.selectedSites;
         cbu.displayEnabledMessage();
         
         system.assertEquals(domainlist,siteList);
         system.assertEquals(cbu.cont.FirstName, con.FirstName);
         system.assertEquals(cbu.cont.LastName, con.LastName);         
         system.assertEquals(cbu.cont.Email, con.Email);
         PageReference checkUrl;
         if(contactType.equalsIgnoreCase('NewCon'))
         {
             Test.setMock(HttpCalloutMock.class, new MockCustGenerator(MockCustGenerator.SYNC_NEW_CUSTOMER));
             checkUrl = cbu.createCustomer();
             system.assert(cbu.disableCreate);
             chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c 
                                                            from chargebeeapps__Contact_Associate_Site__c 
                                                            where chargebeeapps__Contact__c=:con.Id and chargebeeapps__External_Id__c ='1n6BPujRUOG1LeV2R' and chargebeeapps__CB_Site__c=:site.Id]; 
         	system.assertEquals(testCon.chargebeeapps__External_Id__c,'1n6BPujRUOG1LeV2R');
         	system.assertEquals(testCon.chargebeeapps__CB_Site__c,site.Id);
         }         
         else if(contactType.equalsIgnoreCase('ExistingCon'))
         {
             Test.setMock(HttpCalloutMock.class, new MockCustGenerator(MockCustGenerator.SYNC_EXISTING_CUSTOMER));         
         	 checkUrl = cbu.createCustomer(); 
             system.assert(cbu.disableUpdate);
             chargebeeapps__Contact_Associate_Site__c testCon2 =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c 
                                                            from chargebeeapps__Contact_Associate_Site__c 
                                                            where chargebeeapps__Contact__c=:con.Id and chargebeeapps__External_Id__c ='1t0Aw4lRUsqQiYsg' and chargebeeapps__CB_Site__c=:site.Id];
             system.assertEquals(testCon2.chargebeeapps__External_Id__c,'1t0Aw4lRUsqQiYsg');
         	 system.assertEquals(testCon2.chargebeeapps__CB_Site__c,site.Id);
         }
         //system.assertEquals(cbu.utilObj.createCustomer(con.Id),StatusClass.Status.SUCCESS);
         redirectToPage(checkUrl,action,con,siteId);
         Test.stopTest();
     }
    public static void redirectToPage(PageReference redirectUrl,string action,Contact con,string siteId)
    {
        chargebeeapps__CB_Sites__c site = TestdataUtility.getSites(); 
        chargebeeapps__Coupon__c[] cpnList = TestdataUtility.getSiteBasedCpns(site.Id);
		if(action == 'create_sub')
        {
            system.assertEquals(redirectUrl.getUrl(),'/apex/chargebeeapps__Create_Subscription?con_id='+con.Id+'&domain='+siteId+'&id='+con.Id);
            CBCreateSubscriptionTest.pageDataValidation(null,con,cpnList);
        }
        else if(action == 'sync')
        {
            system.assertEquals(redirectUrl.getUrl(),'/'+con.id);
        }
    }
    /* UseCase Simulation: "Confirm" button click user action
     * is done. 
     * When we try to synch without selecting a target domain/site, handled
     * assert to validate the error message. 
     */
    public static void cusSyncWithNoSite(Contact con) 
     {
         PageReference pageRef = Page.CBNewCustomer;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('url','/003/o');
         pageRef.getParameters().put('action','create_sub');
         CBNewCustomer cbu = new CBNewCustomer();         
         cbu.selectedSites ='-1';
     	 cbu.createCustomer();         
         system.assertEquals(cbu.errorMessage,'Please select a site.');
         PageReference back = cbu.back();
         system.assertEquals(back.getUrl(), '/'+con.Id);
     }
    /* This method simulates the use case when "Confirm" action is triggered from
	   Create/Update page for a synced contact(Synced in CB but not present now) 
     * assert to validate the API error message.
     */
     public static void custWithOutExtIdInResp(Contact con,string conType) 
     {
         
         Test.startTest();
         PageReference pageRef = Page.CBNewCustomer;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('url','/003/o');
         pageRef.getParameters().put('action','sync');
         CBNewCustomer cbu = new CBNewCustomer();         
         cbu.selectedSites ='cbtest1';
         Test.setMock(HttpCalloutMock.class, new MockCustGenerator('APIError'));
     	 cbu.createCustomer();     
         Test.stopTest();
         if(conType == 'NewCon')
         {
         	system.assertEquals(cbu.errorMessage,'Unable to create Customer in Chargebee. 1n6BPujRUOG1LeV2R not found');
         }
         else if(conType == 'ExistingCon')
         {
             system.assert(cbu.utilObj.response.startswith('Unable to create Customer in Chargebee.'));
         }
     }
         
}