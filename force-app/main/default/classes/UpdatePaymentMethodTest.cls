@IsTest public with sharing class UpdatePaymentMethodTest 
{
   
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         
         TestdataUtility.insertContacts();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSite();
         Contact validcontact=TestdataUtility.getValidContact();
         TestdataUtility.associateContactToSite(site.Id,validcontact.Id);
         
    }
    @IsTest public static void test1() 
     {
        
         Contact con = TestdataUtility.getValidContact();
                 
         Test.startTest();
         PageReference pageRef = Page.UpdatePaymentMethod;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);//0030K00001pxTOB
         UpdatePaymentMethod cbu = new UpdatePaymentMethod();
         cbu.fetchLinkUrl('cbtest1');
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(0,callouts);
     
     }
     
     @IsTest public static void test2() 
     {
         
         Contact con = TestdataUtility.getValidContact();
                 
         Test.startTest();
         PageReference pageRef = Page.UpdatePaymentMethod;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id',con.Id);
         UpdatePaymentMethod cbu = new UpdatePaymentMethod();
         cbu.selectedSites='cbtest1';
         cbu.getSiteDetails();
         cbu.check();
         
         //cbu.fetchLinkForRedirection();
         cbu.send();
         cbu.cancel();
         cbu.redirectToError('error','obj');
         Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(0,callouts);
     
     }     
 }