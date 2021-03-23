@IsTest public with sharing class CreateQuoteControllerTest
{
@TestSetup public static void insertRecord()
{
	TestdataUtility.insertCustomSetting();
	TestdataUtility.insertSiteDetails();
	chargebeeapps__CB_Sites__c site = TestdataUtility.getSite();
	
	Contact[] contacts = TestdataUtility.insertContacts();
	Opportunity[] opt = TestdataUtility.insertOpportunity();
    Contact validcontact=TestdataUtility.getValidContact();
    TestdataUtility.associateContactToSite(site.Id,validcontact.Id);
	
	Product2[] prod = TestdataUtility.insertProducts();
	TestdataUtility.insertCoupons();
	List<string> extid = new List<string>();
	List<string> selectedIds = new List<string>();
	for(Product2 pr:prod)
	{
		string externalids = pr.ExternalId;
		extid.add(externalids);
		string plantype = pr.chargebeeapps__Recurring_charge_model__c;
		if(pr.chargebeeapps__Addon_Type__c != null)
		{
			string addonType = pr.chargebeeapps__Addon_Type__c;
			if(( addonType.equalsIgnoreCase('Tiered') || addonType.equalsIgnoreCase('StairStep')||addonType.equalsIgnoreCase('Volume')))
			{
				selectedIds.add(pr.Id);
			}
		}
		if((plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
		{
			selectedIds.add(pr.Id);
		}
	}
	List<string> pbIds = new List<string>();
	PricebookEntry[] pbentry = TestdataUtility.insertPBEntry(extid);
	PricebookEntry[] selctedprod = [select Id,product2Id from PricebookEntry where product2Id IN:selectedIds];
	for(PricebookEntry pb:selctedprod)
	{
		pbIds.add(pb.Id);
	}

	OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opt[1].Id,Quantity = 5,PricebookEntryId = pbentry[0].Id,TotalPrice = 5 * 100);

	insert oli1;
	TestdataUtility.insertCBTiers(pbIds);

}

@IsTest public static void testQuoteEnabled()
{
	
	Contact con = TestdataUtility.getValidContact();
	Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
	string oppid = opt.Id;
	string coid = con.Id;

	Test.startTest();
	PageReference pageRef = Page.Create_Quote;
	test.setCurrentPage(pageRef);
	pageRef.getParameters().put('opp_id',oppid);
	pageRef.getParameters().put('con_id',coid);
	pageRef.getParameters().put('domain','cbtest1');
	chargebeeapps.CreateQuoteController cbn = new chargebeeapps.CreateQuoteController();
	cbn.canOverride = true;
	PageReference checkPermission = cbn.checkPermissions();
	cbn.domain='cbtest1';
	cbn.selectedSiteName();
	cbn.plan = new chargebeeapps.PlanObject('Testplan1',1,100.0,'USD',0.0);
	Test.setMock(HttpCalloutMock.class, new Mocks.MockQuoteGenerator());
	cbn.createQuote();
	PageReference redirect = cbn.redirectToError('error', 'contact');
	cbn.addonOptions = new List<selectOption>();
	List<SelectOption> testAddons = cbn.addonOptions;
	testAddons.add(new SelectOption('addon1','addon1'));
	testAddons.add(new SelectOption('addon2','addon2'));
	cbn.couponOptions = new List<selectOption>();
	List<SelectOption> testCoupons = cbn.couponOptions;
	testCoupons.add(new SelectOption('coupon1','coupon1'));
	testCoupons.add(new SelectOption('coupon2','coupon2'));
	List<selectOption> multiSites = cbn.getSiteDetails();
	Integer callouts = Limits.getCallouts();
	system.debug('callouts--'+callouts);
	Test.stopTest();
	system.assertequals(2,callouts);
}


@IsTest public static void testQuote()
{
	
	Contact con = TestdataUtility.getValidContact();
	Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
	string oppid = opt.Id;
	string coid = con.Id;

	Test.startTest();
	PageReference pageRef = Page.Create_Quote;
	test.setCurrentPage(pageRef);
	pageRef.getParameters().put('opp_id',oppid);
	pageRef.getParameters().put('con_id',coid);
	pageRef.getParameters().put('domain','cbtest1');
	chargebeeapps.CreateQuoteController cbn = new chargebeeapps.CreateQuoteController();
	cbn.canOverride = true;
	PageReference checkPermission = cbn.checkPermissions();
	cbn.domain='cbtest1';
	cbn.selectedSiteName();
	cbn.plan = new chargebeeapps.PlanObject('Testplan1',1,100.0,'USD',0.0);
	Test.setMock(HttpCalloutMock.class, new Mocks.MockQuoteGenerator());
	cbn.createQuote();
	PageReference redirect = cbn.redirectToError('error', 'contact');
	cbn.addonOptions = new List<selectOption>();
	List<SelectOption> testAddons = cbn.addonOptions;
	testAddons.add(new SelectOption('addon1','addon1'));
	testAddons.add(new SelectOption('addon2','addon2'));
	cbn.couponOptions = new List<selectOption>();
	List<SelectOption> testCoupons = cbn.couponOptions;
	testCoupons.add(new SelectOption('coupon1','coupon1'));
	testCoupons.add(new SelectOption('coupon2','coupon2'));
	List<selectOption> multiSites = cbn.getSiteDetails();
	Integer callouts = Limits.getCallouts();
	system.debug('callouts--'+callouts);
	Test.stopTest();
	system.assertequals(2,callouts);
}
@IsTest public static void testQuote2()
{
	chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c where name='cbtest1'];
	Contact con = TestdataUtility.getValidContact();
	Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
	string oppid = opt.Id;
	string coid = con.Id;

	Test.startTest();
	PageReference pageRef = Page.Create_Quote;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('opp_id',oppid);
	pageRef.getParameters().put('con_id',coid);
	pageRef.getParameters().put('domain','cbtest1');
	Test.setMock(HttpCalloutMock.class, new Mocks.MockPlanGenerator());
	chargebeeapps.CreateQuoteController cbn = new chargebeeapps.CreateQuoteController();
	cbn.domain='cbtest1';
	cbn.selectedSiteName();
	cbn.plan = new chargebeeapps.PlanObject('Testplan1',1,100.0,'USD',0.0);
	cbn.siteId=sites.Id;
	cbn.CbPriceBookEntry();
	cbn.selList = new List<AddonObject>();
	List<AddonObject> selistTest = cbn.selList;
	AddonObject addonObj = new AddonObject('TestAddon8',1,1,50.00,false);
	selistTest.add(addonObj);
	cbn.addonId=1;
	cbn.CbPriceBookEntryAddon();
	Integer callouts = Limits.getCallouts();
	Test.stopTest();
	system.assertequals(1,callouts);
}

@IsTest public static void testQuoteVolume()
{
	chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c where name='cbtest1'];
	Contact con = TestdataUtility.getValidContact();
	Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
	string oppid = opt.Id;
	string coid = con.Id;

	Test.startTest();
	PageReference pageRef = Page.Create_Quote;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('opp_id',oppid);
	pageRef.getParameters().put('con_id',coid);
	pageRef.getParameters().put('domain','cbtest1');
	Test.setMock(HttpCalloutMock.class, new Mocks.MockPlanGenerator());
	chargebeeapps.CreateQuoteController cbn = new chargebeeapps.CreateQuoteController();
	cbn.domain='cbtest1';
	cbn.selectedSiteName();
	cbn.plan = new chargebeeapps.PlanObject('Testplan2',45,100.0,'USD',0.0);
	//cbn.addon = 'TestAddon7';
	cbn.addonId = 1;
	cbn.siteId=sites.Id;
	cbn.CbPriceBookEntry();
	cbn.selList = new List<AddonObject>();
	List<AddonObject> selistTest = cbn.selList;
	AddonObject addonObj = new AddonObject('TestAddon7',1,1,50.00,false);
	selistTest.add(addonObj);
	cbn.CbPriceBookEntryAddon();
	Integer callouts = Limits.getCallouts();
	Test.stopTest();
	system.assertequals(1,callouts);

}

