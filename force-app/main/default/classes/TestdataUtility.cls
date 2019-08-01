@isTest public class TestdataUtility {

private static final Integer TESTACCOUNT_SIZE=4;
private static final String defaultSiteName='cbtest1';    
    
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
        cbsetting.chargebeeapps__Settings_JSON__c  = '{"isOverRide":false,"useV3UpdatePayment":"V3","autoCollectionFlag":"OFF","cb.customerid":"Phone"}';
    cbSettingList.add(cbsetting);
    chargebeeapps__CB_Settings__c cbsettingNew = new chargebeeapps__CB_Settings__c();
         cbsettingNew.Name = 'yaalidemo-test';
         cbsettingNew.chargebeeapps__API_Key__c ='test_BgFUABPcdcuVN9lbGN0cuwHRC7SUToVWP5r';
         cbsettingNew.chargebeeapps__ChargeBee_URL__c = 'https://yaalidemo-test.chargebee.com';
         cbsettingNew.chargebeeapps__User_Name__c = 'sibanee@bizappln.com';
    if(quotesEnabled)
        cbsettingNew.chargebeeapps__Settings_JSON__c = '{"isOverRide":false,"useV3UpdatePayment":"V3","cb.customerid":"Phone","isQuotesEnabled":"true"}';
    else
         cbsettingNew.chargebeeapps__Settings_JSON__c   = '{"isOverRide":true,"useV3UpdatePayment":"V3","autoCollectionFlag":"OFF","cb.customerid":"Phone"}';   
         cbSettingList.add(cbsettingNew);
     insert cbSettingList;
    system.debug('cbsetting---'+cbSettingList[0]);
     return cbSettingList;    
    
}

@testsetup public static void insertSiteDetails()
{
    List<chargebeeapps__CB_Sites__c> siteList = loadSiteDetails();
    populateTestAccounts();
}
    
public static String getCustomFieldForSite()
{    
    String customfieldmap=null;
    TestdataUtility.MetaDataUtility metautil=new TestdataUtility.MetaDataUtility();
    if(metautil.isFieldExist('Contact','PreferredContactMethod__c'))
    {
        customfieldmap='{"Contact":{"PreferredContactMethod__c":"String"}}';    
    }    
    return customfieldmap;
}
    
public static List<chargebeeapps__CB_Sites__c> loadSiteDetails()
{
     String customfieldMetaforSite=getCustomFieldForSite();
    List<chargebeeapps__CB_Sites__c> siteList = new List<chargebeeapps__CB_Sites__c>();
    chargebeeapps__CB_Sites__c defaultSite = new chargebeeapps__CB_Sites__c(Name=defaultSiteName);
    if(customfieldMetaforSite != null){
        defaultSite.chargebeeapps__Custom_Field_Mapping__c=customfieldMetaforSite;      
    }   
    chargebeeapps__CB_Sites__c site3 = new chargebeeapps__CB_Sites__c(Name='yaalidemo-test');
    siteList.add(defaultSite);    
    siteList.add(site3);
    insert siteList;   
    return siteList;
}

public static String getDefaultSelectedSite()
{
    return defaultSiteName;
}    
    
public static Account[] populateTestAccounts()
{
    List<Account> accList = new List<Account>();
    for(Integer i=1; i<=TESTACCOUNT_SIZE; i++)
    {
        Account acc = new Account(Name='SfTest'+i);
        accList.add(acc);
    }
    insert accList;
    return accList;
}   
    
public static chargebeeapps__CB_Sites__c getSite()
{

    return getSite(defaultSiteName);
}

public static chargebeeapps__CB_Sites__c getSite(String sitename)
{

    chargebeeapps__CB_Sites__c site = [select Id,Name from chargebeeapps__CB_Sites__c where Name=:sitename LIMIT 1];
    return site;
}

    
public static chargebeeapps__CB_Sites__c[] getSiteList()
{

    chargebeeapps__CB_Sites__c[] sitesList = [select Id,Name from chargebeeapps__CB_Sites__c];

    return sitesList;
}
public static List<Account> getAccounts()
{
    Account[] accs = [select Id,Name from Account];
    return accs;
}

