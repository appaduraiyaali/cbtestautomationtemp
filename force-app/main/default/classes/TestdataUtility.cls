@isTest public class TestdataUtility {
 
public static chargebeeapps__CB_Settings__c[] insertCustomSetting() {
    return insertCustomSetting(false);
}

public static chargebeeapps__CB_Settings__c[] insertCustomSetting(boolean quotesEnabled)
{
    List<chargebeeapps__CB_Settings__c> cbSettingList = new List<chargebeeapps__CB_Settings__c>();
    chargebeeapps__CB_Settings__c cbsetting = new chargebeeapps__CB_Settings__c();
    cbsetting.Name = 'cbtest1';
    cbsetting.chargebeeapps__API_Key__c ='live_sqsN6OTb37Wuh8JIPpYFgS1m0Gp0FEGI';
    cbsetting.chargebeeapps__ChargeBee_URL__c = 'https://cbtest1.chargebee.com';
    cbsetting.chargebeeapps__User_Name__c = 'ksadithya@chargebee.com';//ksadithya@chargebee.com
    if(quotesEnabled)
        cbsetting.chargebeeapps__Settings_JSON__c  = '{"isOverRide":false,"useV3UpdatePayment":"V3","cb.customerid":"Phone","isQuotesEnabled":"true"}';
    else 
        cbsetting.chargebeeapps__Settings_JSON__c  = '{"isOverRide":false,"useV3UpdatePayment":"V3","cb.customerid":"Phone"}';
    cbSettingList.add(cbsetting);
    chargebeeapps__CB_Settings__c cbsettingNew = new chargebeeapps__CB_Settings__c();
         cbsettingNew.Name = 'yaalidemo-test';
         cbsettingNew.chargebeeapps__API_Key__c ='test_BgFUABPcdcuVN9lbGN0cuwHRC7SUToVWP5r';
         cbsettingNew.chargebeeapps__ChargeBee_URL__c = 'https://yaalidemo-test.chargebee.com';
         cbsettingNew.chargebeeapps__User_Name__c = 'sibanee@bizappln.com';
    if(quotesEnabled)
        cbsettingNew.chargebeeapps__Settings_JSON__c = '{"isOverRide":false,"useV3UpdatePayment":"V3","cb.customerid":"Phone","isQuotesEnabled":"true"}';
    else
         cbsettingNew.chargebeeapps__Settings_JSON__c   = '{"isOverRide":true,"useV3UpdatePayment":"V3","cb.customerid":"Phone"}';   
         cbSettingList.add(cbsettingNew);
     insert cbSettingList;
     return cbSettingList;    
    
}

@testsetup public static void insertSiteDetails()
{
    List<chargebeeapps__CB_Sites__c> siteList = loadSiteDetails();
    populateTestAccounts();
}
    
    
public static List<chargebeeapps__CB_Sites__c> loadSiteDetails()
{
    List<chargebeeapps__CB_Sites__c> siteList = new List<chargebeeapps__CB_Sites__c>();
    chargebeeapps__CB_Sites__c site1 = new chargebeeapps__CB_Sites__c(Name='cbtest1');
    //chargebeeapps__CB_Sites__c site2 = new chargebeeapps__CB_Sites__c(Name='mailchimp-stag-test');
    chargebeeapps__CB_Sites__c site3 = new chargebeeapps__CB_Sites__c(Name='yaalidemo-test');
    siteList.add(site1);
    //siteList.add(site2);
    siteList.add(site3);
    insert siteList;   
    return siteList;
}

public static Account[] populateTestAccounts()
{
    List<Account> accList = new List<Account>();
    for(Integer i=1; i<=4; i++)
    {
        Account acc = new Account(Name='SfTest'+i);
        accList.add(acc);
    }
    insert accList;
    return accList;
}    
    
@isTest public static chargebeeapps__CB_Sites__c getSites()
{

    chargebeeapps__CB_Sites__c sites1 = [select Id,Name from chargebeeapps__CB_Sites__c where Name='cbtest1' LIMIT 1];
    return sites1;
}
@isTest public static chargebeeapps__CB_Sites__c[] getSiteList()
{

    chargebeeapps__CB_Sites__c[] sitesList = [select Id,Name from chargebeeapps__CB_Sites__c];

    return sitesList;
}
@isTest public static List<Account> getAccounts()
{
    Account[] accs = [select Id,Name from Account];
    return accs;
}

public static List<Contact> insertContacts()
{
    List<Account> accTest = getAccounts();
    List<Contact> conTest = new List<Contact>();
    for(Integer i=1; i<=4; i++)
    {
        Contact con = new Contact(Lastname='test'+i,FirstName='con'+i,Email='con'+i+'test'+i+'@gmail.com');
        conTest.add(con);
        if(i==1)
        {
            con.AccountId = accTest[3].Id;
        }
    }

    insert conTest;
    if((conTest[1].AccountId == null && conTest[1].Email == null) || (conTest[2].AccountId == null && conTest[2].Email != null))
    {
        conTest[1].AccountId = accTest[0].Id;
        conTest[2].Email = null;
        conTest[2].AccountId = accTest[1].Id;
        conTest[3].AccountId = accTest[1].Id;
    }
    update conTest;

    return conTest;
}
public static Contact getContact(string conName)
{
    return [select Name,FirstName,LastName,Email,AccountId from Contact where LastName =: conName];
}
public static chargebeeapps__Contact_Associate_Site__c insertContactSite(string site,string conid)
{
    contact con = [select id,LastName from Contact where Id=:conid];
    chargebeeapps__Contact_Associate_Site__c conSite = new chargebeeapps__Contact_Associate_Site__c();
    conSite.chargebeeapps__CB_Site__c = site;
    conSite.chargebeeapps__Contact__c = conid;
    if(con.LastName=='test1')
    {
        conSite.chargebeeapps__External_Id__c = '1ps2glZRUOKGciVZ5';
    }
    else if(con.LastName=='test2')
    {
        conSite.chargebeeapps__External_Id__c = '1t0Aw4lRUsqQiYsg';
    }
    conSite.chargebeeapps__SiteName__c ='cbtest1';
    system.debug('conSite '+conSite);
    insert conSite;

    return conSite;
}
 
public static List<Opportunity> insertOpportunity()
{
    List<Account> accTest = getAccounts();
    List<Opportunity> oppList =new List<Opportunity>();
    for(Integer i=1; i<=3; i++)
    {
        Opportunity opp = new Opportunity(Name='test opp'+i,StageName='Prospecting',Probability = 10, CloseDate=system.today());
        oppList.add(opp);
    }
    
    
    insert oppList;
    return oppList;
}

public static chargebeeapps__CB_Subscription__c insertSub()
{
    Account[] accTest = getAccounts();
    chargebeeapps__CB_Sites__c sites1 = getSites();
    chargebeeapps__CB_Subscription__c cbsub = new chargebeeapps__CB_Subscription__c(Name='Hr5511nROMSd0r1urD',chargebeeapps__CB_Id__c='Hr5511nROMSd0r1urD',
                                                                                    chargebeeapps__CB_Site__c=sites1.Id,
                                                                                    chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD',
                                                                                    chargebeeapps__SubscriptionId__c='Hr5511nROMSd0r1urD',
                                                                                    chargebeeapps__Company__c=accTest[0].Id);
    insert cbsub;
    return cbsub;
}
public static List<chargebeeapps__Coupon__c> insertCoupons()
{
    system.debug('coupon loaded');
    chargebeeapps__CB_Sites__c sites1 = getSites();
    chargebeeapps__Coupon__c cpn;
    List<chargebeeapps__Coupon__c> cpnlist = new List<chargebeeapps__Coupon__c>();
    for(Integer i =1; i<=3; i++)
    {
        cpn = new chargebeeapps__Coupon__c(Name='cbdemo_fitfreak'+i,chargebeeapps__CB_Coupon_Id__c='cbdemo_fitfreak'+i,
                                           chargebeeapps__CB_Id__c='cbdemo_fitfreak'+i,chargebeeapps__Coupon_Id__c='cbdemo_fitfreak'+i,
                                           chargebeeapps__CB_Site__c=sites1.Id,chargebeeapps__Status__c='ACTIVE');
        cpnlist.add(cpn);
    }
    cpn = new chargebeeapps__Coupon__c(Name='cbdemo_great',chargebeeapps__CB_Coupon_Id__c='cbdemo_great',
                                           chargebeeapps__CB_Id__c='cbdemo_great',chargebeeapps__Coupon_Id__c='cbdemo_great',
                                           chargebeeapps__CB_Site__c=sites1.Id,chargebeeapps__Status__c='ACTIVE');
    cpnlist.add(cpn); 

    insert cpnlist;

    return cpnlist;
}
public static List<chargebeeapps__Coupon__c> getSiteBasedCpns(string siteId)
{
    chargebeeapps__Coupon__c[] cpnList = [select Id,Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c 
                                               from chargebeeapps__Coupon__c 
                                               where chargebeeapps__CB_Site__c=:siteId and chargebeeapps__Status__c = 'ACTIVE']; 
    return cpnList;
}
public static List<Product2> insertProducts()
{
    List<Product2> prodList = new List<Product2>();
    
    for(Integer i=1; i<=4; i++)
    {
        Product2 prod = new Product2(Name='Testplan'+i,ProductCode='Testplan'+i,ExternalId='Testplan'+i,
                                     chargebeeapps__Status__c='ACTIVE',chargebeeapps__Currency__c='USD',chargebeeapps__Product_Type__c='PLAN');
        
        prodList.add(prod);
        if(i == 1)
        {
            prod.chargebeeapps__Recurring_charge_model__c = 'FLAT_FEE';
        }
        else if(i == 2)
        {
            prod.chargebeeapps__Recurring_charge_model__c = 'VOLUME';
            prod.chargebeeapps__Addon_Applicability__c = 'RESTRICTED';
        }
        else if(i == 3)
        {
            prod.chargebeeapps__Recurring_charge_model__c = 'TIERED';
            prod.chargebeeapps__Addon_Applicability__c = 'All';
        }
        else
        {
            prod.chargebeeapps__Recurring_charge_model__c = 'STAIRSTEP';
        }
    }
    for(Integer i=5; i<=8; i++)
    {
        Product2 prod = new Product2(Name='TestAddon'+i,ProductCode='TestAddon'+i,ExternalId='TestAddon'+i,
                                     chargebeeapps__Status__c='ACTIVE',chargebeeapps__Currency__c='USD',chargebeeapps__Product_Type__c='ADDON');
        prodList.add(prod);
        if(i == 5)
        {
            prod.chargebeeapps__Addon_Type__c = 'FLAT_FEE';
            prod.chargebeeapps__Recurring_charge_model__c = 'RECURRING';
        }
        else if(i == 6)
        {
            prod.chargebeeapps__Addon_Type__c = 'VOLUME';
            prod.chargebeeapps__Recurring_charge_model__c = 'RECURRING';

        }
        else if(i == 7)
        {
            prod.chargebeeapps__Addon_Type__c = 'TIERED';
            prod.chargebeeapps__Recurring_charge_model__c = 'RECURRING';

        }
        else
        {
            prod.chargebeeapps__Addon_Type__c = 'STAIRSTEP';
            prod.chargebeeapps__Recurring_charge_model__c = 'NON_RECURRING';

        }
    }
    Product2 perunitPlan = new Product2(Name='perunitplan',ProductCode='perunitplan',ExternalId='perunitplan',chargebeeapps__Recurring_charge_model__c='PER_UNIT',
                                     chargebeeapps__Status__c='ACTIVE',chargebeeapps__Currency__c='USD',chargebeeapps__Product_Type__c='PLAN');
    prodList.add(perunitplan);
    Product2 perunitAddon = new Product2(Name='perunitAddon',ProductCode='perunitAddon',ExternalId='perunitAddon',chargebeeapps__Addon_Type__c='PER_UNIT',
                                     chargebeeapps__Status__c='ACTIVE',chargebeeapps__Recurring_charge_model__c='RECURRING',chargebeeapps__Currency__c='USD',chargebeeapps__Product_Type__c='ADDON');
    prodList.add(perunitAddon);
    
    insert prodList;
    system.debug('prodsize--'+prodList.size());
    return prodList;
}
public static List<PricebookEntry> insertPBEntry(List<string> prod)
{

    ID standardPBID = Test.getStandardPricebookId();
    List<PricebookEntry> stdPbEntrylist = new List<PricebookEntry>();

    chargebeeapps__CB_Sites__c sites1 = getSites();
    List<Product2> prd = [select Name,ExternalId from Product2 where ExternalId IN:prod];
    integer i;
    for(i=0; i<prd.size(); i++)
    {
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPBID,Product2Id = prd[i].Id,UnitPrice = 0,IsActive = true);
        stdPbEntrylist.add(standardPrice);
    }
    insert stdPbEntrylist;
    Pricebook2 custompricebk = new Pricebook2(Name='CB Standard',chargebeeapps__CB_Site__c=sites1.Id);

    insert custompricebk;

    List<PricebookEntry> allPriceEntries = new List<PricebookEntry>();

    for(Product2 pr:prd)
    {
        PricebookEntry pEntry = new PricebookEntry(Product2Id=pr.Id,Pricebook2Id=custompricebk.Id,IsActive=true,UnitPrice=160);
        allPriceEntries.add(pEntry);
    }
    insert allPriceEntries;
    return allPriceEntries;
}
public static chargebeeapps__CB_Invoice__c insertInvoices(string subid)
{
    chargebeeapps__CB_Invoice__c inv = new chargebeeapps__CB_Invoice__c (Name='32',chargebeeapps__InvoiceID__c ='32',
                                                                         chargebeeapps__Status__c='PAYMENT_DUE',chargebeeapps__SubscriptionId__c= subid);
    insert inv;
    return inv;
}
    