@IsTest public static void testAttachedAddons()
{
	chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c where name='cbtest1'];
	Contact con = TestdataUtility.getValidContact();
	Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
	string oppid = opt.Id;
	string coid = con.Id;

	Test.startTest();
	PageReference pageRef = Page.Create_Quote;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('opp_id',oppid);
	pageRef.getParameters().put('con_id',coid);
	pageRef.getParameters().put('domain','cbtest1');
	Test.setMock(HttpCalloutMock.class, new Mocks.MockPlanGenerator());
	chargebeeapps.CreateQuoteController cbn = new chargebeeapps.CreateQuoteController();
	cbn.plan = new chargebeeapps.PlanObject('Testplan3',45,100.0,'USD',0.0);
	cbn.canOverride =false;
	cbn.siteId=sites.Id;
	cbn.addonId = 1;
	cbn.coupon = 'cbdemo_fitfreak1';
	cbn.domain='cbtest1';

	cbn.planOptions = new List<selectOption>();
	List<selectOption> testPlans =  cbn.planOptions;
	testPlans.add(new SelectOption('plan1','plan1'));
	testPlans.add(new SelectOption('plan2','plan2'));

	cbn.addonOptions = new List<selectOption>();
	List<SelectOption> testAddons = cbn.addonOptions;
	testAddons.add(new SelectOption('addon1','addon1'));
	testAddons.add(new SelectOption('addon2','addon2'));
	cbn.couponOptions = new List<selectOption>();

	cbn.CbPriceBookEntry();
	cbn.selList = new List<AddonObject>();
	List<AddonObject> selistTest = cbn.selList;
	AddonObject addonObj = new AddonObject('TestAddon8',1,1,50.00,false);
	selistTest.add(addonObj);

	Test.setMock(HttpCalloutMock.class, new MockRetrieveoupon());
	cbn.validate();
	Integer callouts = Limits.getCallouts();
	cbn.CbPriceBookEntryAddon();
	Test.stopTest();
	system.assertequals(1,callouts);

}
@IsTest public static void testAttachedAddonsStairType()
{
	chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c where name='cbtest1'];
	Contact con = TestdataUtility.getValidContact();
	Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
	string oppid = opt.Id;
	string coid = con.Id;

	Test.startTest();
	PageReference pageRef = Page.Create_Quote;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('opp_id',oppid);
	pageRef.getParameters().put('con_id',coid);
	pageRef.getParameters().put('domain','cbtest1');
	Test.setMock(HttpCalloutMock.class, new MockRetrievePlanResGenStairtype());
	chargebeeapps.CreateQuoteController cbn = new chargebeeapps.CreateQuoteController();
	cbn.plan = new chargebeeapps.PlanObject('Testplan4',45,100.0,'USD',0.0);
	cbn.siteId=sites.Id;
	cbn.addonId = 1;
	cbn.coupon = 'cbdemo_fitfreak1';
	cbn.domain='cbtest1';
	cbn.CbPriceBookEntry();
	List<AddonObject> selistTest1 = cbn.selListNonrecur;
	AddonObject addonObj1 = new AddonObject('TestAddon8',1,1,50.00,false);
	selistTest1.add(addonObj1);
	cbn.CbPriceBookEntryAddon1();

	Test.setMock(HttpCalloutMock.class, new MockRetrieveoupon());
	cbn.validate();
	Test.setMock(HttpCalloutMock.class, new Mocks.MockQuoteGenerator());
	PageReference p = cbn.createQuote();
	Test.stopTest();
	Integer callouts = Limits.getCallouts();
	system.assertequals(0,callouts);
}
@IsTest public static void testAttachedAddonsVolType()
{
	chargebeeapps__CB_Sites__c sites = [select name from chargebeeapps__CB_Sites__c where name='cbtest1'];
	Contact con = TestdataUtility.getValidContact();
	Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
	string oppid = opt.Id;
	string coid = con.Id;

	Test.startTest();
	PageReference pageRef = Page.Create_Quote;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('opp_id',oppid);
	pageRef.getParameters().put('con_id',coid);
	pageRef.getParameters().put('domain','cbtest1');
	Test.setMock(HttpCalloutMock.class, new MockRetrievePlanResGenVol());
	chargebeeapps.CreateQuoteController cbn = new chargebeeapps.CreateQuoteController();
	cbn.plan = new chargebeeapps.PlanObject('Testplan2',45,100.0,'USD',0.0);
	cbn.siteId=sites.Id;
	cbn.addonId = 1;
	cbn.coupon = 'cbdemo_fitfreak1';
	cbn.domain='cbtest1';
	cbn.CbPriceBookEntry();
	List<AddonObject> selistTest1 = cbn.selListNonrecur;
	AddonObject addonObj1 = new AddonObject('TestAddon6',1,1,50.00,false);
	selistTest1.add(addonObj1);
	cbn.CbPriceBookEntryAddon1();
	Integer callouts = Limits.getCallouts();
	Test.stopTest();
	system.assertequals(1,callouts);

}

