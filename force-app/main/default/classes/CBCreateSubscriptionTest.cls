@IsTest public with sharing class CBCreateSubscriptionTest 
{
   
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSites();
         
         Contact[] contacts = TestdataUtility.insertContacts();
         Opportunity[] opt = TestdataUtility.insertOpportunity();
         TestdataUtility.insertContactSite(site.Id,contacts[0].Id);
         Product2[] prod = TestdataUtility.insertProducts();
         
         TestdataUtility.insertCoupons();
         
         List<string> extid = new List<string>();
         List<string> selectedIds = new List<string>();
         for(Product2 pr:prod)
         {
             string externalids = pr.ExternalId;
             extid.add(externalids);
             string plantype = pr.chargebeeapps__Recurring_charge_model__c;
             system.debug('plantype---'+plantype);
             if(pr.chargebeeapps__Addon_Type__c != null)
             {
                 string addonType = pr.chargebeeapps__Addon_Type__c;
                 if(( addonType.equalsIgnoreCase('Tiered') || addonType.equalsIgnoreCase('StairStep')||addonType.equalsIgnoreCase('Volume')))
                 {
                     string pid = pr.Id;
             		 selectedIds.add(pid);
                 }
             }
             if((plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))

                {
					string pid = pr.Id;
             		selectedIds.add(pid);
                 
             	}
         }
                 
         List<string> pbIds = new List<string>();
         PricebookEntry[] pbentry = TestdataUtility.insertPBEntry(extid);
         
         PricebookEntry[] selctedprod = [select Id,product2Id from PricebookEntry where product2Id IN:selectedIds];
         
         for(PricebookEntry pb:selctedprod)
         {
             string pid = pb.Id;
             pbIds.add(pid);
              
         }         
         OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opt[1].Id,Quantity = 5,PricebookEntryId = pbentry[0].Id,TotalPrice = 5 * 100);
            
         insert oli1;
         TestdataUtility.insertCBTiers(pbIds);
         
    }
    @IsTest public static void testSubscription1() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
     	 system.debug('testCon'+testCon);
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         string oppid = opt.Id;
         string coid = con.Id;
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         
         Test.startTest();
         PageReference pageRef = Page.Create_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('opp_id',oppid);
         //pageRef.getParameters().put('opp_id',null);
         pageRef.getParameters().put('con_id',coid);
         pageRef.getParameters().put('domain','cbtest1');       
         Test.setMock(HttpCalloutMock.class, new MockEstSubResponseGenerator());
         CBCreateSubscription cbn = new CBCreateSubscription();
         cbn.plans='Testplan1';
         cbn.planSetupCost='100';
         cbn.sFname = 'Test Fname';
         cbn.sLname = 'Test sLname';
         cbn.sEmail = 'hariharan11@chargebee.com';
         cbn.sPhone = '8345678789';
         cbn.sCompany = 'Totodoin';
         cbn.sAddress1 = 'line 1';
         cbn.sAddress2 = 'line 2';
         cbn.sAddress3 = 'line 3';
         cbn.sCity = 'Pleasanton';
         cbn.sState = 'California';
         cbn.sCountry = 'US';                     
         cbn.sZipcode = '98564';
         cbn.sameBillAddress = false;
         cbn.planPrice = '100'; 
         cbn.canOverride = true;
         cbn.sDate = system.today();
         cbn.invNow=True;
         cbn.stdate=false;
         cbn.JsonMap = 'test';
         string json = cbn.JsonMap;
         PageReference checkPermission = cbn.checkPermissions();
         cbn.ChangeselectedSiteName();
         cbn.canOverRide=true;
         cbn.preview();
         cbn.populate();
         cbn.selecttab();
         cbn.selecttab1();
         Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
         cbn.save();                 
         PageReference updateDate = cbn.updateStartDate(system.today());
         PageReference saveacc = cbn.saveAccount();        
         PageReference redirect = cbn.redirectToError('error', 'contact');
         PageReference cancel = cbn.Cancel();
         cbn.options3 = new List<selectOption>();
         List<selectOption> testPlans =  cbn.options3;
         testPlans.add(new SelectOption('plan1','plan1'));
         testPlans.add(new SelectOption('plan2','plan2'));       
         cbn.addonOptionsCache = new List<selectOption>();
         List<SelectOption> testAddons = cbn.addonOptions;
         testAddons.add(new SelectOption('addon1','addon1'));
         testAddons.add(new SelectOption('addon2','addon2'));
         cbn.coupenOptions = new List<selectOption>();
         List<SelectOption> testCoupons = cbn.coupenOptions;
         testCoupons.add(new SelectOption('coupon1','coupon1'));
         testCoupons.add(new SelectOption('coupon2','coupon2'));
         List<selectOption> multiSites = cbn.getSiteDetails();        
         Integer callouts = Limits.getCallouts();
         system.debug('callouts--'+callouts);        
         Test.stopTest();
         system.assertequals(5,callouts);
     }
    @IsTest public static void testSubscription2() 
     {
         
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
    	 system.debug('testCon'+testCon);
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         string oppid = opt.Id;
         string coid = con.Id;
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
         Test.startTest();
         PageReference pageRef = Page.Create_Subscription;
         test.setCurrentPageReference(pageRef);     
         pageRef.getParameters().put('opp_id',null);
         pageRef.getParameters().put('con_id',coid);
         pageRef.getParameters().put('domain','cbtest1');      
         Test.setMock(HttpCalloutMock.class, new MockEstSubResponseGenerator());     
         CBCreateSubscription cbn = new CBCreateSubscription();
         cbn.selectedSites='cbtest1';
         cbn.plans='Testplan1';         
         cbn.sameBillAddress = false;
         cbn.planPrice = '100'; 
         //cbn.canOverride = true;
         cbn.sDate = system.today();
         cbn.invNow=false;
         cbn.stdate=true;
         cbn.siteId=sites.Id;
         cbn.options3 = new List<selectOption>();
         List<selectOption> testPlans =  cbn.options3;
         testPlans.add(new SelectOption('plan1','plan1'));
         testPlans.add(new SelectOption('Testplan1','Testplan1'));
         cbn.preview();
         cbn.populate();
         cbn.selecttab();
         cbn.selecttab1();
         cbn.CbPriceBookEntry();
         cbn.selList = new List<AddonObject>();
         List<AddonObject> selistTest = cbn.selList;
         AddonObject addonObj = new AddonObject('TestAddon8',1,1,50.00,false);
         selistTest.add(addonObj);
         cbn.addonId=1;       
         cbn.CbPriceBookEntryAddon();
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(2,callouts);
     }
     public static void pageDataValidation(string oppid,Contact con,List<chargebeeapps__Coupon__c> cpnList) 
     {
         CreateTestData.insertTestData();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSites();
         contact cont = TestdataUtility.getContact(con.LastName);
         Account acc = [select Id,Name from Account where Id=:cont.AccountId LIMIT 1];
     	 
         PageReference pageRef = Page.Create_Subscription;
         test.setCurrentPageReference(pageRef);     
         pageRef.getParameters().put('opp_id',null);
         pageRef.getParameters().put('con_id',cont.Id);
         pageRef.getParameters().put('domain','cbtest1');      
         Test.setMock(HttpCalloutMock.class, new MockEstSubResponseGenerator());     
         CBCreateSubscription cbn = new CBCreateSubscription();
         cbn.selectedSiteName();
         cbn.coupenOptions = new List<selectOption>();
         List<SelectOption> testCoupons = new List<selectOption>();
         testCoupons.add(new SelectOption('-1','Select'));
         testCoupons.add(new SelectOption(cpnList[0].chargebeeapps__CB_Coupon_Id__c,cpnList[0].Name));
         testCoupons.add(new SelectOption(cpnList[1].chargebeeapps__CB_Coupon_Id__c,cpnList[1].Name));
         testCoupons.add(new SelectOption(cpnList[2].chargebeeapps__CB_Coupon_Id__c,cpnList[2].Name));
         testCoupons.add(new SelectOption(cpnList[3].chargebeeapps__CB_Coupon_Id__c,cpnList[3].Name));
         system.assertEquals(cbn.cont.Name,cont.Name);
         system.assertEquals(cbn.cont.Account.Name,acc.Name);
         system.assertEquals(UIUtil.getCouponOptions(site.Id),testCoupons);
         List<selectOption> testPlans = cbn.options3;
         system.debug('options3--'+testPlans);
      
     }
    @IsTest public static void testSubscription3() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
    	 system.debug('testCon'+testCon);
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         string oppid = opt.Id;
         string coid = con.Id;
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers;
        
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
		 Test.startTest();
         PageReference pageRef = Page.Create_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('opp_id',oppid);
         //pageRef.getParameters().put('opp_id',null);
         pageRef.getParameters().put('con_id',coid);
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockSubGenerator());         
         CBCreateSubscription cbn = new CBCreateSubscription();
         cbn.selectedSites='cbtest1';
         cbn.plans='Testplan1';         
         cbn.sameBillAddress = false;
         cbn.planPrice = '100';          
         cbn.sDate = system.today();
         cbn.invNow=true;
         cbn.stdate=true;        
         cbn.preview();
         cbn.populate();
         cbn.selecttab();
         cbn.selecttab1();                 
         cbn.cancel_page();
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(2,callouts);
     }

    @IsTest public static void testCheckout1() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
    	 system.debug('testCon'+testCon);
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp2' LIMIT 1];
         string oppid = opt.Id;
         string coid = con.Id;
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers;
        
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
		 Test.startTest();
         PageReference pageRef = Page.Create_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('opp_id',oppid);
         pageRef.getParameters().put('con_id',coid);
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockCheckoutResponse1Generator());
         CBCreateSubscription cbn = new CBCreateSubscription();
         cbn.selectedSites='cbtest1';
         cbn.plans='Testplan1';
         cbn.planPrice = '100'; 
         cbn.sDate = system.today();                
         cbn.checkout();
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(1,callouts);
     }
    
    @IsTest public static void testSubscriptionVolType() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
    	 system.debug('testCon'+testCon);
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         string oppid = opt.Id;
         string coid = con.Id;
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers;
        
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
		 Test.startTest();
         PageReference pageRef = Page.Create_Subscription;
         test.setCurrentPageReference(pageRef);        
         pageRef.getParameters().put('opp_id',null);
         pageRef.getParameters().put('con_id',coid);//0030K00001l4Deb
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockEstSubResponseGenerator());
         CBCreateSubscription cbn = new CBCreateSubscription();
         cbn.plans='Testplan2'; 
         cbn.pquan = 45;        
         cbn.sameBillAddress = false;
         cbn.planPrice = '100';
         cbn.addon = 'TestAddon7';
         cbn.addonId = 1;
         cbn.sDate = system.today();
         cbn.invNow=false;
         cbn.stdate=true;
         cbn.siteId=sites.Id;
         cbn.CbPriceBookEntry();
         cbn.selList = new List<AddonObject>();
         List<AddonObject> selistTest = cbn.selList;
         AddonObject addonObj = new AddonObject('TestAddon7',1,1,50.00,false);
         selistTest.add(addonObj);
         cbn.CbPriceBookEntryAddon();
         cbn.populate();
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(1,callouts);
     }
     @IsTest public static void testSubscriptionTieredType() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c testCon =[select chargebeeapps__External_Id__c,chargebeeapps__Contact__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=:con.Id];
    	 system.debug('testCon'+testCon);
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         string oppid = opt.Id;
         string coid = con.Id;
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
		 Test.startTest();
         PageReference pageRef = Page.Create_Subscription;
         test.setCurrentPageReference(pageRef);         
         pageRef.getParameters().put('opp_id',null);
         pageRef.getParameters().put('con_id',coid);//0030K00001l4Deb
         pageRef.getParameters().put('domain','cbtest1');         
         Test.setMock(HttpCalloutMock.class, new MockEstSubResponseGenerator());        
         CBCreateSubscription cbn = new CBCreateSubscription();
         cbn.plans='Testplan3'; 
         cbn.pquan = 45;                
         cbn.sameBillAddress = false;
         cbn.planPrice = '100';
         cbn.addon = 'TestAddon6';
         cbn.addonId = 1;         
         cbn.sDate = system.today();
         cbn.invNow=false;
         cbn.stdate=true;  
         cbn.siteId=sites.Id;
         cbn.CbPriceBookEntry();
         cbn.selList = new List<AddonObject>();
         List<AddonObject> selistTest = cbn.selList;
         AddonObject addonObj = new AddonObject('TestAddon6',1,1,50.00,false);         
         selistTest.add(addonObj);
         cbn.CbPriceBookEntryAddon();
         cbn.populate();
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(1,callouts);
    
     }
 
}