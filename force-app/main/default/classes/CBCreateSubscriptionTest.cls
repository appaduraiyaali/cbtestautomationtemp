@IsTest public with sharing class CBCreateSubscriptionTest 
{   
    private static chargebeeapps__CB_Sites__c defaultSite;
    private static chargebeeapps__CB_Sites__c secondarySite;
    private static Map<String,List<PriceBookEntry>> siteVsPriceBookEntries=new Map<String,List<PriceBookEntry>>();
    @TestSetup public static void populateTestRecords()
    {
        TestdataUtility.insertCustomSetting();
        TestdataUtility.insertSiteDetails();
        TestdataUtility.insertContacts();
        Opportunity[] opportunities = TestdataUtility.insertOpportunity();
        insertProducts('PLAN');
        insertProducts('ADDON'); 
        insertStandardPricebookEntries();
        defaultSite = TestdataUtility.getSite('cbtest1');
        secondarySite = TestdataUtility.getSite('yaalidemo-test');
        PricebookEntry[] defaultpbentries = insertPriceBookEntries(defaultSite.Id);         
        PricebookEntry[] secpbentries=insertPriceBookEntries(secondarySite.Id);        
        siteVsPriceBookEntries.put(secondarySite.Id, secpbentries);
        TestdataUtility.insertOpportunityLineItem(opportunities[0].Id,defaultpbentries[0].Id);        
        TestdataUtility.insertCoupons();           
    }
    
    /* This function validate the data in CreateSubscription when the navigation 
     * is done from Opportunity Detail Page.
     * The expected and actual values are compared for the Contact and Opportunity.
     * Prerequisites: The user running this function has the permission for the Objects 
     * and Fields involved.
     */ 
    @istest
    public static void validateDataFromOpportunity()
    {
   		chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);
	    Contact oppContact=oppContacts[0];
        OpportunityLineItem opplineitem = TestDataUtility.getOppLineItem(testOpportunity[0].Id);
        TestDataUtility.associateContactToSite(defaultSite.Id,oppContact.Id);
	    PageReference pr = new PageReference('/apex/Create_Subscription');
		pr.getParameters().put('opp_id',testOpportunity[0].Id);
		pr.getParameters().put('con_id',oppContact.Id);
		//pr.getParameters().put('domain',defaultSite.Id);
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
    }

     /* This function validate the data in CreateSubscription when the navigation 
     * is done from Account/Contact Detail Page.
     * The expected and actual values are compared for the Contact .
     * Prerequisites: The user running this function has the permission for the Objects 
     * and Fields involved.
     */ 
    @istest
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
		//pr.getParameters().put('domain',defaultSite.Id);
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
    
    private static void getPopulatedData()
    {
        chargebeeapps__CB_Sites__c defaultSite=TestDataUtility.getSite();
    	Account[] accountslist=TestDataUtility.getAccounts();
    	Account oppAccount=accountslist[0];
    	List<Opportunity> testOpportunity=TestDataUtility.getOpportunities(oppAccount.Id);   
	    List<Contact> oppContacts=TestDataUtility.getContactFromAccount(oppAccount.Id);
	    Contact oppContact=oppContacts[0];
        OpportunityLineItem opplineitem = TestDataUtility.getOppLineItem(testOpportunity[0].Id);
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
        Map<String,List<chargebeeapps__CB_Pricing_Tiers__c>> pnameVsPt=getPricingTiers('PLAN');
        selectNChangePerUnitPlanQuantity(cbs);     
        cbs.pquan=initialQuantity;
        selectStairStepPlan(cbs,pnameVsPt);
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
    
    private static void selectStairStepPlan(CBCreateSubscription cbs,Map<String,List<chargebeeapps__CB_Pricing_Tiers__c>> pnameVsPt)
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
        zeroQuantityCheck(cbs);
        
    }
    
    private static void zeroQuantityCheck(CBCreateSubscription cbs)
    {
        Integer zeroquantity=0;
        cbs.pquan=zeroquantity;
        cbs.CbPriceBookEntry();
        System.assert(!cbs.displayIcon);
    }
    
    private static void negativeQuantityCheck(CBCreateSubscription cbs)
    {
        
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
        selectPerUnitAddon(cbs);
        selectTieredDataAddon(cbs);
    }
    
    private static void selectPerUnitAddon(CBCreateSubscription cbs)
    {
        AddonObject expectedAddonB4Select=cbs.selList[0];        
        // Assertion before changing the select list
        Decimal expectedPrice=160.00; //data populated in testsetup
        System.assert(expectedAddonB4Select.addon.equals('-1'));
        System.assert(expectedAddonB4Select.price == 0);
        cbs.selList[0].addon='Per_Unitaddon';
        cbs.addonId=expectedAddonB4Select.id;
        cbs.CbPriceBookEntryAddon();                
        AddonObject addonAfterSelection=cbs.selList[0];
        System.assert(addonAfterSelection.model.equals('Per_Unit'));
        System.assert(addonAfterSelection.price == expectedPrice);
        System.assert(addonAfterSelection.tierdata == null);
    }
    
    private static void selectTieredDataAddon(CBCreateSubscription cbs)
    {
        Decimal expectedPriceChange=160.00;
     	AddonObject addOnSelected=cbs.selList[0];
		addOnSelected.addon='Volumeaddon';	        
        cbs.addonId=addOnSelected.Id;
        cbs.CBPriceBookEntryAddon();        
        System.assertEquals(expectedPriceChange,addOnSelected.price);
     	Integer changedQty=12;
        addOnSelected.qty=changedQty;
        expectedPriceChange=1800.00;
        cbs.CBPriceBookEntryAddon();        
        
        addOnSelected=cbs.selList[0];
		addOnSelected.addon='Tieredaddon';	        
        cbs.addonId=addOnSelected.Id;
        cbs.CBPriceBookEntryAddon();
        expectedPriceChange=1500.00;        
		System.assertEquals(expectedPriceChange,addOnSelected.price);        
        System.assertEquals('Tiered',addOnSelected.model);
        
        addOnSelected=cbs.selList[0];
		addOnSelected.addon='StairStepaddon';	        
        cbs.addonId=addOnSelected.Id;
        cbs.CBPriceBookEntryAddon();        
        expectedPriceChange=150.00;        
        System.assertEquals(expectedPriceChange,addOnSelected.price);
        System.assertEquals('Stairstep',addOnSelected.model);        
    }
    
    public static Map<String,List<chargebeeapps__CB_Pricing_Tiers__c>> getPricingTiers(String productType)
    {
        Map<String,List<chargebeeapps__CB_Pricing_Tiers__c>> ptlist=new Map<String,List<chargebeeapps__CB_Pricing_Tiers__c>>();
        String defaultSiteId = TestdataUtility.getSite('cbtest1').Id;
        List<String> pricingmodeltypes = new List<String>{'Tiered','Stairstep','Volume'};
        for(String thepricingmodel:pricingmodeltypes)
        {
            String productname=thepricingmodel+productType;
            PriceBookEntry pbEntry = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c 
                                              From PricebookEntry where Product2.ExternalId =:productname and Pricebook2.chargebeeapps__CB_Site__c=:defaultSiteId];
           List<chargebeeapps__CB_Pricing_Tiers__c> pricingtierList=[Select Id,Name,chargebeeapps__PriceBookEntryId__c,chargebeeapps__ExternalId__c,chargebeeapps__Lower_Limit__c, 
				chargebeeapps__Upper_Limit__c,chargebeeapps__Price__c From chargebeeapps__CB_Pricing_Tiers__c 
				Where chargebeeapps__PriceBookEntryId__c=:pbEntry.Id 
				ORDER BY chargebeeapps__Lower_Limit__c ASC] ;            
            System.debug(' ProductName ' + productname + ' PricingTierList ' + pricingtierList);
            ptlist.put(productname,pricingtierlist);
        }  
        return ptlist;
    }    
    
    public static List<Product2> insertProducts(string producttype)
    {
        List<String> pricingmodeltypes = new List<String>{'Flat_Fee','Per_Unit','Tiered','Stairstep','Volume'};
        List<Product2> productList = new List<Product2>();
        
            for(string prodtypebyModel:pricingmodeltypes)
            {
                Product2 testProduct = new Product2(Name=prodtypebyModel+producttype,ProductCode=prodtypebyModel+producttype,ExternalId=prodtypebyModel+producttype,
                                             		 chargebeeapps__Status__c='ACTIVE',chargebeeapps__Currency__c='USD',
                                                     chargebeeapps__Product_Type__c=producttype);
                productList.add(testProduct);
                if(producttype.equalsIgnoreCase('plan'))
        		{
                    
                	testProduct.chargebeeapps__Recurring_charge_model__c = prodtypebyModel;
                    
                    if(prodtypebyModel.equalsIgnoreCase('Tiered'))
                    {
                    	testProduct.chargebeeapps__Addon_Applicability__c = 'All';	
                    }else if(prodtypebyModel.equalsIgnoreCase('VOLUME'))
                    {                        
                    	testProduct.chargebeeapps__Addon_Applicability__c = 'RESTRICTED';	
                    }
                }else if(producttype.equalsIgnoreCase('addon'))
                {
                    testProduct.chargebeeapps__Addon_Type__c = prodtypebyModel;
                    testProduct.chargebeeapps__Recurring_charge_model__c = 'RECURRING';
                    if(prodtypebyModel.equalsIgnoreCase('Stairstep'))
                    {
                        testProduct.chargebeeapps__Recurring_charge_model__c = 'NON_RECURRING';
                    }
                }
                               
            }   
          insert productList;
          return productList;
    }
  public static void insertStandardPricebookEntries()
  {
      List<PricebookEntry> stdPricebookEntryList = new List<PricebookEntry>();
      ID stdPricebookID = Test.getStandardPricebookId();            
      Product2[] products = TestdataUtility.getProducts();      
      for(Integer prodcount=0; prodcount<products.size(); prodcount++)
      {
          PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPricebookID,Product2Id = products[prodcount].Id,UnitPrice = 160,IsActive = true);
          stdPricebookEntryList.add(standardPrice);
      }
      insert stdPricebookEntryList;
  }
    
  public  static List<PricebookEntry> insertPriceBookEntries(string siteId)
  {  
      Product2[] products = TestdataUtility.getProducts();
      Pricebook2 CBPriceBook = new Pricebook2(Name='CB Standard'+siteId,chargebeeapps__CB_Site__c=siteId);
      insert CBPriceBook;
      List<PricebookEntry> CBPricebookEntries = new List<PricebookEntry>();
      for(product2 product:products)
      {
          PricebookEntry cbpricebookentry = new PricebookEntry(Product2Id=product.Id,Pricebook2Id=CBPriceBook.Id,IsActive=true,UnitPrice=160);
          CBPricebookEntries.add(cbpricebookentry);
      }
      insert CBPricebookEntries;
      insertCBPricingTiers(CBPricebookEntries);
      return CBPricebookEntries;
  }
  
  public static List<chargebeeapps__CB_Pricing_Tiers__c> insertCBPricingTiers(List<PricebookEntry> CBPricebookEntries)
  {
      List<chargebeeapps__CB_Pricing_Tiers__c> cbPricingTiers = new List<chargebeeapps__CB_Pricing_Tiers__c>();
      
      for(PricebookEntry cbPricebookEntry:CBPricebookEntries)
      {
          product2 product = TestdataUtility.getProduct(cbPricebookEntry.Product2Id);
          
          string pricingModel;
          if(product.chargebeeapps__Product_Type__c.equalsIgnoreCase('Plan'))
          {
              pricingModel = product.chargebeeapps__Recurring_charge_model__c;
          }else if(product.chargebeeapps__Product_Type__c.equalsIgnoreCase('Addon'))
          {
              pricingModel = product.chargebeeapps__Addon_Type__c;
          }          
          
          if(pricingModel!= null)
          {
              if(pricingModel.equalsIgnoreCase('Tiered')||pricingModel.equalsIgnoreCase('Stairstep')||pricingModel.equalsIgnoreCase('Volume'))
                 
              {
                  
                      chargebeeapps__CB_Pricing_Tiers__c pricetier1 = new chargebeeapps__CB_Pricing_Tiers__c(Name=cbPricebookEntry.Id,
                                                                                                chargebeeapps__ExternalId__c=pricingModel,
                                                                                                chargebeeapps__PriceBookEntryId__c=cbPricebookEntry.Id,
                                                                                                chargebeeapps__Lower_Limit__c=1,chargebeeapps__Upper_Limit__c=10,
                                                                                                chargebeeapps__Price__c=160);
                      chargebeeapps__CB_Pricing_Tiers__c pricetier2 = new chargebeeapps__CB_Pricing_Tiers__c(Name=cbPricebookEntry.Id,
                                                                                                chargebeeapps__ExternalId__c=pricingModel,
                                                                                                chargebeeapps__PriceBookEntryId__c=cbPricebookEntry.Id,
                                                                                                chargebeeapps__Lower_Limit__c=11,chargebeeapps__Upper_Limit__c=null,
                                                                                                chargebeeapps__Price__c=150);
                      cbPricingTiers.add(pricetier1);
                      cbPricingTiers.add(pricetier2);
                  
              }
          }
      }
     insert cbPricingTiers;     
     return cbPricingTiers;
  }  
}