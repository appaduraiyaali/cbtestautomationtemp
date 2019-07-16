@IsTest public with sharing class CBManageProdTest {
    
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c sites = TestdataUtility.getSites();
         
         Opportunity[] opt = TestdataUtility.insertOpportunity();
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
         system.debug('selctedprod--'+selctedprod);
         for(PricebookEntry pb:selctedprod)
         {
             string pid = pb.Id;
             pbIds.add(pid);
              
         }
         
         OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opt[1].Id,Quantity = 5,PricebookEntryId = pbentry[1].Id,TotalPrice = 5 * 100);
            
         insert oli1;
         
         OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opt[1].Id,Quantity = 5,PricebookEntryId = pbentry[5].Id,TotalPrice = 5 * 100);
            
         insert oli2;
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = TestdataUtility.insertCBTiers(pbIds);
         
    }
    
    @IsTest public static void testAttachedAddons() 
     {
         
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='cbdemo_fitfreak1'];
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers;
        
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
         Test.startTest();
         PageReference pageRef = Page.CBManageProduct;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockRetrievePlanResGenerator());
         CBManageProds cbp = new CBManageProds();
         cbp.plans='Testplan3';
         cbp.JsonMap ='test';
         cbp.canOverride =false;
         cbp.siteId=sites.Id;
         cbp.addon = 'TestAddon7';
         cbp.addonId = 1;
         cbp.coupon = 'cbdemo_fitfreak1';
         
         cbp.options3 = new List<selectOption>();
         List<selectOption> testPlans =  cbp.options3;
         testPlans.add(new SelectOption('plan1','plan1'));
         testPlans.add(new SelectOption('plan2','plan2')); 
         
         cbp.addonOptions = new List<selectOption>();
         List<SelectOption> testAddons = cbp.addonOptions;
         testAddons.add(new SelectOption('addon1','addon1'));
         testAddons.add(new SelectOption('addon2','addon2'));
         cbp.couponOptions = new List<selectOption>();
         
         cbp.CbPriceBookEntry();
         cbp.selList = new List<AddonObject>();
         List<AddonObject> selistTest = cbp.selList;
         AddonObject addonObj = new AddonObject('TestAddon8',1,1,50.00,false);
         selistTest.add(addonObj);
         cbp.showPriceTiers();
         cbp.hidePriceTiers();
         Test.setMock(HttpCalloutMock.class, new MockRetrieveoupon());
         cbp.validate();
         Integer callouts = Limits.getCallouts();
         cbp.CbPriceBookEntryAddon();
         //chargebeeapps.CouponService.getTotalAmount( 1, 50.00, 'tiered-additional', 'addon', 'cbtest1');
         Test.stopTest();
         system.assertequals(1,callouts);
         
    }
    @IsTest public static void testAttachedAddonsStairType() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='cbdemo_fitfreak1'];
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers;
        
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
         Test.startTest();
         PageReference pageRef = Page.CBManageProduct;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockRetrievePlanResGenStairtype());
         CBManageProds cbp = new CBManageProds();
         cbp.plans='Testplan1';
         cbp.siteId=sites.Id;
         cbp.addon = 'TestAddon8';
         cbp.addonId = 1;
         cbp.coupon = 'cbdemo_fitfreak1';
         cbp.CbPriceBookEntry();
         List<AddonObject> selistTest1 = cbp.selListNonrecur;
         AddonObject addonObj1 = new AddonObject('TestAddon8',1,1,50.00,false);
         selistTest1.add(addonObj1);
         cbp.CbPriceBookEntryAddon1();
         
         Test.setMock(HttpCalloutMock.class, new MockRetrieveoupon());
         cbp.validate();
         cbp.saveObjects();
         List<Id> ids = new List<Id>();
         ids.add(opt.Id);
         List<OpportunityLineItem> oppItem = [select Quantity,UnitPrice,Product2Id,Discount,OpportunityId,PricebookEntryId from OpportunityLineItem where OpportunityId IN: ids];
         Test.stopTest();
         system.assertEquals(oppItem[0].OpportunityId, opt.Id);

     }
    @IsTest public static void testAttachedAddonsVolType() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='cbdemo_fitfreak1'];
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers;
        
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
         Test.startTest();
         PageReference pageRef = Page.CBManageProduct;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockRetrievePlanResGenVol());
         CBManageProds cbp = new CBManageProds();
         cbp.plans='Testplan2';
         cbp.siteId=sites.Id;
         cbp.addon = 'TestAddon6';
         cbp.addonId = 1;
         cbp.coupon = 'cbdemo_fitfreak1';
         cbp.CbPriceBookEntry();
         List<AddonObject> selistTest1 = cbp.selListNonrecur;
         AddonObject addonObj1 = new AddonObject('TestAddon6',1,1,50.00,false);
         selistTest1.add(addonObj1);
         cbp.CbPriceBookEntryAddon1();
         Test.setMock(HttpCalloutMock.class, new MockRetrieveoupon());
         cbp.validate();
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(2,callouts);
         

     }
    @IsTest public static void testOpportunity() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='cbdemo_fitfreak1'];
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers;
        
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
         Test.startTest();
         PageReference pageRef = Page.CBManageProduct;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockRetrievePlanResGenVol());
         CBManageProds cbp = new CBManageProds();
         cbp.plans='Testplan2';
         cbp.siteId=sites.Id;
         cbp.addon = 'TestAddon6';
         cbp.addonId = 1;
         cbp.coupon = 'cbdemo_fitfreak1';
         cbp.CbPriceBookEntry();
         List<AddonObject> selistTest1 = cbp.selList;
         cbp.populateAddonList();
         List<string> temp=new List<String>();
         temp.add('addont');
         cbp.filladdons(temp);
         AddonObject addonObj1 = new AddonObject('TestAddon6',1,1,50.00,false);
         selistTest1.add(addonObj1);
         Test.setMock(HttpCalloutMock.class, new MockRetrieveoupon());
         cbp.validate();
         cbp.saveObjects();
         cbp.CbPriceBookEntryAddon();
         List<Id> ids = new List<Id>();
         ids.add(opt.Id);
         List<OpportunityLineItem> oppItem = [select Quantity,UnitPrice,Product2Id,Discount,OpportunityId,PricebookEntryId from OpportunityLineItem where OpportunityId IN: ids];
         Test.stopTest();
         system.assertEquals(oppItem[0].OpportunityId, opt.Id);
     }
    @IsTest public static void testFlatfee() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='cbdemo_fitfreak1'];
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp2' LIMIT 1];
         
         Product2[] prd = [select Name,ExternalId from Product2 ];
         system.debug('prd--'+prd); 
         Pricebook2 pricebk = [select Id,Name,chargebeeapps__CB_Site__c from Pricebook2 where Name='CB Standard'];
         //Opportunity opt = TestdataUtility.insertOpportunity1(string.valueOf(pricebk.Id));
         system.debug('opt--'+opt);
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod[0]);
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
         OpportunityLineItem[] oitem = [select Id,OpportunityId,PricebookEntryId from OpportunityLineItem];
         system.debug('oli1--'+oitem);
         
         Test.startTest();
          PageReference pageRef = Page.CBManageProduct;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockRetrievePlanResGenVol());
         CBManageProds cbp = new CBManageProds();
         cbp.plans='Testplan2';
         cbp.siteId=sites.Id;
         cbp.addon = 'TestAddon5';
         cbp.addonId = 1;
         cbp.coupon = 'cbdemo_fitfreak1';
         //cbp.CbPriceBookEntry();
         List<AddonObject> selistTest1 = cbp.selListNonrecur;
         cbp.populateAddonList();
         List<string> temp=new List<String>();
         temp.add('addont');
         cbp.filladdons(temp);
         AddonObject addonObj1 = new AddonObject('TestAddon5',1,1,50.00,false);
         selistTest1.add(addonObj1);       
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(1,callouts);
         
     }
    @IsTest public static void testCoupons() 
     {
         Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         system.debug('acc id'+acc.Id);
         chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         chargebeeapps__Coupon__c cp = [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where Name='cbdemo_fitfreak2'];
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp2' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         system.debug('selctedprod--'+selctedprod);
         //chargebeeapps__CB_Pricing_Tiers__c[] cbtiers;
        
         chargebeeapps__CB_Pricing_Tiers__c[] cbtiers = [select Id,Name,chargebeeapps__ExternalId__c from  chargebeeapps__CB_Pricing_Tiers__c];
          OpportunityLineItem[] oitem = [select Id,OpportunityId,PricebookEntryId from OpportunityLineItem];
         
         Test.startTest();
         PageReference pageRef = Page.CBManageProduct;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);//0060K00000U7MfJ
         pageRef.getParameters().put('domain','cbtest1');
         Test.setMock(HttpCalloutMock.class, new MockRetrievePlanResGenVol());
         CBManageProds cbp = new CBManageProds();
         Map<String,String> temp  = cbp.PlanExternalIdVsChargeModel;
         cbp.plans='Testplan2';
         cbp.siteId=sites.Id;
         cbp.addon = 'TestAddon6';
         cbp.addonId = 1;
         Map<String,Object> couponobj = new Map<String,Object>();
         couponobj.put('discount_type','percentage');
         List<SelectOption> testCoupons = cbp.couponOptions;
         testCoupons.add(new SelectOption('coupon1','coupon1'));
         testCoupons.add(new SelectOption('coupon2','coupon2'));
         cbp.coupon = 'cbdemo_fitfreak2';
         cbp.CbPriceBookEntry();
         List<AddonObject> selistTest1 = cbp.selListNonrecur;
         AddonObject addonObj1 = new AddonObject('TestAddon6',1,1,50.00,false);
         selistTest1.add(addonObj1);
         Test.setMock(HttpCalloutMock.class, new MockRetrieveoupon());
         PageReference p = cbp.validate();
         cbp.validateCoupon();
         chargebeeapps.CouponService.calculateDiscountInPercent(couponobj,5);
         cbp.CbPriceBookEntryAddon1();
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(3,callouts);
         
         //system.assertEquals(p.geturl(), '/'+opt.Id);
         
     }
    
    
}