@IsTest public with sharing class UpdateSubTest 
{
    
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c sites = TestdataUtility.getSites();
         
         Contact[] contacts = TestdataUtility.insertContacts();
         Opportunity[] opt = TestdataUtility.insertOpportunity();
         TestdataUtility.insertContactSite(sites.Id,contacts[0].Id);
         Product2[] prod = TestdataUtility.insertProducts();
         system.debug('prod--'+prod);
         chargebeeapps__Coupon__c cpn = new chargebeeapps__Coupon__c(Name='Doing Great',chargebeeapps__CB_Coupon_Id__c='cbdemo_great',
                                              chargebeeapps__CB_Id__c='cbdemo_great',chargebeeapps__Coupon_Id__c='cbdemo_great',
                                              chargebeeapps__CB_Site__c=sites.Id,chargebeeapps__Status__c='ACTIVE');
         insert cpn;
         //system.debug('cpns--'+cpns);
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
         system.debug('selectedIds---'+selectedIds);        
         List<string> pbIds = new List<string>();
         PricebookEntry[] pbentry = TestdataUtility.insertPBEntry(extid);
         system.debug('pbentry---'+pbentry[0]);
         PricebookEntry[] selctedprod = [select Id,product2Id from PricebookEntry where product2Id IN:selectedIds];
         system.debug('selctedprod--'+selctedprod);
         for(PricebookEntry pb:selctedprod)
         {
             string pid = pb.Id;
             pbIds.add(pid);
              
         }
         
         OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opt[1].Id,Quantity = 5,PricebookEntryId = pbentry[0].Id,TotalPrice = 5 * 100);
            
         insert oli1;
         system.debug('oli---'+oli1);
         TestdataUtility.insertCBTiers(pbIds);
         TestdataUtility.insertSub();
    }
     @IsTest public static void testSubscription() 
     {
         
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Product2 prd1 = [select Name,ProductCode,ExternalId from Product2 where ExternalId ='Testplan1' LIMIT 1];
         List<PricebookEntry> stdPb1 = [select Id,Product2Id from PricebookEntry];
         Pricebook2 custmpbk = [select Id,Name,chargebeeapps__CB_Site__c from Pricebook2 where Name='CB Standard' LIMIT 1];
         //Opportunity[] opp = [select Id,Name from Opportunity];
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c,chargebeeapps__CB_Oppurtunity__c
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='Doing Great'];
         Test.startTest();
         PageReference pageRef = Page.Change_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',subid);//a0J2800000JDA74
         Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
         UpdateSub cbn = new UpdateSub();
         cbn.oldPlan='Testplan1';
         cbn.planOpts = new List<selectOption>();
         List<selectOption> testPlans =  cbn.planOpts;
         testPlans.add(new SelectOption('plan1','plan1'));
         testPlans.add(new SelectOption('plan2','plan2'));
         cbn.addons = new List<AddonResp>();
         List<AddonResp> selistTest = cbn.addons;
         AddonResp addonObj = new AddonResp('TestAddon7',1,200,false,1,1);
         selistTest.add(addonObj);
         UpdateSubController usc = new UpdateSubController();
         UpdateSubEstController uscEst = new UpdateSubEstController();
         UpdateSubEstUrlBuilder subUrl = new UpdateSubEstUrlBuilder();
         subUrl.planUnitPrice('price');
         subUrl.planSetupFee('price');
         subUrl.couponId(cp.Id);
         subUrl.poNum('123');
         subUrl.replaceAddons('addon');
         UpdateSubscriptionUrlBuilder urlBuild = new UpdateSubscriptionUrlBuilder();
         urlBuild.planUnitPrice('100');
         urlBuild.planSetupFee('20');
         urlBuild.billingCycles('1');
         urlBuild.poNum('123');
         
         Test.setMock(HttpCalloutMock.class, new MockUpSubResponseGenerator());
         cbn.preview();
         PageReference p = cbn.updateSub();
         cbn.cancel();
         Test.stopTest();
         system.assertEquals(p.getUrl(),'/'+subid);
         
     }
     
     @IsTest public static void testCheckout() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Product2 prd1 = [select Name,ProductCode,ExternalId from Product2 where ExternalId ='Testplan1' LIMIT 1];
         List<PricebookEntry> stdPb1 = [select Id,Product2Id from PricebookEntry];
         Pricebook2 custmpbk = [select Id,Name,chargebeeapps__CB_Site__c from Pricebook2 where Name='CB Standard' LIMIT 1];
         
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c,chargebeeapps__CB_Oppurtunity__c
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='Doing Great'];
         Test.startTest();                   
         PageReference pageRef = Page.Change_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',subid);
         Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
         UpdateSub cbn = new UpdateSub();
         cbn.oldPlan='Testplan1';
         //cbn.dispTxt = new List<String>();
         Test.setMock(HttpCalloutMock.class, new MockUpSubResponseGenerator());
         cbn.populate();
         PageReference p = cbn.updateSub();
         cbn.cancel();
         Test.stopTest();
         system.assertEquals(p.getUrl(),'/'+subid);
         
     }
     
    @IsTest public static void testUnsynced() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Product2 prd1 = [select Name,ProductCode,ExternalId from Product2 where ExternalId ='Testplan1' LIMIT 1];
         List<PricebookEntry> stdPb1 = [select Id,Product2Id from PricebookEntry];
         Pricebook2 custmpbk = [select Id,Name,chargebeeapps__CB_Site__c from Pricebook2 where Name='CB Standard' LIMIT 1];
         
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c,chargebeeapps__CB_Oppurtunity__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='Doing Great'];
         Test.startTest();                   
         PageReference pageRef = Page.Change_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',subid);
         Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
         UpdateSub cbn = new UpdateSub();
         cbn.oldPlan='Testplan1';
         //cbn.dispTxt = new List<String>();
         Test.setMock(HttpCalloutMock.class, new MockUpSubResponseGenerator());
         cbn.populate();
         PageReference p = cbn.updateSub();
         cbn.cancel();
         Test.stopTest();
         system.assertEquals(p.getUrl(),'/'+subid);
         
         
     }     
     
     @IsTest public static void testSubscriptionWithoutAddress() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Product2 prd1 = [select Name,ProductCode,ExternalId from Product2 where ExternalId ='Testplan1' LIMIT 1];
         List<PricebookEntry> stdPb1 = [select Id,Product2Id from PricebookEntry];
         Pricebook2 custmpbk = [select Id,Name,chargebeeapps__CB_Site__c from Pricebook2 where Name='CB Standard' LIMIT 1];
         
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c,chargebeeapps__CB_Oppurtunity__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='Doing Great'];             
         Test.startTest();
         PageReference pageRef = Page.Change_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',subid);
         Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
         UpdateSub cbn = new UpdateSub();
         cbn.oldPlan='Testplan1';
         //cbn.dispTxt = new List<String>();
         Test.setMock(HttpCalloutMock.class, new MockUpSubResponseGenerator());
         cbn.populate();
         PageReference p = cbn.updateSub();
         cbn.cancel();
         Test.stopTest();
         system.assertEquals(p.getUrl(),'/'+subid);
         
     }
     
     @IsTest public static void testErrSubscription() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Product2 prd1 = [select Name,ProductCode,ExternalId from Product2 where ExternalId ='Testplan1' LIMIT 1];
         List<PricebookEntry> stdPb1 = [select Id,Product2Id from PricebookEntry];
         Pricebook2 custmpbk = [select Id,Name,chargebeeapps__CB_Site__c from Pricebook2 where Name='CB Standard' LIMIT 1];
         
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c,chargebeeapps__CB_Oppurtunity__c 
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='Doing Great'];
         Test.startTest();
         PageReference pageRef = Page.Change_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',subid);
         Test.setMock(HttpCalloutMock.class, new ErrResponseGenerator());
         UpdateSub cbn = new UpdateSub();
         cbn.oldPlan='Testplan1';
         Test.setMock(HttpCalloutMock.class, new ErrResponseGenerator());
         cbn.dispTxt = new List<String>();
         cbn.addons = new List<AddonResp>();
         PageReference p = cbn.updateSub();
         cbn.cancel();
         Test.stopTest();
         system.assertEquals(p,null);
         
     }
    @IsTest public static void testSubscriptionStairType() 
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
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c,chargebeeapps__CB_Oppurtunity__c
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='Doing Great'];
		 Test.startTest();
         PageReference pageRef = Page.Change_Subscription;
         test.setCurrentPageReference(pageRef);        
         pageRef.getParameters().put('sub_id',subid);        
         Test.setMock(HttpCalloutMock.class, new MockRetNewResponseGenerator());
         UpdateSub cbn = new UpdateSub();
         cbn.oldPlan='Testplan4';
         cbn.oldPlanQuan = 3;
         cbn.val = 2;
         cbn.addonId = 0;        
         cbn.addonqty = 2;        
         Test.setMock(HttpCalloutMock.class, new MockUpSubResponseGenerator());        
         cbn.addons = new List<AddonResp>();
         List<AddonResp> selistTest = cbn.addons;
         AddonResp addonObj = new AddonResp('TestAddon8',3,200,false,1,1);
         selistTest.add(addonObj);
         cbn.CbPriceBookEntry();
         cbn.CbPriceBookEntryAddon();
         PageReference p = cbn.updateSub();
         Test.stopTest();
         system.assertEquals(p.getUrl(),'/'+subid);
         
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
         chargebeeapps__CB_Subscription__c sub = [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
                                                  chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c,chargebeeapps__CB_Oppurtunity__c
                                                  from chargebeeapps__CB_Subscription__c where Name='Hr5511nROMSd0r1urD' LIMIT 1];
         string subid = sub.Id;
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='Doing Great'];
		 Test.startTest();
         PageReference pageRef = Page.Change_Subscription;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',subid);        
         Test.setMock(HttpCalloutMock.class, new MockRetNewResponseGenerator());
         UpdateSub cbn = new UpdateSub();
         cbn.oldPlan='Testplan2';
         cbn.oldPlanQuan = 4;
         cbn.val = 3;
         cbn.addonId = 0;
         cbn.addonqty = 1;  
         cbn.canOverridePrice('Testplan2');
         Test.setMock(HttpCalloutMock.class, new MockUpSubResponseGenerator());
         cbn.addons = new List<AddonResp>();
         List<AddonResp> selistTest = cbn.addons;
         AddonResp addonObj = new AddonResp('TestAddon6',2,200,false,1,1);
         selistTest.add(addonObj);
         cbn.CbPriceBookEntry();
         cbn.CbPriceBookEntryAddon();
         PageReference p = cbn.updateSub();
         system.assertEquals(p.getUrl(),'/'+subid);
         //cbn.preview();
     }
}