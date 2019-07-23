@IsTest
public class InvoiceUnbilledTest
{
    
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
        
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSite();
         
         TestdataUtility.insertContacts();
         Contact validcontact=TestdataUtility.getValidContact();
         TestdataUtility.associateContactToSite(site.Id,validcontact.Id);
         
    }
     @IsTest public static void testTrivial(){
         
         Contact con = TestdataUtility.getValidContact();
         
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
         
         Contact con = TestdataUtility.getValidContact();  
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
         
         Contact con = TestdataUtility.getCBUnsynchedContact();
           
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