public static List<Contact> insertContacts()
{
    List<Account> accTest = getAccounts();
    List<Contact> conTest = new List<Contact>();
    List<String> testcontactnames=new List<String>{'validcontact','contactunsynchedtocb','contactwithoutemail','secondarycontactunsynched'};        
    for(Integer countofcontact=0; countofcontact< testcontactnames.size(); countofcontact++)
    {
        String contactname=testcontactnames[countofcontact];
        String contactlastname=contactname+'LN';
        String contactfirstname=contactname+'FN';
        String contactemail=contactname+'@email.com';
        Contact testcontact= new Contact(Lastname=contactlastname,FirstName=contactfirstname);
        conTest.add(testcontact);
        if(contactname.equalsIgnoreCase('validcontact'))
        {
            testcontact.AccountId = accTest[3].Id;
            testcontact.Email=contactemail;
            
        }
        else if(!contactname.equalsIgnoreCase('contactwithoutemail'))
        {
            system.debug('unsynched contact--'+testcontact);
            testcontact.Email=contactemail;
            testcontact.AccountId = accTest[0].Id;
        }
    }
    System.debug('TestContacts created are ' + conTest);    
    insert conTest;
    associateAccountToContacts(accTest,conTest);
    update conTest;
    return conTest;
}

private static void associateAccountToContacts(Account[] accountlist, Contact[] contactlist)
{   
    if(accountlist.size() < 2 || contactlist.size() < 3)        
        return;
        contactlist[2].AccountId = accountlist[1].Id;       
        contactlist[3].AccountId = accountlist[1].Id;    
}    
    
public static Contact getContact(string conName)
{
    return [select Name,FirstName,LastName,Email,AccountId from Contact where LastName =: conName];
}

public static Contact[] getContactFromAccount(String accountId)
{
    return [select Id,Name,LastName from Contact where Accountid=:accountId];
}
public static List<Contact> getContacts()
{
    return [select Name,FirstName,LastName,Email,AccountId from Contact];
}
public static Contact getValidContact()
{
    return getContact('validcontactLN');
}   
    
public static Contact getCBUnsynchedContact()
{
    return getContact('contactunsynchedtocbLN');
}

public static Contact getContactWithoutEmail()
{
    return getContact('contactwithoutemailLN');
}    

public static Account getAccountWOContactAssociation()
{
    List<Account> accountList=getAccounts();
    return accountList[2];
}

public static Account getAccountWithMultipleContacts()
{
    List<Account> accountList=getAccounts();
    return accountList[1];
}
    
public static chargebeeapps__Contact_Associate_Site__c associateContactToSite(String siteId,String contactId)
{
    system.debug('contactId--'+contactId);
    contact contactRecord = [select id,LastName from Contact where Id=:contactId];
    chargebeeapps__CB_Sites__c siteRecord= [select Name from chargebeeapps__CB_Sites__c where Id=:siteId];
    chargebeeapps__Contact_Associate_Site__c contactSiteassociation = new chargebeeapps__Contact_Associate_Site__c();
    contactSiteassociation.chargebeeapps__CB_Site__c = siteId;
    contactSiteassociation.chargebeeapps__Contact__c = contactId;   
    contactSiteassociation.chargebeeapps__External_Id__c = contactRecord.LastName+'_externalid';    
    contactSiteassociation.chargebeeapps__SiteName__c = siteRecord.Name;
    system.debug('contactSiteassociation  '+contactSiteassociation);
    insert contactSiteassociation;    
    return contactSiteassociation;
}  

public static List<Opportunity> insertOpportunity()
{
    List<Account> accTest = getAccounts();
    List<Opportunity> oppList =new List<Opportunity>();
    for(Integer i=1; i<=4; i++)
    {
        Opportunity opp = new Opportunity(Name='test opp'+i,StageName='Prospecting',AccountId=accTest[0].Id,Probability = 10, CloseDate=system.today());
        oppList.add(opp);
        if(i==3 || i==4)
        {
            Opportunity oppTest = new Opportunity(Name='test opp'+i,StageName='Closed Won',AccountId=accTest[1].Id,Probability = 10, CloseDate=system.today());
            oppList.add(oppTest);
        }
        
    }
    insert oppList;
    
    return oppList;
}
public static List<Opportunity> getOpportunities(string accId)
{
    return [select Id,Name,AccountId,StageName,CloseDate,Probability,Pricebook2Id from Opportunity where AccountId=:accId];
}

