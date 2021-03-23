@IsTest public with sharing class CBRouterTest 
{
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSite();
         TestdataUtility.insertContacts();
         Contact validcontact=TestdataUtility.getValidContact();
         TestdataUtility.associateContactToSite(site.Id,validcontact.Id);
         TestdataUtility.insertOpportunity();
         TestdataUtility.insertSub();
    }
    @IsTest public static void testCBRouterOpp() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact con = TestdataUtility.getCBUnsynchedContact();
         //Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         
          
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);//0060K00000VBnK0
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','opp');
         Opportunity opp = [select AccountId from Opportunity where id=:opt.Id];
         
         CBRouter cbr = new CBRouter();
         cbr.route();
         Test.stopTest();
         system.assertEquals(cbr.acc_id, opp.AccountId);
     }
     
     @IsTest public static void testCBRouterCon() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact validcontact=TestdataUtility.getValidContact();
        /* Contact cons = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,cons.Id);*/       
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',validcontact.Id);//0030K00001kRp8S
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','con');
         
          CBRouter cbr = new CBRouter();//'create_subscription','con','0030K00001kRp8S');
          cbr.selectedSites = 'cbtest1';
          PageReference p = cbr.route();
          system.debug('url '+p.getUrl());
          Test.stopTest();
          system.assertEquals(p.getUrl(), '/apex/chargebeeapps__Create_Subscription?con_id='+validcontact.Id);
     }   
     
     @IsTest public static void testCBRouterUpdatePayment() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact validcontact=TestdataUtility.getValidContact();
         /*Contact cons = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,cons.Id);*/        
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',validcontact.Id);//0030K00001kRp8S
         pageRef.getParameters().put('action','update_payment_method');
         pageRef.getParameters().put('from','con');           
         CBRouter cbr = new CBRouter();//'update_payment_method','con','00310000014Jtpw');
         cbr.selectedSites = 'cbtest1';
         PageReference p = cbr.route();
         string url = p.getUrl();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__UpdatePaymentMethod?id='+validcontact.Id));
     }        
     
    @IsTest public static void testCBRouterSubUpdatePayment() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact validcontact=TestdataUtility.getValidContact();
         /*Contact cons = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,cons.Id);*/       
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',validcontact.Id);//0030K00001kRp8S
         pageRef.getParameters().put('action','update_payment_method');
         pageRef.getParameters().put('from','con');           
          CBRouter cbr = new CBRouter();
         cbr.selectedSites = 'cbtest1';
          //cbr.con_id = '00310000014K3z7';
         PageReference p = cbr.route();
         string url = p.getUrl();
         cbr.backToContact();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__UpdatePaymentMethod?id='+validcontact.Id));
          //cbr.createSubscription();
         
     } 
    @IsTest public static void testCBRouterSubUpdatePayment2() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact validcontact=TestdataUtility.getValidContact();
         /*Contact cons = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,cons.Id); */       
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',validcontact.Id);//0030K00001kRp8S
         pageRef.getParameters().put('action','update_payment_method');
         pageRef.getParameters().put('from','con');           
          CBRouter cbr = new CBRouter();
         cbr.selectedSites = 'cbtest1';
          //cbr.con_id = '00310000014Jtpw';
         //cbr.route();
         PageReference p = cbr.route();
         system.debug('url---'+p.getUrl());
         string url = p.getUrl();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__UpdatePaymentMethod?id='+validcontact.Id));
          //cbr.createSubscription();
         //cbr.backToContact();
     } 
     
     @IsTest public static void testCBRouterSub() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact validcontact=TestdataUtility.getValidContact();
        /* Contact cons = [select Id,LastName from Contact where LastName='test2' LIMIT 1];
         system.debug('acc id'+acc.Id);
         
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,cons.Id);*/        
         Test.startTest();

         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',validcontact.Id);//0030K00001kRp8S
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','con');           
         CBRouter cbr = new CBRouter();
         cbr.selectedSites = 'cbtest1';
         cbr.con_id = validcontact.Id;//00310000014Jtpw
         cbr.route();
 		 PageReference pageSub = cbr.createSubscription();
         
         system.assertEquals(pageSub.getUrl(), '/apex/chargebeeapps__Create_Subscription?con_id='+validcontact.Id+'&domain=cbtest1');
     } 
        
     @IsTest public static void testCBRouterAcc() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account accs = [select Id,Name from Account where Name='SfTest4' LIMIT 1];
         Test.startTest();
         PageReference pageRef = Page.CBRouter;    
         test.setCurrentPageReference(pageRef);      
         pageRef.getParameters().put('id',accs.Id);//0010K00001y4Bq6
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','acc');           
         CBRouter cbr = new CBRouter();//'create_subscription','acc','00128000015tfJd');
         cbr.selectedSites = 'cbtest1';
         cbr.route();
         Test.stopTest();
         system.assertEquals(cbr.disableCreateCon,false);
         //cbr.createSubscription();
     } 
    @IsTest public static void testCBRouterCreateCus() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact validcontact=TestdataUtility.getValidContact();
         /*Contact cons = [select Id,LastName from Contact where LastName='test3' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,validcontact.Id);*/        
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',validcontact.Id);//0030K00001kQvkI
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','con');
         CBRouter cbr = new CBRouter();//'create_subscription','con','00310000014Jtpw');
         cbr.selectedSites = 'cbtest1';
         cbr.route();
         PageReference pageSub = cbr.createSubscription();
         Test.stopTest();
         system.assertEquals(pageSub.getUrl(), '/apex/chargebeeapps__Create_Subscription?con_id='+validcontact.Id+'&domain=cbtest1');
     }
    @IsTest public static void testCreateCusUpdatePayment() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact validcontact=TestdataUtility.getValidContact();
         /*Contact cons = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,cons.Id); */       
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',validcontact.Id);//0030K00001kQvkI
         pageRef.getParameters().put('action','update_payment_method');
         pageRef.getParameters().put('from','con');
         CBRouter cbr = new CBRouter();//'create_subscription','con','00310000014Jtpw');
         cbr.selectedSites = 'cbtest1';
         PageReference p = cbr.route();
         string url = p.getUrl();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__UpdatePaymentMethod?id='+validcontact.Id));
         
         
     }
    @IsTest public static void testCreateCusAcc() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account accs = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',accs.Id);//0010K00001y8vBm     
         pageRef.getParameters().put('action','create_subscription');
         pageRef.getParameters().put('from','acc');
         CBRouter cbr = new CBRouter();//'create_subscription','con','00310000014Jtpw');
         cbr.selectedSites = 'cbtest1';
         PageReference p = cbr.route();
         Test.stopTest();
         system.debug('checkurlroute---'+p.getUrl());
         system.assertEquals(cbr.disableCreateCon,false);
         //PageReference pageSub = cbr.createSubscription();
     }
    @IsTest public static void testCBRouterAddCharge() 
    {
         //chargebeeapps__CB_Settings__c cbsetting = TestdataUtility.insertCustomSetting();
         chargebeeapps__CB_Subscription__c sub = [select Id,Name,chargebeeapps__CB_Site__c,
                                                  chargebeeapps__CB_Subscription_Id__c,chargebeeapps__Company__c
                                                 from chargebeeapps__CB_Subscription__c where chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD'];
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',sub.Id);
         pageRef.getParameters().put('action','add_charge');
   
         CBRouter cbr = new CBRouter();
         PageReference p = cbr.route();
         string url = p.getUrl();
         test.stopTest();
         system.debug('addcharge url '+url);
         system.assert(url.contains('/apex/chargebeeapps__Add_Charge'));
    }
    @IsTest public static void testCBRouterChangeBilling() 
    {
         chargebeeapps__CB_Subscription__c sub = [select Id,Name,chargebeeapps__CB_Site__c,
                                                  chargebeeapps__CB_Subscription_Id__c,chargebeeapps__Company__c
                                                 from chargebeeapps__CB_Subscription__c where chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD'];
         Test.startTest();
         
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',sub.Id);
         pageRef.getParameters().put('action','change_renewal_date');
   
         CBRouter cbr = new CBRouter();
         PageReference p = cbr.route();
         string url = p.getUrl();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__ChangeNextRenewalDate'));
    }
    @IsTest public static void testCBRouterCancel() 
    {
         chargebeeapps__CB_Subscription__c sub = [select Id,Name,chargebeeapps__CB_Site__c,
                                                  chargebeeapps__CB_Subscription_Id__c,chargebeeapps__Company__c
                                                 from chargebeeapps__CB_Subscription__c where chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD'];
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',sub.Id);//a0J0K00000SOsEd
         pageRef.getParameters().put('action','cancel_sub');
         
         
         CBRouter cbr = new CBRouter();
         PageReference p = cbr.route();
         string url = p.getUrl();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__Cancel_subscription'));
    }
    @IsTest public static void testCBRouterInvCount() 
    {
         CBURLUtil util=new CBURLUtil();
         chargebeeapps__CB_Subscription__c sub = [select Id,Name,chargebeeapps__CB_Site__c,
                                                  chargebeeapps__CB_Subscription_Id__c,chargebeeapps__Company__c
                                                 from chargebeeapps__CB_Subscription__c where chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD'];
         Test.startTest();
         PageReference pageRef = Page.CBRouter;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',sub.Id);//a0J0K00000SOsEd
         pageRef.getParameters().put('action','syncInvCount');
         Test.setMock(HttpCalloutMock.class, new MockCustGenerator('Positive'));
         
         CBRouter cbr = new CBRouter();
         //PageReference p = cbr.route();
         cbr.syncInvCount();
         
         String resp = CBURLUtil.sendRequest('https://cbtest1.chargebee.com/api/v2/subscriptions/Hr5511nROMSd0r1urD',null,util,true,'GET');
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(2,callouts);
         
    }
    @IsTest public static void testCBRouterMultiSites() 
    {
        chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Account accs = [select Id,Name from Account where Name='SfTest2' LIMIT 1];
         Test.startTest();
        PageReference pageRef = Page.CBRouter;
        test.setCurrentPageReference(pageRef);
        CBRouter cbr = new CBRouter();
        pageRef.getParameters().put('id',accs.Id);
        List<selectOption> sites = cbr.fetchAllSites();
        cbr.handleContact();
        PageReference pageRefe = cbr.redirectToError('err');
        PageReference pageRefRedirect = cbr.redirectContact();
        string url = pageRefe.getUrl();
        Test.stopTest();
        system.debug('redirurl '+url);
        system.assert(url.contains('/apex/chargebeeapps__error'));
    }
    
}