@IsTest public static void testProductServiceMandatoryAddon()
{
	Test.startTest();
	Test.setMock(HttpCalloutMock.class, new Mocks.MockPlanGenerator());
	Map<string,List<string> > result = ProductService.getMandatoryAddon('test-mandatory-recommended', 'cbtest1');
	System.assertEquals(3, result.size());
	System.assertEquals(1, result.get('mandatory').size());
	System.assertEquals(1, result.get('recommended').size());
	System.assertEquals(3, result.get('applicable').size());
	Test.stopTest();
}

@IsTest public static void testPlanObject()
{
	PlanObject plan = new PlanObject('Testplan4', 1, 10, 'USD', 0);
	System.assertEquals('Testplan4', plan.cbId);
	plan.model = 'Tiered';
	System.assertEquals(false, plan.canOverridePrice);
	System.assertEquals(true, plan.displaytiericon);
	System.assertEquals(true, plan.showUnit);
	System.assertEquals(true, plan.displayQuantity);

	plan.model = 'Stairstep';
	System.assertEquals(false, plan.canOverridePrice);
	System.assertEquals(true, plan.displaytiericon);
	System.assertEquals(false, plan.showUnit);
	System.assertEquals(true, plan.displayQuantity);

	plan.model = 'Volume';
	System.assertEquals(false, plan.canOverridePrice);
	System.assertEquals(false, plan.displaytiericon);
	System.assertEquals(false, plan.showUnit);
	System.assertEquals(true, plan.displayQuantity);

	plan.model = 'Flat_Fee';
	System.assertEquals(true, plan.canOverridePrice);
	System.assertEquals(false, plan.displaytiericon);
	System.assertEquals(false, plan.showUnit);
	System.assertEquals(false, plan.displayQuantity);

	plan.model = 'Stairstep';
	plan.qty = 0;
	System.assertEquals(false, plan.displaytiericon);
}

