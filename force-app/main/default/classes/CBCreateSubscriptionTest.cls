@IsTest public with sharing class CBCreateSubscriptionTest 
{   
    private static chargebeeapps__CB_Sites__c defaultSite;
    private static chargebeeapps__CB_Sites__c secondarySite;    
    @TestSetup public static void populateTestRecords()
    {
        TestdataUtility.insertCustomSetting();
        TestdataUtility.insertSiteDetails();
        TestdataUtility.insertContacts();
        Opportunity[] opportunities = TestdataUtility.insertOpportunity();
        TestdataUtility.insertProducts('PLAN');
        TestdataUtility.insertProducts('ADDON'); 
        TestdataUtility.insertStandardPricebookEntries();
        defaultSite = TestdataUtility.getSite('cbtest1');
        secondarySite = TestdataUtility.getSite('yaalidemo-test');
        PricebookEntry[] defaultpbentries = TestdataUtility.insertPriceBookEntries(defaultSite.Id);         
        PricebookEntry[] secpbentries=TestdataUtility.insertPriceBookEntries(secondarySite.Id);                        
        TestdataUtility.insertCoupons();           
    }
    
    /* This function validate the data in CreateSubscription when the navigation 
     * is done from Opportunity Detail Page.
     * The expected and actual values are compared for the Contact and Opportunity.
     * Prerequisites: The user running this function has the permission for the Objects 
     * and Fields involved.
     */ 
    @isTest
    public static void validateDataFromOpportunity()
    {
        chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);        
	    Contact oppContact=oppContacts[0];
		TestDataUtility.insertOpportunityLineItems(testOpportunity[0].Id, defaultSite);        
        TestDataUtility.associateContactToSite(defaultSite.Id,oppContact.Id);
	    PageReference pr = new PageReference('/apex/Create_Subscription');
		pr.getParameters().put('opp_id',testOpportunity[0].Id);
		pr.getParameters().put('con_id',oppContact.Id);
		
		Test.setCurrentPageReference(pr);
	    
   		CBCreateSubscription cbs=new CBCreateSubscription();
        // SiteDetails autofill Validation
        List<selectOption> siteList=cbs.getSiteDetails();
        System.assert(siteList.size() == 1);
        System.assert(cbs.isSiteConnected);
        System.assert(siteList[0].getLabel() == defaultSite.Name);        
        // Opportunity and Contact auot fill Validation        
	    PageReference noerror=cbs.checkPermissions();        
	    System.debug('Error page ' + noerror);                
        System.debug(' ContactName Expected ' + cbs.con_id + ' Actual ' + oppContact.Id );
        System.debug(' OpportunityName Expected ' + cbs.opp_id + ' Actual ' + testOpportunity[0].Id );
        System.debug('IsSiteSelected ' + cbs.isSiteConnected + 'SelectedSiteName ' + cbs.selectedSites);        
	    System.assert(noerror == null); // When permission pass the test, return value is null
        System.assert(cbs.opp_id != null);
        System.assertEquals(cbs.opp_id, testOpportunity[0].Id);        
	    System.assertEquals(cbs.con_id, oppContact.Id);
        System.assert(cbs.oppOptions == null); 
        // Plans and Addon Autofill validation
       	System.debug('DefaultSiteId input to fetch PBEntries ' + defaultSite.Id + ' Name ' + defaultSite.Name);
        List<PriceBookEntry> pbEntriesActual=TestDataUtility.getPBEntryBySite(defaultSite.Id,'PLAN');                        
        System.debug(' ExpectedPlanConented Content ' + cbs.options3);
        System.debug(' pbEntriesActual->Size ' + pbEntriesActual.size() + ' plansExpected->SIze ' + cbs.options3.size() );
        System.assert(comparePlansSelectList(cbs.options3,pbEntriesActual)); // Plan selectlist from Controller matches the testdata
        validatePlanAddonsAutoFill(cbs);       
    }

     /* This function validate the data in CreateSubscription when the navigation 
     * is done from Account/Contact Detail Page.
     * The expected and actual values are compared for the Contact .
     * Prerequisites: The user running this function has the permission for the Objects 
     * and Fields involved.
     */ 
    @isTest
    public static void validateDataFromContact()
    {
   		chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);
	    Contact oppContact=oppContacts[0];
        TestDataUtility.associateContactToSite(defaultSite.Id,oppContact.Id);
	    PageReference pr = new PageReference('/apex/Create_Subscription');		
		pr.getParameters().put('con_id',oppContact.Id);		
		Test.setCurrentPageReference(pr);
	    CBCreateSubscription cbs=new CBCreateSubscription();
        // SiteDetails Validation
        List<selectOption> siteList=cbs.getSiteDetails();
        System.assert(siteList.size() == 1);
        System.assert(cbs.isSiteConnected);
        System.assert(siteList[0].getLabel() == defaultSite.Name);        
        // Opportunityn and Contact Validation        
	    PageReference noerror=cbs.checkPermissions();        
	    System.debug('Error page ' + noerror);                
        System.debug(' ContactName Expected ' + cbs.con_id + ' Actual ' + oppContact.Id );
        System.debug(' OpportunityName Expected ' + cbs.opp_id + ' Actual ' + testOpportunity[0].Id );
        System.debug('IsSiteSelected ' + cbs.isSiteConnected + 'SelectedSiteName ' + cbs.selectedSites);        
	    System.assert(noerror == null); // When permission pass the test, return value is null                
	    System.assertEquals(cbs.con_id, oppContact.Id);
        System.assert(cbs.oppOptions != null);       
        System.debug('CBS OppOptions ' + cbs.oppOptions);
        System.assert(compareOpptySelectList(cbs.oppOptions,testOpportunity)); // Test Opportunity matches the SelectList        
    }
   
    /** This function validates that the contents of the 
     * 'PLANS' selectlist loaded and the PriceBookEntries created
     * in this testclass match.
     * Returns : True - When RecordsMatch
     * 			 False - When the size or record are not equal.
     */ 
    private static boolean comparePlansSelectList(List<SelectOption> expectedPlanlist, List<PricebookEntry> actuallist)
    {
        boolean contentMatch=true;
        boolean sizematch=actuallist.size() == (expectedPlanlist.size() -1);
        if(!sizematch) return false;        
        List<String> planNamelist=new List<String>();
        for(PriceBookEntry thepbentry:actuallist)
        {
            planNamelist.add(thepbentry.product2.name);
        }        
        for(SelectOption singleoption:expectedPlanlist)
        {
            String planlabel=singleoption.getLabel();
            if(planlabel.equalsIgnoreCase('Select')){
                continue;
            }
            System.debug('PlanLabel ' + planlabel);
            boolean exists=planNamelist.contains(planlabel);
            if(!exists){
                contentMatch=false;                
                break;
            }            
        }    
        System.debug('Content Match ' + contentMatch);    
        return contentMatch;
    }
   	
     /** This function validates that the contents of the 
     * 'Opportunity' selectlist loaded with the Opportunities associated to the test Account created.
     * Returns : True - When RecordsMatch
     * 			 False - When the size or record are not equal.
     */    
    private static boolean compareOpptySelectList(List<SelectOption> expectedSelectList, List<Opportunity> actualOpptyList)
    {
        List<String> opptyNameList=new List<String>();
        for(Opportunity singleOppty:actualOpptyList)
        {
            opptyNameList.add(singleOppty.Name);
        }        
        boolean contentmatch=true;
        boolean sizematch=opptyNameList.size() == (expectedSelectList.size() -1);
        if(!sizematch) return false;        
        for(SelectOption singleoption:expectedSelectList)
        {
            String opplabel=singleoption.getLabel();
            if(opplabel.equalsIgnoreCase('Select')){
                continue;
            }
            System.debug('OppLabel ' + opplabel);
            boolean exists=opptyNameList.contains(opplabel);
            if(!exists){
                contentMatch=false;                
                break;
            }            
        }    
        System.debug('Content Match ' + contentMatch);    
        return contentMatch;
    }
    
    private static void validatePlanAddonsAutoFill(CBCreateSubscription cbs)
    {        
    	String expAutofillPlan='Flat_FeePLAN';    	   	    	
    	String expPlanprice='160.00';    	
        String expPlansetupCost='50.00';
    	// Plan Autofill Assertions
    	System.assertEquals(expAutofillPlan, cbs.plans);
        System.assertEquals(expPlanprice, cbs.planPrice);
        System.assert(cbs.planHasSetupCost);
        System.assertEquals(expPlansetupCost,cbs.planSetupCost);        
    	
    	// Addon Autofill Assertions
    	Integer associatedAddonsExpected=1;
    	System.assertEquals(associatedAddonsExpected,cbs.addonId);
    	String expectedAddonName='Per_UnitADDON';        
    	System.assertEquals(expectedAddonName,cbs.selList[0].addon);
        System.assertEquals(3,cbs.selList[0].status); //display Removeaddon
    }    
    
    
    private static void getPopulatedData()
    {
        chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);
	    Contact oppContact=oppContacts[0];
        List<PriceBookEntry> pbentryplan = TestDataUtility.getPBEntryBySite(defaultSite.Id,'PLAN');        
        TestdataUtility.insertOpportunityLineItem(testopportunity[0].Id,pbentryplan[0]);
        TestDataUtility.associateContactToSite(defaultSite.Id,oppContact.Id);
	    PageReference pr = new PageReference('/apex/Create_Subscription');
		pr.getParameters().put('opp_id',testOpportunity[0].Id);
		pr.getParameters().put('con_id',oppContact.Id);
		//pr.getParameters().put('domain',defaultSite.Id);
		Test.setCurrentPageReference(pr);	    
    }
    
    /* This function will simulate the 'Plan' change action for 
     * all the available pricing tiers from "Create Subscription" Page
     * and the impact on other sections in the page, like
     * Quantiy, Price, Tier Section
     */ 
    @isTest 
    public static void validatePlanChangeAction()
    {
        getPopulatedData();
        CBCreateSubscription cbs=new CBCreateSubscription();        
        Integer initialQuantity=10;        
        selectNChangePerUnitPlanQuantity(cbs);     
        cbs.pquan=initialQuantity;
        selectStairStepPlan(cbs);
        cbs.pquan=initialQuantity;
        selectTieredPlan(cbs);
        cbs.pquan=initialQuantity;
        selectVolumePlan(cbs);
    }    
    
    private static void selectNChangePerUnitPlanQuantity(CBCreateSubscription cbs)
    {        
        cbs.plans='Per_UnitPlan';        
        cbs.CbPriceBookEntry();
        System.debug(' PerUnitExpected: Price ' + cbs.planPrice + ' displayIcon ' + cbs.displayIcon 
                     + ' TierData ' + cbs.tierdata + ' showUnit ' + cbs.showUnit);        
        String expectedPrice='160.00'; //data populated in testsetup
        // Assertions
        System.assertEquals(expectedprice,cbs.planPrice);
        System.assert(cbs.tierdata == null);
        System.assert(!cbs.showUnit);
		Integer changedQty=10; 
        cbs.pquan=changedQty;// Quantity change trigger        
        cbs.CbPriceBookEntry();  
        expectedPrice='160.00'; //data populated in testsetup
        System.assertEquals(expectedPrice,cbs.planPrice); // PerUnitPlanPrice displayed does not change when Qty changes
        zeroQuantityCheck(cbs);
    }
    
    private static void selectStairStepPlan(CBCreateSubscription cbs)
    {
     	cbs.plans='StairstepPlan';        
        cbs.pquan=11;
        cbs.CbPriceBookEntry();
          System.debug(' StairStepPlanExpected: Price ' + cbs.planPrice + ' displayIcon ' + cbs.displayIcon 
                     + ' TierData ' + cbs.tierdata + ' showUnit ' + cbs.showUnit);  
        String expectedprice='150.00'; //data populated in testsetup        
        System.assertEquals(expectedprice,cbs.planPrice);
        System.assert(cbs.displayIcon);
        System.assert(cbs.tierdata != null);
		zeroQuantityCheck(cbs);
    }
    
	private static void selectTieredPlan(CBCreateSubscription cbs)
    {
     	cbs.plans='TieredPlan';
        Integer initialQuantity=11;        
        cbs.pquan=initialQuantity;
        cbs.CbPriceBookEntry();
          System.debug(' TieredPlanExpected: Price ' + cbs.planPrice + ' displayIcon ' + cbs.displayIcon 
                     + ' TierData ' + cbs.tierdata + ' showUnit ' + cbs.showUnit);  
        String expectedPrice='1750.00'; //data populated in testsetup        
        System.assertEquals(expectedprice,cbs.planPrice);
        System.assert(cbs.displayIcon);
        System.assert(cbs.tierdata != null);
    }
    
    private static void zeroQuantityCheck(CBCreateSubscription cbs)
    {
        Integer zeroquantity=0;
        cbs.pquan=zeroquantity;
        cbs.CbPriceBookEntry();
        System.assert(!cbs.displayIcon);
    }
    
    
    private static void selectVolumePlan(CBCreateSubscription cbs)
    {
        cbs.plans='VolumePlan';
        Integer initialQuantity=12;        
        cbs.pquan=initialQuantity;
        cbs.CbPriceBookEntry();
          //System.debug(' VolumePlanExpected: Price ' + cbs.planPrice + ' displayIcon ' + cbs.displayIcon 
            //         + ' TierData ' + cbs.tierdata + ' showUnit ' + cbs.showUnit);  
        String expectedPrice='1800.00';
        System.assertEquals(expectedprice,cbs.planPrice);
        System.assert(!cbs.displayIcon);
        System.assert(cbs.tierdata != null);
        zeroQuantityCheck(cbs);
    }
    
    @isTest 
    public static void validateAddonChangeAction()
    {
        getPopulatedData();
        CBCreateSubscription cbs=new CBCreateSubscription(); 
        System.debug('ValidateAddonChange ' + cbs.selList);
        selectPerUnitAddon(cbs,cbs.selList.size()-1);
        selectTieredDataAddon(cbs,0);
    }
    
    private static void selectPerUnitAddon(CBCreateSubscription cbs)
    {
    	selectPerUnitAddon(cbs,0);
    }  
    
    
    private static void selectPerUnitAddon(CBCreateSubscription cbs, Integer addOnIndex)
    {
        AddonObject expectedAddonB4Select=cbs.selList[addOnIndex];        
        // Assertion before changing the select list
        Decimal expectedPrice=160.00; //data populated in testsetup
        System.assert(expectedAddonB4Select.addon.equals('-1'));
        System.assert(expectedAddonB4Select.price == 0);
        cbs.selList[addOnIndex].addon='Per_Unitaddon';
        cbs.addonId=expectedAddonB4Select.id;
        cbs.CbPriceBookEntryAddon();                
        AddonObject addonAfterSelection=cbs.selList[addOnIndex];
        System.assert(addonAfterSelection.model.equals('Per_Unit'));
        System.assert(addonAfterSelection.price == expectedPrice);
        System.assert(addonAfterSelection.tierdata == null);
    }
    
    private static void selectTieredDataAddon(CBCreateSubscription cbs, Integer addOnIndex)
    {
        Decimal expectedPriceChange=160.00;
     	AddonObject addOnSelected=cbs.selList[addOnIndex];
		addOnSelected.addon='Volumeaddon';	        
        cbs.addonId=addOnSelected.Id;
        cbs.CBPriceBookEntryAddon();        
        System.assertEquals(expectedPriceChange,addOnSelected.price);
     	Integer changedQty=12;
        addOnSelected.qty=changedQty;
        expectedPriceChange=1800.00;
        cbs.CBPriceBookEntryAddon();        
        
        addOnSelected=cbs.selList[addOnIndex];
		addOnSelected.addon='Tieredaddon';	        
        cbs.addonId=addOnSelected.Id;
        cbs.CBPriceBookEntryAddon();
        expectedPriceChange=1900.00;        
		System.assertEquals(expectedPriceChange,addOnSelected.price);        
        System.assertEquals('Tiered',addOnSelected.model);
        
        addOnSelected=cbs.selList[addOnIndex];
		addOnSelected.addon='StairStepaddon';	        
        cbs.addonId=addOnSelected.Id;
        cbs.CBPriceBookEntryAddon();        
        expectedPriceChange=150.00;        
        System.assertEquals(expectedPriceChange,addOnSelected.price);
        System.assertEquals('Stairstep',addOnSelected.model);        
    }
    
    @isTest
    public static void saveRemoveAddOnsActions()
    {
        getPopulatedData();
        CBCreateSubscription cbs=new CBCreateSubscription();                
        saveAddons(cbs);
        removeAddons(cbs);
    }

    private static void saveAddons(CBCreateSubscription cbs)
    {
        cbs.values=cbs.selList.size();
        AddonObject defaultAddon=cbs.selList[0];
        System.assertEquals(cbs.selList.size(),1); // Addon Current Size is 1
        System.assertEquals(defaultAddon.status,2);
        selectPerUnitAddon(cbs);				   // Change the select list to 'PerUnit' 
        cbs.saveAddOns();						   // Click 'Add Addon
        System.assertEquals(cbs.selList.size(),2); // Assertion: size increases by 1	
        System.assertEquals(defaultAddon.status,3);      // Status changed from 2 (show 'Add Addon') to 3(show "Remove" Button)
        AddonObject newlyAdded=cbs.selList[1];
        System.assertEquals(newlyAdded.addon,'-1');
        System.assertEquals(newlyAdded.qty,1);
        System.assertEquals(newlyAdded.status,2);
        System.assertEquals(newlyAdded.id,2);
        selectTieredDataAddon(cbs,1);
        cbs.saveAddOns();
        System.debug(' Addon List from Controller ' + cbs.selList);
    }
    
    private static void removeAddons(CBCreateSubscription cbs)
    {
        cbs.values=1; // Remove the first element which is PerUnit AddonOn and verify its status
        cbs.delAddons();
        Integer expectedStatus=4;
        System.assertEquals(expectedStatus, cbs.selList[0].status);
        System.assertEquals('Per_Unitaddon', cbs.selList[0].addon);        
    }
	    
    
    /* When Action 'Create New Subscription' is clicked, 
     * We will setup Plan and Addons, other input parameters like 
     * validate the plan/addon and verify the data loaded in Preview page with the
     * Expected values for various scenarios.
     * 1. Invoice Now option with Immediate Effect or Future Date
     * 2. 
     */ 
    @isTest public static void previewInvNowFutureSubscription()
    {
        getPopulatedData();        
        CBCreateSubscription cbs=new CBCreateSubscription();
        /** Invoice Now Future Subscription **/
        Date futureDate=Date.today().addDays(1);
        cbs.sDateStr=((DateTime)futureDate).format('yyyy-MM-dd HH:mm'); // Set to future date
        cbs.invNow=true; // Invoice Now is enabled
        cbs.sameBillAddress=false;
        selectTieredPlan(cbs);
        saveAddons(cbs);        
        Test.startTest();
        MockEstSubResponseGenerator successResponse=new MockEstSubResponseGenerator(MockEstSubResponseGenerator.ResponseType.SUCCESS_FUTURESUBSCRIPTION);
        Test.setMock(HttpCalloutMock.class, successResponse);             
        cbs.preview();        
        Decimal expectedSubtotal=370.0;
        Decimal expectedTotal=370.0;        
        String expectedTabName='CHARGES ON ACTIVATION';
        Boolean expectedStDate=true; 
        String expectedDisplayText='There will be no immediate charges.An invoice for USD ' + String.valueOf(expectedTotal) +' will be generated upon activation';
        System.debug('InvoiceNowFutureSubscription: subtotal ' + cbs.subt + ' Total ' + cbs.tot + ' TablNme ' + cbs.tabName + ' DisplayText '
                    + cbs.displayText);        
        System.assert(cbs.showPopup);
        System.assertEquals(expectedTabName,cbs.tabName);
        System.assertEquals(expectedStDate,cbs.stdate);
        System.assertEquals(expectedSubtotal, cbs.subt);
        System.assertEquals(expectedTotal, cbs.tot);
       System.assertEquals(expectedDisplayText,cbs.displayText);
        Test.stopTest();
    }
    
    @isTest
    public static void previewInvNowImmediateSubscription()
    {
        getPopulatedData();        
        CBCreateSubscription cbs=new CBCreateSubscription();
        /*** InvoiceNow with Immediate Subscription **/        
        cbs.invNow=true;
        cbs.sDateStr=null;
        selectTieredPlan(cbs);        
        Test.startTest();
        MockEstSubResponseGenerator successResponse=new MockEstSubResponseGenerator(MockEstSubResponseGenerator.ResponseType.SUCCESS_INVNOW_IMMDSUBSCRIPTION);
        Test.setMock(HttpCalloutMock.class, successResponse);             
        cbs.preview();        
        String expectedTabName='IMMEDIATE CHARGES';
        Boolean expectedStDate=false;
        Decimal expectedSubtotal=100.0;
        Decimal expectedTotal=100.0;   
        String expectedDisplayText='An invoice for USD '+ String.valueOf(expectedTotal) +' will be generated immediately.';
        System.debug('InvoiceNowImmediateSubscription: subtotal ' + cbs.subt + ' Total ' + cbs.tot + ' TablNme ' + cbs.tabName + ' DisplayText '
                    + cbs.displayText);        
        System.assert(cbs.showPopup);
        System.assertEquals(expectedTabName,cbs.tabName);
        System.assertEquals(expectedStDate,cbs.stdate);
        System.assertEquals(expectedSubtotal, cbs.subt);
        System.assertEquals(expectedTotal, cbs.tot);
        System.assertEquals(expectedDisplayText,cbs.displaytext);
        Test.stopTest();
    }
    
    @IsTest
    public static void previewUnbilledCharges()
    {
        getPopulatedData();        
        CBCreateSubscription cbs=new CBCreateSubscription();
        /** Unbilled Charges **/
        cbs = new CBCreateSubscription();
        cbs.invNow=false;
        selectTieredPlan(cbs);
		Test.startTest();
        MockEstSubResponseGenerator successResponse=new MockEstSubResponseGenerator(MockEstSubResponseGenerator.ResponseType.SUCCESS_UNBILLEDCHARGES);
        Test.setMock(HttpCalloutMock.class, successResponse);             
        cbs.preview();                
        String expectedTabName='UNBILLED CHARGES';
        Decimal expectedSubtotal=100.0;
        Decimal expectedTotal=100.0;   
        String displayText='There are no charges. An amount of USD ' + expectedTotal + ' will be added to the upcoming invoice.';
        System.assert(cbs.showPopup);        
        Test.stopTest();
    }
    
     private static string pageRedirectdedUrl()
    {
        chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);
	    Contact oppContact=oppContacts[0];
        TestDataUtility.associateContactToSite(defaultSite.Id,oppContact.Id);
        
        PageReference pr = new PageReference('/apex/Create_Subscription');
		//pr.getParameters().put('opp_id',testOpportunity[0].Id);
		pr.getParameters().put('con_id',oppContact.Id);
		Test.setCurrentPageReference(pr);
        return oppContact.Id;
    }
    @isTest public static void checkoutSubscription()
    {
        
        getPopulatedData();       
        product2 plan = TestDataUtility.getSpecificProduct('Flat_Fee','PLAN');
        
        Test.startTest();
        
        CBCreateSubscription cbs=new CBCreateSubscription(); 
        cbs.plans = plan.ExternalId;
        system.assert(cbs.Plans!=null);
        //selectPerUnitAddon(cbs);
        cbs.invNow=true;
        Test.setMock(HttpCalloutMock.class, new MockCheckoutResponse1Generator('SUCCESS'));
        PageReference checkoutPage = cbs.checkout();
        system.debug('Expected redirect url--'+checkoutPage.getUrl());
        string checkouturl = checkoutPage.getUrl();
        system.assert(checkouturl.contains('/apex/chargebeeapps__CBCheckoutLink'));
        
        
        cbs=new CBCreateSubscription(); 
        cbs.plans='-1';
        Test.setMock(HttpCalloutMock.class, new MockCheckoutResponse1Generator('APIERROR'));
        PageReference redirectedurl = cbs.checkout();
        system.assertEquals(null,redirectedurl);
        
        Test.stopTest();
    
    }
    @isTest public static void cancelFromCreateSubscription()
    {
        
        string conid = pageRedirectdedUrl();
        CBCreateSubscription cbs=new CBCreateSubscription();
        PageReference cancelredirpage = cbs.cancel_page();
        system.assertequals('/'+conid,cancelredirpage.getUrl());
    }
    @isTest public static void confirmSubscription()
     {
      	chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);
	    Contact oppContact=oppContacts[0];
        TestDataUtility.associateContactToSite(defaultSite.Id,oppContact.Id);
        
        PageReference pr = new PageReference('/apex/Create_Subscription');
		pr.getParameters().put('opp_id',testOpportunity[0].Id);
		pr.getParameters().put('con_id',oppContact.Id);
        pr.getParameters().put('domain',defaultSite.Name);
		Test.setCurrentPageReference(pr);
       
        product2 plan = TestDataUtility.getSpecificProduct('Per_Unit','PLAN');
        
         Test.startTest();
         CBCreateSubscription cbs=new CBCreateSubscription();
         cbs.sameBillAddress=false;
         cbs.plans = plan.ExternalId;
         
         MockEstSubResponseGenerator successResponse=new MockEstSubResponseGenerator(MockEstSubResponseGenerator.ResponseType.SUCCESS_INVNOW_IMMDSUBSCRIPTION);
         Test.setMock(HttpCalloutMock.class, successResponse);   
         
         cbs.preview();  
         string expectedStatus = 'active';
         string expectedEntityType = 'plan';
         string expectedDescription = 'perunitplan';
         string expectedCurCode = 'USD';
         Double expectedUnitAmount = 100.00;
         string expectedQuantity = '1';
         Double expectedTotal = 100.00;
         Double expectedSubTotal = 100.00;
         cbs.selecttab();
         system.assert(cbs.tab1);
         system.assertEquals(expectedStatus, cbs.status);
         system.assertEquals(expectedEntityType, cbs.lts[0].etype);
         system.assertEquals(expectedDescription, cbs.lts[0].description);
         system.assertEquals(expectedCurCode, cbs.cc);
         system.assertEquals(expectedUnitAmount, cbs.lts[0].unitAmount);
         system.assertEquals(expectedQuantity, cbs.lts[0].quantity);
         
         cbs.selecttab1();
         system.assert(!cbs.tab1);
         system.assertEquals(expectedDescription, cbs.lts[0].description);
         system.assertEquals(expectedCurCode, cbs.cc);
         system.assertEquals(expectedUnitAmount, cbs.lts[0].unitAmount);
         system.assertEquals(expectedQuantity, cbs.lts[0].quantity);
         
         system.assertEquals(expectedTotal, cbs.tot);
         system.assertEquals(expectedSubTotal, cbs.subt);
         Test.setMock(HttpCalloutMock.class, new MockRetSubResponseGenerator());
         PageReference confirmsub = cbs.save();
         Test.stopTest();
         system.assertEquals('/'+testOpportunity[0].Id,confirmsub.getUrl());
     }
    @isTest public static void cancelConfirmPopup()
    {
        string conid = pageRedirectdedUrl();
        CBCreateSubscription cbs=new CBCreateSubscription();
        PageReference cancelfrompopup = cbs.Cancel();
        system.assert(!cbs.showPopup);
        system.assertequals('/apex/chargebeeapps__Create_Subscription?con_id='+conid,cancelfrompopup.getUrl());
        
    }
    /* This method creates a User with "Standard User" profile, which does not have permissions
      * for contact/Custom Objects. The context of execution is set to be the newly created User.
      * When "Create Subscription" button click is simulated from the above test user, this will
      * result in error page due to restricted access to the Contact Object.
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
         chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);
	    Contact oppContact=oppContacts[0];
        TestDataUtility.associateContactToSite(defaultSite.Id,oppContact.Id);
        
        PageReference pr = new PageReference('/apex/Create_Subscription');
		pr.getParameters().put('opp_id',testOpportunity[0].Id);
		pr.getParameters().put('con_id',oppContact.Id);
        pr.getParameters().put('domain',defaultSite.Name);
		Test.setCurrentPageReference(pr);
        CBCreateSubscription cbs=new CBCreateSubscription();
        PageReference checkpermission = cbs.checkPermissions();
        string redirToErrorUrl = checkpermission.getUrl();
        
        system.assert(redirToErrorUrl.contains('/apex/chargebeeapps__error'));  
         
         }
     }
    
    /**
     * Create a testContact and associate the testcontact to multiple Sites.
     * Simulate navigation to CreateSubscription Page using domain and contactId 
     * parameter. 
     * Validation : 
     * 		Verify the Plans/Addons associated to the domain passed are same as test Data.
     * 		Change the Site. This would trigger the reloading of Plans/Addons specific
     * to modified site. Verify the new Plans/Addons match the test data of secondary Site
     */
    @isTest
    public static void multipleSitesHandling()
    {
        chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);
	    Contact oppContact=oppContacts[0];
        chargebeeapps__CB_Sites__c secondarySite=TestDataUtility.getSite('yaalidemo-test');
        TestDataUtility.associateContactToSite(defaultSite.Id,oppContact.Id);
        TestDataUtility.associateContactToSite(secondarySite.Id,oppContact.Id); 
        // delete few records from the secondary site to compare the test data
        List<PricebookEntry> plansSecSite=TestDataUtility.getPBEntryBySite(secondarySite.Id,'PLAN');
        List<PricebookEntry> addonSecSite=TestDataUtility.getPBEntryBySite(secondarySite.Id,'ADDON');
        delete plansSecSite[1];delete plansSecSite[2];
        delete addonSecSite[1];delete addonSecSite[2];
        
	    PageReference pr = new PageReference('/apex/Create_Subscription');		
		pr.getParameters().put('con_id',oppContact.Id);	
        pr.getParameters().put('domain','cbtest1');	
		Test.setCurrentPageReference(pr);
	    CBCreateSubscription cbs=new CBCreateSubscription();        
        List<selectOption> siteList=cbs.getSiteDetails();
        System.debug('MultipleSiteHandling ' + siteList);
        System.debug('MultipleSiteHandling:IsSiteSelected ' + cbs.isSiteConnected + 'SelectedSiteName ' + cbs.selectedSites);        
        cbs.selectedSiteName();
        //Check the Plans and Adons of Site1        
        Integer expSitePlans=6;
        Integer expSiteAddons=6;
        System.assertEquals(expSitePlans,cbs.options3Cache.size());
        System.assertEquals(expSiteAddons,cbs.addonOptionsCache.size());
        cbs.selectedSites='yaalidemo-test';
        cbs.ChangeselectedSiteName();
		expSitePlans=4;
		expSiteAddons=4;        
		System.assertEquals(expSitePlans,cbs.options3Cache.size());
        System.assertEquals(expSiteAddons,cbs.addonOptionsCache.size());
    }
}