@IsTest
public class InvoiceUnbilledTest
{
    
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
        
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c sites = TestdataUtility.getSites();
         
         Contact[] contacts = TestdataUtility.insertContacts();
         TestdataUtility.insertContactSite(sites.Id,contacts[0].Id);
    }
     @IsTest public static void testTrivial(){
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c consites = [select Id,chargebeeapps__CB_Site__c,chargebeeapps__Contact__c 
                                                              from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c =:con.Id];        
         Test.startTest();
         PageReference pageRef = Page.list_unbilled_charges;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('con_id',con.Id);//0030K00001eGwAs
         Test.setMock(HttpCalloutMock.class, new ListUnbilledChargeResponseGenerator());
         ListUnbilledChargesController lucc = new ListUnbilledChargesController();
         List<selectOption> multiSites = lucc.getSiteDetails();
         lucc.selectedSites='cbtest1';
         lucc.selectedSiteName();
         Test.setMock(HttpCalloutMock.class, new InvoiceUnbilledEstimateResponseGenerator());
         lucc.preview();
         PageReference p = lucc.save();
         Test.stopTest();
         system.assertEquals(p, null);
         
     }
     
     @IsTest public static void testCancelButton(){
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c consites = [select Id,chargebeeapps__CB_Site__c,chargebeeapps__Contact__c 
                                                              from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c =:con.Id];        
         Test.startTest();
         PageReference pageRef = Page.list_unbilled_charges;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('con_id',con.Id);//0030K00001eGwAs
         Test.setMock(HttpCalloutMock.class, new ListUnbilledChargeResponseGenerator());
         ListUnbilledChargesController lucc = new ListUnbilledChargesController();
         List<selectOption> multiSites = lucc.getSiteDetails();
         lucc.selectedSites='cbtest1';
         lucc.selectedSiteName();
         Test.setMock(HttpCalloutMock.class, new InvoiceUnbilledEstimateResponseGenerator());
         lucc.preview();
         PageReference p = lucc.Cancel();
         string url = p.getUrl();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__list_unbilled_charges'));
         
     }
     
     @IsTest public static void testNoCustInCB(){
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         Contact con = [select Id,LastName from Contact where LastName='test2' LIMIT 1];
           
         Test.startTest();
         PageReference pageRef = Page.list_unbilled_charges;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('con_id',con.Id);//0030K00001gsa5z  
         Test.setMock(HttpCalloutMock.class, new ListUnbilledChargeResponseGenerator());
         ListUnbilledChargesController lucc = new ListUnbilledChargesController();
         
         Test.setMock(HttpCalloutMock.class, new InvoiceUnbilledEstimateResponseGenerator());
         //lucc.preview();
         PageReference p = lucc.Cancel();
         string url = p.getUrl();
         lucc.backToContact();
         Test.stopTest();
         system.assert(url.contains('/apex/chargebeeapps__list_unbilled_charges'));
        } 
     
}