public static OpportunityLineItem insertOpportunityLineItem(string oppId,PricebookEntry pbentry)
{
    
    OpportunityLineItem opplineitem = new OpportunityLineItem(OpportunityId = oppId,Quantity = 1,PricebookEntryId = pbentry.Id,TotalPrice = 1 * pbentry.UnitPrice);
    
    insert opplineitem;
    return opplineitem;
}  
    
public static List<OpportunityLineItem> insertOpportunityLineItems(string oppId, chargebeeapps__CB_Sites__c defaultSite)
{
    return insertOpportunityLineItems(oppId,defaultSite,true);
}    
    
public static List<OpportunityLineItem> insertOpportunityLineItems(string oppId, chargebeeapps__CB_Sites__c defaultSite, boolean plansonly)
{
     List<OpportunityLineItem> oppItems = new List<OpportunityLineItem>();
     List<PricebookEntry> pricebookenties = getPricebookEntries(defaultSite.Id);
     for(PricebookEntry pbentry:pricebookenties)
     {
         product2 product = getProduct(pbentry.Product2Id);
         
         if((product.chargebeeapps__Recurring_charge_model__c.equalsIgnorecase('Flat_Fee')) || (product.chargebeeapps__Addon_Type__c !=null && product.chargebeeapps__Addon_Type__c.equalsIgnorecase('Per_Unit')))
         {
             //if(product.chargebeeapps__Addon_Type__c == null)
             //{
             	OpportunityLineItem opplineitem = new OpportunityLineItem(OpportunityId = oppId,Quantity = 1,PricebookEntryId = pbentry.Id,TotalPrice = 1 * pbentry.UnitPrice);
	             oppItems.add(opplineitem);    
             //}             
         }
     }       
     insert oppItems;
     return oppItems;
}
    
