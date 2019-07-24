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
        insertProducts('PLAN');
        insertProducts('ADDON'); 
        insertStandardPricebookEntries();
        defaultSite = TestdataUtility.getSite('cbtest1');
        secondarySite = TestdataUtility.getSite('yaalidemo-test');
        PricebookEntry[] defaultpbentries = insertPriceBookEntries(defaultSite.Id); 
        insertPriceBookEntries(secondarySite.Id);
        TestdataUtility.insertOpportunityLineItem(opportunities[0].Id,defaultpbentries[0].Id);
        TestdataUtility.insertCoupons();           
    }
    
    /* This function validate the data in CreateSubscription when the navigation 
     * is done from Opportunity Detail Page.
     * The expected and actual values are compared for the Contact and Opportunity.
     * Prerequisites: The user running this function has the permission for the Objects 
     * and Fields involved.
     */ 
     @istest public static void validateDataFromOpportunity()
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
        // SiteDetails Validation
        List<selectOption> siteList=cbs.getSiteDetails();
        System.assert(siteList.size() == 1);
        System.assert(cbs.isSiteConnected);
        System.assert(siteList[0].getLabel() == defaultSite.Name);        
        // Opportunityn and Contact Validation        
	    PageReference errorpage=cbs.checkPermissions();        
	    System.debug('Error page ' + errorpage);                
        System.debug(' ContactName Expected ' + cbs.con_id + ' Actual ' + oppContact.Id );
        System.debug(' OpportunityName Expected ' + cbs.opp_id + ' Actual ' + testOpportunity[0].Id );
        System.debug('IsSiteSelected ' + cbs.isSiteConnected + 'SelectedSiteName ' + cbs.selectedSites);        
	    System.assert(errorpage == null); // When permission pass the test, return value is null
        System.assert(cbs.opp_id != null);
        System.assertEquals(cbs.opp_id, testOpportunity[0].Id);        
	    System.assertEquals(cbs.con_id, oppContact.Id);
        System.assert(cbs.oppOptions == null); 
    }

/* This function validate the data in CreateSubscription when the navigation 
     * is done from Account/Contact Detail Page.
     * The expected and actual values are compared for the Contact .
     * Prerequisites: The user running this function has the permission for the Objects 
     * and Fields involved.
     */ 
    @istest public static void validateDataFromContact()
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
                                                                                                chargebeeapps__Price__c=100);
                      chargebeeapps__CB_Pricing_Tiers__c pricetier2 = new chargebeeapps__CB_Pricing_Tiers__c(Name=cbPricebookEntry.Id,
                                                                                                chargebeeapps__ExternalId__c=pricingModel,
                                                                                                chargebeeapps__PriceBookEntryId__c=cbPricebookEntry.Id,
                                                                                                chargebeeapps__Lower_Limit__c=11,chargebeeapps__Upper_Limit__c=null,
                                                                                                chargebeeapps__Price__c=200);
                      cbPricingTiers.add(pricetier1);
                      cbPricingTiers.add(pricetier2);
                  
              }
          }
      }
     insert cbPricingTiers;     
     return cbPricingTiers;
  }
    
     public static void pageDataValidation(string oppid,Contact con,List<chargebeeapps__Coupon__c> cpnList) 
     {
         CreateTestData.insertTestData();         
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSite();
         //contact cont = TestdataUtility.getContact(con.LastName);
         system.debug('acc id--'+con.AccountId);
         Account acc = [select Id,Name from Account where Id=:con.AccountId LIMIT 1]; 
         
         Opportunity[] oppList = TestdataUtility.getOpportunities(acc.Id);         
         PageReference pageRef = Page.Create_Subscription;
         test.setCurrentPageReference(pageRef);     
         pageRef.getParameters().put('opp_id',null);
         pageRef.getParameters().put('con_id',con.Id);
         pageRef.getParameters().put('domain','cbtest1');      
         Test.setMock(HttpCalloutMock.class, new MockEstSubResponseGenerator());     
         CBCreateSubscription cbn = new CBCreateSubscription();
         cbn.selectedSiteName();
         List<SelectOption> testOppList = new List<selectOption>();
         if(oppList!=null)
         {
             
             testOppList.add(new SelectOption('-1','Select'));
             for(Opportunity opp:oppList)
             {
                 testOppList.add(new SelectOption(opp.Id,opp.Name));
             }    
         }
              
         cbn.coupenOptions = new List<selectOption>();
         List<SelectOption> testCoupons = new List<selectOption>();
         testCoupons.add(new SelectOption('-1','Select'));
         testCoupons.add(new SelectOption(cpnList[0].chargebeeapps__CB_Coupon_Id__c,cpnList[0].Name));
         testCoupons.add(new SelectOption(cpnList[1].chargebeeapps__CB_Coupon_Id__c,cpnList[1].Name));
         testCoupons.add(new SelectOption(cpnList[2].chargebeeapps__CB_Coupon_Id__c,cpnList[2].Name));
         testCoupons.add(new SelectOption(cpnList[3].chargebeeapps__CB_Coupon_Id__c,cpnList[3].Name));
         system.assertEquals(cbn.cont.Name,con.Name);
         system.assertEquals(cbn.cont.Account.Name,acc.Name);
         if(oppid==null)
         {
             system.assertEquals(cbn.oppOptions,testOppList);
         }else
             system.assertEquals(cbn.opp_name,oppList[0].Name);
         
         system.assertEquals(UIUtil.getCouponOptions(site.Id),testCoupons);
         List<selectOption> testPlans = cbn.options3;
         system.debug('options3--'+testPlans);
      
     }   
 
}