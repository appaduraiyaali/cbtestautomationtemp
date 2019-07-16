@IsTest public with sharing class CreateQuoteForUpdateSubscriptionTest {
@TestSetup public static void insertRecord()
{
	TestdataUtility.insertCustomSetting();
	TestdataUtility.insertSiteDetails();
	chargebeeapps__CB_Sites__c sites = TestdataUtility.getSites();
	
	Contact[] contacts = TestdataUtility.insertContacts();
	Opportunity[] opt = TestdataUtility.insertOpportunity();
	chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites.Id,contacts[0].Id);
	Product2[] prod = TestdataUtility.insertProducts();
	chargebeeapps__Coupon__c cpn = new chargebeeapps__Coupon__c(Name='Doing Great',chargebeeapps__CB_Coupon_Id__c='cbdemo_great',
	                                                            chargebeeapps__CB_Id__c='cbdemo_great',chargebeeapps__Coupon_Id__c='cbdemo_great',
	                                                            chargebeeapps__CB_Site__c=sites.Id,chargebeeapps__Status__c='ACTIVE');
	insert cpn;

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
	TestdataUtility.insertSub();
}
@IsTest public static void testSubscription()
{
	chargebeeapps__CB_Subscription__c sub = TestdataUtility.getSubscription('Hr5511nROMSd0r1urD' );
	string subid = sub.Id;
	chargebeeapps__Coupon__c cp = TestdataUtility.getCoupon('Doing Great');
	Test.startTest();
	PageReference pageRef = Page.CreateQuoteForUpdateSubscription;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('sub_id',subid);
	Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
	CreateQuoteForUpdateSubscription cbn = new CreateQuoteForUpdateSubscription();
	cbn.oldPlan='Testplan1';
	cbn.planOpts = new List<selectOption>();
	List<selectOption> testPlans =  cbn.planOpts;
	testPlans.add(new SelectOption('plan1','plan1'));
	testPlans.add(new SelectOption('plan2','plan2'));
	cbn.addons = new List<AddonResp>();
	List<AddonResp> selistTest = cbn.addons;
	AddonResp addonObj = new AddonResp('TestAddon7',1,200,false,1,1);
	selistTest.add(addonObj);
	Test.setMock(HttpCalloutMock.class, new Mocks.MockQuoteForUpdateSubscriptionGenerator());
	PageReference p = cbn.createQuote();
	Test.stopTest();
	system.assertEquals(p.getUrl(),'/'+subid);
}

@IsTest public static void testCheckout()
{
	chargebeeapps__CB_Subscription__c sub = TestdataUtility.getSubscription('Hr5511nROMSd0r1urD' );
	string subid = sub.Id;
	chargebeeapps__Coupon__c cp = TestdataUtility.getCoupon('Doing Great');
    Test.startTest();
	PageReference pageRef = Page.CreateQuoteForUpdateSubscription;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('sub_id',subid);
	Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
	CreateQuoteForUpdateSubscription cbn = new CreateQuoteForUpdateSubscription();
	cbn.oldPlan='Testplan1';
	Test.setMock(HttpCalloutMock.class, new Mocks.MockQuoteForUpdateSubscriptionGenerator());
	PageReference p = cbn.createQuote();
	Test.stopTest();
	system.assertEquals(p.getUrl(),'/'+subid);

}

@IsTest public static void testUnsynced()
{
	chargebeeapps__CB_Subscription__c sub = TestdataUtility.getSubscription('Hr5511nROMSd0r1urD' );
	string subid = sub.Id;
	chargebeeapps__Coupon__c cp = TestdataUtility.getCoupon('Doing Great');
    Test.startTest();
	PageReference pageRef = Page.CreateQuoteForUpdateSubscription;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('sub_id',subid);
	Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
	CreateQuoteForUpdateSubscription cbn = new CreateQuoteForUpdateSubscription();
	cbn.oldPlan='Testplan1';
	Test.setMock(HttpCalloutMock.class,new Mocks.MockQuoteForUpdateSubscriptionGenerator());
	PageReference p = cbn.createQuote();
	Test.stopTest();
	system.assertEquals(p.getUrl(),'/'+subid);


}

@IsTest public static void testSubscriptionStairType()
{
	chargebeeapps__CB_Subscription__c sub = TestdataUtility.getSubscription('Hr5511nROMSd0r1urD' );
	string subid = sub.Id;
	chargebeeapps__Coupon__c cp = TestdataUtility.getCoupon('Doing Great');
    Test.startTest();
	PageReference pageRef = Page.CreateQuoteForUpdateSubscription;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('sub_id',subid);
	Test.setMock(HttpCalloutMock.class, new MockRetNewResponseGenerator());
	CreateQuoteForUpdateSubscription cbn = new CreateQuoteForUpdateSubscription();
	cbn.oldPlan='Testplan4';
	cbn.oldPlanQuan = 3;
	cbn.val = 2;
	cbn.addonId = 0;
	cbn.addonqty = 2;
	Test.setMock(HttpCalloutMock.class,new Mocks.MockQuoteForUpdateSubscriptionGenerator());
	cbn.addons = new List<AddonResp>();
	List<AddonResp> selistTest = cbn.addons;
	AddonResp addonObj = new AddonResp('TestAddon8',3,200,false,1,1);
	selistTest.add(addonObj);
	cbn.CbPriceBookEntry();
	cbn.CbPriceBookEntryAddon();
	PageReference p = cbn.createQuote();
	Test.stopTest();
	system.assertEquals(p.getUrl(),'/'+subid);

}
@IsTest public static void testSubscriptionVolType()
{
	chargebeeapps__CB_Subscription__c sub = TestdataUtility.getSubscription('Hr5511nROMSd0r1urD' );
	string subid = sub.Id;
	chargebeeapps__Coupon__c cp = TestdataUtility.getCoupon('Doing Great');
    Test.startTest();
	PageReference pageRef = Page.CreateQuoteForUpdateSubscription;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('sub_id',subid);
	Test.setMock(HttpCalloutMock.class, new MockRetNewResponseGenerator());
	CreateQuoteForUpdateSubscription cbn = new CreateQuoteForUpdateSubscription();
	cbn.oldPlan='Testplan2';
	cbn.oldPlanQuan = 4;
	cbn.val = 3;
	cbn.addonId = 0;
	cbn.addonqty = 1;
	cbn.canOverridePrice('Testplan2');
	Test.setMock(HttpCalloutMock.class,new Mocks.MockQuoteForUpdateSubscriptionGenerator());
	cbn.addons = new List<AddonResp>();
	List<AddonResp> selistTest = cbn.addons;
	AddonResp addonObj = new AddonResp('TestAddon6',2,200,false,1,1);
	selistTest.add(addonObj);
	cbn.CbPriceBookEntry();
	cbn.CbPriceBookEntryAddon();
	PageReference p = cbn.createQuote();
	Test.stopTest();
	system.assertEquals(p.getUrl(),'/'+subid);
}

@IsTest public static void testOpportunityStage()
{
	String stageName = CreateQuoteForUpdateSubscription.getLowestNonZeroProbabilityStage();
	System.assertNotEquals(null, stageName);
}

@IsTest public static void testRemoveElementFromList()
{
	List<SelectOption> lst = new List<System.SelectOption>();
	lst.add(new SelectOption('plan1','plan1'));
	lst.add(new SelectOption('plan2','plan2'));
	lst = CreateQuoteForUpdateSubscription.removeElementFromlist('plan1', lst);
	System.assertEquals(1, lst.size());
}

}