public static OpportunityLineItem[] getOppLineItems(string oppId)
{
    return [select Product2Id,PricebookEntry.chargebeeapps__Setup_Cost__c,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Currency__c,
            Product2.chargebeeapps__Product_Type__c,Product2.chargebeeapps__Addon_Type__c,Product2.chargebeeapps__Addon_Applicability__c,Quantity,
            UnitPrice, Discount ,Product2.chargebeeapps__Recurring_charge_model__c,TotalPrice,OpportunityId 
            from OpportunityLineItem where OpportunityId =:oppId];
}
public static chargebeeapps__CB_Subscription__c insertSub()
{
    Account[] accTest = getAccounts();
    chargebeeapps__CB_Sites__c site = getSite();
    chargebeeapps__CB_Subscription__c cbsub = new chargebeeapps__CB_Subscription__c(Name='Hr5511nROMSd0r1urD',
                                                                                    chargebeeapps__CB_Site__c=site.Id,
                                                                                    chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD',                                                                                    
                                                                                    chargebeeapps__Company__c=accTest[0].Id,
                                                                                    chargebeeapps__Subscription_status__c='ACTIVE');
    insert cbsub;
    return cbsub;
}
public static List<chargebeeapps__Coupon__c> insertCoupons()
{
    system.debug('coupon loaded');
    chargebeeapps__CB_Sites__c sites1 = getSite();
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
            if(product.chargebeeapps__Recurring_charge_model__c.equalsIgnoreCase('Tiered') || product.chargebeeapps__Recurring_charge_model__c.equalsIgnoreCase('Flat_Fee'))
            {
                cbpricebookentry.chargebeeapps__Setup_Cost__c = 50;
            }
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
public static List<Product2> getProducts()
{
    return [select Name,ExternalId,chargebeeapps__Recurring_charge_model__c from Product2];
}
public static Product2 getProduct(string prodId)
{
    return [select Name,ExternalId,chargebeeapps__Product_Type__c,chargebeeapps__Recurring_charge_model__c,
            chargebeeapps__Addon_Type__c from product2 where Id=:prodId LIMIT 1];
}
public static List<Product2> getPlans(string plantype)
{
    return [select Name,ExternalId,chargebeeapps__Product_Type__c,chargebeeapps__Recurring_charge_model__c,
            chargebeeapps__Addon_Type__c from product2 where chargebeeapps__Product_Type__c=:plantype];
}
public static Product2 getSpecificProduct(string modeltype,string prodtype)
{
    return [select Name,ExternalId,chargebeeapps__Product_Type__c,chargebeeapps__Recurring_charge_model__c,
            chargebeeapps__Addon_Type__c from product2 where chargebeeapps__Product_Type__c=:prodtype and (chargebeeapps__Recurring_charge_model__c =:modeltype or chargebeeapps__Addon_Type__c =:modeltype)];
}
public static List<PricebookEntry> getPBEntryBySite(String siteId,String producttype)
{
    String siteIdinPBEntry='CB Standard'+siteId;
    List<PricebookEntry> pbentryList=[Select id,Product2.ExternalId,product2.name,Pricebook2.chargebeeapps__CB_Site__c,UnitPrice From PricebookEntry where PriceBook2.chargebeeapps__CB_Site__c=:siteId and Product2.chargebeeapps__Product_Type__c=:producttype];
    System.debug('Price Book Entry List ' + pbentryList);
    return pbentryList;
}    
public static List<PricebookEntry> getPricebookEntries(String siteId)
{
    String siteIdinPBEntry='CB Standard'+siteId;
    List<PricebookEntry> pbentryList=[Select id,Product2.ExternalId,product2.name,Pricebook2.chargebeeapps__CB_Site__c,UnitPrice  From PricebookEntry where PriceBook2.chargebeeapps__CB_Site__c=:siteId];
    System.debug('Price Book Entry List ' + pbentryList);
    return pbentryList;
}     

public static chargebeeapps__CB_Invoice__c insertInvoices(string subid)
{
    chargebeeapps__CB_Invoice__c inv = new chargebeeapps__CB_Invoice__c (Name='32',chargebeeapps__InvoiceID__c ='32',
                                                                         chargebeeapps__Status__c='PAYMENT_DUE',chargebeeapps__SubscriptionId__c= subid);
    insert inv;
    return inv;
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
    Contact contacts = getCBUnsynchedContact();
    chargebeeapps__CB_Sites__c sites1 = getSite();
    chargebeeapps__CB_Subscription__c sub= getSubscription('Hr5511nROMSd0r1urD');
    chargebeeapps__CB_Quote__c quote = new chargebeeapps__CB_Quote__c(Name='1', chargebeeapps__Operation_Type__c ='CREATE_SUBSCRIPTION_FOR_CUSTOMER',
                                                                                    chargebeeapps__CB_Site__c=sites1.Id,
                                                                                    chargebeeapps__CB_Quote_Id__c ='1',
                                                                                    chargebeeapps__CustomerID__c =contacts.Id,
                                                                                    chargebeeapps__Status__c='OPEN',
                                                                                    chargebeeapps__CB_Subscription__c=sub.Id,
                                                                                    chargebeeapps__Company__c=accTest[0].Id);
    chargebeeapps__CB_Quote__c quote1 = new chargebeeapps__CB_Quote__c(Name='2', chargebeeapps__Operation_Type__c ='CHANGE_SUBSCRIPTION',
                                                                                    chargebeeapps__CB_Site__c=sites1.Id,
                                                                                    chargebeeapps__CB_Quote_Id__c ='2',
                                                                                    chargebeeapps__CustomerID__c =contacts.Id,
                                                                                    chargebeeapps__Status__c='OPEN',
                                                                                    chargebeeapps__CB_Subscription__c=sub.Id,
                                                                                    chargebeeapps__Company__c=accTest[0].Id);
    List<chargebeeapps__CB_Quote__c> quotes = new List<chargebeeapps__CB_Quote__c>();
    quotes.add(quote);                                                                                                                                                               
    quotes.add(quote1);                                                                                                                                                               
    insert quotes;
    return quotes;
}

public class MetaDataUtility
{
    public boolean isFieldExist(String objectName,String fieldName)
    {
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        Set<String> fieldNames=mfields.keySet();
        System.debug(' Field Set for Object ' + objectName + fieldNames);
        if(fieldNames.contains(fieldName)) {
            return true;        
        }
        return false;
    }
}
    
        
}