@IsTest public with sharing class UpdatePaymentMethodTest 
{
   
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         
         TestdataUtility.insertContacts();
         
    }
    @IsTest public static void test1() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         //Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,con.Id);        
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
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         //Account acc = [select Id,Name from Account where Name='SfTest1' LIMIT 1];
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites1.Id,con.Id);        
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