@IsTest public static void testAddonObject() {
	chargebeeapps.AddonObject addon = new chargebeeapps.AddonObject('test',1,1,10,false);
	addon.model = 'Tiered';
	System.assertEquals(false, addon.canOverridePrice);
	System.assertEquals(true, addon.displaytiericon);
	System.assertEquals(true, addon.showUnit);
	System.assertEquals(true, addon.displayQuantity);

	addon.model = 'Stairstep';
	System.assertEquals(false, addon.canOverridePrice);
	System.assertEquals(true, addon.displaytiericon);
	System.assertEquals(false, addon.showUnit);
	System.assertEquals(true, addon.displayQuantity);

	addon.model = 'Volume';
	System.assertEquals(false, addon.canOverridePrice);
	System.assertEquals(false, addon.displaytiericon);
	System.assertEquals(false, addon.showUnit);
	System.assertEquals(true, addon.displayQuantity);

	addon.model = 'Flat_Fee';
	System.assertEquals(true, addon.canOverridePrice);
	System.assertEquals(false, addon.displaytiericon);
	System.assertEquals(false, addon.showUnit);
	System.assertEquals(false, addon.displayQuantity);

	addon.model = 'Stairstep';
	addon.qty = 0;
	System.assertEquals(false, addon.displaytiericon);
}


