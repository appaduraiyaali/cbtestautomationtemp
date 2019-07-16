@IsTest
public class AddChargeTest 
{
   
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();        
        TestdataUtility.insertSiteDetails();       
        chargebeeapps__CB_Subscription__c subs = TestdataUtility.insertSub();
    }
     @IsTest
     public static void test1() 
     {
         chargebeeapps__CB_Subscription__c sub = [select Id,Name,chargebeeapps__CB_Site__c,
                                                  chargebeeapps__CB_Subscription_Id__c,chargebeeapps__Company__c
                                                 from chargebeeapps__CB_Subscription__c where chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD'];
         Test.startTest();
         PageReference pageRef = Page.Add_Charge;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',sub.chargebeeapps__CB_Subscription_Id__c);
         pageRef.getParameters().put('pk',sub.Id);
         AddCharge ch = new AddCharge();
         ch.checkPermissions();
         ch.invoiceOpt = 'ADD_UNBILLED_CHARGE';
         ch.amount = '1000';
         ch.description = 'test';
         ch.save();
     	 Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(0,callouts);
     }
     
    @IsTest
     public static void test2() 
     {
         chargebeeapps__CB_Subscription__c sub = [select Id,Name,chargebeeapps__CB_Site__c,
                                                  chargebeeapps__CB_Subscription_Id__c,chargebeeapps__Company__c
                                                 from chargebeeapps__CB_Subscription__c where chargebeeapps__CB_Subscription_Id__c='Hr5511nROMSd0r1urD'];
         Test.startTest();
         PageReference pageRef = Page.Add_Charge;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('sub_id',sub.chargebeeapps__CB_Subscription_Id__c);
         pageRef.getParameters().put('pk',sub.Id);
         AddCharge ch = new AddCharge();
         ch.invoiceOpt = 'INVOICE_NOW';
         ch.amount = '1000';
         ch.description = 'test';
         ch.save();
     	 Integer callouts = Limits.getCallouts();
         Test.stopTest();
         system.assertequals(0,callouts);
     }     
 }