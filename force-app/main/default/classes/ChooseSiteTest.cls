@IsTest public with sharing class ChooseSiteTest {
  
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         Account[] accts = TestdataUtility.getAccounts();
        TestdataUtility.insertContacts();
         
        Product2[] prod = TestdataUtility.insertProducts();
         system.debug('prod--'+prod);
         TestdataUtility.insertCoupons();
         
         List<string> extid = new List<string>();
         for(Product2 pr:prod)
         {
             string externalids = pr.ExternalId;
             extid.add(externalids); 
         }
         
         PricebookEntry[] pbentry = TestdataUtility.insertPBEntry(extid);
         system.debug('pbentry---'+pbentry[0].Product2.ExternalId);
         
         Opportunity optLi = new Opportunity(Name='test opp1',StageName='Prospecting',AccountId=accts[0].Id, Probability = 10,
                                      CloseDate=system.today(),Pricebook2Id=string.valueOf(pbentry[0].Pricebook2Id));
         insert optLi; 
         
    }
    
    @IsTest public static void test1() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Opportunity opt = [select Id,Name,StageName,CloseDate,Pricebook2Id from Opportunity where Name='test opp1' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);  
         Pricebook2 pricebk = [select Id,Name,chargebeeapps__CB_Site__c from Pricebook2 where Name='CB Standard'];
         system.debug('pricebk'+pricebk);
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         //OpportunityLineItem oli1 = [select Id,PricebookEntryId from OpportunityLineItem];
         //insert oli1;
         //system.debug('opt li '+oli1);
         PageReference pageRef = Page.Choose_site;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);//0060K00000WbYlfQAF
         ChooseSite cs = new ChooseSite();
         cs.selectedSite = 'cbtest1';
         PageReference p = cs.next(); 
         string url = p.getUrl();
         system.assert(url.contains('/apex/chargebeeapps__CBManageProduct'));
     }
     @IsTest public static void test2() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         //OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opt.Id,Quantity = 5,PricebookEntryId = selctedprod[0].Id,TotalPrice = 5 * 160);
         PageReference pageRef = Page.Choose_site;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt.Id);
         ChooseSite cs = new ChooseSite();
         cs.selectedSite = 'cbtest1';
         PageReference p = cs.next(); 
         string url = p.getUrl();
         system.assert(url.contains('/apex/chargebeeapps__CBManageProduct'));   
     }
     @IsTest public static void test3() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Opportunity[] opt = TestdataUtility.insertOpportunity();
         //Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         //OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opt.Id,Quantity = 5,PricebookEntryId = selctedprod[0].Id,TotalPrice = 5 * 160);
         PageReference pageRef = Page.Choose_site;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt[0].Id);
         ChooseSite cs = new ChooseSite();
         cs.selectedSite = 'cbtest1';
         cs.isMultiSite = true;
         cs.getSiteDetails();
         PageReference p = cs.next(); 
         string url = p.getUrl();
         system.assert(url.contains('/apex/chargebeeapps__CBManageProduct'));   
     }
     @IsTest public static void test4() 
     {
         
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Opportunity[] opt = TestdataUtility.insertOpportunity();
         //Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
         Product2[] prd = [select Name,ExternalId from Product2];
         system.debug('prd--'+prd);   
         PricebookEntry[] selctedprod = [select Id,Product2.Name,Product2.ExternalId from PricebookEntry];
         //OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opt.Id,Quantity = 5,PricebookEntryId = selctedprod[0].Id,TotalPrice = 5 * 160);
         PageReference pageRef = Page.Choose_site;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',opt[0].Id);
         ChooseSite cs = new ChooseSite();
         cs.selectedSite = 'cbtest1';
         PageReference p = cs.back(); 
         string url = p.getUrl();
         system.assert(url.contains('/'+opt[0].Id));
     }
}