@IsTest public static void testAddonResp() {
	chargebeeapps.AddonResp addon = new chargebeeapps.AddonResp('id',10,100L,true,1,10);
	addon.model = 'Tiered';
	System.assertEquals(false, addon.canOverridePrice);
	System.assertEquals(true, addon.displaytiericon);
	System.assertEquals(true, addon.showUnit);
	System.assertEquals(true, addon.displayQuantity);

	addon.model = 'Stairstep';
	System.assertEquals(false, addon.canOverridePrice);
	System.assertEquals(true, addon.displaytiericon);
	System.assertEquals(false, addon.showUnit);
	System.assertEquals(true, addon.displayQuantity);

	addon.model = 'Volume';
	System.assertEquals(false, addon.canOverridePrice);
	System.assertEquals(false, addon.displaytiericon);
	System.assertEquals(false, addon.showUnit);
	System.assertEquals(true, addon.displayQuantity);

	addon.model = 'Flat_Fee';
	System.assertEquals(true, addon.canOverridePrice);
	System.assertEquals(false, addon.displaytiericon);
	System.assertEquals(false, addon.showUnit);
	System.assertEquals(false, addon.displayQuantity);

	addon.model = 'Stairstep';
	addon.quan = 0;
	System.assertEquals(false, addon.displaytiericon);
}

@IsTest public static void testCreateQuoteForUpdateSubBuilder() {
	EndPoint ep = EndPointsIndex.update_subscription_quote;
	ep.domainName('cbtest1');
	CreateQuoteForUpdateSubUrlBuilder builder = new CreateQuoteForUpdateSubUrlBuilder(ep);
	builder.subscriptionid('test')
	.planId('Testplan4')
	.planQuan('10')
	.planUnitPrice('10')
	.billingCycles('2')
	.couponId('Doing Great')
	.replaceAddons('true');

	String ustring = builder.ustring;
	System.assertNotEquals(null, ustring);
}


@IsTest public static void testCreateQuoteForCreateSubBuilder() {
	EndPoint ep = EndPointsIndex.create_subscription_quote;
	ep.domainName('cbtest1');
	CreateQuoteUrlBuilder builder = new CreateQuoteUrlBuilder(ep);
	builder.planId('Testplan4')
	.planQuan('10')
	.planUnitPrice('10')
	.planSetupFee('100')
	.billingCycles('2')
	.couponId('Doing Great');

	String ustring = builder.ustring;
	System.assertNotEquals(null, ustring);
}

@IsTest public static void testUpdateSubUrlBuilder() {
	EndPoint ep = EndPointsIndex.update_sub_url;
	ep.domainName('cbtest1');
	UpdateSubUrlBuilder builder = new UpdateSubUrlBuilder(ep);
	builder.planId('Testplan4')
	.planQuan('10')
	.planUnitPrice('10')
	.planSetupFee('100')
	.billingCycles('2')
	.poNum('test')
	.couponId('Doing Great')
	.prorate('true')
	.endOfTerm('true')
	.invoiceImmediately('test');

	String ustring = builder.ustring;
	System.assertNotEquals(null, ustring);
}

/*@IsTest public static void testCouponService() {

        chargebeeapps__Coupon__c coupon = chargebeeapps.CouponService.getCoupon('cbdemo_fitfreak1','cbtest1');
        System.assertEquals('cbdemo_fitfreak1', coupon.chargebeeapps__CB_Id__c);*/

/*Test.setMock(HttpCalloutMock.class, new Mocks.MockQuoteGenerator());
   Map<String, Object> couponObj = chargebeeapps.CouponService.getCouponDetails('cbdemo_fitfreak1','cbtest1');
   System.assertEquals('cbdemo_fitfreak1', couponObj.get('id'));

   couponObj = chargebeeapps.CouponService.getCouponDetails('-1','cbtest1');
   System.assertEquals(null, couponObj);

   public static Integer calculateSubscriptionAmount(chargebeeapps.PlanObject plan, List<chargebeeapps.AddonObject> addons, String siteId){
   public static Integer getTotalAmount(Integer quantity,Decimal totalPrice,string cbId,string type, String siteId){
   public static boolean validateCoupon(String coupon, String plan, List<AddonObject> addons, Map<String, Object>  couponObj){
   public static Decimal applyCoupon(Map<String,Object> coupon, String cbId,Decimal price,String type, Integer subscriptionValueCents){
   public static Decimal calculateDiscountInPercent(Map<String,Object> coupon,Integer priceInCents)
   }*/

}