public static List<chargebeeapps__CB_Pricing_Tiers__c> insertCBTiers(List<string> pbId)
{
    List<chargebeeapps__CB_Pricing_Tiers__c> allCBTiers = new List<chargebeeapps__CB_Pricing_Tiers__c>();
    List<PricebookEntry> allPriceEntries = [select Id,Product2Id,Pricebook2Id from PricebookEntry where Id IN:pbId];
    for(PricebookEntry pb:allPriceEntries)
    {


        chargebeeapps__CB_Pricing_Tiers__c cbtiers = new chargebeeapps__CB_Pricing_Tiers__c(Name=pb.Id,
                                                                                            chargebeeapps__ExternalId__c='tiered',
                                                                                            chargebeeapps__PriceBookEntryId__c=pb.Id,
                                                                                            chargebeeapps__Lower_Limit__c=1,chargebeeapps__Upper_Limit__c=100,
                                                                                            chargebeeapps__Price__c=10);
        allCBTiers.add(cbtiers);
        if(allCBTiers[0].chargebeeapps__Lower_Limit__c == 1)
        {
            chargebeeapps__CB_Pricing_Tiers__c cbtiers1 = new chargebeeapps__CB_Pricing_Tiers__c(Name=pb.Id,
                                                                                                 chargebeeapps__ExternalId__c='tiered',
                                                                                                 chargebeeapps__PriceBookEntryId__c=pb.Id,
                                                                                                 chargebeeapps__Lower_Limit__c=11,
                                                                                                 chargebeeapps__Price__c=10);
            allCBTiers.add(cbtiers1);
        }
    }
    insert allCBTiers;

    return allCBTiers;
}

