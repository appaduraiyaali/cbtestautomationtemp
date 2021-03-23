@IsTest public class UCCreateSubsciptionTest {
    
    /* This method will pre-load the data needed for
     * testing the "CreateSubscription" button click UserAction 
     * from Contact Detail page. The subsequent test methods for various
     * use cases will use this data 
     */
    @TestSetup public static void populateTestData()
    {
         TestdataUtility.insertCustomSetting(); 
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSite(); 
         Contact[] contacts = TestdataUtility.insertContacts();
         Contact validcontact=TestdataUtility.getValidContact();
         TestdataUtility.associateContactToSite(site.Id,validcontact.Id);         
         TestdataUtility.insertCoupons();
    }
    
    /* This method simulates the test case when "Create Subscription" button click UserAction
     * is triggered for a Contact which is not synched to CB. 
     * The following cases are verified
     * 1. System.asserts verify that the next page navigation is "Create/Update customer page".
     * 2. Sync the Contact details to CB and asserts both positive and negative case
     * from Server Mock response 
     */ 
     @IsTest public static void createSubsForNewCT() 
     {         
         Contact con = TestdataUtility.getCBUnsynchedContact();                          
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','con');         
         CBRouter cbr = new CBRouter();
         PageReference checkUrl = cbr.route();         
         system.assertEquals(checkUrl.getUrl(), '/apex/chargebeeapps__CBNewCustomer?action=create_sub&id='+con.Id);
         CBCustomerTest.createSubsActionUnsynchedCust(con,'create_sub','NewCon');         
     }
    
    /* This method simulates the test case when "CreateSubscription" button click UserAction
     * is triggered for a Contact which is already synched to CB application. 
     * The following cases are verified
     * 1. System.asserts verify that the next page navigation is "Create Subscription"
     * 2. Validates the Contact and Account details populated in "CreateSubsription" page 
     * using the "id" parameter, matches the details of test Contact created.
    */   
     
     @IsTest public static void createSubsForExistingCT() 
     {         
         Contact con = TestdataUtility.getValidContact();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSite();         
         chargebeeapps__Coupon__c[] cpnList = TestdataUtility.getSiteBasedCpns(site.Id);
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','con');         
         CBRouter cbr = new CBRouter();
         PageReference checkUrl = cbr.route();         
         system.assertEquals(checkUrl.getUrl(), '/apex/chargebeeapps__Create_Subscription?con_id='+con.Id);         
         CBCreateSubscriptionTest.pageDataValidation(null,con,cpnList);
     }
    
     /* This method creates a User with "Standard User" profile, which does not have permissions
      * for Custom Objects. The context of execution is set to be the newly created User.
      * When "Create Subscription" button click is simulated from the above test user, this will
      * result in error page due to restricted access to the Custom Object(Contact Site Mapping) .
      */ 
     @IsTest public static void createSubsForCTPermissionError() 
     {  
         UserRole role = new UserRole(Name ='Sales');
         insert role;
         Profile pf= [SELECT Id FROM Profile WHERE Name = 'Standard User'];
         User testUser = new User(
         ProfileId = pf.Id,
         LastName = 'last',
         Email = 'puser000@chargebee.com',
         Username = 'puser000@chargebee.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         UserRoleId = role.Id
        );
         system.runAs(testUser){        
         Contact con = TestdataUtility.getContact('test2');
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','con');         
         CBRouter cbr = new CBRouter();         
         PageReference checkUrl = cbr.route();
         
         string url = checkUrl.getUrl();
         Test.stopTest();         
         system.assert(url.contains('/apex/chargebeeapps__error'));  
         
         }
     }
    
    /** This method simulate the use case when "Create Subscription" action is triggered from
     * Contact detail page, contact is created without giving a emailid.
     * 1. Ensure that the "Create Subscription" action navigates to "Create New Customer" page.
     * 2. System assert to ensure that error message is handled when "Confirm" button click user action
     * is done at "CreateNewCustomer" page.
     * 3. "Cancel" user action is also handled which will navigate back to contact page.
     */
    @IsTest public static void contactWOEmail() 
     {         
         Contact con =  TestDataUtility.getContactWithoutEmail();          
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','con');         
         CBRouter cbr = new CBRouter();
         PageReference checkUrl = cbr.route();
         Test.stopTest();
         system.assertEquals(checkUrl.getUrl(), '/apex/chargebeeapps__CBNewCustomer?action=create_sub&id='+con.Id);
         CBCustomerUtilTest.cusSyncWithNoEmail(con);
     }
    
    /* UseCase Simulation: Contact is created in Salesforce and "Create Subscription" button click user action
     * is done. 
     * Result is page navigation should go to "Create/Update customer page" page.
     * When we try to synch without selecting a target domain/site, handled
     * assert to validate the error message. 
     */    
     @IsTest public static void contactWithNoSite() 
     {
         Contact con = TestdataUtility.getCBUnsynchedContact();
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','con');         
         CBRouter cbr = new CBRouter();
         PageReference checkUrl = cbr.route();
         Test.stopTest();
         system.assertEquals(checkUrl.getUrl(), '/apex/chargebeeapps__CBNewCustomer?action=create_sub&id='+con.Id);
         CBCustomerTest.cusSyncWithNoSite(con);
     }
    /*UseCase Simulation: "Create Subscription" button click user action is done from an account
     * Account with only contact which is not synched to CB.
     * Result is page navigation should go to "Create/Update customer page" page. 
     */
    @IsTest public static void createSubFrmAcctUnsynchedCust() 
     {  
         Account[] accts = TestdataUtility.getAccounts();
         Contact con = TestdataUtility.getValidContact();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',accts[3].Id);
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','acc');         
         CBRouter cbr = new CBRouter();
         PageReference checkUrl = cbr.route(); 
         system.assert(!cbr.disableSubscription);
         system.debug('checkUrl---'+checkUrl.getUrl());
         system.assertEquals(checkUrl.getUrl(), '/apex/chargebeeapps__CBNewCustomer?action=create_sub%3Fcon_id%3D'+con.Id+'&id='+con.Id);
         CBCustomerTest.createSubsActionUnsynchedCust(con,'create_sub','NewCon');         
     } 
    /*UseCase Simulation: "Create Subscription" button click user action is done from an account
     * Account with more than one contacts.
     * Test case is for both new customer(which is not synched to CB) and existing customer(synched customer to CB) .
     * Result is page navigation should go to "Create subscription page" page for existing customer. 
     * Result is page navigation should go to "Create/Update customer page" page for existing customer.
     */
    @IsTest public static void createSubFrmAccWTMultiCon() 
     { 
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSite();
         
         chargebeeapps__CB_Sites__c[] sites = TestdataUtility.getSiteList();
         Account multipleContactAcct = TestdataUtility.getAccountWithMultipleContacts();
         Contact[] con = [select Id,Firstname,LastName,Name,Email from Contact where AccountId=:multipleContactAcct.Id];
         TestdataUtility.insertContactSite(site.Id,con[0].Id);
         chargebeeapps__Coupon__c[] cpnList = TestdataUtility.getSiteBasedCpns(site.Id);
         
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',multipleContactAcct.Id);
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','acc');         
         CBRouter cbr = new CBRouter();
         cbr.route(); 
         system.assert(!cbr.disableSubscription);
         
         List<SelectOption> testConList = new List<selectOption>();
         testConList.add(new SelectOption(con[0].Id,con[0].Name+'('+site.Name+')'));
         testConList.add(new SelectOption(con[1].Id,con[1].Name));
         system.assertEquals(cbr.options3,testConList);         
         cbr.con_id = con[0].Id;
         cbr.selectedSites = 'cbtest1';
         
         cbr.handleContact();
         system.assertEquals(cbr.isMultiple,false);
         PageReference redirectSub = cbr.createSubscription();
         
         system.assertEquals(redirectSub.getUrl(), '/apex/chargebeeapps__Create_Subscription?con_id='+con[0].Id+'&domain='+cbr.selectedSites);
         CBCreateSubscriptionTest.pageDataValidation(null,con[0],cpnList); 
         cbr.con_id = con[1].Id;
         List<SelectOption> testSites = new List<selectOption>();
         testSites.add(new SelectOption(sites[0].Name,sites[0].Name));
         testSites.add(new SelectOption(sites[1].Name,sites[1].Name));
         cbr.handleContact();
         system.assertEquals(cbr.isMultiple,true);
         
         system.assertEquals(cbr.SiteDetails,testSites);
         cbr.selectedSites = 'cbtest1';
         PageReference rediRectCust = cbr.createSubscription();
         system.assertEquals(rediRectCust.getUrl(), '/apex/chargebeeapps__CBNewCustomer?action=create_sub&con_id='+cbr.con_id+'&domain='+cbr.selectedSites+'&id='+cbr.con_id);
         //CBCustomerTest.cbCreateSubNewCus(con[1],'create_sub','NewCon');
     }
    /*UseCase Simulation: "Create Subscription" button click user action is done from an account
     * Account with no contacts.
     * Result is "Create Contact" button should be enabled and "Create Subscription button is disabled for the account".
     */
    @IsTest public static void createSubFrmAccWOCon() 
     {  
         Account[] accts = TestdataUtility.getAccounts();                                   
         Account accountWOContact=TestdataUtility.getAccountWOContactAssociation();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',accountWOContact.Id);
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','acc');         
         CBRouter cbr = new CBRouter();
         PageReference checkUrl = cbr.route(); 
         system.assert(cbr.disableSubscription);
         system.assert(cbr.disableCreateCon);                         
     } 
}