public static chargebeeapps__CB_Subscription__c getSubscription(String name) {
    return [select Id,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__CB_Subscription_Id__c,
            chargebeeapps__Subscription_Plan__c,chargebeeapps__SubscriptionId__c,chargebeeapps__CB_Oppurtunity__c
            from chargebeeapps__CB_Subscription__c where Name=:name LIMIT 1];
}

public static chargebeeapps__Coupon__c getCoupon(String name) {
    return [select Name,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Id__c,chargebeeapps__CB_Site__c 
            from chargebeeapps__Coupon__c where Name=:name];
}
public static List<chargebeeapps__CB_Quote_Product__c> insertQuoteProducts(String quoteId,String productId)
{
    List<chargebeeapps__CB_Quote_Product__c> quoteProducts = new List<chargebeeapps__CB_Quote_Product__c>();
    quoteProducts.add(new chargebeeapps__CB_Quote_Product__c(chargebeeapps__Product__c=productId,chargebeeapps__CB_Quote__c=quoteId, chargebeeapps__Quantity__c=1,chargebeeapps__UnitPrice__c=15));
    insert quoteProducts;
    return quoteProducts;
}
public static List<chargebeeapps__CB_Quote__c> insertQuote()
{
    Account[] accTest = getAccounts();
    Contact[] contacts = [select Id,AccountId from Contact where AccountId=:accTest[0].Id];
    chargebeeapps__CB_Sites__c sites1 = getSites();
    chargebeeapps__CB_Subscription__c sub= getSubscription('Hr5511nROMSd0r1urD');
    chargebeeapps__CB_Quote__c quote = new chargebeeapps__CB_Quote__c(Name='1', chargebeeapps__Operation_Type__c ='CREATE_SUBSCRIPTION_FOR_CUSTOMER',
                                                                                    chargebeeapps__CB_Site__c=sites1.Id,
                                                                                    chargebeeapps__CB_Quote_Id__c ='1',
                                                                                    chargebeeapps__CustomerID__c =contacts[0].Id,
                                                                                    chargebeeapps__Status__c='OPEN',
                                                                                    chargebeeapps__CB_Subscription__c=sub.Id,
                                                                                    chargebeeapps__Company__c=accTest[0].Id);
    chargebeeapps__CB_Quote__c quote1 = new chargebeeapps__CB_Quote__c(Name='2', chargebeeapps__Operation_Type__c ='CHANGE_SUBSCRIPTION',
                                                                                    chargebeeapps__CB_Site__c=sites1.Id,
                                                                                    chargebeeapps__CB_Quote_Id__c ='2',
                                                                                    chargebeeapps__CustomerID__c =contacts[0].Id,
                                                                                    chargebeeapps__Status__c='OPEN',
                                                                                    chargebeeapps__CB_Subscription__c=sub.Id,
                                                                                    chargebeeapps__Company__c=accTest[0].Id);
    List<chargebeeapps__CB_Quote__c> quotes = new List<chargebeeapps__CB_Quote__c>();
    quotes.add(quote);                                                                                                                                                               
    quotes.add(quote1);                                                                                                                                                               
    insert quotes;
    return quotes;
}
}